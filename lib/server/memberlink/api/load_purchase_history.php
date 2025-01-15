<?php
include_once("dbconnect.php");

if (!isset($_GET['userid'])) {
    echo json_encode([
        'status' => 'failed',
        'message' => 'User ID is required'
    ]);
    exit;
}

$userid = $_GET['userid'];

$sql = "SELECT p.*, m.membership_name, m.membership_desc, u.user_name, u.user_email, u.user_phoneNum 
        FROM membership_purchase_tbl p
        LEFT JOIN membership_tbl m ON p.membership_id = m.membership_id
        LEFT JOIN user_tbl u ON p.user_id = u.user_id
        WHERE p.user_id = ?
        ORDER BY p.purchase_date DESC";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $userid);

if ($stmt->execute()) {
    $result = $stmt->get_result();
    $purchases = [];
    
    while ($row = $result->fetch_assoc()) {
        $purchases[] = [
            'purchase_id' => $row['purchase_id'],
            'membership_name' => $row['membership_name'],
            'membership_desc' => $row['membership_desc'],
            'receipt_id' => $row['receipt_id'],
            'amount' => $row['amount'],
            'payment_status' => $row['payment_status'],
            'purchase_date' => $row['purchase_date'],
            'user_name' => $row['user_name'],
            'user_email' => $row['user_email'],
            'user_phone' => $row['user_phone']
        ];
    }
    
    echo json_encode([
        'status' => 'success',
        'data' => $purchases
    ]);
} else {
    echo json_encode([
        'status' => 'failed',
        'message' => 'Failed to load purchase history'
    ]);
}

$stmt->close();
$conn->close();
?>