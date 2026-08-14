<?php
/**
 * SkillLink - Automated Scheduled Task
 * Auto-cancels pending bookings that have received no artisan response after 24 hours.
 * 
 * Usage:
 * CLI: php api/cron_expire_bookings.php
 * Web/Cron trigger: curl -s "https://yourdomain.com/api/cron_expire_bookings.php?key=skilllink_cron_secret"
 */

// Define paths
define('ROOT_PATH', __DIR__);
define('APP_PATH', ROOT_PATH . '/app');
define('CORE_PATH', ROOT_PATH . '/core');

// Universal Autoloader
spl_autoload_register(function ($class) {
    $classPath = str_replace('\\', '/', $class);
    if (strpos($class, 'core\\') === 0) {
        $file = CORE_PATH . '/' . str_replace('core/', '', $classPath) . '.php';
    } else {
        $file = APP_PATH . '/' . $classPath . '.php';
    }
    if (file_exists($file)) {
        require_once $file;
    }
});

header('Content-Type: application/json');

$timestamp = date('Y-m-d H:i:s');
echo "[$timestamp] Starting SkillLink auto-cancellation worker...\n";

try {
    $bookingModel = new \models\Booking();
    $inactivityHours = 24;
    $result = $bookingModel->expirePendingBookings($inactivityHours);

    $count = $result['count'] ?? 0;
    $expired = implode(', ', $result['expired'] ?? []);

    echo "[$timestamp] Success: $count pending booking(s) auto-cancelled ($expired).\n";
    echo json_encode([
        'status' => 'success',
        'timestamp' => $timestamp,
        'expired_count' => $count,
        'expired_bookings' => $result['expired'] ?? []
    ], JSON_PRETTY_PRINT);
} catch (\Throwable $e) {
    $err = $e->getMessage();
    echo "[$timestamp] Error running expiration worker: $err\n";
    echo json_encode([
        'status' => 'error',
        'timestamp' => $timestamp,
        'error' => $err
    ], JSON_PRETTY_PRINT);
}
