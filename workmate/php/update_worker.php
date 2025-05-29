<?php
include_once("dbconnect.php"); // ensure connection

$email = $_POST['email'] ?? '';
$full_name = $_POST['full_name'] ?? '';
$phone = $_POST['phone'] ?? '';
$address = $_POST['address'] ?? '';

// Basic validation
if (empty($email) || empty($full_name)) {
    echo json_encode(["status" => "failed", "message" => "Missing required fields"]);
    exit();
}

// Find the worker ID using the provided email
$sql = "SELECT worker_id FROM workers WHERE email = '$email'";
$result = mysqli_query($conn, $sql);
$row = mysqli_fetch_assoc($result);

if ($row) {
    $worker_id = $row['worker_id'];

    // Corrected column name from `name` to `full_name`
    $update_sql = "UPDATE workers SET full_name = '$full_name', phone = '$phone', address = '$address' WHERE email = '$email'";
    
    if (mysqli_query($conn, $update_sql)) {
        echo json_encode([
            "status" => "success",
            "worker_id" => $worker_id,
            "message" => "Profile updated successfully"
        ]);
    } else {
        echo json_encode(["status" => "failed", "message" => "Update failed"]);
    }
} else {
    echo json_encode(["status" => "failed", "message" => "User not found"]);
}
?>
