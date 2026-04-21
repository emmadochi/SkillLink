<?php
/**
 * DashboardController.php
 * Handles the main admin dashboard view.
 */

namespace controllers;

class DashboardController {
    
    public function index() {
        // Mock data for the dashboard
        $data = [
            'total_users' => 1250,
            'active_artisans' => 450,
            'recent_bookings' => 85,
            'revenue' => '₦1.2M',
            'title' => 'Admin Dashboard'
        ];
        
        $this->render('dashboard/index', $data);
    }
    
    protected function render($view, $data = []) {
        extract($data);
        $view_file = APP_PATH . '/views/' . $view . '.php';
        
        if (file_exists($view_file)) {
            // Load the full layout
            require_once APP_PATH . '/views/layout.php';
        } else {
            echo "View '$view' not found at $view_file";
        }
    }
}
