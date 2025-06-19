<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(['status' => 'failed', 'message' => 'Invalid request method']);
    exit;
}

include_once("dbconnect.php");

$name = $_POST['full_name'] ?? '';
$email = $_POST['email'] ?? '';
$password = sha1($_POST['password'] ?? '');
$phone = $_POST['phone'] ?? '';
$address = $_POST['address'] ?? '';
$image_base64 = $_POST['image'] ?? '';
$image_filename = "";

// Basic validation
if (empty($name) || empty($email) || empty($password)) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Missing required fields']);
    exit;
}

// Check if email already exists
$check_sql = "SELECT * FROM tbl_users WHERE email = '$email'";
$result = $conn->query($check_sql);

if ($result && $result->num_rows > 0) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Email already registered']);
    exit;
}

// Handle image upload
if (!empty($image_base64)) {
    $image_filename = $email . ".png";
    $image_path = "../assets/images/" . $image_filename;

    $decoded_image = base64_decode($image_base64);
    if (!$decoded_image || file_put_contents($image_path, $decoded_image) === false) {
        sendJsonResponse(['status' => 'failed', 'message' => 'Image upload failed']);
        exit;
    }
}

// Insert user data
$sqlinsert = "INSERT INTO `tbl_users` (`name`, `email`, `password`, `phone`, `address`, `image`)
VALUES ('$name','$email','$password','$phone','$address','$image_filename')";

if ($conn->query($sqlinsert) === TRUE) {
    sendJsonResponse(['status' => 'success', 'message' => 'Registration successful']);
} else {
    sendJsonResponse(['status' => 'failed', 'message' => 'Database insert error']);
}

function sendJsonResponse($sentArray) {
    echo json_encode($sentArray);
}
?>
