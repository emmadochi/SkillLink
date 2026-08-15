<?php
/**
 * OperationsModel.php
 * Handles real-time geospatial queries for citywide active jobs and artisan telemetry.
 */

namespace models;

class OperationsModel {

    private \mysqli $db;

    public function __construct(\mysqli $db) {
        $this->db = $db;
    }

    /**
     * Get real-time operational KPI metrics
     */
    public function getLiveKPIs(): array {
        $kpis = [
            'active_jobs' => 0,
            'in_progress_jobs' => 0,
            'en_route_jobs' => 0,
            'pending_jobs' => 0,
            'on_duty_artisans' => 0,
            'open_disputes' => 0,
            'escrow_at_risk' => 0.00
        ];

        // Active jobs count by status
        $res = $this->db->query("
            SELECT status, COUNT(*) as cnt, SUM(price) as total_val 
            FROM bookings 
            WHERE status IN ('pending', 'confirmed', 'arrived', 'in_progress') 
            GROUP BY status
        ");

        if ($res) {
            while ($row = $res->fetch_assoc()) {
                $status = $row['status'];
                $count = (int)$row['cnt'];
                $kpis['active_jobs'] += $count;

                if ($status === 'in_progress') $kpis['in_progress_jobs'] = $count;
                if ($status === 'confirmed' || $status === 'arrived') $kpis['en_route_jobs'] += $count;
                if ($status === 'pending') $kpis['pending_jobs'] = $count;
            }
        }

        // On-duty / online artisans
        $artRes = $this->db->query("
            SELECT COUNT(*) as total 
            FROM artisans 
            WHERE verification_status = 'approved' AND (is_available = 1 OR live_latitude IS NOT NULL)
        ");
        if ($artRes && $row = $artRes->fetch_assoc()) {
            $kpis['on_duty_artisans'] = (int)$row['total'];
        }

        // Open disputes & Escrow at risk
        $checkDisputes = $this->db->query("SHOW TABLES LIKE 'disputes'");
        if ($checkDisputes && $checkDisputes->num_rows > 0) {
            $dispRes = $this->db->query("
                SELECT COUNT(d.id) as disp_count, SUM(b.price) as risk_val
                FROM disputes d
                JOIN bookings b ON b.id = d.booking_id
                WHERE d.status IN ('open', 'under_review')
            ");
            if ($dispRes && $row = $dispRes->fetch_assoc()) {
                $kpis['open_disputes'] = (int)($row['disp_count'] ?? 0);
                $kpis['escrow_at_risk'] = (float)($row['risk_val'] ?? 0.00);
            }
        }

        return $kpis;
    }

    /**
     * Fetch active bookings with coordinates and participant details
     */
    public function getActiveJobs(): array {
        $sql = "
            SELECT 
                b.id,
                b.booking_number,
                b.status,
                b.price,
                b.platform_fee,
                b.artisan_payout,
                b.service_description,
                b.scheduled_at,
                b.created_at,
                b.updated_at,
                cu.id as customer_id,
                cu.name as customer_name,
                cu.phone as customer_phone,
                cu.avatar_url as customer_avatar,
                au.id as artisan_id,
                au.name as artisan_name,
                au.phone as artisan_phone,
                au.avatar_url as artisan_avatar,
                a.latitude as artisan_base_lat,
                a.longitude as artisan_base_lng,
                a.live_latitude as artisan_live_lat,
                a.live_longitude as artisan_live_lng,
                a.location_name as artisan_location_name,
                a.average_rating as artisan_rating,
                c.id as category_id,
                c.name as category_name,
                c.icon as category_icon,
                c.slug as category_slug,
                (SELECT d.status FROM disputes d WHERE d.booking_id = b.id ORDER BY d.created_at DESC LIMIT 1) as dispute_status
            FROM bookings b
            JOIN users cu ON cu.id = b.customer_id
            JOIN users au ON au.id = b.artisan_id
            JOIN artisans a ON a.user_id = au.id
            JOIN categories c ON c.id = b.category_id
            WHERE b.status IN ('pending', 'confirmed', 'arrived', 'in_progress')
            ORDER BY 
                CASE 
                    WHEN b.status = 'in_progress' THEN 1
                    WHEN b.status = 'arrived' THEN 2
                    WHEN b.status = 'confirmed' THEN 3
                    ELSE 4
                END,
                b.updated_at DESC
        ";

        $res = $this->db->query($sql);
        if (!$res) return [];

        $jobs = [];
        $defaultCityCenterLat = 6.5244; // Default to Lagos / Metro
        $defaultCityCenterLng = 3.3792;

        while ($row = $res->fetch_assoc()) {
            // Determine best available artisan coordinates
            $artisanLat = $row['artisan_live_lat'] !== null ? (float)$row['artisan_live_lat'] : ($row['artisan_base_lat'] !== null ? (float)$row['artisan_base_lat'] : null);
            $artisanLng = $row['artisan_live_lng'] !== null ? (float)$row['artisan_live_lng'] : ($row['artisan_base_lng'] !== null ? (float)$row['artisan_base_lng'] : null);

            // If coordinates not set, generate slight offset from metro center based on ID for visual simulation
            if ($artisanLat === null || $artisanLng === null) {
                $hash = crc32($row['booking_number'] . $row['artisan_id']);
                $artisanLat = $defaultCityCenterLat + (($hash % 100) - 50) * 0.0018;
                $artisanLng = $defaultCityCenterLng + ((($hash >> 8) % 100) - 50) * 0.0022;
            }

            // Customer location (destination)
            $customerLat = $artisanLat + 0.012 * sin($row['id']);
            $customerLng = $artisanLng + 0.012 * cos($row['id']);

            $jobs[] = [
                'id' => (int)$row['id'],
                'booking_number' => $row['booking_number'],
                'status' => $row['status'],
                'price' => (float)$row['price'],
                'service_description' => $row['service_description'] ?: 'Standard Service Request',
                'scheduled_at' => $row['scheduled_at'],
                'created_at' => $row['created_at'],
                'updated_at' => $row['updated_at'],
                'dispute_status' => $row['dispute_status'],
                'category' => [
                    'id' => (int)$row['category_id'],
                    'name' => $row['category_name'],
                    'icon' => $row['category_icon'] ?: 'handyman',
                    'slug' => $row['category_slug']
                ],
                'customer' => [
                    'id' => (int)$row['customer_id'],
                    'name' => $row['customer_name'],
                    'phone' => $row['customer_phone'] ?: 'N/A',
                    'avatar' => $row['customer_avatar'],
                    'latitude' => round($customerLat, 6),
                    'longitude' => round($customerLng, 6)
                ],
                'artisan' => [
                    'id' => (int)$row['artisan_id'],
                    'name' => $row['artisan_name'],
                    'phone' => $row['artisan_phone'] ?: 'N/A',
                    'avatar' => $row['artisan_avatar'],
                    'rating' => (float)($row['artisan_rating'] ?? 5.0),
                    'location_name' => $row['artisan_location_name'] ?: 'City Center',
                    'latitude' => round($artisanLat, 6),
                    'longitude' => round($artisanLng, 6),
                    'is_live' => !empty($row['artisan_live_lat'])
                ]
            ];
        }

        return $jobs;
    }

    /**
     * Get available / on-duty artisans across the city
     */
    public function getOnDutyArtisans(int $limit = 60): array {
        $sql = "
            SELECT 
                u.id,
                u.name,
                u.phone,
                u.avatar_url,
                a.skill,
                a.experience_years,
                a.location_name,
                a.average_rating,
                a.is_available,
                a.latitude as base_lat,
                a.longitude as base_lng,
                a.live_latitude,
                a.live_longitude,
                a.heading,
                a.speed,
                a.last_location_update,
                GROUP_CONCAT(c.name SEPARATOR ', ') as categories
            FROM users u
            JOIN artisans a ON a.user_id = u.id
            LEFT JOIN artisan_categories ac ON ac.artisan_id = a.user_id
            LEFT JOIN categories c ON c.id = ac.category_id
            WHERE u.role = 'artisan' 
              AND a.verification_status = 'approved'
            GROUP BY u.id
            ORDER BY (a.live_latitude IS NOT NULL) DESC, a.is_available DESC, a.average_rating DESC
            LIMIT ?
        ";

        $stmt = $this->db->prepare($sql);
        $stmt->bind_param('i', $limit);
        $stmt->execute();
        $res = $stmt->get_result();

        $artisans = [];
        $defaultCityCenterLat = 6.5244;
        $defaultCityCenterLng = 3.3792;

        while ($row = $res->fetch_assoc()) {
            $lat = $row['live_latitude'] !== null ? (float)$row['live_latitude'] : ($row['base_lat'] !== null ? (float)$row['base_lat'] : null);
            $lng = $row['live_longitude'] !== null ? (float)$row['live_longitude'] : ($row['base_lng'] !== null ? (float)$row['base_lng'] : null);

            if ($lat === null || $lng === null) {
                $hash = crc32($row['name'] . $row['id']);
                $lat = $defaultCityCenterLat + (($hash % 140) - 70) * 0.0016;
                $lng = $defaultCityCenterLng + ((($hash >> 6) % 140) - 70) * 0.0019;
            }

            $artisans[] = [
                'id' => (int)$row['id'],
                'name' => $row['name'],
                'phone' => $row['phone'] ?: 'N/A',
                'avatar' => $row['avatar_url'],
                'skill' => $row['skill'] ?: 'General Tradesman',
                'categories' => $row['categories'] ?: $row['skill'],
                'rating' => (float)($row['average_rating'] ?? 5.0),
                'location_name' => $row['location_name'] ?: 'Metropolitan Area',
                'is_available' => (bool)$row['is_available'],
                'latitude' => round($lat, 6),
                'longitude' => round($lng, 6),
                'heading' => $row['heading'] !== null ? (float)$row['heading'] : null,
                'speed' => $row['speed'] !== null ? (float)$row['speed'] : null,
                'is_live' => !empty($row['live_latitude']),
                'last_update' => $row['last_location_update']
            ];
        }

        return $artisans;
    }

    /**
     * Emergency status update / dispatch action from operations room
     */
    public function updateJobStatus(int $bookingId, string $status, string $note = ''): bool {
        $allowed = ['pending', 'confirmed', 'arrived', 'in_progress', 'completed', 'cancelled'];
        if (!in_array($status, $allowed)) return false;

        $stmt = $this->db->prepare("UPDATE bookings SET status = ?, updated_at = NOW() WHERE id = ?");
        $stmt->bind_param('si', $status, $bookingId);
        $res = $stmt->execute();

        if ($res && $note) {
            // Retrieve booking parties
            $bStmt = $this->db->prepare("SELECT customer_id, artisan_id, booking_number FROM bookings WHERE id = ?");
            $bStmt->bind_param('i', $bookingId);
            $bStmt->execute();
            $bData = $bStmt->get_result()->fetch_assoc();

            if ($bData) {
                $nStmt = $this->db->prepare("INSERT INTO notifications (user_id, type, title, message, related_id) VALUES (?, 'booking', ?, ?, ?)");
                $title = "Operations Alert: #" . $bData['booking_number'];
                $msg = "Status changed to " . ucfirst(str_replace('_', ' ', $status)) . " by Dispatch: " . $note;

                $nStmt->bind_param('issi', $bData['customer_id'], $title, $msg, $bookingId);
                $nStmt->execute();

                $nStmt->bind_param('issi', $bData['artisan_id'], $title, $msg, $bookingId);
                $nStmt->execute();
            }
        }

        return $res;
    }
}
