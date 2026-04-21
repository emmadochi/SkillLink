<?php
/**
 * DisputeModel.php
 * DB queries for booking disputes.
 * Uses the bookings table — disputed bookings are those
 * raised as disputes via a lightweight disputes table.
 *
 * Note: If the disputes table does not exist yet, add the
 * CREATE TABLE statement below to schema.sql and run it.
 *
 * CREATE TABLE IF NOT EXISTS `disputes` (
 *   `id`          INT AUTO_INCREMENT PRIMARY KEY,
 *   `booking_id`  INT NOT NULL,
 *   `raised_by`   INT NOT NULL COMMENT 'user_id of reporter',
 *   `reason`      TEXT NOT NULL,
 *   `status`      ENUM('open','under_review','resolved','closed') DEFAULT 'open',
 *   `resolution`  TEXT,
 *   `created_at`  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 *   `updated_at`  TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
 *   FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`),
 *   FOREIGN KEY (`raised_by`)  REFERENCES `users`(`id`)
 * ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 */

namespace models;

class DisputeModel {

    private \mysqli $db;

    public function __construct(\mysqli $db) {
        $this->db = $db;
    }

    public function getAll(int $limit = 20, int $offset = 0): array {
        // Gracefully returns empty array if disputes table doesn't exist
        $check = $this->db->query("SHOW TABLES LIKE 'disputes'");
        if ($check->num_rows === 0) return [];

        $stmt = $this->db->prepare(
            "SELECT d.id, d.status, d.reason, d.created_at,
                    b.booking_number,
                    cu.name  AS customer_name,
                    au.name  AS artisan_name,
                    rb.name  AS raised_by_name,
                    c.name   AS category
             FROM disputes d
             JOIN bookings b ON b.id = d.booking_id
             JOIN users    cu ON cu.id = b.customer_id
             JOIN users    au ON au.id = b.artisan_id
             JOIN users    rb ON rb.id = d.raised_by
             JOIN categories c ON c.id = b.category_id
             ORDER BY d.created_at DESC
             LIMIT ? OFFSET ?"
        );
        $stmt->bind_param('ii', $limit, $offset);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }

    public function count(): int {
        $check = $this->db->query("SHOW TABLES LIKE 'disputes'");
        if ($check->num_rows === 0) return 0;
        $result = $this->db->query("SELECT COUNT(*) AS t FROM disputes");
        return (int)($result->fetch_assoc()['t'] ?? 0);
    }

    public function countOpen(): int {
        $check = $this->db->query("SHOW TABLES LIKE 'disputes'");
        if ($check->num_rows === 0) return 0;
        $result = $this->db->query("SELECT COUNT(*) AS t FROM disputes WHERE status = 'open'");
        return (int)($result->fetch_assoc()['t'] ?? 0);
    }

    public function resolve(int $id, string $resolution): bool {
        $status = 'resolved';
        $stmt = $this->db->prepare(
            "UPDATE disputes SET status = ?, resolution = ? WHERE id = ?"
        );
        $stmt->bind_param('ssi', $status, $resolution, $id);
        $stmt->execute();
        return $stmt->affected_rows > 0;
    }

    public function close(int $id): bool {
        $status = 'closed';
        $stmt = $this->db->prepare("UPDATE disputes SET status = ? WHERE id = ?");
        $stmt->bind_param('si', $status, $id);
        $stmt->execute();
        return $stmt->affected_rows > 0;
    }
}
