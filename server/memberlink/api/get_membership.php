<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

header('Content-Type: application/json');

if (!isset($_GET['userid'])) {
    echo json_encode(['status' => 'failed', 'message' => 'User ID is required']);
    exit();
}

include_once("dbconnect.php");

$userid = intval($_GET['userid']);

$sql = "SELECT 
            m.membership_name, 
            m.membership_duration_month,
            p.purchase_date,
            DATE_ADD(p.purchase_date, INTERVAL m.membership_duration_month MONTH) as expiry_date
        FROM membership_purchase_tbl p 
        INNER JOIN membership_tbl m ON p.membership_id = m.membership_id 
        WHERE p.user_id = ? 
        AND p.payment_status = 'Success' 
        ORDER BY p.purchase_id DESC 
        LIMIT 1";

try {
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        throw new Exception("Prepare failed: " . $conn->error);
    }

    $stmt->bind_param('i', $userid);
    
    if ($stmt->execute()) {
        $result = $stmt->get_result();
        
        if ($result->num_rows > 0) {
            $row = $result->fetch_assoc();
            $stmt->close();
            
            // Format the dates
            $purchase_date = new DateTime($row['purchase_date']);
            $expiry_date = new DateTime($row['expiry_date']);
            
            echo json_encode([
                'status' => 'success',
                'membership_name' => $row['membership_name'],
                'expiry_date' => $expiry_date->format('Y-m-d')
            ]);
        } else {
            $stmt->close();
            echo json_encode([
                'status' => 'success',
                'membership_name' => 'No active membership',
                'expiry_date' => null
            ]);
        }
    } else {
        $stmt->close();
        throw new Exception("Execute failed: " . $stmt->error);
    }
    
} catch (Exception $e) {
    echo json_encode([
        'status' => 'failed',
        'message' => 'Database error: ' . $e->getMessage()
    ]);
}

$conn->close();
?>