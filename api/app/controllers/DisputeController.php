<?php
namespace controllers;

use core\Controller;
use core\Auth;
use models\Dispute;

class DisputeController extends Controller {

    /**
     * POST /api/v1/dispute/create
     * Body: { booking_id: int, reason: string }
     */
    public function create() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->error('Method not allowed', 405);
        }

        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) {
            $this->error('Unauthorized', 401);
        }

        $body = $this->getBody();
        if (empty($body['booking_id']) || empty($body['reason'])) {
            $this->error('Booking ID and reason are required', 400);
        }

        try {
            $disputeModel = new Dispute();
            $result = $disputeModel->create(
                intval($body['booking_id']),
                intval($tokenData['id']),
                trim($body['reason'])
            );

            if ($result['success']) {
                $this->json([
                    'status' => 'success',
                    'message' => $result['message'],
                    'data' => [
                        'dispute_id' => $result['dispute_id']
                    ]
                ], 201);
            } else {
                $this->error($result['message'], 400);
            }
        } catch (\Throwable $e) {
            $this->error('Dispute submission error: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/v1/dispute/booking/:bookingId
     */
    public function booking($bookingId = null) {
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
            $this->error('Method not allowed', 405);
        }

        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) {
            $this->error('Unauthorized', 401);
        }

        if (!$bookingId) {
            $bookingId = $_GET['booking_id'] ?? null;
        }

        if (!$bookingId) {
            $this->error('Booking ID required', 400);
        }

        try {
            $disputeModel = new Dispute();
            $dispute = $disputeModel->getByBooking(intval($bookingId), intval($tokenData['id']));

            $this->json([
                'status' => 'success',
                'data' => $dispute ?: null
            ]);
        } catch (\Throwable $e) {
            $this->error('Failed to get dispute: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/v1/dispute/history
     */
    public function history() {
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
            $this->error('Method not allowed', 405);
        }

        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) {
            $this->error('Unauthorized', 401);
        }

        try {
            $disputeModel = new Dispute();
            $disputes = $disputeModel->getByUser(intval($tokenData['id']));

            $this->json([
                'status' => 'success',
                'data' => $disputes
            ]);
        } catch (\Throwable $e) {
            $this->error('Failed to get disputes: ' . $e->getMessage(), 500);
        }
    }
}
