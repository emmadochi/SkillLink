<?php
/**
 * SkillLink Mega Diagnostic Tool
 * This script simulates an actual API request through the router logic.
 */
error_reporting(E_ALL);
ini_set('display_errors', 1);

define('ROOT_PATH', __DIR__);
define('APP_PATH', ROOT_PATH . '/app');
define('CORE_PATH', ROOT_PATH . '/core');

// 1. Test Autoloader
echo "<h1>Mega Diagnostic: Router & Autoloader</h1>";
echo "<h3>1. Testing Autoloader Logic...</h3>";

spl_autoload_register(function ($class) {
    $classPath = str_replace('\\', '/', $class);
    
    // Check if it's a Core class or an App class
    if (strpos($class, 'core\\') === 0) {
        $file = CORE_PATH . '/' . str_replace('core/', '', $classPath) . '.php';
    } else {
        $file = APP_PATH . '/' . $classPath . '.php';
    }

    echo "Attempting to load: <code>$class</code> from <code>$file</code>... ";
    if (file_exists($file)) {
        require_once $file;
        echo "<span style='color:green'>SUCCESS</span><br>";
    } else {
        echo "<span style='color:red'>FAILED (File not found)</span><br>";
    }
});

try {
    echo "<h3>2. Simulating ArtisanController Loading...</h3>";
    $controllerClass = "controllers\\ArtisanController";
    if (class_exists($controllerClass)) {
        $controller = new $controllerClass();
        echo "<p style='color:green'>✅ Controller Instance Created!</p>";
        
        echo "<h3>3. Testing JSON Output for Search...</h3>";
        $artisanModel = new \models\Artisan();
        $data = $artisanModel->search();
        
        echo "<p>Artisans found: " . count($data) . "</p>";
        
        $json = json_encode(['status' => 'success', 'data' => $data]);
        if ($json === false) {
            echo "<p style='color:red'>❌ JSON ENCODE FAILED! Error: " . json_last_error_msg() . "</p>";
        } else {
            echo "<p style='color:green'>✅ JSON ENCODE SUCCESS!</p>";
            echo "<textarea style='width:100%; height:100px;'>" . htmlspecialchars($json) . "</textarea>";
        }
    } else {
        echo "<p style='color:red'>❌ Class $controllerClass not found!</p>";
    }

} catch (\Throwable $e) {
    echo "<div style='background:#fee; padding:20px; border:2px solid red;'>";
    echo "<h2>❌ CRITICAL ERROR</h2>";
    echo "<p><b>Message:</b> " . $e->getMessage() . "</p>";
    echo "<p><b>File:</b> " . $e->getFile() . " (Line " . $e->getLine() . ")</p>";
    echo "</div>";
}
