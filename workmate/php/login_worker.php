<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

// Validate request method
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    $response = array('status' => 'failed', 'data' => null);
    echo json_encode($response);
    exit;
}

include_once("dbconnect.php");

// Collect and hash credentials
$email = $_POST['email'];
$password = sha1($_POST['password']);

// SQL query to authenticate user
$sqllogin = "SELECT * FROM `workers` WHERE email = '$email' AND password = '$password'";
$result = $conn->query($sqllogin);

// Build response
if ($result && $result->num_rows > 0) {
    $sentArray = array();
    while ($row = $result->fetch_assoc()) {
        $sentArray[] = $row;
    }
    $response = array('status' => 'success', 'data' => $sentArray);
} else {
    $response = array('status' => 'failed', 'data' => null);
}

// Send JSON response
echo json_encode($response);
?>
