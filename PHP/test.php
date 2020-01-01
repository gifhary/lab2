<?php
$host = 'https://billplz-sandbox.com/api/v3/bills';
$api_key = '6b544d08-262d-4db4-99b7-8388cf6c7d50';
$process = curl_init($host);

$data = array(
          'collection_id' => 'eiulvu33',
          'email' => 'gifhary@pickupandlaundry.com',
          'mobile' => null,
          'name' => 'gifhary',
          'amount' => 10 * 100, // RM20
		  'description' => 'Payment for order id 029485-dfg4543',
          'callback_url' => "http://pickupandlaundry.com/return_url",
          'redirect_url' => "http://pickupandlaundry.com/my_pickup/gifhary/payment_update.php?userid=gifhary@pickupandlaundry.com&mobile=0992841234&amount=10&orderid=029485-dfg4543" 
);

curl_setopt($process, CURLOPT_HEADER, 0);
curl_setopt($process, CURLOPT_USERPWD, $api_key . ":");
curl_setopt($process, CURLOPT_TIMEOUT, 30);
curl_setopt($process, CURLOPT_RETURNTRANSFER, 1);
curl_setopt($process, CURLOPT_SSL_VERIFYHOST, 0);
curl_setopt($process, CURLOPT_SSL_VERIFYPEER, 0);
curl_setopt($process, CURLOPT_POSTFIELDS, http_build_query($data) ); 


$return = curl_exec($process);
$bill = json_decode($return, true);
echo $bill['url'];
header("Location: {$bill['url']}");