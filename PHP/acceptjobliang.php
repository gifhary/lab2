<?php
error_reporting(0);
include_once("dbConnect.php");
$job_id = $_POST['job_id'];
$email = $_POST['email'];

$sql = "UPDATE job SET driver_email = '$email'  WHERE job_id = '$job_id'";
if ($conn->query($sql) === TRUE) {
            echo "success";
        } else {
            echo "error";
        }
$conn->close();
?>
