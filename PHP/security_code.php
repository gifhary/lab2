<?php
error_reporting(0);
include_once("dbConnect.php");
$email = $_POST['email'];

$number = rand(1111,9999);
$stringNum = (string)$number;

$subject = 'Password reset security code';
$message = 'Use this security code to reset your password'. "\r\n" .$stringNum;
$headers = 'From: noreply_mypickup@pickupandlaundry.com' . "\r\n" . 
    'Reply-To: '.$useremail . "\r\n" . 
    'X-Mailer: PHP/' . phpversion();
    
$sql = "SELECT * FROM user_provider WHERE user_email = '$email'";
$result = $conn->query($sql);

if ($result->num_rows > 0) {
    mail($email, $subject, $message, $headers);
    echo $stringNum;
}else{
    echo "error";
}
?>