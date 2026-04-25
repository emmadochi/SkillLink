<?php
/**
 * Migration script to add missing indexes for performance
 */
require_once 'core/Database.php';

error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    $db = new \core\Database();
    $conn = $db->getConnection();
    
    echo "Adding indexes to bookings table...<br>";
    $conn->exec("ALTER TABLE bookings ADD INDEX IF NOT EXISTS (customer_id)");
    $conn->exec("ALTER TABLE bookings ADD INDEX IF NOT EXISTS (artisan_id)");
    $conn->exec("ALTER TABLE bookings ADD INDEX IF NOT EXISTS (category_id)");
    $conn->exec("ALTER TABLE bookings ADD INDEX IF NOT EXISTS (created_at)");

    echo "Adding indexes to users table...<br>";
    $conn->exec("ALTER TABLE users ADD INDEX IF NOT EXISTS (role)");

    echo "Adding indexes to artisans table...<br>";
    $conn->exec("ALTER TABLE artisans ADD INDEX IF NOT EXISTS (category_id)");
    $conn->exec("ALTER TABLE artisans ADD INDEX IF NOT EXISTS (user_id)");

    echo "Optimization complete.<br>";

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "<br>";
}
