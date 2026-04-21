<?php
namespace core;

class Controller {
    
    /**
     * Send a JSON response to the client.
     */
    protected function json($data, $status = 200) {
        header('Content-Type: application/json; charset=utf-8');
        http_response_code($status);
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
}
