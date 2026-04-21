<?php
/**
 * UserController.php
 * Handles user and artisan management.
 */

namespace controllers;

use models\UserModel;

class UserController extends BaseController {
    
    public function index() {
        $this->requireAuth();
        $userModel = new UserModel($this->db());

        $data = [
            'title' => 'User Management',
            'users' => $userModel->getCustomers(),
            'artisans' => $userModel->getArtisans()
        ];
        
        $this->render('users/index', $data);
    }

    public function details() {
        $this->requireAuth();
        $id = $_GET['id'] ?? 0;
        
        $userModel = new UserModel($this->db());
        $artisan = $userModel->getArtisanById((int)$id);

        if (!$artisan) {
            $this->redirect('/SkillLink/admin/users');
        }

        // For now, mock portfolio as we don't have a table for it in the schema yet
        // but the view expects it.
        $artisan['portfolio'] = [
            ['title' => 'Project A', 'img' => 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=400'],
            ['title' => 'Project B', 'img' => 'https://images.unsplash.com/photo-1542013936693-884638332954?auto=format&fit=crop&w=400'],
        ];

        $data = [
            'title' => 'Artisan Verification',
            'artisan' => $artisan
        ];
        
        $this->render('users/details', $data);
    }

    public function approve() {
        $this->requireAuth();
        $this->requireMethod('POST');
        
        $id = $_POST['id'] ?? 0;
        $userModel = new UserModel($this->db());
        
        if ($userModel->updateArtisanStatus((int)$id, 'approved')) {
            // Success
        }
        
        $this->redirect('/SkillLink/admin/user/details?id=' . $id);
    }

    public function reject() {
        $this->requireAuth();
        $this->requireMethod('POST');
        
        $id = $_POST['id'] ?? 0;
        $userModel = new UserModel($this->db());
        
        if ($userModel->updateArtisanStatus((int)$id, 'rejected')) {
            // Success
        }
        
        $this->redirect('/SkillLink/admin/user/details?id=' . $id);
    }
}
