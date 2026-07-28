"""
Local web UI to run the chinguisoft SMS campaign against members.csv.

The chinguisoft campaign token is loaded from .env and used only on the
server side - it is never sent to the browser. Run locally with
`python app.py` and open http://localhost:5000.
"""

import csv
import os
import threading
import time
from datetime import datetime

from flask import Flask, jsonify, render_template_string, request

import send_sms

app = Flask(__name__)

STATE_LOCK = threading.Lock()
state = {
    "running": False,
    "total": 0,
    "sent": 0,
    "results": [],
}


def load_members():
    path = "members.csv"
    if not os.path.exists(path):
        return []
    with open(path, newline="", encoding="utf-8-sig") as f:
        return list(csv.DictReader(f))


def run_campaign(delay: int, lang: str, url: str | None) -> None:
    members = load_members()
    with STATE_LOCK:
        state["running"] = True
        state["total"] = len(members)
        state["sent"] = 0
        state["results"] = []

    for i, member in enumerate(members):
        name = member.get("name", "").strip()
        phone = member.get("phone", "").strip()
        if not phone:
            continue

        success, detail = send_sms.send_one(phone, lang, url)
        send_sms.log_result(name, phone, success, detail)

        with STATE_LOCK:
            state["sent"] += 1
            state["results"].insert(0, {
                "name": name,
                "phone": phone,
                "status": "sent" if success else "failed",
                "detail": detail,
                "time": datetime.now().strftime("%H:%M:%S"),
            })

        if i < len(members) - 1:
            time.sleep(delay)

    with STATE_LOCK:
        state["running"] = False


@app.route("/")
def index():
    members = load_members()
    configured = bool(
        os.environ.get("CHINGUISOFT_CAMPAIGN_KEY") and os.environ.get("CHINGUISOFT_CAMPAIGN_TOKEN")
    )
    return render_template_string(PAGE, members=members, count=len(members), configured=configured)


@app.route("/api/start", methods=["POST"])
def start():
    with STATE_LOCK:
        if state["running"]:
            return jsonify({"error": "already running"}), 409

    payload = request.get_json(silent=True) or {}
    try:
        delay = max(1, int(payload.get("delay", 60)))
    except (TypeError, ValueError):
        delay = 60
    lang = payload.get("lang") or "ar"
    url = payload.get("url") or None

    thread = threading.Thread(target=run_campaign, args=(delay, lang, url), daemon=True)
    thread.start()
    return jsonify({"started": True})


@app.route("/api/status")
def status():
    with STATE_LOCK:
        return jsonify(state)


