<?php
include_once("dbconnect.php");

$work_id = $_POST['work_id'];
$worker_id = $_POST['worker_id'];
$submission_text = $_POST['submission_text'];

if (!$work_id || !$worker_id || !$submission_text) {
    echo json_encode(["status" => "failed", "message" => "Missing fields"]);
    exit();
}

// Insert submission
$sql_insert = "INSERT INTO tbl_submissions (work_id, worker_id, submission_text) VALUES (?, ?, ?)";
$stmt_insert = $conn->prepare($sql_insert);
$stmt_insert->bind_param("iis", $work_id, $worker_id, $submission_text);

if ($stmt_insert->execute()) {
    // Update work status
    $sql_update = "UPDATE tbl_works SET status = 'success' WHERE work_id = ? AND assigned_to = ?";
    $stmt_update = $conn->prepare($sql_update);
    $stmt_update->bind_param("ii", $work_id, $worker_id);
    $stmt_update->execute();

    echo json_encode(["status" => "success", "message" => "Submission successful"]);
} else {
    echo json_encode(["status" => "failed", "message" => "Submission failed"]);
}

$stmt_insert->close();
$conn->close();
?>