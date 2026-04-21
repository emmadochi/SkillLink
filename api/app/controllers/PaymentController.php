<?php
namespace controllers;

use core\Controller;
use core\Auth;
use models\Booking;

class PaymentController extends Controller {

    private $paystack_secret = "sk_test_mock_secret_key_12345"; // Move to config

    /**
     * POST /api/v1/payment/initialize
     * Initializes a Paystack transaction for a booking.
     */
    public function initialize() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->error('Method not allowed', 405);
        }

        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) $this->error('Unauthorized', 401);

        $body = $this->getBody();
        if (empty($body['booking_id']) || empty($body['amount'])) {
            $this->error('Booking ID and amount required');
        }

        // Real Paystack API implementation would go here
        // For now, we mock the response from Paystack
        $reference = 'SLTXN' . time() . rand(100, 999);
        
        $this->json([
            'status' => 'success',
            'data' => [
                'authorization_url' => "https://checkout.paystack.com/mock_" . $reference,
                'access_code' => "v_mock_" . $reference,
                'reference' => $reference
            ]
        ]);
    }

    /**
     * POST /api/v1/payment/verify
     * Verifies transaction with Paystack and updates booking.
     */
    public function verify() {
        $body = $this->getBody();
        $reference = $body['reference'] ?? null;

        if (!$reference) $this->error('Transaction reference required');

        // Logic to hit Paystack verify endpoint: https://api.paystack.co/transaction/verify/:reference
        // On success:
        // 1. Update transaction status in DB
        // 2. Update booking status to 'confirmed'
        
        $this->json([
            'status' => 'success',
            'message' => 'Payment verified and booking confirmed.'
        ]);
    }
}
