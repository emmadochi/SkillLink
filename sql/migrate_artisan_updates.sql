-- Migration Script for Artisan Profile Enhancements
-- This script adds the necessary security and skill verification fields to the existing database.

-- 1. Update the artisans table
ALTER TABLE `artisans` 
ADD COLUMN `business_address` TEXT AFTER `location_name`,
ADD COLUMN `guarantor_name` VARCHAR(100) AFTER `business_address`,
ADD COLUMN `guarantor_phone` VARCHAR(20) AFTER `guarantor_name`,
ADD COLUMN `identity_verified` BOOLEAN DEFAULT FALSE AFTER `verification_status`;

-- 2. Create Artisan Verifications table (Security/Tracking)
CREATE TABLE IF NOT EXISTS `artisan_verifications` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `artisan_id` INT NOT NULL,
    `id_type` ENUM('national_id', 'drivers_license', 'voters_card', 'passport') NOT NULL,
    `id_number` VARCHAR(50) NOT NULL,
    `id_image_front` VARCHAR(255),
    `id_image_back` VARCHAR(255),
    `status` ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    `admin_notes` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`artisan_id`) REFERENCES `artisans`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Create Artisan Portfolio table (Skill Showcase)
CREATE TABLE IF NOT EXISTS `artisan_portfolios` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `artisan_id` INT NOT NULL,
    `image_url` VARCHAR(255) NOT NULL,
    `description` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`artisan_id`) REFERENCES `artisans`(`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
