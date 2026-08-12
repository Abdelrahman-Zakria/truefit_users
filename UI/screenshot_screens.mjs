import { firefox as chromium } from "playwright";
import { writeFileSync } from "fs";
import { mkdirSync } from "fs";

const OUT = "/workspaces/default/screenshots";
mkdirSync(OUT, { recursive: true });

const VIEWPORT = { width: 390, height: 844 }; // iPhone 14 Pro

const browser = await chromium.launch();
const ctx = await browser.newContext({ viewport: VIEWPORT, deviceScaleFactor: 2 });
const page = await ctx.newPage();

async function shot(name) {
  await page.waitForTimeout(600);
  await page.screenshot({ path: `${OUT}/${name}.png`, fullPage: false });
  console.log(`✓ ${name}`);
}

async function waitText(text, timeout = 8000) {
  await page.waitForSelector(`text=${text}`, { timeout });
}

// ── 1. Splash ─────────────────────────────────────────────────────────────────
await page.goto("http://localhost:5173");
await waitText("TRUE FIT");
await shot("01_splash");

// Wait for splash to finish (3s)
await page.waitForTimeout(3200);

// ── 2. Login ──────────────────────────────────────────────────────────────────
await waitText("Sign in");
await shot("02_login");

// ── 3. Login - Arabic ─────────────────────────────────────────────────────────
const arBtn = page.locator("button", { hasText: "AR" }).first();
await arBtn.click();
await page.waitForTimeout(400);
await shot("03_login_arabic");

// Switch back to English
const enBtn = page.locator("button", { hasText: "EN" }).first();
await enBtn.click();
await page.waitForTimeout(300);

// ── 4. Register ───────────────────────────────────────────────────────────────
await page.click("text=Create Account");
await waitText("Join True Fit");
await shot("04_register");

// ── 5. Pending ────────────────────────────────────────────────────────────────
await page.fill("input[placeholder*='Full Name'], input[type='text']", "Ahmed Hassan");
const emailInput = page.locator("input[type='email']").first();
await emailInput.fill("ahmed@example.com");
const pwds = page.locator("input[type='password']");
await pwds.nth(0).fill("password123");
await pwds.nth(1).fill("password123");
// Check terms checkbox if present
const checkbox = page.locator("input[type='checkbox']").first();
if (await checkbox.count() > 0) await checkbox.check();
await page.click("button:has-text('Create Account')");
await waitText("Application Submitted");
await shot("05_pending");

// ── 6. Member Home (simulate approval) ───────────────────────────────────────
await page.click("text=Simulate Admin Approval");
await waitText("Welcome back");
await shot("06_member_home");

// Scroll down to see banners + upcoming
await page.evaluate(() => document.querySelector("main")?.scrollTo(0, 300));
await page.waitForTimeout(400);
await shot("07_member_home_scroll");

// Scroll more - activity rings + upcoming sessions
await page.evaluate(() => document.querySelector("main")?.scrollTo(0, 700));
await page.waitForTimeout(400);
await shot("08_member_activity_upcoming");

// Scroll more - quick actions
await page.evaluate(() => document.querySelector("main")?.scrollTo(0, 1100));
await page.waitForTimeout(400);
await shot("09_member_quick_actions");

// ── 7. Check-in barcode ──────────────────────────────────────────────────────
await page.evaluate(() => document.querySelector("main")?.scrollTo(0, 0));
await page.waitForTimeout(300);
await page.click("button:has-text('Show Barcode')");
await page.waitForTimeout(500);
await shot("10_member_barcode");

// ── 8. Subscription (Member) ─────────────────────────────────────────────────
await page.click("a[href='/subscription']");
await page.waitForTimeout(800);
await shot("11_member_subscription");

// ── 9. Renew modal ───────────────────────────────────────────────────────────
const renewBtn = page.locator("button:has-text('Renew'), button:has-text('Renew Subscription')").first();
if (await renewBtn.count() > 0) {
  await renewBtn.click();
  await page.waitForTimeout(600);
  await shot("12_renew_modal");
  await page.keyboard.press("Escape");
}

// ── 10. Booking ───────────────────────────────────────────────────────────────
await page.click("a[href='/booking']");
await page.waitForTimeout(800);
await shot("13_booking");

// ── 11. Diet ─────────────────────────────────────────────────────────────────
await page.click("a[href='/diet']");
await page.waitForTimeout(800);
await shot("14_diet");

// ── 12. Progress ─────────────────────────────────────────────────────────────
await page.click("a[href='/progress']");
await page.waitForTimeout(800);
await shot("15_progress");

// ── 13. Conversations ────────────────────────────────────────────────────────
await page.click("a[href='/chat']");
await page.waitForTimeout(800);
await shot("16_conversations");

// ── 14. Chat (open first coach) ──────────────────────────────────────────────
const firstConvo = page.locator(".rounded-xl").first();
if (await firstConvo.count() > 0) {
  await firstConvo.click();
  await page.waitForTimeout(700);
  await shot("17_chat");
}

// ── 15. Guest Home ───────────────────────────────────────────────────────────
// Logout first
await page.click("a[href='/']");
await page.waitForTimeout(300);
const logoutBtn = page.locator("button").filter({ has: page.locator("svg") }).last();
// Navigate to login and go guest
await page.goto("http://localhost:5173");
await page.waitForTimeout(3200); // splash
await waitText("Sign in");
await page.click("text=Continue as Guest");
await page.waitForTimeout(500);
await waitText("Welcome to");
await shot("18_guest_home");

// Scroll to banners + packages
await page.evaluate(() => document.querySelector("main")?.scrollTo(0, 500));
await page.waitForTimeout(400);
await shot("19_guest_home_banners");

// Scroll to outdoor sessions
await page.evaluate(() => document.querySelector("main")?.scrollTo(0, 1200));
await page.waitForTimeout(400);
await shot("20_guest_outdoor_sessions");

// ── 16. Session detail modal ─────────────────────────────────────────────────
const sessionBtns = page.locator("button:has-text('Morning Beach')");
if (await sessionBtns.count() > 0) {
  await sessionBtns.first().click();
  await page.waitForTimeout(500);
  await shot("21_session_detail");
  await page.keyboard.press("Escape");
  await page.waitForTimeout(300);
}

// ── 17. Package detail modal ─────────────────────────────────────────────────
await page.evaluate(() => document.querySelector("main")?.scrollTo(0, 700));
await page.waitForTimeout(400);
const pkgBtn = page.locator("button:has-text('Standard')").first();
if (await pkgBtn.count() > 0) {
  await pkgBtn.click();
  await page.waitForTimeout(500);
  await shot("22_package_detail");
  await page.keyboard.press("Escape");
  await page.waitForTimeout(300);
}

// ── 18. Guest locked tab ─────────────────────────────────────────────────────
await page.click("a[href='/booking']");
await page.waitForTimeout(600);
await shot("23_guest_locked_booking");

// ── 19. Guest Arabic home ─────────────────────────────────────────────────────
await page.click("a[href='/']");
await page.waitForTimeout(400);
const headerArBtn = page.locator("header button:has-text('AR')").first();
if (await headerArBtn.count() > 0) {
  await headerArBtn.click();
  await page.waitForTimeout(500);
  await shot("24_guest_home_arabic");
}

await browser.close();
console.log(`\n✅ All screenshots saved to ${OUT}`);
