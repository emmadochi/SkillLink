<?php
/**
 * UserModel.php
 * DB queries for users and artisan verification.
 */

namespace models;

class UserModel {

    private \mysqli $db;

    public function __construct(\mysqli $db) {
        $this->db = $db;
    }

    /** Stats for dashboard */
    public function getTotalUsers(): int {
        $result = $this->db->query("SELECT COUNT(*) AS total FROM users WHERE role = 'customer'");
        return (int)($result->fetch_assoc()['total'] ?? 0);
    }

    public function getTotalArtisans(): int {
        $result = $this->db->query("SELECT COUNT(*) AS total FROM artisans WHERE verification_status = 'approved'");
        return (int)($result->fetch_assoc()['total'] ?? 0);
    }

    /** List all customers */
    public function getCustomers(int $limit = 50, int $offset = 0): array {
        $stmt = $this->db->prepare(
            "SELECT id, name, email, phone, is_verified, created_at FROM users
             WHERE role = 'customer' ORDER BY created_at DESC LIMIT ? OFFSET ?"
        );
        $stmt->bind_param('ii', $limit, $offset);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }

    /** List all artisans with their profile */
    public function getArtisans(int $limit = 50, int $offset = 0): array {
        $stmt = $this->db->prepare(
            "SELECT u.id, u.name, u.email, u.phone, u.avatar_url,
                    a.verification_status AS status, a.average_rating AS rating,
                    a.experience_years, a.location_name,
                    GROUP_CONCAT(c.name SEPARATOR ', ') AS skills
             FROM users u
             JOIN artisans a ON a.user_id = u.id
             LEFT JOIN artisan_categories ac ON ac.artisan_id = a.user_id
             LEFT JOIN categories c ON c.id = ac.category_id
             WHERE u.role = 'artisan'
             GROUP BY u.id
             ORDER BY a.verification_status ASC, u.created_at DESC
             LIMIT ? OFFSET ?"
        );
        $stmt->bind_param('ii', $limit, $offset);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }

    /** Get a single artisan's full profile */
    public function getArtisanById(int $id): ?array {
        $stmt = $this->db->prepare(
            "SELECT u.id, u.name, u.email, u.phone, u.avatar_url, u.created_at,
                    a.bio, a.experience_years, a.location_name,
                    a.verification_status AS status,
                    a.average_rating AS rating, a.total_reviews,
                    GROUP_CONCAT(c.name SEPARATOR ', ') AS skills
             FROM users u
             JOIN artisans a ON a.user_id = u.id
             LEFT JOIN artisan_categories ac ON ac.artisan_id = a.user_id
             LEFT JOIN categories c ON c.id = ac.category_id
             WHERE u.id = ?
             GROUP BY u.id"
        );
        $stmt->bind_param('i', $id);
        $stmt->execute();
        $row = $stmt->get_result()->fetch_assoc();
        return $row ?: null;
    }

    /** Update artisan verification status */
    public function updateArtisanStatus(int $userId, string $status): bool {
        $allowed = ['approved', 'rejected', 'pending'];
        if (!in_array($status, $allowed)) return false;

        $stmt = $this->db->prepare(
            "UPDATE artisans SET verification_status = ? WHERE user_id = ?"
        );
        $stmt->bind_param('si', $status, $userId);
        $stmt->execute();
        return $stmt->affected_rows > 0;
    }

    /** Suspend / activate a customer account */
    public function toggleUserVerification(int $userId): bool {
        $stmt = $this->db->prepare(
            "UPDATE users SET is_verified = NOT is_verified WHERE id = ?"
        );
        $stmt->bind_param('i', $userId);
        $stmt->execute();
        return $stmt->affected_rows > 0;
    }
}
