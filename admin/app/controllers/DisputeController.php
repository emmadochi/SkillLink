<?php
/**
 * DisputeController.php
 * Handles platform disputes and conflict resolution.
 */

namespace controllers;

use models\DisputeModel;

class DisputeController extends BaseController {
    
    public function index() {
        $this->requireAuth();
        $disputeModel = new DisputeModel($this->db());

        $page = (int)($_GET['page'] ?? 1);
        $limit = 20;
        $offset = ($page - 1) * $limit;

        $data = [
            'title' => 'Dispute Management',
            'disputes' => $disputeModel->getAll($limit, $offset),
            'total' => $disputeModel->count(),
            'open_count' => $disputeModel->countOpen(),
            'current_page' => $page,
            'limit' => $limit
        ];
        
        $this->render('disputes/index', $data);
    }

    public function resolve() {
        $this->requireAuth();
        $this->requireMethod('POST');
        
        $id = (int)($_POST['id'] ?? 0);
        $resolution = trim($_POST['resolution'] ?? '');
        
        if ($id && $resolution) {
            $disputeModel = new DisputeModel($this->db());
            $disputeModel->resolve($id, $resolution);
        }
        
        $this->redirect('/SkillLink/admin/dispute');
    }

    public function close() {
        $this->requireAuth();
        $this->requireMethod('POST');
        
        $id = (int)($_POST['id'] ?? 0);
        if ($id) {
            $disputeModel = new DisputeModel($this->db());
            $disputeModel->close($id);
        }
        
        $this->redirect('/SkillLink/admin/dispute');
    }
}
