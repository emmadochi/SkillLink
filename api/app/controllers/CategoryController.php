<?php
namespace controllers;

use core\Controller;
use models\Category;

class CategoryController extends Controller {

    /**
     * GET /api/v1/category
     */
    public function index() {
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
            $this->error('Method not allowed', 405);
        }

        try {
            $categoryModel = new Category();
            $categories = $categoryModel->getAll();

            $this->json([
                'status' => 'success',
                'data' => $categories
            ]);
        } catch (\Exception $e) {
            $this->error('Failed to fetch categories: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/v1/category/services?id=1
     */
    public function services() {
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
            $this->error('Method not allowed', 405);
        }

        $id = $_GET['id'] ?? null;
        if (!$id) {
            $this->error('Category ID required');
        }

        try {
            $categoryModel = new Category();
            $services = $categoryModel->getServicesByCategoryId($id);

            $this->json([
                'status' => 'success',
                'data' => $services
            ]);
        } catch (\Exception $e) {
            $this->error('Failed to fetch services: ' . $e->getMessage(), 500);
        }
    }
}
