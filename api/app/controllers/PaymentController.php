<?php
namespace controllers;

use core\Controller;
use core\Auth;
use models\Booking;
use models\Wallet;
use models\Notification;

class PaymentController extends Controller {

    private $paystack_secret = "sk_test_mock_secret_key_12345";

    /**
     * POST /api/v1/payment/initialize
     * Initializes a Paystack / Flutterwave transaction for escrow holding.
     */
    public function initialize() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->error('Method not allowed', 405);
        }

        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) $this->error('Unauthorized', 401);

        $body = $this->getBody();
        $bookingId = intval($body['booking_id'] ?? 0);
        $amount = floatval($body['amount'] ?? 0);
        $gateway = trim($body['gateway'] ?? 'paystack'); // 'paystack' or 'flutterwave'

        if ($bookingId <= 0 || $amount <= 0) {
            $this->error('Booking ID and valid amount are required');
        }

        try {
            $bookingModel = new Booking();
            $booking = $bookingModel->getById($bookingId);
            if (!$booking) {
                $this->error('Booking not found', 404);
            }

            $reference = 'SL-ESCROW-' . time() . '-' . rand(1000, 9999);
            
            // Record pending escrow transaction
            $db = new \core\Database();
            $conn = $db->getConnection();
            if ($conn) {
                $tStmt = $conn->prepare("
                    INSERT INTO transactions (booking_id, user_id, amount, type, payment_method, payment_reference, status)
                    VALUES (:bid, :uid, :amt, 'payment', 'card', :ref, 'pending')
                ");
                $tStmt->bindParam(':bid', $bookingId);
                $tStmt->bindParam(':uid', $tokenData['id']);
                $tStmt->bindParam(':amt', $amount);
                $tStmt->bindParam(':ref', $reference);
                $tStmt->execute();
            }

            $authUrl = ($gateway === 'flutterwave') 
                ? "https://checkout.flutterwave.com/v3/hosted/pay/mock_" . $reference
                : "https://checkout.paystack.com/mock_" . $reference;

            $this->json([
                'status' => 'success',
                'message' => 'Escrow transaction initialized',
                'data' => [
                    'gateway' => $gateway,
                    'authorization_url' => $authUrl,
                    'access_code' => "v_mock_" . $reference,
                    'reference' => $reference,
                    'amount' => $amount,
                    'booking_id' => $bookingId,
                    'escrow_note' => 'Funds will be held securely in escrow until job completion is verified.'
                ]
            ]);
        } catch (\Throwable $e) {
            $this->error('Payment initialization error: ' . $e->getMessage(), 500);
        }
    }

    /**
     * POST /api/v1/payment/verify
     * Verifies transaction and locks funds in escrow for the artisan.
     */
    public function verify() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->error('Method not allowed', 405);
        }

        $body = $this->getBody();
        $reference = $body['reference'] ?? null;

        if (!$reference) $this->error('Transaction reference required');

        try {
            $db = new \core\Database();
            $conn = $db->getConnection();
            if (!$conn) $this->error('Database error', 500);

            // Fetch transaction
            $stmt = $conn->prepare("SELECT * FROM transactions WHERE payment_reference = :ref");
            $stmt->bindParam(':ref', $reference);
            $stmt->execute();
            $txn = $stmt->fetch(\PDO::FETCH_ASSOC);

            if (!$txn) {
                $this->error('Transaction reference not found', 404);
            }

            $bookingId = (int)$txn['booking_id'];
            $bookingModel = new Booking();
            $booking = $bookingModel->getById($bookingId);

            if (!$booking) {
                $this->error('Associated booking not found', 404);
            }

            // 1. Mark transaction successful
            $updTxn = $conn->prepare("UPDATE transactions SET status = 'successful' WHERE id = :id");
            $updTxn->bindParam(':id', $txn['id']);
            $updTxn->execute();

            // 2. Mark booking as confirmed / escrow locked
            $updBook = $conn->prepare("UPDATE bookings SET status = 'confirmed', updated_at = NOW() WHERE id = :bid");
            $updBook->bindParam(':bid', $bookingId);
            $updBook->execute();

            // 3. Credit artisan's pending escrow balance
            $artisanPayout = (float)($booking['artisan_payout'] ?? ($booking['price'] * 0.90));
            $walletModel = new Wallet();
            $walletModel->creditPendingEscrow($booking['artisan_id'], $artisanPayout);

            // 4. Notify both parties
            $notif = new Notification();
            $notif->create([
                'user_id' => $booking['customer_id'],
                'type' => 'booking',
                'title' => 'Payment Secured in Escrow',
                'message' => 'Your payment of ₦' . number_format($txn['amount'], 2) . ' for booking #' . $booking['booking_number'] . ' is held securely in escrow.',
                'related_id' => $bookingId
            ]);

            $notif->create([
                'user_id' => $booking['artisan_id'],
                'type' => 'booking',
                'title' => 'New Escrow-Secured Job! 🛡️',
                'message' => 'Payment for booking #' . $booking['booking_number'] . ' is confirmed in escrow. ₦' . number_format($artisanPayout, 2) . ' will be credited to your wallet once completed.',
                'related_id' => $bookingId
            ]);

            $this->json([
                'status' => 'success',
                'message' => 'Payment verified. Funds held securely in escrow.',
                'data' => [
                    'booking_id' => $bookingId,
                    'booking_number' => $booking['booking_number'],
                    'status' => 'confirmed',
                    'escrow_amount' => (float)$txn['amount'],
                    'artisan_payout_pending' => $artisanPayout
                ]
            ]);
        } catch (\Throwable $e) {
            $this->error('Verification error: ' . $e->getMessage(), 500);
        }
    }

    /**
     * POST /api/v1/payment/escrowHold
     * Direct in-app escrow checkout simulation
     */
    public function escrowHold() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->error('Method not allowed', 405);
        }

        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) $this->error('Unauthorized', 401);

        $body = $this->getBody();
        $bookingId = intval($body['booking_id'] ?? 0);

        if ($bookingId <= 0) $this->error('Booking ID is required');

        try {
            $bookingModel = new Booking();
            $booking = $bookingModel->getById($bookingId);
            if (!$booking) $this->error('Booking not found', 404);

            $reference = 'SL-ESCROW-' . time() . '-' . rand(100, 999);
            $amount = (float)$booking['price'];
            $artisanPayout = (float)($booking['artisan_payout'] ?? ($amount * 0.90));

            $db = new \core\Database();
            $conn = $db->getConnection();
            if (!$conn) $this->error('Database connection failed', 500);

            // Record transaction
            $tStmt = $conn->prepare("
                INSERT INTO transactions (booking_id, user_id, amount, type, payment_method, payment_reference, status)
                VALUES (:bid, :uid, :amt, 'payment', 'card', :ref, 'successful')
            ");
            $tStmt->bindParam(':bid', $bookingId);
            $tStmt->bindParam(':uid', $tokenData['id']);
            $tStmt->bindParam(':amt', $amount);
            $tStmt->bindParam(':ref', $reference);
            $tStmt->execute();

            // Update booking status
            $upd = $conn->prepare("UPDATE bookings SET status = 'confirmed', updated_at = NOW() WHERE id = :bid");
            $upd->bindParam(':bid', $bookingId);
            $upd->execute();

            // Credit artisan pending escrow
            $walletModel = new Wallet();
            $walletModel->creditPendingEscrow($booking['artisan_id'], $artisanPayout);

            // Notify parties
            $notif = new Notification();
            $notif->create([
                'user_id' => $booking['customer_id'],
                'type' => 'booking',
                'title' => 'Escrow Secured',
                'message' => '₦' . number_format($amount, 2) . ' secured in escrow for booking #' . $booking['booking_number'],
                'related_id' => $bookingId
            ]);

            $this->json([
                'status' => 'success',
                'message' => 'Funds locked in escrow successfully',
                'data' => [
                    'booking_id' => $bookingId,
                    'booking_number' => $booking['booking_number'],
                    'status' => 'confirmed',
                    'reference' => $reference,
                    'amount' => $amount
                ]
            ]);
        } catch (\Throwable $e) {
            $this->error('Escrow hold error: ' . $e->getMessage(), 500);
        }
    }
}
