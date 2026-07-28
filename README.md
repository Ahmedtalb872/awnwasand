# إرسال رسائل SMS للأعضاء (chinguisoft)

سكربت بايثون يُشغّل حملة SMS جاهزة على **chinguisoft** (chinguisoft.com) لقائمة من الأعضاء، بفاصل زمني (دقيقة افتراضيًا) بين كل إرسال والذي يليه.

نص الرسالة نفسه **لا يُرسل من هذا السكربت** — هو معرّف مسبقًا داخل الحملة ("Awn-wasand") من لوحة تحكم chinguisoft. السكربت فقط يُطلق الإرسال لكل رقم، مع إمكانية إدراج رابط (مثلاً رابط المساهمة/التبرع) داخل الرسالة عبر `--url`.

## الإعداد

```bash
pip install -r requirements.txt
cp .env.example .env
```

عدّل ملف `.env` وضع فيه بيانات حملة chinguisoft (من لوحة التحكم: المفتاح والرمز السري الخاصين بالحملة):

```
CHINGUISOFT_API_URL=https://chinguisoft.com
CHINGUISOFT_CAMPAIGN_KEY=...
CHINGUISOFT_CAMPAIGN_TOKEN=...
```

> ⚠️ رصيد حملة "Awn-wasand" وقت الإعداد: **0 رسائل متوفرة** — تأكد من شحن الرصيد قبل التجربة الفعلية. الرد من الـ API يتضمن `balance` (الرصيد المتبقي بعد كل إرسال) ويُسجَّل في `sent_log.csv`.

## البيانات

انسخ `members_template.csv` إلى `members.csv` وعبّئه بأسماء وأرقام الأعضاء (عمودين: `name,phone`).

`members.csv` مستثنى من Git عمدًا (في `.gitignore`) لأنه يحتوي بيانات شخصية.

## التشغيل

```bash
python send_sms.py --members members.csv
```

لإدراج رابط (مثل رابط المساهمة) داخل الرسالة:

```bash
python send_sms.py --members members.csv --url https://example.com/donate
```

يمكن تغيير الفاصل الزمني بين الرسائل (بالثواني، الافتراضي 60):

```bash
python send_sms.py --members members.csv --delay 60
```

نتائج الإرسال (نجاح/فشل + رد الـ API) تُسجَّل في `sent_log.csv`.

## واجهة ويب محلية (بديل عن سطر الأوامر)

```bash
python app.py
```

ثم افتح `http://localhost:5000` — تعرض الصفحة جدول الأعضاء وزر "ابدأ الإرسال" مع تقدّم حي لكل رسالة (نجحت/فشلت).

⚠️ هذه الواجهة **محلية فقط** ويجب ألا تُنشر كصفحة عامة على الإنترنت: رمز حملة chinguisoft السري يبقى على الخادم (من `.env`) ولا يصل للمتصفح، لكن أي شخص يفتح هذه الصفحة يقدر يضغط "إرسال" ويستهلك رصيد الحملة.
