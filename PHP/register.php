<?php
error_reporting(0);
include_once ("dbConnect.php");
$email = $_POST['email'];
$password = sha1($_POST['password']);
$phone = $_POST['phone'];
$name = $_POST['name'];
$encoded_string = $_POST["encoded_string"];
$decoded_string = base64_decode($encoded_string);
$sqlinsert = "INSERT INTO user_provider(user_email, user_name, user_password, user_phone, verify) VALUES ('$email','$name','$password','$phone','0')";

//empty string value in sha1 encryption
$empty_string = "da39a3ee5e6b4b0d3255bfef95601890afd80709";
if($empty_string == $password){
    echo "password empty error";
    exit();
}

$checkEmail = "SELECT user_email FROM user_provider WHERE user_email = '$email'";
$result = $conn->query($checkEmail);


if($result->num_rows == 0){
    if ($conn->query($sqlinsert) === TRUE) {
        $path = 'profile/'.$email.'.jpg';
        file_put_contents($path, $decoded_string);
        sendEmail($email);
        echo "success";
    } else {
        echo "failed";
    }
} else {
    echo "use another email";
}



function sendEmail($email) {
    $to      = $email; 
    $subject = 'Verification for MyPickup'; 
    $message = 'Please confirm your email using link bellow' . "\r\n \r\n" . 'http://pickupandlaundry.com/my_pickup/gifhary/verify.php?email='.$email;

    $headers = 'From: noreply_mypickup@pickupandlaundry.com' . "\r\n" . 
    'Reply-To: '.$email . "\r\n" . 
    'X-Mailer: PHP/' . phpversion(); 
    mail($to, $subject, $message, $headers);
}
?>