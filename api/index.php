<?php
/**
 * SkillLink API - Main Router
 * Handles all requests to /api/v1/
 */

error_reporting(E_ALL);
ini_set('display_errors', 1);
ob_start(); // Buffer output to prevent warnings from breaking JSON

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

// Universal Autoloader
spl_autoload_register(function ($class) {
    $classPath = str_replace('\\', '/', $class);
    
    // Check if it's a Core class or an App class
    if (strpos($class, 'core\\') === 0) {
        $file = CORE_PATH . '/' . str_replace('core/', '', $classPath) . '.php';
    } else {
        $file = APP_PATH . '/' . $classPath . '.php';
    }

    if (file_exists($file)) {
        require_once $file;
    }
});

// Route requested URI
$request_uri = $_SERVER['REQUEST_URI'];
$script_name = $_SERVER['SCRIPT_NAME']; 
$base_path = '/api/v1';

// Get the path after /v1 accurately
$full_path = parse_url($request_uri, PHP_URL_PATH);
$path = $full_path;

// Remove base path if present
if (strpos($path, $base_path) !== false) {
    $path = substr($path, strpos($path, $base_path) + strlen($base_path));
}

$path = trim($path, '/');

// Robustness: If path starts with 'api' or 'v1' after stripping, strip it again
// This handles cases like /api/v1/api/artisans or /api/v1/v1/artisans
$path_parts = explode('/', $path);
while (!empty($path_parts) && ($path_parts[0] === 'api' || $path_parts[0] === 'v1')) {
    array_shift($path_parts);
}
$path = implode('/', $path_parts);

// Dispatcher
$parts = explode('/', $path);
$controller_name = !empty($parts[0]) ? ucfirst($parts[0]) . 'Controller' : null;
$method = $parts[1] ?? 'index';
if ($method === "") $method = 'index';

// Convert kebab-case (e.g. upload-avatar) to camelCase (e.g. uploadAvatar)
if (strpos($method, '-') !== false) {
    $parts_method = explode('-', $method);
    $method = $parts_method[0] . implode('', array_map('ucfirst', array_slice($parts_method, 1)));
}

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
