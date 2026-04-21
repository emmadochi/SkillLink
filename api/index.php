<?php
/**
 * SkillLink API - Main Router
 * Handles all requests to /api/v1/
 */

// Basic CORS headers
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Define paths
define('ROOT_PATH', __DIR__);
define('APP_PATH', ROOT_PATH . '/app');
define('CORE_PATH', ROOT_PATH . '/core');

// Simple Autoloader
spl_autoload_register(function ($class) {
    // Convert namespace to path
    $classPath = str_replace('\\', '/', $class);
    
    // Check in CORE_PATH first, then APP_PATH
    $coreFile = CORE_PATH . '/' . basename($classPath) . '.php';
    if (file_exists($coreFile)) {
        require_once $coreFile;
        return;
    }

    $appFile = APP_PATH . '/' . $classPath . '.php';
    if (file_exists($appFile)) {
        require_once $appFile;
    }
});

// Route requested URI
$request_uri = $_SERVER['REQUEST_URI'];
$base_path = '/SkillLink/api/v1/';
$path = str_replace($base_path, '', $request_uri);
$path = explode('?', $path)[0]; // Remove query strings
$path = trim($path, '/');

// Dispatcher
$parts = explode('/', $path);
$controller_name = !empty($parts[0]) ? ucfirst($parts[0]) . 'Controller' : null;
$method = $parts[1] ?? 'index';

if (!$controller_name) {
    header('Content-Type: application/json');
    echo json_encode(['status' => 'ok', 'version' => '1.0.0', 'message' => 'SkillLink API is live.']);
    exit;
}

$controller_class = "controllers\\$controller_name";

if (class_exists($controller_class)) {
    $controller_instance = new $controller_class();
    if (method_exists($controller_instance, $method)) {
        // Pass remaining path parts as arguments
        $params = array_slice($parts, 2);
        call_user_func_array([$controller_instance, $method], $params);
    } else {
        http_response_code(404);
        echo json_encode(['error' => "Method '$method' not found in $controller_name"]);
    }
} else {
    http_response_code(404);
    echo json_encode(['error' => "Controller '$controller_name' not found."]);
}
