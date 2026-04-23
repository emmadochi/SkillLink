<?php
/**
 * Global Configuration - SkillLink Admin
 * Dynamically detects the base URL to prevent broken links in different environments.
 */
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Define the root URL path for the admin panel
if (!defined('ADMIN_ROOT')) {
    // Detect the script's directory relative to the document root
    $script_name = $_SERVER['SCRIPT_NAME'];
    $admin_pos = stripos($script_name, '/admin/');
    
    if ($admin_pos !== false) {
        $base = substr($script_name, 0, $admin_pos + 7);
    } else {
        // Fallback to simple directory detection
        $script_dir = str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME']));
        $base = rtrim($script_dir, '/') . '/';
    }
    
    define('ADMIN_ROOT', $base);
}

// Define the absolute project root (one level above admin)
if (!defined('PROJECT_ROOT')) {
    define('PROJECT_ROOT', rtrim(str_replace('/admin', '', ADMIN_ROOT), '/') . '/');
}

/**
 * Helper to generate absolute URLs within the admin panel
 */
function admin_url($path = '') {
    return ADMIN_ROOT . ltrim($path, '/');
}

/**
 * Helper to generate absolute URLs for project-wide assets (like logos)
 */
function asset_url($path = '') {
    return PROJECT_ROOT . ltrim($path, '/');
}
