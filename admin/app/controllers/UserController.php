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

        $artisan['portfolio'] = $userModel->getArtisanPortfolio((int)$id);

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
