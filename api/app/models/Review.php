<?php
namespace models;

use core\Database;
use PDO;

class Review {
    private $conn;
    private $table = "reviews";

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
        if (!$this->conn) {
            header('Content-Type: application/json');
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Database connection failed']);
            exit;
        }

        $this->ensureSchema();
    }

    private function ensureSchema() {
        try {
            $cols = [
                "quality_tags" => "TEXT DEFAULT NULL",
                "before_photo_url" => "VARCHAR(255) DEFAULT NULL",
                "after_photo_url" => "VARCHAR(255) DEFAULT NULL"
            ];

            foreach ($cols as $col => $def) {
                $check = $this->conn->query("SHOW COLUMNS FROM {$this->table} LIKE '{$col}'");
                if ($check && $check->rowCount() === 0) {
                    $this->conn->exec("ALTER TABLE {$this->table} ADD COLUMN {$col} {$def}");
                }
            }
        } catch (\Throwable $e) {
            // Ignore schema alter errors
        }
    }

    /**
     * Create a new review with ratings, quality tags, and photo proof.
     */
    public function create($data) {
        $qualityTags = isset($data['quality_tags']) 
            ? (is_array($data['quality_tags']) ? json_encode($data['quality_tags']) : $data['quality_tags']) 
            : null;
        $beforePhoto = $data['before_photo_url'] ?? null;
        $afterPhoto = $data['after_photo_url'] ?? null;

        $query = "INSERT INTO " . $this->table . " 
                  (booking_id, customer_id, artisan_id, rating, comment, quality_tags, before_photo_url, after_photo_url) 
                  VALUES (:bid, :cid, :aid, :rate, :comment, :tags, :bphoto, :aphoto)";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':bid', $data['booking_id']);
        $stmt->bindParam(':cid', $data['customer_id']);
        $stmt->bindParam(':aid', $data['artisan_id']);
        $stmt->bindParam(':rate', $data['rating']);
        $stmt->bindParam(':comment', $data['comment']);
        $stmt->bindParam(':tags', $qualityTags);
        $stmt->bindParam(':bphoto', $beforePhoto);
        $stmt->bindParam(':aphoto', $afterPhoto);

        if ($stmt->execute()) {
            $this->updateArtisanRating($data['artisan_id']);
            return true;
        }
        return false;
    }

    /**
     * Recalculate artisan average rating.
     */
    private function updateArtisanRating($artisanId) {
        $query = "UPDATE artisans SET 
                  average_rating = COALESCE((SELECT AVG(rating) FROM reviews WHERE artisan_id = :id1), 5.0),
                  total_reviews = COALESCE((SELECT COUNT(*) FROM reviews WHERE artisan_id = :id2), 0)
                  WHERE user_id = :id3";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id1', $artisanId);
        $stmt->bindParam(':id2', $artisanId);
        $stmt->bindParam(':id3', $artisanId);
        $stmt->execute();
    }
}
