<?php
/**
 * SkillLink Database Diagnostic Script
 * Run this from the command line: php check_db.php
 */

require_once 'core/Database.php';

use core\Database;

if (php_sapi_name() !== 'cli') {
    header('Content-Type: text/plain');
}

echo "--- SkillLink Database Diagnostic ---\n";

try {
    $db = new Database();
    $conn = $db->getConnection();

    if (!$conn) {
        echo "[ERROR] Database connection failed. Check your config in api/core/Database.php\n";
        exit(1);
    }

    echo "[OK] Connected to database successfully.\n";

    $tables = ['users', 'artisans', 'categories', 'artisan_verifications', 'artisan_portfolios'];
    
    foreach ($tables as $table) {
        $stmt = $conn->query("SHOW TABLES LIKE '$table'");
        if ($stmt->rowCount() > 0) {
            echo "[OK] Table '$table' exists.\n";
            
            if ($table === 'artisans') {
                $required_columns = ['business_address', 'guarantor_name', 'guarantor_phone', 'identity_verified'];
                $stmt = $conn->query("DESCRIBE artisans");
                $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
                
                foreach ($required_columns as $col) {
                    if (in_array($col, $columns)) {
                        echo "  [OK] Column 'artisans.$col' exists.\n";
                    } else {
                        echo "  [MISSING] Column 'artisans.$col' is MISSING!\n";
                    }
                }
            }

            if ($table === 'artisan_verifications') {
                $stmt = $conn->query("DESCRIBE artisan_verifications");
                $columns = $stmt->fetchAll(PDO::FETCH_COLUMN);
                echo "  [INFO] Columns found: " . implode(', ', $columns) . "\n";
            }
        } else {
            echo "[MISSING] Table '$table' does not exist!\n";
        }
    }

} catch (Exception $e) {
    echo "[CRITICAL] An error occurred: " . $e->getMessage() . "\n";
}

echo "--- Diagnostic Complete ---\n";
