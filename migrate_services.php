<?php
require_once __DIR__ . '/api/config.php';

try {
    $dsn = "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4";
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    // 0. Ensure AC Repair category exists
    $checkCat = $pdo->prepare("SELECT id FROM categories WHERE slug = 'ac-repair' OR name = 'AC Repair'");
    $checkCat->execute();
    if (!$checkCat->fetch()) {
        $insCat = $pdo->prepare("INSERT INTO categories (name, slug, icon) VALUES ('AC Repair', 'ac-repair', 'ac_unit')");
        $insCat->execute();
    }

    // 0.1 Add columns to categories if not exists
    try {
        $pdo->exec("ALTER TABLE categories ADD COLUMN is_technical TINYINT(1) DEFAULT 0");
    } catch (Exception $e) {}
    
    try {
        $pdo->exec("ALTER TABLE categories ADD COLUMN sort_order INT DEFAULT 0");
    } catch (Exception $e) {}

    // 0.2 Set technical status and sort order for major categories
    $majorCategories = [
        'ac-repair' => 1,
        'ac repair' => 1,
        'electrical' => 2,
        'plumbing' => 3,
        'carpentry' => 4,
        'cleaning' => 5,
        'painting' => 6,
        'laundry' => 7,
    ];
    foreach ($majorCategories as $slug => $order) {
        $upd = $pdo->prepare("UPDATE categories SET is_technical = 1, sort_order = ? WHERE slug = ? OR name = ?");
        $upd->execute([$order, $slug, $slug]);
    }

    // 1. Create sub-services table if not exists
    $pdo->exec("CREATE TABLE IF NOT EXISTS category_services (
        id INT AUTO_INCREMENT PRIMARY KEY,
        category_id INT NOT NULL,
        service_name VARCHAR(100) NOT NULL,
        icon_name VARCHAR(50) DEFAULT 'bolt_outlined',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
    )");

    // 1.1 Create saved_artisans table if not exists
    $pdo->exec("CREATE TABLE IF NOT EXISTS saved_artisans (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        artisan_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY(user_id, artisan_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (artisan_id) REFERENCES users(id) ON DELETE CASCADE
    )");

    // 2. Fetch all categories to map names to IDs
    $stmt = $pdo->query("SELECT id, name FROM categories");
    $categoryMap = [];
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $categoryMap[strtolower($row['name'])] = $row['id'];
    }

    // 3. Define sub-services data
    $servicesData = [
        'electrical' => [
            ['Wiring & Installation', 'bolt_outlined'],
            ['Fault Diagnosis & Repair', 'build_circle_outlined'],
            ['CCTV & Security Setup', 'videocam_outlined'],
            ['Solar & Inverter Setup', 'wb_sunny_outlined'],
        ],
        'plumbing' => [
            ['Pipe Leakage Repair', 'water_drop_outlined'],
            ['Bathroom/Toilet Fitting', 'bathtub_outlined'],
            ['Water Tank Cleaning', 'vape_free_outlined'],
            ['Drainage Unclogging', 'plumbing_outlined'],
        ],
        'carpentry' => [
            ['Furniture Repair', 'chair_outlined'],
            ['Door & Lock Fitting', 'door_front_outlined'],
            ['Cabinet & Kitchen Work', 'kitchen_outlined'],
            ['Roofing & Woodwork', 'house_siding_outlined'],
        ],
        'ac repair' => [
            ['A.C Gas Filling / Servicing', 'ac_unit'],
            ['A.C Repair or Installation', 'build'],
            ['Refrigerator Repair', 'kitchen'],
            ['Freezer Repair', 'icecream'],
            ['Water Dispenser', 'water_drop'],
            ['Cold Room Servicing', 'severe_cold'],
        ]
    ];

    // 4. Insert data
    $insertStmt = $pdo->prepare("INSERT INTO category_services (category_id, service_name, icon_name) VALUES (?, ?, ?)");
    foreach ($servicesData as $catName => $subs) {
        if (isset($categoryMap[$catName])) {
            $catId = $categoryMap[$catName];
            foreach ($subs as $s) {
                // Check if already exists to avoid duplicates
                $checkStmt = $pdo->prepare("SELECT 1 FROM category_services WHERE category_id = ? AND service_name = ?");
                $checkStmt->execute([$catId, $s[0]]);
                if (!$checkStmt->fetch()) {
                    $insertStmt->execute([$catId, $s[0], $s[1]]);
                }
            }
        }
    }

    echo "Migration successful: Created category_services and added default data.\n";
} catch (Exception $e) {
    echo "Migration failed: " . $e->getMessage() . "\n";
}
