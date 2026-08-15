<?php
/**
 * WalletController.php
 * Handles Artisan & Customer in-app wallet balances, bank withdrawals, and payment histories.
 */

namespace controllers;

use core\Controller;
use core\Auth;
use models\Wallet;

class WalletController extends Controller {

    /**
     * GET /api/v1/wallet/balance
     */
    public function balance() {
        if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
            $this->error('Method not allowed', 405);
        }

        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) $this->error('Unauthorized', 401);

        try {
            $walletModel = new Wallet();
            $wallet = $walletModel->getWallet($tokenData['id']);
            $ledger = $walletModel->getLedger($tokenData['id']);
            $savedAccounts = $walletModel->getBankAccounts($tokenData['id']);

            $this->json([
                'status' => 'success',
                'data' => [
                    'balance' => $wallet['balance'],
                    'pending_balance' => $wallet['pending_balance'],
                    'total_balance' => $wallet['balance'] + $wallet['pending_balance'],
                    'saved_accounts' => $savedAccounts,
                    'transactions' => $ledger
                ]
            ]);
        } catch (\Throwable $e) {
            $this->error('Wallet error: ' . $e->getMessage(), 500);
        }
    }

    /**
     * POST /api/v1/wallet/withdraw
     */
    public function withdraw() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->error('Method not allowed', 405);
        }

        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) $this->error('Unauthorized', 401);

        $body = $this->getBody();
        $amount = floatval($body['amount'] ?? 0);
        $bankName = trim($body['bank_name'] ?? '');
        $bankCode = trim($body['bank_code'] ?? '');
        $accountNumber = trim($body['account_number'] ?? '');
        $accountName = trim($body['account_name'] ?? '');
        $saveAccount = !empty($body['save_account']);

        if ($amount < 500) {
            $this->error('Minimum withdrawal amount is ₦500.00');
        }

        if (empty($bankName) || empty($accountNumber) || empty($accountName)) {
            $this->error('Bank name, account number, and account name are required');
        }

        try {
            $walletModel = new Wallet();
            $result = $walletModel->requestWithdrawal($tokenData['id'], $amount, [
                'bank_name' => $bankName,
                'bank_code' => $bankCode,
                'account_number' => $accountNumber,
                'account_name' => $accountName,
                'save_account' => $saveAccount
            ]);

            if ($result['success']) {
                $this->json([
                    'status' => 'success',
                    'message' => $result['message'],
                    'data' => $result
                ]);
            } else {
                $this->error($result['message'], 400);
            }
        } catch (\Throwable $e) {
            $this->error('Withdrawal error: ' . $e->getMessage(), 500);
        }
    }

    /**
     * GET /api/v1/wallet/banks
     */
    public function banks() {
        $banks = Wallet::getNigerianBanks();
        $this->json([
            'status' => 'success',
            'data' => $banks
        ]);
    }

    /**
     * GET /api/v1/wallet/accounts
     */
    public function accounts() {
        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) $this->error('Unauthorized', 401);

        try {
            $walletModel = new Wallet();
            $accounts = $walletModel->getBankAccounts($tokenData['id']);
            $this->json([
                'status' => 'success',
                'data' => $accounts
            ]);
        } catch (\Throwable $e) {
            $this->error('Failed to load accounts: ' . $e->getMessage());
        }
    }

    /**
     * POST /api/v1/wallet/saveAccount
     */
    public function saveAccount() {
        if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
            $this->error('Method not allowed', 405);
        }

        $tokenData = Auth::verifyToken(Auth::getBearerToken());
        if (!$tokenData) $this->error('Unauthorized', 401);

        $body = $this->getBody();
        if (empty($body['bank_name']) || empty($body['account_number']) || empty($body['account_name'])) {
            $this->error('Bank name, account number, and account name are required');
        }

        try {
            $walletModel = new Wallet();
            $success = $walletModel->saveBankAccount($tokenData['id'], [
                'bank_name' => trim($body['bank_name']),
                'bank_code' => trim($body['bank_code'] ?? '000'),
                'account_number' => trim($body['account_number']),
                'account_name' => trim($body['account_name'])
            ]);

            if ($success) {
                $this->json(['status' => 'success', 'message' => 'Bank account saved']);
            } else {
                $this->error('Failed to save account');
            }
        } catch (\Throwable $e) {
            $this->error('Error: ' . $e->getMessage());
        }
    }
}
