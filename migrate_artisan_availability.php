<?php
require_once __DIR__ . '/api/config.php';

try {
    $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4";
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    $pdo->exec("ALTER TABLE artisans ADD COLUMN is_available TINYINT(1) DEFAULT 1 AFTER identity_status");
    echo "Migration successful: Added is_available to artisans table.\n";
} catch (Exception $e) {
    echo "Migration failed: " . $e->getMessage() . "\n";
}
