#!/usr/bin/env bash
# Example 4: DuckDuckGo news search with ddgs CLI
#
# Usage:
#   bash examples/search_news.sh "artificial intelligence"
#   bash examples/search_news.sh                       # default query

QUERY="${1:-"web scraping tools"}"

# Check CLI available
if ! command -v ddgs &>/dev/null; then
    echo "ddgs CLI not found. Install: pip install ddgs"
    exit 1
fi

echo "=== Searching: $QUERY ==="
echo ""

# News search
ddgs news --keywords "$QUERY" --max_results 5 --timelimit w

echo ""
echo "=== Text Search ==="
ddgs text --keywords "$QUERY" --max_results 3
