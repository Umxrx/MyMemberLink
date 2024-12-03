<?php

if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");
$email = $_POST['email'];
$password = sha1($_POST['password']);

// SQL query to check if a user with the provided email and hashed password exists in `tbl_admins`
$sqllogin = "SELECT `user_email`, `user_password` FROM `user_tbl` WHERE `user_email` = '$email' AND `user_pass` = '$password'";
$result = $conn->query($sqllogin); // Execute the query

// Check if any rows were returned (i.e., if the email exists)
if ($result->num_rows > 0) {
    // Email already exists
    $response = array('status' => 'success', 'data' => null);
} else {
    // Email does not exist
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