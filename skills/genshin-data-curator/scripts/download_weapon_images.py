#!/usr/bin/env python3
import json
import os
import ssl
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

VALID_EXT = {".png", ".jpg", ".jpeg", ".webp"}


def infer_ext(url: str, content_type: str | None) -> str:
    if content_type:
        content_type = content_type.lower()
        if "png" in content_type:
            return ".png"
        if "jpeg" in content_type or "jpg" in content_type:
            return ".jpg"
        if "webp" in content_type:
            return ".webp"

    path = urllib.parse.urlparse(url).path.lower()
    _, ext = os.path.splitext(path)
    if ext in VALID_EXT:
        return ext
    return ".png"


def download(url: str, timeout: int, ctx: ssl.SSLContext) -> tuple[bytes, str] | None:
    if not url:
        return None

    normalized = url.replace(" ", "%20")
    req = urllib.request.Request(normalized, method="GET", headers={"User-Agent": "Mozilla/5.0"})
    try:
        with urllib.request.urlopen(req, timeout=timeout, context=ctx) as res:
            if res.status != 200:
                return None
            data = res.read()
            content_type = res.headers.get("Content-Type", "")
            ext = infer_ext(normalized, content_type)
            return data, ext
    except (urllib.error.HTTPError, urllib.error.URLError, TimeoutError):
        return None


def build_fallback_urls(url: str) -> list[str]:
    parsed = urllib.parse.urlparse(url)
    base_name = os.path.basename(parsed.path)
    if not base_name:
        return [url]
    return [url, f"https://enka.network/ui/{base_name}"]


def main() -> int:
    data_path = Path("Resources/Data/weapons.json")
    output_dir = Path("Resources/Images/weapons")
    output_dir.mkdir(parents=True, exist_ok=True)

    with data_path.open("r", encoding="utf-8") as f:
        weapons = json.load(f)

    ctx = ssl.create_default_context()

    success = 0
    failed = []

    for item in weapons:
        candidates = [item.get("image", "")]
        candidates.extend(item.get("imageAlternatives") or [])

        downloaded = None
        for candidate in candidates:
            for target in build_fallback_urls(candidate):
                downloaded = download(target, timeout=12, ctx=ctx)
                if downloaded:
                    break
            if downloaded:
                break

        if not downloaded:
            failed.append((item["id"], item["name"]))
            item["localImage"] = None
            continue

        data, ext = downloaded
        file_name = f"{item['id']}{ext}"
        file_path = output_dir / file_name
        file_path.write_bytes(data)

        item["localImage"] = f"Images/weapons/{file_name}"
        success += 1

    with data_path.open("w", encoding="utf-8") as f:
        json.dump(weapons, f, ensure_ascii=False, indent=2)
        f.write("\n")

    print(f"Downloaded: {success}")
    print(f"Failed: {len(failed)}")
    if failed:
        print("Failed IDs:")
        for weapon_id, name in failed:
            print(f"- {weapon_id} ({name})")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
