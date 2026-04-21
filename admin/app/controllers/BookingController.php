<?php
/**
 * BookingController.php
 * Handles platform-wide booking logs.
 */

namespace controllers;

use models\BookingModel;

class BookingController extends BaseController {
    
    public function index() {
        $this->requireAuth();
        $bookingModel = new BookingModel($this->db());

        $status = $_GET['status'] ?? '';
        $page = (int)($_GET['page'] ?? 1);
        $limit = 20;
        $offset = ($page - 1) * $limit;

        $data = [
            'title' => 'Booking Management',
            'bookings' => $bookingModel->getAll($limit, $offset, $status),
            'total' => $bookingModel->count($status),
            'current_page' => $page,
            'limit' => $limit,
            'status_filter' => $status
        ];
        
        $this->render('bookings/index', $data);
    }
}
