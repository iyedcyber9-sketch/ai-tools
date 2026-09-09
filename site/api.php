<?php
// AI Tools - Reviews & Bugs API
// Stores in data/reviews.json and data/bugs.json

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') { http_response_code(204); exit; }

$type = $_GET['type'] ?? 'reviews';
$action = $_GET['action'] ?? 'list';

if (!in_array($type, ['reviews', 'bugs'])) { http_response_code(400); echo '{"error":"bad type"}'; exit; }

$dataDir = __DIR__ . '/data';
if (!is_dir($dataDir)) mkdir($dataDir, 0755, true);

$jsonFile = $dataDir . '/' . $type . '.json';

function loadData($path) {
    if (file_exists($path)) {
        return json_decode(file_get_contents($path), true) ?? [];
    }
    return [];
}

function saveData($path, $data) {
    file_put_contents($path, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
}

// POST - submit new review or bug
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (!$input || empty($input['name']) || empty($input['message'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Name and message are required']);
        exit;
    }

    $items = loadData($jsonFile);
    $item = [
        'id' => time() . '_' . rand(1000, 9999),
        'name' => htmlspecialchars(trim($input['name']), ENT_QUOTES, 'UTF-8'),
        'message' => htmlspecialchars(trim($input['message']), ENT_QUOTES, 'UTF-8'),
        'rating' => isset($input['rating']) ? max(1, min(5, (int)$input['rating'])) : null,
        'platform' => isset($input['platform']) ? htmlspecialchars(trim($input['platform']), ENT_QUOTES, 'UTF-8') : null,
        'version' => isset($input['version']) ? htmlspecialchars(trim($input['version']), ENT_QUOTES, 'UTF-8') : null,
        'status' => 'new',
        'date' => date('Y-m-d H:i:s'),
    ];

    // Bug-specific fields
    if ($type === 'bugs') {
        $item['severity'] = in_array($input['severity'] ?? '', ['low','medium','high','critical']) ? $input['severity'] : 'medium';
        $item['steps'] = isset($input['steps']) ? htmlspecialchars(trim($input['steps']), ENT_QUOTES, 'UTF-8') : '';
    }

    array_unshift($items, $item);
    saveData($jsonFile, $items);

    echo json_encode(['success' => true, 'item' => $item]);
    exit;
}

// GET - list items
if ($action === 'list') {
    $items = loadData($jsonFile);
    echo json_encode(['items' => $items, 'count' => count($items)]);
    exit;
}

http_response_code(400);
echo '{"error":"bad action"}';
