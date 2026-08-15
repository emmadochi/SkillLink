<?php
/**
 * DisputeController.php
 * Comprehensive dispute management, arbitration actions, and refund mediation.
 */

namespace controllers;

use models\DisputeModel;

class DisputeController extends BaseController {
    
    public function index(): void {
        $this->requireAuth();
        $disputeModel = new DisputeModel($this->db());

        $status = $_GET['status'] ?? '';
        $page = (int)($_GET['page'] ?? 1);
        $limit = 20;
        $offset = ($page - 1) * $limit;

        $data = [
            'title' => 'Dispute Arbitration & Mediation',
            'disputes' => $disputeModel->getAll($limit, $offset, $status),
            'total' => $disputeModel->count($status),
            'open_count' => $disputeModel->countOpen(),
            'current_page' => $page,
            'limit' => $limit,
            'status_filter' => $status
        ];
        
        $this->render('disputes/index', $data);
    }

    /**
     * Fetch complete dispute case file including transaction history and chat evidence
     */
    public function details(): void {
        $this->requireAuth();
        $id = (int)($_GET['id'] ?? 0);

        if ($id <= 0) {
            $this->json(['status' => 'error', 'message' => 'Dispute ID is required'], 400);
        }

        $disputeModel = new DisputeModel($this->db());
        $case = $disputeModel->getDisputeDetails($id);

        if (!$case) {
            $this->json(['status' => 'error', 'message' => 'Dispute case not found'], 404);
        }

        $this->json(['status' => 'success', 'data' => $case]);
    }

    /**
     * Submit formal arbitration ruling & refund/payout settlement
     */
    public function arbitrate(): void {
        $this->requireAuth();
        $this->requireMethod('POST');

        $id = (int)($_POST['id'] ?? 0);
        $ruling = trim($_POST['ruling'] ?? 'full_refund');
        $refundAmount = floatval($_POST['refund_amount'] ?? 0);
        $payoutAmount = floatval($_POST['payout_amount'] ?? 0);
        $resolution = trim($_POST['resolution'] ?? '');
        $adminNotes = trim($_POST['admin_notes'] ?? '');

        if ($id <= 0 || !$resolution) {
            if ($this->isAjax()) {
                $this->json(['status' => 'error', 'message' => 'Dispute ID and Resolution description are required'], 400);
            } else {
                $this->redirect('dispute');
            }
        }

        $disputeModel = new DisputeModel($this->db());
        $success = $disputeModel->arbitrate($id, $ruling, $refundAmount, $payoutAmount, $resolution, $adminNotes);

        if ($this->isAjax()) {
            if ($success) {
                $this->json(['status' => 'success', 'message' => 'Arbitration ruling executed and funds settled successfully.']);
            } else {
                $this->json(['status' => 'error', 'message' => 'Arbitration processing failed.'], 500);
            }
        } else {
            $this->redirect('dispute');
        }
    }

    /**
     * Change dispute status (e.g. mark Under Review)
     */
    public function updateStatus(): void {
        $this->requireAuth();
        $this->requireMethod('POST');

        $id = (int)($_POST['id'] ?? 0);
        $status = trim($_POST['status'] ?? '');

        if ($id > 0 && $status) {
            $disputeModel = new DisputeModel($this->db());
            $disputeModel->updateStatus($id, $status);
        }

        if ($this->isAjax()) {
            $this->json(['status' => 'success', 'message' => 'Dispute status updated']);
        } else {
            $this->redirect('dispute');
        }
    }

    public function resolve(): void {
        $this->requireAuth();
        $this->requireMethod('POST');
        
        $id = (int)($_POST['id'] ?? 0);
        $resolution = trim($_POST['resolution'] ?? '');
        
        if ($id && $resolution) {
            $disputeModel = new DisputeModel($this->db());
            $disputeModel->resolve($id, $resolution);
        }
        
        $this->redirect('dispute');
    }

    public function close(): void {
        $this->requireAuth();
        $this->requireMethod('POST');
        
        $id = (int)($_POST['id'] ?? 0);
        if ($id) {
            $disputeModel = new DisputeModel($this->db());
            $disputeModel->close($id);
        }
        
        $this->redirect('dispute');
    }

    private function isAjax(): bool {
        return (!empty($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) === 'xmlhttprequest') 
            || (isset($_SERVER['HTTP_ACCEPT']) && str_contains($_SERVER['HTTP_ACCEPT'], 'application/json'));
    }
}
