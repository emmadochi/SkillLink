<?php
/**
 * PaymentController.php
 * Handles financial logs and platform overview.
 */

namespace controllers;

class PaymentController {
    
    public function index() {
        $data = [
            'title' => 'Payment Management',
            'balance' => '₦4,250,800',
            'monthly_revenue' => '₦850,200',
            'transactions' => [
                ['id' => 'TXN-9021', 'customer' => 'John Doe', 'amount' => '₦5,000', 'fee' => '₦500', 'date' => '2026-04-20', 'status' => 'Successful'],
                ['id' => 'TXN-9020', 'customer' => 'Jane Smith', 'amount' => '₦15,000', 'fee' => '₦1,500', 'date' => '2026-04-20', 'status' => 'Successful'],
                ['id' => 'TXN-9019', 'customer' => 'Michael Obi', 'amount' => '₦12,500', 'fee' => '₦1,250', 'date' => '2026-04-19', 'status' => 'Successful'],
            ]
        ];
        
        $this->render('payments/index', $data);
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
