<?php

include_once("dbconnect.php");

$results_per_page = 10;
if (isset($_GET['pageno'])){
	$pageno = (int)$_GET['pageno'];
}else{
	$pageno = 1;
}

$page_first_result = ($pageno - 1) * $results_per_page;

$sqlloadproducts = "SELECT * FROM `products_tbl` ORDER BY `product_date` DESC";
$result = $conn->query($sqlloadproducts);
$number_of_result = $result->num_rows;

$number_of_page = ceil($number_of_result / $results_per_page);
$sqlloadproducts = $sqlloadproducts." LIMIT $page_first_result, $results_per_page";

$result = $conn->query($sqlloadproducts);
// `product_id`, `product_title`, `product_description`, `product_startdate`, `product_enddate`, `product_type`, `product_location`, `product_filename`, `product_date`
if ($result->num_rows > 0) {
    $productsarray['products'] = array();
    while ($row = $result->fetch_assoc()) {
        $product = array();
        $product['product_id'] = $row['product_id'];
        $product['product_name'] = $row['product_name'];
        $product['product_description'] = $row['product_description'];
        $product['product_category'] = $row['product_category'];
        $product['product_location'] = $row['product_location'];
        $product['product_filename'] = $row['product_filename'];
        $product['product_date'] = $row['product_date'];
        $product['product_quantity'] = $row['product_quantity'];
        $product['product_price'] = $row['product_price'];
        array_push($productsarray['products'], $product);
    }
    $response = array('status' => 'success', 'data' => $productsarray,'numofpage'=>$number_of_page,'numberofresult'=>$number_of_result);
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