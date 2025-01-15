<?php
//error_reporting(0);
include_once("dbconnect.php");
$userid = $_GET['userid'];
$phone = $_GET['phone'];
$amount = $_GET['amount'];
$email = $_GET['email'];
$name = $_GET['name'];

$data = array(
    'id' =>  $_GET['billplz']['id'],
    'paid_at' => $_GET['billplz']['paid_at'] ,
    'paid' => $_GET['billplz']['paid'],
    'x_signature' => $_GET['billplz']['x_signature']
);

$paidstatus = $_GET['billplz']['paid'];
if ($paidstatus=="true"){
    $paidstatus = "Success";
}else{
    $paidstatus = "Failed";
}

$receiptid = $_GET['billplz']['id'];
$signing = '';
foreach ($data as $key => $value) {
    $signing.= 'billplz'.$key . $value;
    if ($key === 'paid') {
        break;
    } else {
        $signing .= '|';
    }
}
 
$signed= hash_hmac('sha256', $signing, '94d737a89cc4562daf98f4dc81f2b5b6c334ac073a2cfc966a73938e1ed8e7f7faf05791900e95b1dc865dcb5105eda1f8ccca89245670d6ad2028a321e4efd2');
if ($signed === $data['x_signature']) {
    if ($paidstatus == "Success") {
        // Insert purchase record
        $sqlinsertpurchase = "INSERT INTO `membership_purchase_tbl` 
            (`user_id`, `membership_id`, `receipt_id`, `amount`, `payment_status`) 
            VALUES (?, ?, ?, ?, ?)";
            
        $stmt = $conn->prepare($sqlinsertpurchase);
        $stmt->bind_param("iisds", $userid, $membershipId, $receiptid, $amount, $paidstatus);
        
        if (!$stmt->execute()) {
            error_log("Failed to insert purchase: " . $stmt->error);
        }
        
        // Get membership details
        $sqlmembership = "SELECT * FROM membership_tbl WHERE membership_id = ?";
        $stmt = $conn->prepare($sqlmembership);
        $stmt->bind_param("i", $membershipId);
        $stmt->execute();
        $result = $stmt->get_result();
        $membership = $result->fetch_assoc();

        // Format the dates
        $purchaseDate = date("d M Y, h:i A");
        $expiryDate = date("d M Y", strtotime("+{$membership['membership_duration_month']} months"));

        echo "
        <!DOCTYPE html>
        <html>
        <head>
            <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
            <link rel=\"stylesheet\" href=\"https://www.w3schools.com/w3css/4/w3.css\">
            <style>
                body { font-family: Arial, sans-serif; background-color: #f5f5f5; }
                .receipt-container { 
                    max-width: 600px; 
                    margin: 20px auto; 
                    background: white;
                    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                    border-radius: 8px;
                }
                .receipt-header {
                    background-color: #463F3A;
                    color: white;
                    padding: 20px;
                    text-align: center;
                    border-radius: 8px 8px 0 0;
                }
                .receipt-content { padding: 20px; }
                .company-info {
                    text-align: center;
                    margin-bottom: 20px;
                    padding-bottom: 20px;
                    border-bottom: 1px dashed #ddd;
                }
                .receipt-details {
                    margin: 20px 0;
                    border-bottom: 1px dashed #ddd;
                    padding-bottom: 20px;
                }
                .membership-details {
                    margin: 20px 0;
                    padding: 15px;
                    background: #f9f9f9;
                    border-radius: 4px;
                }
                .total-amount {
                    font-size: 24px;
                    text-align: right;
                    padding: 20px;
                    background: #f9f9f9;
                    border-radius: 4px;
                }
                .status-paid { color: #4CAF50; }
                .status-failed { color: #f44336; }
                .footer {
                    text-align: center;
                    padding: 20px;
                    color: #666;
                    font-size: 14px;
                }
            </style>
        </head>
        <body>
            <div class='receipt-container'>
                <div class='receipt-header'>
                    <h2 style='margin:0;'>PAYMENT RECEIPT</h2>
                    <p style='margin:5px 0 0;'>Receipt ID: $receiptid</p>
                </div>
                
                <div class='receipt-content'>
                    <div class='company-info'>
                        <img src='../assets/logo/logoMM.png' style='width:80px; margin-bottom:10px;'>
                        <h3 style='margin:0;'>MyMemberLink</h3>
                        <p style='color:#666; margin:5px 0;'>123 Business Street, City, State 12345</p>
                    </div>

                    <div class='receipt-details'>
                        <table class='w3-table'>
                            <tr>
                                <td><strong>Date:</strong></td>
                                <td>$purchaseDate</td>
                            </tr>
                            <tr>
                                <td><strong>Name:</strong></td>
                                <td>$name</td>
                            </tr>
                            <tr>
                                <td><strong>Email:</strong></td>
                                <td>$email</td>
                            </tr>
                            <tr>
                                <td><strong>Phone:</strong></td>
                                <td>$phone</td>
                            </tr>
                        </table>
                    </div>

                    <div class='membership-details'>
                        <h4 style='margin-top:0;'>Membership Details</h4>
                        <table class='w3-table'>
                            <tr>
                                <td><strong>Plan:</strong></td>
                                <td>{$membership['membership_name']}</td>
                            </tr>
                            <tr>
                                <td><strong>Description:</strong></td>
                                <td>{$membership['membership_desc']}</td>
                            </tr>
                            <tr>
                                <td><strong>Duration:</strong></td>
                                <td>{$membership['membership_duration']} months</td>
                            </tr>
                            <tr>
                                <td><strong>Valid Until:</strong></td>
                                <td>$expiryDate</td>
                            </tr>
                            <tr>
                                <td><strong>Benefits:</strong></td>
                                <td>{$membership['membership_benefits']}</td>
                            </tr>
                        </table>
                    </div>

                    <div class='total-amount'>
                        <table class='w3-table'>
                            <tr>
                                <td><strong>Total Amount:</strong></td>
                                <td><strong>RM$amount</strong></td>
                            </tr>
                            <tr>
                                <td><strong>Status:</strong></td>
                                <td class='" . ($paidstatus == 'success' ? 'status-paid' : 'status-failed') . "'>
                                    <strong>" . strtoupper($paidstatus) . "</strong>
                                </td>
                            </tr>
                        </table>
                    </div>

                    <div class='footer'>
                        <p>Thank you for your business!</p>
                        <p style='margin:5px 0;'>For support: help@mymemberlink.com</p>
                        <p style='margin:5px 0;'>Terms and Conditions Apply</p>
                    </div>
                </div>
            </div>
        </body>
        </html>";
    } else {
        // Insert failed purchase record
        $sqlinsertpurchase = "INSERT INTO `membership_purchase_tbl` 
            (`user_id`, `membership_id`, `receipt_id`, `amount`, `payment_status`) 
            VALUES (?, ?, ?, ?, ?)";
            
        $stmt = $conn->prepare($sqlinsertpurchase);
        $stmt->bind_param("iisds", $userid, $membershipId, $receiptid, $amount, $paidstatus);
        
        if (!$stmt->execute()) {
            error_log("Failed to insert purchase: " . $stmt->error);
        }
        
        // Print receipt for failed transaction
        echo "
        <html>
            <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
            <link rel=\"stylesheet\" href=\"https://www.w3schools.com/w3css/4/w3.css\">
            <body>
                <center><h4>Receipt</h4></center>
                <table class='w3-table w3-striped'>
                    <th>Item</th><th>Description</th>
                    <tr><td>Receipt</td><td>$receiptid</td></tr>
                    <tr><td>Name</td><td>$name</td></tr>
                    <tr><td>Email</td><td>$email</td></tr>
                    <tr><td>Phone</td><td>$phone</td></tr>
                    <tr><td>Paid</td><td>RM$amount</td></tr>
                    <tr><td>Paid Status</td><td class='w3-text-red'>$paidstatus</td></tr>
                </table><br>
            </body>
        </html>";
    }
} else {
    // Invalid signature, do not process the payment
    echo "Invalid signature.";
}
?>