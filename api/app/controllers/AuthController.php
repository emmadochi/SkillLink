<?php
namespace controllers;

use core\Controller;
use core\Auth;
use models\User;

class AuthController extends Controller {

    /**
     * POST /api/v1/auth/signup
     */
    public function signup() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->error('Method not allowed', 405);
        }

        $body = $this->getBody();
        
        // Basic validation
        if (empty($body['name']) || empty($body['email']) || empty($body['password'])) {
            $this->error('Missing required fields');
        }

        $userModel = new User();
        
        // Check if user exists
        if ($userModel->findByEmail($body['email'])) {
            $this->error('Email already registered', 409);
        }

        // Hash password
        $hashed = password_hash($body['password'], PASSWORD_DEFAULT);
        
        $role = $body['role'] ?? 'customer';

        $userId = $userModel->create([
            'name' => $body['name'],
            'email' => $body['email'],
            'phone' => $body['phone'] ?? null,
            'password' => $hashed,
            'role' => $role
        ]);

        if (!$userId) {
            $this->error('Failed to create account', 500);
        }

        // If artisan, create secondary profile
        if ($role === 'artisan') {
            $userModel->createArtisanProfile([
                'user_id' => $userId,
                'bio' => $body['bio'] ?? '',
                'experience' => $body['experience'] ?? 0
            ]);
        }

        // Generate Token
        $token = Auth::generateToken([
            'id' => $userId,
            'email' => $body['email'],
            'role' => $role
        ]);

        $this->json([
            'status' => 'success',
            'message' => 'Account created successfully',
            'data' => [
                'token' => $token,
                'user' => [
                    'id' => (int)$userId,
                    'name' => $body['name'],
                    'email' => $body['email'],
                    'role' => $role,
                    'phone' => $body['phone'] ?? null,
                    'is_verified' => 0
                ]
            ]
        ], 201);
    }

    /**
     * POST /api/v1/auth/login
     */
    public function login() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->error('Method not allowed', 405);
        }

        $body = $this->getBody();

        if (empty($body['email']) || empty($body['password'])) {
            $this->error('Email and password required');
        }

        $userModel = new User();
        $user = $userModel->findByEmail($body['email']);

        if (!$user || !password_verify($body['password'], $user['password_hash'])) {
            $this->error('Invalid credentials', 401);
        }

        $token = Auth::generateToken([
            'id' => $user['id'],
            'email' => $user['email'],
            'role' => $user['role']
        ]);

        $this->json([
            'status' => 'success',
            'message' => 'Login successful',
            'data' => [
                'token' => $token,
                'user' => [
                    'id' => (int)$user['id'],
                    'name' => $user['name'],
                    'email' => $user['email'],
                    'role' => $user['role'],
                    'phone' => $user['phone'],
                    'is_verified' => (int)$user['is_verified']
                ]
            ]
        ]);
    }
}
