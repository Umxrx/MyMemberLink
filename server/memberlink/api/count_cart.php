<?php

if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");
$userid = (int)$_POST['userid'];

$sqlcheck = "SELECT * FROM `cart_tbl` WHERE `user_id` = $userid";

$result = $conn->query($sqlcheck);
$itemcount = $result->num_rows;

if ($itemcount > 0) {

    $response = array('status' => 'success', 'data' => $itemcount);
} else {

    $response = array('status' => 'failed', 'data' => null);
}

sendJsonResponse($response);

// Function to send a JSON response
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>