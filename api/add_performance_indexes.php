<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/core/Database.php';

try {
    $db = (new \core\Database())->getConnection();
    echo "Connected to database successfully.\n";

    $queries = [
        "ALTER TABLE reviews ADD INDEX IF NOT EXISTS idx_reviews_artisan (artisan_id)",
        "ALTER TABLE reviews ADD INDEX IF NOT EXISTS idx_reviews_customer (customer_id)",
        "ALTER TABLE artisan_portfolios ADD INDEX IF NOT EXISTS idx_portfolio_artisan (artisan_id)",
        "ALTER TABLE artisan_sub_services ADD INDEX IF NOT EXISTS idx_sub_services_artisan (artisan_id)",
        "ALTER TABLE bookings ADD INDEX IF NOT EXISTS idx_bookings_artisan (artisan_id)",
        "ALTER TABLE bookings ADD INDEX IF NOT EXISTS idx_bookings_customer (customer_id)",
        "ALTER TABLE bookings ADD INDEX IF NOT EXISTS idx_bookings_status (status)"
    ];

    foreach ($queries as $sql) {
        try {
            $db->exec($sql);
            echo "Executed: $sql\n";
        } catch (\PDOException $e) {
            // Some MySQL versions don't support IF NOT EXISTS in ADD INDEX
            if (strpos($e->getMessage(), 'Duplicate key name') !== false) {
                echo "Index already exists: $sql\n";
            } else {
                // Fallback without IF NOT EXISTS
                $simpleSql = preg_replace('/IF NOT EXISTS /', '', $sql);
                try {
                    $db->exec($simpleSql);
                    echo "Executed: $simpleSql\n";
                } catch (\PDOException $e2) {
                    echo "Notice: " . $e2->getMessage() . "\n";
                }
            }
        }
    }

    echo "All performance indexes verified.\n";
} catch (\Throwable $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
