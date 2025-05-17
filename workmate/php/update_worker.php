<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include_once("dbconnect.php");

$response = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = $_POST['id'];
    $name = $_POST['full_name'];
    $phone = $_POST['phone'];
    $address = $_POST['address'];

    // Email is excluded from update as it is read-only on the frontend
    $sql = "UPDATE workers SET full_name='$full_name', phone='$phone', address='$address' WHERE id='$id'";
    
    if (mysqli_query($conn, $sql)) {
        $response['status'] = 'success';
        $response['message'] = 'Profile updated successfully';
    } else {
        $response['status'] = 'failed';
        $response['message'] = 'Update failed: ' . mysqli_error($conn);
    }

    echo json_encode($response);
}
?>
