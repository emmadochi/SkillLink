<?php
/**
 * Wallet.php
 * Handles Artisan & Customer in-app wallets, escrow balances, and Nigerian bank account withdrawals.
 */

namespace models;

use core\Database;
use PDO;

class Wallet {
    private $conn;

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
        if ($this->conn) {
            $this->ensureTablesExist();
        }
    }

    private function ensureTablesExist() {
        try {
            // 1. Wallets Table
            $this->conn->exec("CREATE TABLE IF NOT EXISTS wallets (
                user_id INT PRIMARY KEY,
                balance DECIMAL(12, 2) DEFAULT 0.00,
                pending_balance DECIMAL(12, 2) DEFAULT 0.00,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

            // 2. Saved Bank Accounts Table
            $this->conn->exec("CREATE TABLE IF NOT EXISTS artisan_bank_accounts (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                bank_name VARCHAR(100) NOT NULL,
                bank_code VARCHAR(20) NOT NULL,
                account_number VARCHAR(20) NOT NULL,
                account_name VARCHAR(100) NOT NULL,
                is_default TINYINT(1) DEFAULT 1,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                INDEX (user_id)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");

            // 3. Withdrawals Table
            $this->conn->exec("CREATE TABLE IF NOT EXISTS withdrawals (
                id INT AUTO_INCREMENT PRIMARY KEY,
                user_id INT NOT NULL,
                amount DECIMAL(12, 2) NOT NULL,
                bank_name VARCHAR(100) NOT NULL,
                bank_code VARCHAR(20) NOT NULL,
                account_number VARCHAR(20) NOT NULL,
                account_name VARCHAR(100) NOT NULL,
                reference VARCHAR(100) UNIQUE NOT NULL,
                status ENUM('pending', 'processing', 'successful', 'failed') DEFAULT 'pending',
                notes TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                INDEX (user_id),
                INDEX (reference)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;");
        } catch (\PDOException $e) {
            error_log("Wallet table creation notice: " . $e->getMessage());
        }
    }

    /**
     * Get or create wallet for user
     */
    public function getWallet($userId) {
        if (!$this->conn) return null;

        $stmt = $this->conn->prepare("SELECT * FROM wallets WHERE user_id = :uid");
        $stmt->bindParam(':uid', $userId, PDO::PARAM_INT);
        $stmt->execute();
        $wallet = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$wallet) {
            // Auto-create wallet
            $insert = $this->conn->prepare("INSERT IGNORE INTO wallets (user_id, balance, pending_balance) VALUES (:uid, 0.00, 0.00)");
            $insert->bindParam(':uid', $userId, PDO::PARAM_INT);
            $insert->execute();

            return [
                'user_id' => (int)$userId,
                'balance' => 0.00,
                'pending_balance' => 0.00
            ];
        }

        return [
            'user_id' => (int)$wallet['user_id'],
            'balance' => (float)$wallet['balance'],
            'pending_balance' => (float)$wallet['pending_balance']
        ];
    }

    /**
     * Lock funds in escrow when booking is confirmed/paid
     */
    public function creditPendingEscrow($artisanId, $artisanPayout) {
        if (!$this->conn || $artisanPayout <= 0) return false;
        $this->getWallet($artisanId); // Ensure exists

        $stmt = $this->conn->prepare("UPDATE wallets SET pending_balance = pending_balance + :amt WHERE user_id = :uid");
        $stmt->bindParam(':amt', $artisanPayout);
        $stmt->bindParam(':uid', $artisanId, PDO::PARAM_INT);
        return $stmt->execute();
    }

    /**
     * Automatically release escrow funds to available balance upon verified completion
     */
    public function releaseEscrowToBalance($artisanId, $artisanPayout, $bookingId) {
        if (!$this->conn || $artisanPayout <= 0) return false;
        $this->getWallet($artisanId); // Ensure exists

        try {
            $this->conn->beginTransaction();

            // 1. Move from pending_balance to available balance
            $stmt = $this->conn->prepare("
                UPDATE wallets 
                SET pending_balance = GREATEST(0, pending_balance - :amt),
                    balance = balance + :amt
                WHERE user_id = :uid
            ");
            $stmt->bindParam(':amt', $artisanPayout);
            $stmt->bindParam(':uid', $artisanId, PDO::PARAM_INT);
            $stmt->execute();

            // 2. Record transaction ledger entry
            $ref = 'ESCROW-REL-' . strtoupper(substr(uniqid(), 0, 8));
            $tStmt = $this->conn->prepare("
                INSERT INTO transactions (booking_id, user_id, amount, type, payment_method, payment_reference, status)
                VALUES (:bid, :uid, :amt, 'payout', 'wallet', :ref, 'successful')
            ");
            $tStmt->bindParam(':bid', $bookingId, PDO::PARAM_INT);
            $tStmt->bindParam(':uid', $artisanId, PDO::PARAM_INT);
            $tStmt->bindParam(':amt', $artisanPayout);
            $tStmt->bindParam(':ref', $ref);
            $tStmt->execute();

            // 3. Send Notification to artisan
            $notif = new Notification();
            $notif->create([
                'user_id' => $artisanId,
                'type' => 'payment',
                'title' => 'Escrow Payout Released! 💰',
                'message' => '₦' . number_format($artisanPayout, 2) . ' from booking #' . $bookingId . ' has been credited to your available wallet balance.',
                'related_id' => $bookingId
            ]);

            $this->conn->commit();
            return true;
        } catch (\Throwable $e) {
            $this->conn->rollBack();
            error_log("Failed to release escrow: " . $e->getMessage());
            return false;
        }
    }

    /**
     * Artisan requests bank payout/withdrawal to Nigerian Bank Account
     */
    public function requestWithdrawal($userId, $amount, array $bankData) {
        if (!$this->conn || $amount <= 0) return ['success' => false, 'message' => 'Invalid amount'];

        $wallet = $this->getWallet($userId);
        if ($wallet['balance'] < $amount) {
            return ['success' => false, 'message' => 'Insufficient wallet balance. Available: ₦' . number_format($wallet['balance'], 2)];
        }

        try {
            $this->conn->beginTransaction();

            // 1. Deduct from available balance
            $stmt = $this->conn->prepare("UPDATE wallets SET balance = balance - :amt WHERE user_id = :uid AND balance >= :amt");
            $stmt->bindParam(':amt', $amount);
            $stmt->bindParam(':uid', $userId, PDO::PARAM_INT);
            $stmt->execute();

            if ($stmt->rowCount() === 0) {
                $this->conn->rollBack();
                return ['success' => false, 'message' => 'Failed to deduct balance'];
            }

            // 2. Create withdrawal record
            $ref = 'WD-' . time() . rand(100, 999);
            $wStmt = $this->conn->prepare("
                INSERT INTO withdrawals (user_id, amount, bank_name, bank_code, account_number, account_name, reference, status)
                VALUES (:uid, :amt, :bname, :bcode, :accno, :accname, :ref, 'successful')
            ");
            $wStmt->bindParam(':uid', $userId, PDO::PARAM_INT);
            $wStmt->bindParam(':amt', $amount);
            $wStmt->bindParam(':bname', $bankData['bank_name']);
            $wStmt->bindParam(':bcode', $bankData['bank_code']);
            $wStmt->bindParam(':accno', $bankData['account_number']);
            $wStmt->bindParam(':accname', $bankData['account_name']);
            $wStmt->bindParam(':ref', $ref);
            $wStmt->execute();

            // 3. Record in transactions ledger
            $tStmt = $this->conn->prepare("
                INSERT INTO transactions (user_id, amount, type, payment_method, payment_reference, status)
                VALUES (:uid, :amt, 'payout', 'bank_transfer', :ref, 'successful')
            ");
            $tStmt->bindParam(':uid', $userId, PDO::PARAM_INT);
            $tStmt->bindParam(':amt', $amount);
            $tStmt->bindParam(':ref', $ref);
            $tStmt->execute();

            // 4. Save bank account if requested or if first time
            if (!empty($bankData['save_account'])) {
                $this->saveBankAccount($userId, $bankData);
            }

            // 5. Send Notification
            $notif = new Notification();
            $notif->create([
                'user_id' => $userId,
                'type' => 'payment',
                'title' => 'Bank Withdrawal Processed',
                'message' => 'Your withdrawal of ₦' . number_format($amount, 2) . ' to ' . $bankData['bank_name'] . ' (' . $bankData['account_number'] . ') has been processed.',
                'related_id' => null
            ]);

            $this->conn->commit();
            return [
                'success' => true,
                'reference' => $ref,
                'amount' => $amount,
                'message' => 'Withdrawal of ₦' . number_format($amount, 2) . ' processed successfully to ' . $bankData['bank_name']
            ];
        } catch (\Throwable $e) {
            $this->conn->rollBack();
            return ['success' => false, 'message' => 'Withdrawal error: ' . $e->getMessage()];
        }
    }

    /**
     * Get transaction & withdrawal ledger for wallet screen
     */
    public function getLedger($userId, $limit = 30) {
        if (!$this->conn) return [];

        $stmt = $this->conn->prepare("
            SELECT t.id, t.amount, t.type, t.payment_method, t.payment_reference, t.status, t.created_at,
                   b.booking_number, c.name as category_name
            FROM transactions t
            LEFT JOIN bookings b ON b.id = t.booking_id
            LEFT JOIN categories c ON c.id = b.category_id
            WHERE t.user_id = :uid
            ORDER BY t.created_at DESC
            LIMIT :lim
        ");
        $stmt->bindParam(':uid', $userId, PDO::PARAM_INT);
        $stmt->bindValue(':lim', (int)$limit, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    /**
     * Get saved bank accounts
     */
    public function getBankAccounts($userId) {
        if (!$this->conn) return [];
        $stmt = $this->conn->prepare("SELECT * FROM artisan_bank_accounts WHERE user_id = :uid ORDER BY is_default DESC, created_at DESC");
        $stmt->bindParam(':uid', $userId, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getSavedAccounts($userId) {
        return $this->getBankAccounts($userId);
    }

    /**
     * Save a bank account
     */
    public function saveBankAccount($userId, array $data) {
        if (!$this->conn) return false;
        
        // Check if account already exists
        $check = $this->conn->prepare("SELECT id FROM artisan_bank_accounts WHERE user_id = :uid AND account_number = :accno AND bank_code = :bcode");
        $check->bindParam(':uid', $userId, PDO::PARAM_INT);
        $check->bindParam(':accno', $data['account_number']);
        $check->bindParam(':bcode', $data['bank_code']);
        $check->execute();

        if ($check->rowCount() > 0) return true;

        $stmt = $this->conn->prepare("
            INSERT INTO artisan_bank_accounts (user_id, bank_name, bank_code, account_number, account_name, is_default)
            VALUES (:uid, :bname, :bcode, :accno, :accname, 1)
        ");
        $stmt->bindParam(':uid', $userId, PDO::PARAM_INT);
        $stmt->bindParam(':bname', $data['bank_name']);
        $stmt->bindParam(':bcode', $data['bank_code']);
        $stmt->bindParam(':accno', $data['account_number']);
        $stmt->bindParam(':accname', $data['account_name']);
        return $stmt->execute();
    }

    /**
     * Nigerian Commercial & Microfinance Banks (Paystack/Flutterwave standard)
     */
    public static function getNigerianBanks(): array {
        return [
            ['name' => 'Access Bank', 'code' => '044'],
            ['name' => 'Guaranty Trust Bank (GTBank)', 'code' => '058'],
            ['name' => 'Zenith Bank', 'code' => '057'],
            ['name' => 'United Bank for Africa (UBA)', 'code' => '033'],
            ['name' => 'First Bank of Nigeria', 'code' => '011'],
            ['name' => 'Kuda Microfinance Bank', 'code' => '50211'],
            ['name' => 'OPay (PayCom)', 'code' => '999992'],
            ['name' => 'PalmPay', 'code' => '999991'],
            ['name' => 'Moniepoint MFB', 'code' => '50515'],
            ['name' => 'Wema Bank / ALAT', 'code' => '035'],
            ['name' => 'Fidelity Bank', 'code' => '070'],
            ['name' => 'Stanbic IBTC Bank', 'code' => '221'],
            ['name' => 'Sterling Bank', 'code' => '232'],
            ['name' => 'First City Monument Bank (FCMB)', 'code' => '214'],
            ['name' => 'Union Bank of Nigeria', 'code' => '032'],
            ['name' => 'Ecobank Nigeria', 'code' => '050'],
            ['name' => 'Keystone Bank', 'code' => '082'],
            ['name' => 'Polaris Bank', 'code' => '076'],
            ['name' => 'Jaiz Bank', 'code' => '301'],
            ['name' => 'Taj Bank', 'code' => '302']
        ];
    }
}
