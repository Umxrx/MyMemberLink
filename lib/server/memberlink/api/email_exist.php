<?php

if (!isset($_POST)) {
	$response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die;
}

include_once("dbconnect.php");
$email = $_POST['email'];

// Prepare and execute SQL query to check if the email exists in `tbl_users`
$sqlcheck = "SELECT * FROM `user_tbl` WHERE `user_email` = ?";
$stmt = $conn->prepare($sqlcheck);
$stmt->bind_param("s", $email);
$stmt->execute();
$result = $stmt->get_result();

// Check if any rows were returned (i.e., if the email exists)
if ($result->num_rows > 0) {
    // Email already exists
    $response = array('status' => 'success', 'data' => 'Email already registered');
} else {
    // Email does not exist
    $response = array('status' => 'failed', 'data' => 'Email is available');
}

sendJsonResponse($response);

// Function to send a JSON response
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>