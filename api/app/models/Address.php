<?php
namespace models;

use core\Database;
use PDO;

class Address {
    private $conn;
    private $table = "user_addresses";

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

    public function getByUser($userId) {
        $query = "SELECT * FROM " . $this->table . " WHERE user_id = :uid ORDER BY is_default DESC, created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':uid', $userId);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    public function create($data) {
        // If is_default is true, unset other defaults for this user
        if (!empty($data['is_default'])) {
            $this->clearDefaults($data['user_id']);
        }

        $query = "INSERT INTO " . $this->table . " (user_id, label, address, latitude, longitude, is_default) 
                  VALUES (:uid, :label, :addr, :lat, :lng, :def)";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':uid', $data['user_id']);
        $stmt->bindParam(':label', $data['label']);
        $stmt->bindParam(':addr', $data['address']);
        $stmt->bindParam(':lat', $data['latitude']);
        $stmt->bindParam(':lng', $data['longitude']);
        $stmt->bindParam(':def', $data['is_default'], PDO::PARAM_BOOL);

        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        return false;
    }

    public function delete($id, $userId) {
        $query = "DELETE FROM " . $this->table . " WHERE id = :id AND user_id = :uid";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->bindParam(':uid', $userId);
        return $stmt->execute();
    }

    private function clearDefaults($userId) {
        $query = "UPDATE " . $this->table . " SET is_default = 0 WHERE user_id = :uid";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':uid', $userId);
        $stmt->execute();
    }
}
