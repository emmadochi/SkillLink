<?php
namespace models;

use core\Database;
use PDO;

class Message {
    private $conn;
    private $table = "messages";

    private static $tableEnsured = false;

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
        if ($this->conn && !self::$tableEnsured) {
            $this->ensureTableExists();
            self::$tableEnsured = true;
        }
    }

    private function ensureTableExists() {
        $sql = "CREATE TABLE IF NOT EXISTS " . $this->table . " (
            id INT AUTO_INCREMENT PRIMARY KEY,
            sender_id INT NOT NULL,
            receiver_id INT NOT NULL,
            message TEXT NOT NULL,
            message_type ENUM('text', 'image', 'video', 'audio') DEFAULT 'text',
            media_url VARCHAR(255) DEFAULT NULL,
            media_duration INT DEFAULT NULL,
            is_read TINYINT(1) DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX (sender_id),
            INDEX (receiver_id),
            FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE,
            FOREIGN KEY (receiver_id) REFERENCES users(id) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";
        try {
            $this->conn->exec($sql);
        } catch (\PDOException $e) {
            // Check if table exists without media columns and alter
            try {
                $this->conn->exec("ALTER TABLE " . $this->table . " ADD COLUMN IF NOT EXISTS message_type ENUM('text', 'image', 'video', 'audio') DEFAULT 'text'");
                $this->conn->exec("ALTER TABLE " . $this->table . " ADD COLUMN IF NOT EXISTS media_url VARCHAR(255) DEFAULT NULL");
                $this->conn->exec("ALTER TABLE " . $this->table . " ADD COLUMN IF NOT EXISTS media_duration INT DEFAULT NULL");
            } catch (\Exception $e2) {
                // Table alter fallback for older MySQL
            }
        }
    }

    public function send($senderId, $receiverId, $message, $type = 'text', $mediaUrl = null, $duration = null) {
        if (!$this->conn) return false;
        
        $query = "INSERT INTO " . $this->table . " 
                  (sender_id, receiver_id, message, message_type, media_url, media_duration) 
                  VALUES (:sid, :rid, :msg, :type, :murl, :dur)";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':sid', $senderId, PDO::PARAM_INT);
        $stmt->bindParam(':rid', $receiverId, PDO::PARAM_INT);
        $stmt->bindParam(':msg', $message);
        $stmt->bindParam(':type', $type);
        $stmt->bindParam(':murl', $mediaUrl);
        $stmt->bindParam(':dur', $duration, $duration === null ? PDO::PARAM_NULL : PDO::PARAM_INT);
        
        return $stmt->execute();
    }

    public function create($data) {
        $senderId = $data['sender_id'];
        $receiverId = $data['receiver_id'];
        $message = $data['message'];
        $type = $data['message_type'] ?? 'text';
        $mediaUrl = $data['media_url'] ?? null;
        $duration = $data['media_duration'] ?? null;

        if ($this->send($senderId, $receiverId, $message, $type, $mediaUrl, $duration)) {
            return (int)$this->conn->lastInsertId();
        }
        return false;
    }

    public function getConversation($user1, $user2, $limit = 60) {
        if (!$this->conn) return [];
        $query = "SELECT * FROM (
                    SELECT id, sender_id, receiver_id, message, 
                           IFNULL(message_type, 'text') as message_type,
                           media_url, media_duration, is_read, created_at 
                    FROM " . $this->table . " 
                    WHERE (sender_id = :u1 AND receiver_id = :u2) 
                    OR (sender_id = :u2 AND receiver_id = :u1) 
                    ORDER BY created_at DESC LIMIT :limit
                  ) tmp ORDER BY created_at ASC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':u1', $user1, PDO::PARAM_INT);
        $stmt->bindParam(':u2', $user2, PDO::PARAM_INT);
        $stmt->bindValue(':limit', (int)$limit, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getChatList($userId) {
        if (!$this->conn) return [];

        $query = "SELECT 
                    t.partner_id,
                    u.name as partner_name, 
                    u.avatar_url as partner_avatar,
                    m.message as last_message,
                    m.message_type as last_message_type,
                    m.created_at as last_time
                  FROM (
                      SELECT 
                          CASE WHEN sender_id = :uid THEN receiver_id ELSE sender_id END as partner_id,
                          MAX(id) as last_msg_id
                      FROM " . $this->table . "
                      WHERE sender_id = :uid OR receiver_id = :uid
                      GROUP BY partner_id
                  ) t
                  JOIN users u ON u.id = t.partner_id
                  JOIN " . $this->table . " m ON m.id = t.last_msg_id
                  ORDER BY m.created_at DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':uid', $userId, PDO::PARAM_INT);
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
