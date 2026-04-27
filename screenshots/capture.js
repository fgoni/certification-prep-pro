// Captures the 5 App Store screenshots at 1320x2868 (iPhone 6.9").
// Run from the repo root:
//   NODE_PATH=$HOME/Sites/kanban/node_modules node screenshots/capture.js

const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const FRAMES = ['home', 'quiz', 'feedback', 'result', 'history'];
const OUT_DIR = path.resolve(__dirname, 'output');
const SOURCE = 'file://' + path.resolve(__dirname, 'render.html');

(async () => {
  fs.mkdirSync(OUT_DIR, { recursive: true });
  const browser = await chromium.launch();
  const ctx = await browser.newContext({
    viewport: { width: 1320, height: 2868 },
    deviceScaleFactor: 1,
  });
  const page = await ctx.newPage();

  for (let i = 0; i < FRAMES.length; i++) {
    const url = `${SOURCE}#${i}`;
    process.stdout.write(`[${i + 1}/${FRAMES.length}] ${FRAMES[i]} ... `);
    await page.goto(url, { waitUntil: 'networkidle' });
    // wait for fonts + the data-ready flag set by render()
    await page.waitForFunction(() => document.body?.dataset?.ready === 'true');
    await page.evaluate(() => document.fonts.ready);
    // small settle
    await page.waitForTimeout(200);
    const out = path.join(OUT_DIR, `${i + 1}-${FRAMES[i]}.png`);
    await page.screenshot({ path: out, fullPage: false, omitBackground: false });
    console.log(out);
  }

  await browser.close();
})();
