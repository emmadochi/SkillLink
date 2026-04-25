<?php
/**
 * Diagnostic script for Chat/Message system
 */
require_once 'app/models/Message.php';
require_once 'core/Database.php';
require_once 'core/Controller.php';

error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    echo "Connecting to database...<br>";
    $db = new \core\Database();
    $conn = $db->getConnection();
    echo "Connected successfully.<br>";

    echo "Checking/Creating messages table...<br>";
    $msg = new \models\Message();
    echo "Message model initialized.<br>";

    $table = "messages";
    $check = $conn->query("SHOW TABLES LIKE '$table'");
    if ($check->rowCount() > 0) {
        echo "Table '$table' exists.<br>";
        $desc = $conn->query("DESCRIBE $table");
        echo "Table structure:<pre>";
        print_r($desc->fetchAll(PDO::FETCH_ASSOC));
        echo "</pre>";
    } else {
        echo "Table '$table' does NOT exist. Attempting manual creation...<br>";
        $sql = "CREATE TABLE IF NOT EXISTS $table (
            id INT AUTO_INCREMENT PRIMARY KEY,
            sender_id INT NOT NULL,
            receiver_id INT NOT NULL,
            message TEXT NOT NULL,
            is_read TINYINT(1) DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";
        $conn->exec($sql);
        echo "Creation command executed.<br>";
    }

} catch (Exception $e) {
    echo "ERROR: " . $e->getMessage() . "<br>";
    echo "Trace: <pre>" . $e->getTraceAsString() . "</pre>";
}
