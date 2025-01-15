<?php
if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");
$userid = intval($_POST['userid']);
$membershipid = intval($_POST['membershipid']);
$price = doubleval($_POST['membershipprice']);

$sqlinsert="INSERT INTO `membership_cart_tbl`(`user_id`, `membership_id`, `membership_price_RM`) VALUES ('$userid', '$membershipid', '$price');";

if ($conn->query($sqlinsert) === TRUE) {
	$response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
}
else {
	$response = array('status' => 'failed', 'data' => null);
	sendJsonResponse($response);
}
	

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}
?>