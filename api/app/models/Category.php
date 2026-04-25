<?php
namespace models;

use core\Database;
use PDO;

class Category {
    private $conn;
    private $table = "categories";

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
     * Get all categories.
     */
    public function getAll() {
        $query = "SELECT id, name, slug, icon, is_technical FROM " . $this->table . " ORDER BY name ASC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get sub-services for a specific category.
     */
    public function getServicesByCategoryId($categoryId) {
        $query = "SELECT * FROM category_services WHERE category_id = :cid ORDER BY service_name ASC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':cid', $categoryId);
        $stmt->execute();
        return $stmt->fetchAll();
    }
}
