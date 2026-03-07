# AI Factory Assistant — Architecture

## What Is This?

A web dashboard for a factory, with a floating AI chatbot in the bottom-right corner. Workers can ask questions about products, stock, production, orders, sales, materials — anything in the database — by voice or text, in Russian or Uzbek. The AI writes SQL queries to look up or update data, then answers in natural language.

**The AI writes SQL dynamically**, but PHP validates every query before execution. Only `SELECT` and `UPDATE` are allowed — no deleting, no creating tables, no inserting records.

---

## What Can The AI Do?

### It CAN:

| Capability | Example Question | What Happens |
|---|---|---|
| Query any table | "Покажи все продукты" | AI writes `SELECT ... FROM product ...` |
| Complex joins | "Какие материалы нужны для продукта 8?" | AI writes JOINs across recipe/recipe_item/material |
| Aggregations | "Сколько заказов за этот месяц?" | AI writes `COUNT`, `SUM`, `GROUP BY` queries |
| Stock info | "Что на складе?" | AI writes JOIN across stock/warehouse/product/material |
| Production stats | "Статистика производства" | AI writes aggregation on production_batch |
| Sales/purchases | "Покажи последние продажи" | AI queries sale + sale_item + client |
| Update records | "Измени название продукта 8 на Молоко" | AI writes `UPDATE product SET name='Молоко' WHERE id=8` |
| Answer in Russian | Select RU at the bottom | System prompt switches to Russian |
| Answer in Uzbek | Select UZ at the bottom | System prompt switches to Uzbek |
| Voice input | Hold the mic button and speak | Browser Speech API transcribes, auto-sends on release |
| Voice output | AI responds with audio | Gemini TTS generates natural speech (auto-play, can be toggled off) |
| General chat | "Привет, что ты умеешь?" | Responds without running SQL |

### It CANNOT (by design):

- **DELETE** anything from the database
- **INSERT** new records
- **CREATE/DROP/ALTER** tables
- **UPDATE** system tables (user, audit_log, migration, stock_txn, analytics)
- Access sensitive columns (passwords, auth tokens)
- Run multiple statements in one query
- Run queries without a LIMIT (auto-appended if missing, max 200 rows)

---

## Technologies

| Layer | What | Why |
|---|---|---|
| Frontend | React 19 + Vite 6 | Fast dev, modern UI |
| Backend | PHP 8.2 (built-in server) | Simple, no framework needed |
| AI (Chat) | Google Gemini 2.5 Flash | Function-calling support, fast |
| AI (TTS) | Google Gemini 2.5 Flash TTS | Natural speech with auto language detection |
| Database | MySQL 8.0 (Docker) | Factory ERP data (35 tables) |
| Voice In | Web Speech API (browser) | Speech-to-text for RU/UZ |
| Voice Out | Gemini 2.5 Flash TTS API | High-quality text-to-speech with auto language detection (Puck voice) |

---

## How It Works

```
User speaks or types a question
        |
        v
React frontend sends POST to /api/agent_bridge.php
  (includes last 10 messages as conversation history)
        |
        v
PHP builds conversation context from history + current message
        |
        v
PHP sends conversation + DB schema (cached, 5-min TTL) to Gemini AI
        |
        v
Gemini writes a SQL query: "SELECT p.id, p.name FROM product p LIMIT 200"
        |
        v
PHP validates the SQL (only SELECT/UPDATE allowed, no forbidden keywords)
        |
        v
PHP executes the query via PDO
        |
        v
PHP sends the results back to Gemini
        |
        v
Gemini writes a human-friendly answer
        |
        v
PHP cleans the reply text (strips any code blocks, SQL fragments)
        |
        v
PHP calls Gemini TTS API to generate audio from the reply text
        |
        v
React shows the answer + data table in the chat widget
        |
        v
Frontend plays the Gemini-generated WAV audio (if TTS enabled)
```

**3 API calls to Gemini per question** (one to write the SQL, one to explain the results, one to generate TTS audio).
Simple questions like "Hello" need only 2 calls (no SQL needed, but TTS still runs).
If Gemini writes bad SQL, PHP returns the error, and Gemini retries (up to 5 loop iterations).

