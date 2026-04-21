<?php
/**
 * CategoryModel.php
 * DB queries for service categories management.
 */

namespace models;

class CategoryModel {

    private \mysqli $db;

    public function __construct(\mysqli $db) {
        $this->db = $db;
    }

    /** All categories with artisan count */
    public function getAll(): array {
        $result = $this->db->query(
            "SELECT c.id, c.name, c.slug, c.icon,
                    COUNT(ac.artisan_id) AS artisan_count
             FROM categories c
             LEFT JOIN artisan_categories ac ON ac.category_id = c.id
             GROUP BY c.id
             ORDER BY c.name ASC"
        );
        return $result->fetch_all(MYSQLI_ASSOC);
    }

    /** Add a new category */
    public function create(string $name): bool {
        $slug = strtolower(preg_replace('/\s+/', '-', trim($name)));
        $stmt = $this->db->prepare(
            "INSERT INTO categories (name, slug) VALUES (?, ?)"
        );
        $stmt->bind_param('ss', $name, $slug);
        $stmt->execute();
        return $stmt->affected_rows > 0;
    }

    /** Update category name */
    public function update(int $id, string $name): bool {
        $slug = strtolower(preg_replace('/\s+/', '-', trim($name)));
        $stmt = $this->db->prepare(
            "UPDATE categories SET name = ?, slug = ? WHERE id = ?"
        );
        $stmt->bind_param('ssi', $name, $slug, $id);
        $stmt->execute();
        return $stmt->affected_rows > 0;
    }

    /** Delete a category */
    public function delete(int $id): bool {
        $stmt = $this->db->prepare("DELETE FROM categories WHERE id = ?");
        $stmt->bind_param('i', $id);
        $stmt->execute();
        return $stmt->affected_rows > 0;
    }

    /** Platform settings — from a simple key-value config table (optional) */
    public function getSettings(): array {
        return [
            'platform_fee' => '10%',
            'min_payout'   => '₦5,000',
            'support_email'=> 'support@skilllink.com',
        ];
    }
}
