<?php

if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");
$userid = $_POST['userid'];
$productid = $_POST['productid'];

$sqlcheck = "SELECT * FROM `cart_tbl` WHERE `user_id` = $userid AND `product_id` = $productid";

$result = $conn->query($sqlcheck);

if ($result->num_rows > 0) {
    // Product already exists
    $cartarray['cart'] = array();
    while ($row = $result->fetch_assoc()) {
        $cart = array();
        $cart['product_quantity'] = $row['product_quantity'];
        array_push($cartarray['cart'], $cart);
    }
    $response = array('status' => 'success', 'data' => $cartarray);
} else {
    // Product does not exist
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