"""Awn Wasand learning application. Python 3.10+, no runtime dependencies."""
import hashlib
import hmac
import json
import mimetypes
import os
import re
import secrets
import sqlite3
import time
from http.cookies import SimpleCookie
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlsplit

from curriculum import BY_ID, public_catalog

ROOT = Path(__file__).resolve().parent
DB_PATH = os.environ.get("APP_DB", str(ROOT / "data" / "learning.sqlite3"))


def database():
    conn = sqlite3.connect(DB_PATH, timeout=15)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys=ON")
    return conn


def init_db():
    Path(DB_PATH).parent.mkdir(parents=True, exist_ok=True)
    with database() as db:
        db.executescript('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY, name TEXT NOT NULL, email TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL, goal INTEGER NOT NULL DEFAULT 1);
        CREATE TABLE IF NOT EXISTS sessions (
          token TEXT PRIMARY KEY, user_id INTEGER REFERENCES users(id), csrf TEXT NOT NULL, expires REAL NOT NULL);
        CREATE TABLE IF NOT EXISTS progress (
          user_id INTEGER REFERENCES users(id), lesson_id TEXT, completed INTEGER DEFAULT 0,
          best_score INTEGER DEFAULT 0, attempts INTEGER DEFAULT 0, updated TEXT,
          PRIMARY KEY(user_id, lesson_id));
        CREATE TABLE IF NOT EXISTS bookmarks (
          user_id INTEGER REFERENCES users(id), lesson_id TEXT, PRIMARY KEY(user_id, lesson_id));
        CREATE TABLE IF NOT EXISTS login_attempts (
          address TEXT PRIMARY KEY, count INTEGER NOT NULL, expires REAL NOT NULL);
        ''')


def hash_password(password, salt=None):
    salt = salt or secrets.token_hex(16)
    digest = hashlib.pbkdf2_hmac("sha256", password.encode(), bytes.fromhex(salt), 260000).hex()
    return f"{salt}${digest}"


class Handler(BaseHTTPRequestHandler):
    def send(self, status, data, cookie=None):
        body = json.dumps(data, ensure_ascii=False).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-store")
        self.security_headers()
        if cookie:
            self.send_header("Set-Cookie", cookie)
        self.end_headers()
        self.wfile.write(body)

    def security_headers(self):
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Referrer-Policy", "same-origin")
        self.send_header("Content-Security-Policy", "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; connect-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'self'")

    def identity(self):
        cookie = SimpleCookie()
        try:
            cookie.load(self.headers.get("Cookie", ""))
        except Exception:
            return None
        token = cookie.get("awn_session")
        if not token:
            return None
        with database() as db:
            row = db.execute("SELECT u.*, s.csrf, s.token FROM sessions s JOIN users u ON u.id=s.user_id WHERE s.token=? AND s.expires>?", (hashlib.sha256(token.value.encode()).hexdigest(), time.time())).fetchone()
        return dict(row) if row else None

    def profile(self, user):
        with database() as db:
            progress = [dict(r) for r in db.execute("SELECT lesson_id,completed,best_score,attempts,updated FROM progress WHERE user_id=?", (user["id"],))]
            bookmarks = [r[0] for r in db.execute("SELECT lesson_id FROM bookmarks WHERE user_id=?", (user["id"],))]
        return dict(name=user["name"], goal=user["goal"], csrf=user["csrf"], progress=progress, bookmarks=bookmarks)

    def do_GET(self):
        path = urlsplit(self.path).path
        if path == "/api/catalog":
            return self.send(200, public_catalog())
        if path == "/api/me":
            user = self.identity()
            return self.send(200, {"user": self.profile(user) if user else None})
        files = {"/": "index.html", "/static/app.js": "app.js", "/static/style.css": "style.css"}
        if path not in files:
            return self.send(404, {"error": "الصفحة غير موجودة"})
        body = (ROOT / "static" / files[path]).read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", (mimetypes.guess_type(files[path])[0] or "text/plain") + "; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-cache")
        self.security_headers()
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        # Browser writes must originate from this host. Authenticated writes also require CSRF.
        if self.headers.get("Content-Type", "").split(";")[0] != "application/json":
            return self.send(415, {"error": "الطلب يجب أن يكون بصيغة JSON"})
        origin = self.headers.get("Origin")
        if origin and urlsplit(origin).netloc != self.headers.get("Host"):
            return self.send(403, {"error": "مصدر الطلب غير مسموح"})
        try:
            size = int(self.headers.get("Content-Length", "0"))
            if not 0 < size <= 16384:
                return self.send(400, {"error": "حجم الطلب غير صالح"})
            data = json.loads(self.rfile.read(size))
            if not isinstance(data, dict):
                raise ValueError()
        except (ValueError, UnicodeDecodeError):
            return self.send(400, {"error": "بيانات الطلب غير صالحة"})
        path = urlsplit(self.path).path
        if path in ("/api/register", "/api/login"):
            return self.authenticate(path, data)
        user = self.identity()
        if not user:
            return self.send(401, {"error": "سجّل الدخول لحفظ تقدمك"})
        if not hmac.compare_digest(self.headers.get("X-CSRF-Token", ""), user["csrf"]):
            return self.send(403, {"error": "أعد تحميل الصفحة ثم حاول مجددًا"})
        with database() as db:
            if path == "/api/logout":
                db.execute("DELETE FROM sessions WHERE token=?", (user["token"],))
                return self.send(200, {"ok": True}, self.cookie("", clear=True))
            if path == "/api/goal":
                goal = data.get("goal")
                if type(goal) is not int or not 1 <= goal <= 5:
                    return self.send(400, {"error": "اختر هدفًا بين درس واحد وخمسة دروس"})
                db.execute("UPDATE users SET goal=? WHERE id=?", (goal, user["id"]))
                return self.send(200, {"ok": True})
            lesson_id = data.get("lesson_id")
            if not isinstance(lesson_id, str) or lesson_id not in BY_ID:
                return self.send(404, {"error": "الدرس غير موجود"})
            if path == "/api/bookmark":
                exists = db.execute("SELECT 1 FROM bookmarks WHERE user_id=? AND lesson_id=?", (user["id"], lesson_id)).fetchone()
                if exists:
                    db.execute("DELETE FROM bookmarks WHERE user_id=? AND lesson_id=?", (user["id"], lesson_id))
                else:
                    db.execute("INSERT INTO bookmarks VALUES (?,?)", (user["id"], lesson_id))
                return self.send(200, {"saved": not bool(exists)})
            if path != "/api/quiz":
                return self.send(404, {"error": "المسار غير موجود"})
            questions = BY_ID[lesson_id]["questions"]
            answers = data.get("answers")
            if not isinstance(answers, list) or len(answers) != len(questions) or any(type(a) is not int or not 0 <= a < len(q["options"]) for a, q in zip(answers, questions)):
                return self.send(400, {"error": "أجب عن جميع الأسئلة"})
            score = round(100 * sum(a == q["answer"] for a, q in zip(answers, questions)) / len(questions))
            passed = score >= 70
            db.execute('''INSERT INTO progress VALUES (?,?,?,?,1,date('now'))
              ON CONFLICT(user_id,lesson_id) DO UPDATE SET
              completed=MAX(completed,excluded.completed), best_score=MAX(best_score,excluded.best_score),
              attempts=attempts+1, updated=date('now')''', (user["id"], lesson_id, int(passed), score))
            return self.send(200, {"score": score, "passed": passed, "feedback": [dict(correct=a == q["answer"], answer=q["answer"], explanation=q["explanation"]) for a, q in zip(answers, questions)]})

    def cookie(self, token, clear=False):
        secure = "; Secure" if os.environ.get("COOKIE_SECURE") == "1" else ""
        return f"awn_session={token}; Path=/; HttpOnly; SameSite=Strict; Max-Age={0 if clear else 604800}{secure}"

    def authenticate(self, path, data):
        email, password = data.get("email", ""), data.get("password", "")
        name = data.get("name", "")
        if not all(isinstance(v, str) for v in (email, password, name)):
            return self.send(400, {"error": "بيانات غير صالحة"})
        email = email.strip().lower()
        if not re.fullmatch(r"[^\s@]+@[^\s@]+\.[^\s@]+", email) or len(email) > 254 or not 8 <= len(password) <= 128:
            return self.send(400, {"error": "أدخل بريدًا صحيحًا وكلمة مرور من 8 إلى 128 حرفًا"})
        with database() as db:
            now = time.time()
            db.execute("DELETE FROM login_attempts WHERE expires<?", (now,))
            db.execute("DELETE FROM sessions WHERE expires<?", (now,))
            address = self.client_address[0]
            attempt = db.execute("SELECT count FROM login_attempts WHERE address=?", (address,)).fetchone()
            if attempt and attempt[0] >= 20:
                return self.send(429, {"error": "محاولات كثيرة؛ حاول بعد 15 دقيقة"})
            db.execute("INSERT INTO login_attempts VALUES (?,1,?) ON CONFLICT(address) DO UPDATE SET count=count+1", (address, now + 900))
        with database() as db:
            if path == "/api/register":
                name = name.strip()
                if not 2 <= len(name) <= 60:
                    return self.send(400, {"error": "أدخل اسمًا من حرفين إلى 60 حرفًا"})
                try:
                    db.execute("INSERT INTO users(name,email,password) VALUES (?,?,?)", (name, email, hash_password(password)))
                except sqlite3.IntegrityError:
                    return self.send(409, {"error": "لا يمكن إنشاء الحساب بهذا البريد؛ جرّب تسجيل الدخول"})
            user = db.execute("SELECT * FROM users WHERE email=?", (email,)).fetchone()
            stored = user["password"] if user else hash_password("dummy-password")
            if not user or not hmac.compare_digest(stored, hash_password(password, stored.split("$")[0])):
                return self.send(401, {"error": "البريد أو كلمة المرور غير صحيحة"})
            token, csrf = secrets.token_urlsafe(32), secrets.token_urlsafe(32)
            db.execute("INSERT INTO sessions VALUES (?,?,?,?)", (hashlib.sha256(token.encode()).hexdigest(), user["id"], csrf, now + 604800))
            db.execute("DELETE FROM login_attempts WHERE address=?", (address,))
        return self.send(200, {"ok": True}, self.cookie(token))


if __name__ == "__main__":
    init_db()
    host, port = os.environ.get("HOST", "127.0.0.1"), int(os.environ.get("PORT", "5000"))
    print(f"عون وسند — http://{host}:{port}", flush=True)
    ThreadingHTTPServer((host, port), Handler).serve_forever()
