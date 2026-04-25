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
        
        $json = json_encode($data);
        if ($json === false) {
            $json = json_encode([
                'status' => 'error',
                'message' => 'JSON Encoding Error: ' . json_last_error_msg()
            ]);
        }

        if (ob_get_length()) ob_clean(); 
        echo $json;
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
    protected function getCurrentUser($required = true) {
        $token = Auth::getBearerToken();
        $user = Auth::verifyToken($token);
        if ($required && !$user) {
            $this->error('Unauthorized', 401);
        }
        return $user;
    }

    /**
     * Handle file uploads
     */
    protected function uploadFile($fileKey, $targetDir = 'uploads/') {
        if (!isset($_FILES[$fileKey]) || $_FILES[$fileKey]['error'] !== UPLOAD_ERR_OK) {
            return null;
        }

        if (!is_dir($targetDir)) {
            mkdir($targetDir, 0777, true);
        }

        $file = $_FILES[$fileKey];
        $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = uniqid() . '.' . $ext;
        $targetPath = $targetDir . $filename;

        if (move_uploaded_file($file['tmp_name'], $targetPath)) {
            return $targetPath;
        }

        return null;
    }
}
