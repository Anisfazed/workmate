<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendJsonResponse(['status' => 'failed', 'message' => 'Invalid request method']);
    exit;
}

include_once("dbconnect.php");

$submission_id = $_POST['submission_id'];
$updated_text = $_POST['updated_text'];

if (empty($submission_id) || empty($updated_text)) {
    sendJsonResponse(['status' => 'failed', 'message' => 'Missing required fields']);
    exit;
}

$sql = "UPDATE tbl_submissions SET submission_text = ? WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("si", $updated_text, $submission_id);

if ($stmt->execute()) {
    sendJsonResponse(['status' => 'success', 'message' => 'Submission updated successfully']);
} else {
    sendJsonResponse(['status' => 'failed', 'message' => 'Update failed']);
}

$stmt->close();
$conn->close();

function sendJsonResponse($array) {
    echo json_encode($array);
}
?>
