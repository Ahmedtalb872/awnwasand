# إرسال رسائل SMS للأعضاء (chingsoft)

سكربت بايثون يرسل رسالة نصية واحدة موحّدة لقائمة من الأعضاء عبر API شركة **chingsoft**، بفاصل زمني (دقيقة افتراضيًا) بين كل رسالة والتي تليها.

## الإعداد

```bash
pip install -r requirements.txt
cp .env.example .env
```

عدّل ملف `.env` وضع فيه بيانات API الخاصة بـ chingsoft:

```
CHINGSOFT_API_URL=...
CHINGSOFT_API_KEY=...
CHINGSOFT_SENDER_NAME=...
```

> ملاحظة: شكل الطلب الحالي في `send_sms.py` (دالة `send_one`) هو نموذج مبدئي (placeholder) ويحتاج تعديل ليطابق توثيق chingsoft الفعلي (رابط الـ endpoint، طريقة المصادقة، وشكل الحقول).

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
