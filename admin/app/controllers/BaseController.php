<?php
/**
 * BaseController.php
 * Shared base for all admin controllers.
 * Provides render(), db access, and auth guard.
 */

namespace controllers;

require_once ROOT_PATH . '/config/db.php';

abstract class BaseController {

    /**
     * Render a view inside layout.php.
     */
    protected function render(string $view, array $data = []): void {
        extract($data);
        $view_file = APP_PATH . '/views/' . $view . '.php';

        if (file_exists($view_file)) {
            require_once APP_PATH . '/views/layout.php';
        } else {
            http_response_code(404);
            echo "View '<strong>$view</strong>' not found at: $view_file";
        }
    }

    /**
     * Get a live MySQLi database connection.
     */
    protected function db(): \mysqli {
        return getDB();
    }

    /**
     * Guard: redirect to login if not authenticated.
     */
    protected function requireAuth(): void {
        if (session_status() === PHP_SESSION_NONE) {
            session_start();
        }
        if (empty($_SESSION['admin_id'])) {
            header('Location: ' . admin_url('login.php'));
            exit;
        }
    }

    /**
     * Redirect helper.
     */
    protected function redirect(string $path): void {
        header("Location: " . admin_url($path));
        exit;
    }

    /**
     * Return a 405 if the request method doesn't match.
     */
    protected function requireMethod(string $method): void {
        if ($_SERVER['REQUEST_METHOD'] !== strtoupper($method)) {
            http_response_code(405);
            die("Method Not Allowed. Expected: $method");
        }
    }
}
