-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Feb 01, 2025 at 01:57 AM
-- Server version: 10.11.10-MariaDB-log
-- PHP Version: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `u915692715_mymemberlink`
--

-- --------------------------------------------------------

--
-- Table structure for table `cart_tbl`
--

CREATE TABLE `cart_tbl` (
  `cart_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `product_quantity` int(11) NOT NULL DEFAULT 1,
  `cart_timestamp` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `cart_status` varchar(20) NOT NULL DEFAULT 'New'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cart_tbl`
--

INSERT INTO `cart_tbl` (`cart_id`, `user_id`, `product_id`, `product_quantity`, `cart_timestamp`, `cart_status`) VALUES
(26, 2, 5, 2, '2024-12-15 15:07:30.608478', 'New'),
(27, 2, 9, 1, '2024-12-15 15:07:33.994678', 'New'),
(28, 2, 10, 1, '2024-12-15 15:07:38.554279', 'New'),
(29, 2, 8, 1, '2024-12-15 15:07:40.704277', 'New'),
(30, 2, 7, 1, '2024-12-15 15:07:42.241642', 'New'),
(31, 2, 1, 2, '2024-12-15 15:07:51.238321', 'New'),
(32, 2, 2, 1, '2024-12-15 15:07:54.002326', 'New'),
(33, 2, 3, 2, '2024-12-15 15:07:58.810410', 'New'),
(34, 2, 4, 1, '2024-12-15 15:08:01.718103', 'New'),
(35, 2, 11, 1, '2024-12-15 15:08:14.168902', 'New'),
(38, 2, 6, 1, '2024-12-15 16:21:50.926497', 'New'),
(39, 2, 13, 3, '2024-12-18 15:25:41.332304', 'New');

-- --------------------------------------------------------

--
-- Table structure for table `events_tbl`
--

CREATE TABLE `events_tbl` (
  `event_id` int(11) NOT NULL,
  `event_title` varchar(200) NOT NULL,
  `event_description` varchar(5000) NOT NULL,
  `event_startdate` datetime(6) NOT NULL,
  `event_enddate` datetime(6) NOT NULL,
  `event_type` varchar(100) NOT NULL,
  `event_location` varchar(300) NOT NULL,
  `event_filename` varchar(300) NOT NULL,
  `event_date` datetime(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `membership_purchase_tbl`
--

CREATE TABLE `membership_purchase_tbl` (
  `purchase_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `membership_id` int(11) NOT NULL,
  `receipt_id` varchar(50) NOT NULL,
  `amount` double NOT NULL,
  `payment_status` enum('Pending','Success','Failed') NOT NULL DEFAULT 'Pending',
  `purchase_date` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `expiry_date` datetime(6) DEFAULT NULL,
  `payment_method` varchar(50) NOT NULL DEFAULT 'Billplz',
  `payment_provider` varchar(50) NOT NULL DEFAULT 'Online Banking',
  `transaction_id` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `membership_purchase_tbl`
--

INSERT INTO `membership_purchase_tbl` (`purchase_id`, `user_id`, `membership_id`, `receipt_id`, `amount`, `payment_status`, `purchase_date`, `expiry_date`, `payment_method`, `payment_provider`, `transaction_id`) VALUES
(35, 2, 2, 'bgpnlhg0', 28, 'Success', '2025-02-01 00:25:36.446191', NULL, 'Billplz', 'Online Banking', NULL),
(37, 2, 4, 'uq7vjmic', 89, 'Failed', '2025-02-01 00:26:18.473186', NULL, 'Billplz', 'Online Banking', NULL),
(39, 2, 4, 'qnssmnw0', 89, 'Success', '2025-02-01 00:33:25.581179', NULL, 'Billplz', 'Online Banking', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `membership_tbl`
--

CREATE TABLE `membership_tbl` (
  `membership_id` int(11) NOT NULL,
  `membership_name` varchar(50) NOT NULL,
  `membership_description` varchar(4000) NOT NULL,
  `membership_price_RM` double NOT NULL DEFAULT 0,
  `membership_duration_month` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `membership_tbl`
--

INSERT INTO `membership_tbl` (`membership_id`, `membership_name`, `membership_description`, `membership_price_RM`, `membership_duration_month`) VALUES
(1, 'Economic', 'No Ads, 10 GB Cloud Space Storage, 1 User Account, 1 Device Access', 10, 1),
(2, 'Basic', 'No Ads, 300 GB Cloud Space Storage, 3 User Account, 3 Device Access', 28, 1),
(3, 'Pro', 'No Ads, 500 GB Cloud Space Storage, 10 User Account, 10 Device Access', 42, 1),
(4, 'Business', 'No Ads, Unlimited Cloud Space Storage, 20 User Account, 20 Device Access', 89, 1);

-- --------------------------------------------------------

--
-- Table structure for table `news_tbl`
--

CREATE TABLE `news_tbl` (
  `news_id` int(11) NOT NULL,
  `news_title` varchar(500) NOT NULL,
  `news_details` varchar(5000) NOT NULL,
  `news_date` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `news_tbl`
--

INSERT INTO `news_tbl` (`news_id`, `news_title`, `news_details`, `news_date`) VALUES
(1, 'Exclusive Member Rewards Unlocked!', 'We’re excited to announce a new rewards program exclusively for our valued members! Enjoy access to special discounts, early event registration, and a personalized dashboard to track your benefits. Log in to explore your new perks!', '2024-10-30 15:46:06.775643'),
(2, 'Exciting Updates in Your Membership!', 'Your membership app just got better! We’ve rolled out a series of updates to enhance your experience, including a redesigned profile page and streamlined access to your account history. Update the app today to check out these improvements!', '2024-10-30 15:46:32.239606'),
(3, 'New Feature Alert: Enhanced Member Dashboard', 'Keeping track of your membership benefits is now easier than ever! With our enhanced dashboard, you can view your points, redeem rewards, and get personalized offers at a glance. Log in now to explore!', '2024-10-30 15:46:51.886697'),
(4, 'Special Offer for Loyal Members!', 'Thank you for being a valued member! As a token of our appreciation, enjoy a special 15% discount on all renewals this month. Make sure to use the code MEMBER15 at checkout. Don’t miss out on this limited-time offer!', '2024-10-30 16:25:45.383816'),
(5, 'Member-Exclusive Webinar: Insights for Growth', 'Join our exclusive webinar featuring industry leaders discussing key trends and strategies for personal and professional growth. Reserve your spot now!', '2024-11-01 10:00:00.000000'),
(6, 'Celebrate Milestones with Us!', 'We’re turning 10! As part of our anniversary celebration, we’re giving members a chance to win exciting prizes through our special raffle draw. Stay tuned!', '2024-11-02 12:15:30.000000'),
(7, 'Member Spotlight: Inspiring Stories', 'We’re celebrating you! Check out our latest feature highlighting members who are making a difference in their communities. Read their inspiring stories now.', '2024-11-03 14:20:45.000000'),
(8, 'Priority Access to Events Just for You', 'Enjoy early access to exclusive events and workshops as a valued member. Register now to secure your spot before it’s open to the public!', '2024-11-04 16:30:00.000000'),
(9, 'Introducing Member Match Program', 'Find members with shared interests and collaborate on exciting projects through our new Member Match Program. Start connecting today!', '2024-11-05 09:00:00.000000'),
(10, 'Special Recognition for Long-Time Members', 'We’re grateful for your loyalty! Members with 5+ years of continuous membership will receive an exclusive gift as a token of our appreciation.', '2024-11-06 11:45:00.000000'),
(11, 'New Blog Series: Member Insights', 'Gain valuable insights from our members through our new blog series. Discover tips, success stories, and expert advice straight from our community.', '2024-11-07 13:00:00.000000'),
(12, 'Limited-Time Offer: Double Rewards Points', 'Earn double the rewards points on all activities this month. Don’t miss out on this opportunity to maximize your benefits!', '2024-11-08 15:20:00.000000'),
(13, 'Your Feedback Matters to Us', 'Help us improve by sharing your feedback. Complete our short survey and stand a chance to win a $50 gift card. Your opinion counts!', '2024-11-09 10:10:00.000000'),
(14, 'Exciting Partnership Announcement', 'We’re thrilled to partner with top brands to bring you more member-exclusive deals. Stay tuned for upcoming collaborations!', '2024-11-10 11:00:00.000000'),
(15, 'Enhanced Security Features for Your Account', 'Your safety is our priority. We’ve added new security measures to keep your account protected. Update your settings today!', '2024-11-11 13:30:00.000000'),
(16, 'Member Appreciation Day: Free Goodies!', 'Visit any of our locations on Member Appreciation Day to enjoy complimentary snacks and gifts as our way of saying thank you!', '2024-11-12 12:00:00.000000'),
(17, 'Virtual Networking Event for Members', 'Connect with fellow members from around the globe at our upcoming virtual networking event. Register now to expand your network!', '2024-11-13 14:45:00.000000'),
(18, 'Exciting Contest: Share Your Story', 'Tell us how being a member has impacted you and stand a chance to win an exclusive prize. Submit your story by the end of this month!', '2024-11-14 09:15:00.000000'),
(19, 'Exclusive Access to New Courses', 'As a member, you get early access to our latest courses on personal development and skill enhancement. Start learning today!', '2024-11-15 10:00:00.000000'),
(20, 'Seasonal Discounts for Members', 'Enjoy up to 25% off on selected items this holiday season. Log in to view your exclusive offers!', '2024-11-16 15:00:00.000000'),
(21, 'Charity Drive: Members Making a Difference', 'Join us in giving back to the community. Participate in our charity drive and make a meaningful impact.', '2024-11-17 11:00:00.000000'),
(22, 'Exciting Updates to the Member Portal', 'Your member portal just got an upgrade! Enjoy a more intuitive design and additional features for a seamless experience.', '2024-11-18 13:00:00.000000'),
(23, 'Surprise Giveaway for Active Members', 'Stay active and engaged this month for a chance to win surprise gifts! Keep an eye on your notifications for more details.', '2024-11-19 14:30:00.000000'),
(24, 'Upcoming Event: Member-Exclusive Q&A', 'Get your questions answered by our expert panel in this exclusive Q&A session. Reserve your spot today!', '2024-11-20 16:15:00.000000'),
(25, 'Holiday Season Gift Packs for Members', 'Celebrate the festive season with our specially curated gift packs available exclusively to members. Order yours now!', '2024-11-21 17:00:00.000000');

-- --------------------------------------------------------

--
-- Table structure for table `products_tbl`
--

CREATE TABLE `products_tbl` (
  `product_id` int(11) NOT NULL,
  `product_name` varchar(200) NOT NULL,
  `product_filename` varchar(200) NOT NULL,
  `product_category` varchar(20) NOT NULL,
  `product_date` datetime(6) NOT NULL DEFAULT current_timestamp(6),
  `product_location` varchar(300) NOT NULL,
  `product_description` varchar(5000) NOT NULL,
  `product_quantity` int(11) NOT NULL,
  `product_price` double NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products_tbl`
--

INSERT INTO `products_tbl` (`product_id`, `product_name`, `product_filename`, `product_category`, `product_date`, `product_location`, `product_description`, `product_quantity`, `product_price`) VALUES
(1, 'Mug', 'mug.jpeg', 'Tableware', '2024-12-12 03:27:55.000000', 'Lot 13, Kampung Baru, Pulau Sayak, 08500, Kota Kuala Muda, Kedah', 'Volume: 400 ml, Height: 10 cm, Width: 8 cm', 3, 10.5),
(2, 'A4 Paper', 'a4-paper.jpeg', 'Stationery', '0000-00-00 00:00:00.000000', 'Jalan Ampang, Congkak 2, Universiti, Selangor', 'A4 Paper, 80gsm (1 ream x 500 sheets)', 10, 16.7),
(3, 'Black Pen', 'blackpen.jpeg', 'Stationery', '0000-00-00 00:00:00.000000', 'Gambut, Kepala Terbatas, Saito, Kelantan', 'Super smooth, nice black ink, doesn\'t smudge, great price point, but it starting to skip after about a week of use.', 55, 1.7),
(4, 'Black Totebag', 'blacktotebag.jpeg', 'Accessory', '0000-00-00 00:00:00.000000', 'Serabut, Gabut, Manakal, China', 'Tote bag; Synthetic material; 9.5\" H x 11.75\" W x 5\" D; Top Handle: 4.5\'; Strap Drop: 24\"', 21, 11.2),
(5, 'Black Bowtie', 'bowtie.jpeg', 'Accessory', '0000-00-00 00:00:00.000000', 'Sandakan, Sandarkan, Bumiputera, Sabah', 'Black Bird\'s Eye Bowtie Set. RM59.90. Out of stock. ADD ON. SmartMaster Exclusive Gift Box. Add to cart. Exclusive Gift Box. RM10.00', 40, 159.9),
(6, 'Coffee Sachet', 'coffee-sachet.jpeg', 'Culinary', '0000-00-00 00:00:00.000000', 'Kampung Lama, Bandar Buah, Sayonara, Johor', 'Alor Americano Freeze Dried Arabica Coffee (2.5g x 1 sachets). RM1.75 ; Super 3in1 Instant Coffee 1 Sachet.', 148, 1.75),
(7, 'Creamer Sachet', 'creamer-sachet.jpeg', 'Culinary', '0000-00-00 00:00:00.000000', 'Kampung Lama, Bandar Buah, Sayonara, Johor', 'Size: 3g per sachet Quantity: 1 sachet Packing: 1 sachet Milky flavored powdered coffee creamer.', 132, 1.75),
(8, 'Sugar Sachet', 'sugar-sachet.jpeg', 'Culinary', '0000-00-00 00:00:00.000000', 'Kampung Lama, Bandar Buah, Sayonara, Johor', 'Size: 3g per sachet Quantity: 1 sachet Packing: 1 sachet Sugar for coffee.', 92, 1.75),
(9, 'Blue Jersey', 'jersey.jpeg', 'Accessory', '0000-00-00 00:00:00.000000', 'Bandar Sungai, Laut China Utara, GG, Yan, Terengganu', 'Explore Zul Amirul\'s board \"Blue Jersey\" on Pinterest. See more ideas about sports shirts, jersey, sport shirt design.', 12, 100),
(10, 'Turquoise Corporate Shirt', 'turquoise-corporate-shirt.jpeg', 'Accessory', '0000-00-00 00:00:00.000000', 'Gerambit, Maju Jaya, Amangagal, Singapura', 'Light Blue, Light Grey, Light Pink, Maroon, Navy, Orange, Royal Blue, Turquoise. +14 More - Performance Dri-Fit T-Shirt (UDF01).', 6, 55),
(11, 'Black T-Shirt', 't-shirt.jpeg', 'Accessory', '0000-00-00 00:00:00.000000', 'Gerambit, Maju Jaya, Amangagal, Singapura', 'Men\'s Eversoft Cotton T-Shirts, Breathable & Moisture Wicking with Odor Control, Sizes S-4XL', 24, 25),
(12, 'Pencil', 'pencil.jpeg', 'Stationery', '0000-00-00 00:00:00.000000', 'Kaitel, Markosa, Jalan Ketimbang, Kuala Lumpur', 'This black barrel hexagonal Pencil 1323 is a quality pencil with a 2B lead for writing and sketching.', 45, 2),
(13, 'Black Pencil Box', 'pencil-case.jpeg', 'Stationery', '0000-00-00 00:00:00.000000', 'Lumpur Halus, Pasir Basah, Kota Lama, Negeri Sembilan', 'Water repellent pencil case Color black size 22cm×8cm', 3, 4.29);

-- --------------------------------------------------------

--
-- Table structure for table `user_tbl`
--

CREATE TABLE `user_tbl` (
  `user_id` int(11) NOT NULL,
  `user_name` varchar(100) NOT NULL,
  `user_email` varchar(100) NOT NULL,
  `user_phone` varchar(20) NOT NULL,
  `user_password` varchar(80) NOT NULL,
  `user_datereg` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `user_tbl`
--

INSERT INTO `user_tbl` (`user_id`, `user_name`, `user_email`, `user_phone`, `user_password`, `user_datereg`) VALUES
(1, 'uuu', 'u@gmail.com', '0115703', '12345678', '2024-11-20 23:26:03'),
(2, 'Umair', 'umair1211@gmail.com', '01157033208', '7c222fb2927d828af22f592134e8932480637c0d', '2024-11-27 15:25:24'),
(3, 'Siti Azwah', 'meim48@gmail.com', '01318283828', '88ea39439e74fa27c09a4fc0bc8ebe6d00978392', '2024-11-27 15:39:31'),
(11, 'Umair Suhaimee', 'umair@gmail.com', '01157990283', '7c222fb2927d828af22f592134e8932480637c0d', '2024-12-04 17:23:43'),
(12, 'Haiwan', 'apa@gmail.com', '01128288288', '7c222fb2927d828af22f592134e8932480637c0d', '2024-12-07 22:50:26'),
(13, 'Mohammed Umair', 'um@gmail.com', '0129384756', '7c222fb2927d828af22f592134e8932480637c0d', '2024-12-15 16:42:12');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cart_tbl`
--
ALTER TABLE `cart_tbl`
  ADD PRIMARY KEY (`cart_id`);

--
-- Indexes for table `events_tbl`
--
ALTER TABLE `events_tbl`
  ADD PRIMARY KEY (`event_id`);

--
-- Indexes for table `membership_purchase_tbl`
--
ALTER TABLE `membership_purchase_tbl`
  ADD PRIMARY KEY (`purchase_id`),
  ADD KEY `membership_purchase_tbl_ibfk_1` (`user_id`),
  ADD KEY `membership_purchase_tbl_ibfk_2` (`membership_id`);

--
-- Indexes for table `membership_tbl`
--
ALTER TABLE `membership_tbl`
  ADD PRIMARY KEY (`membership_id`);

--
-- Indexes for table `news_tbl`
--
ALTER TABLE `news_tbl`
  ADD PRIMARY KEY (`news_id`);

--
-- Indexes for table `products_tbl`
--
ALTER TABLE `products_tbl`
  ADD PRIMARY KEY (`product_id`);

--
-- Indexes for table `user_tbl`
--
ALTER TABLE `user_tbl`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cart_tbl`
--
ALTER TABLE `cart_tbl`
  MODIFY `cart_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `events_tbl`
--
ALTER TABLE `events_tbl`
  MODIFY `event_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `membership_purchase_tbl`
--
ALTER TABLE `membership_purchase_tbl`
  MODIFY `purchase_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `membership_tbl`
--
ALTER TABLE `membership_tbl`
  MODIFY `membership_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `news_tbl`
--
ALTER TABLE `news_tbl`
  MODIFY `news_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `products_tbl`
--
ALTER TABLE `products_tbl`
  MODIFY `product_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `user_tbl`
--
ALTER TABLE `user_tbl`
  MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `membership_purchase_tbl`
--
ALTER TABLE `membership_purchase_tbl`
  ADD CONSTRAINT `membership_purchase_tbl_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user_tbl` (`user_id`),
  ADD CONSTRAINT `membership_purchase_tbl_ibfk_2` FOREIGN KEY (`membership_id`) REFERENCES `membership_tbl` (`membership_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
