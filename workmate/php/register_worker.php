<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(['status' => 'failed', 'data' => null]);
    exit;
}

include_once("dbconnect.php");

$name = $_POST['name'];
$email = $_POST['email'];
$password = sha1($_POST['password']);
$phone = $_POST['phone'];
$address = $_POST['address'];

$sqlinsert = "INSERT INTO `workers`(`full_name`, `email`, `password`, `phone`, `address`) VALUES ('$name','$email','$password','$phone','$address')";

try {
    if ($conn->query($sqlinsert) === TRUE) {
        sendJsonResponse(['status' => 'success', 'data' => null]);
    } else {
        sendJsonResponse(['status' => 'failed', 'data' => null]);
    }
} catch (Exception $e) {
    sendJsonResponse(['status' => 'failed', 'data' => null]);
}

function sendJsonResponse($sentArray) {
    echo json_encode($sentArray);
    
}

?>
