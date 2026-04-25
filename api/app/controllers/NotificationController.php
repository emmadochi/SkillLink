<?php
namespace controllers;

use core\Controller;
use core\Auth;
use models\Notification;

class NotificationController extends Controller {

    public function index() {
        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) $this->error('Unauthorized', 401);

        try {
            $notificationModel = new Notification();
            $notifications = $notificationModel->getByUser($tokenData['id']);

            $this->json([
                'status' => 'success',
                'data' => $notifications
            ]);
        } catch (\Exception $e) {
            $this->error('Failed to load notifications: ' . $e->getMessage(), 500);
        }
    }

    public function markRead() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->error('Method not allowed', 405);
        }

        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) $this->error('Unauthorized', 401);

        $body = $this->getBody();
        $notificationId = $body['id'] ?? null;

        try {
            $notificationModel = new Notification();
            if ($notificationModel->markAsRead($tokenData['id'], $notificationId)) {
                $this->json([
                    'status' => 'success',
                    'message' => 'Notifications marked as read'
                ]);
            } else {
                $this->error('Failed to update notifications', 500);
            }
        } catch (\Exception $e) {
            $this->error('Error: ' . $e->getMessage(), 500);
        }
    }
}
