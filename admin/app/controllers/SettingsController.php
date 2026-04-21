<?php
/**
 * SettingsController.php
 * Handles platform configuration and service categories.
 */

namespace controllers;

use models\CategoryModel;

class SettingsController extends BaseController {
    
    public function index() {
        $this->requireAuth();
        $categoryModel = new CategoryModel($this->db());

        $data = [
            'title' => 'Platform Settings',
            'categories' => $categoryModel->getAll(),
            'settings' => $categoryModel->getSettings()
        ];
        
        $this->render('settings/index', $data);
    }

    public function addCategory() {
        $this->requireAuth();
        $this->requireMethod('POST');
        
        $name = trim($_POST['name'] ?? '');
        if ($name) {
            $categoryModel = new CategoryModel($this->db());
            $categoryModel->create($name);
        }
        
        $this->redirect('/SkillLink/admin/settings');
    }

    public function updateCategory() {
        $this->requireAuth();
        $this->requireMethod('POST');
        
        $id = (int)($_POST['id'] ?? 0);
        $name = trim($_POST['name'] ?? '');
        
        if ($id && $name) {
            $categoryModel = new CategoryModel($this->db());
            $categoryModel->update($id, $name);
        }
        
        $this->redirect('/SkillLink/admin/settings');
    }

    public function deleteCategory() {
        $this->requireAuth();
        $this->requireMethod('POST');
        
        $id = (int)($_POST['id'] ?? 0);
        if ($id) {
            $categoryModel = new CategoryModel($this->db());
            $categoryModel->delete($id);
        }
        
        $this->redirect('/SkillLink/admin/settings');
    }
}
