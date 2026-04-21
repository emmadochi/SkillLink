<?php
namespace models;

use core\Database;
use PDO;

class Booking {
    private $conn;
    private $table = "bookings";

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    /**
     * Create a new booking request.
     */
    public function create($data) {
        $query = "INSERT INTO " . $this->table . " 
                  (booking_number, customer_id, artisan_id, category_id, service_description, scheduled_at, price, platform_fee, artisan_payout) 
                  VALUES (:bno, :cid, :aid, :catid, :desc, :sch, :pr, :fee, :po)";
        
        $stmt = $this->conn->prepare($query);
        
        $stmt->bindParam(':bno', $data['booking_number']);
        $stmt->bindParam(':cid', $data['customer_id']);
        $stmt->bindParam(':aid', $data['artisan_id']);
        $stmt->bindParam(':catid', $data['category_id']);
        $stmt->bindParam(':desc', $data['service_description']);
        $stmt->bindParam(':sch', $data['scheduled_at']);
        $stmt->bindParam(':pr', $data['price']);
        $stmt->bindParam(':fee', $data['platform_fee']);
        $stmt->bindParam(':po', $data['artisan_payout']);

        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        return false;
    }

    /**
     * Get bookings by user (Customer or Artisan).
     */
    public function getByUser($userId, $role = 'customer') {
        $field = ($role === 'customer') ? 'customer_id' : 'artisan_id';
        $otherRole = ($role === 'customer') ? 'u_artisan' : 'u_customer';
        
        $relJoin = ($role === 'customer') ? 'JOIN users u_artisan ON u_artisan.id = b.artisan_id' : 'JOIN users u_customer ON u_customer.id = b.customer_id';

        $query = "SELECT b.*, u_other.name as partner_name, u_other.avatar_url as partner_avatar, c.name as category_name
                  FROM " . $this->table . " b
                  JOIN categories c ON c.id = b.category_id ";
        
        if ($role === 'customer') {
            $query .= "JOIN users u_other ON u_other.id = b.artisan_id ";
        } else {
            $query .= "JOIN users u_other ON u_other.id = b.customer_id ";
        }

        $query .= "WHERE b.$field = :uid ORDER BY b.created_at DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':uid', $userId);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    /**
     * Update booking status.
     */
    public function updateStatus($id, $status) {
        $query = "UPDATE " . $this->table . " SET status = :status WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':status', $status);
        $stmt->bindParam(':id', $id);
        return $stmt->execute();
    }
}
