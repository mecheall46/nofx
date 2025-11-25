# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Repository Information

**Upstream Repository:**
- **Official Repo:** https://github.com/NoFxAiOS/nofx
- **Fork Owner:** mecheall46 (https://github.com/mecheall46/nofx)
- **Tracking Branch:** `dev` (tracks `upstream/dev`)

**Sync Strategy:**
```bash
# Check upstream updates
git fetch upstream dev

# View upstream changes
git log dev..upstream/dev

# Merge upstream changes
git merge upstream/dev

# Push to fork
git push origin dev
```

**Recent Upstream Updates (as of 2025-11-25):**
- ✅ **LIGHTER DEX Integration** (#1085) - Full SDK integration with V1/V2 support
- ✅ **Bybit Futures Support** (#1100) - USDT perpetual futures trading
- ✅ **HTTP Client Refactor** (#1061) - Axios with unified error handling
- ✅ **MCP Refactor** (#1042) - Improved AI client architecture
- ✅ **Multi-language Docs** - Korean, Vietnamese documentation

**Local Modifications:**
- `CLAUDE.md` - This documentation file (local only)
- `docs/work_log/` - Work diary and analysis reports (local only)
- `scripts/常用/` - Batch scripts for Windows (local only)
- `.gitignore` - Custom ignores (modified)
- `docker/Dockerfile.backend` - Go proxy configuration (modified)

---

## Project Overview

**NOFX** is an AI-powered cryptocurrency trading system that enables autonomous multi-agent trading across multiple exchanges (Binance, Hyperliquid, Aster DEX, Bybit, Lighter). The system uses Large Language Models (DeepSeek, Qwen, or custom OpenAI-compatible APIs) to make trading decisions based on technical analysis, historical performance, and real-time market data.

**Tech Stack:**
- **Backend:** Go 1.21+ with Gin framework, SQLite database
- **Frontend:** React 18 + TypeScript + Vite + TailwindCSS
- **Dependencies:** TA-Lib (technical indicators), go-ethereum (DEX support)
- **Deployment:** Docker Compose multi-stage builds

---

## Development Commands

### Building & Running

**Backend:**
```bash
# Install dependencies
go mod download

# Build binary
go build -o nofx

# Run locally
./nofx

# Note: Requires TA-Lib library installed
# macOS: brew install ta-lib
# Ubuntu: sudo apt-get install libta-lib0-dev
```

**Frontend:**
```bash
cd web
npm install
npm run dev          # Development server on :3000
npm run build        # Production build to ./dist
```

**Docker (Recommended for Production):**
```bash
# Quick start with convenience script
./start.sh start --build

# Or use docker compose directly
docker compose up -d --build

# View logs
./start.sh logs      # or: docker compose logs -f

# Stop services
./start.sh stop      # or: docker compose down
```

### Testing

```bash
# Backend tests
make test-backend    # or: go test -v ./...
go test -race ./...  # Race condition detection

# Frontend tests
make test-frontend   # or: cd web && npm run test

# All tests
make test

# Code coverage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

### Code Quality

```bash
# Go formatting
make fmt             # or: go fmt ./...

# Frontend linting
cd web
npm run lint
npm run lint:fix     # Auto-fix issues
```

---

## Architecture Overview

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    React Frontend (Port 3000)                │
│  - Trader Dashboard, Competition Leaderboard, Config UI     │
└────────────────────────┬────────────────────────────────────┘
                         │ HTTP/REST API (JWT Auth)
┌────────────────────────▼────────────────────────────────────┐
│               Go Backend API Server (Port 8080)              │
│                     (Gin Framework)                          │
└─────┬──────────┬──────────────┬────────────┬────────────────┘
      │          │              │            │
┌─────▼─────┐┌──▼──────┐┌──────▼──────┐┌───▼────────────────┐
│  Trader   ││ Decision││   Market    ││  SQLite Database   │
│  Manager  ││  Engine ││   Monitor   ││  (config.db)       │
│           ││         ││             ││                    │
│ Multi-    ││ AI API  ││ WebSocket   ││ - Users/Traders    │
│ Trader    ││ (DeepSeek││ Binance    ││ - AI/Exchange      │
│ Lifecycle ││  Qwen)  ││ K-line Cache││   Configs          │
└─────┬─────┘└──┬──────┘└──────┬──────┘└───┬────────────────┘
      │         │              │            │
┌─────▼─────────▼──────────────▼────────────▼────────────────┐
│              Exchange Integrations (Trader Interface)        │
│  - Binance Futures (REST API)                               │
│  - Hyperliquid (DEX L1)                                     │
│  - Aster DEX (EVM-compatible)                               │
│  - Bybit, Lighter (partial support)                         │
└─────────────────────────────────────────────────────────────┘
```

### Key Packages & Responsibilities

| Package | Purpose | Key Files |
|---------|---------|-----------|
| **`api/`** | HTTP REST API server, authentication, route handlers | `server.go`, `crypto_handler.go` |
| **`trader/`** | Exchange integrations, unified trader interface | `auto_trader.go`, `binance_futures.go`, `hyperliquid_trader.go` |
| **`manager/`** | Multi-trader orchestration, lifecycle management | `trader_manager.go` |
| **`decision/`** | AI decision engine, context building, risk validation | `engine.go`, `validate.go`, `prompt_manager.go` |
| **`market/`** | Real-time price data, K-line caching, technical indicators | `monitor.go`, `types.go`, `websocket_client.go` |
| **`config/`** | SQLite database operations, schema migrations | `database.go`, `config.go` |
| **`mcp/`** | AI API clients (DeepSeek, Qwen, custom OpenAI) | `mcp_client.go`, `deepseek_client.go` |
| **`logger/`** | Decision logging, performance analysis, PnL tracking | `decision_logger.go` |
| **`pool/`** | Coin selection (AI500 pool, OI Top ranking) | `manager.go` |
| **`auth/`** | JWT token management, user authentication, 2FA | `auth.go` |
| **`crypto/`** | RSA encryption for sensitive data | `encryption.go`, `secure_storage.go` |
| **`bootstrap/`** | System initialization, hook system | `bootstrap.go`, `init_hook.go` |

### Critical Data Structures

**Trader Interface (`trader/interface.go`):**
```go
type Trader interface {
    GetBalance() (map[string]interface{}, error)
    GetPositions() ([]map[string]interface{}, error)
    OpenLong(symbol, quantity string, leverage int) error
    OpenShort(symbol, quantity string, leverage int) error
    CloseLong(symbol, quantity string) error
    CloseShort(symbol, quantity string) error
    SetStopLoss(symbol, side, stopPrice string) error
    SetTakeProfit(symbol, side, takeProfitPrice string) error
    // ... precision handling, leverage, margin mode
}
```

**Decision Context (`decision/engine.go`):**
```go
type Context struct {
    CurrentTime     string
    RuntimeMinutes  int
    CallCount       int
    Account         AccountInfo           // Equity, margin, positions
    Positions       []PositionInfo        // Open positions with duration
    CandidateCoins  []CandidateCoin       // Trading candidates
    MarketDataMap   map[string]*Data      // K-line + indicators
    Performance     *PerformanceAnalysis  // Historical feedback (last 20 trades)
}
```

**Performance Tracking (`logger/decision_logger.go`):**
```go
type PerformanceAnalysis struct {
    TotalTrades   int
    WinningTrades int
    LosingTrades  int
    WinRate       float64
    AvgWin        float64      // Average profit %
    AvgLoss       float64      // Average loss %
    ProfitFactor  float64      // Avg win / Avg loss
    SharpeRatio   float64      // Risk-adjusted return
    SymbolStats   map[string]*SymbolPerformance
}
```

---

## AI Trading Decision Flow

Each trading cycle (default 3-5 minutes):

1. **Historical Performance Analysis** (`logger/decision_logger.go`)
   - Analyzes last 20 trades
   - Calculates win rate, profit/loss ratio, Sharpe ratio
   - Per-coin performance statistics
   - Identifies patterns to avoid/reinforce

2. **Account Status Collection** (`trader/auto_trader.go`)
   - Total equity, available balance
   - Open positions with unrealized P/L
   - Margin usage rate (enforced ≤90%)
   - Daily drawdown monitoring

3. **Position Analysis** (`market/monitor.go`)
   - Fetches latest K-line data (3-min, 4-hour)
   - Calculates technical indicators via TA-Lib:
     - RSI(7, 14), MACD, EMA(20, 50), ATR
   - Tracks position holding duration
   - Evaluates exit conditions

4. **Candidate Coin Selection** (`pool/manager.go`)
   - Default coins or AI500 pool + OI Top ranking
   - Liquidity filtering (>15M USD open interest)
   - Deduplication & merging
   - Batch market data fetching

5. **AI Reasoning** (`decision/engine.go`, `mcp/mcp_client.go`)
   - Chain-of-Thought (CoT) analysis
   - Prompt includes:
     - Historical feedback from Step 1
     - Current account state from Step 2
     - Position details from Step 3
     - Market data for candidates from Step 4
   - AI outputs structured decision JSON:
     ```json
     {
       "symbol": "BTCUSDT",
       "action": "open_long|close_short|hold|wait",
       "leverage": 5,
       "position_size_usd": 1000,
       "stop_loss": 95000,
       "take_profit": 100000,
       "reasoning": "Chain of thought explanation..."
     }
     ```

6. **Risk Control Validation** (`decision/validate.go`)
   - Position size limits (1.5x equity altcoins, 10x BTC/ETH)
   - Duplicate position prevention (one long + one short max per symbol)
   - Margin usage enforcement (≤90%)
   - Risk-reward ratio check (stop-loss:take-profit ≥1:2)
   - Exchange-specific precision handling

7. **Trade Execution** (`trader/auto_trader.go`, `trader/binance_futures.go`)
   - Priority: close existing positions → then open new
   - Auto-precision formatting per exchange
   - Order ID tracking
   - Execution price recording

8. **Logging & Performance Update** (`logger/decision_logger.go`)
   - Save complete decision log to `decision_logs/{trader_id}/decision_{timestamp}.json`
   - Log includes: CoT, input prompt, decision JSON, execution results
   - Update performance database for next cycle's feedback

---

## Database Schema (SQLite)

**Key Tables:**

```sql
-- User accounts with authentication
users (id, username, email, password_hash, created_at)

-- Trader configurations
traders (
  id, user_id, name, exchange, ai_model,
  initial_balance, leverage_btc_eth, leverage_altcoin,
  scan_interval_minutes, enabled, created_at
)

-- AI model configurations (per user)
ai_models (
  user_id, model_name, api_key_encrypted,
  base_url, enabled
)

-- Exchange credentials (per user)
exchanges (
  user_id, exchange_name, api_key_encrypted,
  secret_key_encrypted, additional_config_json, enabled
)

-- System-wide settings
system_config (key, value)

-- User-specific signal sources (coin pool APIs)
user_signal_sources (user_id, source_type, api_url, auth_param)

-- Beta access codes
beta_codes (code, used, used_by, used_at)
```

**Access Pattern:**
- Database is source of truth (not config.json)
- config.json synced to DB at startup for backward compatibility
- All trader configs loaded from DB at system start
- Runtime changes via API endpoints

---

## Multi-Exchange Support

**Unified Trader Interface:**
All exchanges implement the `Trader` interface, enabling:
- Seamless exchange switching per trader
- Consistent risk control logic
- Exchange-agnostic decision engine

**Exchange-Specific Implementation Details:**

| Exchange | API Type | Key Considerations |
|----------|----------|-------------------|
| **Binance** | REST + WebSocket | - Precision from `LOT_SIZE` filter<br>- Dual position mode<br>- Leverage ≤125x |
| **Hyperliquid** | DEX (L1) | - Private key auth (no API key)<br>- Agent wallet pattern<br>- Native precision handling |
| **Aster DEX** | DEX (EVM) | - API wallet system<br>- Binance-compatible API<br>- Multi-chain support |
| **Bybit** | REST | - Partial support<br>- Similar to Binance API |
| **Lighter** | DEX (L2) | - SDK integration (V1 + V2)<br>- Order book model |

**Adding New Exchanges:**
1. Implement `Trader` interface in `trader/{exchange}_trader.go`
2. Add exchange config fields in database schema
3. Register in `manager/trader_manager.go`
4. Add UI support in `web/src/components/ExchangeConfig.tsx`

---

## Configuration & Secrets Management

**Priority Order (highest to lowest):**

1. **Environment Variables** (`.env` file)
   ```bash
   NOFX_BACKEND_PORT=8080
   NOFX_FRONTEND_PORT=3000
   JWT_SECRET=your_jwt_secret_here
   DATA_ENCRYPTION_KEY=base64_encrypted_key
   ```

2. **SQLite Database** (`config.db`)
   - AI model configs, exchange credentials
   - Trader settings, leverage, scan intervals
   - User-specific configurations

3. **config.json** (legacy, synced to DB at startup)
   ```json
   {
     "api_server_port": 8080,
     "use_default_coins": true,
     "default_coins": ["BTCUSDT", "ETHUSDT", "SOLUSDT"],
     "leverage": {
       "btc_eth_leverage": 5,
       "altcoin_leverage": 5
     }
   }
   ```

**Sensitive Data Handling:**
- API keys encrypted with RSA-4096 (`secrets/rsa_key`)
- Private keys never logged or exposed in API responses
- JWT tokens for session management (configurable expiry)

---

## Prompt Engineering System

**Location:** `prompts/`

**Available Prompt Templates:**
- `default.txt` (129 lines) - Balanced strategy
- `Hansen.txt` (180 lines) - Conservative risk management
- `nof1.txt` (238 lines) - Systematic trend following
- `taro_long_prompts.txt` (337 lines) - Aggressive, multi-timeframe validation

**Prompt Structure:**
```markdown
## System Prompt (from template)
- Trading principles, risk management rules
- Technical indicator interpretation
- Position sizing guidelines

## Historical Performance Feedback (auto-injected)
- Last 20 trades analysis
- Win rate, profit factor, Sharpe ratio
- Best/worst performing coins

## Current Market Context (auto-generated)
- Account state (balance, margin, positions)
- Open positions with holding duration
- Candidate coins with full market data
- Technical indicators (RSI, MACD, EMA, ATR)

## Expected Output Format
- Structured JSON decision
- Chain-of-Thought reasoning
```

**Customization:**
- Edit prompt templates in `prompts/` directory
- Changes take effect on next decision cycle (hot-reload)
- Per-trader prompt selection via database config

---

## Testing Strategy

**Test Coverage: 56 test files**

**Unit Tests:**
- `trader/auto_trader_test.go` - Trading logic
- `decision/validate_test.go` - Decision validation
- `config/database_test.go` - Schema operations
- `crypto/encryption_test.go` - Encryption correctness

**Integration Tests:**
- `api/server_test.go` - API endpoints
- `manager/trader_manager_test.go` - Multi-trader orchestration

**Race Condition Tests:**
- `trader/auto_trader_race_test.go` - Concurrency safety
- Run with: `go test -race ./...`

**Frontend Tests:**
- `web/src/components/CompetitionPage.test.tsx` - UI components
- Vitest framework

**Critical Test Scenarios:**
- Position size validation (prevent over-leverage)
- Duplicate position prevention
- Precision handling per exchange
- Stop-loss/take-profit price validation
- JWT token expiry and refresh

---

## Risk Control Implementation

**Multi-Layered Risk Management:**

1. **Account-Level Controls** (`config/config.go`)
   - Daily loss limit (default 10%, configurable)
   - Maximum drawdown (default 20%, configurable)
   - Automatic trading pause if exceeded
   - Cooldown period before resume

2. **Position-Level Controls** (`decision/validate.go`)
   - Per-symbol exposure limits:
     - Altcoins: ≤1.5x account equity
     - BTC/ETH: ≤10x account equity
   - Leverage constraints (user-configured max per asset class)
   - Margin utilization cap: ≤90% of available margin

3. **Order-Level Controls** (`trader/auto_trader.go`)
   - Precision validation per exchange (LOT_SIZE, PRICE_FILTER)
   - Risk-reward ratio enforcement (stop-loss:take-profit ≥1:2)
   - Duplicate position prevention (one long + one short max per symbol)
   - Pending order cleanup before new position opens

**Stop-Loss Validation Logic:**

**CRITICAL:** Stop-loss price must be set correctly relative to position direction:
- **LONG positions:** Stop-loss < Entry Price (protects against downward movement)
- **SHORT positions:** Stop-loss > Entry Price (protects against upward movement)

**Example Error from Decision Logs:**
```
❌ BNBUSDT update_stop_loss 失败:
<APIError> code=-2021, msg=Order would immediately trigger

Issue: SHORT position @ 87758.60, current price 85596.40 (profitable)
AI tried to set stop: 86500 ❌ (between entry and current)
Should set stop: > 87758.60, e.g., 88000 ✅ (protects against rally)
```

**Implementation Location:** `trader/binance_futures.go:SetStopLoss()`

**Recommendation:** Add validation before order submission:
```go
func (b *BinanceFutures) SetStopLoss(symbol, side, stopPrice string) error {
    position := b.GetPosition(symbol)
    stopPriceFloat, _ := strconv.ParseFloat(stopPrice, 64)

    // Validate stop-loss direction
    if side == "SHORT" && stopPriceFloat <= position.EntryPrice {
        return fmt.Errorf("SHORT止损价格(%.2f)必须高于入场价(%.2f)",
            stopPriceFloat, position.EntryPrice)
    }
    if side == "LONG" && stopPriceFloat >= position.EntryPrice {
        return fmt.Errorf("LONG止损价格(%.2f)必须低于入场价(%.2f)",
            stopPriceFloat, position.EntryPrice)
    }

    // Proceed with order submission...
}
```

---

## Performance Optimization

**Key Optimizations:**

1. **Market Data Efficiency**
   - WebSocket streaming (not REST polling) for price updates
   - K-line caching with TTL to reduce API calls
   - Batch requests for multiple symbols
   - Connection pooling for exchange APIs

2. **Frontend Performance**
   - SWR (stale-while-revalidate) with 5-10s intervals
   - Competition data caching with TTL
   - Lazy loading for decision logs
   - Virtual scrolling for large lists

3. **Database Optimization**
   - Prepared statements (SQL injection prevention)
   - Proper indexing on trader_id, user_id
   - Transaction batching for bulk operations
   - Connection pooling

4. **AI API Efficiency**
   - Token limit optimization (AI_MAX_TOKENS=4000)
   - Streaming responses for faster perceived latency
   - Prompt template caching
   - Timeout management (120s default)

---

## Deployment Best Practices

**Docker Deployment (Recommended):**

1. **Environment Setup:**
   ```bash
   cp .env.example .env
   # Edit .env with JWT_SECRET, DATA_ENCRYPTION_KEY

   cp config.json.example config.json
   # Edit config.json (optional, DB takes precedence)
   ```

2. **Initial Configuration:**
   - Access web UI: http://localhost:3000
   - Register user account (or use beta code)
   - Configure AI models (DeepSeek/Qwen API keys)
   - Configure exchanges (Binance/Hyperliquid credentials)
   - Create traders (AI + Exchange + Settings)

3. **Security Checklist:**
   - [ ] Change default JWT_SECRET
   - [ ] Generate new DATA_ENCRYPTION_KEY
   - [ ] Enable Binance IP whitelist
   - [ ] Use agent/API wallets for DEXs (not main wallet)
   - [ ] Set appropriate leverage limits (≤5x for testing)
   - [ ] Enable 2FA for user accounts (optional)

4. **Monitoring:**
   ```bash
   ./start.sh logs              # Real-time logs
   ./start.sh status            # Service health

   # Access decision logs
   ls -lh decision_logs/{trader_id}/

   # Check database
   sqlite3 config.db
   SELECT * FROM traders WHERE enabled = 1;
   ```

**Production Considerations:**
- Use persistent volumes for `config.db` and `decision_logs/`
- Set up log rotation for `decision_logs/` (can grow large)
- Monitor disk usage (decision logs are ~1-5MB per day per trader)
- Regular database backups (`sqlite3 config.db .dump > backup.sql`)
- Consider rate limits on Binance API (1200 req/min)

---

## Common Development Tasks

**Adding a New Exchange:**

1. Create `trader/{exchange}_trader.go` implementing `Trader` interface
2. Add exchange config in `config/database.go` schema
3. Register in `manager/trader_manager.go:createTraderInstance()`
4. Add UI support in `web/src/components/ExchangeConfig.tsx`
5. Update `api/server.go:getSupportedExchanges()`

**Adding a New AI Model:**

1. Create client in `mcp/{model}_client.go` implementing MCP interface
2. Add model config in `config/database.go` schema
3. Register in `decision/engine.go:getAIClient()`
4. Add UI support in `web/src/components/AIModelConfig.tsx`
5. Update `api/server.go:getSupportedModels()`

**Modifying Trading Logic:**

1. Core logic: `trader/auto_trader.go:Monitor()` (main trading loop)
2. Decision engine: `decision/engine.go:MakeDecision()`
3. Risk validation: `decision/validate.go:ValidateDecision()`
4. Always add tests: `trader/auto_trader_test.go`

**Debugging Trading Issues:**

1. Check decision logs: `decision_logs/{trader_id}/decision_{timestamp}.json`
   - Contains full AI reasoning, input data, execution results
2. Check API logs: `docker compose logs -f nofx`
3. Query database: `sqlite3 config.db`
   ```sql
   SELECT * FROM traders WHERE id = 'trader_id';
   SELECT * FROM ai_models WHERE user_id = 'user_id';
   ```
4. Test exchange connectivity:
   ```go
   // In trader code
   balance, err := trader.GetBalance()
   log.Printf("Balance: %+v, Error: %v", balance, err)
   ```

---

## Known Issues & Limitations

**Current Limitations:**

1. **Stop-Loss Logic Error** (68.4% failure rate in testing)
   - Issue: AI sets stop-loss on wrong side of entry price
   - Location: `trader/binance_futures.go:SetStopLoss()`
   - Solution: Add direction validation before order submission
   - See "Risk Control Implementation" section above

2. **Exchange-Specific Quirks:**
   - Binance subaccounts: Limited to 5x leverage (error if exceeded)
   - Hyperliquid: Requires separate agent wallet for security
   - Aster: API wallet setup required before trading

3. **Rate Limits:**
   - Binance: 1200 requests/min, 10 orders/sec
   - AI APIs: DeepSeek ~50 req/min, Qwen varies
   - Market data WebSocket: 150 symbols/connection max

4. **Performance:**
   - Decision logs can grow large (1-5MB/day/trader)
   - SQLite may need optimization at >100 concurrent traders
   - AI API latency: 2-10s per decision (affects cycle time)

**Planned Improvements:**
- Enhanced stop-loss validation (code fix needed)
- Bybit and Lighter full integration
- Additional exchanges (OKX, EdgeX)
- Strategy backtesting engine
- Mobile application

---

## Important Notes for Future Development

1. **Multi-Tenant Architecture:** User ID is fundamental - always filter by user_id in queries
2. **Database is Source of Truth:** config.json is synced to DB, not the reverse
3. **Exchange Abstraction:** Always implement full `Trader` interface for new exchanges
4. **Security First:** Never log sensitive data (API keys, private keys, JWT tokens)
5. **Decision Logging is Critical:** Every trade must be logged with full context for AI learning
6. **Risk Controls are Non-Negotiable:** Never bypass validation in `decision/validate.go`
7. **Test Coverage Matters:** Add tests for all new trading logic and exchange integrations
8. **Concurrency Safety:** Use proper locking for shared state (sync.RWMutex)
9. **Error Handling:** Always return errors, don't panic in production code
10. **Prompt Engineering:** Small changes to prompts can significantly affect trading behavior

---

## Additional Resources

- **README.md** - User-facing documentation, deployment guide
- **docs/architecture/** - Detailed architecture diagrams
- **docs/getting-started/** - Setup tutorials
- **docs/prompt-guide.md** - Prompt engineering best practices
- **CONTRIBUTING.md** - Development workflow, code standards
- **SECURITY.md** - Security policy, vulnerability reporting
- **CHANGELOG.md** - Version history and updates

---

**Last Updated:** 2025-11-25 (based on v3.0.0 codebase)