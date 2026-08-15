<?php
namespace models;

use core\Database;
use PDO;

class Artisan {
    private $conn;
    private $table = "artisans";

    private static $tablesEnsured = false;

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
        if (!$this->conn) {
            header('Content-Type: application/json');
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Database connection failed']);
            exit;
        }
        
        // Self-healing: Ensure saved_artisans table exists (run only once per request)
        if (!self::$tablesEnsured) {
            $this->ensureTablesExist();
            self::$tablesEnsured = true;
        }
    }

    private function ensureTablesExist() {
        $sql = "CREATE TABLE IF NOT EXISTS saved_artisans (
            user_id INT, 
            artisan_id INT, 
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
            PRIMARY KEY (user_id, artisan_id), 
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE, 
            FOREIGN KEY (artisan_id) REFERENCES artisans(user_id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";
        try {
            $this->conn->exec($sql);
        } catch (\PDOException $e) {
            // Ignore if already exists or other non-critical errors
        }

        // Ensure live tracking columns exist on artisans table
        $columnsToAdd = [
            "ALTER TABLE artisans ADD COLUMN IF NOT EXISTS live_latitude DECIMAL(10, 8) DEFAULT NULL",
            "ALTER TABLE artisans ADD COLUMN IF NOT EXISTS live_longitude DECIMAL(11, 8) DEFAULT NULL",
            "ALTER TABLE artisans ADD COLUMN IF NOT EXISTS last_location_update TIMESTAMP NULL DEFAULT NULL",
            "ALTER TABLE artisans ADD COLUMN IF NOT EXISTS heading DECIMAL(5, 2) DEFAULT NULL",
            "ALTER TABLE artisans ADD COLUMN IF NOT EXISTS speed DECIMAL(5, 2) DEFAULT NULL"
        ];

        foreach ($columnsToAdd as $alterSql) {
            try {
                $this->conn->exec($alterSql);
            } catch (\PDOException $e) {
                // Ignore if already exists
            }
        }
    }

    /**
     * Search artisans by category, location, rating, and calculate Haversine distance.
     */
    public function search($filters = []) {
        $userLat = isset($filters['lat']) && is_numeric($filters['lat']) ? floatval($filters['lat']) : null;
        $userLng = isset($filters['lng']) && is_numeric($filters['lng']) ? floatval($filters['lng']) : null;
        $hasCoords = ($userLat !== null && $userLng !== null && ($userLat != 0.0 || $userLng != 0.0));

        $distanceSelect = "";
        if ($hasCoords) {
            $distanceSelect = ", (6371 * acos(LEAST(1.0, GREATEST(-1.0, 
                cos(radians(:user_lat)) * cos(radians(IFNULL(IFNULL(a.live_latitude, a.latitude), 0))) * 
                cos(radians(IFNULL(IFNULL(a.live_longitude, a.longitude), 0)) - radians(:user_lng)) + 
                sin(radians(:user_lat)) * sin(radians(IFNULL(IFNULL(a.live_latitude, a.latitude), 0)))
            )))) AS distance_km";
        } else {
            $distanceSelect = ", NULL AS distance_km";
        }

        $query = "SELECT u.id as user_id, u.name, u.avatar_url, a.bio, a.skill, a.category_id, a.average_rating, 
                         a.experience_years, a.location_name, a.hourly_rate, a.latitude, a.longitude,
                         a.live_latitude, a.live_longitude, a.last_location_update $distanceSelect
                  FROM " . $this->table . " a
                  JOIN users u ON u.id = a.user_id
                  WHERE (a.verification_status = 'approved' OR a.verification_status = 'verified') 
                  AND a.is_available = 1";
        
        if (!empty($filters['category_id'])) {
            $query .= " AND a.category_id = :cat_id";
        }

        if (!empty($filters['min_rating'])) {
            $query .= " AND a.average_rating >= :min_rating";
        }

        if (!empty($filters['query'])) {
            $query .= " AND (u.name LIKE :q OR a.bio LIKE :q OR a.skill LIKE :q OR a.location_name LIKE :q)";
        }

        if (!empty($filters['skills'])) {
            $skills = is_array($filters['skills']) ? $filters['skills'] : explode(',', $filters['skills']);
            $skillConditions = [];
            foreach ($skills as $index => $skill) {
                $paramName = ":skill_" . $index;
                $skillConditions[] = "(a.bio LIKE $paramName OR a.skill LIKE $paramName)";
            }
            if (!empty($skillConditions)) {
                $query .= " AND (" . implode(' OR ', $skillConditions) . ")";
            }
        }

        // Sorting
        $sortBy = strtolower($filters['sort_by'] ?? $filters['sort'] ?? '');
        if ($sortBy === 'nearest' && $hasCoords) {
            $query .= " ORDER BY distance_km ASC, a.average_rating DESC";
        } elseif ($sortBy === 'price_low' || $sortBy === 'price: low') {
            $query .= " ORDER BY a.hourly_rate ASC";
        } elseif ($sortBy === 'price_high' || $sortBy === 'price: high') {
            $query .= " ORDER BY a.hourly_rate DESC";
        } else {
            $query .= " ORDER BY a.average_rating DESC";
        }
        
        $stmt = $this->conn->prepare($query);

        if ($hasCoords) {
            $stmt->bindParam(':user_lat', $userLat);
            $stmt->bindParam(':user_lng', $userLng);
        }

        if (!empty($filters['category_id'])) {
            $stmt->bindParam(':cat_id', $filters['category_id']);
        }
        if (!empty($filters['min_rating'])) {
            $stmt->bindParam(':min_rating', $filters['min_rating']);
        }
        if (!empty($filters['query'])) {
            $searchTerm = '%' . $filters['query'] . '%';
            $stmt->bindParam(':q', $searchTerm);
        }

        if (!empty($filters['skills'])) {
            $skills = is_array($filters['skills']) ? $filters['skills'] : explode(',', $filters['skills']);
            foreach ($skills as $index => $skill) {
                $paramName = ":skill_" . $index;
                $val = '%' . trim($skill) . '%';
                $stmt->bindValue($paramName, $val);
            }
        }

        $stmt->execute();
        $artisans = $stmt->fetchAll();

        return array_map(function($a) {
            $a['distance_km'] = isset($a['distance_km']) && $a['distance_km'] !== null ? round(floatval($a['distance_km']), 1) : null;
            $a['user'] = [
                'id' => (int)($a['user_id'] ?? 0),
                'name' => $a['name'] ?? 'Artisan',
                'avatar_url' => $a['avatar_url'] ?? ''
            ];
            $a['average_rating'] = (float)($a['average_rating'] ?? 0.0);
            $a['experience_years'] = (int)($a['experience_years'] ?? 0);
            $a['hourly_rate'] = (float)($a['hourly_rate'] ?? 0.0);
            return $a;
        }, $artisans ?: []);
    }

    /**
     * Get artisan full profile details.
     */
    public function getProfile($id, $currentUserId = null) {
        $query = "SELECT u.id as user_id, u.name, u.email, u.phone, u.avatar_url, u.role,
                         a.bio, a.skill, a.category_id, a.experience_years, a.average_rating,
                         a.location_name, a.business_address, a.guarantor_name, a.guarantor_phone,
                         a.identity_verified, a.verification_status, a.is_available, a.hourly_rate,
                         (SELECT status FROM artisan_verifications WHERE artisan_id = u.id ORDER BY created_at DESC LIMIT 1) as identity_status
                  FROM users u
                  LEFT JOIN " . $this->table . " a ON a.user_id = u.id
                  WHERE u.id = :id LIMIT 1";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':id', $id);
        $stmt->execute();
        $row = $stmt->fetch();

        if (!$row) return null;

        $profile = $row;
        $profile['user'] = [
            'id' => (int)$row['user_id'],
            'name' => $row['name'],
            'email' => $row['email'],
            'phone' => $row['phone'],
            'avatar_url' => $row['avatar_url']
        ];
        
        // Get portfolio, reviews & sub-services
        $profile['portfolio'] = $this->getPortfolio($id);
        $profile['reviews'] = $this->getReviews($id);
        $profile['sub_services'] = $this->getSubServices($id);

        
        // Check if saved
        $profile['is_saved'] = false;
        if ($currentUserId) {
            $sQuery = "SELECT 1 FROM saved_artisans WHERE user_id = :cuid AND artisan_id = :aid";
            $sStmt = $this->conn->prepare($sQuery);
            $sStmt->bindParam(':cuid', $currentUserId);
            $sStmt->bindParam(':aid', $id);
            $sStmt->execute();
            $profile['is_saved'] = $sStmt->fetch() ? true : false;
        }

        // Cast types
        $profile['average_rating'] = (float)($profile['average_rating'] ?? 0.0);
        $profile['experience_years'] = (int)($profile['experience_years'] ?? 0);
        $profile['hourly_rate'] = (float)($profile['hourly_rate'] ?? 0.0);
        $profile['identity_verified'] = (bool)($profile['identity_verified'] ?? false);

        return $profile;
    }

    public function getReviews($artisan_id) {
        $query = "SELECT r.*, u.name as customer_name, u.avatar_url as customer_avatar 
                  FROM reviews r
                  JOIN users u ON u.id = r.customer_id
                  WHERE r.artisan_id = :aid 
                  ORDER BY r.created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':aid', $artisan_id);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    public function getPortfolio($artisan_id) {
        $query = "SELECT * FROM artisan_portfolios WHERE artisan_id = :aid ORDER BY created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':aid', $artisan_id);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    public function updateProfile($data) {
        // Check if artisan record exists
        $query = "SELECT user_id FROM " . $this->table . " WHERE user_id = :uid";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':uid', $data['user_id']);
        $stmt->execute();
        $exists = $stmt->fetch();

        if ($exists) {
            $query = "UPDATE " . $this->table . " 
                      SET bio = :bio, skill = :skill, experience_years = :exp, 
                          location_name = :loc, latitude = :lat, longitude = :lng,
                          business_address = :b_addr, guarantor_name = :g_name, guarantor_phone = :g_phone,
                          is_available = :avail, hourly_rate = :rate
                      WHERE user_id = :uid";
        } else {
            $query = "INSERT INTO " . $this->table . " 
                      (user_id, bio, skill, experience_years, location_name, latitude, longitude, 
                       business_address, guarantor_name, guarantor_phone, verification_status, is_available, hourly_rate) 
                      VALUES (:uid, :bio, :skill, :exp, :loc, :lat, :lng, :b_addr, :g_name, :g_phone, 'pending', :avail, :rate)";
        }

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':uid', $data['user_id']);
        $stmt->bindParam(':bio', $data['bio']);
        $stmt->bindParam(':skill', $data['skill']);
        $stmt->bindParam(':exp', $data['experience_years']);
        $stmt->bindParam(':loc', $data['location_name']);
        $stmt->bindParam(':lat', $data['latitude']);
        $stmt->bindParam(':lng', $data['longitude']);
        $stmt->bindParam(':b_addr', $data['business_address']);
        $stmt->bindParam(':g_name', $data['guarantor_name']);
        $stmt->bindParam(':g_phone', $data['guarantor_phone']);
        $avail = isset($data['is_available']) ? (int)$data['is_available'] : 1;
        $stmt->bindParam(':avail', $avail);
        $rate = isset($data['hourly_rate']) ? (float)$data['hourly_rate'] : 0.0;
        $stmt->bindParam(':rate', $rate);

        return $stmt->execute();
    }

    public function submitVerification($data) {
        $query = "INSERT INTO artisan_verifications 
                  (artisan_id, id_type, id_number, id_image_front, id_image_back, passport_photo, status) 
                  VALUES (:aid, :type, :num, :front, :back, :passport, 'pending')";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':aid', $data['artisan_id']);
        $stmt->bindParam(':type', $data['id_type']);
        $stmt->bindParam(':num', $data['id_number']);
        $stmt->bindParam(':front', $data['id_image_front']);
        $stmt->bindParam(':back', $data['id_image_back']);
        $stmt->bindParam(':passport', $data['passport_photo']);

        return $stmt->execute();
    }

    public function addPortfolioItem($artisan_id, $image_url, $description = "") {
        $query = "INSERT INTO artisan_portfolios (artisan_id, image_url, description) 
                  VALUES (:aid, :url, :desc)";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':aid', $artisan_id);
        $stmt->bindParam(':url', $image_url);
        $stmt->bindParam(':desc', $description);

        return $stmt->execute();
    }

    public function getSubServices($artisan_id) {
        $query = "SELECT cs.id, cs.service_name 
                  FROM artisan_sub_services ass
                  JOIN category_services cs ON cs.id = ass.sub_service_id
                  WHERE ass.artisan_id = :aid";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':aid', $artisan_id);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function updateSubServices($artisan_id, $sub_service_ids) {
        // 1. Delete existing
        $del = $this->conn->prepare("DELETE FROM artisan_sub_services WHERE artisan_id = :aid");
        $del->execute([':aid' => $artisan_id]);

        if (empty($sub_service_ids)) return true;

        // 2. Insert new
        if (is_string($sub_service_ids)) {
            $sub_service_ids = explode(',', $sub_service_ids);
        }

        $query = "INSERT INTO artisan_sub_services (artisan_id, sub_service_id) VALUES (:aid, :sid)";
        $stmt = $this->conn->prepare($query);
        
        foreach ($sub_service_ids as $sid) {
            if (empty($sid)) continue;
            $stmt->execute([':aid' => $artisan_id, ':sid' => (int)$sid]);
        }
        
        return true;
    }

    /**
     * Update live GPS coordinates of an artisan during active service / transit.
     */
    public function updateLiveLocation($artisanId, $lat, $lng, $heading = null, $speed = null) {
        $query = "UPDATE " . $this->table . " 
                  SET live_latitude = :lat, 
                      live_longitude = :lng, 
                      heading = :heading, 
                      speed = :speed, 
                      last_location_update = CURRENT_TIMESTAMP 
                  WHERE user_id = :aid";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':lat', $lat);
        $stmt->bindParam(':lng', $lng);
        $stmt->bindParam(':heading', $heading);
        $stmt->bindParam(':speed', $speed);
        $stmt->bindParam(':aid', $artisanId, PDO::PARAM_INT);

        return $stmt->execute();
    }

    /**
     * Fetch live location of an artisan.
     */
    public function getLiveLocation($artisanId) {
        $query = "SELECT a.user_id, u.name, u.avatar_url, u.phone,
                         a.latitude as base_latitude, a.longitude as base_longitude,
                         a.live_latitude, a.live_longitude, a.heading, a.speed,
                         a.last_location_update, a.location_name, a.is_available
                  FROM " . $this->table . " a
                  JOIN users u ON u.id = a.user_id
                  WHERE a.user_id = :aid";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':aid', $artisanId, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetch();
    }

    /**
     * AI-Powered Artisan Recommendation & Proximity Matchmaker
     * Multi-factor scoring: Distance Decay + Bayesian Quality + Reliability & Availability
     */
    public function getRecommendations($filters = []) {
        $userLat = isset($filters['lat']) && is_numeric($filters['lat']) ? floatval($filters['lat']) : null;
        $userLng = isset($filters['lng']) && is_numeric($filters['lng']) ? floatval($filters['lng']) : null;
        $categoryId = !empty($filters['category_id']) ? intval($filters['category_id']) : null;
        $limit = isset($filters['limit']) ? intval($filters['limit']) : 10;

        $hasCoords = ($userLat !== null && $userLng !== null && ($userLat != 0.0 || $userLng != 0.0));

        $distanceSelect = "";
        if ($hasCoords) {
            $distanceSelect = ", (6371 * acos(LEAST(1.0, GREATEST(-1.0, 
                cos(radians(:user_lat)) * cos(radians(IFNULL(IFNULL(a.live_latitude, a.latitude), 0))) * 
                cos(radians(IFNULL(IFNULL(a.live_longitude, a.longitude), 0)) - radians(:user_lng)) + 
                sin(radians(:user_lat)) * sin(radians(IFNULL(IFNULL(a.live_latitude, a.latitude), 0)))
            )))) AS distance_km";
        } else {
            $distanceSelect = ", NULL AS distance_km";
        }

        $query = "SELECT u.id as user_id, u.name, u.avatar_url, a.bio, a.skill, a.category_id, c.name as category_name,
                         a.average_rating, a.total_reviews, a.experience_years, a.location_name, a.hourly_rate,
                         a.latitude, a.longitude, a.live_latitude, a.live_longitude, a.is_available $distanceSelect
                  FROM " . $this->table . " a
                  JOIN users u ON u.id = a.user_id
                  LEFT JOIN categories c ON c.id = a.category_id
                  WHERE (a.verification_status = 'approved' OR a.verification_status = 'verified')";

        if ($categoryId) {
            $query .= " AND a.category_id = :cat_id";
        }

        $stmt = $this->conn->prepare($query);
        if ($hasCoords) {
            $stmt->bindParam(':user_lat', $userLat);
            $stmt->bindParam(':user_lng', $userLng);
        }
        if ($categoryId) {
            $stmt->bindParam(':cat_id', $categoryId);
        }

        $stmt->execute();
        $artisans = $stmt->fetchAll(PDO::FETCH_ASSOC);

        // Compute AI Match Score for each artisan
        foreach ($artisans as &$artisan) {
            $rating = floatval($artisan['average_rating'] ?? 5.0);
            $reviews = intval($artisan['total_reviews'] ?? 0);
            $exp = intval($artisan['experience_years'] ?? 2);
            $dist = isset($artisan['distance_km']) && $artisan['distance_km'] !== null ? floatval($artisan['distance_km']) : 10.0;
            $isAvail = intval($artisan['is_available'] ?? 1);

            // 1. Proximity score (0-40 pts)
            $distScore = 40.0;
            if ($dist > 30) $distScore = 15.0;
            elseif ($dist > 15) $distScore = 25.0;
            elseif ($dist > 5) $distScore = 32.0;
            elseif ($dist <= 5) $distScore = 40.0;

            // 2. Quality & Rating score (0-30 pts)
            $qualityScore = ($rating / 5.0) * 30.0;

            // 3. Experience & Trust volume (0-15 pts)
            $trustScore = min(15.0, ($reviews * 1.5) + ($exp * 0.8));

            // 4. Availability & Reliability boost (0-15 pts)
            $availScore = ($isAvail == 1) ? 15.0 : 5.0;

            $totalScore = round($distScore + $qualityScore + $trustScore + $availScore);
            if ($totalScore > 99) $totalScore = 99;
            if ($totalScore < 60) $totalScore = 60;

            $artisan['match_percentage'] = $totalScore;
            
            // Generate smart recommendation tags
            if ($dist <= 5 && $rating >= 4.7) {
                $artisan['match_tag'] = "{$totalScore}% Match • Top Rated Nearby";
            } elseif ($dist <= 5) {
                $artisan['match_tag'] = "{$totalScore}% Match • Nearest Pro";
            } elseif ($rating >= 4.8) {
                $artisan['match_tag'] = "{$totalScore}% Match • Master Craftsman";
            } elseif ($artisan['hourly_rate'] > 0 && $artisan['hourly_rate'] <= 6000) {
                $artisan['match_tag'] = "{$totalScore}% Match • Great Value";
            } else {
                $artisan['match_tag'] = "{$totalScore}% Match • Highly Recommended";
            }
        }
        unset($artisan);

        // Sort descending by match score
        usort($artisans, function($a, $b) {
            return $b['match_percentage'] <=> $a['match_percentage'];
        });

        return array_slice($artisans, 0, $limit);
    }
}

