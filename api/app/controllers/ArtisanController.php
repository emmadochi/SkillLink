<?php
namespace controllers;

use core\Controller;
use models\Artisan;

class ArtisanController extends Controller {

    /**
     * GET /api/v1/artisan
     * GET /api/v1/artisan?category=1
     */
    public function index() {
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
            $this->error('Method not allowed', 405);
        }

        $filters = [
            'category_id' => $_GET['category'] ?? null,
            'min_rating' => $_GET['rating'] ?? null
        ];

        try {
            $artisanModel = new Artisan();
            $artisans = $artisanModel->search($filters);

            $this->json([
                'status' => 'success',
                'data' => $artisans
            ]);
        } catch (\Exception $e) {
            $this->error('Failed to search artisans: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/v1/artisan/profile/{id}
     */
    public function profile($id = null) {
        if (!$id) $this->error('Artisan ID required');

        try {
            $artisanModel = new Artisan();
            $profile = $artisanModel->getProfile($id);

            if (!$profile) {
                $this->error('Artisan not found', 404);
            }

            $this->json([
                'status' => 'success',
                'data' => $profile
            ]);
        } catch (\Exception $e) {
            $this->error('Error loading profile: ' . $e->getMessage(), 500);
        }
    }
}
