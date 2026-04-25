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
            $this->json(['status' => 'success', 'message' => 'Category added successfully']);
        }
        
        $this->json(['status' => 'error', 'message' => 'Category name is required'], 400);
    }

    public function updateCategory() {
        $this->requireAuth();
        $this->requireMethod('POST');
        
        $id = (int)($_POST['id'] ?? 0);
        $name = trim($_POST['name'] ?? '');
        $order = (int)($_POST['sort_order'] ?? 0);
        
        if ($id && $name) {
            $categoryModel = new CategoryModel($this->db());
            $categoryModel->update($id, $name, $order);
            $this->json(['status' => 'success', 'message' => 'Category updated successfully']);
        }
        
        $this->json(['status' => 'error', 'message' => 'ID and Name are required'], 400);
    }

    public function deleteCategory() {
        $this->requireAuth();
        $this->requireMethod('POST');
        
        $id = (int)($_POST['id'] ?? 0);
        if ($id) {
            $categoryModel = new CategoryModel($this->db());
            $categoryModel->delete($id);
            $this->json(['status' => 'success', 'message' => 'Category deleted successfully']);
        }
        
        $this->json(['status' => 'error', 'message' => 'ID is required'], 400);
    }
}
