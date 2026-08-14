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
        if (!$this->conn) {
            header('Content-Type: application/json');
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Database connection failed']);
            exit;
        }
    }

    /**
     * Create a new booking request.
     */
    public function create($data) {
        $offerPrice = isset($data['offer_price']) ? floatval($data['offer_price']) : null;
        $status = $offerPrice ? 'pending_artisan' : 'none';
        
        $query = "INSERT INTO " . $this->table . " 
                  (booking_number, customer_id, artisan_id, category_id, service_description, scheduled_at, price, offer_price, negotiation_status, platform_fee, artisan_payout) 
                  VALUES (:bno, :cid, :aid, :catid, :desc, :sch, :pr, :opr, :nstat, :fee, :po)";
        
        $stmt = $this->conn->prepare($query);
        
        $stmt->bindParam(':bno', $data['booking_number']);
        $stmt->bindParam(':cid', $data['customer_id']);
        $stmt->bindParam(':aid', $data['artisan_id']);
        $stmt->bindParam(':catid', $data['category_id']);
        $stmt->bindParam(':desc', $data['service_description']);
        $stmt->bindParam(':sch', $data['scheduled_at']);
        $stmt->bindParam(':pr', $data['price']);
        $stmt->bindParam(':opr', $offerPrice);
        $stmt->bindParam(':nstat', $status);
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
        // Normalize role and set filtering field
        $role = strtolower($role);
        $field = ($role === 'customer') ? 'customer_id' : 'artisan_id';
        
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
        $stmt->bindParam(':uid', $userId, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    /**
     * Update booking status.
     */
    public function updateStatus($id, $status, $userId, $role = 'customer', $reason = null) {
        $field = ($role === 'customer') ? 'customer_id' : 'artisan_id';
        
        $query = "UPDATE " . $this->table . " SET status = :status";
        if ($reason !== null) {
            $query .= ", cancellation_reason = :reason";
        }
        $query .= " WHERE id = :id AND $field = :uid";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':status', $status);
        if ($reason !== null) {
            $stmt->bindParam(':reason', $reason);
        }
        $stmt->bindParam(':id', $id);
        $stmt->bindParam(':uid', $userId);
        return $stmt->execute();
    }

    /**
     * Update negotiation state.
     */
    public function updateNegotiation($id, $price, $status) {
        $query = "UPDATE " . $this->table . " SET 
                  negotiation_status = :status, 
                  counter_price = :price ";
        
        // If accepted, update the final price and recalculate fees
        if ($status === 'accepted') {
            $fee = $price * 0.10;
            $payout = $price - $fee;
            $query .= ", price = :price, platform_fee = $fee, artisan_payout = $payout, is_negotiated = 1, status = 'confirmed' ";
        }

        $query .= " WHERE id = :id";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':status', $status);
        $stmt->bindParam(':price', $price);
        $stmt->bindParam(':id', $id);
        return $stmt->execute();
    }

    public function getById($id) {
        $query = "SELECT * FROM " . $this->table . " WHERE id = :id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->execute();
        return $stmt->fetch();
    }

    /**
     * Auto-cancel / expire pending bookings that have had no response for > $inactivityHours or scheduled_at has passed.
     */
    public function expirePendingBookings($inactivityHours = 24) {
        try {
            $query = "SELECT id, booking_number, customer_id, artisan_id, scheduled_at, created_at 
                      FROM " . $this->table . " 
                      WHERE status = 'pending' 
                      AND (created_at <= DATE_SUB(NOW(), INTERVAL :hours HOUR) OR (scheduled_at IS NOT NULL AND scheduled_at < NOW()))";
            
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':hours', $inactivityHours, PDO::PARAM_INT);
            $stmt->execute();
            $expired = $stmt->fetchAll(PDO::FETCH_ASSOC);

            if (empty($expired)) {
                return ['count' => 0, 'expired' => []];
            }

            $notifModel = new Notification();
            $cancelStmt = $this->conn->prepare(
                "UPDATE " . $this->table . " 
                 SET status = 'cancelled', 
                     cancellation_reason = 'Auto-cancelled: No response from artisan within 24 hours (inactivity timeout)' 
                 WHERE id = :id AND status = 'pending'"
            );

            $expiredList = [];
            foreach ($expired as $b) {
                $cancelStmt->bindParam(':id', $b['id'], PDO::PARAM_INT);
                if ($cancelStmt->execute()) {
                    $expiredList[] = $b['booking_number'];

                    // Notify customer
                    $notifModel->create([
                        'user_id' => $b['customer_id'],
                        'type' => 'booking',
                        'title' => 'Booking Auto-Cancelled',
                        'message' => 'Your booking #' . $b['booking_number'] . ' was cancelled because the artisan did not respond within 24 hours.',
                        'related_id' => $b['id']
                    ]);

                    // Notify artisan
                    $notifModel->create([
                        'user_id' => $b['artisan_id'],
                        'type' => 'booking',
                        'title' => 'Booking Request Expired',
                        'message' => 'Booking request #' . $b['booking_number'] . ' expired due to inactivity.',
                        'related_id' => $b['id']
                    ]);
                }
            }

            return ['count' => count($expiredList), 'expired' => $expiredList];
        } catch (\Throwable $e) {
            return ['count' => 0, 'expired' => [], 'error' => $e->getMessage()];
        }
    }
}

