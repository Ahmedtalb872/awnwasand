"""
Parse the raw, manually-typed monthly member list (as pasted from WhatsApp/
notes) into a clean members CSV, and flag rows that need a human look
before any SMS goes out.

Expected raw format, one entry per line, e.g.:
    12: +222 47 35 47 74 عيشة / عبد الله
    24: +222 47 39 73 85 فاطمة / احمدو محمد الامين7/1 ✅

A trailing checkmark (with or without a payment date like 7/1 or 01/07)
marks a member who already contributed this month.

Usage:
    python parse_members.py members_raw.txt
"""

import argparse
import csv
import re
import sys

LINE_RE = re.compile(r"^\s*(\d+)\s*:\s*(.*)$")
PHONE_RE = re.compile(r"\+\d{1,4}(?:[\s]?\d){6,}")
CHECK_RE = re.compile(r"✅️?")
DATE_RE = re.compile(r"\b\d{1,2}[/.]\d{1,2}(?:[/.]\d{2,4})?\b")


def parse(path: str):
    rows = []
    issues = []
    pending_index = None

    with open(path, encoding="utf-8") as f:
        raw_lines = [line.rstrip("\n") for line in f]

    for raw in raw_lines:
        line = raw.strip()
        if not line:
            continue

        m = LINE_RE.match(line)
        if m:
            index, rest = int(m.group(1)), m.group(2).strip()
        else:
            # continuation line with no "N:" prefix - likely belongs to a
            # dropped index number right after the last one seen.
            index, rest = None, line

        if not rest:
            issues.append(f"#{index}: entry has no phone/name at all - skipped")
            continue

        phone_match = PHONE_RE.search(rest)
        if not phone_match:
            issues.append(f"#{index or '?'}: no phone number found in {rest!r} - needs manual review")
            continue

        phone_raw = phone_match.group(0)
        phone = re.sub(r"\s+", "", phone_raw)
        name = (rest[:phone_match.start()] + rest[phone_match.end():]).strip()
        paid = bool(CHECK_RE.search(name))
        date_match = DATE_RE.search(name)
        paid_date = date_match.group(0) if date_match else ""

        name = CHECK_RE.sub("", name)
        if date_match:
            name = name.replace(date_match.group(0), "")
        name = name.strip(" /\t")

        if index is None:
            issues.append(
                f"orphan line (no index prefix) paired as best guess: "
                f"name={name!r} phone={phone!r} - VERIFY, this may belong to a "
                f"missing/mislabeled row number"
            )

        if not phone.startswith("+222") and not (index and 100 <= index <= 130):
            issues.append(f"#{index}: unusual country code {phone!r} - verify it's correct")
        elif not phone.startswith("+222"):
            issues.append(f"#{index}: unusual country code {phone!r} - verify it's correct")

        digits = re.sub(r"\D", "", phone)
        if not (10 <= len(digits) <= 13):
            issues.append(f"#{index}: phone {phone!r} has an unusual digit count ({len(digits)}) - verify")

        if not name:
            issues.append(f"#{index}: phone {phone!r} has no name attached - verify")

        rows.append({
            "index": index if index is not None else "",
            "name": name,
            "phone": phone,
            "paid": "yes" if paid else "no",
            "paid_date": paid_date,
        })

    return rows, issues


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("input", help="Raw member list text file")
    parser.add_argument("--out", default="members_parsed.csv", help="Output CSV path")
    args = parser.parse_args()

    rows, issues = parse(args.input)

    with open(args.out, "w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=["index", "name", "phone", "paid", "paid_date"])
        writer.writeheader()
        writer.writerows(rows)

    paid = sum(1 for r in rows if r["paid"] == "yes")
    print(f"Parsed {len(rows)} entries -> {args.out} ({paid} marked paid, {len(rows) - paid} unpaid)")

    if issues:
        print(f"\n{len(issues)} rows need manual review:")
        for issue in issues:
            print(f"  - {issue}")
    else:
        print("No anomalies detected.")


if __name__ == "__main__":
    main()
