import http.client
import io
import json
import tempfile
import unittest
from pathlib import Path

import app
from curriculum import LESSONS


class LearningTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory()
        app.DB_PATH = str(Path(cls.temp.name) / "test.sqlite3")
        app.init_db()

    @classmethod
    def tearDownClass(cls):
        cls.temp.cleanup()

    def setUp(self):
        self.cookie = ""
        self.csrf = ""

    def request(self, path, data=None, headers=None):
        h = {"Content-Type": "application/json", "Cookie": self.cookie, "X-CSRF-Token": self.csrf}
        h.update(headers or {})
        body = json.dumps(data).encode() if data is not None else b""
        h.update({"Host": "localhost", "Content-Length": str(len(body))})
        method = "POST" if data is not None else "GET"
        raw_request = (f"{method} {path} HTTP/1.0\r\n" + "".join(f"{k}: {v}\r\n" for k, v in h.items()) + "\r\n").encode() + body

        class MemoryConnection:
            def __init__(self, raw):
                self.input = io.BytesIO(raw)
                self.output = io.BytesIO()

            def makefile(self, *args):
                return self.input

            def sendall(self, value):
                self.output.write(value)

        connection = MemoryConnection(raw_request)
        app.Handler(connection, ("127.0.0.1", 12345), None)
        response = http.client.HTTPResponse(MemoryConnection(connection.output.getvalue()))
        response.begin()
        cookie = response.getheader("Set-Cookie")
        raw = response.read()
        status = response.status
        if cookie:
            self.cookie = cookie.split(";")[0]
        response.close()
        return status, json.loads(raw) if raw.startswith(b"{") else raw

    def register(self):
        import secrets
        status, _ = self.request("/api/register", {"name": "متعلم", "email": secrets.token_hex(8)+"@test.example", "password": "test-password-123"})
        self.assertEqual(status, 200)
        status, me = self.request("/api/me")
        self.csrf = me["user"]["csrf"]
        return me["user"]

    def test_catalog_hides_quiz_answers(self):
        status, data = self.request("/api/catalog")
        self.assertEqual(status, 200)
        self.assertEqual(len(data["tracks"]), 6)
        self.assertEqual(len(data["lessons"]), 12)
        for lesson in data["lessons"]:
            self.assertTrue(lesson["source_url"].startswith("https://"))
            for question in lesson["questions"]:
                self.assertNotIn("answer", question)
                self.assertNotIn("explanation", question)

    def test_guest_can_read_but_cannot_write(self):
        self.assertEqual(self.request("/")[0], 200)
        self.assertEqual(self.request("/api/quiz", {"lesson_id": "faith-1", "answers": [1, 0]})[0], 401)

    def test_quiz_score_persistence_and_no_duplicate_completion(self):
        self.register()
        answers = [q["answer"] for q in LESSONS[0]["questions"]]
        status, result = self.request("/api/quiz", {"lesson_id": "faith-1", "answers": answers})
        self.assertEqual(status, 200)
        self.assertTrue(result["passed"])
        self.assertEqual(result["score"], 100)
        self.request("/api/quiz", {"lesson_id": "faith-1", "answers": [0, 2]})
        progress = self.request("/api/me")[1]["user"]["progress"]
        self.assertEqual(len(progress), 1)
        self.assertEqual(progress[0]["best_score"], 100)
        self.assertEqual(progress[0]["completed"], 1)
        self.assertEqual(progress[0]["attempts"], 2)

    def test_failed_quiz_not_completed(self):
        self.register()
        status, result = self.request("/api/quiz", {"lesson_id": "faith-1", "answers": [0, 2]})
        self.assertEqual(status, 200)
        self.assertFalse(result["passed"])
        self.assertEqual(self.request("/api/me")[1]["user"]["progress"][0]["completed"], 0)

    def test_bookmark_goal_and_logout(self):
        self.register()
        self.assertTrue(self.request("/api/bookmark", {"lesson_id": "faith-1"})[1]["saved"])
        self.assertEqual(self.request("/api/me")[1]["user"]["bookmarks"], ["faith-1"])
        self.assertFalse(self.request("/api/bookmark", {"lesson_id": "faith-1"})[1]["saved"])
        self.assertEqual(self.request("/api/goal", {"goal": 3})[0], 200)
        self.assertEqual(self.request("/api/me")[1]["user"]["goal"], 3)
        self.assertEqual(self.request("/api/logout", {})[0], 200)
        self.assertIsNone(self.request("/api/me")[1]["user"])

    def test_invalid_answers_and_goal_rejected(self):
        self.register()
        for answers in ([1], [True, 0], [100, 0], "bad"):
            self.assertEqual(self.request("/api/quiz", {"lesson_id": "faith-1", "answers": answers})[0], 400)
        self.assertEqual(self.request("/api/goal", {"goal": 0})[0], 400)
        self.assertEqual(self.request("/api/quiz", {"lesson_id": "missing", "answers": [0, 0]})[0], 404)

    def test_csrf_and_cross_origin_rejected(self):
        self.register()
        self.assertEqual(self.request("/api/goal", {"goal": 2}, {"X-CSRF-Token": "wrong"})[0], 403)
        self.assertEqual(self.request("/api/goal", {"goal": 2}, {"Origin": "https://untrusted.example"})[0], 403)
        self.assertEqual(self.request("/api/login", {}, {"Content-Type": "text/plain"})[0], 415)

    def test_users_have_separate_progress(self):
        self.register()
        self.request("/api/bookmark", {"lesson_id": "faith-1"})
        self.cookie = ""
        second = self.register()
        self.assertEqual(second["bookmarks"], [])
        self.assertEqual(second["progress"], [])

    def test_login_and_password_storage(self):
        self.register()
        with app.database() as db:
            row = db.execute("SELECT email,password FROM users ORDER BY id DESC LIMIT 1").fetchone()
        self.assertNotEqual(row["password"], "test-password-123")
        self.request("/api/logout", {})
        self.assertEqual(self.request("/api/login", {"email": row["email"], "password": "incorrect-password"})[0], 401)
        self.assertEqual(self.request("/api/login", {"email": row["email"], "password": "test-password-123"})[0], 200)

    def test_static_path_traversal_rejected(self):
        self.assertEqual(self.request("/static/../app.py")[0], 404)
        self.assertEqual(self.request("/static/app.js")[0], 200)


if __name__ == "__main__":
    unittest.main()
