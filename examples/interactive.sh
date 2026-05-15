#!/usr/bin/env bash
# Example 5: Interactive browser automation with camofox-browser REST API
#
# Usage:
#   bash examples/interactive.sh
#
# Requires: camofox-browser installed and running
# Start server: node node_modules/camofox-browser/bin/camofox-browser.js

SERVER_PID=""
cleanup() {
    if [ -n "$SERVER_PID" ]; then
        kill "$SERVER_PID" 2>/dev/null || true
        SERVER_PID=""
    fi
}
trap cleanup EXIT INT TERM

# Default: start server in background if not running
start_server() {
    local CB_PATH
    for p in node_modules/camofox-browser/bin/camofox-browser.js \
             ../node_modules/camofox-browser/bin/camofox-browser.js \
             "$HOME/node_modules/camofox-browser/bin/camofox-browser.js"; do
        if [ -f "$p" ]; then
            CB_PATH="$p"
            break
        fi
    done

    if [ -z "${CB_PATH:-}" ]; then
        echo "camofox-browser not installed."
        echo "Install: npm install --save-dev camofox-browser"
        exit 1
    fi

    echo "Starting camofox-browser server..."
    node "$CB_PATH" &
    SERVER_PID=$!
    sleep 3
    echo "Server started (PID: $SERVER_PID)"
}

# Check if server is running
if ! curl -s http://localhost:9377/ > /dev/null 2>&1; then
    start_server
fi

BASE="http://localhost:9377"

echo ""
echo "=== camofox-browser API Demo ==="
echo ""

# Create a tab and navigate
echo "1. Opening https://httpbin.org/headers..."
TAB_RESP=$(curl -s -X POST "$BASE/tabs" \
    -H 'Content-Type: application/json' \
    -d '{"url":"https://httpbin.org/headers","userId":"demo","sessionKey":"demo"}' 2>/dev/null || echo '{"id":"demo-tab"}')
TAB_ID=$(echo "$TAB_RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('id','demo-tab'))" 2>/dev/null || echo "demo-tab")
echo "   Tab ID: $TAB_ID"

# Get snapshot
echo ""
echo "2. Page content..."
curl -s "$BASE/tabs/$TAB_ID/snapshot?userId=demo" 2>/dev/null | head -20 || echo "   (snapshot unavailable - check server logs)"

# Close tab
echo ""
echo "3. Closing tab..."
curl -s -X DELETE "$BASE/tabs/$TAB_ID?userId=demo" > /dev/null 2>&1 && echo "   Done" || echo "   (cleanup skipped)"

# Server stopped by cleanup trap on EXIT
