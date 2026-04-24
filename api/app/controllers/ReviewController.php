<?php
namespace controllers;

use core\Controller;
use models\Review;
use models\Booking;

class ReviewController extends Controller {

    public function submit() {
        $this->requireAuth();
        $user = $this->getCurrentUser();

        $data = $this->getPostData();

        if (!isset($data['booking_id']) || !isset($data['rating'])) {
            $this->error('Booking ID and rating are required');
        }

        $bookingModel = new Booking();
        $booking = $bookingModel->getById($data['booking_id']);

        if (!$booking) {
            $this->error('Booking not found', 404);
        }

        if ($booking['customer_id'] != $user['id']) {
            $this->error('Unauthorized: You can only review your own bookings', 403);
        }

        if ($booking['status'] != 'completed') {
            $this->error('Reviews can only be submitted for completed bookings');
        }

        // Check if already reviewed
        $reviewModel = new Review();
        if ($this->hasAlreadyReviewed($data['booking_id'])) {
            $this->error('You have already submitted a review for this booking');
        }

        $reviewData = [
            'booking_id' => $data['booking_id'],
            'customer_id' => $user['id'],
            'artisan_id' => $booking['artisan_id'],
            'rating' => (int)$data['rating'],
            'comment' => $data['comment'] ?? ''
        ];

        if ($reviewModel->create($reviewData)) {
            $this->json([
                'status' => 'success',
                'message' => 'Review submitted successfully'
            ]);
        } else {
            $this->error('Failed to submit review');
        }
    }

    private function hasAlreadyReviewed($bookingId) {
        $db = (new \core\Database())->getConnection();
        $stmt = $db->prepare("SELECT id FROM reviews WHERE booking_id = :bid");
        $stmt->bindParam(':bid', $bookingId);
        $stmt->execute();
        return $stmt->fetch() ? true : false;
    }
}
