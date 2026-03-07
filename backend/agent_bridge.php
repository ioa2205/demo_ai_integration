<?php

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: http://localhost:5173');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/tools.php';

// --- GET: Dashboard data (no AI, direct DB) ---

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    try {
        echo json_encode([
            'products' => get_product_list(),
            'stock'    => get_stock_overview(),
            'stats'    => get_production_stats(),
        ], JSON_UNESCAPED_UNICODE);
    } catch (Throwable $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
    }
    exit;
}

// --- POST: AI Chat ---

$input = json_decode(file_get_contents('php://input'), true);
$userMessage = trim($input['message'] ?? '');
$userLang = $input['lang'] ?? 'ru-RU';
$history = $input['history'] ?? [];

if ($userMessage === '') {
    echo json_encode(['error' => 'Empty message']);
    exit;
}

// --- Helper: Generate TTS audio via Gemini ---

function generate_tts(string $text): ?string
{
    if (trim($text) === '') return null;

    $endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/'
        . GEMINI_TTS_MODEL . ':generateContent?key=' . GEMINI_API_KEY;

    $payload = json_encode([
        'contents' => [['parts' => [['text' => $text]]]],
        'generationConfig' => [
            'responseModalities' => ['AUDIO'],
            'speechConfig' => [
                'voiceConfig' => [
                    'prebuiltVoiceConfig' => ['voiceName' => 'Puck'],
                ],
            ],
        ],
    ], JSON_UNESCAPED_UNICODE);

    $ch = curl_init($endpoint);
    $curlOpts = [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST           => true,
        CURLOPT_HTTPHEADER     => ['Content-Type: application/json'],
        CURLOPT_POSTFIELDS     => $payload,
        CURLOPT_TIMEOUT        => 30,
    ];
    $caPath = 'C:/php/cacert.pem';
    if (file_exists($caPath)) {
        $curlOpts[CURLOPT_CAINFO] = $caPath;
    } else {
        $curlOpts[CURLOPT_SSL_VERIFYPEER] = false;
        $curlOpts[CURLOPT_SSL_VERIFYHOST] = 0;
    }
    curl_setopt_array($ch, $curlOpts);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($httpCode !== 200) return null;

    $json = json_decode($response, true);
    $pcmBase64 = $json['candidates'][0]['content']['parts'][0]['inlineData']['data'] ?? null;
    if (!$pcmBase64) return null;

    // Convert raw PCM to WAV (add 44-byte header for browser playback)
    $pcm = base64_decode($pcmBase64);
    $sampleRate = 24000;
    $channels = 1;
    $bitsPerSample = 16;
    $dataSize = strlen($pcm);
    $header = pack('A4VA4', 'RIFF', 36 + $dataSize, 'WAVE')
        . pack('A4VvvVVvv', 'fmt ', 16, 1, $channels, $sampleRate,
            $sampleRate * $channels * $bitsPerSample / 8,
            $channels * $bitsPerSample / 8, $bitsPerSample)
        . pack('A4V', 'data', $dataSize);

    return base64_encode($header . $pcm);
}

// --- Helper: Get DB Schema Description ---

