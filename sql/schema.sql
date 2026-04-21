-- SkillLink Relational Database Schema
-- Version: 1.0.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

-- 1. Categories
CREATE TABLE IF NOT EXISTS `categories` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `slug` VARCHAR(100) NOT NULL UNIQUE,
    `icon` VARCHAR(100) DEFAULT 'handyman',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Users
CREATE TABLE IF NOT EXISTS `users` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `email` VARCHAR(255) NOT NULL UNIQUE,
    `phone` VARCHAR(20) DEFAULT NULL,
    `password_hash` VARCHAR(255) NOT NULL,
    `role` ENUM('customer', 'artisan', 'admin') DEFAULT 'customer',
    `avatar_url` VARCHAR(255) DEFAULT NULL,
    `is_verified` BOOLEAN DEFAULT FALSE,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Artisan Specific Profiles
CREATE TABLE IF NOT EXISTS `artisans` (
    `user_id` INT PRIMARY KEY,
    `bio` TEXT,
    `experience_years` INT DEFAULT 0,
    `location_name` VARCHAR(255),
    `latitude` DECIMAL(10, 8),
    `longitude` DECIMAL(11, 8),
    `verification_status` ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    `average_rating` DECIMAL(3, 2) DEFAULT 0.00,
    `total_reviews` INT DEFAULT 0,
    `is_available` BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Artisan Skills (Many-to-Many Bridge)
CREATE TABLE IF NOT EXISTS `artisan_categories` (
    `artisan_id` INT,
    `category_id` INT,
    PRIMARY KEY (`artisan_id`, `category_id`),
    FOREIGN KEY (`artisan_id`) REFERENCES `artisans`(`user_id`) ON DELETE CASCADE,
    FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Bookings
CREATE TABLE IF NOT EXISTS `bookings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `booking_number` VARCHAR(20) UNIQUE,
    `customer_id` INT NOT NULL,
    `artisan_id` INT NOT NULL,
    `category_id` INT NOT NULL,
    `service_description` TEXT,
    `scheduled_at` DATETIME NOT NULL,
    `status` ENUM('pending', 'confirmed', 'arrived', 'in_progress', 'completed', 'cancelled') DEFAULT 'pending',
    `price` DECIMAL(12, 2) NOT NULL,
    `platform_fee` DECIMAL(12, 2) NOT NULL,
    `artisan_payout` DECIMAL(12, 2) NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`customer_id`) REFERENCES `users`(`id`),
    FOREIGN KEY (`artisan_id`) REFERENCES `artisans`(`user_id`),
    FOREIGN KEY (`category_id`) REFERENCES `categories`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Payments/Transactions
CREATE TABLE IF NOT EXISTS `transactions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `booking_id` INT,
    `user_id` INT NOT NULL,
    `amount` DECIMAL(12, 2) NOT NULL,
    `type` ENUM('payment', 'payout', 'refund') NOT NULL,
    `payment_method` ENUM('card', 'wallet', 'bank_transfer') NOT NULL,
    `payment_reference` VARCHAR(100) UNIQUE,
    `status` ENUM('pending', 'successful', 'failed') DEFAULT 'pending',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Reviews
CREATE TABLE IF NOT EXISTS `reviews` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `booking_id` INT UNIQUE NOT NULL,
    `customer_id` INT NOT NULL,
    `artisan_id` INT NOT NULL,
    `rating` INT CHECK (`rating` >= 1 AND `rating` <= 5),
    `comment` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`booking_id`) REFERENCES `bookings`(`id`),
    FOREIGN KEY (`customer_id`) REFERENCES `users`(`id`),
    FOREIGN KEY (`artisan_id`) REFERENCES `artisans`(`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Seed Initial Categories
INSERT INTO `categories` (`name`, `slug`, `icon`) VALUES
('Plumbing', 'plumbing', 'water_drop'),
('Electrical', 'electrical', 'bolt'),
('Cleaning', 'cleaning', 'cleaning_services'),
('Carpentry', 'carpentry', 'home_repair_service'),
('Catering', 'catering', 'restaurant'),
('Painting', 'painting', 'format_paint'),
('Laundry', 'laundry', 'local_laundry_service');
