"""Read-only readiness checks using the browser's public Supabase key."""
import json
import os
import urllib.error
import urllib.request
from pathlib import Path

config = json.loads(Path('config/public_backend.json').read_text())
url = (os.environ.get('SUPABASE_URL') or config['SUPABASE_URL']).rstrip('/')
key = os.environ.get('SUPABASE_ANON_KEY') or config['SUPABASE_ANON_KEY']
results = []


def fetch(path):
    request = urllib.request.Request(url + path, headers={'apikey': key})
    try:
        with urllib.request.urlopen(request, timeout=20) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as error:
        try:
            data = json.loads(error.read())
        except ValueError:
            data = {}
        return error.code, data


try:
    status, settings = fetch('/auth/v1/settings')
    results.append({'component': 'authentication', 'status': status, 'ready': status == 200,
                    'phone_enabled': settings.get('external', {}).get('phone'),
                    'sms_autoconfirm': settings.get('sms_autoconfirm')})
    for table, column in [('profiles', 'id'), ('courses', 'id'), ('course_materials', 'id'), ('enrollments', 'course_id')]:
        status, payload = fetch(f'/rest/v1/{table}?select={column}&limit=1')
        code = payload.get('code') if isinstance(payload, dict) else None
        exists = code == '42501' or status == 200
        # Never print records. Anonymous profile/enrollment rows are a setup error.
        exposed = table in ('profiles', 'enrollments') and status == 200 and bool(payload)
        results.append({'component': table, 'status': status, 'code': code, 'exists': exists, 'anonymous_rows_exposed': exposed})
except (urllib.error.URLError, TimeoutError) as error:
    results.append({'component': 'connection', 'ready': False, 'error_type': type(error).__name__})

ready = len(results) == 5 and results[0]['ready'] and all(item.get('exists') and not item.get('anonymous_rows_exposed') for item in results[1:])
report = {'project_url': url, 'schema_detected': ready, 'checks': results}
Path('/tmp/backend-readiness.json').write_text(json.dumps(report, indent=2))
print(json.dumps(report, indent=2))
summary = os.environ.get('GITHUB_STEP_SUMMARY')
if summary:
    with open(summary, 'a') as output:
        output.write('## Supabase readiness\n\n')
        output.write('Schema detected; authenticated policy checks still require configured accounts.\n' if ready else 'Backend setup is incomplete. Apply the supplied schema or connect the Supabase integration.\n')
