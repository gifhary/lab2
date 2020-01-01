<?php
error_reporting(0);
include_once("dbConnect.php");
$email = $_POST['email'];
$password = $_POST['password'];
$passwordsha = sha1($password);

$sql = "SELECT * FROM user_provider WHERE user_email = '$email' AND user_password = '$passwordsha'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
    $row = $result ->fetch_assoc();
    echo json_encode($row);
}else{
    echo "failed";
}