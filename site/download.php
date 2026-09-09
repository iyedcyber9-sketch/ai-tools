<?php
// AI Tools Download Counter + Redirect
// Count file: counter.json (writable dir above public_root recommended, fallback to local)
// MySQL: optional, uses Byethost sql305.byethost6.com if configured

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

$action = $_GET['action'] ?? '';
$file = $_GET['file'] ?? '';

// --- MySQL config (use your Byethost MySQL) ---
$DB_HOST = 'sql305.byethost6.com';
$DB_NAME = 'b6_42870140_ai_tools';
$DB_USER = 'b6_42870140';
$DB_PASS = ''; // SET THIS in cPanel MySQL

// --- GitHub release URLs (fallback) ---
$GITHUB_URLS = [
    'windows' => 'https://github.com/iyedcyber9-sketch/ai-tools/releases/download/v1.0.1/AI_Tools_Windows_x64.zip',
    'linux'   => 'https://github.com/iyedcyber9-sketch/ai-tools/releases/download/v1.0.1/AI_Tools_Kali_Linux_x64_release.tar.gz',
    'android' => 'https://github.com/iyedcyber9-sketch/ai-tools/releases/download/v1.0.1/AI_Tools_v1.0.1_arm64-release.apk',
];

// --- MySQL helper ---
function getDB() {
    global $DB_HOST, $DB_NAME, $DB_USER, $DB_PASS;
    try {
        $pdo = new PDO("mysql:host=$DB_HOST;dbname=$DB_NAME;charset=utf8mb4", $DB_USER, $DB_PASS, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
        return $pdo;
    } catch (PDOException $e) {
        return null;
    }
}

function initDB($pdo) {
    $pdo->exec("CREATE TABLE IF NOT EXISTS downloads (
        id INT AUTO_INCREMENT PRIMARY KEY,
        os VARCHAR(20) NOT NULL UNIQUE,
        count INT DEFAULT 0
    )");
    foreach (['windows','linux','android'] as $os) {
        $stmt = $pdo->prepare("INSERT IGNORE INTO downloads (os, count) VALUES (?, 0)");
        $stmt->execute([$os]);
    }
}

function getCountsMySQL($pdo) {
    initDB($pdo);
    $rows = $pdo->query("SELECT os, count FROM downloads")->fetchAll();
    $counts = ['windows'=>0, 'linux'=>0, 'android'=>0];
    foreach ($rows as $r) $counts[$r['os']] = (int)$r['count'];
    return $counts;
}

function trackMySQL($pdo, $os) {
    initDB($pdo);
    $stmt = $pdo->prepare("UPDATE downloads SET count = count + 1 WHERE os = ?");
    $stmt->execute([$os]);
}

// --- JSON file fallback ---
function getCountsJSON() {
    $path = __DIR__ . '/counter.json';
    if (file_exists($path)) {
        return json_decode(file_get_contents($path), true) ?? ['windows'=>0,'linux'=>0,'android'=>0];
    }
    return ['windows'=>0, 'linux'=>0, 'android'=>0];
}

function saveCountsJSON($counts) {
    $path = __DIR__ . '/counter.json';
    file_put_contents($path, json_encode($counts, JSON_PRETTY_PRINT));
}

function trackJSON($os) {
    $counts = getCountsJSON();
    if (!isset($counts[$os])) return;
    $counts[$os]++;
    saveCountsJSON($counts);
}

// --- Route ---
if ($action === 'count') {
    $pdo = getDB();
    if ($pdo) {
        echo json_encode(getCountsMySQL($pdo));
    } else {
        echo json_encode(getCountsJSON());
    }
    exit;
}

if ($action === 'track' && isset($GITHUB_URLS[$file])) {
    $pdo = getDB();
    if ($pdo) {
        trackMySQL($pdo, $file);
    } else {
        trackJSON($file);
    }
    // Return counts
    if ($pdo) {
        echo json_encode(getCountsMySQL($pdo));
    } else {
        echo json_encode(getCountsJSON());
    }
    exit;
}

if ($action === 'dl' && isset($GITHUB_URLS[$file])) {
    // Track + redirect
    $pdo = getDB();
    if ($pdo) {
        trackMySQL($pdo, $file);
    } else {
        trackJSON($file);
    }
    header('Location: ' . $GITHUB_URLS[$file], true, 302);
    exit;
}

// Unknown action
http_response_code(400);
echo json_encode(['error' => 'Invalid request']);
