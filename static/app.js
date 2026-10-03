'use strict';
const view = document.querySelector('#view');
let catalog, user = null, register = false, noticeTimer;
const esc = value => String(value).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const trackFor = id => catalog.tracks.find(t => t.id === id);
const progressFor = id => user?.progress.find(p => p.lesson_id === id);
const done = id => Boolean(progressFor(id)?.completed);
function notify(message) {
  document.querySelector('#notice').textContent = message;
  clearTimeout(noticeTimer);
  noticeTimer = setTimeout(() => document.querySelector('#notice').textContent = '', 6000);
}
async function api(path, data) {
  const response = await fetch(path, data === undefined ? {} : {method:'POST', headers:{'Content-Type':'application/json','X-CSRF-Token':user?.csrf || ''},body:JSON.stringify(data)});
  const result = await response.json();
  if (!response.ok) throw new Error(result.error || 'تعذر إتمام الطلب');
  return result;
}
async function refreshUser() {
  user = (await api('/api/me')).user;
  document.querySelector('#account').textContent = user ? `${user.name} · خروج` : 'تسجيل الدخول';
}
function needUser() { if (user) return true; document.querySelector('#auth').showModal(); return false; }
function lessonRow(l) {
  return `<a class="lesson-row" href="#lesson/${l.id}"><div><span class="eyebrow">${esc(trackFor(l.track).title)}</span><h3>${esc(l.title)}</h3><p>${l.minutes} دقائق · اختبار قصير · مصدر موثّق</p></div><span class="pill">${done(l.id) ? '✓ مكتمل' : 'ابدأ الدرس ←'}</span></a>`;
}
function trackCard(t) {
  const lessons = catalog.lessons.filter(l => l.track === t.id), count = lessons.filter(l => done(l.id)).length;
  return `<a class="card" href="#track/${t.id}"><span class="icon">${t.icon}</span><h3>${esc(t.title)}</h3><p>${esc(t.description)}</p><div class="card-bottom"><span>${lessons.length} دروس · للمبتدئين</span><span>استكشف ←</span></div>${user ? `<progress class="meter" value="${count}" max="${lessons.length}" aria-label="تقدم المسار"></progress><small>${count} / ${lessons.length} مكتمل</small>` : ''}</a>`;
}
function home() {
  const next = catalog.lessons.find(l => !done(l.id)) || catalog.lessons[0];
  view.innerHTML = `<section class="hero"><div><span class="eyebrow">رحلة علم تُضيء حياتك</span><h1>تعلّم دينك.<br>وابنِ أثرًا يدوم.</h1><p>مسارات واضحة في القرآن والسنة والعبادات والأخلاق. تعلّم على مهل، اختبر فهمك، واجعل كل درس خطوة إلى عمل صالح.</p><div class="actions"><a class="gold" href="#lesson/${next.id}">${user ? 'تابع رحلتك' : 'ابدأ التعلم الآن'} ←</a><a class="outline" href="#tracks">اكتشف المسارات</a></div></div><div class="hero-art" aria-hidden="true"><span>۞</span><small>علمٌ · عملٌ · ارتقاء</small></div></section><div class="stats"><div class="stat"><strong>6</strong><span>مسارات تعليمية</span></div><div class="stat"><strong>12</strong><span>درسًا تمهيديًا موثّقًا</span></div><div class="stat"><strong>${user ? user.progress.filter(p => p.completed).length : '6'}</strong><span>${user ? 'دروس أنجزتها' : 'دقائق للدرس'}</span></div></div><div class="section-head"><div><span class="eyebrow">اختر وجهتك</span><h2>مسارات التعلم</h2></div><a href="#tracks">عرض الكل ←</a></div><div class="grid">${catalog.tracks.map(trackCard).join('')}</div><section class="callout"><span class="eyebrow">من العلم إلى العمل</span><h3>قليلٌ مستمر، خيرٌ من بداية تنقطع</h3><p>اختر درسًا اليوم، راجع مصدره، ثم طبّق فائدته العملية.</p><a href="#lesson/${next.id}">درس اليوم: ${esc(next.title)} ←</a></section>`;
}
function library(saved = false) {
  view.innerHTML = `<span class="eyebrow">ابحث، اقرأ، وتعلّم</span><h1>${saved ? 'الدروس المحفوظة' : 'مكتبة الدروس'}</h1><div class="filters"><input id="search" type="search" placeholder="ابحث عن درس أو موضوع…" aria-label="البحث في الدروس"><select id="filter" aria-label="تصفية حسب المسار"><option value="">كل المسارات</option>${catalog.tracks.map(t => `<option value="${t.id}">${esc(t.title)}</option>`).join('')}</select><button id="saved-filter" class="outline">${saved ? 'كل الدروس' : 'المحفوظات'}</button></div><div id="results"></div>`;
  function results() {
    const query = document.querySelector('#search').value.trim(), track = document.querySelector('#filter').value;
    const list = catalog.lessons.filter(l => (!saved || user?.bookmarks.includes(l.id)) && (!track || l.track === track) && `${l.title} ${l.paragraphs.join(' ')} ${trackFor(l.track).title}`.includes(query));
    document.querySelector('#results').innerHTML = list.length ? list.map(lessonRow).join('') : '<div class="empty">لا توجد دروس مطابقة. جرّب بحثًا آخر أو احفظ درسًا للعودة إليه.</div>';
  }
  document.querySelector('#search').addEventListener('input', results);
  document.querySelector('#filter').addEventListener('change', results);
  document.querySelector('#saved-filter').onclick = () => { if (saved || needUser()) location.hash = saved ? '#library' : '#saved'; };
  results();
}
function reading(id) {
  const l = catalog.lessons.find(item => item.id === id);
  if (!l) return missing();
  const t = trackFor(l.track);
  view.innerHTML = `<div class="reading"><a class="muted" href="#track/${t.id}">← ${esc(t.title)}</a><h1>${esc(l.title)}</h1><p class="muted">${l.minutes} دقائق · المستوى التمهيدي ${done(l.id) ? '· ✓ مكتمل' : ''}</p><article>${l.paragraphs.map(p => `<p>${esc(p)}</p>`).join('')}<div class="source"><strong>مرجع الدرس</strong><br><a href="${esc(l.source_url)}" target="_blank" rel="noopener noreferrer">${esc(l.source)} ↗</a><p>الشرح أعلاه صياغة تعليمية، ويمكن مراجعة النص الأصلي من المصدر.</p></div></article><div class="callout"><strong>خطوة عملية</strong><p>${esc(l.task)}</p></div><button id="bookmark" class="outline">${user?.bookmarks.includes(id) ? '★ إزالة من المحفوظات' : '☆ احفظ للعودة لاحقًا'}</button><form class="quiz" id="quiz"><span class="eyebrow">اختبر فهمك</span><h2>مراجعة الدرس</h2><p>أجب عن السؤالين. يُحتسب الدرس مكتملًا عند تحقيق 70٪ على الأقل.</p>${l.questions.map((q,i) => `<fieldset><legend>${i+1}. ${esc(q.prompt)}</legend>${q.options.map((o,j) => `<label><input type="radio" name="q${i}" value="${j}" required>${esc(o)}</label>`).join('')}</fieldset>`).join('')}<button class="primary" type="submit">تحقق من إجاباتي</button><div id="feedback" aria-live="polite"></div></form><div class="actions"><a class="outline" href="#track/${t.id}">العودة إلى المسار</a></div></div>`;
  document.querySelector('#bookmark').onclick = async () => {
    if (!needUser()) return;
    try { const result = await api('/api/bookmark', {lesson_id:id}); await refreshUser(); document.querySelector('#bookmark').textContent = result.saved ? '★ إزالة من المحفوظات' : '☆ احفظ للعودة لاحقًا'; notify(result.saved ? 'حُفظ الدرس' : 'أُزيل من المحفوظات'); } catch(e) { notify(e.message); }
  };
  document.querySelector('#quiz').onsubmit = async event => {
    event.preventDefault(); if (!needUser()) return;
    const button = event.target.querySelector('button'), answers = l.questions.map((_,i) => Number(new FormData(event.target).get(`q${i}`)));
    button.disabled = true;
    try {
      const result = await api('/api/quiz', {lesson_id:id, answers}); await refreshUser();
      document.querySelector('#feedback').innerHTML = `<div class="feedback ${result.passed ? '' : 'fail'}"><strong>${result.score}٪ — ${result.passed ? 'أحسنت! حُفظ إنجازك.' : 'راجع الدرس وحاول مرة أخرى.'}</strong>${result.feedback.map((f,i) => `<p>${f.correct ? '✓' : '○'} ${esc(f.explanation)}<br><small>الإجابة الصحيحة: ${esc(l.questions[i].options[f.answer])}</small></p>`).join('')}</div>`;
    } catch(e) { notify(e.message); } finally { button.disabled = false; }
  };
}
function progress() {
  if (!user) { view.innerHTML = '<div class="empty"><h2>رحلتك تستحق المتابعة</h2><p>أنشئ حسابًا لحفظ نتائجك ودروسك وأهدافك.</p><button id="progress-login" class="primary">ابدأ بحسابك</button></div>'; document.querySelector('#progress-login').onclick = needUser; return; }
  const complete = catalog.lessons.filter(l => done(l.id));
  const today = new Date().toISOString().slice(0,10);
  const todayCount = user.progress.filter(p => p.completed && p.updated === today).length;
  view.innerHTML = `<span class="eyebrow">كل خطوة تصنع فرقًا</span><h1>رحلتك يا ${esc(user.name)}</h1><div class="stats"><div class="stat"><strong>${complete.length} / ${catalog.lessons.length}</strong><span>دروس مكتملة</span></div><div class="stat"><strong>${user.progress.reduce((n,p) => n+p.attempts,0)}</strong><span>محاولات الاختبارات</span></div><div class="stat"><strong>${user.bookmarks.length}</strong><span>دروس محفوظة</span></div></div><div class="callout"><label for="goal">هدفي اليومي</label> <select id="goal">${[1,2,3,4,5].map(n => `<option value="${n}" ${user.goal===n ? 'selected' : ''}>${n} درس</option>`).join('')}</select> <button id="save-goal" class="primary">حفظ الهدف</button><p>${Math.min(todayCount,user.goal)} / ${user.goal} من الهدف اليوم (بتوقيت UTC). مراجعة درس مكتمل تُحتسب مرة واحدة اليوم.</p></div><div class="grid">${catalog.tracks.map(trackCard).join('')}</div><div class="section-head"><h2>إنجازات المسارات</h2></div>${catalog.tracks.filter(t => catalog.lessons.filter(l => l.track===t.id).every(l => done(l.id))).map(t => `<div class="certificate"><span class="eyebrow">إنجاز تعليمي داخل التطبيق</span><h2>أتممت مسار ${esc(t.title)}</h2><p>${esc(user.name)}</p><p>أكملت الدروس واجتزت اختبارات المسار التمهيدي.</p><small>سجل إنجاز شخصي؛ لا يمثل شهادة علمية معتمدة.</small></div>`).join('') || '<p class="muted">أكمل أحد المسارات ليظهر سجل إنجازك هنا.</p>'}<div class="actions"><button id="print" class="outline">طباعة الإنجازات</button><a href="#saved" class="outline">دروسي المحفوظة</a></div>`;
  document.querySelector('#save-goal').onclick = async () => { try { await api('/api/goal', {goal:Number(document.querySelector('#goal').value)}); await refreshUser(); progress(); notify('حُفظ هدفك اليومي'); } catch(e) { notify(e.message); } };
  document.querySelector('#print').onclick = () => window.print();
}
function missing() { view.innerHTML = '<div class="empty"><h2>الصفحة غير موجودة</h2><a href="#home">العودة للرئيسية</a></div>'; }
function render() {
  if (!catalog) return;
  const [page,id] = (location.hash.slice(1) || 'home').split('/');
  if (page==='home') home();
  else if (page==='tracks') view.innerHTML = `<span class="eyebrow">علم على بصيرة</span><h1>مسارات التعلم</h1><p class="muted">ابدأ بالمسار الذي تحتاجه. جميع الدروس متاحة للقراءة دون حساب.</p><div class="grid">${catalog.tracks.map(trackCard).join('')}</div>`;
  else if (page==='track') { const t = trackFor(id); if (!t) return missing(); view.innerHTML = `<a class="muted" href="#tracks">← جميع المسارات</a><h1>${esc(t.title)}</h1><p>${esc(t.description)}</p>${catalog.lessons.filter(l => l.track===id).map(lessonRow).join('')}`; }
  else if (page==='library' || page==='saved') library(page==='saved');
  else if (page==='lesson') reading(id);
  else if (page==='progress') progress();
  else missing();
  window.scrollTo(0,0);
}
document.querySelector('#account').onclick = async () => {
  if (!user) return needUser();
  try { await api('/api/logout', {}); await refreshUser(); render(); notify('تم تسجيل الخروج'); } catch(e) { notify(e.message); }
};
document.querySelector('#close-auth').onclick = () => document.querySelector('#auth').close();
document.querySelector('#auth-toggle').onclick = () => {
  register = !register;
  document.querySelector('#name-label').hidden = !register;
  document.querySelector('[name=name]').required = register;
  document.querySelector('[name=password]').autocomplete = register ? 'new-password' : 'current-password';
  document.querySelector('#auth-title').textContent = register ? 'ابدأ رحلتك معنا' : 'مرحبًا بعودتك';
  document.querySelector('#auth-submit').textContent = register ? 'إنشاء حساب' : 'تسجيل الدخول';
  document.querySelector('#auth-toggle').textContent = register ? 'لديك حساب؟ سجّل الدخول' : 'ليس لديك حساب؟ أنشئ حسابًا';
  document.querySelector('#auth-error').textContent = '';
};
document.querySelector('#auth-form').onsubmit = async event => {
  event.preventDefault(); const button = document.querySelector('#auth-submit'); button.disabled = true;
  try { await api(register ? '/api/register' : '/api/login', Object.fromEntries(new FormData(event.target))); await refreshUser(); document.querySelector('#auth').close(); event.target.reset(); render(); notify('أهلًا بك في عون وسند'); }
  catch(e) { document.querySelector('#auth-error').textContent = e.message; }
  finally { button.disabled = false; }
};
window.addEventListener('hashchange', render);
async function boot() {
  try { [catalog] = await Promise.all([api('/api/catalog'), refreshUser()]); render(); }
  catch(e) { view.innerHTML = '<div class="empty"><h2>تعذر تحميل التطبيق</h2><p>تحقق من اتصال الخادم ثم أعد تحميل الصفحة.</p><button id="retry" class="primary">إعادة المحاولة</button></div>'; document.querySelector('#retry').onclick = boot; }
}
boot();
