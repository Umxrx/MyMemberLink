<?php

if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("db.php");
$username = $_POST['username'];
$email = $_POST['email'];
$userphone = $_POST['userphone'];
$password = sha1($_POST['password']);

$sqlinsert="INSERT INTO `user_tbl`(`user_name`, `user_email`, `user_phone`, `user_pass`) VALUES ('$username', '$email', '$userphone','$password')";

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