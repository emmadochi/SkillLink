<?php
/**
 * BookingController.php
 * Handles platform-wide booking logs.
 */

namespace controllers;

class BookingController {
    
    public function index() {
        // Mock data for bookings
        $data = [
            'title' => 'Booking Management',
            'bookings' => [
                [
                    'id' => 'SL-1029',
                    'customer' => 'John Doe',
                    'artisan' => 'Emmanuel Okafor',
                    'service' => 'Electrical Wiring',
                    'date' => '2026-04-22',
                    'time' => '10:00 AM',
                    'price' => '₦5,000',
                    'status' => 'Confirmed'
                ],
                [
                    'id' => 'SL-1028',
                    'customer' => 'Jane Smith',
                    'artisan' => 'Grace Okoro',
                    'service' => 'Catering',
                    'date' => '2026-04-21',
                    'time' => '2:00 PM',
                    'price' => '₦15,000',
                    'status' => 'In Progress'
                ],
                [
                    'id' => 'SL-1025',
                    'customer' => 'Michael Obi',
                    'artisan' => 'Chukwudi Adeyemi',
                    'service' => 'Plumbing',
                    'date' => '2026-04-19',
                    'time' => '09:00 AM',
                    'price' => '₦12,500',
                    'status' => 'Completed'
                ]
            ]
        ];
        
        $this->render('bookings/index', $data);
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
