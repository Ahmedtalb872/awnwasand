"""
Send a single SMS message to a list of members via the chinguisoft API,
with a fixed delay between each message.

Usage:
    python send_sms.py --members members.csv --message message.txt

members.csv columns: name,phone
message.txt: plain text of the single message sent to everyone
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

CHINGUISOFT_API_URL = os.environ.get("CHINGUISOFT_API_URL", "")
CHINGUISOFT_CAMPAIGN_KEY = os.environ.get("CHINGUISOFT_CAMPAIGN_KEY", "")
CHINGUISOFT_CAMPAIGN_TOKEN = os.environ.get("CHINGUISOFT_CAMPAIGN_TOKEN", "")

DELAY_SECONDS = 60
LOG_FILE = "sent_log.csv"


def send_one(phone: str, message: str) -> tuple[bool, str]:
    """Send a single SMS via chinguisoft. Returns (success, raw_response_or_error).

    TODO: the endpoint URL below is unconfirmed - chinguisoft.com blocks
    automated doc fetches. Verify the exact path and whether campaign_key/
    Campaign-token are sent as headers or as body fields against their
    "sample code" panel, then update this function accordingly.
    """
    if not CHINGUISOFT_API_URL or not CHINGUISOFT_CAMPAIGN_KEY or not CHINGUISOFT_CAMPAIGN_TOKEN:
        return False, "CHINGUISOFT_API_URL / CHINGUISOFT_CAMPAIGN_KEY / CHINGUISOFT_CAMPAIGN_TOKEN not configured in .env"

    headers = {
        "campaign_key": CHINGUISOFT_CAMPAIGN_KEY,
        "Campaign-token": CHINGUISOFT_CAMPAIGN_TOKEN,
        "Content-Type": "application/json",
    }
    payload = {
        "phone": phone,
        "message": message,
    }

    try:
        response = requests.post(CHINGUISOFT_API_URL, json=payload, headers=headers, timeout=15)
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
    parser = argparse.ArgumentParser(description="Send one SMS to a list of members, one per minute.")
    parser.add_argument("--members", default="members.csv", help="CSV file with name,phone columns")
    parser.add_argument("--message", default="message.txt", help="Text file containing the message")
    parser.add_argument("--delay", type=int, default=DELAY_SECONDS, help="Seconds to wait between messages")
    args = parser.parse_args()

    if not os.path.exists(args.members):
        sys.exit(f"Members file not found: {args.members}")
    if not os.path.exists(args.message):
        sys.exit(f"Message file not found: {args.message}")

    members = load_members(args.members)
    with open(args.message, encoding="utf-8") as f:
        message = f.read().strip()

    print(f"Loaded {len(members)} members. Sending with {args.delay}s delay between messages.")

    for i, member in enumerate(members, start=1):
        name = member.get("name", "").strip()
        phone = member.get("phone", "").strip()

        if not phone:
            print(f"[{i}/{len(members)}] Skipping row with empty phone (name={name!r})")
            continue

        success, detail = send_one(phone, message)
        status = "OK" if success else "FAILED"
        print(f"[{i}/{len(members)}] {status} -> {name} ({phone})")
        log_result(name, phone, success, detail)

        if i < len(members):
            time.sleep(args.delay)

    print(f"Done. Results logged to {LOG_FILE}")


if __name__ == "__main__":
    main()
