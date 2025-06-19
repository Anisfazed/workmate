<?php
error_reporting(0);
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

include_once("dbconnect.php");

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(["status" => "failed", "message" => "Invalid request method"]);
    exit;
}

$worker_id = $_POST['worker_id'];

$sql = "SELECT s.id, s.work_id, s.worker_id, s.submission_text, s.submitted_at, w.title 
        FROM tbl_submissions s 
        JOIN tbl_works w ON s.work_id = w.work_id 
        WHERE s.worker_id = '$worker_id' 
        ORDER BY s.submitted_at DESC";

$result = $conn->query($sql);

if ($result->num_rows > 0) {
    $submissions = [];
    while ($row = $result->fetch_assoc()) {
        $submissions[] = $row;
    }
    sendJsonResponse([
        "status" => "success",
        "data" => $submissions
    ]);
} else {
    sendJsonResponse([
        "status" => "failed",
        "message" => "No submissions found"
    ]);
}

function sendJsonResponse($response) {
    echo json_encode($response);
}
?>
