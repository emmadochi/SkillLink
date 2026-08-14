<?php
/**
 * SkillLink - Artisan Seeder for all Service Categories
 * Generates verified artisans with rich profiles, reviews, portfolios, and sub-services.
 */

// Try local root config first or fall back to localhost defaults
$dbHost = '127.0.0.1';
$dbName = 'quantu16_skilllink';
$dbUser = 'root';
$dbPass = '';

if (file_exists(__DIR__ . '/api/config.php')) {
    require_once __DIR__ . '/api/config.php';
    if (defined('DB_HOST')) $dbHost = DB_HOST;
    if (defined('DB_NAME')) $dbName = DB_NAME;
    if (defined('DB_USER')) $dbUser = DB_USER;
    if (defined('DB_PASS')) $dbPass = DB_PASS;
}

try {
    // Connect to MySQL server first
    $rawPdo = null;
    $possibleCredentials = [
        ['127.0.0.1', 'root', ''],
        ['localhost', 'root', ''],
        [$dbHost, $dbUser, $dbPass],
    ];

    foreach ($possibleCredentials as [$h, $u, $p]) {
        try {
            $rawPdo = new PDO("mysql:host=$h;charset=utf8mb4", $u, $p, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
            ]);
            break;
        } catch (PDOException $e) {}
    }

    if (!$rawPdo) {
        throw new Exception("Could not connect to MySQL server with available credentials.");
    }

    // List databases to find skilllink DB
    $dbs = $rawPdo->query("SHOW DATABASES")->fetchAll(PDO::FETCH_COLUMN);
    $targetDb = null;
    foreach ($dbs as $d) {
        if (in_array(strtolower($d), ['quantu16_skilllink', 'skilllink', 'skill_link', 'skilllink_db'])) {
            $targetDb = $d;
            break;
        }
    }

    if (!$targetDb) {
        $targetDb = 'skilllink';
        $rawPdo->exec("CREATE DATABASE IF NOT EXISTS `$targetDb` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
        echo "Created local database: $targetDb\n";
    } else {
        echo "Using existing database: $targetDb\n";
    }

    $rawPdo->exec("USE `$targetDb`");
    $pdo = $rawPdo;
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);

    // Ensure columns exist on artisans table
    $artisanCols = [
        'skill' => "ALTER TABLE artisans ADD COLUMN skill VARCHAR(100) DEFAULT NULL",
        'category_id' => "ALTER TABLE artisans ADD COLUMN category_id INT DEFAULT NULL",
        'experience_years' => "ALTER TABLE artisans ADD COLUMN experience_years INT DEFAULT 0",
        'hourly_rate' => "ALTER TABLE artisans ADD COLUMN hourly_rate DECIMAL(10,2) DEFAULT 0.00",
        'business_address' => "ALTER TABLE artisans ADD COLUMN business_address TEXT DEFAULT NULL",
        'guarantor_name' => "ALTER TABLE artisans ADD COLUMN guarantor_name VARCHAR(100) DEFAULT NULL",
        'guarantor_phone' => "ALTER TABLE artisans ADD COLUMN guarantor_phone VARCHAR(20) DEFAULT NULL",
        'identity_verified' => "ALTER TABLE artisans ADD COLUMN identity_verified BOOLEAN DEFAULT FALSE",
        'verification_status' => "ALTER TABLE artisans ADD COLUMN verification_status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending'",
        'average_rating' => "ALTER TABLE artisans ADD COLUMN average_rating DECIMAL(3,2) DEFAULT 0.00",
        'total_reviews' => "ALTER TABLE artisans ADD COLUMN total_reviews INT DEFAULT 0",
        'is_available' => "ALTER TABLE artisans ADD COLUMN is_available BOOLEAN DEFAULT TRUE",
        'location_name' => "ALTER TABLE artisans ADD COLUMN location_name VARCHAR(255) DEFAULT NULL",
    ];

    $existingCols = $pdo->query("SHOW COLUMNS FROM artisans")->fetchAll(PDO::FETCH_COLUMN);
    foreach ($artisanCols as $col => $sql) {
        if (!in_array($col, $existingCols)) {
            try { $pdo->exec($sql); } catch (\Throwable $e) {}
        }
    }

    // Ensure category_services table exists
    $pdo->exec("CREATE TABLE IF NOT EXISTS category_services (
        id INT AUTO_INCREMENT PRIMARY KEY,
        category_id INT NOT NULL,
        service_name VARCHAR(100) NOT NULL,
        icon_name VARCHAR(50) DEFAULT 'build',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Ensure artisan_categories table exists
    $pdo->exec("CREATE TABLE IF NOT EXISTS artisan_categories (
        artisan_id INT,
        category_id INT,
        PRIMARY KEY (artisan_id, category_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Ensure reviews table exists
    $pdo->exec("CREATE TABLE IF NOT EXISTS reviews (
        id INT AUTO_INCREMENT PRIMARY KEY,
        artisan_id INT NOT NULL,
        customer_id INT NOT NULL,
        rating INT NOT NULL,
        comment TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");

    // Ensure columns exist on categories table
    $catCols = $pdo->query("SHOW COLUMNS FROM categories")->fetchAll(PDO::FETCH_COLUMN);
    if (!in_array('is_technical', $catCols)) {
        try { $pdo->exec("ALTER TABLE categories ADD COLUMN is_technical TINYINT(1) DEFAULT 0"); } catch (\Throwable $e) {}
    }
    if (!in_array('sort_order', $catCols)) {
        try { $pdo->exec("ALTER TABLE categories ADD COLUMN sort_order INT DEFAULT 0"); } catch (\Throwable $e) {}
    }

    // ── 1. Define Categories & Services ──────────────────────────────────────
    $servicesByCategory = [
        'Plumbing' => [
            'icon' => 'plumbing',
            'slug' => 'plumbing',
            'sub_services' => ['Pipe Leakage Repair', 'Bathroom & Toilet Fitting', 'Water Heater Installation', 'Water Tank & Pump Setup', 'Drainage Unclogging'],
            'artisans' => [
                [
                    'name' => 'Emmanuel Okafor',
                    'email' => 'emmanuel.plumbing@skilllink.ng',
                    'phone' => '+2348031234501',
                    'avatar' => 'https://images.unsplash.com/photo-1540569014015-19a7be504e3a?w=400',
                    'skill' => 'Master Plumber & Pipefitter',
                    'bio' => 'Licensed master plumber with 8+ years specializing in residential piping, solar water heaters, and concealed bathroom installations.',
                    'experience' => 8,
                    'rating' => 4.9,
                    'reviews_count' => 38,
                    'hourly_rate' => 5000,
                    'location' => 'Lekki Phase 1, Lagos',
                    'address' => 'Shop 4, Admiralty Way, Lekki',
                    'portfolio' => [
                        ['title' => 'Concealed Bathroom Piping', 'url' => 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=600'],
                        ['title' => 'Water Treatment & Pump Station', 'url' => 'https://images.unsplash.com/photo-1504148455328-c376907d081c?w=600'],
                    ],
                    'reviews' => [
                        ['name' => 'Dr. Babatunde Alabi', 'rating' => 5, 'comment' => 'Fixed an underground pipe leak in my compound within 2 hours. Very clean and professional!'],
                        ['name' => 'Mrs. Grace Okon', 'rating' => 5, 'comment' => 'Top notch work on our new bathroom fixtures. Highly recommended.'],
                    ]
                ],
                [
                    'name' => 'Sunday Bassey',
                    'email' => 'sunday.pipes@skilllink.ng',
                    'phone' => '+2348031234502',
                    'avatar' => 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
                    'skill' => 'Commercial Drainage Specialist',
                    'bio' => 'Certified drainage expert specializing in high-pressure unclogging, borehole water connection, and industrial piping.',
                    'experience' => 6,
                    'rating' => 4.7,
                    'reviews_count' => 24,
                    'hourly_rate' => 4500,
                    'location' => 'Ikeja, Lagos',
                    'address' => '12 Allen Avenue, Ikeja',
                    'portfolio' => [
                        ['title' => 'Industrial Borehole Connection', 'url' => 'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600'],
                    ],
                    'reviews' => [
                        ['name' => 'Chidi Eze', 'rating' => 5, 'comment' => 'Resolved our restaurant drainage issue swiftly.'],
                    ]
                ]
            ]
        ],
        'Electrical' => [
            'icon' => 'bolt',
            'slug' => 'electrical',
            'sub_services' => ['Full House Conduit Wiring', 'Solar & Inverter Installation', 'Distribution Box / Breaker Repair', 'CCTV & Smart Home Setup', 'Fault Finding & Surge Protection'],
            'artisans' => [
                [
                    'name' => 'Adebayo Ogunleye',
                    'email' => 'adebayo.electric@skilllink.ng',
                    'phone' => '+2348031234503',
                    'avatar' => 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
                    'skill' => 'Certified Electrical & Solar Engineer',
                    'bio' => 'COREN certified electrical engineer specializing in hybrid 5kVA-20kVA solar installations, lithium battery setups, and house conduit wiring.',
                    'experience' => 10,
                    'rating' => 5.0,
                    'reviews_count' => 52,
                    'hourly_rate' => 7500,
                    'location' => 'Victoria Island, Lagos',
                    'address' => 'Plot 8, Adeola Odeku St, VI',
                    'portfolio' => [
                        ['title' => '10kVA Solar Inverter Setup', 'url' => 'https://images.unsplash.com/photo-1508873696983-2df5293cb32f?w=600'],
                        ['title' => 'Smart Distribution Board', 'url' => 'https://images.unsplash.com/photo-1558346490-a72e53ae2d4f?w=600'],
                    ],
                    'reviews' => [
                        ['name' => 'Engr. Kenneth Uche', 'rating' => 5, 'comment' => 'Flawless solar inverter setup. He explained the load balancing clearly.'],
                        ['name' => 'Aisha Danjuma', 'rating' => 5, 'comment' => 'Prompt response during a power surge emergency. Fixed the short circuit in 30 mins.'],
                    ]
                ]
            ]
        ],
        'AC Repair' => [
            'icon' => 'ac_unit',
            'slug' => 'ac-repair',
            'sub_services' => ['AC Gas Refill (R410A / R22)', 'Split & Inverter AC Installation', 'Compressor Replacement', 'Refrigerator & Freezer Repair', 'Cold Room Maintenance'],
            'artisans' => [
                [
                    'name' => 'Chinedu Nwosu',
                    'email' => 'chinedu.cool@skilllink.ng',
                    'phone' => '+2348031234504',
                    'avatar' => 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=400',
                    'skill' => 'HVAC & Refrigeration Technician',
                    'bio' => 'Expert cooling technician with 9 years of field work on LG, Panasonic, and Gree inverter AC systems, industrial chillers, and deep freezers.',
                    'experience' => 9,
                    'rating' => 4.8,
                    'reviews_count' => 43,
                    'hourly_rate' => 6000,
                    'location' => 'Surulere, Lagos',
                    'address' => '45 Bode Thomas Street, Surulere',
                    'portfolio' => [
                        ['title' => 'Multi-split Inverter AC Mount', 'url' => 'https://images.unsplash.com/photo-1621905252507-b35492cc74b4?w=600'],
                    ],
                    'reviews' => [
                        ['name' => 'Titi Adeleke', 'rating' => 5, 'comment' => 'My AC is blowing ice cold again! Genuine gas refill and very polite artisan.'],
                    ]
                ]
            ]
        ],
        'Carpentry' => [
            'icon' => 'chair',
            'slug' => 'carpentry',
            'sub_services' => ['Custom Kitchen Cabinets', 'Wardrobe & Closet Fitting', 'Door & Lock Installation', 'Roof Truss & Woodwork', 'Furniture Upholstery & Repair'],
            'artisans' => [
                [
                    'name' => 'Ibrahim Musa',
                    'email' => 'ibrahim.wood@skilllink.ng',
                    'phone' => '+2348031234505',
                    'avatar' => 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=400',
                    'skill' => 'Master Woodworker & Cabinet Maker',
                    'bio' => 'Specialized in modern MDF and hardwood kitchen cabinets, flush doors, security locks, and bespoke dining sets.',
                    'experience' => 11,
                    'rating' => 4.9,
                    'reviews_count' => 31,
                    'hourly_rate' => 6500,
                    'location' => 'Yaba, Lagos',
                    'address' => '22 Commercial Avenue, Sabo, Yaba',
                    'portfolio' => [
                        ['title' => 'Modern Kitchen High-Gloss Cabinets', 'url' => 'https://images.unsplash.com/photo-1556911220-e15b29be8c8f?w=600'],
                        ['title' => 'Custom Built-in Wardrobe', 'url' => 'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=600'],
                    ],
                    'reviews' => [
                        ['name' => 'Folake Olumide', 'rating' => 5, 'comment' => 'The precision and finish of my kitchen cabinet exceeded expectations.'],
                    ]
                ]
            ]
        ],
        'Painting' => [
            'icon' => 'format_paint',
            'slug' => 'painting',
            'sub_services' => ['Interior Luxury Emulsion & Satin', 'Exterior Weather-Shield Painting', 'POP Ceiling Screeding & Design', 'Wallpaper Installation', 'Epoxy Flooring'],
            'artisans' => [
                [
                    'name' => 'Tunde Bakare',
                    'email' => 'tunde.paints@skilllink.ng',
                    'phone' => '+2348031234506',
                    'avatar' => 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
                    'skill' => 'Decorative Painter & Screeder',
                    'bio' => 'Professional interior finisher with 7 years experience in smooth wall screeding, stucco marble paint, and crisp color combinations.',
                    'experience' => 7,
                    'rating' => 4.9,
                    'reviews_count' => 29,
                    'hourly_rate' => 4000,
                    'location' => 'Gbagada, Lagos',
                    'address' => '10 Diya Street, Gbagada',
                    'portfolio' => [
                        ['title' => 'Duplex Satin Finish & Stucco Accent Wall', 'url' => 'https://images.unsplash.com/photo-1589939705384-5185137a7f0f?w=600'],
                    ],
                    'reviews' => [
                        ['name' => 'Senator Briggs', 'rating' => 5, 'comment' => 'Neat lines, no paint splatter, and completed our 4-bedroom house on schedule.'],
                    ]
                ]
            ]
        ],
        'Cleaning' => [
            'icon' => 'cleaning_services',
            'slug' => 'cleaning',
            'sub_services' => ['Post-Construction Deep Cleaning', 'Fumigation & Pest Control', 'Sofa & Rug Steam Cleaning', 'Move-in / Move-out Cleaning', 'Office Sanitization'],
            'artisans' => [
                [
                    'name' => 'Blessing Okon',
                    'email' => 'blessing.clean@skilllink.ng',
                    'phone' => '+2348031234507',
                    'avatar' => 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=400',
                    'skill' => 'Deep Cleaning & Sanitization Lead',
                    'bio' => 'Certified eco-friendly cleaning expert providing industrial steam cleaning for homes, rugs, mattresses, and post-construction sites.',
                    'experience' => 5,
                    'rating' => 5.0,
                    'reviews_count' => 64,
                    'hourly_rate' => 3500,
                    'location' => 'Ajah, Lagos',
                    'address' => 'Badore Road, Ajah',
                    'portfolio' => [
                        ['title' => 'Post-Construction Villa Deep Clean', 'url' => 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=600'],
                    ],
                    'reviews' => [
                        ['name' => 'Kemi Adeleke', 'rating' => 5, 'comment' => 'My sofa and rug look brand new! Very polite and thorough team.'],
                    ]
                ]
            ]
        ],
        'Tiling' => [
            'icon' => 'grid_view',
            'slug' => 'tiling',
            'sub_services' => ['Granite & Marble Laying', 'Vitrified Ceramic Floor Tiling', 'Swimming Pool Mosaic Tiling', 'Interlocking Pavers', 'Wall Subway Tiles'],
            'artisans' => [
                [
                    'name' => 'Yusuf Danjuma',
                    'email' => 'yusuf.tiles@skilllink.ng',
                    'phone' => '+2348031234508',
                    'avatar' => 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400',
                    'skill' => 'Precision Tile & Marble Mason',
                    'bio' => 'Over 12 years of experience laying laser-leveled porcelain, Spanish tiles, and Italian marble with zero hollow sound.',
                    'experience' => 12,
                    'rating' => 4.8,
                    'reviews_count' => 37,
                    'hourly_rate' => 5500,
                    'location' => 'Maryland, Lagos',
                    'address' => '14 Ikorodu Road, Maryland',
                    'portfolio' => [
                        ['title' => 'Marble Living Room Tiling', 'url' => 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600'],
                    ],
                    'reviews' => [
                        ['name' => 'Arch. Oladipo', 'rating' => 5, 'comment' => 'Flawless leveling and neat grouting. The best tiler on the platform.'],
                    ]
                ]
            ]
        ],
        'Welding' => [
            'icon' => 'construction',
            'slug' => 'welding',
            'sub_services' => ['Wrought Iron Gates & Grills', 'Stainless Steel Railings', 'Security Burglary Proofs', 'Carport & Overhead Tank Stands', 'Argon & Arc Welding'],
            'artisans' => [
                [
                    'name' => 'Samuel Akpan',
                    'email' => 'samuel.weld@skilllink.ng',
                    'phone' => '+2348031234509',
                    'avatar' => 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=400',
                    'skill' => 'Fabrication & Ironwork Specialist',
                    'bio' => 'Heavy-duty steel fabricator building remote-controlled gates, stainless glass railings, and reinforced water tank scaffolds.',
                    'experience' => 8,
                    'rating' => 4.7,
                    'reviews_count' => 22,
                    'hourly_rate' => 6000,
                    'location' => 'Oshodi, Lagos',
                    'address' => 'Plot 3, Oshodi-Isolo Expressway',
                    'portfolio' => [
                        ['title' => 'Automated Wrought Iron Security Gate', 'url' => 'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=600'],
                    ],
                    'reviews' => [
                        ['name' => 'Chief Okonkwo', 'rating' => 5, 'comment' => 'Solid gate fabrication and delivered on the agreed date.'],
                    ]
                ]
            ]
        ],
        'Landscaping' => [
            'icon' => 'yard',
            'slug' => 'landscaping',
            'sub_services' => ['Lawn Mowing & Turf Grass Planting', 'Tree Trimming & Pruning', 'Garden Design & Flower Beds', 'Irrigation & Sprinkler Setup', 'Compound Interlock Weed Treatment'],
            'artisans' => [
                [
                    'name' => 'David Adeleke',
                    'email' => 'david.garden@skilllink.ng',
                    'phone' => '+2348031234510',
                    'avatar' => 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
                    'skill' => 'Horticulturist & Landscape Designer',
                    'bio' => 'Professional garden designer transforming residential compounds with lush Bermuda grass, ornamental flowers, and automated drip irrigation.',
                    'experience' => 6,
                    'rating' => 4.9,
                    'reviews_count' => 19,
                    'hourly_rate' => 4500,
                    'location' => 'Ikoyi, Lagos',
                    'address' => 'Kingsway Road, Ikoyi',
                    'portfolio' => [
                        ['title' => 'Ikoyi Villa Lush Lawn Transformation', 'url' => 'https://images.unsplash.com/photo-1558904541-efa8c4a08931?w=600'],
                    ],
                    'reviews' => [
                        ['name' => 'Ambassador Clark', 'rating' => 5, 'comment' => 'Our garden is the envy of the street. Excellent plant selection.'],
                    ]
                ]
            ]
        ],
        'Moving' => [
            'icon' => 'local_shipping',
            'slug' => 'moving',
            'sub_services' => ['Home & Apartment Relocation', 'Office Packing & Dismantling', 'Furniture Wrapping & Heavy Lifting', 'Inter-State Haulage', 'Fragile Item Crating'],
            'artisans' => [
                [
                    'name' => 'Fatima Bello',
                    'email' => 'fatima.movers@skilllink.ng',
                    'phone' => '+2348031234511',
                    'avatar' => 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=400',
                    'skill' => 'Relocation & Logistics Coordinator',
                    'bio' => 'Stress-free home and corporate relocations with enclosed trucks, bubble wrap protection, and zero-breakage guarantee.',
                    'experience' => 7,
                    'rating' => 5.0,
                    'reviews_count' => 48,
                    'hourly_rate' => 8000,
                    'location' => 'Ikeja GRA, Lagos',
                    'address' => 'Isaac John Street, GRA Ikeja',
                    'portfolio' => [
                        ['title' => '4-Bedroom Duplex Packing & Moving', 'url' => 'https://images.unsplash.com/photo-1600585154526-990dced4db0d?w=600'],
                    ],
                    'reviews' => [
                        ['name' => 'Barrister Fashola', 'rating' => 5, 'comment' => 'Moved our 4-bedroom house in one day without a single scratch or broken glass.'],
                    ]
                ]
            ]
        ]
    ];

    // Default password hash for all seed test accounts: 'password123'
    $defaultPasswordHash = password_hash('password123', PASSWORD_BCRYPT);

    $catStmt = $pdo->prepare("SELECT id FROM categories WHERE slug = ? OR name = ? LIMIT 1");
    $insCatStmt = $pdo->prepare("INSERT INTO categories (name, slug, icon, is_technical, sort_order) VALUES (?, ?, ?, 1, ?)");
    $userStmt = $pdo->prepare("SELECT id FROM users WHERE email = ? LIMIT 1");
    $insUserStmt = $pdo->prepare("INSERT INTO users (name, email, phone, password_hash, role, avatar_url, is_verified) VALUES (?, ?, ?, ?, 'artisan', ?, 1)");
    $updUserStmt = $pdo->prepare("UPDATE users SET name = ?, avatar_url = ?, is_verified = 1 WHERE id = ?");
    
    $insArtisanStmt = $pdo->prepare("INSERT INTO artisans 
        (user_id, bio, skill, category_id, experience_years, location_name, business_address, identity_verified, verification_status, average_rating, total_reviews, is_available, hourly_rate)
        VALUES (?, ?, ?, ?, ?, ?, ?, 1, 'approved', ?, ?, 1, ?)
        ON DUPLICATE KEY UPDATE 
        bio = VALUES(bio), skill = VALUES(skill), category_id = VALUES(category_id), experience_years = VALUES(experience_years), 
        location_name = VALUES(location_name), business_address = VALUES(business_address), identity_verified = 1, verification_status = 'approved',
        average_rating = VALUES(average_rating), total_reviews = VALUES(total_reviews), is_available = 1, hourly_rate = VALUES(hourly_rate)");

    $sortIndex = 1;
    $totalArtisansCreated = 0;

    foreach ($servicesByCategory as $catName => $data) {
        // 1. Ensure category exists
        $catStmt->execute([$data['slug'], $catName]);
        $catRow = $catStmt->fetch();
        if ($catRow) {
            $catId = $catRow['id'];
        } else {
            $insCatStmt->execute([$catName, $data['slug'], $data['icon'], $sortIndex]);
            $catId = $pdo->lastInsertId();
            echo "Created category: $catName (ID: $catId)\n";
        }
        $sortIndex++;

        // 2. Ensure category sub-services exist
        if (!empty($data['sub_services'])) {
            foreach ($data['sub_services'] as $subName) {
                try {
                    $subCheck = $pdo->prepare("SELECT id FROM category_services WHERE category_id = ? AND service_name = ?");
                    $subCheck->execute([$catId, $subName]);
                    if (!$subCheck->fetch()) {
                        $subIns = $pdo->prepare("INSERT INTO category_services (category_id, service_name, icon_name) VALUES (?, ?, ?)");
                        $subIns->execute([$catId, $subName, $data['icon']]);
                    }
                } catch (\Throwable $e) {}
            }
        }

        // 3. Create / Update Artisans for this category
        foreach ($data['artisans'] as $a) {
            $userStmt->execute([$a['email']]);
            $userRow = $userStmt->fetch();
            if ($userRow) {
                $userId = $userRow['id'];
                $updUserStmt->execute([$a['name'], $a['avatar'], $userId]);
            } else {
                $insUserStmt->execute([$a['name'], $a['email'], $a['phone'], $defaultPasswordHash, $a['avatar']]);
                $userId = $pdo->lastInsertId();
            }

            // Insert into artisans
            $insArtisanStmt->execute([
                $userId,
                $a['bio'],
                $a['skill'],
                $catId,
                $a['experience'],
                $a['location'],
                $a['address'],
                $a['rating'],
                $a['reviews_count'],
                $a['hourly_rate']
            ]);

            // Link category in artisan_categories
            try {
                $bridgeStmt = $pdo->prepare("INSERT IGNORE INTO artisan_categories (artisan_id, category_id) VALUES (?, ?)");
                $bridgeStmt->execute([$userId, $catId]);
            } catch (\Throwable $e) {}

            // Populate portfolio
            if (!empty($a['portfolio'])) {
                $pdo->prepare("DELETE FROM artisan_portfolios WHERE artisan_id = ?")->execute([$userId]);
                $portStmt = $pdo->prepare("INSERT INTO artisan_portfolios (artisan_id, image_url, description) VALUES (?, ?, ?)");
                foreach ($a['portfolio'] as $p) {
                    $portStmt->execute([$userId, $p['url'], $p['title']]);
                }
            }

            // Populate reviews
            if (!empty($a['reviews'])) {
                // Ensure a test customer user exists to author the reviews
                $custCheck = $pdo->prepare("SELECT id FROM users WHERE email = 'customer.test@skilllink.ng' LIMIT 1");
                $custCheck->execute();
                $custRow = $custCheck->fetch();
                if ($custRow) {
                    $customerId = $custRow['id'];
                } else {
                    $pdo->prepare("INSERT INTO users (name, email, phone, password_hash, role, avatar_url, is_verified) VALUES ('Verified Customer', 'customer.test@skilllink.ng', '+2348000000001', ?, 'customer', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200', 1)")->execute([$defaultPasswordHash]);
                    $customerId = $pdo->lastInsertId();
                }

                // Check reviews columns to see if booking_id is in table
                $revCols = $pdo->query("SHOW COLUMNS FROM reviews")->fetchAll(PDO::FETCH_COLUMN);
                $hasBookingId = in_array('booking_id', $revCols);

                $pdo->prepare("DELETE FROM reviews WHERE artisan_id = ?")->execute([$userId]);

                foreach ($a['reviews'] as $r) {
                    $bookingId = null;
                    if ($hasBookingId) {
                        // Create a completed booking to satisfy foreign key
                        $bkNumber = 'BK-SEED-' . substr(md5(uniqid()), 0, 8);
                        $bkStmt = $pdo->prepare("INSERT INTO bookings (booking_number, customer_id, artisan_id, category_id, service_description, scheduled_at, status, price, platform_fee, artisan_payout, created_at) VALUES (?, ?, ?, ?, 'Initial Service Consultation', DATE_SUB(NOW(), INTERVAL 3 DAY), 'completed', 5000, 500, 4500, DATE_SUB(NOW(), INTERVAL 3 DAY))");
                        $bkStmt->execute([$bkNumber, $customerId, $userId, $catId]);
                        $bookingId = $pdo->lastInsertId();

                        $revStmt = $pdo->prepare("INSERT INTO reviews (artisan_id, customer_id, booking_id, rating, comment, created_at) VALUES (?, ?, ?, ?, ?, NOW())");
                        $revStmt->execute([$userId, $customerId, $bookingId, $r['rating'], $r['comment']]);
                    } else {
                        $revStmt = $pdo->prepare("INSERT INTO reviews (artisan_id, customer_id, rating, comment, created_at) VALUES (?, ?, ?, ?, NOW())");
                        $revStmt->execute([$userId, $customerId, $r['rating'], $r['comment']]);
                    }
                }
            }

            echo "  ✓ Seeded Artisan: {$a['name']} ({$catName} - ₦{$a['hourly_rate']}/hr, Rating: {$a['rating']}★)\n";
            $totalArtisansCreated++;
        }
    }

    echo "\n🎉 SUCCESS: Seeded {$totalArtisansCreated} verified artisans across all " . count($servicesByCategory) . " categories!\n";
    echo "Default test password for all artisan logins: password123\n";

} catch (\Throwable $e) {
    echo "❌ Error during seeding: " . $e->getMessage() . "\n";
}
