<?php
/**
 * DisputeModel.php
 * Comprehensive DB queries for dispute mediation, case inspection, chat evidence, and arbitration settlements.
 */

namespace models;

class DisputeModel {

    private \mysqli $db;

    public function __construct(\mysqli $db) {
        $this->db = $db;
        try {
            $this->db->query("ALTER TABLE `bookings` ADD COLUMN IF NOT EXISTS `cancellation_reason` TEXT DEFAULT NULL");
            $this->db->query("CREATE TABLE IF NOT EXISTS `notifications` (
                `id` INT AUTO_INCREMENT PRIMARY KEY,
                `user_id` INT NOT NULL,
                `type` VARCHAR(50) NOT NULL,
                `title` VARCHAR(255) NOT NULL,
                `message` TEXT NOT NULL,
                `related_id` INT DEFAULT NULL,
                `is_read` TINYINT(1) DEFAULT 0,
                `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4");
        } catch (\Throwable $e) {}
    }

    public function getAll(int $limit = 20, int $offset = 0, string $status = ''): array {
        $check = $this->db->query("SHOW TABLES LIKE 'disputes'");
        if (!$check || $check->num_rows === 0) return [];

        $where = '';
        $types = 'ii';
        $params = [$limit, $offset];

        if ($status) {
            $where = "WHERE d.status = ?";
            $types = 'sii';
            $params = [$status, $limit, $offset];
        }

        $sql = "
            SELECT d.id, d.booking_id, d.status, d.reason, d.resolution, d.created_at, d.updated_at,
                   b.booking_number, b.price, b.platform_fee, b.artisan_payout, b.status as booking_status,
                   cu.id as customer_id, cu.name AS customer_name, cu.email as customer_email, cu.phone as customer_phone,
                   au.id as artisan_id, au.name AS artisan_name, au.email as artisan_email, au.phone as artisan_phone,
                   rb.name AS raised_by_name, rb.role AS raised_by_role,
                   c.name AS category
            FROM disputes d
            JOIN bookings b ON b.id = d.booking_id
            JOIN users    cu ON cu.id = b.customer_id
            JOIN users    au ON au.id = b.artisan_id
            JOIN users    rb ON rb.id = d.raised_by
            JOIN categories c ON c.id = b.category_id
            $where
            ORDER BY 
                CASE 
                    WHEN d.status = 'open' THEN 1
                    WHEN d.status = 'under_review' THEN 2
                    WHEN d.status = 'resolved' THEN 3
                    ELSE 4
                END,
                d.created_at DESC
            LIMIT ? OFFSET ?
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->bind_param($types, ...$params);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }

    public function count(string $status = ''): int {
        $check = $this->db->query("SHOW TABLES LIKE 'disputes'");
        if (!$check || $check->num_rows === 0) return 0;

        if ($status) {
            $stmt = $this->db->prepare("SELECT COUNT(*) AS t FROM disputes WHERE status = ?");
            $stmt->bind_param('s', $status);
            $stmt->execute();
            return (int)($stmt->get_result()->fetch_assoc()['t'] ?? 0);
        }

        $result = $this->db->query("SELECT COUNT(*) AS t FROM disputes");
        return (int)($result->fetch_assoc()['t'] ?? 0);
    }

    public function countOpen(): int {
        return $this->count('open') + $this->count('under_review');
    }

    /**
     * Get full details for an individual dispute case including booking, users, and transactions
     */
    public function getDisputeDetails(int $id): ?array {
        $check = $this->db->query("SHOW TABLES LIKE 'disputes'");
        if (!$check || $check->num_rows === 0) return null;

        $sql = "
            SELECT d.id, d.booking_id, d.status, d.reason, d.resolution, d.created_at, d.updated_at,
                   b.booking_number, b.price, b.platform_fee, b.artisan_payout, b.status as booking_status,
                   b.service_description, b.scheduled_at, b.created_at as booking_created_at,
                   cu.id as customer_id, cu.name as customer_name, cu.email as customer_email, cu.phone as customer_phone, cu.avatar_url as customer_avatar,
                   au.id as artisan_id, au.name as artisan_name, au.email as artisan_email, au.phone as artisan_phone, au.avatar_url as artisan_avatar,
                   rb.id as raised_by_id, rb.name as raised_by_name, rb.role as raised_by_role,
                   c.name as category_name
            FROM disputes d
            JOIN bookings b ON b.id = d.booking_id
            JOIN users    cu ON cu.id = b.customer_id
            JOIN users    au ON au.id = b.artisan_id
            JOIN users    rb ON rb.id = d.raised_by
            JOIN categories c ON c.id = b.category_id
            WHERE d.id = ?
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->bind_param('i', $id);
        $stmt->execute();
        $dispute = $stmt->get_result()->fetch_assoc();

        if (!$dispute) return null;

        // Fetch transaction history on this booking
        $tStmt = $this->db->prepare("
            SELECT id, user_id, amount, type, payment_method, payment_reference, status, created_at
            FROM transactions
            WHERE booking_id = ?
            ORDER BY created_at DESC
        ");
        $tStmt->bind_param('i', $dispute['booking_id']);
        $tStmt->execute();
        $dispute['transactions'] = $tStmt->get_result()->fetch_all(MYSQLI_ASSOC);

        // Fetch direct chat evidence between the two parties
        $dispute['chat_evidence'] = $this->getChatEvidence((int)$dispute['customer_id'], (int)$dispute['artisan_id']);

        return $dispute;
    }

    /**
     * Fetch direct messaging history between customer and artisan for evidence inspection
     */
    public function getChatEvidence(int $customerId, int $artisanId, int $limit = 50): array {
        $check = $this->db->query("SHOW TABLES LIKE 'messages'");
        if (!$check || $check->num_rows === 0) return [];

        $sql = "
            SELECT m.id, m.sender_id, m.receiver_id, m.message, m.created_at,
                   u.name as sender_name, u.role as sender_role
            FROM messages m
            JOIN users u ON u.id = m.sender_id
            WHERE (m.sender_id = ? AND m.receiver_id = ?)
               OR (m.sender_id = ? AND m.receiver_id = ?)
            ORDER BY m.created_at ASC
            LIMIT ?
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->bind_param('iiiii', $customerId, $artisanId, $artisanId, $customerId, $limit);
        $stmt->execute();
        return $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    }

    /**
     * Multi-option dispute arbitration engine
     * @param int $id Dispute ID
     * @param string $ruling 'full_refund' | 'full_payout' | 'split_settlement' | 'dismiss'
     * @param float $refundAmount Amount refunded to customer
     * @param float $payoutAmount Amount released to artisan
     * @param string $resolution Summary text for public settlement notice
     * @param string $adminNotes Internal audit note
     */
    public function arbitrate(int $id, string $ruling, float $refundAmount, float $payoutAmount, string $resolution, string $adminNotes = ''): bool {
        // Retrieve dispute & booking context
        $dStmt = $this->db->prepare("
            SELECT d.id, d.booking_id, d.status,
                   b.booking_number, b.price, b.customer_id, b.artisan_id
            FROM disputes d
            JOIN bookings b ON b.id = d.booking_id
            WHERE d.id = ?
        ");
        $dStmt->bind_param('i', $id);
        $dStmt->execute();
        $dispute = $dStmt->get_result()->fetch_assoc();

        if (!$dispute) return false;

        $bookingId = (int)$dispute['booking_id'];
        $customerId = (int)$dispute['customer_id'];
        $artisanId = (int)$dispute['artisan_id'];
        $bookingNumber = $dispute['booking_number'];
        $totalPrice = (float)$dispute['price'];

        $this->db->begin_transaction();

        try {
            $newDisputeStatus = ($ruling === 'dismiss') ? 'closed' : 'resolved';
            $fullResolutionText = $resolution;
            if ($adminNotes) {
                $fullResolutionText .= "\n[Internal Note]: " . $adminNotes;
            }

            // 1. Update dispute table
            $updDispute = $this->db->prepare("
                UPDATE disputes 
                SET status = ?, resolution = ?, updated_at = NOW() 
                WHERE id = ?
            ");
            $updDispute->bind_param('ssi', $newDisputeStatus, $fullResolutionText, $id);
            $updDispute->execute();

            // 2. Handle ledger transactions & booking state based on ruling
            $tStmt = $this->db->prepare("
                INSERT INTO transactions (booking_id, user_id, amount, type, payment_method, payment_reference, status) 
                VALUES (?, ?, ?, ?, 'wallet', ?, 'successful')
            ");

            if ($ruling === 'full_refund') {
                $refCode = 'REFUND-' . strtoupper(substr(uniqid(), 0, 8));
                $type = 'refund';
                $refundVal = $refundAmount > 0 ? $refundAmount : $totalPrice;
                $tStmt->bind_param('iidss', $bookingId, $customerId, $refundVal, $type, $refCode);
                $tStmt->execute();

                // Update booking to cancelled / refunded
                $updBooking = $this->db->prepare("
                    UPDATE bookings 
                    SET status = 'cancelled', cancellation_reason = ?, updated_at = NOW() 
                    WHERE id = ?
                ");
                $reason = "Cancelled by Dispute Arbitration: 100% Refund Issued (" . $resolution . ")";
                $updBooking->bind_param('si', $reason, $bookingId);
                $updBooking->execute();

            } elseif ($ruling === 'full_payout') {
                $refCode = 'PAYOUT-' . strtoupper(substr(uniqid(), 0, 8));
                $type = 'payout';
                $payoutVal = $payoutAmount > 0 ? $payoutAmount : ($totalPrice * 0.90);
                $tStmt->bind_param('iidss', $bookingId, $artisanId, $payoutVal, $type, $refCode);
                $tStmt->execute();

                // Update booking to completed
                $updBooking = $this->db->prepare("
                    UPDATE bookings 
                    SET status = 'completed', updated_at = NOW() 
                    WHERE id = ?
                ");
                $updBooking->bind_param('i', $bookingId);
                $updBooking->execute();

            } elseif ($ruling === 'split_settlement') {
                // Record customer refund
                if ($refundAmount > 0) {
                    $refCodeCust = 'REFUND-SPLIT-' . strtoupper(substr(uniqid(), 0, 6));
                    $typeRef = 'refund';
                    $tStmt->bind_param('iidss', $bookingId, $customerId, $refundAmount, $typeRef, $refCodeCust);
                    $tStmt->execute();
                }

                // Record artisan payout
                if ($payoutAmount > 0) {
                    $refCodeArt = 'PAYOUT-SPLIT-' . strtoupper(substr(uniqid(), 0, 6));
                    $typePay = 'payout';
                    $tStmt->bind_param('iidss', $bookingId, $artisanId, $payoutAmount, $typePay, $refCodeArt);
                    $tStmt->execute();
                }

                // Update booking status
                $updBooking = $this->db->prepare("
                    UPDATE bookings 
                    SET status = 'completed', updated_at = NOW() 
                    WHERE id = ?
                ");
                $updBooking->bind_param('i', $bookingId);
                $updBooking->execute();

            } elseif ($ruling === 'dismiss') {
                // Dispute rejected, contract holds
            }

            // 3. Dispatch Notifications
            $nStmt = $this->db->prepare("
                INSERT INTO notifications (user_id, type, title, message, related_id) 
                VALUES (?, 'dispute', ?, ?, ?)
            ");

            $title = "Dispute Mediation Ruling: #" . $bookingNumber;
            $msgCust = "Your dispute on booking #" . $bookingNumber . " has been arbitrated: " . $resolution;
            $msgArt = "Dispute ruling issued on booking #" . $bookingNumber . ": " . $resolution;

            if ($ruling === 'full_refund') {
                $msgCust .= " (Full refund of ₦" . number_format($refundAmount > 0 ? $refundAmount : $totalPrice, 2) . " processed)";
                $msgArt .= " (Escrow funds refunded to customer)";
            } elseif ($ruling === 'full_payout') {
                $msgArt .= " (Escrow payout of ₦" . number_format($payoutAmount > 0 ? $payoutAmount : ($totalPrice * 0.90), 2) . " released to your wallet)";
            } elseif ($ruling === 'split_settlement') {
                $msgCust .= " (Settlement refund: ₦" . number_format($refundAmount, 2) . ")";
                $msgArt .= " (Settlement payout: ₦" . number_format($payoutAmount, 2) . ")";
            }

            $nStmt->bind_param('issi', $customerId, $title, $msgCust, $bookingId);
            $nStmt->execute();

            $nStmt->bind_param('issi', $artisanId, $title, $msgArt, $bookingId);
            $nStmt->execute();

            $this->db->commit();
            return true;
        } catch (\Throwable $e) {
            $this->db->rollback();
            return false;
        }
    }

    public function updateStatus(int $id, string $status): bool {
        $allowed = ['open', 'under_review', 'resolved', 'closed'];
        if (!in_array($status, $allowed)) return false;

        $stmt = $this->db->prepare("UPDATE disputes SET status = ?, updated_at = NOW() WHERE id = ?");
        $stmt->bind_param('si', $status, $id);
        return $stmt->execute();
    }

    public function resolve(int $id, string $resolution): bool {
        return $this->arbitrate($id, 'full_refund', 0.0, 0.0, $resolution);
    }

    public function close(int $id): bool {
        return $this->updateStatus($id, 'closed');
    }
}
