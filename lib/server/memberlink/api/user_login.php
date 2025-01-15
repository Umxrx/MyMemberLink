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
$sqllogin = "SELECT * FROM `user_tbl` WHERE `user_email` = '$email' AND `user_password` = '$password'";
$result = $conn->query($sqllogin); // Execute the query

// Check if any rows were returned (i.e., if the email exists)
if ($result->num_rows > 0) {
    // Email already exists
    $userlist = array();
    while ($row = $result->fetch_assoc()) {
        $userlist['user_id'] = $row['user_id'];
        $userlist['user_name'] = $row['user_name'];
        $userlist['user_email'] = $row['user_email'];
        $userlist['user_password'] = $_POST['password'];
        $userlist['user_phone'] = $row['user_phone'];
        $userlist['user_datereg'] = $row['user_datereg'];
    }
    $response = array('status' => 'success', 'data' => $userlist);
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