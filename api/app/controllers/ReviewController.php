<?php
namespace controllers;

use core\Controller;
use models\Review;
use models\Booking;
use models\Notification;

class ReviewController extends Controller {

    /**
     * POST /api/v1/review/submit
     */
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
            'comment' => $data['comment'] ?? '',
            'quality_tags' => $data['quality_tags'] ?? null,
            'before_photo_url' => $data['before_photo_url'] ?? null,
            'after_photo_url' => $data['after_photo_url'] ?? null
        ];

        if ($reviewModel->create($reviewData)) {
            // Notify the artisan
            $notifModel = new Notification();
            $notifModel->create([
                'user_id' => $booking['artisan_id'],
                'type' => 'review',
                'title' => 'New Service Review (⭐ ' . $data['rating'] . '/5)',
                'message' => 'A customer reviewed your completed work for booking #' . $booking['booking_number'] . '.',
                'related_id' => $data['booking_id']
            ]);

            $this->json([
                'status' => 'success',
                'message' => 'Review submitted successfully'
            ]);
        } else {
            $this->error('Failed to submit review');
        }
    }

    /**
     * POST /api/v1/review/uploadPhoto
     */
    public function uploadPhoto() {
        $this->requireAuth();

        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->error('Method not allowed', 405);
        }

        if (!isset($_FILES['photo']) || $_FILES['photo']['error'] !== UPLOAD_ERR_OK) {
            $this->error('No photo file provided or upload error', 400);
        }

        $file = $_FILES['photo'];
        $uploadDir = __DIR__ . '/../../uploads/reviews/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }

        $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        $allowed = ['jpg', 'jpeg', 'png', 'webp'];
        if (!in_array($ext, $allowed)) {
            $this->error('Invalid file type. Allowed: JPG, PNG, WebP', 400);
        }

        $fileName = 'review_' . time() . '_' . rand(1000, 9999) . '.' . $ext;
        $targetPath = $uploadDir . $fileName;

        if (move_uploaded_file($file['tmp_name'], $targetPath)) {
            $this->json([
                'status' => 'success',
                'message' => 'Photo uploaded successfully',
                'data' => [
                    'photo_url' => 'uploads/reviews/' . $fileName
                ]
            ]);
        } else {
            $this->error('Failed to save uploaded photo', 500);
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
