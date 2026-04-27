<?php
require_once __DIR__ . '/api/config.php';

try {
    $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4";
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    // 1. Ensure artisan_portfolios table exists with correct column
    $pdo->exec("CREATE TABLE IF NOT EXISTS `artisan_portfolios` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `artisan_id` INT NOT NULL,
        `image_url` VARCHAR(255) NOT NULL,
        `description` TEXT,
        `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

    // 2. Check if image_url column exists, if not add it
    $stmt = $pdo->query("SHOW COLUMNS FROM artisan_portfolios LIKE 'image_url'");
    if (!$stmt->fetch()) {
        $pdo->exec("ALTER TABLE artisan_portfolios ADD COLUMN image_url VARCHAR(255) NOT NULL AFTER artisan_id");
        echo "Added 'image_url' column to 'artisan_portfolios' table.\n";
    } else {
        echo "'image_url' column already exists in 'artisan_portfolios' table.\n";
    }

    echo "Database fix completed successfully.\n";
} catch (Exception $e) {
    echo "Database fix failed: " . $e->getMessage() . "\n";
}
