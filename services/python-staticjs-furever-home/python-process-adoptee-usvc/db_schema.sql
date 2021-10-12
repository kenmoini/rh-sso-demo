#
# TABLE STRUCTURE FOR: pet_adoptees
#

CREATE TABLE `pet_adoptees` (
  `id` int(9) unsigned NOT NULL AUTO_INCREMENT,
  `name` text NOT NULL,
  `type` varchar(100) NOT NULL,
  `city` text NOT NULL,
  `locale` text NOT NULL,
  `image_url` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `adopted_at` timestamp DEFAULT NULL,
  `adopted_by` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `adoption_submissions` (
  `id` int(9) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` text NOT NULL,
  `pet_adoptee_id` int(9) unsigned NOT NULL,
  `status` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;