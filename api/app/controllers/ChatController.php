<?php
namespace controllers;

use core\Controller;
use models\Message;

class ChatController extends Controller {

    public function send() {
        $this->requireAuth();
        $user = $this->getCurrentUser();
        $data = $this->getPostData();

        if (empty($data['receiver_id']) || empty($data['message'])) {
            $this->error('Receiver and message are required');
        }

        try {
            $messageModel = new Message();
            if ($messageModel->send($user['id'], $data['receiver_id'], $data['message'])) {
                $this->json(['status' => 'success', 'message' => 'Message sent']);
            } else {
                $this->error('Failed to send message');
            }
        } catch (\Throwable $e) {
            $this->error('Chat error: ' . $e->getMessage());
        }
    }

    public function conversation($partnerId = null) {
        $this->requireAuth();
        $user = $this->getCurrentUser();

        // If not passed via path, check query string
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
