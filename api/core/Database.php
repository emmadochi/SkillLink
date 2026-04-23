<?php
namespace core;

use PDO;
use PDOException;

class Database {
    private $host = "localhost";
    private $db_name = "skilllink_db";
    private $username = "root";
    private $password = "";
    public $conn;

    public function getConnection() {
        $this->conn = null;

        try {
            $this->conn = new PDO("mysql:host=" . $this->host . ";dbname=" . $this->db_name, $this->username, $this->password);
            $this->conn->exec("set names utf8mb4");
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            $this->conn->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
        } catch(PDOException $exception) {
            // Log error instead of echoing to avoid breaking JSON responses
            error_log("Database Connection Error: " . $exception->getMessage());
            return null;
        }

        return $this->conn;
    }
}
