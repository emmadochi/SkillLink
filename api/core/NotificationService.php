<?php
namespace core;

class NotificationService {
    
    private static $fcm_server_key = "MOCK_FCM_KEY_12345"; // Move to config

    /**
     * Send a push notification via FCM.
     */
    public static function send($to_token, $title, $body, $data = []) {
        $url = 'https://fcm.googleapis.com/fcm/send';
        
        $fields = [
            'to' => $to_token,
            'notification' => [
                'title' => $title,
                'body' => $body,
                'sound' => 'default'
            ],
            'data' => $data
        ];

        $headers = [
            'Authorization: key=' . self::$fcm_server_key,
            'Content-Type: application/json'
        ];

        // In a real implementation, use cURL to send the request
        /*
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($fields));
        $result = curl_exec($ch);
        curl_close($ch);
        */

        return true; 
    }
}
