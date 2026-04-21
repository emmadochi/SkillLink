<?php
namespace models;

use core\Database;
use PDO;

class User {
    private $conn;
    private $table = "users";

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    /**
     * Find user by email.
     */
    public function findByEmail($email) {
        $query = "SELECT * FROM " . $this->table . " WHERE email = :email LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':email', $email);
        $stmt->execute();
        return $stmt->fetch();
    }

    /**
     * Create new user.
     */
    public function create($data) {
        $query = "INSERT INTO " . $this->table . " (name, email, phone, password_hash, role) 
                  VALUES (:name, :email, :phone, :password, :role)";
        
        $stmt = $this->conn->prepare($query);
        
        $stmt->bindParam(':name', $data['name']);
        $stmt->bindParam(':email', $data['email']);
        $stmt->bindParam(':phone', $data['phone']);
        $stmt->bindParam(':password', $data['password']);
        $stmt->bindParam(':role', $data['role']);

        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        return false;
    }

    /**
     * Create artisan profile.
     */
    public function createArtisanProfile($data) {
        $query = "INSERT INTO artisans (user_id, bio, experience_years) 
                  VALUES (:user_id, :bio, :experience)";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':user_id', $data['user_id']);
        $stmt->bindParam(':bio', $data['bio']);
        $stmt->bindParam(':experience', $data['experience']);

        return $stmt->execute();
    }
}
