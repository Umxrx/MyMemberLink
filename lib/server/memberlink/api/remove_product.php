<?php
if (!isset($_POST)) {
    $response = array( 'status' => 'failed', 'data' => null );
    sendJsonResponse( $response );
    die;
}

include_once( 'dbconnect.php' );
$cartid = (int)$_POST['cartid'];

$sqldeletecart = "DELETE FROM `cart_tbl` WHERE `cart_id` = $cartid";

if ($conn->query($sqldeletecart) === TRUE) {
    $response = array('status' => 'success', 'data' => $sqldeletecart);
    sendJsonResponse($response);
} else {
    $response = array('status' => 'failed', 'data' => $sqldeletecart);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray)
 {
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>