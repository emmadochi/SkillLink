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
}
