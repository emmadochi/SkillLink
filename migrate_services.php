<?php
require_once __DIR__ . '/api/config.php';

try {
    $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4";
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    // Create services table
    $pdo->exec("CREATE TABLE IF NOT EXISTS category_services (
        id INT AUTO_INCREMENT PRIMARY KEY,
        category_id INT NOT NULL,
        service_name VARCHAR(100) NOT NULL,
        icon_name VARCHAR(50) DEFAULT 'bolt_outlined',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
    )");

    // Insert professional default services
    $services = [
        // Electrical (assuming ID 1)
        [1, 'Wiring & Installation', 'bolt_outlined'],
        [1, 'Fault Diagnosis & Repair', 'build_circle_outlined'],
        [1, 'CCTV & Security Setup', 'videocam_outlined'],
        [1, 'Solar & Inverter Setup', 'wb_sunny_outlined'],
        
        // Plumbing (assuming ID 2)
        [2, 'Pipe Leakage Repair', 'water_drop_outlined'],
        [2, 'Bathroom/Toilet Fitting', 'bathtub_outlined'],
        [2, 'Water Tank Cleaning', 'vape_free_outlined'],
        [2, 'Drainage Unclogging', 'plumbing_outlined'],

        // Carpentry (assuming ID 3)
        [3, 'Furniture Repair', 'chair_outlined'],
        [3, 'Door & Lock Fitting', 'door_front_outlined'],
        [3, 'Cabinet & Kitchen Work', 'kitchen_outlined'],
        [3, 'Roofing & Woodwork', 'house_siding_outlined']
    ];

    $stmt = $pdo->prepare("INSERT INTO category_services (category_id, service_name, icon_name) VALUES (?, ?, ?)");
    foreach ($services as $s) {
        $stmt->execute($s);
    }

    echo "Migration successful: Created category_services and added default data.\n";
} catch (Exception $e) {
    echo "Migration failed: " . $e->getMessage() . "\n";
}
