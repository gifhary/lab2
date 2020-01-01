<!DOCTYPE html>
<html>
<head><meta http-equiv="Content-Type" content="text/html; charset=utf-8">

	<title>Email Verification</title>
	
	<style>
body {
  font-family: calibri;
  background: #e4e4e4;
}.header {
  width: 30%;
  margin: 50px auto 0px;
  color: white;
  background: #5F9EA0;
  text-align: center;
  border: 1px solid #B0C4DE;
  border-bottom: none;
  border-radius: 10px 10px 0px 0px;
  padding: 20px;
}.content {
  width: 30%;
  margin: 0px auto;
  color: #666666;
  padding: 20px;
  border: 1px solid #c0c0c0;
  background: white;
  border-radius: 0px 0px 10px 10px;
}.btn {
  width: 100%;
  padding: 10px;
  font-size: 15px;
  color: white;
  background: #5F9EA0;
  border: none;
  border-radius: 5px;
}.btn:hover{
  background:#808080;
}.btn:active{
	background:#333;
}
	
	</style>
</head>

<body>
	<div class='header'>
		<h1>Verify Your Email</h1>
	</div>
	
	<div class='content' method='post'>
		<h3>
          Thankyou for joining us
      </h3>
      <h4>
        Please verify your email address using this button
      </h4>
	<form method="post">
	    <input type = 'submit' class='btn' name='verify' value='Verify' />
	</form>
  </div>
  
  <?php
    error_reporting(0);
    include_once("dbConnect.php");
    $email = $_GET['email'];

    $sql = "UPDATE user_provider SET verify = '1' WHERE user_email = '$email'";
    
    if(isset($_POST['verify'])) { 
        if ($conn->query($sql) === TRUE) {
            echo "<script type='text/javascript'>alert('Success');</script>";
            exit();
        } else {
            echo "<script type='text/javascript'>alert('Error');</script>";
            exit();
        }
    }

    $conn->close();
  ?>
</body>
</html>