---

## File Structure

```
demo_ai_integration/
|
|-- backend/
|   |-- config.php           <-- DB connection + Gemini API key + TTS model config
|   |-- tools.php            <-- PHP functions used by GET dashboard handler
|   |-- agent_bridge.php     <-- THE ONLY API ENDPOINT
|       |-- GET handler      <-- Dashboard data (hardcoded queries, no AI)
|       |-- POST handler     <-- AI chat (dynamic SQL via Gemini)
|       |-- validate_sql()   <-- Security gate for AI-generated SQL
|       |-- get_schema_description() <-- Reads DB schema from INFORMATION_SCHEMA
|       |-- generate_tts()  <-- Calls Gemini TTS API, returns base64 WAV audio
|
|-- frontend/
|   |-- vite.config.js       <-- Dev server + proxy /api/* to PHP
|   |-- src/
|       |-- App.jsx           <-- Layout shell (header + dashboard + widget)
|       |-- components/
|       |   |-- Dashboard.jsx           <-- Main page: stats cards + data tables
|       |   |-- ChatWidget.jsx          <-- Floating chat bubble (bottom-right)
|       |   |-- ChatPanel.jsx           <-- Message list inside the chat
|       |   |-- SuggestedQuestions.jsx   <-- Clickable question chips (empty state)
|       |   |-- VoiceInput.jsx          <-- Text input + mic + RU/UZ toggle
|       |   |-- ToolStatus.jsx          <-- Loading bar while AI thinks
|       |   |-- DataTable.jsx           <-- Renders tables from AI data
|       |-- styles/
|           |-- app.css         <-- Dark theme (navy + amber)
|
|-- pro_count_db.sql          <-- Database dump (35 tables)
```

---

## The Single API Endpoint

Everything goes through `agent_bridge.php`. No other endpoints.

| Method | What It Does |
|---|---|
| **GET** `/api/agent_bridge.php` | Returns dashboard data (products, stock, stats) — no AI, hardcoded queries |
| **POST** `/api/agent_bridge.php` | Sends user message to Gemini AI, AI writes SQL, PHP validates & executes |

### POST Request Body
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

### POST Response Body
```json
{
  "reply": "Вот список всех продуктов: ...",
  "tool_calls": [{ "name": "execute_sql", "args": { "sql": "SELECT ..." } }],
  "data": [{ "id": 8, "name": "Mahsulot 1", ... }],
  "audio": "UklGRi4A... (base64-encoded WAV audio)"
}
```

---

## How the AI Generates SQL

### Schema Discovery (Cached)
PHP queries `INFORMATION_SCHEMA.COLUMNS` to get the full database schema (all tables, columns, types). The result is **cached to a temp file with a 5-minute TTL** to avoid redundant queries on every request. This is included in the system instruction sent to Gemini, so the AI knows exactly what tables and columns exist.

### Single Tool: `execute_sql`
The AI has one tool available: `execute_sql(sql)`. It passes a SQL string, and PHP validates and executes it.

### SQL Validation (the security gate)
Before executing any AI-generated SQL, `validate_sql()` checks:

1. **Statement type** — first keyword must be `SELECT` or `UPDATE`
2. **Forbidden keywords** — blocks: DELETE, DROP, CREATE, ALTER, TRUNCATE, INSERT, GRANT, REVOKE, REPLACE, RENAME, LOAD, CALL, BENCHMARK, SLEEP, INTO OUTFILE, INTO DUMPFILE
3. **Multiple statements** — no semicolons inside the query body
4. **Auto LIMIT** — SELECTs without LIMIT get `LIMIT 200` appended
5. **UPDATE table whitelist** — only business tables allowed (product, material, client, order, sale, etc.). System tables blocked (user, audit_log, migration, stock_txn, analytics)

### Error Recovery
If the AI writes invalid SQL:
1. PDO throws an exception (syntax error, unknown column, etc.)
2. PHP catches it and returns the error as the function response
3. Gemini sees the error message and writes corrected SQL
4. The loop continues (max 5 iterations total)

---

## Frontend Components

