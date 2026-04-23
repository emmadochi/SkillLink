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
        $query = "SELECT DISTINCT 
                    CASE WHEN sender_id = :uid THEN receiver_id ELSE sender_id END as partner_id,
                    u.name as partner_name, u.avatar_url as partner_avatar,
                    (SELECT message FROM messages m2 
                     WHERE (m2.sender_id = :uid AND m2.receiver_id = partner_id) 
                     OR (m2.sender_id = partner_id AND m2.receiver_id = :uid) 
                     ORDER BY m2.created_at DESC LIMIT 1) as last_message,
                    (SELECT created_at FROM messages m3 
                     WHERE (m3.sender_id = :uid AND m3.receiver_id = partner_id) 
                     OR (m3.sender_id = partner_id AND m3.receiver_id = :uid) 
                     ORDER BY m3.created_at DESC LIMIT 1) as last_time
                  FROM " . $this->table . " m
                  JOIN users u ON u.id = (CASE WHEN sender_id = :uid THEN receiver_id ELSE sender_id END)
                  WHERE sender_id = :uid OR receiver_id = :uid";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(':uid', $userId);
        $stmt->execute();
        return $stmt->fetchAll();
    }
}
