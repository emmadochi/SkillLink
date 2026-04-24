-- Migration: Add Negotiation Fields to Bookings
ALTER TABLE `bookings` 
ADD COLUMN `offer_price` DECIMAL(12, 2) DEFAULT NULL AFTER `price`,
ADD COLUMN `counter_price` DECIMAL(12, 2) DEFAULT NULL AFTER `offer_price`,
ADD COLUMN `negotiation_status` ENUM('none', 'pending_artisan', 'pending_customer', 'accepted', 'rejected') DEFAULT 'none' AFTER `counter_price`,
ADD COLUMN `is_negotiated` BOOLEAN DEFAULT FALSE AFTER `negotiation_status`;
