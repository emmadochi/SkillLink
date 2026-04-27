<?php
require 'api/config.php';
try {
    $pdo = new PDO('mysql:host='.DB_HOST.';dbname='.DB_NAME, DB_USER, DB_PASS);
    $tables = $pdo->query('SHOW TABLES')->fetchAll(PDO::FETCH_COLUMN);
    foreach ($tables as $table) {
        $stmt = $pdo->query("DESCRIBE $table");
        $columns = $stmt->fetchAll(PDO::FETCH_ASSOC);
        foreach ($columns as $col) {
            if ($col['Field'] === 'image_url') {
                echo "Found image_url in table: $table\n";
            }
        }
        if ($table === 'artisan_portfolios') {
            echo "Columns for artisan_portfolios:\n";
            print_r($columns);
        }
    }
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
