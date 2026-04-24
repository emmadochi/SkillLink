<?php
namespace models;

use core\Database;
use PDO;

class Artisan {
    private $conn;
    private $table = "artisans";

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
        if (!$this->conn) {
            header('Content-Type: application/json');
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Database connection failed']);
            exit;
        }
    }

    /**
     * Search artisans by category, location, and rating.
     */
    public function search($filters = []) {
        $query = "SELECT u.id as user_id, u.name, u.avatar_url, a.bio, a.skill, a.category_id, a.average_rating, a.experience_years, a.location_name, a.hourly_rate
                  FROM " . $this->table . " a
                  JOIN users u ON u.id = a.user_id
                  WHERE (a.verification_status = 'approved' OR a.verification_status = 'verified' OR a.verification_status = 'pending') 
                  AND a.is_available = 1";
        
        if (!empty($filters['category_id'])) {
            $query .= " AND a.category_id = :cat_id";
        }

        if (!empty($filters['min_rating'])) {
            $query .= " AND a.average_rating >= :min_rating";
        }

        if (!empty($filters['query'])) {
            $query .= " AND (u.name LIKE :q OR a.bio LIKE :q OR a.skill LIKE :q OR a.location_name LIKE :q)";
        }

        $query .= " ORDER BY a.average_rating DESC";
        
        $stmt = $this->conn->prepare($query);

        if (!empty($filters['category_id'])) {
            $stmt->bindParam(':cat_id', $filters['category_id']);
        }
        if (!empty($filters['min_rating'])) {
            $stmt->bindParam(':min_rating', $filters['min_rating']);
        }
        if (!empty($filters['query'])) {
            $searchTerm = '%' . $filters['query'] . '%';
            $stmt->bindParam(':q', $searchTerm);
        }

        $stmt->execute();
        $artisans = $stmt->fetchAll();

        return array_map(function($a) {
            $res = [];
            foreach ($a as $key => $value) {
                $res[$key] = is_string($value) ? mb_convert_encoding($value, 'UTF-8', 'UTF-8') : $value;
            }
            
            $res['user'] = [
                'id' => (int)($a['user_id'] ?? 0),
                'name' => mb_convert_encoding($a['name'] ?? 'Artisan', 'UTF-8', 'UTF-8'),
                'avatar_url' => $a['avatar_url'] ?? ''
            ];
            $res['average_rating'] = (float)($a['average_rating'] ?? 0.0);
            $res['experience_years'] = (int)($a['experience_years'] ?? 0);
            $res['hourly_rate'] = (float)($a['hourly_rate'] ?? 0.0);
            return $res;
        }, $artisans ?: []);
    }

    /**
     * Get artisan full profile details.
     */
    public function getProfile($id) {
        $query = "SELECT u.id as user_id, u.name, u.email, u.phone, u.avatar_url, a.*,
                  (SELECT status FROM artisan_verifications WHERE artisan_id = a.user_id ORDER BY created_at DESC LIMIT 1) as identity_status
                  FROM " . $this->table . " a
                  JOIN users u ON u.id = a.user_id
                  WHERE a.user_id = :id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->execute();
        $profile = $stmt->fetch();

        if ($profile) {
            $profile['user'] = [
                'id' => $profile['user_id'],
                'name' => $profile['name'],
                'email' => $profile['email'],
                'phone' => $profile['phone'],
                'avatar_url' => $profile['avatar_url']
            ];
            // Get portfolio
            $profile['portfolio'] = $this->getPortfolio($id);
            // Get reviews
            $profile['reviews'] = $this->getReviews($id);
            // Cast types
            $profile['average_rating'] = (float)($profile['average_rating'] ?? 0.0);
            $profile['experience_years'] = (int)($profile['experience_years'] ?? 0);
            $profile['hourly_rate'] = (float)($profile['hourly_rate'] ?? 0.0);
            $profile['identity_verified'] = (bool)($profile['identity_verified'] ?? false);
        }

        return $profile;
    }

    public function getReviews($artisan_id) {
        $query = "SELECT r.*, u.name as customer_name, u.avatar_url as customer_avatar 
                  FROM reviews r
                  JOIN users u ON u.id = r.customer_id
                  WHERE r.artisan_id = :aid 
                  ORDER BY r.created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':aid', $artisan_id);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    public function getPortfolio($artisan_id) {
        $query = "SELECT * FROM artisan_portfolios WHERE artisan_id = :aid ORDER BY created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':aid', $artisan_id);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    public function updateProfile($data) {
        // Check if artisan record exists
        $query = "SELECT user_id FROM " . $this->table . " WHERE user_id = :uid";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':uid', $data['user_id']);
        $stmt->execute();
        $exists = $stmt->fetch();

        if ($exists) {
            $query = "UPDATE " . $this->table . " 
                      SET bio = :bio, skill = :skill, experience_years = :exp, 
                          location_name = :loc, latitude = :lat, longitude = :lng,
                          business_address = :b_addr, guarantor_name = :g_name, guarantor_phone = :g_phone,
                          is_available = :avail, hourly_rate = :rate
                      WHERE user_id = :uid";
        } else {
            $query = "INSERT INTO " . $this->table . " 
                      (user_id, bio, skill, experience_years, location_name, latitude, longitude, 
                       business_address, guarantor_name, guarantor_phone, verification_status, is_available, hourly_rate) 
                      VALUES (:uid, :bio, :skill, :exp, :loc, :lat, :lng, :b_addr, :g_name, :g_phone, 'pending', :avail, :rate)";
        }

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':uid', $data['user_id']);
        $stmt->bindParam(':bio', $data['bio']);
        $stmt->bindParam(':skill', $data['skill']);
        $stmt->bindParam(':exp', $data['experience_years']);
        $stmt->bindParam(':loc', $data['location_name']);
        $stmt->bindParam(':lat', $data['latitude']);
        $stmt->bindParam(':lng', $data['longitude']);
        $stmt->bindParam(':b_addr', $data['business_address']);
        $stmt->bindParam(':g_name', $data['guarantor_name']);
        $stmt->bindParam(':g_phone', $data['guarantor_phone']);
        $avail = isset($data['is_available']) ? (int)$data['is_available'] : 1;
        $stmt->bindParam(':avail', $avail);
        $rate = isset($data['hourly_rate']) ? (float)$data['hourly_rate'] : 0.0;
        $stmt->bindParam(':rate', $rate);

        return $stmt->execute();
    }

    public function submitVerification($data) {
        $query = "INSERT INTO artisan_verifications 
                  (artisan_id, id_type, id_number, id_image_front, id_image_back, passport_photo, status) 
                  VALUES (:aid, :type, :num, :front, :back, :passport, 'pending')";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':aid', $data['artisan_id']);
        $stmt->bindParam(':type', $data['id_type']);
        $stmt->bindParam(':num', $data['id_number']);
        $stmt->bindParam(':front', $data['id_image_front']);
        $stmt->bindParam(':back', $data['id_image_back']);
        $stmt->bindParam(':passport', $data['passport_photo']);

        return $stmt->execute();
    }

    public function addPortfolioItem($artisan_id, $image_url, $description = "") {
        $query = "INSERT INTO artisan_portfolios (artisan_id, image_url, description) 
                  VALUES (:aid, :url, :desc)";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':aid', $artisan_id);
        $stmt->bindParam(':url', $image_url);
        $stmt->bindParam(':desc', $description);

        return $stmt->execute();
    }
}
