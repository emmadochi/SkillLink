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
    }

    /**
     * Create a new review.
     */
    public function create($data) {
        $query = "INSERT INTO " . $this->table . " (booking_id, customer_id, artisan_id, rating, comment) 
                  VALUES (:bid, :cid, :aid, :rate, :comment)";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':bid', $data['booking_id']);
        $stmt->bindParam(':cid', $data['customer_id']);
        $stmt->bindParam(':aid', $data['artisan_id']);
        $stmt->bindParam(':rate', $data['rating']);
        $stmt->bindParam(':comment', $data['comment']);

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
                  average_rating = (SELECT AVG(rating) FROM reviews WHERE artisan_id = :id1),
                  total_reviews = (SELECT COUNT(*) FROM reviews WHERE artisan_id = :id2)
                  WHERE user_id = :id3";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id1', $artisanId);
        $stmt->bindParam(':id2', $artisanId);
        $stmt->bindParam(':id3', $artisanId);
        $stmt->execute();
    }
}
