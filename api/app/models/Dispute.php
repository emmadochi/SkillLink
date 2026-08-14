<?php
namespace models;

use core\Database;
use PDO;

class Dispute {
    private $conn;
    private $table = "disputes";

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
        if (!$this->conn) {
            header('Content-Type: application/json');
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Database connection failed']);
            exit;
        }
        $this->ensureTableExists();
    }

    /**
     * Self-healing table check.
     */
    private function ensureTableExists() {
        $sql = "CREATE TABLE IF NOT EXISTS `disputes` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `booking_id` INT NOT NULL,
            `raised_by` INT NOT NULL COMMENT 'user_id of reporter',
            `reason` TEXT NOT NULL,
            `status` ENUM('open','under_review','resolved','closed') DEFAULT 'open',
            `resolution` TEXT,
            `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX (`booking_id`),
            INDEX (`raised_by`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";
        $this->conn->exec($sql);
    }

    /**
     * Create a dispute for a booking.
     */
    public function create($bookingId, $userId, $reason) {
        // 1. Verify booking exists and user is participant
        $bookingQuery = "SELECT * FROM bookings WHERE id = :bid";
        $bStmt = $this->conn->prepare($bookingQuery);
        $bStmt->bindParam(':bid', $bookingId, PDO::PARAM_INT);
        $bStmt->execute();
        $booking = $bStmt->fetch(PDO::FETCH_ASSOC);

        if (!$booking) {
            return ['success' => false, 'message' => 'Booking not found'];
        }

        if ($booking['customer_id'] != $userId && $booking['artisan_id'] != $userId) {
            return ['success' => false, 'message' => 'You are not authorized to dispute this booking'];
        }

        // 2. Check if open dispute already exists
        $checkQuery = "SELECT id, status FROM " . $this->table . " WHERE booking_id = :bid AND status IN ('open', 'under_review')";
        $cStmt = $this->conn->prepare($checkQuery);
        $cStmt->bindParam(':bid', $bookingId, PDO::PARAM_INT);
        $cStmt->execute();
        if ($cStmt->fetch()) {
            return ['success' => false, 'message' => 'An active dispute is already open for this booking'];
        }

        // 3. Insert dispute
        $query = "INSERT INTO " . $this->table . " (booking_id, raised_by, reason, status) 
                  VALUES (:bid, :uid, :reason, 'open')";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':bid', $bookingId, PDO::PARAM_INT);
        $stmt->bindParam(':uid', $userId, PDO::PARAM_INT);
        $stmt->bindParam(':reason', $reason);

        if ($stmt->execute()) {
            $disputeId = $this->conn->lastInsertId();

            // 4. Send notification to other party
            $recipientId = ($booking['customer_id'] == $userId) ? $booking['artisan_id'] : $booking['customer_id'];
            $notifModel = new Notification();
            $notifModel->create([
                'user_id' => $recipientId,
                'type' => 'booking',
                'title' => 'Dispute Lodged',
                'message' => 'A dispute has been raised on booking #' . $booking['booking_number'] . '. Our mediation team will review it.',
                'related_id' => $bookingId
            ]);

            return [
                'success' => true,
                'dispute_id' => $disputeId,
                'message' => 'Dispute submitted successfully. Admin support has been alerted.'
            ];
        }

        return ['success' => false, 'message' => 'Failed to submit dispute'];
    }

    /**
     * Get dispute by booking ID.
     */
    public function getByBooking($bookingId, $userId) {
        $query = "SELECT d.*, u.name as raised_by_name 
                  FROM " . $this->table . " d
                  JOIN users u ON u.id = d.raised_by
                  WHERE d.booking_id = :bid 
                  ORDER BY d.created_at DESC LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':bid', $bookingId, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    /**
     * Get all disputes raised by or involving a user.
     */
    public function getByUser($userId) {
        $query = "SELECT d.*, b.booking_number, b.status as booking_status, c.name as category_name
                  FROM " . $this->table . " d
                  JOIN bookings b ON b.id = d.booking_id
                  JOIN categories c ON c.id = b.category_id
                  WHERE d.raised_by = :uid OR b.customer_id = :uid OR b.artisan_id = :uid
                  ORDER BY d.created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':uid', $userId, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
