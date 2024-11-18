<?php

if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("db.php");
$email = $_POST['email'];

$sqlinsert="SELECT * FROM `user_tbl` WHERE `user_email` = '$email'";

$result = $conn->query($sqlinsert);

if ($result->num_rows > 0) {
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