<?php
/**
 * SkillLink API Diagnostic Tool
 * Run this in your browser: http://localhost/SkillLink/api/test_api.php
 */
error_reporting(E_ALL);
ini_set('display_errors', 1);

require_once 'app/models/Artisan.php';
require_once 'core/Database.php';
require_once 'core/Controller.php';

echo "<h1>SkillLink API Diagnostic</h1>";

try {
    echo "<h3>1. Checking Database Connection...</h3>";
    $db = new \core\Database();
    $conn = $db->getConnection();
    if ($conn) {
        echo "<p style='color:green'>✅ Connected successfully!</p>";
    } else {
        echo "<p style='color:red'>❌ Connection failed!</p>";
    }

    echo "<h3>2. Testing Artisan Search...</h3>";
    $artisanModel = new \models\Artisan();
    $results = $artisanModel->search();
    
    echo "<p style='color:green'>✅ Search query executed!</p>";
    echo "<p>Found <b>" . count($results) . "</b> artisans.</p>";
    
    echo "<h3>3. Checking Bookings Table...</h3>";
    $stmt = $conn->query("SHOW COLUMNS FROM bookings");
    $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
    echo "<p>Columns found: <b>" . implode(", ", $columns) . "</b></p>";
    
    $required = ['offer_price', 'counter_price', 'negotiation_status', 'is_negotiated'];
    $missing = array_diff($required, $columns);
    
    if (empty($missing)) {
        echo "<p style='color:green'>✅ All negotiation columns present!</p>";
    } else {
        echo "<p style='color:red'>❌ Missing columns: " . implode(", ", $missing) . "</p>";
        echo "<p>Please run <b>sql/negotiation_migration.sql</b> on your database.</p>";
    }

    echo "<h3>4. Booking Integrity Check</h3>";
    $leakageCheck = $conn->query("SELECT b.id, b.artisan_id, u.name as artisan_name, b.customer_id, cu.name as customer_name 
                                  FROM bookings b 
                                  LEFT JOIN users u ON u.id = b.artisan_id 
                                  LEFT JOIN users cu ON cu.id = b.customer_id 
                                  LIMIT 10");
    if ($leakageCheck && $leakageCheck->rowCount() > 0) {
        echo "<table border='1' cellpadding='5' style='border-collapse: collapse; width: 100%; font-size:12px;'>";
        echo "<tr style='background:#eee'><th>Booking ID</th><th>Artisan ID</th><th>Artisan Name</th><th>Customer ID</th><th>Customer Name</th></tr>";
        while ($row = $leakageCheck->fetch(PDO::FETCH_ASSOC)) {
            echo "<tr><td>{$row['id']}</td><td>{$row['artisan_id']}</td><td>{$row['artisan_name']}</td><td>{$row['customer_id']}</td><td>{$row['customer_name']}</td></tr>";
        }
        echo "</table>";
    } else {
        echo "<p>No bookings found to analyze.</p>";
    }

    // Check for inconsistent roles
    echo "<h3>5. Inconsistent Roles Check</h3>";
    $roleCheck = $conn->query("SELECT COUNT(*) as count FROM users WHERE role = 'artisan' AND id NOT IN (SELECT user_id FROM artisans)");
    $roleRes = $roleCheck->fetch();
    if ($roleRes['count'] > 0) {
        echo "<p style='color:red'>❌ Found <b>{$roleRes['count']}</b> users with 'artisan' role but NO entry in 'artisans' table!</p>";
    } else {
        echo "<p style='color:green'>✅ All artisans have valid profile entries.</p>";
    }

    echo "<h3>6. Raw Data Sample:</h3>";
    echo "<pre>";
    print_r(array_slice($results, 0, 1));
    echo "</pre>";

} catch (\Throwable $e) {
    echo "<div style='background:#fee; padding:20px; border:2px solid red;'>";
    echo "<h2>❌ SERVER ERROR DETECTED</h2>";
    echo "<p><b>Message:</b> " . $e->getMessage() . "</p>";
    echo "<p><b>File:</b> " . $e->getFile() . " (Line " . $e->getLine() . ")</p>";
    echo "</div>";
}
