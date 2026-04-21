<?php
/**
 * DashboardController.php
 * Handles the main admin dashboard view.
 */

namespace controllers;

use models\UserModel;
use models\BookingModel;
use models\PaymentModel;

class DashboardController extends BaseController {
    
    public function index() {
        $this->requireAuth();
        
        $db = $this->db();
        $userModel = new UserModel($db);
        $bookingModel = new BookingModel($db);
        $paymentModel = new PaymentModel($db);

        // Fetch real data
        $data = [
            'total_users'     => $userModel->getTotalUsers(),
            'active_artisans' => $userModel->getTotalArtisans(),
            'recent_bookings' => $bookingModel->getBookingsToday(),
            'revenue'         => $paymentModel->getMonthlyRevenue(), //Net Platform Revenue (MTD)
            'title'           => 'Admin Dashboard',
            'pending_artisans'=> array_slice($userModel->getArtisans(5), 0, 5) // For the "Recent Artisan Requests" table
        ];
        
        $this->render('dashboard/index', $data);
    }
}
