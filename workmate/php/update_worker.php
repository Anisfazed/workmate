<?php
include_once("dbconnect.php");

$worker_id = $_POST['worker_id'] ?? '';
$full_name = $_POST['full_name'] ?? '';
$phone = $_POST['phone'] ?? '';
$address = $_POST['address'] ?? '';
$image_base64 = $_POST['image'] ?? '';
$image_filename = '';

// Basic validation
if (empty($worker_id) || empty($full_name)) {
    echo json_encode(["status" => "failed", "message" => "Missing required fields"]);
    exit();
}

// If image is provided, save it
if (!empty($image_base64)) {
    $image_filename = $worker_id . "_profile.png";
    $image_path = "../assets/images/" . $image_filename;

    if (!file_put_contents($image_path, base64_decode($image_base64))) {
        echo json_encode(["status" => "failed", "message" => "Image upload failed"]);
        exit();
    }
}

// Escape strings
$full_name = $conn->real_escape_string($full_name);
$phone = $conn->real_escape_string($phone);
$address = $conn->real_escape_string($address);

// Build SQL
$sql = "UPDATE tbl_users SET 
    name = '$full_name',
    phone = '$phone',
    address = '$address'";

if (!empty($image_filename)) {
    $sql .= ", image = '$image_filename'";
}

$sql .= " WHERE user_id = '$worker_id'";

// Execute
if ($conn->query($sql) === TRUE) {
    echo json_encode([
        "status" => "success",
        "worker_id" => $worker_id,
        "image" => $image_filename
    ]);
} else {
    echo json_encode(["status" => "failed", "message" => $conn->error]);
}
?>
