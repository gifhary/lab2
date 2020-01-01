<?php
$servername = "localhost";
$username 	= "pickupan_mypickupadmin";
$password 	= "gifhary97";
$dbname 	= "pickupan_my_pickup";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>