### Page Layout
```
+----------------------------------------------------------+
| Header: "AI Zavod Yordamchisi"                            |
+----------------------------------------------------------+
|                                                            |
|  [Stats Cards: Products | In Progress | Completed | ...]  |
|                                                            |
|  +------------------+  +------------------+                |
|  | Products Table   |  | Stock Table      |                |
|  +------------------+  +------------------+                |
|                                                            |
|  +------------------+                                      |
|  | Production Stats |                                      |
|  +------------------+                                      |
|                                                            |
|                                           +----------+     |
|                                           | AI Chat  |     |
|                                           | Widget   |     |
|                                           | (popup)  |     |
|                                           +----------+     |
|                                              [fab btn]     |
+----------------------------------------------------------+
```

### Component Responsibilities

| Component | What It Does |
|---|---|
| `App.jsx` | Thin shell — renders header, Dashboard, ChatWidget |
| `Dashboard.jsx` | Fetches data on load (GET), shows 4 stat cards + 3 data tables |
| `ChatWidget.jsx` | Floating button (bottom-right). Click to open chat popup. Owns all chat state (messages, loading, language, TTS). Persists messages to localStorage (last 50). Sends last 10 messages as conversation history to backend. Has clear history button. Plays Gemini-generated WAV audio via HTML5 Audio. Speaker toggle in header to enable/disable/stop. |
| `ChatPanel.jsx` | Scrollable message list. Shows user/AI messages, SQL tool badges, inline data tables, typing animation. Shows suggested questions when chat is empty. |
| `SuggestedQuestions.jsx` | Clickable question chips organized by category (Production, Stock, Sales, Products). Bilingual (RU/UZ). Shown when chat history is empty. |
| `VoiceInput.jsx` | Text input + mic button + RU/UZ toggle. Hold mic to record, auto-sends on release. |
| `ToolStatus.jsx` | Animated bar showing "Выполнение SQL запроса..." during queries |
| `DataTable.jsx` | Smart renderer — handles flat arrays (table), nested objects (sections), key-value pairs (grid) |

### Language Flow
```
User clicks RU or UZ toggle
        |
        v
VoiceInput calls onLangChange("ru-RU" or "uz-UZ")
        |
        v
ChatWidget stores lang in state, sends it in POST body
        |
        v
PHP picks system instruction language + includes DB schema
        |
        v
Gemini responds in the selected language
```

### Text-to-Speech (TTS)
```
AI response arrives (with base64 WAV audio from Gemini TTS)
        |
        v
ChatWidget checks: is TTS enabled?
        |
   YES -+- NO -> just show text
        |
        v
Frontend decodes base64 WAV and plays via HTML5 Audio
(Gemini TTS auto-detects language from text — Uzbek text = Uzbek speech, Russian text = Russian speech)
        |
        v
User can:
  - Click speaker icon -> stop current audio
  - Click again -> disable TTS entirely
  - Speaker icon shows 3 states:
    - Waves icon (enabled, idle)
    - Stop square (currently playing - click to stop)
    - X icon (disabled - click to re-enable)
```

TTS is **on by default**. Uses **Gemini 2.5 Flash TTS API** (`gemini-2.5-flash-preview-tts`) with the **Puck** voice. Audio is generated server-side in PHP, converted from raw PCM to WAV (44-byte header added), and sent as base64 in the JSON response. The model auto-detects language, so Uzbek and Russian are spoken natively — no browser TTS dependency.

### Response Style
The system instruction tells Gemini to:
- Keep answers **short and direct** — no filler words
- **NEVER** include SQL code, code blocks, function calls, or technical column/table names
- Never say "I executed a query" — just give the answer naturally
- Respond as a human assistant who looked up the information, not a program that ran code
- For data tables: add a brief 1-2 sentence summary (the table renders automatically)
- For updates: confirm the change in one sentence
- **Accuracy is the top priority** — always query, never guess

### Reply Text Cleaning
As a safety net, PHP strips any technical content that slips through the prompt:
- Markdown code blocks (` ```...``` `)
- Inline code containing SQL keywords
- `execute_sql(...)` function call syntax
- Standalone SQL statements
- Excessive whitespace left behind

