<?php
include_once("dbconnect.php");

if (!isset($_GET['membership_name'])) {
    echo json_encode([
        'status' => 'failed',
        'message' => 'Membership name is required'
    ]);
    exit;
}

$membership_name = $_GET['membership_name'];

$sql = "SELECT * FROM `membership_tbl` WHERE `membership_name` = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $membership_name);

if ($stmt->execute()) {
    $result = $stmt->get_result();

    $membershiparray['membership'] = array();
    while ($row = $result->fetch_assoc()) {
        $membership = array();
        $membership['membership_id'] = strval($row['membership_id']);
        $membership['membership_name'] = $row['membership_name'];
        $membership['membership_description'] = $row['membership_description'];
        $membership['membership_price_RM'] = strval($row['membership_price_RM']);
        $membership['membership_duration_month'] = strval($row['membership_duration_month']);
        array_push($membershiparray['membership'], $membership);
    }
    $response = array('status' => 'success', 'data' => $membershiparray);
    sendJsonResponse($response);
}else{
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}
	
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>