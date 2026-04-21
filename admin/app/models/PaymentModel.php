<?php
/**
 * PaymentModel.php
 * DB queries for transactions and revenue.
 */

namespace models;

class PaymentModel {

    private \mysqli $db;

    public function __construct(\mysqli $db) {
        $this->db = $db;
    }

    /** Platform revenue (sum of platform fees on completed bookings) */
    public function getTotalRevenue(): string {
        $result = $this->db->query(
            "SELECT SUM(platform_fee) AS total FROM bookings WHERE status = 'completed'"
        );
        $val = $result->fetch_assoc()['total'] ?? 0;
        return '₦' . number_format((float)$val, 2);
    }

    /** Revenue for current month */
    public function getMonthlyRevenue(): string {
        $result = $this->db->query(
            "SELECT SUM(platform_fee) AS total FROM bookings
             WHERE status = 'completed'
             AND MONTH(updated_at) = MONTH(CURDATE())
             AND YEAR(updated_at) = YEAR(CURDATE())"
        );
        $val = $result->fetch_assoc()['total'] ?? 0;
        return '₦' . number_format((float)$val, 2);
    }

    /** Total escrow balance (pending + in-progress bookings) */
    public function getEscrowBalance(): string {
        $result = $this->db->query(
            "SELECT SUM(price) AS total FROM bookings
             WHERE status IN ('confirmed','arrived','in_progress')"
        );
        $val = $result->fetch_assoc()['total'] ?? 0;
        return '₦' . number_format((float)$val, 2);
    }

    /** Paginated transaction list */
    public function getTransactions(int $limit = 20, int $offset = 0): array {
        $stmt = $this->db->prepare(
            "SELECT t.id, t.payment_reference, t.amount, t.type,
                    t.status, t.payment_method, t.created_at,
                    u.name AS user_name,
                    b.booking_number,
                    b.platform_fee AS fee
             FROM transactions t
             JOIN users u ON u.id = t.user_id
             LEFT JOIN bookings b ON b.id = t.booking_id
             ORDER BY t.created_at DESC
             LIMIT ? OFFSET ?"
        );
        $stmt->bind_param('ii', $limit, $offset);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }

    public function countTransactions(): int {
        $result = $this->db->query("SELECT COUNT(*) AS t FROM transactions");
        return (int)($result->fetch_assoc()['t'] ?? 0);
    }
}
