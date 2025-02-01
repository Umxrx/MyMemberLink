<?php
include_once("dbconnect.php");

$sqlloadmembership= "SELECT * FROM `membership_tbl`";
$result = $conn->query($sqlloadmembership);

if ($result->num_rows > 0) {
    $membershiparray['membership'] = array();
    while ($row = $result->fetch_assoc()) {
        $membership = array();
        $membership['membership_id'] = $row['membership_id'];
        $membership['membership_name'] = $row['membership_name'];
        $membership['membership_description'] = $row['membership_description'];
        $membership['membership_price_RM'] = $row['membership_price_RM'];
        $membership['membership_duration_month'] = $row['membership_duration_month'];
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