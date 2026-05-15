#!/usr/bin/env python3
"""Example 3: Cloudflare bypass with httpcloak → camoufox fallback chain.

Demonstrates the recommended anti-detection strategy:
1. Try httpcloak first (HTTP layer, TLS fingerprint simulation)
2. Fall back to camoufox (browser layer, C++ fingerprint spoofing)

Usage:
    python3 examples/cloudflare_bypass.py <url>
"""
import sys


def bypass(url):
    # Level 1: HTTP layer with httpcloak
    try:
        import httpcloak
        r = httpcloak.get(url, preset='chrome-latest')
        print(f"[httpcloak] Status: {r.status_code}")
        print(f"[httpcloak] Protocol: {r.protocol}")
        print(f"[httpcloak] Response preview: {r.text[:200]}")
        return
    except ImportError:
        print("[--] httpcloak not installed, skipping")
    except Exception as e:
        print(f"[httpcloak] Failed: {e}")

    # Level 2: Browser layer with camoufox
    try:
        from camoufox.sync_api import Camoufox
        with Camoufox() as browser:
            page = browser.new_page()
            page.goto(url)
            print(f"[camoufox] Page title: {page.title()}")
            print(f"[camoufox] Content preview: {page.content()[:200]}")
    except ImportError:
        print("[--] camoufox not installed, skipping")
    except Exception as e:
        print(f"[camoufox] Failed: {e}")
        print("Fallback chain exhausted. Try: Archive.org or search engine cache")


if __name__ == "__main__":
    url = sys.argv[1] if len(sys.argv) > 1 else 'https://httpbin.org/headers'
    bypass(url)
