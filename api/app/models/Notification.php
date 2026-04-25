<?php
namespace models;

use core\Database;
use PDO;

class Notification {
    private $conn;
    private $table = "notifications";

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
        if (!$this->conn) {
            header('Content-Type: application/json');
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Database connection failed']);
            exit;
        }
        
        // Self-healing: Ensure notifications table exists
        $this->ensureTableExists();
    }

    private function ensureTableExists() {
        $sql = "CREATE TABLE IF NOT EXISTS notifications (
            id INT AUTO_INCREMENT PRIMARY KEY,
            user_id INT NOT NULL,
            type VARCHAR(50) NOT NULL,
            title VARCHAR(255) NOT NULL,
            message TEXT NOT NULL,
            related_id INT,
            is_read TINYINT(1) DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";
        try {
            $this->conn->exec($sql);
        } catch (\PDOException $e) {
            // Ignore
        }
    }

    public function create($data) {
        $query = "INSERT INTO " . $this->table . " (user_id, type, title, message, related_id) 
                  VALUES (:user_id, :type, :title, :message, :related_id)";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $data['user_id']);
        $stmt->bindParam(':type', $data['type']);
        $stmt->bindParam(':title', $data['title']);
        $stmt->bindParam(':message', $data['message']);
        $stmt->bindParam(':related_id', $data['related_id']);

        return $stmt->execute();
    }

    public function getByUser($userId) {
        $query = "SELECT * FROM " . $this->table . " WHERE user_id = :user_id ORDER BY created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $userId);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function markAsRead($userId, $notificationId = null) {
        if ($notificationId) {
            $query = "UPDATE " . $this->table . " SET is_read = 1 WHERE id = :id AND user_id = :user_id";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':id', $notificationId);
            $stmt->bindParam(':user_id', $userId);
        } else {
            $query = "UPDATE " . $this->table . " SET is_read = 1 WHERE user_id = :user_id";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':user_id', $userId);
        }
        return $stmt->execute();
    }
}
