<?php
error_reporting(0);
include_once("dbConnect.php");
$email = $_POST['email'];
$newPassword = $_POST['newPassword'];
$newPasswordsha = sha1($newPassword);

$sql = "UPDATE user_provider SET user_password = '$newPasswordsha' WHERE user_email = '$email'";
if ($conn->query($sql) === TRUE) {
            echo "success";
        } else {
            echo "error";
        }
$conn->close();
?>