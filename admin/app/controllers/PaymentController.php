<?php
/**
 * PaymentController.php
 * Handles financial logs and platform overview.
 */

namespace controllers;

use models\PaymentModel;

class PaymentController extends BaseController {
    
    public function index() {
        $this->requireAuth();
        $paymentModel = new PaymentModel($this->db());

        $page = (int)($_GET['page'] ?? 1);
        $limit = 20;
        $offset = ($page - 1) * $limit;

        $data = [
            'title' => 'Payment Management',
            'balance' => $paymentModel->getEscrowBalance(),
            'monthly_revenue' => $paymentModel->getMonthlyRevenue(),
            'transactions' => $paymentModel->getTransactions($limit, $offset),
            'total_transactions' => $paymentModel->countTransactions(),
            'current_page' => $page,
            'limit' => $limit
        ];
        
        $this->render('payments/index', $data);
    }
}
