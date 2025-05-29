<?php
header('Content-Type: application/json');

require_once 'dbconnect.php'; // Your DB connection setup

if (!isset($_POST['worker_id'])) {
    echo json_encode(['status' => 'failed', 'data' => [], 'message' => 'worker_id not provided']);
    exit;
}

$worker_id = $_POST['worker_id'];

$sql = "SELECT * FROM tbl_works WHERE assigned_to = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $worker_id);
$stmt->execute();
$result = $stmt->get_result();

$tasks = [];
while ($row = $result->fetch_assoc()) {
    $tasks[] = $row;
}

echo json_encode(['status' => 'success', 'data' => $tasks]);
?>
