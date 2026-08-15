<?php
/**
 * OperationsController.php
 * Handles real-time operations dashboard, live dispatch telemetry, and map feeds.
 */

namespace controllers;

use models\OperationsModel;
use models\BookingModel;

class OperationsController extends BaseController {

    public function index(): void {
        $this->requireAuth();
        $opsModel = new OperationsModel($this->db());

        $data = [
            'title' => 'Live Operations & City Dispatch',
            'kpis' => $opsModel->getLiveKPIs(),
            'active_jobs' => $opsModel->getActiveJobs(),
            'on_duty_artisans' => $opsModel->getOnDutyArtisans(30)
        ];

        $this->render('operations/index', $data);
    }

    /**
     * Real-time polling JSON feed for the live map
     */
    public function feed(): void {
        $this->requireAuth();
        $opsModel = new OperationsModel($this->db());

        $data = [
            'status' => 'success',
            'timestamp' => time(),
            'kpis' => $opsModel->getLiveKPIs(),
            'jobs' => $opsModel->getActiveJobs(),
            'artisans' => $opsModel->getOnDutyArtisans(60)
        ];

        $this->json($data);
    }

    /**
     * Quick dispatch status change from the live map inspector
     */
    public function updateStatus(): void {
        $this->requireAuth();
        $this->requireMethod('POST');

        $bookingId = (int)($_POST['booking_id'] ?? 0);
        $newStatus = trim($_POST['status'] ?? '');
        $notes = trim($_POST['notes'] ?? 'Status updated by Operations Desk');

        if ($bookingId <= 0 || !$newStatus) {
            $this->json(['status' => 'error', 'message' => 'Invalid parameters'], 400);
        }

        $opsModel = new OperationsModel($this->db());
        $success = $opsModel->updateJobStatus($bookingId, $newStatus, $notes);

        if ($success) {
            $this->json(['status' => 'success', 'message' => 'Job status updated']);
        } else {
            $this->json(['status' => 'error', 'message' => 'Failed to update job status'], 500);
        }
    }
}
