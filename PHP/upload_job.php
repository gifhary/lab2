<?php
error_reporting(0);
include_once ("dbConnect.php");

$jobname = $_POST['job_name'];
$jobprice = $_POST['job_price'];
$jobdesc = $_POST['job_desc'];
$joblocnames = $_POST['job_loc_names'];
$joblocation = $_POST['job_location'];
$jobdestination = $_POST['job_destination'];
$email = $_POST['email'];
$jobdate =  date('dmYhis');

$sqlinsert = "INSERT INTO job(job_name,job_price,job_desc,job_loc_names,job_location,job_destination,user_email,job_date) VALUES ('$jobname','$jobprice','$jobdesc','$joblocnames','$joblocation','$jobdestination','$email','$jobdate')";

if ($conn->query($sqlinsert) === TRUE) {
    echo "success";
} else {
    echo "failed";
}
?>