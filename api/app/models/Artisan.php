<?php
namespace models;

use core\Database;
use PDO;

class Artisan {
    private $conn;
    private $table = "artisans";

    private static $tablesEnsured = false;

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
        if (!$this->conn) {
            header('Content-Type: application/json');
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Database connection failed']);
            exit;
        }
        
        // Self-healing: Ensure saved_artisans table exists (run only once per request)
        if (!self::$tablesEnsured) {
            $this->ensureTablesExist();
            self::$tablesEnsured = true;
        }
    }

    private function ensureTablesExist() {
        $sql = "CREATE TABLE IF NOT EXISTS saved_artisans (
            user_id INT, 
            artisan_id INT, 
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
            PRIMARY KEY (user_id, artisan_id), 
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE, 
            FOREIGN KEY (artisan_id) REFERENCES artisans(user_id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";
        try {
            $this->conn->exec($sql);
        } catch (\PDOException $e) {
            // Ignore if already exists or other non-critical errors
        }
    }

    /**
     * Search artisans by category, location, and rating.
     */
    public function search($filters = []) {
        $query = "SELECT u.id as user_id, u.name, u.avatar_url, a.bio, a.skill, a.category_id, a.average_rating, a.experience_years, a.location_name, a.hourly_rate
                  FROM " . $this->table . " a
                  JOIN users u ON u.id = a.user_id
                  WHERE (a.verification_status = 'approved' OR a.verification_status = 'verified') 
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

        if (!empty($filters['skills'])) {
            $skills = is_array($filters['skills']) ? $filters['skills'] : explode(',', $filters['skills']);
            $skillConditions = [];
            foreach ($skills as $index => $skill) {
                $paramName = ":skill_" . $index;
                $skillConditions[] = "(a.bio LIKE $paramName OR a.skill LIKE $paramName)";
            }
            if (!empty($skillConditions)) {
                $query .= " AND (" . implode(' OR ', $skillConditions) . ")";
            }
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

        if (!empty($filters['skills'])) {
            $skills = is_array($filters['skills']) ? $filters['skills'] : explode(',', $filters['skills']);
            foreach ($skills as $index => $skill) {
                $paramName = ":skill_" . $index;
                $val = '%' . trim($skill) . '%';
                $stmt->bindValue($paramName, $val);
            }
        }

        $stmt->execute();
        $artisans = $stmt->fetchAll();

        return array_map(function($a) {
            $a['user'] = [
                'id' => (int)($a['user_id'] ?? 0),
                'name' => $a['name'] ?? 'Artisan',
                'avatar_url' => $a['avatar_url'] ?? ''
            ];
            $a['average_rating'] = (float)($a['average_rating'] ?? 0.0);
            $a['experience_years'] = (int)($a['experience_years'] ?? 0);
            $a['hourly_rate'] = (float)($a['hourly_rate'] ?? 0.0);
            return $a;
        }, $artisans ?: []);
    }

    /**
     * Get artisan full profile details.
     */
    public function getProfile($id, $currentUserId = null) {
        $query = "SELECT u.id as user_id, u.name, u.email, u.phone, u.avatar_url, u.role,
                         a.bio, a.skill, a.category_id, a.experience_years, a.average_rating,
                         a.location_name, a.business_address, a.guarantor_name, a.guarantor_phone,
                         a.identity_verified, a.verification_status, a.is_available, a.hourly_rate,
                         (SELECT status FROM artisan_verifications WHERE artisan_id = u.id ORDER BY created_at DESC LIMIT 1) as identity_status
                  FROM users u
                  LEFT JOIN " . $this->table . " a ON a.user_id = u.id
                  WHERE u.id = :id LIMIT 1";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->execute();
        $row = $stmt->fetch();

        if (!$row) return null;

        $profile = $row;
        $profile['user'] = [
            'id' => (int)$row['user_id'],
            'name' => $row['name'],
            'email' => $row['email'],
            'phone' => $row['phone'],
            'avatar_url' => $row['avatar_url']
        ];
        
        // Get portfolio, reviews & sub-services
        $profile['portfolio'] = $this->getPortfolio($id);
        $profile['reviews'] = $this->getReviews($id);
        $profile['sub_services'] = $this->getSubServices($id);

        
        // Check if saved
        $profile['is_saved'] = false;
        if ($currentUserId) {
            $sQuery = "SELECT 1 FROM saved_artisans WHERE user_id = :cuid AND artisan_id = :aid";
            $sStmt = $this->conn->prepare($sQuery);
            $sStmt->bindParam(':cuid', $currentUserId);
            $sStmt->bindParam(':aid', $id);
            $sStmt->execute();
            $profile['is_saved'] = $sStmt->fetch() ? true : false;
        }

        // Cast types
        $profile['average_rating'] = (float)($profile['average_rating'] ?? 0.0);
        $profile['experience_years'] = (int)($profile['experience_years'] ?? 0);
        $profile['hourly_rate'] = (float)($profile['hourly_rate'] ?? 0.0);
        $profile['identity_verified'] = (bool)($profile['identity_verified'] ?? false);

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

    public function getSubServices($artisan_id) {
        $query = "SELECT cs.id, cs.service_name 
                  FROM artisan_sub_services ass
                  JOIN category_services cs ON cs.id = ass.sub_service_id
                  WHERE ass.artisan_id = :aid";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':aid', $artisan_id);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function updateSubServices($artisan_id, $sub_service_ids) {
        // 1. Delete existing
        $del = $this->conn->prepare("DELETE FROM artisan_sub_services WHERE artisan_id = :aid");
        $del->execute([':aid' => $artisan_id]);

        if (empty($sub_service_ids)) return true;

        // 2. Insert new
        if (is_string($sub_service_ids)) {
            $sub_service_ids = explode(',', $sub_service_ids);
        }

        $query = "INSERT INTO artisan_sub_services (artisan_id, sub_service_id) VALUES (:aid, :sid)";
        $stmt = $this->conn->prepare($query);
        
        foreach ($sub_service_ids as $sid) {
            if (empty($sid)) continue;
            $stmt->execute([':aid' => $artisan_id, ':sid' => (int)$sid]);
        }
        
        return true;
    }
}

