<?php
require_once 'api/config.php';

try {
    $db = new PDO("mysql:host=" . DB_HOST . ";dbname=" . DB_NAME, DB_USER, DB_PASS);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $sql = "CREATE TABLE IF NOT EXISTS saved_artisans (
        user_id INT, 
        artisan_id INT, 
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (user_id, artisan_id), 
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE, 
        FOREIGN KEY (artisan_id) REFERENCES artisans(user_id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";

    $db->exec($sql);
    echo "Table 'saved_artisans' created successfully.\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>
