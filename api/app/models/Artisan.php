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
        $query = "SELECT u.id, u.name, u.avatar_url, a.bio, a.skill, a.average_rating, a.experience_years, a.location_name
                  FROM " . $this->table . " a
                  JOIN users u ON u.id = a.user_id
                  WHERE a.verification_status = 'approved'";
        
        if (!empty($filters['category_id'])) {
            $query .= " AND a.user_id IN (SELECT artisan_id FROM artisan_categories WHERE category_id = :cat_id)";
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
        return $stmt->fetchAll();
    }

    /**
     * Get artisan full profile details.
     */
    public function getProfile($id) {
        $query = "SELECT u.id, u.name, u.email, u.phone, u.avatar_url, a.*
                  FROM " . $this->table . " a
                  JOIN users u ON u.id = a.user_id
                  WHERE a.user_id = :id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->execute();
        return $stmt->fetch();
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
                          location_name = :loc, latitude = :lat, longitude = :lng 
                      WHERE user_id = :uid";
        } else {
            $query = "INSERT INTO " . $this->table . " 
                      (user_id, bio, skill, experience_years, location_name, latitude, longitude, verification_status) 
                      VALUES (:uid, :bio, :skill, :exp, :loc, :lat, :lng, 'approved')"; // Auto-approve for demo
        }

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':uid', $data['user_id']);
        $stmt->bindParam(':bio', $data['bio']);
        $stmt->bindParam(':skill', $data['skill']);
        $stmt->bindParam(':exp', $data['experience_years']);
        $stmt->bindParam(':loc', $data['location_name']);
        $stmt->bindParam(':lat', $data['latitude']);
        $stmt->bindParam(':lng', $data['longitude']);

        return $stmt->execute();
    }
}
