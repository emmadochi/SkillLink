<?php
/**
 * BookingModel.php
 * DB queries for bookings and disputes.
 */

namespace models;

class BookingModel {

    private \mysqli $db;

    public function __construct(\mysqli $db) {
        $this->db = $db;
    }

    /** Total bookings count */
    public function getTotalBookings(): int {
        $result = $this->db->query("SELECT COUNT(*) AS total FROM bookings");
        return (int)($result->fetch_assoc()['total'] ?? 0);
    }

    /** Bookings today */
    public function getBookingsToday(): int {
        $result = $this->db->query("SELECT COUNT(*) AS total FROM bookings WHERE DATE(created_at) = CURDATE()");
        return (int)($result->fetch_assoc()['total'] ?? 0);
    }

    /** Paginated booking list with customer and artisan names */
    public function getAll(int $limit = 20, int $offset = 0, string $status = ''): array {
        $where = '';
        $types = 'ii';
        $params = [$limit, $offset];

        if ($status) {
            $where  = 'WHERE b.status = ?';
            $types  = 'sii';
            $params = [$status, $limit, $offset];
        }

        $stmt = $this->db->prepare(
            "SELECT b.id, b.booking_number, b.status, b.price, b.scheduled_at,
                    b.service_description, b.created_at,
                    cu.name AS customer_name,
                    au.name AS artisan_name,
                    c.name  AS category
             FROM bookings b
             JOIN users cu ON cu.id = b.customer_id
             JOIN users au ON au.id = b.artisan_id
             JOIN categories c ON c.id = b.category_id
             $where
             ORDER BY b.created_at DESC
             LIMIT ? OFFSET ?"
        );
        $stmt->bind_param($types, ...$params);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }

    /** Count rows matching optional status filter */
    public function count(string $status = ''): int {
        if ($status) {
            $stmt = $this->db->prepare("SELECT COUNT(*) AS t FROM bookings WHERE status = ?");
            $stmt->bind_param('s', $status);
            $stmt->execute();
            return (int)$stmt->get_result()->fetch_assoc()['t'];
        }
        return $this->getTotalBookings();
    }
}
