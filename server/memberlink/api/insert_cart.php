<?php

if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");
$userid = $_POST['userid'];
$productid = $_POST['productid'];

$sqlinsert="INSERT INTO `cart_tbl`(`user_id`, `product_id`) VALUES ('$userid', '$productid');";

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