#!/usr/bin/env python3
"""Example 2: JS-rendered page with scrapling DynamicFetcher.

Usage:
    python3 examples/js_render.py
"""
from scrapling.fetchers import DynamicFetcher

try:
    page = DynamicFetcher.fetch(
        'https://httpbin.org/html',
        headless=True,
        wait_until='networkidle'
    )
    print("Page content (after JS render):", page.text[:300])
except Exception as e:
    print(f"DynamicFetcher failed: {e}")
    print("Fallback: try crawl4ai-skill or camoufox")
