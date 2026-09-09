<?php
// AI Tools - Download Counter + Redirect
// Uses JSON file (no MySQL needed)

header('Access-Control-Allow-Origin: *');

$action = $_GET['action'] ?? '';
$file = $_GET['file'] ?? '';

$GITHUB_URLS = [
    'windows' => 'https://github.com/iyedcyber9-sketch/ai-tools/releases/download/v1.0.1/AI_Tools_Windows_x64.zip',
    'linux'   => 'https://github.com/iyedcyber9-sketch/ai-tools/releases/download/v1.0.1/AI_Tools_Kali_Linux_x64_release.tar.gz',
    'android' => 'https://github.com/iyedcyber9-sketch/ai-tools/releases/download/v1.0.1/AI_Tools_v1.0.1_arm64-release.apk',
];

function getCounts() {
    $path = __DIR__ . '/data/counts.json';
    if (file_exists($path)) {
        return json_decode(file_get_contents($path), true) ?? ['windows'=>0,'linux'=>0,'android'=>0];
    }
    return ['windows'=>0, 'linux'=>0, 'android'=>0];
}

function saveCounts($counts) {
    $dir = __DIR__ . '/data';
    if (!is_dir($dir)) mkdir($dir, 0755, true);
    file_put_contents($dir . '/counts.json', json_encode($counts, JSON_PRETTY_PRINT));
}

function track($os) {
    $counts = getCounts();
    if (!isset($counts[$os])) return $counts;
    $counts[$os]++;
    saveCounts($counts);
    return $counts;
}

// Get counts
if ($action === 'count') {
    header('Content-Type: application/json');
    echo json_encode(getCounts());
    exit;
}

// Track download (AJAX)
if ($action === 'track' && isset($GITHUB_URLS[$file])) {
    header('Content-Type: application/json');
    $counts = track($file);
    echo json_encode($counts);
    exit;
}

// Direct download link: download.php?file=linux
if ($file !== '' && isset($GITHUB_URLS[$file])) {
    track($file);
    header('Location: ' . $GITHUB_URLS[$file], true, 302);
    exit;
}

http_response_code(400);
echo 'Invalid request';
