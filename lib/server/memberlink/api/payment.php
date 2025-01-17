<?php
$email = $_GET['email'];
$phone = $_GET['phone']; 
$name = $_GET['name']; 
$userid = $_GET['userid'];
$amount = $_GET['amount'];
$membershipId = isset($_GET['membershipId']) ? $_GET['membershipId'] : null;

$api_key = '41ede2d9-faf0-44b0-a04e-8b4884578602';
$collection_id = 'hjx3a2g9';
$host = 'https://www.billplz-sandbox.com/api/v3/bills';

// Build redirect URL with membership ID if present
$redirect_url = "https://feeyazproduction.com/memberlink_umair/memberlink/api/payment_update.php?userid=$userid&email=$email&phone=$phone&amount=$amount&name=$name";
if ($membershipId) {
    $redirect_url .= "&membershipId=$membershipId";
}

$data = array(
          'collection_id' => $collection_id,
          'email' => $email,
          'mobile' => $phone,
          'name' => $name,
          'amount' => ($amount) * 100,
          'description' => 'Payment for order by '.$name,
          'callback_url' => "https://feeyazproduction.com/memberlink_umair/memberlink/return_url",
          'redirect_url' => $redirect_url 
);

$process = curl_init($host );
curl_setopt($process, CURLOPT_HEADER, 0);
curl_setopt($process, CURLOPT_USERPWD, $api_key . ":");
curl_setopt($process, CURLOPT_TIMEOUT, 30);
curl_setopt($process, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($process, CURLOPT_SSL_VERIFYHOST, 0);
curl_setopt($process, CURLOPT_SSL_VERIFYPEER, 0);
curl_setopt($process, CURLOPT_POSTFIELDS, http_build_query($data)); 

$return = curl_exec($process);
curl_close($process);
$bill = json_decode($return, true);

// Check if the 'url' key exists and redirect
if (isset($bill['url'])) {
    header("Location: {$bill['url']}");
} else {
    echo "Error: No URL received from BillPlz.";
}
?>