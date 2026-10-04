const { chromium } = require('playwright');
const fs = require('node:fs');
(async () => {
  fs.mkdirSync('preview', { recursive: true });
  const browser = await chromium.launch({ executablePath: '/usr/bin/google-chrome', headless: true, args: ['--no-sandbox', '--disable-dev-shm-usage', '--enable-unsafe-swiftshader'] });
  for (const screen of ['splash', 'welcome', 'signup', 'login', 'home', 'courses', 'profile', 'admin', 'settings', 'materials']) {
    const page = await browser.newPage({ viewport: { width: 393, height: 852 }, deviceScaleFactor: 2 });
    const errors = [];
    page.on('pageerror', e => errors.push(e.message));
    await page.goto(`http://127.0.0.1:8765/?screen=${screen}`, { waitUntil: 'networkidle' });
    await page.waitForSelector('flutter-view', { timeout: 60000 });
    await page.waitForTimeout(2500);
    await page.screenshot({ path: `preview/${screen}.png` });
    if (errors.length) throw new Error(`${screen}: ${errors.join('; ')}`);
    await page.close();
  }
  await browser.close();
})();
