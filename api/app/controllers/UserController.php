<?php
namespace controllers;

use core\Controller;
use models\User;

class UserController extends Controller {

    public function profile() {
        $this->requireAuth();
        $user = $this->getCurrentUser();
        
        $userModel = new User();
        $userData = $userModel->findById($user['id']);
        
        if (!$userData) {
            $this->error('User not found', 404);
        }

        unset($userData['password_hash']);
        
        $this->json([
            'status' => 'success',
            'data' => $userData
        ]);
    }

    public function uploadAvatar() {
        $this->requireAuth();
        $user = $this->getCurrentUser();

        if (!isset($_FILES['avatar'])) {
            $this->error('No image file uploaded');
        }

        $file = $_FILES['avatar'];
        
        if ($file['error'] !== UPLOAD_ERR_OK) {
            $this->error('File upload error code: ' . $file['error']);
        }

        $uploadDir = __DIR__ . '/../../public/uploads/avatars/';
        
        if (!is_dir($uploadDir)) {
            if (!mkdir($uploadDir, 0777, true)) {
                $this->error('Failed to create upload directory. Check permissions.');
            }
        }

        $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
        if (empty($extension)) $extension = 'jpg'; // Fallback
        
        $fileName = 'avatar_' . $user['id'] . '_' . time() . '.' . $extension;
        $targetPath = $uploadDir . $fileName;

        if (move_uploaded_file($file['tmp_name'], $targetPath)) {
            $avatarUrl = 'uploads/avatars/' . $fileName;
            
            try {
                $userModel = new User();
                if ($userModel->updateAvatar($user['id'], $avatarUrl)) {
                    $this->json([
                        'status' => 'success',
                        'message' => 'Profile picture updated',
                        'data' => ['avatar_url' => $avatarUrl]
                    ]);
                } else {
                    $this->error('Failed to update database record');
                }
            } catch (\Exception $e) {
                $this->error('Database error: ' . $e->getMessage());
            }
        } else {
            $this->error('Failed to move uploaded file to target directory. Check permissions.');
        }
    }
}
