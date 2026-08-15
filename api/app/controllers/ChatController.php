<?php
namespace controllers;

use core\Controller;
use models\Message;

class ChatController extends Controller {

    /**
     * POST /api/v1/chat/upload
     * Accepts photo, video, or audio file upload and returns public URL
     */
    public function upload() {
        $this->requireAuth();

        if (empty($_FILES['file'])) {
            $this->error('No file provided for upload');
        }

        $file = $_FILES['file'];
        if ($file['error'] !== UPLOAD_ERR_OK) {
            $this->error('File upload failed with error code: ' . $file['error']);
        }

        // Validate extensions
        $ext = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
        $imageExts = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
        $videoExts = ['mp4', 'mov', 'avi', 'mkv', 'webm'];
        $audioExts = ['aac', 'm4a', 'mp3', 'wav', 'ogg', 'opus', '3gp'];

        $type = 'text';
        if (in_array($ext, $imageExts)) {
            $type = 'image';
        } elseif (in_array($ext, $videoExts)) {
            $type = 'video';
        } elseif (in_array($ext, $audioExts)) {
            $type = 'audio';
        } else {
            $this->error('Unsupported file format: ' . $ext);
        }

        // Target directory: api/uploads/chat/
        $uploadDir = ROOT_PATH . '/uploads/chat/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }

        $filename = 'chat_' . $type . '_' . time() . '_' . rand(1000, 9999) . '.' . $ext;
        $targetPath = $uploadDir . $filename;

        if (move_uploaded_file($file['tmp_name'], $targetPath)) {
            $mediaUrl = 'uploads/chat/' . $filename;
            $this->json([
                'status' => 'success',
                'message' => 'Media uploaded successfully',
                'data' => [
                    'media_url' => $mediaUrl,
                    'message_type' => $type,
                    'file_name' => $file['name'],
                    'file_size' => $file['size']
                ]
            ]);
        } else {
            $this->error('Failed to move uploaded file', 500);
        }
    }

    /**
     * POST /api/v1/chat/send
     */
    public function send() {
        $this->requireAuth();
        $user = $this->getCurrentUser();
        $data = $this->getPostData();

        $receiverId = intval($data['receiver_id'] ?? 0);
        $message = trim($data['message'] ?? '');
        $type = trim($data['message_type'] ?? 'text');
        $mediaUrl = !empty($data['media_url']) ? trim($data['media_url']) : null;
        $mediaDuration = isset($data['media_duration']) ? intval($data['media_duration']) : null;

        if ($receiverId <= 0) {
            $this->error('Receiver ID is required');
        }

        if (empty($message) && empty($mediaUrl)) {
            $this->error('Message text or media is required');
        }

        // Default placeholder text if media sent with empty caption
        if (empty($message)) {
            if ($type === 'image') $message = '📷 Photo';
            elseif ($type === 'video') $message = '🎥 Video';
            elseif ($type === 'audio') $message = '🎤 Voice Note';
            else $message = 'Attachment';
        }

        try {
            $messageModel = new Message();
            if ($messageModel->send($user['id'], $receiverId, $message, $type, $mediaUrl, $mediaDuration)) {
                $this->json([
                    'status' => 'success',
                    'message' => 'Message sent',
                    'data' => [
                        'sender_id' => (int)$user['id'],
                        'receiver_id' => $receiverId,
                        'message' => $message,
                        'message_type' => $type,
                        'media_url' => $mediaUrl,
                        'media_duration' => $mediaDuration,
                        'created_at' => date('Y-m-d H:i:s')
                    ]
                ]);
            } else {
                $this->error('Failed to send message');
            }
        } catch (\Throwable $e) {
            $this->error('Chat error: ' . $e->getMessage(), 500);
        }
    }

    public function conversation($partnerId = null) {
        $this->requireAuth();
        $user = $this->getCurrentUser();

        if (!$partnerId) {
            $partnerId = $_GET['partner_id'] ?? null;
        }

        if (!$partnerId) $this->error('Partner ID required');

        try {
            $messageModel = new Message();
            $messages = $messageModel->getConversation($user['id'], $partnerId);
            $this->json(['status' => 'success', 'data' => $messages]);
        } catch (\Throwable $e) {
            $this->error('Failed to load conversation: ' . $e->getMessage());
        }
    }

    public function history() {
        $this->requireAuth();
        $user = $this->getCurrentUser();

        try {
            $messageModel = new Message();
            $chats = $messageModel->getChatList($user['id']);
            $this->json(['status' => 'success', 'data' => $chats]);
        } catch (\Throwable $e) {
            $this->error('Failed to load chat history: ' . $e->getMessage());
        }
    }
}
