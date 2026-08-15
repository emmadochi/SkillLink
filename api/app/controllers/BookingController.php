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
                'offer_price' => $body['offer_price'] ?? null,
                'platform_fee' => $fee,
                'artisan_payout' => $payout
            ]);

            if ($id) {
                // Notify Artisan
                $notifModel = new \models\Notification();
                $notifModel->create([
                    'user_id' => $body['artisan_id'],
                    'type' => 'booking',
                    'title' => 'New Booking Request',
                    'message' => 'You have a new booking request for ' . $body['scheduled_at'],
                    'related_id' => $id
                ]);

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
     * POST /api/v1/booking/negotiate
     */
    public function negotiate() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->error('Method not allowed', 405);
        }

        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) $this->error('Unauthorized', 401);

        $body = $this->getBody();
        if (empty($body['id']) || empty($body['action'])) {
            $this->error('Booking ID and action (propose, accept, decline) are required');
        }

        $bookingId = intval($body['id']);
        $action = strtolower(trim($body['action']));
        $price = isset($body['price']) ? floatval($body['price']) : 0;
        $note = $body['note'] ?? null;

        try {
            $bookingModel = new Booking();
            $booking = $bookingModel->getById($bookingId);
            if (!$booking) {
                $this->error('Booking not found', 404);
            }

            $userId = $tokenData['id'];
            if ($booking['customer_id'] != $userId && $booking['artisan_id'] != $userId) {
                $this->error('Unauthorized to negotiate this booking', 403);
            }

            $isCustomer = ($booking['customer_id'] == $userId);
            $targetUserId = $isCustomer ? $booking['artisan_id'] : $booking['customer_id'];

            if ($bookingModel->updateNegotiation($bookingId, $price, $action, $note, $userId)) {
                $notifModel = new \models\Notification();
                
                if ($action === 'propose') {
                    $notifModel->create([
                        'user_id' => $targetUserId,
                        'type' => 'booking',
                        'title' => 'Price Counter-Offer Received',
                        'message' => ($isCustomer ? 'Customer' : 'Artisan') . ' counter-offered ₦' . number_format($price, 2) . ' on booking #' . $booking['booking_number'],
                        'related_id' => $bookingId
                    ]);
                } else if ($action === 'accept') {
                    $notifModel->create([
                        'user_id' => $targetUserId,
                        'type' => 'booking',
                        'title' => 'Price Offer Accepted!',
                        'message' => ($isCustomer ? 'Customer' : 'Artisan') . ' accepted the agreed price on booking #' . $booking['booking_number'] . '. Booking is confirmed!',
                        'related_id' => $bookingId
                    ]);
                } else if ($action === 'decline') {
                    $notifModel->create([
                        'user_id' => $targetUserId,
                        'type' => 'booking',
                        'title' => 'Price Offer Declined',
                        'message' => ($isCustomer ? 'Customer' : 'Artisan') . ' declined the counter-offer on booking #' . $booking['booking_number'],
                        'related_id' => $bookingId
                    ]);
                }

                $updated = $bookingModel->getById($bookingId);
                $this->json([
                    'status' => 'success',
                    'message' => 'Negotiation updated successfully',
                    'data' => $updated
                ]);
            } else {
                $this->error('Failed to update negotiation', 500);
            }
        } catch (\Exception $e) {
            $this->error('Negotiation error: ' . $e->getMessage(), 500);
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
            // Automatically clean up any expired pending bookings
            $bookingModel->expirePendingBookings(24);

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
     * POST /api/v1/booking/expirePending
     * Public or cron endpoint to expire inactive pending bookings.
     */
    public function expirePending() {
        try {
            $hours = intval($_GET['hours'] ?? 24);
            if ($hours <= 0) $hours = 24;

            $bookingModel = new Booking();
            $result = $bookingModel->expirePendingBookings($hours);

            $this->json([
                'status' => 'success',
                'message' => 'Processed pending booking expirations',
                'data' => $result
            ]);
        } catch (\Throwable $e) {
            $this->error('Failed to expire pending bookings: ' . $e->getMessage(), 500);
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
            $reason = $body['reason'] ?? null;
            $role = $tokenData['role'] ?? 'customer';
            
            if ($bookingModel->updateStatus($body['id'], $body['status'], $tokenData['id'], $role, $reason)) {
                $booking = $bookingModel->getById($body['id']);
                
                // Auto-Release Escrow Payout to Artisan when marked completed
                if ($booking && $body['status'] === 'completed') {
                    $artisanPayout = (float)($booking['artisan_payout'] ?? ($booking['price'] * 0.90));
                    $walletModel = new \models\Wallet();
                    $walletModel->releaseEscrowToBalance($booking['artisan_id'], $artisanPayout, $booking['id']);
                }

                // Notify the other party
                if ($booking) {
                    $recipientId = ($role === 'artisan') ? $booking['customer_id'] : $booking['artisan_id'];
                    $notifModel = new \models\Notification();
                    $notifModel->create([
                        'user_id' => $recipientId,
                        'type' => 'booking',
                        'title' => 'Booking ' . ucfirst($body['status']),
                        'message' => 'Your booking #' . $booking['booking_number'] . ' has been ' . $body['status'] . ($reason ? " (Reason: $reason)" : ''),
                        'related_id' => $body['id']
                    ]);
                }

                $this->json([
                    'status' => 'success',
                    'message' => 'Status updated to ' . $body['status']
                ]);
            } else {
                $this->error('Failed to update status or unauthorized', 403);
            }
        } catch (\Exception $e) {
            $this->error('Update error: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/v1/booking/liveTracking?booking_id=123
     * Returns real-time GPS tracking coordinates for the artisan and destination.
     */
    public function liveTracking() {
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
            $this->error('Method not allowed', 405);
        }

        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) $this->error('Unauthorized', 401);

        $bookingId = intval($_GET['booking_id'] ?? $_GET['id'] ?? 0);
        if ($bookingId <= 0) {
            $this->error('Booking ID is required');
        }

        try {
            $bookingModel = new Booking();
            $booking = $bookingModel->getById($bookingId);

            if (!$booking) {
                $this->error('Booking not found', 404);
            }

            // Authorization: User must be customer, artisan, or admin
            $userId = (int)$tokenData['id'];
            if ($userId !== (int)$booking['customer_id'] && $userId !== (int)$booking['artisan_id'] && ($tokenData['role'] ?? '') !== 'admin') {
                $this->error('Unauthorized to track this booking', 403);
            }

            $artisanModel = new \models\Artisan();
            $artisanLive = $artisanModel->getLiveLocation($booking['artisan_id']);

            // Get customer user details
            $userModel = new \models\User();
            $customer = $userModel->getById($booking['customer_id']);

            // Best available coordinates for artisan: live coordinates or base profile coordinates
            $artisanLat = $artisanLive['live_latitude'] ?? $artisanLive['base_latitude'] ?? null;
            $artisanLng = $artisanLive['live_longitude'] ?? $artisanLive['base_longitude'] ?? null;

            // Optional client destination coordinates passed via query if tracking from device
            $destLat = isset($_GET['dest_lat']) ? floatval($_GET['dest_lat']) : null;
            $destLng = isset($_GET['dest_lng']) ? floatval($_GET['dest_lng']) : null;

            $distanceKm = null;
            if ($artisanLat !== null && $artisanLng !== null && $destLat !== null && $destLng !== null) {
                // Haversine calculation
                $latFrom = deg2rad((float)$artisanLat);
                $lonFrom = deg2rad((float)$artisanLng);
                $latTo = deg2rad((float)$destLat);
                $lonTo = deg2rad((float)$destLng);

                $latDelta = $latTo - $latFrom;
                $lonDelta = $lonTo - $lonFrom;

                $angle = 2 * asin(sqrt(pow(sin($latDelta / 2), 2) + cos($latFrom) * cos($latTo) * pow(sin($lonDelta / 2), 2)));
                $distanceKm = round($angle * 6371, 2);
            }

            $this->json([
                'status' => 'success',
                'data' => [
                    'booking_id' => (int)$booking['id'],
                    'booking_number' => $booking['booking_number'],
                    'status' => $booking['status'],
                    'scheduled_at' => $booking['scheduled_at'],
                    'artisan' => [
                        'id' => (int)$booking['artisan_id'],
                        'name' => $artisanLive['name'] ?? 'Artisan',
                        'avatar_url' => $artisanLive['avatar_url'] ?? null,
                        'phone' => $artisanLive['phone'] ?? null,
                        'latitude' => $artisanLat !== null ? floatval($artisanLat) : null,
                        'longitude' => $artisanLng !== null ? floatval($artisanLng) : null,
                        'heading' => isset($artisanLive['heading']) ? floatval($artisanLive['heading']) : null,
                        'speed' => isset($artisanLive['speed']) ? floatval($artisanLive['speed']) : null,
                        'last_update' => $artisanLive['last_location_update'] ?? null,
                        'is_live' => !empty($artisanLive['live_latitude']) && !empty($artisanLive['live_longitude'])
                    ],
                    'customer' => [
                        'id' => (int)$booking['customer_id'],
                        'name' => $customer['name'] ?? 'Customer',
                        'phone' => $customer['phone'] ?? null
                    ],
                    'distance_km' => $distanceKm
                ]
            ]);
        } catch (\Throwable $e) {
            $this->error('Live tracking error: ' . $e->getMessage(), 500);
        }
    }
}

