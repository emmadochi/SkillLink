-- Migration Script for Artisan Sub-Services
-- This script creates the bridge table to link artisans to specific sub-services.

CREATE TABLE IF NOT EXISTS `artisan_sub_services` (
    `artisan_id` INT NOT NULL,
    `sub_service_id` INT NOT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`artisan_id`, `sub_service_id`),
    FOREIGN KEY (`artisan_id`) REFERENCES `artisans`(`user_id`) ON DELETE CASCADE,
    FOREIGN KEY (`sub_service_id`) REFERENCES `category_services`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