function get_schema_description(PDO $db): string
{
    $stmt = $db->query("
        SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY, COLUMN_COMMENT
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = '" . DB_NAME . "'
        ORDER BY TABLE_NAME, ORDINAL_POSITION
    ");
    $rows = $stmt->fetchAll();

    $tables = [];
    foreach ($rows as $row) {
        $tables[$row['TABLE_NAME']][] = $row;
    }

    $output = '';
    foreach ($tables as $tableName => $columns) {
        $output .= "TABLE: {$tableName}\n";
        foreach ($columns as $col) {
            $pk = $col['COLUMN_KEY'] === 'PRI' ? ' [PK]' : '';
            $nullable = $col['IS_NULLABLE'] === 'YES' ? ' NULL' : ' NOT NULL';
            $comment = $col['COLUMN_COMMENT'] ? " -- {$col['COLUMN_COMMENT']}" : '';
            $output .= "  {$col['COLUMN_NAME']} {$col['COLUMN_TYPE']}{$pk}{$nullable}{$comment}\n";
        }
        $output .= "\n";
    }
    return $output;
}

// --- Helper: Validate SQL ---

function validate_sql(string $sql): array
{
    $sql = trim($sql);

    // Remove leading comments
    $sql = preg_replace('/^(--[^\n]*\n|\/\*.*?\*\/\s*)+/s', '', $sql);
    $sql = trim($sql);

    // Determine statement type
    $firstWord = strtoupper(strtok($sql, " \t\r\n("));

    if (!in_array($firstWord, ['SELECT', 'UPDATE'], true)) {
        return ['valid' => false, 'error' => "Only SELECT and UPDATE are allowed. Got: {$firstWord}"];
    }

    // Forbidden keywords
    $forbidden = [
        'DELETE', 'DROP', 'CREATE', 'ALTER', 'TRUNCATE', 'INSERT',
        'GRANT', 'REVOKE', 'REPLACE', 'RENAME', 'LOAD', 'CALL',
        'INTO\\s+OUTFILE', 'INTO\\s+DUMPFILE', 'BENCHMARK', 'SLEEP',
    ];
    foreach ($forbidden as $kw) {
        if (preg_match('/\b' . $kw . '\b/i', $sql)) {
            return ['valid' => false, 'error' => "Forbidden keyword detected: {$kw}"];
        }
    }

    // Block multiple statements
    $stripped = rtrim($sql, "; \t\r\n");
    if (strpos($stripped, ';') !== false) {
        return ['valid' => false, 'error' => 'Multiple statements are not allowed.'];
    }
    $sql = $stripped;

    // SELECT: auto-append LIMIT if missing
    if ($firstWord === 'SELECT' && !preg_match('/\bLIMIT\b/i', $sql)) {
        $sql .= ' LIMIT 200';
    }

    // UPDATE: table whitelist
    if ($firstWord === 'UPDATE') {
        $allowedTables = [
            'product', 'material', 'client', 'supplier', 'order', 'order_item',
            'sale', 'sale_item', 'purchase', 'purchase_item', 'production_batch',
            'warehouse', 'recipe', 'recipe_item', 'price', 'product_packaging',
            'product_category', 'material_category', 'app_settings', 'stock',
        ];
        preg_match('/^UPDATE\s+`?(\w+)`?/i', $sql, $m);
        $table = strtolower($m[1] ?? '');
        if (!in_array($table, $allowedTables, true)) {
            return ['valid' => false, 'error' => "UPDATE not allowed on table: {$table}"];
        }
    }

    return ['valid' => true, 'type' => $firstWord, 'sql' => $sql];
}

// --- Helper: Execute Validated SQL ---

function execute_validated_sql(PDO $db, string $sql, string $type): array
{
    if ($type === 'SELECT') {
        $stmt = $db->query($sql);
        $rows = $stmt->fetchAll();
        return ['success' => true, 'row_count' => count($rows), 'data' => $rows];
    }

    if ($type === 'UPDATE') {
        $stmt = $db->query($sql);
        return ['success' => true, 'affected_rows' => $stmt->rowCount()];
    }

    return ['success' => false, 'error' => 'Unknown statement type'];
}

// --- Gemini Tool Declaration (single tool: execute_sql) ---

$toolDeclarations = [
    [
        'name'        => 'execute_sql',
        'description' => 'Execute a SQL query against the factory ERP MySQL database. Only SELECT and UPDATE statements are allowed. DELETE, DROP, INSERT, CREATE, ALTER, TRUNCATE are forbidden. For SELECT: returns rows as array. For UPDATE: returns affected row count. If query has an error, you get the error message and can retry.',
        'parameters'  => [
            'type'       => 'object',
            'properties' => [
                'sql' => [
                    'type'        => 'string',
                    'description' => 'A valid MySQL 8.0 SQL statement. Only SELECT and UPDATE allowed.',
                ],
            ],
            'required' => ['sql'],
        ],
    ],
];

// --- Helper: Cached Schema (5-minute TTL) ---

function get_schema_cached(PDO $db): string
{
    $cacheFile = sys_get_temp_dir() . '/factory_schema_cache.json';
    $ttl = 300; // 5 minutes

    if (file_exists($cacheFile)) {
        $cached = json_decode(file_get_contents($cacheFile), true);
        if ($cached && (time() - ($cached['time'] ?? 0)) < $ttl) {
            return $cached['schema'];
        }
    }

    $schema = get_schema_description($db);
    file_put_contents($cacheFile, json_encode(['time' => time(), 'schema' => $schema]));
    return $schema;
}

// --- System Instruction with Schema ---

$schemaText = get_schema_cached(getDB());

$sqlRules = <<<'RULES'
SQL RULES:
- You may ONLY use SELECT and UPDATE statements.
- DELETE, INSERT, DROP, CREATE, ALTER, TRUNCATE are FORBIDDEN.
- All timestamps in the database are Unix timestamps (integer seconds since epoch).
- Use FROM_UNIXTIME() to format dates for display.
- Use UNIX_TIMESTAMP() when comparing with date inputs.
- Always include reasonable LIMIT on SELECT queries (max 200 rows).
- For UPDATE: always include a WHERE clause. Never update without conditions.
- Use JOINs to get human-readable names (e.g., join product with product_category for category name).
- The `user` table contains sensitive data. NEVER select or update: password_hash, auth_key, password_reset_token, access_token, verification_token, expiret_access_token columns.
- The `migration` table is internal. Do not query it.
RULES;

if ($userLang === 'uz-UZ') {
    $langInstruction = "Faqat o'zbek tilida javob bering.";
} else {
    $langInstruction = "Отвечайте только на русском языке.";
}

$systemInstruction = <<<PROMPT
Siz zavod yordamchisisiz. Bu ishlab chiqarish ERP tizimi.
Вы помощник завода. Это ERP-система управления производством.
{$langInstruction}

RESPONSE RULES:
- Keep answers SHORT and DIRECT. No filler words, no unnecessary explanations.
- Just state the facts. If data is returned, summarize it briefly in 1-2 sentences.
- CRITICAL: Your text response must ONLY contain natural human-readable text. NEVER include:
  * SQL code or queries (SELECT, UPDATE, FROM, JOIN, WHERE, etc.)
  * Code blocks (```) or inline code (`)
  * Function calls like execute_sql(...)
  * Technical column names, table names, or database terms
  * Any programming syntax whatsoever
- Never say "I executed a query" or "Here are the results". Just give the answer naturally.
- For tables: the data will be shown automatically in the UI. Just add a brief text summary.
- For updates: confirm what was changed in one sentence.
- Accuracy is the top priority. Never guess or invent data — always query first.
- Respond as if you are a human assistant who looked up the information, not a program that ran code.

Ma'lumotlarni topish uchun execute_sql() funksiyasidan foydalaning.
Для получения данных используйте функцию execute_sql().

DATABASE SCHEMA:
{$schemaText}

{$sqlRules}
PROMPT;

// --- Build Conversation (with history for context) ---

$contents = [];
if (is_array($history)) {
    // Include last 10 conversation turns for context
    $recentHistory = array_slice($history, -10);
    foreach ($recentHistory as $turn) {
        $role = ($turn['role'] ?? '') === 'user' ? 'user' : 'model';
        $text = trim($turn['text'] ?? '');
        if ($text !== '') {
            $contents[] = ['role' => $role, 'parts' => [['text' => $text]]];
        }
    }
}
$contents[] = ['role' => 'user', 'parts' => [['text' => $userMessage]]];

$toolCallsLog = [];
$lastToolResult = null;

$geminiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/'
    . GEMINI_MODEL . ':generateContent?key=' . GEMINI_API_KEY;

// --- Function-Calling Loop (max 5 iterations) ---

for ($i = 0; $i < 5; $i++) {
    $payload = [
        'system_instruction' => ['parts' => [['text' => $systemInstruction]]],
        'contents'           => $contents,
        'tools'              => [['function_declarations' => $toolDeclarations]],
    ];

    $jsonBody = json_encode($payload, JSON_UNESCAPED_UNICODE);

    $ch = curl_init($geminiEndpoint);
    $curlOpts = [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST           => true,
        CURLOPT_HTTPHEADER     => ['Content-Type: application/json'],
        CURLOPT_POSTFIELDS     => $jsonBody,
        CURLOPT_TIMEOUT        => 60,
    ];

    // Use CA bundle if available, otherwise disable SSL verify for local dev
    $caPath = 'C:/php/cacert.pem';
    if (file_exists($caPath)) {
        $curlOpts[CURLOPT_CAINFO] = $caPath;
    } else {
        $curlOpts[CURLOPT_SSL_VERIFYPEER] = false;
        $curlOpts[CURLOPT_SSL_VERIFYHOST] = 0;
    }

    curl_setopt_array($ch, $curlOpts);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    curl_close($ch);

    if ($curlError) {
        echo json_encode(['error' => 'Connection error: ' . $curlError]);
        exit;
    }

    if ($httpCode !== 200) {
        $errorBody = json_decode($response, true);
        $errorMsg = $errorBody['error']['message'] ?? ('HTTP ' . $httpCode);
        echo json_encode(['error' => 'Gemini API: ' . $errorMsg]);
        exit;
    }

    $geminiResponse = json_decode($response, true);
    $candidate = $geminiResponse['candidates'][0]['content'] ?? null;

    if (!$candidate) {
        $blockReason = $geminiResponse['candidates'][0]['finishReason'] ?? 'unknown';
        echo json_encode(['error' => 'No response from AI (reason: ' . $blockReason . ')']);
        exit;
    }

    // Clean model response for conversation history.
    // Gemini 2.5 Flash thinking mode: skip thought parts, never echo thoughtSignature
    $cleanParts = [];
    $functionCall = null;
    foreach ($candidate['parts'] as $part) {
        $cleanPart = [];
        if (isset($part['text']) && empty($part['thought'])) {
            $cleanPart['text'] = $part['text'];
        }
        if (isset($part['functionCall'])) {
            $fc = $part['functionCall'];
            // PHP json_decode turns {} into [] — cast args back to object
            // so json_encode outputs {} not [] (Gemini rejects arrays for Struct fields)
            if (isset($fc['args'])) {
                $fc['args'] = (object)$fc['args'];
            } else {
                $fc['args'] = (object)[];
            }
            $cleanPart['functionCall'] = $fc;
            $functionCall = $part['functionCall'];
        }
        if (!empty($cleanPart)) {
            $cleanParts[] = $cleanPart;
        }
    }
    if (empty($cleanParts)) {
        $cleanParts = [['text' => '']];
    }

    $contents[] = ['role' => 'model', 'parts' => $cleanParts];

    if (!$functionCall) {
        $replyText = '';
        foreach ($candidate['parts'] as $part) {
            if (isset($part['text']) && empty($part['thought'])) {
                $replyText .= $part['text'];
            }
        }

        // Clean AI reply: remove code blocks, SQL fragments, and tool call syntax
        // Remove markdown code blocks (```...```)
        $replyText = preg_replace('/```[\s\S]*?```/', '', $replyText);
        // Remove inline code containing SQL keywords or execute_sql
        $replyText = preg_replace('/`[^`]*(?:SELECT|UPDATE|FROM|JOIN|WHERE|execute_sql)[^`]*`/i', '', $replyText);
        // Remove execute_sql(...) function call syntax
        $replyText = preg_replace('/execute_sql\s*\([^)]*\)/i', '', $replyText);
        // Remove standalone SQL statements (lines starting with SELECT/UPDATE)
        $replyText = preg_replace('/^\s*(?:SELECT|UPDATE)\b[^.!?\n]*$/mi', '', $replyText);
        // Clean up excessive whitespace
        $replyText = preg_replace('/\n{3,}/', "\n\n", trim($replyText));

        $audio = generate_tts($replyText);

        echo json_encode([
            'reply'      => $replyText,
            'tool_calls' => $toolCallsLog,
            'data'       => $lastToolResult,
            'audio'      => $audio,
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // Execute the function call
    $fnName = $functionCall['name'];
    $fnArgs = $functionCall['args'] ?? [];

    $toolCallsLog[] = ['name' => $fnName, 'args' => $fnArgs];

    try {
        if ($fnName === 'execute_sql') {
            $sql = (string)($fnArgs['sql'] ?? '');
            if ($sql === '') {
                $result = ['error' => 'Empty SQL query'];
            } else {
                $validation = validate_sql($sql);
                if (!$validation['valid']) {
                    $result = ['error' => 'SQL rejected: ' . $validation['error']];
                } else {
                    $result = execute_validated_sql(getDB(), $validation['sql'], $validation['type']);
                }
            }
        } else {
            $result = ['error' => "Unknown function: {$fnName}. Only execute_sql is available."];
        }
    } catch (PDOException $e) {
        // Send MySQL error to Gemini so it can retry with corrected SQL
        $result = ['error' => 'SQL execution error: ' . $e->getMessage()];
    } catch (Throwable $e) {
        $result = ['error' => 'Execution failed: ' . $e->getMessage()];
    }

    // For SELECT results, pass the rows array directly to frontend's DataTable
    $lastToolResult = $result['data'] ?? $result;

    $contents[] = [
        'role'  => 'user',
        'parts' => [[
            'functionResponse' => [
                'name'     => $fnName,
                'response' => ['result' => $result],
            ],
        ]],
    ];
}

echo json_encode(['error' => 'Too many function call iterations'], JSON_UNESCAPED_UNICODE);
