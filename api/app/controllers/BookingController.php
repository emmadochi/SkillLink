<?php
namespace controllers;

use core\Controller;
use core\Auth;
use models\Booking;

class BookingController extends Controller {

    /**
     * POST /api/v1/booking/create
     */
    public function create() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->error('Method not allowed', 405);
        }

        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) $this->error('Unauthorized', 401);

        $body = $this->getBody();
        if (empty($body['artisan_id']) || empty($body['scheduled_at'])) {
            $this->error('Missing booking details');
        }

        try {
            $bookingModel = new Booking();
            
            // Calculate fees (Example: 10% platform fee)
            $price = floatval($body['price'] ?? 5000);
            $fee = $price * 0.10;
            $payout = $price - $fee;

            $bookingNumber = 'SL' . date('ymd') . rand(1000, 9999);

            $id = $bookingModel->create([
                'booking_number' => $bookingNumber,
                'customer_id' => $tokenData['id'],
                'artisan_id' => $body['artisan_id'],
                'category_id' => $body['category_id'],
                'service_description' => $body['service_description'] ?? '',
                'scheduled_at' => $body['scheduled_at'],
                'price' => $price,
                'platform_fee' => $fee,
                'artisan_payout' => $payout
            ]);

            if ($id) {
                $this->json([
                    'status' => 'success',
                    'message' => 'Booking request sent successfully',
                    'data' => [
                        'booking_id' => $id,
                        'booking_number' => $bookingNumber
                    ]
                ], 201);
            } else {
                $this->error('Failed to process booking', 500);
            }

        } catch (\Exception $e) {
            $this->error('Booking error: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/v1/booking/history
     */
    public function history() {
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
            $this->error('Method not allowed', 405);
        }

        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) $this->error('Unauthorized', 401);

        try {
            $bookingModel = new Booking();
            $role = $tokenData['role'] ?? 'customer';
            $bookings = $bookingModel->getByUser($tokenData['id'], $role);

            $this->json([
                'status' => 'success',
                'data' => $bookings
            ]);
        } catch (\Exception $e) {
            $this->error('Failed to load history: ' . $e->getMessage(), 500);
        }
    }

    /**
     * POST /api/v1/booking/updateStatus
     */
    public function updateStatus() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->error('Method not allowed', 405);
        }

        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) $this->error('Unauthorized', 401);

        $body = $this->getBody();
        if (empty($body['id']) || empty($body['status'])) {
            $this->error('Booking ID and status required');
        }

        try {
            $bookingModel = new Booking();
            if ($bookingModel->updateStatus($body['id'], $body['status'])) {
                $this->json([
                    'status' => 'success',
                    'message' => 'Status updated to ' . $body['status']
                ]);
            } else {
                $this->error('Failed to update status', 500);
            }
        } catch (\Exception $e) {
            $this->error('Update error: ' . $e->getMessage(), 500);
        }
    }
}
