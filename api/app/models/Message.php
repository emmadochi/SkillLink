<?php
namespace models;

use core\Database;
use PDO;

class Message {
    private $conn;
    private $table = "messages";

    public function __construct() {
        $database = new Database();
        $this->conn = $database->getConnection();
    }

    public function send($senderId, $receiverId, $message) {
        $query = "INSERT INTO " . $this->table . " (sender_id, receiver_id, message) VALUES (:sid, :rid, :msg)";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':sid', $senderId);
        $stmt->bindParam(':rid', $receiverId);
        $stmt->bindParam(':msg', $message);
        return $stmt->execute();
    }

    public function getConversation($user1, $user2) {
        $query = "SELECT * FROM " . $this->table . " 
                  WHERE (sender_id = :u1 AND receiver_id = :u2) 
                  OR (sender_id = :u2 AND receiver_id = :u1) 
                  ORDER BY created_at ASC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':u1', $user1);
        $stmt->bindParam(':u2', $user2);
        $stmt->execute();
        return $stmt->fetchAll();
    }

    public function getChatList($userId) {
        $query = "SELECT 
                    t.partner_id,
                    u.name as partner_name, 
                    u.avatar_url as partner_avatar,
                    m.message as last_message,
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
        $stmt->bindParam(':uid', $userId);
        $stmt->execute();
        return $stmt->fetchAll();
    }
}
