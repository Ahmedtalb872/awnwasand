"""
Trigger the chinguisoft SMS Campaign API for a list of members, one send
per member with a fixed delay between each.

The message text itself is NOT sent in the API request - it is defined on
the chinguisoft dashboard for the campaign identified by the campaign key.
This script only triggers a send to each phone number, optionally with a
link (e.g. a donation/contribution link) inserted into the message.

Usage:
    python send_sms.py --members members.csv
    python send_sms.py --members members.csv --url https://example.com/donate
"""

import argparse
import csv
import os
import sys
import time
from datetime import datetime

import requests
from dotenv import load_dotenv

load_dotenv()

CHINGUISOFT_API_URL = os.environ.get("CHINGUISOFT_API_URL", "https://chinguisoft.com")
CHINGUISOFT_CAMPAIGN_KEY = os.environ.get("CHINGUISOFT_CAMPAIGN_KEY", "")
CHINGUISOFT_CAMPAIGN_TOKEN = os.environ.get("CHINGUISOFT_CAMPAIGN_TOKEN", "")

DELAY_SECONDS = 60
LOG_FILE = "sent_log.csv"


def send_one(phone: str, lang: str, url: str | None) -> tuple[bool, str]:
    """Trigger one SMS send via the chinguisoft campaign API.

    Returns (success, detail) where detail is the response body (e.g. the
    remaining balance) on success, or an error message on failure.
    """
    if not CHINGUISOFT_CAMPAIGN_KEY or not CHINGUISOFT_CAMPAIGN_TOKEN:
        return False, "CHINGUISOFT_CAMPAIGN_KEY / CHINGUISOFT_CAMPAIGN_TOKEN not configured in .env"

    endpoint = f"{CHINGUISOFT_API_URL}/api/sms/campaign/{CHINGUISOFT_CAMPAIGN_KEY}"
    headers = {
        "Campaign-token": CHINGUISOFT_CAMPAIGN_TOKEN,
        "Content-Type": "application/json",
    }
    payload = {"phone": phone, "lang": lang}
    if url:
        payload["url"] = url

    try:
        response = requests.post(endpoint, json=payload, headers=headers, timeout=15)
        response.raise_for_status()
        return True, response.text
    except requests.RequestException as exc:
        return False, str(exc)


def load_members(path: str) -> list[dict]:
    with open(path, newline="", encoding="utf-8-sig") as f:
        return list(csv.DictReader(f))


def log_result(name: str, phone: str, success: bool, detail: str) -> None:
    is_new = not os.path.exists(LOG_FILE)
    with open(LOG_FILE, "a", newline="", encoding="utf-8-sig") as f:
        writer = csv.writer(f)
        if is_new:
            writer.writerow(["timestamp", "name", "phone", "status", "detail"])
        writer.writerow([
            datetime.now().isoformat(timespec="seconds"),
            name,
            phone,
            "sent" if success else "failed",
            detail,
        ])


def main() -> None:
    parser = argparse.ArgumentParser(description="Trigger the chinguisoft campaign SMS for a list of members, one per minute.")
    parser.add_argument("--members", default="members.csv", help="CSV file with name,phone columns")
    parser.add_argument("--lang", default="ar", help="Message language (default: ar)")
    parser.add_argument("--url", default=None, help="Optional link to insert into the message (e.g. a donation link)")
    parser.add_argument("--delay", type=int, default=DELAY_SECONDS, help="Seconds to wait between messages")
    args = parser.parse_args()

    if not os.path.exists(args.members):
        sys.exit(f"Members file not found: {args.members}")

    members = load_members(args.members)

    print(f"Loaded {len(members)} members. Sending with {args.delay}s delay between messages.")

    for i, member in enumerate(members, start=1):
        name = member.get("name", "").strip()
        phone = member.get("phone", "").strip()

        if not phone:
            print(f"[{i}/{len(members)}] Skipping row with empty phone (name={name!r})")
            continue

        success, detail = send_one(phone, args.lang, args.url)
        status = "OK" if success else "FAILED"
        print(f"[{i}/{len(members)}] {status} -> {name} ({phone}) {detail}")
        log_result(name, phone, success, detail)

        if i < len(members):
            time.sleep(args.delay)

    print(f"Done. Results logged to {LOG_FILE}")


if __name__ == "__main__":
    main()
