<?php
/**
 * Database Configuration — SkillLink Admin Panel
 * Provides a MySQLi connection singleton.
 */

define('DB_HOST', 'localhost');
define('DB_USER', 'quantu16_skilllink');
define('DB_PASS', 'quantu16_skilllink');
define('DB_NAME', 'quantu16_skilllink');

function getDB(): mysqli {
    static $conn = null;
    if ($conn === null) {
        $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
        if ($conn->connect_error) {
            http_response_code(500);
            die(json_encode(['error' => 'Database connection failed: ' . $conn->connect_error]));
        }
        $conn->set_charset('utf8mb4');
    }
    return $conn;
}
