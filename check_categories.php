<?php
require 'api/config.php';
try {
    $pdo = new PDO('mysql:host='.DB_HOST.';dbname='.DB_NAME, DB_USER, DB_PASS);
    $stmt = $pdo->query('SELECT * FROM categories');
    $categories = $stmt->fetchAll(PDO::FETCH_ASSOC);
    echo json_encode($categories, JSON_PRETTY_PRINT);
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
