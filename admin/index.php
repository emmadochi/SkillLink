<?php
/**
 * SkillLink Admin Panel - Main Entry Point
 * Implements a simple MVC router for Pure PHP.
 */

// Define constants
define('ROOT_PATH', __DIR__);
define('APP_PATH', ROOT_PATH . '/app');

// Autoload classes (PSR-4 style simplicity)
spl_autoload_register(function ($class) {
    $file = APP_PATH . '/' . str_replace('\\', '/', $class) . '.php';
    if (file_exists($file)) {
        require_once $file;
    }
});

// Simple Router
$request_uri = $_SERVER['REQUEST_URI'] ?? '/';
$base_path = '/SkillLink/admin/';
$path = str_replace($base_path, '', $request_uri);
$path = trim($path, '/');

// Default Route
if ($path === '' || $path === 'index.php') {
    $controller = 'DashboardController';
    $method = 'index';
} else {
    $parts = explode('/', $path);
    $controller = ucfirst($parts[0]) . 'Controller';
    $method = $parts[1] ?? 'index';
}

// Dispatch
$controller_class = "controllers\\$controller";
if (class_exists($controller_class)) {
    $obj = new $controller_class();
    if (method_exists($obj, $method)) {
        $obj->$method();
    } else {
        http_response_code(404);
        echo "404 - Method '$method' not found in $controller";
    }
} else {
    // If controller file exists but class not found, might need full path
    $controller_file = APP_PATH . '/controllers/' . $controller . '.php';
    if (file_exists($controller_file)) {
        require_once $controller_file;
        $obj = new $controller();
        if (method_exists($obj, $method)) {
            $obj->$method();
        } else {
            http_response_code(404);
            echo "404 - Method '$method' not found";
        }
    } else {
        http_response_code(404);
        echo "404 - Controller '$controller' not found. Path: $path";
    }
}
