<?php
namespace core;

use core\Auth;

class Controller {
    
    /**
     * Send a JSON response to the client.
     */
    protected function json($data, $status = 200) {
        header('Content-Type: application/json; charset=utf-8');
        http_response_code($status);
        if (ob_get_length()) ob_clean(); // Clear any stray warnings/output
        echo json_encode($data);
        exit;
    }

    /**
     * Handle error responses.
     */
    protected function error($message, $status = 400) {
        $this->json([
            'status' => 'error',
            'message' => $message
        ], $status);
    }

    /**
     * Get JSON request body.
     */
    protected function getBody() {
        $json = file_get_contents('php://input');
        return json_decode($json, true);
    }

    /**
     * Get POST data from body or $_POST
     */
    protected function getPostData() {
        $body = $this->getBody();
        return $body ? $body : $_POST;
    }

    /**
     * Ensure the user is authenticated.
     */
    protected function requireAuth() {
        $token = Auth::getBearerToken();
        if (!$token || !Auth::verifyToken($token)) {
            $this->error('Unauthorized: Valid token required', 401);
        }
    }

    /**
     * Get the currently logged-in user data from token.
     */
    protected function getCurrentUser() {
        $token = Auth::getBearerToken();
        return Auth::verifyToken($token);
    }
}
