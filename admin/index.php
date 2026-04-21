<?php
/**
 * SkillLink Admin Panel - Main Entry Point
 * Implements a simple MVC router for Pure PHP.
 */

// Start session early for auth checks
session_start();

// Define constants
define('ROOT_PATH', __DIR__);
define('APP_PATH', ROOT_PATH . '/app');

// Include configuration
require_once ROOT_PATH . '/config/config.php';

// Autoload classes (PSR-4 style simplicity)
spl_autoload_register(function ($class) {
    $file = APP_PATH . '/' . str_replace('\\', '/', $class) . '.php';
    if (file_exists($file)) {
        require_once $file;
    }
});

// --- Auth Guard ---
// Allow login.php to handle its own authentication
// All other admin routes require a valid admin session
$request_uri = $_SERVER['REQUEST_URI'] ?? '/';
$base_path   = ADMIN_ROOT; // Dynamically detected base

// Unified path parsing
$path = str_replace($base_path, '', $request_uri);
$path = trim(strtok($path, '?'), '/');

$public_routes = ['logout'];

// Determine controller and method
$parts           = explode('/', $path === '' ? 'dashboard' : $path);
$controller_name = ucfirst($parts[0] ?? 'dashboard') . 'Controller';
$method          = $parts[1] ?? 'index';

// Check auth unless it's a public route
$is_public = in_array(strtolower($parts[0] ?? ''), $public_routes);

if (!$is_public && empty($_SESSION['admin_id'])) {
    header('Location: ' . admin_url('login.php'));
    exit;
}

// --- Logout ---
if (strtolower($parts[0] ?? '') === 'logout') {
    $_SESSION = [];
    session_destroy();
    header('Location: ' . admin_url('login.php'));
    exit;
}

// --- Dispatch ---
$controller_class = "controllers\\$controller_name";

if (class_exists($controller_class)) {
    $obj = new $controller_class();
    if (method_exists($obj, $method)) {
        $obj->$method();
    } else {
        http_response_code(404);
        echo "404 — Method '<strong>$method</strong>' not found in <strong>$controller_name</strong>";
    }
} else {
    // Fallback: try including the file directly
    $controller_file = APP_PATH . '/controllers/' . $controller_name . '.php';
    if (file_exists($controller_file)) {
        require_once $controller_file;
        $obj = new $controller_name();
        if (method_exists($obj, $method)) {
            $obj->$method();
        } else {
            http_response_code(404);
            echo "404 — Method '<strong>$method</strong>' not found";
        }
    } else {
        http_response_code(404);
        echo "404 — Controller '<strong>$controller_name</strong>' not found. Path: <em>$path</em>";
    }
}
