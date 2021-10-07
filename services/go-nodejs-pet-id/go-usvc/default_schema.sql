# Generated from http://filldb.info/dbgenerator
#
# TABLE STRUCTURE FOR: pet_profile
#

CREATE TABLE `pet_profile` (
  `id` int(9) unsigned NOT NULL AUTO_INCREMENT,
  `pet_id` int(9) unsigned NOT NULL,
  `profile_id` int(9) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#
# TABLE STRUCTURE FOR: pets
#

CREATE TABLE `pets` (
  `id` int(9) unsigned NOT NULL AUTO_INCREMENT,
  `owner_profile_id` int(9) unsigned NOT NULL,
  `name` text NOT NULL,
  `nickname` text DEFAULT NULL,
  `type` text NOT NULL,
  `breed` text DEFAULT NULL,
  `color` int(11) DEFAULT NULL,
  `birthday` date DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

#
# TABLE STRUCTURE FOR: profiles
#

CREATE TABLE `profiles` (
  `id` int(9) unsigned NOT NULL AUTO_INCREMENT,
  `firstname` text NOT NULL,
  `lastname` text NOT NULL,
  `email` text NOT NULL,
  `city` text DEFAULT NULL,
  `state` text DEFAULT NULL,
  `country` text DEFAULT NULL,
  `phone` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`) USING HASH
) ENGINE=InnoDB DEFAULT CHARSET=utf8;