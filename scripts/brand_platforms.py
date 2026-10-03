"""Apply the approved display name after Flutter generates platform tooling."""
import json
from pathlib import Path

root = Path(__file__).resolve().parent.parent
manifest = root / 'web/manifest.json'
if manifest.exists():
    data = json.loads(manifest.read_text())
    data.update(name='المحجة البيضاء', short_name='المحجة البيضاء',
                description='المحجة البيضاء للعلوم الشرعية',
                theme_color='#2b274b', background_color='#faf8f5')
    data['icons'] = [{'src': 'brand-logo.jpg', 'sizes': 'any', 'type': 'image/jpeg', 'purpose': 'any'}]
    manifest.write_text(json.dumps(data, ensure_ascii=False, indent=2))

android = root / 'android/app/src/main/AndroidManifest.xml'
if android.exists():
    android.write_text(android.read_text().replace('android:label="awnwasand"', 'android:label="المحجة البيضاء"'))
