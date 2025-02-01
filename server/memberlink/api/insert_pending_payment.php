<?php
include_once("dbconnect.php");

if (!isset($_POST['user_id']) || !isset($_POST['membership_id']) || !isset($_POST['amount'])) {
    sendResponse('failed', 'Missing required parameters');
    exit();
}

$userId = $_POST['user_id'];
$membershipId = $_POST['membership_id'];
$amount = $_POST['amount'];
$receiptId = generateReceiptId();
$status = 'Pending';

// Insert pending purchase
$stmt = $conn->prepare("INSERT INTO membership_purchase_tbl (user_id, membership_id, receipt_id, amount, payment_status) VALUES (?, ?, ?, ?, ?)");
$stmt->bind_param("iisds", $userId, $membershipId, $receiptId, $amount, $status);

if ($stmt->execute()) {
    $purchaseId = $conn->insert_id;
    sendResponse('success', 'Pending purchase created', [
        'purchase_id' => $purchaseId,
        'receipt_id' => $receiptId
    ]);
} else {
    sendResponse('failed', 'Failed to create pending purchase');
}

function generateReceiptId() {
    return 'RCP' . date('YmdHis') . rand(1000, 9999);
}

function sendResponse($status, $message, $data = null) {
    $response = [
        'status' => $status,
        'message' => $message
    ];
    if ($data) {
        $response['data'] = $data;
    }
    echo json_encode($response);
}
?> 