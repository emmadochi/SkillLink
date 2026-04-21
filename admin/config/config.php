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
    $script_dir = str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME']));
    
    // Ensure it ends with a slash, but handle root cases
    $base = rtrim($script_dir, '/') . '/';
    
    // If we're deep in a controller or subfile, we need to climb back to the 'admin' root
    // We use stripos for case-insensitive detection (e.g. /Admin/ vs /admin/)
    $admin_pos = stripos($base, '/admin/');
    if ($admin_pos !== false) {
        $base = substr($base, 0, $admin_pos + 7);
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
