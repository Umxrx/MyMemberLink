<?php

include_once("dbconnect.php");

$results_per_page = 10;
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
    $cartarray['cart'] = array();
    $cartarray['product'] = array();
    while ($row = $result->fetch_assoc()) {
        $prod_id = $row['product_id'];
        $cart = array();
        $cart['cart_id'] = $row['cart_id'];
        $cart['user_id'] = $row['user_id'];
        $cart['product_id'] = $prod_id;
        $cart['product_quantity'] = $row['product_quantity'];
        $cart['cart_timestamp'] = $row['cart_timestamp'];
        array_push($cartarray['cart'], $cart);

        $sqlloadproduct = "SELECT * FROM `products_tbl` WHERE `product_id` = $prod_id";
        $result2 = $conn->query($sqlloadproduct);

        if ($result2->num_rows > 0) {
            while ($row = $result2->fetch_assoc()) {
                $product = array();
                $product['product_id'] = $prod_id;
                $product['product_name'] = $row['product_name'];
                $product['product_description'] = $row['product_description'];
                $product['product_category'] = $row['product_category'];
                $product['product_location'] = $row['product_location'];
                $product['product_filename'] = $row['product_filename'];
                $product['product_date'] = $row['product_date'];
                $product['product_quantity'] = $row['product_quantity'];
                $product['product_price'] = $row['product_price'];
                array_push($cartarray['product'], $product);
            }
        }
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