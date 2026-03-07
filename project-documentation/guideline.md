# AI Factory Assistant — Integration Guideline

How to integrate the AI Factory Assistant agent into an existing ERP platform. This guide covers the exact architecture, a ready-to-use Claude Code prompt, and step-by-step manual integration instructions.

---

## Table of Contents

- [1. Overview](#1-overview)
- [2. Architecture](#2-architecture)
  - [2.1 Tech Stack](#21-tech-stack)
  - [2.2 Request Flow](#22-request-flow)
  - [2.3 API Contract](#23-api-contract)
  - [2.4 Gemini Function Calling](#24-gemini-function-calling)
  - [2.5 System Instruction](#25-system-instruction)
  - [2.6 SQL Validation](#26-sql-validation)
  - [2.7 SQL Execution & Error Recovery](#27-sql-execution--error-recovery)
  - [2.8 Text-to-Speech (TTS)](#28-text-to-speech-tts)
  - [2.9 Reply Text Cleaning](#29-reply-text-cleaning)
  - [2.10 Frontend Architecture](#210-frontend-architecture)
  - [2.11 Bilingual Support](#211-bilingual-support)
- [3. Claude Code Integration Prompt](#3-claude-code-integration-prompt)
- [4. Manual Integration Guide](#4-manual-integration-guide)
  - [4.1 Prerequisites](#41-prerequisites)
  - [4.2 Backend Step-by-Step](#42-backend-step-by-step)
  - [4.3 Frontend Step-by-Step](#43-frontend-step-by-step)
  - [4.4 Testing Checklist](#44-testing-checklist)
- [5. Configuration Reference](#5-configuration-reference)

---

## 1. Overview

This guide describes how to integrate the AI Factory Assistant — a conversational AI agent that queries and updates an ERP MySQL database using natural language — into your existing ERP platform.

**What the AI agent does:** Users ask questions in Russian or Uzbek via text or voice. The agent uses Google Gemini to dynamically generate SQL queries, validates and executes them, and returns human-readable answers with optional voice output (TTS).

**Key constraints:**
- Backend logic, API response format, function calling flow, and SQL validation must be **identical** to the reference implementation
- Frontend design and UI framework can differ — only the API integration and data rendering logic must match
- The target platform shares the same MySQL database (or same schema)

**Prerequisites:**
- PHP 8.2+ with `curl` and `pdo_mysql` extensions
- MySQL 8.0 database (the ERP database)
- Google Gemini API key with access to `gemini-2.5-flash` and `gemini-2.5-flash-preview-tts` models
- Frontend framework (React, Vue, Angular, etc.)
- Chrome/Edge browser (for Web Speech API voice input)

---

## 2. Architecture

### 2.1 Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| AI (Chat) | Google Gemini 2.5 Flash | Function-calling to generate SQL |
| AI (TTS) | Google Gemini 2.5 Flash Preview TTS | Text-to-speech audio generation |
| Backend | PHP 8.2 | Single API endpoint, SQL validation, Gemini orchestration |
| Database | MySQL 8.0 | ERP data (queried dynamically via AI-generated SQL) |
| Voice Input | Web Speech API (browser) | Speech-to-text for Russian/Uzbek |
| Voice Output | Gemini TTS → WAV → HTML5 Audio | Server-generated audio played in browser |

### 2.2 Request Flow

```
1. User speaks or types a question
2. Frontend sends POST { message, lang, history } to the API endpoint
3. PHP queries INFORMATION_SCHEMA.COLUMNS for full database schema (cached with 5-minute TTL)
4. PHP builds system instruction (language directive + response rules + schema + SQL rules)
5. PHP builds conversation from history + current message, sends with system instruction + tool declaration to Gemini API
6. Gemini responds with execute_sql() function call containing a SQL query
7. PHP validates SQL (statement type, forbidden keywords, multi-statement, table whitelist)
8. PHP executes validated SQL via PDO
9. PHP sends SQL result back to Gemini as functionResponse
10. Gemini writes human-readable answer (no SQL, no code, natural language only)
11. PHP cleans reply text (strips any leaked code/SQL fragments)
12. PHP generates TTS audio via Gemini TTS API (PCM → WAV → base64)
13. PHP returns JSON { reply, tool_calls, data, audio }
14. Frontend renders message, displays data table, plays audio
```

If Gemini writes invalid SQL (syntax error, wrong column, etc.), the error is sent back to Gemini and it retries with corrected SQL. This loop runs up to **5 iterations** max.

Simple questions ("Hello", "What can you do?") skip the SQL step — Gemini responds directly with text.

### 2.3 API Contract

**Single endpoint** — one file handles both dashboard data and AI chat.

#### POST — AI Chat

**Request:**
```json
{
  "message": "Покажи все продукты",
  "lang": "ru-RU",
  "history": [
    { "role": "user", "text": "previous question" },
    { "role": "assistant", "text": "previous answer" }
  ]
}
```

| Field | Type | Values |
|-------|------|--------|
| `message` | string | User's question text |
| `lang` | string | `"ru-RU"` (Russian) or `"uz-UZ"` (Uzbek) |
| `history` | array | Last 10 conversation turns `[{ role, text }]` (optional, enables follow-up questions) |

**Response (success):**
```json
{
  "reply": "Вот список всех активных продуктов:",
  "tool_calls": [
    { "name": "execute_sql", "args": { "sql": "SELECT p.id, p.name FROM product p WHERE p.status = 1 LIMIT 200" } }
  ],
  "data": [
    { "id": 1, "name": "Mahsulot 1" },
    { "id": 2, "name": "Mahsulot 2" }
  ],
  "audio": "UklGRi4A... (base64-encoded WAV)"
}
```

| Field | Type | Description |
|-------|------|-------------|
| `reply` | string | Human-readable AI answer (cleaned of SQL/code) |
| `tool_calls` | array | Log of all tool calls made during the conversation (name + args) |
| `data` | array\|object\|null | Last SQL result data (rows for SELECT, `{affected_rows}` for UPDATE) |
| `audio` | string\|null | Base64-encoded WAV audio of the reply (null if TTS fails) |

**Response (error):**
```json
{ "error": "Error description" }
```

Possible errors: `"Empty message"`, `"Connection error: ..."`, `"Gemini API: ..."`, `"No response from AI (reason: ...)"`, `"Too many function call iterations"`

#### GET — Dashboard Data

**Response:**
```json
{
  "products": [ { "id": 1, "name": "...", "category_name": "...", ... } ],
  "stock": [ { "item_type": "PRODUCT", "item_name": "...", "qty": 100, ... } ],
  "stats": {
    "by_status": [ { "status": "COMPLETED", "cnt": 3, ... } ],
    "today_completed": [ { "batch_no": "...", "product_name": "...", ... } ],
    "summary": { "total_batches": 3, "completed_count": 1, ... }
  }
}
```

#### CORS Headers

```
Content-Type: application/json; charset=utf-8
Access-Control-Allow-Origin: <your-frontend-origin>
Access-Control-Allow-Methods: GET, POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
```

OPTIONS requests return 204 with these headers (preflight).

### 2.4 Gemini Function Calling

#### Tool Declaration

The AI has exactly one tool:

```json
{
  "name": "execute_sql",
  "description": "Execute a SQL query against the factory ERP MySQL database. Only SELECT and UPDATE statements are allowed. DELETE, DROP, INSERT, CREATE, ALTER, TRUNCATE are forbidden. For SELECT: returns rows as array. For UPDATE: returns affected row count. If query has an error, you get the error message and can retry.",
  "parameters": {
    "type": "object",
    "properties": {
      "sql": {
        "type": "string",
        "description": "A valid MySQL 8.0 SQL statement. Only SELECT and UPDATE allowed."
      }
    },
    "required": ["sql"]
  }
}
```

#### Gemini API Call Structure

**Endpoint:**
```
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={API_KEY}
```

**Payload:**
```json
{
  "system_instruction": {
    "parts": [{ "text": "<system instruction text>" }]
  },
  "contents": [
    { "role": "user", "parts": [{ "text": "user message" }] }
  ],
  "tools": [
    {
      "function_declarations": [ <tool declaration above> ]
    }
  ]
}
```

#### Function Calling Loop

The loop runs up to **5 iterations**. Each iteration:

1. Send `contents` array to Gemini
2. Parse response — filter out `thought` parts (Gemini 2.5 thinking mode), extract `functionCall` and `text` parts
3. **If no `functionCall`**: extract text reply → clean it → generate TTS → return final JSON response
4. **If `functionCall` exists**: validate SQL → execute → append model response and `functionResponse` to `contents` → next iteration

**Conversation array format during loop:**

```
Iteration 1:
  contents: [
    { role: "user", parts: [{ text: "user question" }] }
  ]

After Gemini responds with functionCall:
  contents: [
    { role: "user", parts: [{ text: "user question" }] },
    { role: "model", parts: [{ functionCall: { name: "execute_sql", args: { sql: "..." } } }] },
    { role: "user", parts: [{ functionResponse: { name: "execute_sql", response: { result: { success: true, data: [...] } } } }] }
  ]

Iteration 2: Gemini sees the SQL result and either calls another function or writes final text.
```

**Critical PHP detail:** `json_decode` converts empty JSON objects `{}` into PHP arrays `[]`. The `args` field must be cast back to `(object)` before `json_encode`, because Gemini rejects arrays for Struct fields:

```php
$fc['args'] = (object)$fc['args'];
```

**Thought part handling:** Gemini 2.5 Flash may include parts with a `thought` field. These must be **skipped** — never include them in conversation history or final reply. Check: `if (isset($part['text']) && empty($part['thought']))`.

### 2.5 System Instruction

The system instruction is built dynamically on each request and contains four sections:

#### 1. Language Directive

```
// For ru-RU:
Siz zavod yordamchisisiz. Bu ishlab chiqarish ERP tizimi.
Вы помощник завода. Это ERP-система управления производством.
Отвечайте только на русском языке.

// For uz-UZ:
Siz zavod yordamchisisiz. Bu ishlab chiqarish ERP tizimi.
Вы помощник завода. Это ERP-система управления производством.
Faqat o'zbek tilida javob bering.
```

#### 2. Response Rules

```
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
```

#### 3. Database Schema (Dynamic)

Queried from `INFORMATION_SCHEMA.COLUMNS` on each request:

```sql
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY, COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = '<database_name>'
ORDER BY TABLE_NAME, ORDINAL_POSITION
```

Formatted as:
```
DATABASE SCHEMA:
TABLE: product
  id bigint [PK] NOT NULL
  name varchar(255) NOT NULL
  category_id bigint NOT NULL
  ...

TABLE: stock
  id bigint [PK] NOT NULL
  item_type varchar(20) NOT NULL -- PRODUCT or MATERIAL
  ...
```

#### 4. SQL Rules

```
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
```

### 2.6 SQL Validation

Every AI-generated SQL query passes through `validate_sql()` before execution. Six checks, in order:

**Step 1: Strip leading comments**
```php
$sql = preg_replace('/^(--[^\n]*\n|\/\*.*?\*\/\s*)+/s', '', $sql);
```

**Step 2: Check statement type**
Extract the first word. Only `SELECT` and `UPDATE` are allowed. Everything else is rejected.

**Step 3: Forbidden keywords scan**
Block these keywords via regex word-boundary matching (`/\b{keyword}\b/i`):
```
DELETE, DROP, CREATE, ALTER, TRUNCATE, INSERT,
GRANT, REVOKE, REPLACE, RENAME, LOAD, CALL,
INTO\s+OUTFILE, INTO\s+DUMPFILE, BENCHMARK, SLEEP
```

**Step 4: Multi-statement block**
Strip trailing semicolons/whitespace. If any `;` remains in the body, reject.

**Step 5: Auto-append LIMIT (SELECT only)**
If the query has no `LIMIT` clause (`/\bLIMIT\b/i`), append `LIMIT 200`.

**Step 6: UPDATE table whitelist**
Extract table name from `UPDATE <table>`. Only these tables are allowed:
```
product, material, client, supplier, order, order_item,
sale, sale_item, purchase, purchase_item, production_batch,
warehouse, recipe, recipe_item, price, product_packaging,
product_category, material_category, app_settings, stock
```

### 2.7 SQL Execution & Error Recovery

**SELECT execution:**
```php
$stmt = $db->query($sql);
$rows = $stmt->fetchAll();
return ['success' => true, 'row_count' => count($rows), 'data' => $rows];
```

**UPDATE execution:**
```php
$stmt = $db->query($sql);
return ['success' => true, 'affected_rows' => $stmt->rowCount()];
```

**Error recovery:** When a `PDOException` is thrown (syntax error, unknown column, etc.), the error message is packaged as the function response and sent back to Gemini:
```php
$result = ['error' => 'SQL execution error: ' . $e->getMessage()];
```
Gemini sees the error and writes a corrected query on the next iteration. The user never sees raw SQL errors.

**Data passed to frontend:** For SELECT results, only the `data` array (rows) is passed as the response's `data` field. For UPDATE or error results, the entire result object is passed:
```php
$lastToolResult = $result['data'] ?? $result;
```

### 2.8 Text-to-Speech (TTS)

**Endpoint:**
```
POST https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent?key={API_KEY}
```

**Request payload:**
```json
{
  "contents": [{ "parts": [{ "text": "Text to speak" }] }],
  "generationConfig": {
    "responseModalities": ["AUDIO"],
    "speechConfig": {
      "voiceConfig": {
        "prebuiltVoiceConfig": { "voiceName": "Puck" }
      }
    }
  }
}
```

**Response processing:**
1. Extract base64 PCM data: `candidates[0].content.parts[0].inlineData.data`
2. Decode base64 to raw PCM bytes
3. Create 44-byte WAV header:
   - Sample rate: **24000 Hz**
   - Channels: **1** (mono)
   - Bits per sample: **16**
   - Audio format: **1** (PCM)
4. Concatenate header + PCM, encode as base64
5. Return as string (or null on any error)

**WAV header construction (PHP):**
```php
$header = pack('A4VA4', 'RIFF', 36 + $dataSize, 'WAVE')
    . pack('A4VvvVVvv', 'fmt ', 16, 1, $channels, $sampleRate,
        $sampleRate * $channels * $bitsPerSample / 8,
        $channels * $bitsPerSample / 8, $bitsPerSample)
    . pack('A4V', 'data', $dataSize);
```

**Language detection:** Gemini TTS auto-detects the language from the text content. No explicit language parameter is needed — Uzbek text produces Uzbek speech, Russian text produces Russian speech.

**Frontend playback:**
```javascript
const audio = new Audio(`data:audio/wav;base64,${base64String}`);
audio.play();
```

### 2.9 Reply Text Cleaning

PHP applies 5 regex passes to strip any technical content that leaks through the prompt:

```php
// 1. Remove markdown code blocks (```...```)
$replyText = preg_replace('/```[\s\S]*?```/', '', $replyText);

// 2. Remove inline code containing SQL keywords
$replyText = preg_replace('/`[^`]*(?:SELECT|UPDATE|FROM|JOIN|WHERE|execute_sql)[^`]*`/i', '', $replyText);

// 3. Remove execute_sql(...) function call syntax
$replyText = preg_replace('/execute_sql\s*\([^)]*\)/i', '', $replyText);

// 4. Remove standalone SQL statements (lines starting with SELECT/UPDATE)
$replyText = preg_replace('/^\s*(?:SELECT|UPDATE)\b[^.!?\n]*$/mi', '', $replyText);

// 5. Collapse excessive whitespace
$replyText = preg_replace('/\n{3,}/', "\n\n", trim($replyText));
```

### 2.10 Frontend Architecture

**Component tree:**
```
App
├── Dashboard (no props — fetches GET data on mount)
└── ChatWidget (no props — self-contained)
    ├── ChatPanel (props: messages, isLoading, onSend, lang)
    │   ├── SuggestedQuestions (props: onSelect, lang) — shown when messages is empty
    │   └── DataTable (rendered inline for each message with data)
    ├── ToolStatus (props: toolName)
    └── VoiceInput (props: onSend, disabled, lang, onLangChange)
```

**ChatWidget state:**

| State | Type | Purpose |
|-------|------|---------|
| `isOpen` | boolean | Chat panel visibility |
| `messages` | array | `[{ role, text, toolCalls?, data? }]` — initialized from localStorage, persisted on change (max 50) |
| `isLoading` | boolean | API request in progress |
| `currentTool` | string\|null | Tool name for loading indicator |
| `lang` | string | `'ru-RU'` or `'uz-UZ'` |
| `ttsEnabled` | boolean | Voice output on/off |
| `isSpeaking` | boolean | Audio currently playing |
| `audioRef` | ref | Current HTML5 Audio instance |

**Key callbacks:**
- `sendMessage(text)` — sends message with last 10 messages as history context
- `clearHistory()` — clears messages and removes localStorage entry

**Message object shapes:**
```javascript
// User message
{ role: 'user', text: 'user input' }

// Assistant message
{ role: 'assistant', text: 'reply', toolCalls: [...], data: [...] }
```

**DataTable rendering logic:**
- `Array` of flat objects → HTML `<table>` with columns auto-detected from first row's keys (skip nested object values)
- `Object` with nested values → sections: array values render as tables, object values render as key-value grids, primitives render as single fields
- `null` → nothing (in compact mode) or empty state placeholder

**TTS toggle (3 states):**
- Enabled + idle → speaker icon with waves
- Currently playing → stop (square) icon — click to stop audio
- Disabled → speaker with X icon — click to re-enable

**Tool status display:** Shows tool name during AI processing. Labels: `thinking` → "AI думает...", `execute_sql` → "Выполнение SQL запроса...". Hidden 2 seconds after response arrives.

### 2.11 Bilingual Support

```
User clicks RU or UZ toggle
  → VoiceInput calls onLangChange("ru-RU" or "uz-UZ")
  → ChatWidget stores lang in state
  → lang sent in POST body with every message
  → PHP selects system instruction language directive
  → Gemini responds in the selected language
  → TTS auto-detects language from text (no explicit param needed)
  → Voice input uses lang as recognition.lang for Web Speech API
```

---

## 3. Claude Code Integration Prompt

Copy the entire block below and paste it into Claude Code along with the target ERP codebase.

````
You are integrating an AI Factory Assistant agent into an existing ERP system. The ERP already has a working backend and frontend. Your task is to add a conversational AI chat agent that lets users query and update the MySQL database using natural language.

IMPORTANT: The backend logic, API response format, function calling flow, SQL validation, and TTS generation must be implemented EXACTLY as described below. The frontend design can differ but must handle the same API contract.

## BACKEND REQUIREMENTS

Create a single PHP API endpoint that handles both GET (dashboard data) and POST (AI chat).

### CORS & Routing
- Set headers: Content-Type application/json, Access-Control-Allow-Origin (frontend origin), Allow-Methods GET/POST/OPTIONS, Allow-Headers Content-Type
- Return 204 on OPTIONS requests
- Route GET to dashboard handler, POST to AI chat handler

### POST Request/Response
- Accept: `{ "message": string, "lang": "ru-RU" | "uz-UZ", "history": [{ "role": string, "text": string }] }`
- Return: `{ "reply": string, "tool_calls": array, "data": array|object|null, "audio": string|null }`
- Return `{ "error": string }` on failures

### Database Schema Discovery (Cached)
The schema is queried from INFORMATION_SCHEMA.COLUMNS and **cached to a temp file with a 5-minute TTL** (`factory_schema_cache.json`). On each POST request, the cache is checked first:
```sql
SELECT TABLE_NAME, COLUMN_NAME, COLUMN_TYPE, IS_NULLABLE, COLUMN_KEY, COLUMN_COMMENT
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = '<db_name>'
ORDER BY TABLE_NAME, ORDINAL_POSITION
```
Format as text block:
```
TABLE: <table_name>
  <column> <type>[PK] [NOT NULL|NULL] [-- comment]
```

### System Instruction
Build dynamically with these 4 parts concatenated:

1. Bilingual intro + language directive:
   - Always include both: "Siz zavod yordamchisisiz. Bu ishlab chiqarish ERP tizimi. / Вы помощник завода. Это ERP-система управления производством."
   - For ru-RU append: "Отвечайте только на русском языке."
   - For uz-UZ append: "Faqat o'zbek tilida javob bering."

2. Response rules (include EXACTLY):
```
RESPONSE RULES:
- Keep answers SHORT and DIRECT. No filler words, no unnecessary explanations.
- Just state the facts. If data is returned, summarize it briefly in 1-2 sentences.
- CRITICAL: Your text response must ONLY contain natural human-readable text. NEVER include:
  * SQL code or queries (SELECT, UPDATE, FROM, JOIN, WHERE, etc.)
  * Code blocks or inline code
  * Function calls like execute_sql(...)
  * Technical column names, table names, or database terms
  * Any programming syntax whatsoever
- Never say "I executed a query" or "Here are the results". Just give the answer naturally.
- For tables: the data will be shown automatically in the UI. Just add a brief text summary.
- For updates: confirm what was changed in one sentence.
- Accuracy is the top priority. Never guess or invent data — always query first.
- Respond as if you are a human assistant who looked up the information, not a program that ran code.
```

3. Schema text: "DATABASE SCHEMA:\n" + the formatted schema from INFORMATION_SCHEMA

4. SQL rules (include EXACTLY):
```
SQL RULES:
- You may ONLY use SELECT and UPDATE statements.
- DELETE, INSERT, DROP, CREATE, ALTER, TRUNCATE are FORBIDDEN.
- All timestamps in the database are Unix timestamps (integer seconds since epoch).
- Use FROM_UNIXTIME() to format dates for display.
- Use UNIX_TIMESTAMP() when comparing with date inputs.
- Always include reasonable LIMIT on SELECT queries (max 200 rows).
- For UPDATE: always include a WHERE clause. Never update without conditions.
- Use JOINs to get human-readable names.
- The `user` table contains sensitive data. NEVER select or update: password_hash, auth_key, password_reset_token, access_token, verification_token, expiret_access_token columns.
- The `migration` table is internal. Do not query it.
```

### Gemini API Integration

**Model:** gemini-2.5-flash
**Endpoint:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={API_KEY}`

**Tool declaration (exactly one tool):**
```json
{
  "name": "execute_sql",
  "description": "Execute a SQL query against the factory ERP MySQL database. Only SELECT and UPDATE statements are allowed. DELETE, DROP, INSERT, CREATE, ALTER, TRUNCATE are forbidden. For SELECT: returns rows as array. For UPDATE: returns affected row count. If query has an error, you get the error message and can retry.",
  "parameters": {
    "type": "object",
    "properties": {
      "sql": {
        "type": "string",
        "description": "A valid MySQL 8.0 SQL statement. Only SELECT and UPDATE allowed."
      }
    },
    "required": ["sql"]
  }
}
```

**Payload structure:**
```json
{
  "system_instruction": { "parts": [{ "text": "<system instruction>" }] },
  "contents": [ <conversation turns> ],
  "tools": [{ "function_declarations": [<tool above>] }]
}
```

### Function Calling Loop (max 5 iterations)

```
for i = 0 to 4:
  1. POST payload to Gemini endpoint (timeout 60s)
  2. Handle errors: curl error, HTTP != 200, no candidate
  3. Parse response parts:
     - SKIP parts with `thought` field (Gemini thinking mode)
     - Extract `functionCall` if present
     - Extract `text` parts (only those without `thought`)
     - IMPORTANT: Cast functionCall args to object (PHP json_decode turns {} into [])
  4. Append cleaned model response to contents array (role: "model")
  5. If NO functionCall:
     - Concatenate all text parts as reply
     - Clean reply text (5 regex passes — see below)
     - Generate TTS audio
     - Return { reply, tool_calls, data, audio }
  6. If functionCall exists:
     - Log to toolCallsLog: { name, args }
     - If name == "execute_sql": validate SQL → execute if valid
     - If validation fails: result = { error: "SQL rejected: <reason>" }
     - If PDOException: result = { error: "SQL execution error: <message>" }
     - Save lastToolResult = result['data'] ?? result
     - Append functionResponse to contents:
       { role: "user", parts: [{ functionResponse: { name: "<fn>", response: { result: <result> } } }] }
     - Continue loop

If loop exceeds 5 iterations: return { error: "Too many function call iterations" }
```

### SQL Validation (validate_sql)

Implement these 6 checks in order:

1. Strip leading SQL comments: `/^(--[^\n]*\n|\/\*.*?\*\/\s*)+/s`
2. First word must be SELECT or UPDATE (case-insensitive)
3. Scan for forbidden keywords (regex word-boundary `/\b{kw}\b/i`):
   `DELETE, DROP, CREATE, ALTER, TRUNCATE, INSERT, GRANT, REVOKE, REPLACE, RENAME, LOAD, CALL, INTO\s+OUTFILE, INTO\s+DUMPFILE, BENCHMARK, SLEEP`
4. Strip trailing `;` and whitespace. If any `;` remains, reject (multi-statement)
5. SELECT without LIMIT (`/\bLIMIT\b/i`): auto-append `LIMIT 200`
6. UPDATE: extract table name (`/^UPDATE\s+`?(\w+)`?/i`). Must be in whitelist:
   `product, material, client, supplier, order, order_item, sale, sale_item, purchase, purchase_item, production_batch, warehouse, recipe, recipe_item, price, product_packaging, product_category, material_category, app_settings, stock`

### SQL Execution

- SELECT: `$db->query($sql)->fetchAll()` → return `{ success: true, row_count: N, data: [rows] }`
- UPDATE: `$db->query($sql)` → return `{ success: true, affected_rows: N }`

### Reply Text Cleaning (5 regex passes)

```php
$text = preg_replace('/```[\s\S]*?```/', '', $text);
$text = preg_replace('/`[^`]*(?:SELECT|UPDATE|FROM|JOIN|WHERE|execute_sql)[^`]*`/i', '', $text);
$text = preg_replace('/execute_sql\s*\([^)]*\)/i', '', $text);
$text = preg_replace('/^\s*(?:SELECT|UPDATE)\b[^.!?\n]*$/mi', '', $text);
$text = preg_replace('/\n{3,}/', "\n\n", trim($text));
```

### TTS Audio Generation

**Model:** gemini-2.5-flash-preview-tts
**Endpoint:** `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent?key={API_KEY}`

**Payload:**
```json
{
  "contents": [{ "parts": [{ "text": "<reply text>" }] }],
  "generationConfig": {
    "responseModalities": ["AUDIO"],
    "speechConfig": {
      "voiceConfig": {
        "prebuiltVoiceConfig": { "voiceName": "Puck" }
      }
    }
  }
}
```

**Processing:**
1. Extract base64 PCM: `candidates[0].content.parts[0].inlineData.data`
2. Decode base64 to raw bytes
3. Create WAV header: 24000 Hz, mono, 16-bit PCM, 44 bytes
4. Return base64_encode(header + pcm)
5. Return null on any error (TTS is optional, never blocks the response)

## FRONTEND REQUIREMENTS

These describe the functional requirements. UI design is flexible.

### Chat Widget
- Floating chat button (bottom-right corner) that opens a chat panel
- State: messages array, loading flag, current tool name, language (ru-RU/uz-UZ), TTS enabled, is speaking
- Send POST to API endpoint with { message, lang }
- Handle response: add assistant message { text: reply, toolCalls, data }, play audio
- On network error: show error message as assistant message

### Message Display
- User messages and assistant messages with different styling
- Assistant messages with `data` field: render inline data table
- Typing animation (3 dots) while loading

### Data Table
- Array of flat objects → HTML table with auto-detected columns
- Object with nested values → sections (arrays as tables, objects as key-value grids)
- Handle null gracefully

### Voice Input (Web Speech API)
- Hold-to-record microphone button
- SpeechRecognition with lang set to current language
- interimResults: true, continuous: false
- Auto-send finalized transcript on recognition end
- Gracefully handle unsupported browsers

### Language Toggle
- RU / UZ buttons
- Selection stored in state and sent with every API request

### TTS Audio Playback
- Play base64 WAV via `new Audio('data:audio/wav;base64,' + data)`
- Toggle button: enable/disable TTS, stop current playback
- 3 visual states: enabled, playing (stop icon), disabled

### Tool Status
- Show loading indicator during AI processing
- Labels: "thinking" → "AI думает...", "execute_sql" → "Выполнение SQL запроса..."
- Hide 2 seconds after response

## INTEGRATION NOTES
- Adapt CORS origin to your frontend URL
- Adapt database credentials (host, port, name, user, password)
- Adapt API proxy configuration for your build tool (e.g., Vite proxies /api/* to PHP server)
- The SSL CA bundle path may need adjustment for your environment
- The UPDATE table whitelist should be adapted to match your ERP's business tables vs system tables
- The sensitive columns list in SQL rules should be adapted to your user table structure
````

---

## 4. Manual Integration Guide

### 4.1 Prerequisites

- [ ] PHP 8.2+ with `curl` and `pdo_mysql` extensions
- [ ] MySQL 8.0 database accessible from PHP
- [ ] Google Gemini API key (get from [Google AI Studio](https://aistudio.google.com/))
- [ ] Models enabled: `gemini-2.5-flash`, `gemini-2.5-flash-preview-tts`
- [ ] Frontend project (React, Vue, etc.)
- [ ] Chrome or Edge browser (for Web Speech API)

### 4.2 Backend Step-by-Step

#### Step 1: Create Configuration File

Create `config.php` with database credentials, API key, and a PDO singleton:

```php
<?php
define('DB_HOST', '127.0.0.1');
define('DB_PORT', 3306);
define('DB_NAME', 'your_database_name');
define('DB_USER', 'your_user');
define('DB_PASS', 'your_password');

define('GEMINI_API_KEY', 'your-gemini-api-key');
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
```

#### Step 2: Create API Endpoint with CORS & Routing

Create `agent_bridge.php`:

```php
<?php
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: http://localhost:5173'); // adapt to your frontend
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

require_once __DIR__ . '/config.php';

if ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Dashboard handler — adapt to your ERP's dashboard queries
    // Return JSON with whatever dashboard data you need
    exit;
}

// POST: AI Chat
$input = json_decode(file_get_contents('php://input'), true);
$userMessage = trim($input['message'] ?? '');
$userLang = $input['lang'] ?? 'ru-RU';
$history = $input['history'] ?? [];

if ($userMessage === '') {
    echo json_encode(['error' => 'Empty message']);
    exit;
}

// ... (Steps 3-11 go here)
```

#### Step 3: Implement Schema Discovery

Add this function to your endpoint file:

```php
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
```

#### Step 4: Build System Instruction

See [Section 2.5](#25-system-instruction) for the exact template. Concatenate:
1. Bilingual intro + language directive (based on `$userLang`)
2. Response rules block (copy verbatim)
3. `"DATABASE SCHEMA:\n" . get_schema_description(getDB())`
4. SQL rules block (copy verbatim)

#### Step 5: Define Tool Declaration

```php
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
```

#### Step 6: Implement SQL Validation

```php
function validate_sql(string $sql): array
{
    $sql = trim($sql);
    $sql = preg_replace('/^(--[^\n]*\n|\/\*.*?\*\/\s*)+/s', '', $sql);
    $sql = trim($sql);

    $firstWord = strtoupper(strtok($sql, " \t\r\n("));

    if (!in_array($firstWord, ['SELECT', 'UPDATE'], true)) {
        return ['valid' => false, 'error' => "Only SELECT and UPDATE are allowed. Got: {$firstWord}"];
    }

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

    $stripped = rtrim($sql, "; \t\r\n");
    if (strpos($stripped, ';') !== false) {
        return ['valid' => false, 'error' => 'Multiple statements are not allowed.'];
    }
    $sql = $stripped;

    if ($firstWord === 'SELECT' && !preg_match('/\bLIMIT\b/i', $sql)) {
        $sql .= ' LIMIT 200';
    }

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
```

#### Step 7: Implement SQL Execution

```php
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
```

#### Step 8: Implement the Function Calling Loop

This is the core of the AI agent. See [Section 2.4](#24-gemini-function-calling) for the full flow.

```php
$schemaText = get_schema_description(getDB());

// Build system instruction (Step 4)
$systemInstruction = "..."; // see Section 2.5

// Build conversation with history for context
$contents = [];
if (is_array($history)) {
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

for ($i = 0; $i < 5; $i++) {
    $payload = [
        'system_instruction' => ['parts' => [['text' => $systemInstruction]]],
        'contents'           => $contents,
        'tools'              => [['function_declarations' => $toolDeclarations]],
    ];

    // cURL POST to Gemini (timeout 60s)
    $ch = curl_init($geminiEndpoint);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST           => true,
        CURLOPT_HTTPHEADER     => ['Content-Type: application/json'],
        CURLOPT_POSTFIELDS     => json_encode($payload, JSON_UNESCAPED_UNICODE),
        CURLOPT_TIMEOUT        => 60,
    ]);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    curl_close($ch);

    // Handle errors
    if ($curlError) { echo json_encode(['error' => 'Connection error: ' . $curlError]); exit; }
    if ($httpCode !== 200) {
        $errorBody = json_decode($response, true);
        $errorMsg = $errorBody['error']['message'] ?? ('HTTP ' . $httpCode);
        echo json_encode(['error' => 'Gemini API: ' . $errorMsg]); exit;
    }

    $geminiResponse = json_decode($response, true);
    $candidate = $geminiResponse['candidates'][0]['content'] ?? null;

    if (!$candidate) {
        $blockReason = $geminiResponse['candidates'][0]['finishReason'] ?? 'unknown';
        echo json_encode(['error' => 'No response from AI (reason: ' . $blockReason . ')']); exit;
    }

    // Parse response — filter thought parts, extract functionCall
    $cleanParts = [];
    $functionCall = null;
    foreach ($candidate['parts'] as $part) {
        $cleanPart = [];
        if (isset($part['text']) && empty($part['thought'])) {
            $cleanPart['text'] = $part['text'];
        }
        if (isset($part['functionCall'])) {
            $fc = $part['functionCall'];
            $fc['args'] = (object)($fc['args'] ?? []);  // CRITICAL: cast {} back from []
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

    // No function call → final response
    if (!$functionCall) {
        $replyText = '';
        foreach ($candidate['parts'] as $part) {
            if (isset($part['text']) && empty($part['thought'])) {
                $replyText .= $part['text'];
            }
        }

        // Clean reply (Step 10)
        // Generate TTS (Step 9)
        $audio = generate_tts($replyText);

        echo json_encode([
            'reply'      => $replyText,
            'tool_calls' => $toolCallsLog,
            'data'       => $lastToolResult,
            'audio'      => $audio,
        ], JSON_UNESCAPED_UNICODE);
        exit;
    }

    // Execute function call
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
        $result = ['error' => 'SQL execution error: ' . $e->getMessage()];
    } catch (Throwable $e) {
        $result = ['error' => 'Execution failed: ' . $e->getMessage()];
    }

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
```

#### Step 9: Implement TTS Generation

```php
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
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST           => true,
        CURLOPT_HTTPHEADER     => ['Content-Type: application/json'],
        CURLOPT_POSTFIELDS     => $payload,
        CURLOPT_TIMEOUT        => 30,
    ]);
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    if ($httpCode !== 200) return null;

    $json = json_decode($response, true);
    $pcmBase64 = $json['candidates'][0]['content']['parts'][0]['inlineData']['data'] ?? null;
    if (!$pcmBase64) return null;

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
```

#### Step 10: Implement Reply Text Cleaning

Add these 5 regex passes before returning the reply (insert in the "No function call → final response" block, before `generate_tts`):

```php
$replyText = preg_replace('/```[\s\S]*?```/', '', $replyText);
$replyText = preg_replace('/`[^`]*(?:SELECT|UPDATE|FROM|JOIN|WHERE|execute_sql)[^`]*`/i', '', $replyText);
$replyText = preg_replace('/execute_sql\s*\([^)]*\)/i', '', $replyText);
$replyText = preg_replace('/^\s*(?:SELECT|UPDATE)\b[^.!?\n]*$/mi', '', $replyText);
$replyText = preg_replace('/\n{3,}/', "\n\n", trim($replyText));
```

#### Step 11: Assemble Final Response

Already shown in Step 8. The JSON response is:
```php
echo json_encode([
    'reply'      => $replyText,     // Cleaned AI answer
    'tool_calls' => $toolCallsLog,  // Array of { name, args } for all tool calls
    'data'       => $lastToolResult, // Last SQL result (rows array or { affected_rows })
    'audio'      => $audio,          // Base64 WAV string or null
], JSON_UNESCAPED_UNICODE);
```

### 4.3 Frontend Step-by-Step

These steps use React syntax but the logic applies to any framework.

#### Step 1: Create ChatWidget Component

The central component managing all chat state:

```jsx
import React, { useState, useCallback, useRef, useEffect } from 'react';

const STORAGE_KEY = 'factory_chat_history';

export default function ChatWidget() {
  const [isOpen, setIsOpen] = useState(false);
  const [messages, setMessages] = useState(() => {
    try {
      const saved = localStorage.getItem(STORAGE_KEY);
      return saved ? JSON.parse(saved) : [];
    } catch { return []; }
  });
  const [isLoading, setIsLoading] = useState(false);
  const [currentTool, setCurrentTool] = useState(null);
  const [lang, setLang] = useState('ru-RU');
  const [ttsEnabled, setTtsEnabled] = useState(true);
  const [isSpeaking, setIsSpeaking] = useState(false);
  const audioRef = useRef(null);

  // Persist chat history to localStorage (last 50 messages)
  useEffect(() => {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(messages.slice(-50)));
    } catch {}
  }, [messages]);

  const clearHistory = useCallback(() => {
    setMessages([]);
    localStorage.removeItem(STORAGE_KEY);
  }, []);

  const playAudio = useCallback((base64Wav) => {
    if (!ttsEnabled || !base64Wav) return;
    if (audioRef.current) { audioRef.current.pause(); audioRef.current = null; }

    const audio = new Audio(`data:audio/wav;base64,${base64Wav}`);
    audio.onplay = () => setIsSpeaking(true);
    audio.onended = () => setIsSpeaking(false);
    audio.onerror = () => setIsSpeaking(false);
    audioRef.current = audio;
    audio.play();
  }, [ttsEnabled]);

  const stopSpeaking = useCallback(() => {
    if (audioRef.current) { audioRef.current.pause(); audioRef.current = null; }
    setIsSpeaking(false);
  }, []);

  const toggleTts = useCallback(() => {
    if (ttsEnabled) stopSpeaking();
    setTtsEnabled((prev) => !prev);
  }, [ttsEnabled, stopSpeaking]);

  const sendMessage = useCallback(async (text) => {
    setMessages((prev) => [...prev, { role: 'user', text }]);
    setIsLoading(true);
    setCurrentTool('thinking');

    try {
      const res = await fetch('/api/agent_bridge.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          message: text,
          lang,
          history: messages.slice(-10).map(m => ({ role: m.role, text: m.text })),
        }),
      });
      const json = await res.json();

      if (json.tool_calls?.length) {
        setCurrentTool(json.tool_calls[json.tool_calls.length - 1].name);
      }

      setMessages((prev) => [
        ...prev,
        {
          role: 'assistant',
          text: json.reply || json.error || 'No response',
          toolCalls: json.tool_calls,
          data: json.data,
        },
      ]);

      playAudio(json.audio);
    } catch (err) {
      setMessages((prev) => [
        ...prev,
        { role: 'assistant', text: 'Connection error.' },
      ]);
    } finally {
      setIsLoading(false);
      setTimeout(() => setCurrentTool(null), 2000);
    }
  }, [lang, playAudio]);

  // Render: floating button when closed, chat panel when open
  // Include: ChatPanel, ToolStatus, VoiceInput, TTS toggle button
}
```

#### Step 2: Create Message List (ChatPanel)

```jsx
import React, { useEffect, useRef } from 'react';
import DataTable from './DataTable';

export default function ChatPanel({ messages, isLoading }) {
  const bottomRef = useRef(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages, isLoading]);

  return (
    <div className="chat-panel">
      {messages.map((msg, i) => (
        <div key={i} className={`chat-msg ${msg.role}`}>
          <div className="msg-label">{msg.role === 'user' ? 'You' : 'AI'}</div>
          <div className="msg-text">{msg.text}</div>
          {msg.data && <DataTable data={msg.data} compact />}
        </div>
      ))}

      {isLoading && (
        <div className="chat-msg assistant">
          <div className="msg-label">AI</div>
          <div className="msg-text typing">
            <span className="dot" /><span className="dot" /><span className="dot" />
          </div>
        </div>
      )}

      <div ref={bottomRef} />
    </div>
  );
}
```

#### Step 3: Create Voice Input

```jsx
const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;

export default function VoiceInput({ onSend, disabled, lang, onLangChange }) {
  const [text, setText] = useState('');
  const [isListening, setIsListening] = useState(false);
  const recognitionRef = useRef(null);
  const finalTranscriptRef = useRef('');

  const startListening = useCallback(() => {
    if (!SpeechRecognition) { alert('Use Chrome for voice input.'); return; }
    if (disabled) return;

    finalTranscriptRef.current = '';
    const recognition = new SpeechRecognition();
    recognition.lang = lang;          // 'ru-RU' or 'uz-UZ'
    recognition.interimResults = true;
    recognition.continuous = false;

    recognition.onstart = () => setIsListening(true);

    recognition.onresult = (event) => {
      let interim = '', final = '';
      for (let i = 0; i < event.results.length; i++) {
        if (event.results[i].isFinal) final += event.results[i][0].transcript;
        else interim += event.results[i][0].transcript;
      }
      finalTranscriptRef.current = final;
      setText(final || interim);
    };

    recognition.onend = () => {
      setIsListening(false);
      const transcript = finalTranscriptRef.current.trim();
      if (transcript) { onSend(transcript); setText(''); finalTranscriptRef.current = ''; }
    };

    recognition.onerror = (e) => {
      setIsListening(false);
      if (e.error !== 'no-speech' && e.error !== 'aborted') console.error(e.error);
    };

    recognitionRef.current = recognition;
    recognition.start();
  }, [lang, disabled, onSend]);

  const stopListening = useCallback(() => { recognitionRef.current?.stop(); }, []);

  // Render: language toggle (RU/UZ buttons), text input, mic button (onMouseDown/Up/Leave), send button
}
```

Key: The mic button uses `onMouseDown={startListening}` / `onMouseUp={stopListening}` / `onMouseLeave={stopListening}` for hold-to-record behavior.

#### Step 4: Create DataTable

Renders three data shapes. See [Section 2.10](#210-frontend-architecture) for the full logic:

```jsx
export default function DataTable({ data, compact = false }) {
  if (!data) return compact ? null : <EmptyState />;

  // Array → HTML table
  if (Array.isArray(data)) return renderTable(data);

  // Object → sections (arrays as tables, objects as key-value grids, primitives as fields)
  return Object.entries(data).map(([key, value]) => {
    if (Array.isArray(value)) return <Section title={key}>{renderTable(value)}</Section>;
    if (value && typeof value === 'object') return <Section title={key}><KVGrid data={value} /></Section>;
    return <Field label={key} value={value} />;
  });
}

function renderTable(rows) {
  const columns = Object.keys(rows[0]).filter(c => typeof rows[0][c] !== 'object' || rows[0][c] === null);
  // Render <table> with columns as headers, rows as body
}
```

#### Step 5: Create Tool Status Indicator

```jsx
const TOOL_LABELS = {
  thinking: 'AI thinking...',
  execute_sql: 'Executing SQL query...',
};

export default function ToolStatus({ toolName }) {
  if (!toolName) return null;
  return (
    <div className="tool-status">
      <div className="tool-status-bar" />  {/* Animated progress bar */}
      <span>{TOOL_LABELS[toolName] || `${toolName}...`}</span>
    </div>
  );
}
```

#### Step 6: Configure API Proxy

For Vite:
```javascript
// vite.config.js
export default {
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:8000',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, ''),
      },
    },
  },
};
```

Adapt for your build tool (webpack devServer, Next.js rewrites, nginx reverse proxy, etc.).

### 4.4 Testing Checklist

- [ ] **Suggested questions**: Open empty chat → see clickable question chips by category → click one → sends the question
- [ ] **Conversation memory**: Ask "Show all products" → then ask "How many are there?" → AI should understand the follow-up
- [ ] **Chat persistence**: Send a message → refresh page → messages should still be there
- [ ] **Clear history**: Click trash icon in header → all messages cleared → suggested questions reappear
- [ ] **Basic text query**: Send "Show all products" → get reply with data table
- [ ] **SQL validation - blocked operations**: Verify DELETE/DROP/INSERT are rejected (check server logs)
- [ ] **Error recovery**: Send a question that might cause Gemini to write bad SQL → verify it retries and returns correct answer
- [ ] **UPDATE operation**: Send "Change product name X to Y" → verify it works on whitelisted tables
- [ ] **UPDATE blocked**: Verify UPDATE on `user` or `migration` tables is rejected
- [ ] **TTS audio**: Verify audio plays after response (check browser console for Audio errors)
- [ ] **TTS toggle**: Disable TTS → verify no audio plays. Re-enable → verify audio resumes.
- [ ] **Language switch**: Switch to UZ → send a question → verify response is in Uzbek
- [ ] **Voice input**: Hold mic → speak → release → verify auto-send
- [ ] **Data table rendering**: Verify arrays render as tables, nested objects render as sections
- [ ] **Error handling**: Stop PHP server → send message → verify "Connection error" shown
- [ ] **Multi-iteration**: Ask a complex question requiring multiple SQL queries → verify it works (check tool_calls array)
- [ ] **LIMIT enforcement**: Ask for "all records" from a large table → verify response has max 200 rows

---

## 5. Configuration Reference

| Config | Value | Location |
|--------|-------|----------|
| DB_HOST | `127.0.0.1` | config.php |
| DB_PORT | `3306` | config.php |
| DB_NAME | `<your_database>` | config.php |
| DB_USER | `<your_user>` | config.php |
| DB_PASS | `<your_password>` | config.php |
| GEMINI_API_KEY | `<your_api_key>` | config.php |
| GEMINI_MODEL | `gemini-2.5-flash` | config.php |
| GEMINI_TTS_MODEL | `gemini-2.5-flash-preview-tts` | config.php |
| TTS Voice | `Puck` | generate_tts() |
| TTS Sample Rate | `24000` Hz, mono, 16-bit | generate_tts() |
| Max function call iterations | `5` | Function calling loop |
| Auto LIMIT for SELECT | `200` rows | validate_sql() |
| cURL timeout (chat) | `60` seconds | Function calling loop |
| cURL timeout (TTS) | `30` seconds | generate_tts() |
| CORS origin | `http://localhost:5173` | agent_bridge.php |

**UPDATE Table Whitelist** (adapt to your ERP):
```
product, material, client, supplier, order, order_item,
sale, sale_item, purchase, purchase_item, production_batch,
warehouse, recipe, recipe_item, price, product_packaging,
product_category, material_category, app_settings, stock
```

**Forbidden SQL Keywords:**
```
DELETE, DROP, CREATE, ALTER, TRUNCATE, INSERT,
GRANT, REVOKE, REPLACE, RENAME, LOAD, CALL,
INTO OUTFILE, INTO DUMPFILE, BENCHMARK, SLEEP
```

**Sensitive Columns (blocked via system instruction):**
```
user table: password_hash, auth_key, password_reset_token,
            access_token, verification_token, expiret_access_token
```

**Blocked Tables (via system instruction):**
```
migration (internal schema tracking)
```
