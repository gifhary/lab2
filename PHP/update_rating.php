<?php
error_reporting(0);
include_once("dbConnect.php");
$job_id = $_POST['job_id'];
$rating = $_POST['job_rating'];

$sql = "UPDATE job SET job_rating = '$rating' WHERE job_id = '$job_id'";
if ($conn->query($sql) === TRUE) {
            echo "success";
        } else {
            echo "error";
        }
$conn->close();
?>