---

## Security

```
How it works:
  User -> Gemini AI -> writes SQL -> PHP validates -> executes if safe -> MySQL

What PHP blocks:
  DELETE, DROP, CREATE, ALTER, INSERT, TRUNCATE -> REJECTED
  UPDATE on user/audit_log/migration           -> REJECTED
  Multiple statements (SQL injection)          -> REJECTED
  SLEEP, BENCHMARK (DoS attacks)               -> REJECTED
  INTO OUTFILE (file writes)                   -> REJECTED
  SELECT without LIMIT                         -> auto-appended LIMIT 200
```

| Layer | Protection |
|---|---|
| Statement type | Only SELECT and UPDATE pass validation |
| Forbidden keywords | 16+ dangerous keywords blocked via regex word-boundary matching |
| Multi-statement block | Semicolons inside query body are rejected |
| UPDATE table whitelist | Only business tables (product, material, order, sale, etc.) |
| Auto LIMIT | Prevents unbounded result sets |
| Sensitive columns | System instruction forbids selecting passwords/tokens from user table |
| Error recovery | Bad SQL errors sent to Gemini for retry, not exposed to user |

---

## Conversation Memory & Persistence

### Conversation History
The frontend sends the **last 10 messages** (user + assistant) as a `history` array in every POST request. The backend maps these into Gemini's `contents[]` array as alternating `user`/`model` turns before the current message. This enables follow-up questions like "show me more details" or "filter that by last week".

### Chat History Persistence
Messages are persisted to **localStorage** (key: `factory_chat_history`, max 50 messages). Chat history survives page refreshes and browser restarts. A **clear history** button (trash icon) in the chat header resets the conversation.

### Schema Caching
The database schema is cached to a **temp file** (`factory_schema_cache.json`) with a **5-minute TTL**. This avoids querying `INFORMATION_SCHEMA.COLUMNS` on every request, reducing response latency.

### Suggested Questions
When the chat is empty, clickable **question chips** are shown organized by category:
- Production, Stock, Sales, Products
- Bilingual (Russian and Uzbek, based on current language)
- Clicking a chip sends the question immediately

---

## Database

MySQL 8.0 running in Docker. Database: `pro_count_db` (35 tables, Uzbek data).

### Table Groups

| Group | Tables | Description |
|---|---|---|
| Products | product, product_category, ref_unit, product_packaging | Products with categories, units, packaging |
| Materials | material, material_category | Raw materials with categories |
| Recipes | recipe, recipe_item | Product formulas with material requirements |
| Stock | stock, warehouse, stock_txn | Inventory across warehouses with transaction log |
| Production | production_batch, production_consume, production_output, product_cost_snapshot | Manufacturing batches and costs |
| Sales | sale, sale_item, profit_snapshot, client | Customer sales with profit tracking |
| Purchases | purchase, purchase_item, supplier | Vendor purchases |
| Orders | order, order_item | Customer orders |
| Pricing | price, ref_currency, ref_region | Dynamic pricing with regions |
| Analytics | daily_analytics, monthly_analytics | Aggregated business metrics |
| System | user, audit_log, app_message, app_settings, migration, mrp_draft | Internal system tables |

### Sample Data
- 3 products (Mahsulot 1, 2, 3)
- 3 materials (Xomashyo 1, 2, 3)
- 3 warehouses (MAIN, RAW, FINISHED)
- 4 stock entries
- 3 production batches

---

## How To Run

1. Start MySQL (Docker):
   ```
   docker start factory-db
   ```

2. Start PHP backend:
   ```
   cd backend
   php -S localhost:8000
   ```

3. Start React frontend:
   ```
   cd frontend
   npm run dev
   ```

4. Open `http://localhost:5173` in Chrome (Chrome needed for voice)

### Proxy Setup
Vite proxies `/api/*` to `http://localhost:8000/*` (removes the `/api` prefix).

```js
// vite.config.js
server: {
  proxy: {
    '/api': {
      target: 'http://localhost:8000',
      changeOrigin: true,
      rewrite: (path) => path.replace(/^\/api/, '')
    }
  }
}
```
