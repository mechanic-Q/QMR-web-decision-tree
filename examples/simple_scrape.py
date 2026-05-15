#!/usr/bin/env python3
"""Example 1: Simple page fetch with scrapling Fetcher.

Usage:
    python3 examples/simple_scrape.py
"""
from scrapling.fetchers import Fetcher

try:
    page = Fetcher.get('https://httpbin.org/html')
    print("Title:", page.css('h1::text').get())
    print("Body preview:", page.text[:200])
except Exception as e:
    print(f"Fetcher failed: {e}")
    print("Fallback: try webfetch or another tool from the decision tree")
