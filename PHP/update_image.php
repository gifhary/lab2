<?php
error_reporting(0);
$email = $_POST['email'];

$encoded_string = $_POST["encoded_string"];
$decoded_string = base64_decode($encoded_string);

if($email === null or $email === ""){
    echo "special error";
} else {
$path = 'profile/'.$email.'.jpg';
$result = file_put_contents($path, $decoded_string);

if($result === false){
    echo "error";
}else{
    echo "success";
}
}

?>