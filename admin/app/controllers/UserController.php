<?php
/**
 * UserController.php
 * Handles user and artisan management.
 */

namespace controllers;

class UserController {
    
    public function index() {
        // Mock data for users and artisans
        $data = [
            'title' => 'User Management',
            'users' => [
                ['id' => 1, 'name' => 'John Doe', 'email' => 'john@example.com', 'role' => 'Customer', 'status' => 'Active'],
                ['id' => 2, 'name' => 'Jane Smith', 'email' => 'jane@example.com', 'role' => 'Customer', 'status' => 'Active'],
            ],
            'artisans' => [
                ['id' => 101, 'name' => 'Chukwudi Adeyemi', 'skill' => 'Plumbing', 'status' => 'Pending', 'rating' => 0.0],
                ['id' => 102, 'name' => 'Grace Okoro', 'skill' => 'Catering', 'status' => 'Approved', 'rating' => 4.8],
                ['id' => 103, 'name' => 'Emmanuel Okafor', 'skill' => 'Electrical', 'status' => 'Approved', 'rating' => 4.9],
            ]
        ];
        
        $this->render('users/index', $data);
    }

    public function details() {
        $id = $_GET['id'] ?? 0;
        
        // Mock specific artisan detail
        $data = [
            'title' => 'Artisan Verification',
            'artisan' => [
                'id' => $id,
                'name' => 'Chukwudi Adeyemi',
                'email' => 'chukwudi@example.com',
                'phone' => '+234 801 234 5678',
                'skill' => 'Plumbing',
                'experience' => '8 years',
                'bio' => 'Professional plumber with extensive experience in residential and commercial piping.',
                'status' => 'Pending',
                'portfolio' => [
                    ['title' => 'Bathroom Renovation', 'img' => 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=400'],
                    ['title' => 'Kitchen Leak Fix', 'img' => 'https://images.unsplash.com/photo-1542013936693-884638332954?auto=format&fit=crop&w=400'],
                ]
            ]
        ];
        
        $this->render('users/details', $data);
    }
    
    protected function render($view, $data = []) {
        extract($data);
        $view_file = APP_PATH . '/views/' . $view . '.php';
        
        if (file_exists($view_file)) {
            require_once APP_PATH . '/views/layout.php';
        } else {
            echo "View '$view' not found";
        }
    }
}
