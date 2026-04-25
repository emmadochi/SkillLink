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
            'min_rating' => $_GET['rating'] ?? null,
            'query' => $_GET['q'] ?? null,
            'skills' => $_GET['skills'] ?? null
        ];

        try {
            $artisanModel = new Artisan();
            $artisans = $artisanModel->search($filters);

            $this->json([
                'status' => 'success',
                'data' => $artisans
            ]);
        } catch (\Throwable $e) {
            $this->error('Failed to search artisans: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/v1/artisan/profile/{id}
     */
    public function profile($id = null) {
        if (!$id) {
            $id = $_GET['id'] ?? null;
        }
        
        if (!$id) $this->error('Artisan ID required');

        try {
            $user = $this->getCurrentUser(false); // Get user if available, don't force auth
            $currentUserId = $user ? $user['id'] : null;

            $artisanModel = new Artisan();
            $profile = $artisanModel->getProfile($id, $currentUserId);

            if (!$profile) {
                $this->error('Artisan not found', 404);
            }

            $this->json([
                'status' => 'success',
                'data' => $profile
            ]);
        } catch (\Throwable $e) {
            $this->error('Error loading profile: ' . $e->getMessage(), 500);
        }
    }

    public function update() {
        $this->requireAuth();
        $user = $this->getCurrentUser();

        if ($user['role'] !== 'artisan') {
            $this->error('Only artisans can update professional profiles', 403);
        }

        // Use $_POST instead of getPostData() because we are using multipart/form-data
        $data = $_POST;
        $data['user_id'] = $user['id'];

        try {
            $artisanModel = new Artisan();
            
            // 1. Handle Profile Avatar Upload
            $avatarPath = $this->uploadFile('avatar', 'uploads/avatars/');
            if ($avatarPath) {
                $db = (new \core\Database())->getConnection();
                $stmt = $db->prepare("UPDATE users SET avatar_url = :url WHERE id = :id");
                $stmt->execute([':url' => $avatarPath, ':id' => $user['id']]);
            }

            // 2. Update Profile Details
            if ($artisanModel->updateProfile($data)) {
                
                // 3. Handle Portfolio Uploads (Multi-file)
                if (isset($_FILES['portfolio']) && is_array($_FILES['portfolio']['name'])) {
                    $files = $_FILES['portfolio'];
                    for ($i = 0; $i < count($files['name']); $i++) {
                        if ($files['error'][$i] === UPLOAD_ERR_OK) {
                            // Create a temporary pseudo-file array for uploadFile helper
                            $_FILES['temp_p'] = [
                                'name' => $files['name'][$i],
                                'type' => $files['type'][$i],
                                'tmp_name' => $files['tmp_name'][$i],
                                'error' => $files['error'][$i],
                                'size' => $files['size'][$i]
                            ];
                            $pPath = $this->uploadFile('temp_p', 'uploads/portfolio/');
                            if ($pPath) {
                                $artisanModel->addPortfolioItem($user['id'], $pPath, "");
                            }
                        }
                    }
                }

                $this->json([
                    'status' => 'success',
                    'message' => 'Profile updated successfully'
                ]);
            } else {
                $this->error('Failed to update artisan profile');
            }
        } catch (\Throwable $e) {
            $this->error('Error updating profile: ' . $e->getMessage(), 500);
        }
    }

    public function verify() {
        $this->requireAuth();
        $user = $this->getCurrentUser();

        if ($user['role'] !== 'artisan') {
            $this->error('Access denied', 403);
        }

        $data = $this->getPostData();
        $data['artisan_id'] = $user['id'];

        try {
            $artisanModel = new Artisan();
            if ($artisanModel->submitVerification($data)) {
                $this->json([
                    'status' => 'success',
                    'message' => 'Verification documents submitted'
                ]);
            } else {
                $this->error('Failed to submit verification');
            }
        } catch (\Throwable $e) {
            $this->error('Error submitting verification: ' . $e->getMessage(), 500);
        }
    }

    public function portfolio() {
        $this->requireAuth();
        $user = $this->getCurrentUser();

        if ($user['role'] !== 'artisan') {
            $this->error('Access denied', 403);
        }

        $data = $this->getPostData();
        
        try {
            $artisanModel = new Artisan();
            if ($artisanModel->addPortfolioItem($user['id'], $data['image_url'], $data['description'] ?? "")) {
                $this->json([
                    'status' => 'success',
                    'message' => 'Portfolio item added'
                ]);
            } else {
                $this->error('Failed to add portfolio item');
            }
        } catch (\Throwable $e) {
            $this->error('Error adding portfolio: ' . $e->getMessage(), 500);
        }
    }

    public function reviews($id = null) {
        if (!$id) {
            $id = $_GET['id'] ?? null;
        }
        if (!$id) $this->error('Artisan ID required');

        try {
            $db = (new \core\Database())->getConnection();
            $query = "SELECT r.*, u.name as customer_name, u.avatar_url as customer_avatar 
                      FROM reviews r
                      JOIN users u ON u.id = r.customer_id
                      WHERE r.artisan_id = :id
                      ORDER BY r.created_at DESC";
            
            $stmt = $db->prepare($query);
            $stmt->bindParam(':id', $id);
            $stmt->execute();
            $reviews = $stmt->fetchAll();

            $this->json([
                'status' => 'success',
                'data' => $reviews
            ]);
        } catch (\Throwable $e) {
            $this->error('Error loading reviews: ' . $e->getMessage(), 500);
        }
    }

    public function toggleSave() {
        $this->requireAuth();
        $user = $this->getCurrentUser();
        $data = $this->getPostData();

        if (!isset($data['artisan_id'])) {
            $this->error('Artisan ID required');
        }

        $artisanId = $data['artisan_id'];

        try {
            $db = (new \core\Database())->getConnection();
            
            // Check if already saved
            $stmt = $db->prepare("SELECT 1 FROM saved_artisans WHERE user_id = :uid AND artisan_id = :aid");
            $stmt->bindParam(':uid', $user['id']);
            $stmt->bindParam(':aid', $artisanId);
            $stmt->execute();
            $isSaved = $stmt->fetch();

            if ($isSaved) {
                // Unsave
                $stmt = $db->prepare("DELETE FROM saved_artisans WHERE user_id = :uid AND artisan_id = :aid");
                $stmt->bindParam(':uid', $user['id']);
                $stmt->bindParam(':aid', $artisanId);
                $stmt->execute();
                $saved = false;
            } else {
                // Save
                $stmt = $db->prepare("INSERT INTO saved_artisans (user_id, artisan_id) VALUES (:uid, :aid)");
                $stmt->bindParam(':uid', $user['id']);
                $stmt->bindParam(':aid', $artisanId);
                $stmt->execute();
                $saved = true;
            }

            $this->json([
                'status' => 'success',
                'saved' => $saved,
                'message' => $saved ? 'Artisan saved' : 'Artisan removed from saved'
            ]);
        } catch (\Throwable $e) {
            $this->error('Error toggling save: ' . $e->getMessage(), 500);
        }
    }

    public function getSavedArtisans() {
        $this->requireAuth();
        $user = $this->getCurrentUser();

        try {
            $artisanModel = new Artisan();
            $db = (new \core\Database())->getConnection();
            
            $query = "SELECT u.id as user_id, u.name, u.avatar_url, a.bio, a.skill, a.average_rating, a.location_name
                      FROM saved_artisans s
                      JOIN artisans a ON a.user_id = s.artisan_id
                      JOIN users u ON u.id = a.user_id
                      WHERE s.user_id = :uid
                      ORDER BY s.created_at DESC";
            
            $stmt = $db->prepare($query);
            $stmt->bindParam(':uid', $user['id']);
            $stmt->execute();
            $artisans = $stmt->fetchAll();

            $this->json([
                'status' => 'success',
                'data' => $artisans
            ]);
        } catch (\Throwable $e) {
            $this->error('Error loading saved artisans: ' . $e->getMessage(), 500);
        }
    }
}
