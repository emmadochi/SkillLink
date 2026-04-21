<?php
namespace controllers;

use core\Controller;
use core\Auth;
use core\Database;
use PDO;

class AdminController extends Controller {

    private $conn;

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    /**
     * GET /api/v1/admin/stats
     * Aggregated statistics for the dashboard.
     */
    public function stats() {
        // Simple security check (Should check for 'admin' role in JWT)
        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData || $tokenData['role'] !== 'admin') {
            $this->error('Unauthorized admin access', 403);
        }

        try {
            $stats = [];
            
            // Total Users
            $stmt = $this->conn->query("SELECT count(*) FROM users WHERE role = 'customer'");
            $stats['total_users'] = $stmt->fetchColumn();

            // Total artisans
            $stmt = $this->conn->query("SELECT count(*) FROM artisans");
            $stats['active_artisans'] = $stmt->fetchColumn();

            // Total revenue
            $stmt = $this->conn->query("SELECT SUM(platform_fee) FROM bookings WHERE status = 'completed'");
            $stats['revenue'] = $stmt->fetchColumn() ?? 0;

            // Pending Approvals
            $stmt = $this->conn->query("SELECT count(*) FROM artisans WHERE verification_status = 'pending'");
            $stats['pending_approvals'] = $stmt->fetchColumn();

            $this->json([
                'status' => 'success',
                'data' => $stats
            ]);

        } catch (\Exception $e) {
            $this->error('Failed to gather stats: ' . $e->getMessage(), 500);
        }
    }

    /**
     * POST /api/v1/admin/verifyArtisan
     */
    public function verifyArtisan() {
        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData || $tokenData['role'] !== 'admin') {
            $this->error('Unauthorized admin access', 403);
        }

        $body = $this->getBody();
        if (empty($body['user_id']) || empty($body['status'])) {
            $this->error('User ID and status required');
        }

        try {
            $query = "UPDATE artisans SET verification_status = :status WHERE user_id = :id";
            $stmt = $this->conn->prepare($query);
            $stmt->bindParam(':status', $body['status']);
            $stmt->bindParam(':id', $body['user_id']);
            
            if ($stmt->execute()) {
                $this->json(['status' => 'success', 'message' => 'Verification status updated.']);
            } else {
                $this->error('Failed to update status.');
            }
        } catch (\Exception $e) {
            $this->error('Database error: ' . $e->getMessage());
        }
    }
}
