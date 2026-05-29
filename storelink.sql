-- MariaDB dump 10.19  Distrib 10.4.28-MariaDB, for osx10.10 (x86_64)
--
-- Host: localhost    Database: storelink
-- ------------------------------------------------------
-- Server version	10.4.28-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `group_code` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `note` text DEFAULT NULL,
  PRIMARY KEY (`code`),
  KEY `group_code` (`group_code`),
  CONSTRAINT `categories_ibfk_1` FOREIGN KEY (`group_code`) REFERENCES `groups` (`code`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES ('C001','Coffee','G001','2026-05-28 06:04:43','Sample Category Note'),('C002','Tea','G001','2026-05-28 06:04:43','Sample Category Note'),('C003','Potato Chips','G002','2026-05-28 06:04:43','Sample Category Note'),('C004','Chocolate','G002','2026-05-28 06:13:37','Sample Category Note'),('C005','Cup Noodle','G003','2026-05-28 06:13:37','Sample Category Note'),('C006','Frozen Food','G003','2026-05-28 06:13:37','Sample Category Note'),('C007','Tissue','G004','2026-05-28 06:13:37','Sample Category Note'),('C008','Toothpaste','G004','2026-05-28 06:13:37','Sample Category Note');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `groups`
--

DROP TABLE IF EXISTS `groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groups` (
  `code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `note` text DEFAULT NULL,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `groups`
--

LOCK TABLES `groups` WRITE;
/*!40000 ALTER TABLE `groups` DISABLE KEYS */;
INSERT INTO `groups` VALUES ('G001','Drink','2026-05-28 06:04:43','Sample Group Note'),('G002','Snack','2026-05-28 06:04:43','Sample Group Note'),('G003','Instant Food','2026-05-28 06:13:37','Sample Group Note'),('G004','Daily Item','2026-05-28 06:13:37','Sample Group Note');
/*!40000 ALTER TABLE `groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `item_history`
--

DROP TABLE IF EXISTS `item_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_history` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item_code` varchar(20) DEFAULT NULL,
  `before_qty` int(11) DEFAULT NULL,
  `after_qty` int(11) DEFAULT NULL,
  `diff` int(11) DEFAULT NULL,
  `action_type` varchar(50) DEFAULT NULL,
  `note` text DEFAULT NULL,
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `item_code` (`item_code`),
  CONSTRAINT `item_history_ibfk_1` FOREIGN KEY (`item_code`) REFERENCES `items` (`code`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `item_history`
--

LOCK TABLES `item_history` WRITE;
/*!40000 ALTER TABLE `item_history` DISABLE KEYS */;
INSERT INTO `item_history` VALUES (1,'I001',30,20,-10,'CSV_IMPORT','Sales imported','admin','2026-05-28 06:04:45'),(2,'I003',15,2,-13,'CSV_IMPORT','CSV sales import により在庫を減少','admin','2026-05-28 06:21:39'),(3,'I004',25,1,-24,'CSV_IMPORT','CSV sales import により在庫を減少','admin','2026-05-28 06:21:39'),(4,'I005',30,3,-27,'CSV_IMPORT','CSV sales import により在庫を減少','admin','2026-05-28 06:21:39');
/*!40000 ALTER TABLE `item_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `items`
--

DROP TABLE IF EXISTS `items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `items` (
  `code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `group_code` varchar(20) DEFAULT NULL,
  `category_code` varchar(20) DEFAULT NULL,
  `table_code` varchar(20) DEFAULT NULL,
  `qty` int(11) DEFAULT 0,
  `price` decimal(10,2) DEFAULT 0.00,
  `note` text DEFAULT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`code`),
  KEY `group_code` (`group_code`),
  KEY `category_code` (`category_code`),
  KEY `table_code` (`table_code`),
  CONSTRAINT `items_ibfk_1` FOREIGN KEY (`group_code`) REFERENCES `groups` (`code`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `items_ibfk_2` FOREIGN KEY (`category_code`) REFERENCES `categories` (`code`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `items_ibfk_3` FOREIGN KEY (`table_code`) REFERENCES `tables` (`code`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `items`
--

LOCK TABLES `items` WRITE;
/*!40000 ALTER TABLE `items` DISABLE KEYS */;
INSERT INTO `items` VALUES ('I001','Coca Cola','G001','C001','T001',20,150.00,'Sample Item','uploads/items/noimage.png','admin','2026-05-28 06:04:43'),('I002','Potato Chips','G002','C003','T002',10,200.00,'Sample Snack','uploads/items/noimage.png','admin','2026-05-28 06:04:43'),('I003','Green Tea','G001','C002','T001',2,120.00,'Sample Drink','uploads/items/noimage.png','admin','2026-05-28 06:13:38'),('I004','Chocolate Bar','G002','C004','T002',1,180.00,'Sweet Snack','uploads/items/noimage.png','admin','2026-05-28 06:13:38'),('I005','Cup Noodle','G003','C005','T003',3,250.00,'Instant Food','uploads/items/noimage.png','admin','2026-05-28 06:13:38'),('I006','Toothpaste','G004','C008','T004',12,350.00,'Daily Item','uploads/items/noimage.png','admin','2026-05-28 06:13:38'),('I007','Bubble Tea','G001','C002','T001',7,500.00,'メモ','uploads/items/I007_1779949456314.jpeg','admin','2026-05-28 06:24:16');
/*!40000 ALTER TABLE `items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tables`
--

DROP TABLE IF EXISTS `tables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tables` (
  `code` varchar(20) NOT NULL,
  `name` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `note` text DEFAULT NULL,
  `group_code` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tables`
--

LOCK TABLES `tables` WRITE;
/*!40000 ALTER TABLE `tables` DISABLE KEYS */;
INSERT INTO `tables` VALUES ('T001','Shelf A','2026-05-28 06:04:43','Sample Table Note','G001'),('T002','Shelf B','2026-05-28 06:04:43','Sample Table Note','G002'),('T003','Shelf C','2026-05-28 06:13:37','Sample Table Note','G003'),('T004','Back Storage','2026-05-28 06:13:37','Sample Table Note','G004');
/*!40000 ALTER TABLE `tables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_permissions`
--

DROP TABLE IF EXISTS `user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_permissions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `perm_key` varchar(50) NOT NULL,
  `allowed` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_permissions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_permissions`
--

LOCK TABLES `user_permissions` WRITE;
/*!40000 ALTER TABLE `user_permissions` DISABLE KEYS */;
INSERT INTO `user_permissions` VALUES (1,1,'DASHBOARD',1),(2,1,'GROUP_VIEW',1),(3,1,'CATEGORY_VIEW',1),(4,1,'TABLE_VIEW',1),(5,1,'ITEM_VIEW',1),(6,1,'ITEM_ADD',1);
/*!40000 ALTER TABLE `user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  `role` varchar(20) DEFAULT 'admin',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin','admin','admin');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-29 10:31:04