PAGE = """
<!doctype html>
<html dir="rtl" lang="ar">
<head>
<meta charset="utf-8">
<title>إرسال حملة SMS - عون وسند</title>
<style>
  :root{
    --bg:#221D3F; --panel:#2B2550; --line:#3E3670;
    --accent:#F0ACA0; --accent-soft:#F6CDBE;
    --text:#F8F3EF; --text-dim:#CFC7DE;
    --ok:#7FD8A0; --fail:#F08A8A;
  }
  *{ box-sizing:border-box; }
  body{
    margin:0; background:var(--bg); color:var(--text);
    font-family:'Segoe UI', Tahoma, Cairo, sans-serif;
    padding:32px clamp(16px,4vw,48px) 64px;
  }
  h1{ font-size:1.4rem; margin:0 0 4px; }
  .sub{ color:var(--text-dim); margin:0 0 28px; font-size:.9rem; }
  .warn{
    background:#4A2E2E; border:1px solid #7A3E3E; color:#F3C9C9;
    padding:12px 16px; border-radius:10px; margin-bottom:20px; font-size:.9rem;
  }
  .panel{
    background:var(--panel); border:1px solid var(--line); border-radius:16px;
    padding:20px; margin-bottom:20px;
  }
  .controls{ display:flex; gap:14px; flex-wrap:wrap; align-items:end; }
  .field{ display:flex; flex-direction:column; gap:6px; font-size:.85rem; color:var(--text-dim); }
  input{
    background:var(--bg); border:1px solid var(--line); color:var(--text);
    border-radius:8px; padding:8px 10px; font-size:.9rem; min-width:160px;
    font-variant-numeric:tabular-nums;
  }
  button{
    background:var(--accent); color:#221D3F; border:none; border-radius:100px;
    padding:10px 24px; font-weight:700; font-size:.95rem; cursor:pointer;
  }
  button:hover{ background:var(--accent-soft); }
  button:disabled{ opacity:.5; cursor:not-allowed; }
  .progress-row{ display:flex; justify-content:space-between; font-size:.85rem; color:var(--text-dim); margin-bottom:8px; }
  .bar{ height:8px; background:var(--bg); border-radius:100px; overflow:hidden; }
  .bar-fill{ height:100%; background:var(--accent); width:0%; transition:width .3s ease; }
  table{ width:100%; border-collapse:collapse; font-size:.88rem; }
  th, td{ text-align:right; padding:9px 10px; border-bottom:1px solid var(--line); }
  th{ color:var(--text-dim); font-weight:600; font-size:.8rem; }
  td.phone{ font-variant-numeric:tabular-nums; color:var(--text-dim); }
  .chip{
    display:inline-block; padding:2px 10px; border-radius:100px; font-size:.75rem;
  }
  .chip.pending{ background:#3E3670; color:var(--text-dim); }
  .chip.sent{ background:#1F3B2C; color:var(--ok); }
  .chip.failed{ background:#3B1F1F; color:var(--fail); }
  .table-wrap{ overflow-x:auto; }
</style>
</head>
<body>
  <h1>حملة SMS - جمعية عون وسند</h1>
  <p class="sub">إرسال حملة chinguisoft لجميع أعضاء القائمة، رسالة واحدة كل مدة تحدّدها.</p>

  {% if not configured %}
  <div class="warn">
    ⚠️ بيانات chinguisoft غير مضبوطة في ملف .env (CHINGUISOFT_CAMPAIGN_KEY / CHINGUISOFT_CAMPAIGN_TOKEN).
    الإرسال سيفشل حتى تُضبط.
  </div>
  {% endif %}

  <div class="panel">
    <div class="controls">
      <div class="field">
        <label for="delay">التأخير بين الرسائل (ثانية)</label>
        <input type="number" id="delay" value="60" min="1">
      </div>
      <div class="field">
        <label for="url">رابط اختياري (مثل رابط المساهمة)</label>
        <input type="text" id="url" placeholder="https://...">
      </div>
      <button id="startBtn" onclick="startCampaign()">ابدأ الإرسال لـ {{ count }} عضوًا</button>
    </div>
  </div>

  <div class="panel">
    <div class="progress-row">
      <span id="progressLabel">لم يبدأ الإرسال بعد</span>
      <span id="progressCount">0 / {{ count }}</span>
    </div>
    <div class="bar"><div class="bar-fill" id="barFill"></div></div>
  </div>

  <div class="panel table-wrap">
    <table>
      <thead>
        <tr><th>الاسم</th><th>الهاتف</th><th>الحالة</th><th>الوقت</th></tr>
      </thead>
      <tbody id="resultsBody">
        <tr><td colspan="4" style="color:var(--text-dim)">النتائج ستظهر هنا بعد بدء الإرسال</td></tr>
      </tbody>
    </table>
  </div>

<script>
const total = {{ count }};
let polling = null;

function startCampaign(){
  const delay = parseInt(document.getElementById('delay').value || '60', 10);
  const url = document.getElementById('url').value.trim();
  const msg = `سيتم إرسال رسالة إلى ${total} عضوًا بفاصل ${delay} ثانية بين كل رسالة. هل تريد المتابعة؟`;
  if (!confirm(msg)) return;

  document.getElementById('startBtn').disabled = true;
  fetch('/api/start', {
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body: JSON.stringify({ delay, lang: 'ar', url: url || null })
  }).then(r => r.json()).then(() => {
    if (!polling) polling = setInterval(poll, 1500);
  });
}

function poll(){
  fetch('/api/status').then(r => r.json()).then(s => {
    document.getElementById('progressCount').textContent = `${s.sent} / ${s.total || total}`;
    const pct = s.total ? Math.round((s.sent / s.total) * 100) : 0;
    document.getElementById('barFill').style.width = pct + '%';
    document.getElementById('progressLabel').textContent = s.running ? 'جارٍ الإرسال...' : (s.sent ? 'انتهى الإرسال' : 'لم يبدأ الإرسال بعد');

    const body = document.getElementById('resultsBody');
    if (s.results && s.results.length){
      body.innerHTML = s.results.map(r => `
        <tr>
          <td>${escapeHtml(r.name || '-')}</td>
          <td class="phone">${escapeHtml(r.phone)}</td>
          <td><span class="chip ${r.status}">${r.status === 'sent' ? 'أُرسلت' : 'فشلت'}</span></td>
          <td>${r.time}</td>
        </tr>
      `).join('');
    }

    if (!s.running){
      document.getElementById('startBtn').disabled = false;
      if (polling){ clearInterval(polling); polling = null; }
    }
  });
}

function escapeHtml(str){
  const div = document.createElement('div');
  div.textContent = str;
  return div.innerHTML;
}

poll();
</script>
</body>
</html>
"""


if __name__ == "__main__":
    app.run(debug=False, port=5000)
