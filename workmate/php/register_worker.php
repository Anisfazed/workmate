<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(['status' => 'failed', 'data' => null]);
    exit;
}

include_once("dbconnect.php");

$name = $_POST['full_name'];
$email = $_POST['email'];
$password = sha1($_POST['password']);
$phone = $_POST['phone'];
$address = $_POST['address'];
$image_base64 = $_POST['image'];
$image_filename = "";

if ($image_base64 != "") {
    $image_filename = $email . ".png";
    $image_path = "../assets/images/" . $image_filename;
    file_put_contents($image_path, base64_decode($image_base64));
}

$sqlinsert = "INSERT INTO `workers`(`full_name`, `email`, `password`, `phone`, `address`, `image`)
VALUES ('$name','$email','$password','$phone','$address','$image_filename')";

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
