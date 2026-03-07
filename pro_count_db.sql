-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: MySQL-8.0:3306
-- Generation Time: Mar 04, 2026 at 05:14 AM
-- Server version: 8.0.41
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pro_count_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `app_message`
--

CREATE TABLE `app_message` (
  `id` int NOT NULL,
  `type` varchar(64) NOT NULL COMMENT 'PRODUCTION_FINISH_OVER_PLAN, etc.',
  `entity_type` varchar(32) DEFAULT NULL COMMENT 'BATCH, SALE, PURCHASE, etc.',
  `entity_id` int DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `message` text NOT NULL,
  `severity` varchar(16) NOT NULL DEFAULT 'warning' COMMENT 'info, warning, error',
  `created_by` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `read_at` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `app_settings`
--

CREATE TABLE `app_settings` (
  `id` int NOT NULL,
  `setup_guide_enabled` tinyint(1) NOT NULL DEFAULT '0',
  `updated_at` int NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `app_settings`
--

INSERT INTO `app_settings` (`id`, `setup_guide_enabled`, `updated_at`) VALUES
(1, 1, 1772482081);

-- --------------------------------------------------------

--
-- Table structure for table `audit_log`
--

CREATE TABLE `audit_log` (
  `id` bigint NOT NULL,
  `actor_user_id` int DEFAULT NULL,
  `action` varchar(50) NOT NULL,
  `entity` varchar(50) NOT NULL,
  `entity_id` bigint DEFAULT NULL,
  `payload` json DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `audit_log`
--

INSERT INTO `audit_log` (`id`, `actor_user_id`, `action`, `entity`, `entity_id`, `payload`, `ip`, `user_agent`, `created_at`) VALUES
(1, 1, 'LOGIN', 'user', 1, '\"{\\\"username\\\":\\\"frenk\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772194242),
(2, 1, 'CREATE', 'client', 1, '\"{\\\"name\\\":\\\"Mijoz 1\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772201317),
(3, 1, 'CREATE', 'client', 2, '\"{\\\"name\\\":\\\"Mijoz 2\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772201345),
(4, 1, 'CREATE', 'supplier', 1, '\"{\\\"name\\\":\\\"Yetkazib beruvchi 1 MCHJ\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772201377),
(5, 1, 'CREATE', 'supplier', 2, '\"{\\\"name\\\":\\\"Yetkazib beruvchi Ali MCHJ\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772201406),
(6, 1, 'CREATE', 'material', 1, '\"{\\\"name\\\":\\\"Hom ashyo 1\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772201574),
(7, 1, 'CREATE', 'material', 2, '\"{\\\"name\\\":\\\"Hom ashyo 2\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772201606),
(8, 1, 'CREATE', 'material', 3, '\"{\\\"name\\\":\\\"Hom ashyo 3\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772201628),
(9, 1, 'CREATE', 'material', 4, '\"{\\\"name\\\":\\\"Homa ashyo 4\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772201654),
(10, 1, 'CREATE', 'product', 1, '\"{\\\"name\\\":\\\"Maxsulot 1\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772357883),
(11, 1, 'CREATE', 'product', 2, '\"{\\\"name\\\":\\\"Maxsulot 2\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772357905),
(12, 1, 'CREATE', 'recipe', 1, '\"{\\\"name\\\":\\\"maxsulot1 retsep 1\\\",\\\"product_id\\\":1}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772357994),
(13, 1, 'CREATE', 'recipe', 2, '\"{\\\"name\\\":\\\"maxsulot1 retsept 2\\\",\\\"product_id\\\":1}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772358077),
(14, 1, 'CREATE', 'recipe', 3, '\"{\\\"name\\\":\\\"maxsulot 2 retsept 1\\\",\\\"product_id\\\":2}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772358104),
(15, 1, 'CREATE', 'product', 3, '\"{\\\"name\\\":\\\"maxsulot 3\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772372935),
(16, 1, 'CREATE', 'product', 4, '\"{\\\"name\\\":\\\"maxsulot 4\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772372957),
(17, 1, 'CREATE', 'product', 5, '\"{\\\"name\\\":\\\"maxsulot 5\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772372983),
(18, 1, 'CREATE', 'product', 6, '\"{\\\"name\\\":\\\"maxsulot 6\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772373002),
(19, 1, 'CREATE', 'product', 7, '\"{\\\"name\\\":\\\"maxsulot 7\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772373022),
(20, 1, 'DELETE', 'client', 2, '\"{\\\"name\\\":\\\"Mijoz 2\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466103),
(21, 1, 'DELETE', 'client', 1, '\"{\\\"name\\\":\\\"Mijoz 1\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466106),
(22, 1, 'DELETE', 'supplier', 2, '\"{\\\"name\\\":\\\"Yetkazib beruvchi Ali MCHJ\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466112),
(23, 1, 'DELETE', 'supplier', 1, '\"{\\\"name\\\":\\\"Yetkazib beruvchi 1 MCHJ\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466115),
(24, 1, 'DELETE', 'recipe', 3, '\"{\\\"name\\\":\\\"maxsulot 2 retsept 1\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466131),
(25, 1, 'DELETE', 'recipe', 2, '\"{\\\"name\\\":\\\"maxsulot1 retsept 2\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466134),
(26, 1, 'DELETE', 'recipe', 1, '\"{\\\"name\\\":\\\"maxsulot1 retsep 1\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466137),
(27, 1, 'DELETE', 'product', 7, '\"{\\\"name\\\":\\\"maxsulot 7\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466154),
(28, 1, 'DELETE', 'product', 6, '\"{\\\"name\\\":\\\"maxsulot 6\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466157),
(29, 1, 'DELETE', 'product', 5, '\"{\\\"name\\\":\\\"maxsulot 5\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466160),
(30, 1, 'DELETE', 'product', 4, '\"{\\\"name\\\":\\\"maxsulot 4\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466163),
(31, 1, 'DELETE', 'product', 3, '\"{\\\"name\\\":\\\"maxsulot 3\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466166),
(32, 1, 'DELETE', 'product', 2, '\"{\\\"name\\\":\\\"Maxsulot 2\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466168),
(33, 1, 'DELETE', 'product', 1, '\"{\\\"name\\\":\\\"Maxsulot 1\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466171),
(34, 1, 'DELETE', 'material', 4, '\"{\\\"name\\\":\\\"Homa ashyo 4\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466205),
(35, 1, 'DELETE', 'material', 3, '\"{\\\"name\\\":\\\"Hom ashyo 3\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466207),
(36, 1, 'DELETE', 'material', 2, '\"{\\\"name\\\":\\\"Hom ashyo 2\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466208),
(37, 1, 'DELETE', 'material', 1, '\"{\\\"name\\\":\\\"Hom ashyo 1\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772466209),
(38, 1, 'CREATE', 'supplier', 3, '\"{\\\"name\\\":\\\"yetkazib beruvchi 1\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772482301),
(39, 1, 'CREATE', 'material', 5, '\"{\\\"name\\\":\\\"Xomashyo1\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772482362),
(40, 1, 'CREATE', 'product', 8, '\"{\\\"name\\\":\\\"Maxsulot 1\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772482431),
(41, 1, 'CREATE', 'warehouse', 1, '\"{\\\"name\\\":\\\"Asosiy xom ashyo ombori\\\",\\\"type\\\":\\\"MATERIAL\\\",\\\"wh_type\\\":null}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772482458),
(42, 1, 'CREATE', 'warehouse', 2, '\"{\\\"name\\\":\\\"Maxsulot asosiy ombor\\\",\\\"type\\\":\\\"PRODUCT\\\",\\\"wh_type\\\":null}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772482495),
(43, 1, 'CREATE', 'warehouse', 3, '\"{\\\"name\\\":\\\"Asosiy braklar ombori\\\",\\\"type\\\":\\\"MATERIAL\\\",\\\"wh_type\\\":\\\"DEFECT\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772482514),
(44, 1, 'CREATE', 'recipe', 4, '\"{\\\"name\\\":\\\"retsep 1\\\",\\\"product_id\\\":8}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772482763),
(45, 1, 'CREATE', 'client', 3, '\"{\\\"name\\\":\\\"Mijoz 1\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772482989),
(46, 1, 'DELETE', 'recipe', 4, '\"{\\\"name\\\":\\\"retsep 1\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772486099),
(47, 1, 'CREATE', 'recipe', 5, '\"{\\\"name\\\":\\\"retsep 1\\\",\\\"product_id\\\":8}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772486185),
(48, 1, 'CREATE', 'product', 9, '\"{\\\"name\\\":\\\"Maxsulot 2\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772487221),
(49, 1, 'UPDATE', 'product', 9, '\"{\\\"name\\\":\\\"Maxsulot 2\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772487295),
(50, 1, 'CREATE', 'recipe', 6, '\"{\\\"name\\\":\\\"retsep 2\\\",\\\"product_id\\\":9}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772488155),
(51, 1, 'CREATE', 'material', 6, '\"{\\\"name\\\":\\\"Xomashyo 2\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772495108),
(52, 1, 'CREATE', 'material', 7, '\"{\\\"name\\\":\\\"Xomashyo 3\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772495151),
(53, 1, 'CREATE', 'product', 10, '\"{\\\"name\\\":\\\"Maxsulot 3\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772495979),
(54, 1, 'UPDATE', 'product', 10, '\"{\\\"name\\\":\\\"Maxsulot 3\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772496039),
(55, 1, 'CREATE', 'production', 1, '\"{\\\"batch_no\\\":\\\"BATCH-20260303-061538-351\\\",\\\"product_id\\\":9,\\\"plan_qty\\\":10000}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772500538),
(56, 1, 'CREATE', 'production', 2, '\"{\\\"batch_no\\\":\\\"BATCH-20260303-061845-862\\\",\\\"product_id\\\":8,\\\"plan_qty\\\":1}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772500725),
(57, 1, 'CREATE', 'recipe', 7, '\"{\\\"name\\\":\\\"retsep 3\\\",\\\"product_id\\\":10}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772558875),
(58, 1, 'CREATE', 'purchase', 1, '\"{\\\"number\\\":\\\"PUR-20260303-225912-492\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772560752),
(59, 1, 'UPDATE', 'production', 2, '\"{\\\"status\\\":\\\"IN_PROGRESS\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772560967),
(60, 1, 'UPDATE', 'production', 2, '\"{\\\"batch_no\\\":\\\"BATCH-20260303-061845-862\\\",\\\"status\\\":\\\"COMPLETED\\\",\\\"fact_qty\\\":1}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772560993),
(61, 1, 'CREATE', 'production', 3, '\"{\\\"batch_no\\\":\\\"BATCH-20260303-230941-437\\\",\\\"product_id\\\":8,\\\"plan_qty\\\":20000}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772561381),
(62, 1, 'CREATE', 'sale', 1, '\"{\\\"number\\\":\\\"SAL-20260303-232707-460\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772562427),
(63, 1, 'CREATE', 'purchase', 2, '\"{\\\"number\\\":\\\"PUR-20260304-012611-504\\\"}\"', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 1772569571);

-- --------------------------------------------------------

--
-- Table structure for table `client`
--

CREATE TABLE `client` (
  `id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `inn` varchar(20) DEFAULT NULL,
  `region_id` int DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `client`
--

INSERT INTO `client` (`id`, `name`, `inn`, `region_id`, `phone`, `email`, `address`, `status`, `created_at`, `updated_at`) VALUES
(3, 'Mijoz 1', '12345678', 5, '+998901234567', 'frenk10006@gmail.com', 'Ферганская область, Узбекистанский район, Янги хаёт МСГ, Жаманжар, дом 3', 1, 1772482989, 1772482989);

-- --------------------------------------------------------

--
-- Table structure for table `daily_analytics`
--

CREATE TABLE `daily_analytics` (
  `id` bigint NOT NULL,
  `date` date NOT NULL,
  `sales_count` int NOT NULL DEFAULT '0',
  `purchases_count` int NOT NULL DEFAULT '0',
  `batches_completed` int NOT NULL DEFAULT '0',
  `defects_count` int NOT NULL DEFAULT '0',
  `stock_txn_count` int NOT NULL DEFAULT '0',
  `revenue` decimal(18,2) NOT NULL DEFAULT '0.00',
  `cogs` decimal(18,2) NOT NULL DEFAULT '0.00',
  `profit` decimal(18,2) NOT NULL DEFAULT '0.00',
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `material`
--

CREATE TABLE `material` (
  `id` int NOT NULL,
  `category_id` int DEFAULT NULL,
  `supplier_id` int DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `spec` varchar(255) DEFAULT NULL,
  `unit_id` int NOT NULL,
  `min_qty` decimal(18,3) NOT NULL DEFAULT '0.000',
  `image` varchar(255) DEFAULT NULL,
  `note` text,
  `status` tinyint NOT NULL DEFAULT '1',
  `created_by` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `material`
--

INSERT INTO `material` (`id`, `category_id`, `supplier_id`, `name`, `spec`, `unit_id`, `min_qty`, `image`, `note`, `status`, `created_by`, `created_at`, `updated_at`) VALUES
(5, 4, 3, 'Xomashyo1', 'qora', 8, 20.000, NULL, NULL, 1, 1, 1772482362, 1772482362),
(6, 4, 3, 'Xomashyo 2', 'ss', 7, 35.000, NULL, NULL, 1, 1, 1772495108, 1772495108),
(7, 4, 3, 'Xomashyo 3', 'kulrang', 8, 20.000, NULL, NULL, 1, 1, 1772495151, 1772495151);

-- --------------------------------------------------------

--
-- Table structure for table `material_category`
--

CREATE TABLE `material_category` (
  `id` int NOT NULL,
  `parent_id` int DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `material_category`
--

INSERT INTO `material_category` (`id`, `parent_id`, `name`, `status`, `created_at`, `updated_at`) VALUES
(4, NULL, 'xomashyo kategoriya 1', 1, 1772482266, 1772482266);

-- --------------------------------------------------------

--
-- Table structure for table `migration`
--

CREATE TABLE `migration` (
  `version` varchar(180) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `apply_time` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `migration`
--

INSERT INTO `migration` (`version`, `apply_time`) VALUES
('m000000_000000_base', 1772194009),
('m260227_000001_init_pro_count_schema', 1772194042),
('m260227_000002_analytics_and_snapshots', 1772194043),
('m260227_000003_product_packagings_and_batch_pack', 1772200797),
('m260301_000001_mrp_draft', 1772371360),
('m260303_000002_app_settings', 1772480862),
('m260303_000003_create_ref_currency_table', 1772484486),
('m260303_000004_performance_indexes', 1772493623);

-- --------------------------------------------------------

--
-- Table structure for table `monthly_analytics`
--

CREATE TABLE `monthly_analytics` (
  `id` bigint NOT NULL,
  `year` int NOT NULL,
  `month` int NOT NULL,
  `sales_count` int NOT NULL DEFAULT '0',
  `purchases_count` int NOT NULL DEFAULT '0',
  `batches_completed` int NOT NULL DEFAULT '0',
  `defects_count` int NOT NULL DEFAULT '0',
  `stock_txn_count` int NOT NULL DEFAULT '0',
  `revenue` decimal(18,2) NOT NULL DEFAULT '0.00',
  `cogs` decimal(18,2) NOT NULL DEFAULT '0.00',
  `profit` decimal(18,2) NOT NULL DEFAULT '0.00',
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `mrp_draft`
--

CREATE TABLE `mrp_draft` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `name` varchar(255) DEFAULT '',
  `payload` json NOT NULL,
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `mrp_draft`
--

INSERT INTO `mrp_draft` (`id`, `user_id`, `name`, `payload`, `created_at`, `updated_at`) VALUES
(1, 1, 'MRP 2026-03-04 00:18:33', '\"{\\\"block1Rows\\\":[{\\\"productId\\\":10,\\\"qty\\\":100000,\\\"packagingId\\\":4,\\\"packagingName\\\":\\\"pachka\\\",\\\"packagingCapacity\\\":10000,\\\"packQty\\\":10},{\\\"productId\\\":9,\\\"qty\\\":10000,\\\"packagingId\\\":2,\\\"packagingName\\\":\\\"Karopka\\\",\\\"packagingCapacity\\\":1000,\\\"packQty\\\":10}],\\\"block2\\\":{\\\"checkedItems\\\":[],\\\"deletedOmbors\\\":[],\\\"manualEntries\\\":[],\\\"omborStockEdits\\\":[],\\\"mode\\\":\\\"all\\\"},\\\"block3\\\":{\\\"selectedBoms\\\":[]},\\\"block4\\\":{\\\"b4CheckedItems\\\":[],\\\"b4DeletedOmbors\\\":[],\\\"b4StockEdits\\\":[],\\\"b4AvailEdits\\\":[],\\\"b4ManualEntries\\\":[],\\\"b4CheckedManual\\\":[],\\\"b4Mode\\\":\\\"all\\\"},\\\"block5\\\":{\\\"currency\\\":\\\"UZS\\\",\\\"poItems\\\":[]}}\"', 1772565514, 1772565514),
(2, 1, 'MRP 2026-03-04 00:52:44', '\"{\\\"block1Rows\\\":[{\\\"productId\\\":8,\\\"qty\\\":200,\\\"packagingId\\\":1,\\\"packagingName\\\":\\\"Bochka\\\",\\\"packagingCapacity\\\":200,\\\"packQty\\\":1}],\\\"block2\\\":{\\\"checkedItems\\\":[],\\\"deletedOmbors\\\":[],\\\"manualEntries\\\":[],\\\"omborStockEdits\\\":[],\\\"mode\\\":\\\"all\\\"},\\\"block3\\\":{\\\"selectedBoms\\\":{\\\"8\\\":5}},\\\"block4\\\":{\\\"b4CheckedItems\\\":[\\\"1_5\\\"],\\\"b4DeletedOmbors\\\":[],\\\"b4StockEdits\\\":[],\\\"b4AvailEdits\\\":[],\\\"b4ManualEntries\\\":[],\\\"b4CheckedManual\\\":[],\\\"b4Mode\\\":\\\"all\\\"},\\\"block5\\\":{\\\"currency\\\":\\\"UZS\\\",\\\"poItems\\\":{\\\"Xomashyo1\\\":{\\\"material\\\":\\\"Xomashyo1\\\",\\\"materialId\\\":5,\\\"unit\\\":\\\"kg\\\",\\\"needed\\\":1070.2,\\\"price\\\":100,\\\"supplier\\\":\\\"yetkazib beruvchi 1\\\",\\\"leadDays\\\":7}}}}\"', 1772565723, 1772567564);

-- --------------------------------------------------------

--
-- Table structure for table `order`
--

CREATE TABLE `order` (
  `id` bigint NOT NULL,
  `client_id` int NOT NULL,
  `number` varchar(50) NOT NULL,
  `status` enum('DRAFT','CONFIRMED','IN_PRODUCTION','COMPLETED','DELIVERED','CANCELLED') NOT NULL DEFAULT 'DRAFT',
  `due_date` date DEFAULT NULL,
  `note` text,
  `created_by` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `order_item`
--

CREATE TABLE `order_item` (
  `id` bigint NOT NULL,
  `order_id` bigint NOT NULL,
  `product_id` int NOT NULL,
  `qty` decimal(18,3) NOT NULL,
  `unit_price` decimal(18,2) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `price`
--

CREATE TABLE `price` (
  `id` bigint NOT NULL,
  `item_type` enum('MATERIAL','PRODUCT') NOT NULL,
  `item_id` int NOT NULL,
  `region_id` int DEFAULT NULL,
  `price` decimal(18,2) NOT NULL,
  `currency` char(3) NOT NULL DEFAULT 'UZS',
  `valid_from` date NOT NULL,
  `valid_to` date DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `created_by` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `price`
--

INSERT INTO `price` (`id`, `item_type`, `item_id`, `region_id`, `price`, `currency`, `valid_from`, `valid_to`, `status`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'PRODUCT', 8, NULL, 100000.00, 'UZS', '2026-03-03', NULL, 1, 1, 1772482865, 1772482897),
(3, 'MATERIAL', 5, 5, 100.00, 'UZS', '2026-03-03', NULL, 1, 1, 1772482926, 1772482926),
(4, 'PRODUCT', 9, NULL, 125000.00, 'UZS', '2026-03-03', NULL, 1, 1, 1772487313, 1772487313),
(5, 'PRODUCT', 10, 5, 50000.00, 'UZS', '2026-03-03', NULL, 1, 1, 1772558157, 1772558157),
(6, 'MATERIAL', 6, 5, 120.00, 'UZS', '2026-03-03', NULL, 1, 1, 1772558182, 1772558182),
(7, 'MATERIAL', 7, 5, 200.00, 'UZS', '2026-03-03', NULL, 1, 1, 1772558667, 1772558667);

-- --------------------------------------------------------

--
-- Table structure for table `product`
--

CREATE TABLE `product` (
  `id` int NOT NULL,
  `category_id` int DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `spec` varchar(255) DEFAULT NULL,
  `unit_id` int NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `note` text,
  `status` tinyint NOT NULL DEFAULT '1',
  `created_by` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `product`
--

INSERT INTO `product` (`id`, `category_id`, `name`, `spec`, `unit_id`, `image`, `note`, `status`, `created_by`, `created_at`, `updated_at`) VALUES
(8, 4, 'Maxsulot 1', 'qora', 8, NULL, NULL, 1, 1, 1772482431, 1772482431),
(9, 4, 'Maxsulot 2', 'yashil', 7, NULL, NULL, 1, 1, 1772487221, 1772487295),
(10, 4, 'Maxsulot 3', 'sariq', 6, NULL, NULL, 1, 1, 1772495979, 1772496039);

-- --------------------------------------------------------

--
-- Table structure for table `production_batch`
--

CREATE TABLE `production_batch` (
  `id` bigint NOT NULL,
  `batch_no` varchar(80) NOT NULL,
  `order_id` bigint DEFAULT NULL,
  `product_id` int NOT NULL,
  `recipe_id` int NOT NULL,
  `plan_qty` decimal(18,3) NOT NULL,
  `fact_qty` decimal(18,3) NOT NULL DEFAULT '0.000',
  `status` enum('PENDING','IN_PROGRESS','COMPLETED','CANCELLED') NOT NULL DEFAULT 'PENDING',
  `started_at` int DEFAULT NULL,
  `finished_at` int DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL,
  `packaging_id` int DEFAULT NULL,
  `pack_qty` decimal(18,6) DEFAULT NULL,
  `pack_capacity_snapshot` decimal(18,6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `production_batch`
--

INSERT INTO `production_batch` (`id`, `batch_no`, `order_id`, `product_id`, `recipe_id`, `plan_qty`, `fact_qty`, `status`, `started_at`, `finished_at`, `created_by`, `created_at`, `updated_at`, `packaging_id`, `pack_qty`, `pack_capacity_snapshot`) VALUES
(1, 'BATCH-20260303-061538-351', NULL, 9, 6, 10000.000, 0.000, 'PENDING', NULL, NULL, 1, 1772500538, 1772500538, 2, 10.000000, 1000.000000),
(2, 'BATCH-20260303-061845-862', NULL, 8, 5, 1.000, 1.000, 'COMPLETED', 1772560967, 1772560993, 1, 1772500725, 1772560993, 1, 0.005000, 200.000000),
(3, 'BATCH-20260303-230941-437', NULL, 8, 5, 20000.000, 0.000, 'PENDING', NULL, NULL, 1, 1772561381, 1772561381, 1, 100.000000, 200.000000);

-- --------------------------------------------------------

--
-- Table structure for table `production_consume`
--

CREATE TABLE `production_consume` (
  `id` bigint NOT NULL,
  `batch_id` bigint NOT NULL,
  `material_id` int NOT NULL,
  `qty` decimal(18,3) NOT NULL,
  `waste_percent` decimal(6,3) NOT NULL DEFAULT '0.000',
  `note` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `production_consume`
--

INSERT INTO `production_consume` (`id`, `batch_id`, `material_id`, `qty`, `waste_percent`, `note`) VALUES
(1, 2, 5, 10.200, 2.000, 'normal');

-- --------------------------------------------------------

--
-- Table structure for table `production_output`
--

CREATE TABLE `production_output` (
  `id` bigint NOT NULL,
  `batch_id` bigint NOT NULL,
  `product_id` int NOT NULL,
  `qty` decimal(18,3) NOT NULL,
  `warehouse_id` int NOT NULL,
  `created_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `production_output`
--

INSERT INTO `production_output` (`id`, `batch_id`, `product_id`, `qty`, `warehouse_id`, `created_at`) VALUES
(1, 2, 8, 1.000, 2, 1772560993);

-- --------------------------------------------------------

--
-- Table structure for table `product_category`
--

CREATE TABLE `product_category` (
  `id` int NOT NULL,
  `parent_id` int DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `product_category`
--

INSERT INTO `product_category` (`id`, `parent_id`, `name`, `status`, `created_at`, `updated_at`) VALUES
(4, NULL, 'Maxsulot kategoriya 1', 1, 1772482404, 1772482404);

-- --------------------------------------------------------

--
-- Table structure for table `product_cost_snapshot`
--

CREATE TABLE `product_cost_snapshot` (
  `id` bigint NOT NULL,
  `batch_id` bigint NOT NULL,
  `product_id` int NOT NULL,
  `unit_cost` decimal(18,6) NOT NULL DEFAULT '0.000000',
  `total_cost` decimal(18,2) NOT NULL DEFAULT '0.00',
  `currency` char(3) NOT NULL DEFAULT 'UZS',
  `calculated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `product_cost_snapshot`
--

INSERT INTO `product_cost_snapshot` (`id`, `batch_id`, `product_id`, `unit_cost`, `total_cost`, `currency`, `calculated_at`) VALUES
(1, 2, 8, 1020.000000, 1020.00, 'UZS', 1772560993);

-- --------------------------------------------------------

--
-- Table structure for table `product_packaging`
--

CREATE TABLE `product_packaging` (
  `id` int NOT NULL,
  `product_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `capacity_qty` decimal(18,6) NOT NULL,
  `unit_id` int DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `status` tinyint NOT NULL DEFAULT '1',
  `note` text,
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `product_packaging`
--

INSERT INTO `product_packaging` (`id`, `product_id`, `name`, `capacity_qty`, `unit_id`, `is_default`, `status`, `note`, `created_at`, `updated_at`) VALUES
(1, 8, 'Bochka', 200.000000, 8, 1, 1, NULL, 1772486386, 1772486411),
(2, 9, 'Karopka', 1000.000000, 8, 1, 1, NULL, 1772487253, 1772487275),
(3, 10, 'rulon', 1000.000000, 6, 1, 1, NULL, 1772496001, 1772496030),
(4, 10, 'pachka', 10000.000000, 6, 0, 1, NULL, 1772496022, 1772496022);

-- --------------------------------------------------------

--
-- Table structure for table `profit_snapshot`
--

CREATE TABLE `profit_snapshot` (
  `id` bigint NOT NULL,
  `sale_id` int NOT NULL,
  `sale_item_id` int NOT NULL,
  `product_id` int NOT NULL,
  `sale_date` date NOT NULL,
  `qty` decimal(18,3) NOT NULL,
  `unit_price` decimal(18,2) NOT NULL,
  `revenue` decimal(18,2) NOT NULL,
  `unit_cost` decimal(18,6) NOT NULL DEFAULT '0.000000',
  `cost` decimal(18,2) NOT NULL DEFAULT '0.00',
  `profit` decimal(18,2) NOT NULL DEFAULT '0.00',
  `currency` char(3) NOT NULL DEFAULT 'UZS',
  `created_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `profit_snapshot`
--

INSERT INTO `profit_snapshot` (`id`, `sale_id`, `sale_item_id`, `product_id`, `sale_date`, `qty`, `unit_price`, `revenue`, `unit_cost`, `cost`, `profit`, `currency`, `created_at`) VALUES
(1, 1, 1, 8, '2026-03-03', 1.000, 100000.00, 100000.00, 1020.000000, 1020.00, 98980.00, 'UZS', 1772562844);

-- --------------------------------------------------------

--
-- Table structure for table `purchase`
--

CREATE TABLE `purchase` (
  `id` int NOT NULL,
  `number` varchar(50) NOT NULL,
  `supplier_id` int NOT NULL,
  `warehouse_id` int NOT NULL,
  `status` enum('DRAFT','CONFIRMED','RECEIVED','CANCELLED') NOT NULL DEFAULT 'DRAFT',
  `purchase_date` date NOT NULL,
  `note` text,
  `created_by` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `purchase`
--

INSERT INTO `purchase` (`id`, `number`, `supplier_id`, `warehouse_id`, `status`, `purchase_date`, `note`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'PUR-20260303-225912-492', 3, 1, 'RECEIVED', '2026-03-03', NULL, 1, 1772560752, 1772560763),
(2, 'PUR-20260304-012611-504', 3, 1, 'DRAFT', '2026-03-04', 'MRP dan yaratildi', 1, 1772569571, 1772569571);

-- --------------------------------------------------------

--
-- Table structure for table `purchase_item`
--

CREATE TABLE `purchase_item` (
  `id` int NOT NULL,
  `purchase_id` int NOT NULL,
  `material_id` int NOT NULL,
  `qty` decimal(15,3) NOT NULL,
  `unit_cost` decimal(15,2) NOT NULL,
  `currency` varchar(10) DEFAULT 'UZS',
  `note` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `purchase_item`
--

INSERT INTO `purchase_item` (`id`, `purchase_id`, `material_id`, `qty`, `unit_cost`, `currency`, `note`) VALUES
(1, 1, 5, 1000.000, 100.00, 'UZS', NULL),
(2, 1, 6, 1000.000, 120.00, 'UZS', NULL),
(3, 1, 7, 1000.000, 200.00, 'UZS', NULL),
(4, 2, 5, 1070.200, 100.00, 'UZS', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `recipe`
--

CREATE TABLE `recipe` (
  `id` int NOT NULL,
  `product_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `version` int NOT NULL DEFAULT '1',
  `is_main` tinyint NOT NULL DEFAULT '0',
  `status` tinyint NOT NULL DEFAULT '1',
  `created_by` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `recipe`
--

INSERT INTO `recipe` (`id`, `product_id`, `name`, `version`, `is_main`, `status`, `created_by`, `created_at`, `updated_at`) VALUES
(5, 8, 'retsep 1', 1, 1, 1, 1, 1772486185, 1772486186),
(6, 9, 'retsep 2', 1, 1, 1, 1, 1772488155, 1772488156),
(7, 10, 'retsep 3', 1, 1, 1, 1, 1772558874, 1772558875);

-- --------------------------------------------------------

--
-- Table structure for table `recipe_item`
--

CREATE TABLE `recipe_item` (
  `id` int NOT NULL,
  `recipe_id` int NOT NULL,
  `material_id` int NOT NULL,
  `qty` decimal(18,3) NOT NULL,
  `waste_percent` decimal(6,3) NOT NULL DEFAULT '0.000',
  `note` varchar(255) DEFAULT NULL,
  `defect_pct` decimal(6,3) NOT NULL DEFAULT '0.000'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `recipe_item`
--

INSERT INTO `recipe_item` (`id`, `recipe_id`, `material_id`, `qty`, `waste_percent`, `note`, `defect_pct`) VALUES
(10, 5, 5, 10.000, 2.000, NULL, 0.000),
(11, 6, 5, 1.000, 2.000, NULL, 0.000),
(12, 7, 6, 25.000, 1.600, NULL, 0.000),
(13, 7, 5, 30.000, 1.200, NULL, 0.000),
(14, 7, 7, 15.000, 1.600, NULL, 0.000);

-- --------------------------------------------------------

--
-- Table structure for table `ref_currency`
--

CREATE TABLE `ref_currency` (
  `id` int NOT NULL,
  `code` varchar(10) NOT NULL,
  `name` varchar(100) NOT NULL,
  `symbol` varchar(10) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT '0',
  `status` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `ref_currency`
--

INSERT INTO `ref_currency` (`id`, `code`, `name`, `symbol`, `is_default`, `status`, `created_at`, `updated_at`) VALUES
(1, 'UZS', 'O\'zbek so\'mi', 'so\'m', 1, 1, 1772484486, 1772484486),
(4, 'USD', 'AQSH dollari', '$', 0, 1, 1772486015, 1772486015),
(5, 'EUR', 'Yevro', '€', 0, 1, 1772486060, 1772486060);

-- --------------------------------------------------------

--
-- Table structure for table `ref_region`
--

CREATE TABLE `ref_region` (
  `id` int NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `ref_region`
--

INSERT INTO `ref_region` (`id`, `name`) VALUES
(5, 'Tashkent');

-- --------------------------------------------------------

--
-- Table structure for table `ref_unit`
--

CREATE TABLE `ref_unit` (
  `id` int NOT NULL,
  `code` varchar(30) NOT NULL,
  `name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `ref_unit`
--

INSERT INTO `ref_unit` (`id`, `code`, `name`) VALUES
(6, 'm', 'Metr'),
(7, 'l', 'Litr'),
(8, 'kg', 'Kilogram');

-- --------------------------------------------------------

--
-- Table structure for table `sale`
--

CREATE TABLE `sale` (
  `id` int NOT NULL,
  `number` varchar(255) NOT NULL,
  `client_id` int NOT NULL,
  `warehouse_id` int NOT NULL,
  `status` enum('DRAFT','CONFIRMED','DELIVERED','CANCELLED') DEFAULT 'DRAFT',
  `sale_date` date NOT NULL,
  `note` text,
  `created_by` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `sale`
--

INSERT INTO `sale` (`id`, `number`, `client_id`, `warehouse_id`, `status`, `sale_date`, `note`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'SAL-20260303-232707-460', 3, 2, 'DELIVERED', '2026-03-03', NULL, 1, 1772562427, 1772562844);

-- --------------------------------------------------------

--
-- Table structure for table `sale_item`
--

CREATE TABLE `sale_item` (
  `id` int NOT NULL,
  `sale_id` int NOT NULL,
  `product_id` int NOT NULL,
  `qty` decimal(15,3) NOT NULL,
  `unit_price` decimal(15,2) NOT NULL,
  `currency` varchar(10) DEFAULT 'UZS',
  `note` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `sale_item`
--

INSERT INTO `sale_item` (`id`, `sale_id`, `product_id`, `qty`, `unit_price`, `currency`, `note`) VALUES
(1, 1, 8, 1.000, 100000.00, 'UZS', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `stock`
--

CREATE TABLE `stock` (
  `id` bigint NOT NULL,
  `warehouse_id` int NOT NULL,
  `item_type` enum('MATERIAL','PRODUCT') NOT NULL,
  `item_id` int NOT NULL,
  `qty` decimal(18,3) NOT NULL DEFAULT '0.000',
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `stock`
--

INSERT INTO `stock` (`id`, `warehouse_id`, `item_type`, `item_id`, `qty`, `updated_at`) VALUES
(1, 1, 'MATERIAL', 5, 989.800, 1772560967),
(2, 1, 'MATERIAL', 6, 1000.000, 1772560763),
(3, 1, 'MATERIAL', 7, 1000.000, 1772560763),
(4, 2, 'PRODUCT', 8, 0.000, 1772562844);

-- --------------------------------------------------------

--
-- Table structure for table `stock_txn`
--

CREATE TABLE `stock_txn` (
  `id` bigint NOT NULL,
  `warehouse_id` int NOT NULL,
  `item_type` enum('MATERIAL','PRODUCT') NOT NULL,
  `item_id` int NOT NULL,
  `direction` enum('IN','OUT') NOT NULL,
  `qty` decimal(18,3) NOT NULL,
  `reason` enum('MANUAL','PURCHASE','SALE','TRANSFER','PRODUCTION','DEFECT','RETURN') NOT NULL DEFAULT 'MANUAL',
  `ref_type` varchar(30) DEFAULT NULL,
  `ref_id` bigint DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `stock_txn`
--

INSERT INTO `stock_txn` (`id`, `warehouse_id`, `item_type`, `item_id`, `direction`, `qty`, `reason`, `ref_type`, `ref_id`, `note`, `created_by`, `created_at`) VALUES
(1, 1, 'MATERIAL', 5, 'IN', 1000.000, 'PURCHASE', 'PURCHASE', 1, 'Purchase receive', 1, 1772560763),
(2, 1, 'MATERIAL', 6, 'IN', 1000.000, 'PURCHASE', 'PURCHASE', 1, 'Purchase receive', 1, 1772560763),
(3, 1, 'MATERIAL', 7, 'IN', 1000.000, 'PURCHASE', 'PURCHASE', 1, 'Purchase receive', 1, 1772560763),
(4, 1, 'MATERIAL', 5, 'OUT', 10.200, 'PRODUCTION', 'BATCH', 2, 'Consume (normal)', 1, 1772560967),
(5, 2, 'PRODUCT', 8, 'IN', 1.000, 'PRODUCTION', 'BATCH', 2, 'Output', 1, 1772560993),
(9, 2, 'PRODUCT', 8, 'OUT', 1.000, 'SALE', 'SALE', 1, 'Sale deliver', 1, 1772562844);

-- --------------------------------------------------------

--
-- Table structure for table `supplier`
--

CREATE TABLE `supplier` (
  `id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `inn` varchar(20) DEFAULT NULL,
  `region_id` int DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `supplier`
--

INSERT INTO `supplier` (`id`, `name`, `inn`, `region_id`, `phone`, `email`, `address`, `status`, `created_at`, `updated_at`) VALUES
(3, 'yetkazib beruvchi 1', '12345678', NULL, '+998 94 693-94-09', 'frenk10006@gmail.com', '100185, Узбекистон Республикаси,Тошкент шахри,Чилонзор тумани, Бунёдкор шох кучаси, 29 уй.', 1, 1772482301, 1772482301);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `id` int NOT NULL,
  `username` varchar(255) NOT NULL,
  `fio` varchar(255) DEFAULT NULL,
  `role` varchar(20) DEFAULT NULL,
  `access_token` varchar(255) DEFAULT NULL,
  `expiret_access_token` varchar(15) DEFAULT NULL,
  `auth_key` varchar(32) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `password_reset_token` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `status` smallint NOT NULL DEFAULT '10',
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL,
  `verification_token` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`id`, `username`, `fio`, `role`, `access_token`, `expiret_access_token`, `auth_key`, `password_hash`, `password_reset_token`, `email`, `status`, `created_at`, `updated_at`, `verification_token`) VALUES
(1, 'frenk', NULL, NULL, 'oqAE0uSEaNSy6BK-GL3CLhKkVvzyHrT8', '1773678215', 'LH0EcISWGGE7ifBLyc5q5E_E8hrjiBWZ', '$2y$13$zYh9sUkHrpvkYqDl852Weeciw1KQvwBgIIRKS0kizTlcBgDZtJIGu', NULL, 'frenk10006@gmail.com', 10, 1771078906, 1771079015, '_na9wATL8MqeK7iZXe5fr-RlIvxex2AU_1771078906'),
(2, 'new', 'new', 'manager', NULL, NULL, 'yc21mi4yZ05tIHJYR6DEwkVLLBU21wH2', '$2y$13$Ye.YZ/ePAa06.bfMaHN/HezDu.W16l4hY4sBs4N1dFT404uRnf9ee', NULL, 'frenk10006@gmail.com2', 10, 1771658768, 1771658768, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `warehouse`
--

CREATE TABLE `warehouse` (
  `id` int NOT NULL,
  `type` enum('MATERIAL','PRODUCT') NOT NULL,
  `name` varchar(255) NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  `created_at` int NOT NULL,
  `updated_at` int NOT NULL,
  `wh_type` enum('MATERIAL','PRODUCT','DEFECT') NOT NULL DEFAULT 'MATERIAL'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `warehouse`
--

INSERT INTO `warehouse` (`id`, `type`, `name`, `status`, `created_at`, `updated_at`, `wh_type`) VALUES
(1, 'MATERIAL', 'Asosiy xom ashyo ombori', 1, 1772482458, 1772482458, 'MATERIAL'),
(2, 'PRODUCT', 'Maxsulot asosiy ombor', 1, 1772482495, 1772482495, 'MATERIAL'),
(3, 'MATERIAL', 'Asosiy braklar ombori', 1, 1772482514, 1772482514, 'DEFECT');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `app_message`
--
ALTER TABLE `app_message`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_app_message_created_at` (`created_at`),
  ADD KEY `idx_app_message_entity` (`entity_type`,`entity_id`),
  ADD KEY `idx_app_message_type` (`type`),
  ADD KEY `idx_app_message_read_at` (`read_at`);

--
-- Indexes for table `app_settings`
--
ALTER TABLE `app_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `audit_log`
--
ALTER TABLE `audit_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_actor_time` (`actor_user_id`,`created_at`),
  ADD KEY `idx_audit_entity` (`entity`,`entity_id`),
  ADD KEY `idx_audit_created` (`created_at`);

--
-- Indexes for table `client`
--
ALTER TABLE `client`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_client_region` (`region_id`);

--
-- Indexes for table `daily_analytics`
--
ALTER TABLE `daily_analytics`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `date` (`date`),
  ADD UNIQUE KEY `idx_daily_analytics_date` (`date`);

--
-- Indexes for table `material`
--
ALTER TABLE `material`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_material_cat` (`category_id`),
  ADD KEY `idx_material_supplier` (`supplier_id`),
  ADD KEY `idx_material_unit` (`unit_id`),
  ADD KEY `idx_material_status` (`status`);

--
-- Indexes for table `material_category`
--
ALTER TABLE `material_category`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_matcat_parent` (`parent_id`);

--
-- Indexes for table `migration`
--
ALTER TABLE `migration`
  ADD PRIMARY KEY (`version`);

--
-- Indexes for table `monthly_analytics`
--
ALTER TABLE `monthly_analytics`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_monthly_uniq` (`year`,`month`);

--
-- Indexes for table `mrp_draft`
--
ALTER TABLE `mrp_draft`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_mrp_draft_user_id` (`user_id`);

--
-- Indexes for table `order`
--
ALTER TABLE `order`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `number` (`number`),
  ADD KEY `idx_order_client` (`client_id`),
  ADD KEY `idx_order_status` (`status`);

--
-- Indexes for table `order_item`
--
ALTER TABLE `order_item`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_orderitem` (`order_id`,`product_id`),
  ADD KEY `idx_orderitem_product` (`product_id`);

--
-- Indexes for table `price`
--
ALTER TABLE `price`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_price_item` (`item_type`,`item_id`),
  ADD KEY `idx_price_region` (`region_id`),
  ADD KEY `idx_price_valid` (`valid_from`,`valid_to`);

--
-- Indexes for table `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_product_cat` (`category_id`),
  ADD KEY `idx_product_unit` (`unit_id`),
  ADD KEY `idx_product_status` (`status`);

--
-- Indexes for table `production_batch`
--
ALTER TABLE `production_batch`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `batch_no` (`batch_no`),
  ADD KEY `idx_batch_order` (`order_id`),
  ADD KEY `idx_batch_product` (`product_id`),
  ADD KEY `idx_batch_status` (`status`),
  ADD KEY `idx_batch_finished` (`finished_at`),
  ADD KEY `fk_batch_recipe` (`recipe_id`),
  ADD KEY `idx_batch_packaging` (`packaging_id`),
  ADD KEY `idx_batch_recipe` (`recipe_id`),
  ADD KEY `idx_batch_created` (`created_at`);

--
-- Indexes for table `production_consume`
--
ALTER TABLE `production_consume`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_consume_batch` (`batch_id`),
  ADD KEY `idx_consume_material` (`material_id`);

--
-- Indexes for table `production_output`
--
ALTER TABLE `production_output`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_output_batch` (`batch_id`),
  ADD KEY `fk_output_product` (`product_id`),
  ADD KEY `fk_output_wh` (`warehouse_id`),
  ADD KEY `idx_output_created` (`created_at`);

--
-- Indexes for table `product_category`
--
ALTER TABLE `product_category`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_prodcat_parent` (`parent_id`);

--
-- Indexes for table `product_cost_snapshot`
--
ALTER TABLE `product_cost_snapshot`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_pcs_batch` (`batch_id`),
  ADD KEY `idx_pcs_product` (`product_id`),
  ADD KEY `idx_pcs_product_calc` (`product_id`,`calculated_at`);

--
-- Indexes for table `product_packaging`
--
ALTER TABLE `product_packaging`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_product_packaging_product` (`product_id`),
  ADD KEY `idx_product_packaging_status` (`status`),
  ADD KEY `fk_product_packaging_unit` (`unit_id`);

--
-- Indexes for table `profit_snapshot`
--
ALTER TABLE `profit_snapshot`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_profit_sale` (`sale_id`),
  ADD KEY `idx_profit_product` (`product_id`),
  ADD KEY `idx_profit_date` (`sale_date`),
  ADD KEY `idx_profit_sale_item` (`sale_item_id`),
  ADD KEY `idx_profit_date_product` (`sale_date`,`product_id`);

--
-- Indexes for table `purchase`
--
ALTER TABLE `purchase`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `number` (`number`),
  ADD KEY `idx_supplier` (`supplier_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_purchase_date` (`purchase_date`),
  ADD KEY `idx_purchase_warehouse` (`warehouse_id`);

--
-- Indexes for table `purchase_item`
--
ALTER TABLE `purchase_item`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_purchase_item_purchase` (`purchase_id`),
  ADD KEY `idx_purchitem_material` (`material_id`);

--
-- Indexes for table `recipe`
--
ALTER TABLE `recipe`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_recipe_prod_ver` (`product_id`,`version`),
  ADD KEY `idx_recipe_main` (`product_id`,`is_main`);

--
-- Indexes for table `recipe_item`
--
ALTER TABLE `recipe_item`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_recipeitem` (`recipe_id`,`material_id`),
  ADD KEY `idx_recipeitem_material` (`material_id`);

--
-- Indexes for table `ref_currency`
--
ALTER TABLE `ref_currency`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Indexes for table `ref_region`
--
ALTER TABLE `ref_region`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `name` (`name`);

--
-- Indexes for table `ref_unit`
--
ALTER TABLE `ref_unit`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Indexes for table `sale`
--
ALTER TABLE `sale`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `number` (`number`),
  ADD KEY `idx_sale_client` (`client_id`),
  ADD KEY `idx_sale_warehouse` (`warehouse_id`),
  ADD KEY `idx_sale_date` (`sale_date`),
  ADD KEY `idx_sale_status` (`status`);

--
-- Indexes for table `sale_item`
--
ALTER TABLE `sale_item`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sale_item_product` (`product_id`),
  ADD KEY `fk_sale_item_sale` (`sale_id`);

--
-- Indexes for table `stock`
--
ALTER TABLE `stock`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_stock` (`warehouse_id`,`item_type`,`item_id`),
  ADD KEY `idx_stock_item` (`item_type`,`item_id`);

--
-- Indexes for table `stock_txn`
--
ALTER TABLE `stock_txn`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_txn_wh_time` (`warehouse_id`,`created_at`),
  ADD KEY `idx_txn_item` (`item_type`,`item_id`),
  ADD KEY `idx_txn_ref` (`ref_type`,`ref_id`),
  ADD KEY `idx_txn_item_wh` (`item_type`,`item_id`,`warehouse_id`,`created_at`),
  ADD KEY `idx_txn_created` (`created_at`),
  ADD KEY `fk_txn_user` (`created_by`),
  ADD KEY `idx_txn_reason` (`reason`);

--
-- Indexes for table `supplier`
--
ALTER TABLE `supplier`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_supplier_region` (`region_id`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_user_username` (`username`),
  ADD UNIQUE KEY `idx_user_email` (`email`),
  ADD UNIQUE KEY `idx_user_password_reset_token` (`password_reset_token`);

--
-- Indexes for table `warehouse`
--
ALTER TABLE `warehouse`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `app_message`
--
ALTER TABLE `app_message`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `app_settings`
--
ALTER TABLE `app_settings`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `audit_log`
--
ALTER TABLE `audit_log`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=64;

--
-- AUTO_INCREMENT for table `client`
--
ALTER TABLE `client`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `daily_analytics`
--
ALTER TABLE `daily_analytics`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `material`
--
ALTER TABLE `material`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `material_category`
--
ALTER TABLE `material_category`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `monthly_analytics`
--
ALTER TABLE `monthly_analytics`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `mrp_draft`
--
ALTER TABLE `mrp_draft`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `order`
--
ALTER TABLE `order`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `order_item`
--
ALTER TABLE `order_item`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `price`
--
ALTER TABLE `price`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `product`
--
ALTER TABLE `product`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `production_batch`
--
ALTER TABLE `production_batch`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `production_consume`
--
ALTER TABLE `production_consume`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `production_output`
--
ALTER TABLE `production_output`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `product_category`
--
ALTER TABLE `product_category`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `product_cost_snapshot`
--
ALTER TABLE `product_cost_snapshot`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `product_packaging`
--
ALTER TABLE `product_packaging`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `profit_snapshot`
--
ALTER TABLE `profit_snapshot`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `purchase`
--
ALTER TABLE `purchase`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `purchase_item`
--
ALTER TABLE `purchase_item`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `recipe`
--
ALTER TABLE `recipe`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `recipe_item`
--
ALTER TABLE `recipe_item`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `ref_currency`
--
ALTER TABLE `ref_currency`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `ref_region`
--
ALTER TABLE `ref_region`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `ref_unit`
--
ALTER TABLE `ref_unit`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `sale`
--
ALTER TABLE `sale`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `sale_item`
--
ALTER TABLE `sale_item`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `stock`
--
ALTER TABLE `stock`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `stock_txn`
--
ALTER TABLE `stock_txn`
  MODIFY `id` bigint NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `supplier`
--
ALTER TABLE `supplier`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `user`
--
ALTER TABLE `user`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `warehouse`
--
ALTER TABLE `warehouse`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `client`
--
ALTER TABLE `client`
  ADD CONSTRAINT `fk_client_region` FOREIGN KEY (`region_id`) REFERENCES `ref_region` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `material`
--
ALTER TABLE `material`
  ADD CONSTRAINT `fk_material_cat` FOREIGN KEY (`category_id`) REFERENCES `material_category` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_material_supplier` FOREIGN KEY (`supplier_id`) REFERENCES `supplier` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_material_unit` FOREIGN KEY (`unit_id`) REFERENCES `ref_unit` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `material_category`
--
ALTER TABLE `material_category`
  ADD CONSTRAINT `fk_matcat_parent` FOREIGN KEY (`parent_id`) REFERENCES `material_category` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `mrp_draft`
--
ALTER TABLE `mrp_draft`
  ADD CONSTRAINT `fk_mrp_draft_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `order`
--
ALTER TABLE `order`
  ADD CONSTRAINT `fk_order_client` FOREIGN KEY (`client_id`) REFERENCES `client` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `order_item`
--
ALTER TABLE `order_item`
  ADD CONSTRAINT `fk_orderitem_order` FOREIGN KEY (`order_id`) REFERENCES `order` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_orderitem_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `price`
--
ALTER TABLE `price`
  ADD CONSTRAINT `fk_price_region` FOREIGN KEY (`region_id`) REFERENCES `ref_region` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `product`
--
ALTER TABLE `product`
  ADD CONSTRAINT `fk_product_cat` FOREIGN KEY (`category_id`) REFERENCES `product_category` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_product_unit` FOREIGN KEY (`unit_id`) REFERENCES `ref_unit` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `production_batch`
--
ALTER TABLE `production_batch`
  ADD CONSTRAINT `fk_batch_order` FOREIGN KEY (`order_id`) REFERENCES `order` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_batch_packaging` FOREIGN KEY (`packaging_id`) REFERENCES `product_packaging` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_batch_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_batch_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `recipe` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `production_consume`
--
ALTER TABLE `production_consume`
  ADD CONSTRAINT `fk_consume_batch` FOREIGN KEY (`batch_id`) REFERENCES `production_batch` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_consume_material` FOREIGN KEY (`material_id`) REFERENCES `material` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `production_output`
--
ALTER TABLE `production_output`
  ADD CONSTRAINT `fk_output_batch` FOREIGN KEY (`batch_id`) REFERENCES `production_batch` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_output_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_output_wh` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `product_category`
--
ALTER TABLE `product_category`
  ADD CONSTRAINT `fk_prodcat_parent` FOREIGN KEY (`parent_id`) REFERENCES `product_category` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `product_cost_snapshot`
--
ALTER TABLE `product_cost_snapshot`
  ADD CONSTRAINT `fk_pcs_batch` FOREIGN KEY (`batch_id`) REFERENCES `production_batch` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `product_packaging`
--
ALTER TABLE `product_packaging`
  ADD CONSTRAINT `fk_product_packaging_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_product_packaging_unit` FOREIGN KEY (`unit_id`) REFERENCES `ref_unit` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Constraints for table `purchase_item`
--
ALTER TABLE `purchase_item`
  ADD CONSTRAINT `fk_purchase_item_purchase` FOREIGN KEY (`purchase_id`) REFERENCES `purchase` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `recipe`
--
ALTER TABLE `recipe`
  ADD CONSTRAINT `fk_recipe_product` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `recipe_item`
--
ALTER TABLE `recipe_item`
  ADD CONSTRAINT `fk_recipeitem_material` FOREIGN KEY (`material_id`) REFERENCES `material` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_recipeitem_recipe` FOREIGN KEY (`recipe_id`) REFERENCES `recipe` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `sale_item`
--
ALTER TABLE `sale_item`
  ADD CONSTRAINT `fk_sale_item_sale` FOREIGN KEY (`sale_id`) REFERENCES `sale` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `stock`
--
ALTER TABLE `stock`
  ADD CONSTRAINT `fk_stock_wh` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `stock_txn`
--
ALTER TABLE `stock_txn`
  ADD CONSTRAINT `fk_txn_user` FOREIGN KEY (`created_by`) REFERENCES `user` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_txn_wh` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouse` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE;

--
-- Constraints for table `supplier`
--
ALTER TABLE `supplier`
  ADD CONSTRAINT `fk_supplier_region` FOREIGN KEY (`region_id`) REFERENCES `ref_region` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
