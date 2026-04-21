<?php
/**
 * SettingsController.php
 * Handles platform configuration and service categories.
 */

namespace controllers;

class SettingsController {
    
    public function index() {
        $data = [
            'title' => 'Platform Settings',
            'categories' => [
                ['id' => 1, 'name' => 'Plumbing', 'count' => 125],
                ['id' => 2, 'name' => 'Electrical', 'count' => 98],
                ['id' => 3, 'name' => 'Cleaning', 'count' => 156],
                ['id' => 4, 'name' => 'Catering', 'count' => 42],
                ['id' => 5, 'name' => 'Carpentry', 'count' => 31],
            ],
            'settings' => [
                'platform_fee' => '10%',
                'min_payout' => '₦5,000',
                'support_email' => 'support@skilllink.com'
            ]
        ];
        
        $this->render('settings/index', $data);
    }
    
    protected function render($view, $data = []) {
        extract($data);
        $view_file = APP_PATH . '/views/' . $view . '.php';
        if (file_exists($view_file)) {
            require_once APP_PATH . '/views/layout.php';
        } else {
            echo "View '$view' not found";
        }
    }
}
