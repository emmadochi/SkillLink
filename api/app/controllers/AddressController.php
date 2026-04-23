<?php
namespace controllers;

use core\Controller;
use models\Address;

class AddressController extends Controller {

    public function index() {
        $this->requireAuth();
        $user = $this->getCurrentUser();

        try {
            $addressModel = new Address();
            $addresses = $addressModel->getByUser($user['id']);

            $this->json([
                'status' => 'success',
                'data' => $addresses
            ]);
        } catch (\Exception $e) {
            $this->error('Failed to load addresses: ' . $e->getMessage(), 500);
        }
    }

    public function create() {
        $this->requireAuth();
        $user = $this->getCurrentUser();
        $data = $this->getPostData();

        if (empty($data['label']) || empty($data['address'])) {
            $this->error('Label and address are required');
        }

        try {
            $addressModel = new Address();
            $data['user_id'] = $user['id'];
            $id = $addressModel->create($data);

            if ($id) {
                $this->json([
                    'status' => 'success',
                    'message' => 'Address added successfully',
                    'data' => ['id' => $id]
                ]);
            } else {
                $this->error('Failed to add address');
            }
        } catch (\Exception $e) {
            $this->error('Error adding address: ' . $e->getMessage(), 500);
        }
    }

    public function delete($id) {
        $this->requireAuth();
        $user = $this->getCurrentUser();

        try {
            $addressModel = new Address();
            if ($addressModel->delete($id, $user['id'])) {
                $this->json(['status' => 'success', 'message' => 'Address deleted']);
            } else {
                $this->error('Failed to delete address or unauthorized');
            }
        } catch (\Exception $e) {
            $this->error('Error deleting address: ' . $e->getMessage(), 500);
        }
    }
}
