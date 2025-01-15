<?php

include_once("dbconnect.php");

$results_per_page = 20;
if (isset($_GET['pageno'])){
	$pageno = (int)$_GET['pageno'];
}else{
	$pageno = 1;
}
if (isset($_GET['userid'])){
	$userid = $_GET['userid'];
}else{
	$userid = '';
}

$page_first_result = ($pageno - 1) * $results_per_page;

$sqlloadcart = "SELECT * FROM `cart_tbl` WHERE `user_id` = $userid ORDER BY `cart_timestamp` DESC";
$result = $conn->query($sqlloadcart);
$number_of_result = $result->num_rows;

$number_of_page = ceil($number_of_result / $results_per_page);
$sqlloadcart = $sqlloadcart." LIMIT $page_first_result, $results_per_page";

$result = $conn->query($sqlloadcart);
if ($result->num_rows > 0) {
    $cartarray['user_products'] = array();
    while ($row = $result->fetch_assoc()) {
        $cart = array();
        $cart['product_id'] = $row['product_id'];
        $cart['product_quantity'] = $row['product_quantity'];
        $cart['cart_timestamp'] = $row['cart_timestamp'];
        array_push($cartarray['user_products'], $cart);
    }
    $response = array('status' => 'success', 'data' => $cartarray,'numofpage'=>$number_of_page,'numberofresult'=>$number_of_result);
    sendJsonResponse($response);
}else{
    $response = array('status' => 'failed', 'data' => null, 'numofpage'=>$number_of_page,'numberofresult'=>$number_of_result);
    sendJsonResponse($response);
}
	
	
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>