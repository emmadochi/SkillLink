<?php
namespace core;

class Auth {
    private static $secret = "skilllink_super_secret_key_2026"; // In production, move to config/env

    /**
     * Generate a simple JWT token.
     */
    public static function generateToken($payload) {
        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
        $payload['iat'] = time();
        $payload['exp'] = time() + (60 * 60 * 24 * 7); // 1 week
        $payload = json_encode($payload);

        $base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
        $base64UrlPayload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));

        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, self::$secret, true);
        $base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

        return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
    }

    /**
     * Verify and decode a JWT token.
     */
    public static function verifyToken($token) {
        $parts = explode('.', $token);
        if (count($parts) !== 3) return false;

        [$header, $payload, $signature] = $parts;

        $validSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode(hash_hmac('sha256', $header . "." . $payload, self::$secret, true)));

        if ($signature !== $validSignature) return false;

        $decodedPayload = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $payload)), true);
        
        if (isset($decodedPayload['exp']) && $decodedPayload['exp'] < time()) {
            return false;
        }

        return $decodedPayload;
    }

    /**
     * Get bearer token from headers.
     */
    public static function getBearerToken() {
        $headers = self::getAllHeaders();
        if (isset($headers['Authorization'])) {
            if (preg_match('/Bearer\s(\S+)/', $headers['Authorization'], $matches)) {
                return $matches[1];
            }
        }
        
        // Fallback for some server configs
        if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            if (preg_match('/Bearer\s(\S+)/', $_SERVER['HTTP_AUTHORIZATION'], $matches)) {
                return $matches[1];
            }
        }
        
        return null;
    }

    /**
     * Polyfill for getallheaders() if it doesn't exist.
     */
    private static function getAllHeaders() {
        if (function_exists('getallheaders')) {
            return getallheaders();
        }
        $headers = [];
        foreach ($_SERVER as $name => $value) {
            if (substr($name, 0, 5) == 'HTTP_') {
                $headers[str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($name, 5)))))] = $value;
            }
        }
        return $headers;
    }
}
