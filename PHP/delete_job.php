<?php
error_reporting(0);
include_once("dbConnect.php");
$jobId = $_POST['job_id'];

$sql = "DELETE FROM job WHERE job_id = '$jobId'";

if ($conn->query($sql) === TRUE) {
  echo "success";
}else{
    echo "failed";
}
?>