<?php
if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");
$userid = (int)$_POST['userid'];
$productid = (int)$_POST['productid'];

$sqlupdatecart="UPDATE `cart_tbl` SET `product_quantity`= `product_quantity` + 1 WHERE `user_id` = $userid AND `product_id` = $productid";

if ($conn->query($sqlupdatecart) === TRUE) {
	$response = array('status' => 'success', 'data' => $sqlupdatecart);
    sendJsonResponse($response);
}else{
	$response = array('status' => 'failed', 'data' => $sqlupdatecart);
	sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>