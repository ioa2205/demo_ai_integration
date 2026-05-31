<?php

define('DB_HOST', '127.0.0.1');
define('DB_PORT', 3306);
define('DB_NAME', 'pro_count_db');
define('DB_USER', 'root');
define('DB_PASS', 'root');

define('GEMINI_API_KEY', 'HERE'); // <-- Put your Gemini API key here
define('GEMINI_MODEL', 'gemini-2.5-flash');
define('GEMINI_TTS_MODEL', 'gemini-2.5-flash-preview-tts');

function getDB(): PDO
{
    static $pdo = null;
    if ($pdo === null) {
        $dsn = 'mysql:host=' . DB_HOST . ';port=' . DB_PORT . ';dbname=' . DB_NAME . ';charset=utf8mb4';
        $pdo = new PDO($dsn, DB_USER, DB_PASS, [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
    }
    return $pdo;
}
