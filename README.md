# إرسال رسائل SMS للأعضاء (chinguisoft)

سكربت بايثون يرسل رسالة نصية واحدة موحّدة لقائمة من الأعضاء عبر API شركة **chinguisoft** (chinguisoft.com)، بفاصل زمني (دقيقة افتراضيًا) بين كل رسالة والتي تليها.

## الإعداد

```bash
pip install -r requirements.txt
cp .env.example .env
```

عدّل ملف `.env` وضع فيه بيانات حملة chinguisoft (من لوحة التحكم: المفتاح والرمز السري الخاصين بالحملة):

```
CHINGUISOFT_API_URL=...
CHINGUISOFT_CAMPAIGN_KEY=...
CHINGUISOFT_CAMPAIGN_TOKEN=...
```

> ملاحظة: شكل الطلب الحالي في `send_sms.py` (دالة `send_one`) نموذج مبدئي (placeholder) بانتظار تأكيد رابط الـ endpoint الدقيق من توثيق/نموذج الكود في لوحة chinguisoft، لأن الموقع يمنع الجلب الآلي للتوثيق. الحقول `campaign_key` و`Campaign-token` مأخوذة من تسميات لوحة التحكم نفسها.
>
> ⚠️ رصيد حملة "Awn-wasand" الحالي: **0 رسائل متوفرة** — تأكد من شحن الرصيد قبل التجربة الفعلية.

## البيانات

- انسخ `members_template.csv` إلى `members.csv` وعبّئه بأسماء وأرقام الأعضاء (عمودين: `name,phone`).
- عدّل `message.txt` بنص الرسالة الموحدة التي سترسل للجميع.

`members.csv` مستثنى من Git عمدًا (في `.gitignore`) لأنه يحتوي بيانات شخصية.

## التشغيل

```bash
python send_sms.py --members members.csv --message message.txt
```

يمكن تغيير الفاصل الزمني بين الرسائل (بالثواني، الافتراضي 60):

```bash
python send_sms.py --delay 60
```

نتائج الإرسال (نجاح/فشل) تُسجَّل في `sent_log.csv`.
