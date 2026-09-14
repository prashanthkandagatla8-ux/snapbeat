import { DatabaseSync } from "node:sqlite";
import path from "node:path";
import fs from "node:fs";

let dbInstance = null;

export function getDb() {
  if (dbInstance) return dbInstance;

  const dataDir = path.resolve(process.cwd(), "data");
  if (!fs.existsSync(dataDir)) {
    fs.mkdirSync(dataDir, { recursive: true });
  }

  const dbPath = path.join(dataDir, "snapbeat.db");
  const db = new DatabaseSync(dbPath);

  // Enable WAL mode for high concurrency
  db.exec("PRAGMA journal_mode = WAL;");
  db.exec("PRAGMA synchronous = NORMAL;");

  // Accounts table
  db.exec(`
    CREATE TABLE IF NOT EXISTS accounts (
      id TEXT PRIMARY KEY,
      email TEXT UNIQUE,
      name TEXT,
      picture TEXT,
      is_guest INTEGER DEFAULT 0,
      is_pro INTEGER DEFAULT 0,
      plan_id TEXT,
      expires_at TEXT,
      payment_id TEXT,
      pro_token TEXT,
      device_id TEXT,
      created_at TEXT,
      updated_at TEXT
    );
  `);

  // Activations table (Tracks verified payments & passes)
  db.exec(`
    CREATE TABLE IF NOT EXISTS activations (
      id TEXT PRIMARY KEY,
      account_id TEXT,
      email TEXT,
      order_id TEXT UNIQUE,
      payment_id TEXT,
      gateway TEXT,
      plan_id TEXT,
      amount REAL,
      currency TEXT,
      status TEXT,
      expires_at TEXT,
      pro_token TEXT,
      created_at TEXT,
      FOREIGN KEY(account_id) REFERENCES accounts(id)
    );
  `);

  // Device guest links table
  db.exec(`
    CREATE TABLE IF NOT EXISTS device_links (
      device_id TEXT PRIMARY KEY,
      account_id TEXT,
      created_at TEXT,
      last_seen TEXT
    );
  `);

  dbInstance = db;
  return dbInstance;
}

export function getAccountByEmail(email) {
  if (!email) return null;
  const db = getDb();
  const cleanEmail = email.trim().toLowerCase();
  const stmt = db.prepare("SELECT * FROM accounts WHERE LOWER(email) = ?");
  const row = stmt.get(cleanEmail);
  return row ? formatAccountRow(row) : null;
}

export function getAccountById(id) {
  if (!id) return null;
  const db = getDb();
  const stmt = db.prepare("SELECT * FROM accounts WHERE id = ?");
  const row = stmt.get(id);
  return row ? formatAccountRow(row) : null;
}

export function getAccountByDeviceId(deviceId) {
  if (!deviceId) return null;
  const db = getDb();
  const linkStmt = db.prepare("SELECT account_id FROM device_links WHERE device_id = ?");
  const link = linkStmt.get(deviceId);
  if (!link) return null;
  return getAccountById(link.account_id);
}

export function upsertAccount({
  id,
  email,
  name = "",
  picture = "",
  isGuest = false,
  isPro = false,
  planId = null,
  expiresAt = null,
  paymentId = null,
  proToken = null,
  deviceId = null,
}) {
  const db = getDb();
  const cleanEmail = email ? email.trim().toLowerCase() : null;
  const now = new Date().toISOString();

  let existing = null;
  if (cleanEmail) {
    existing = getAccountByEmail(cleanEmail);
  }
  if (!existing && id) {
    existing = getAccountById(id);
  }

  if (existing) {
    const accountId = existing.id;
    const stmt = db.prepare(`
      UPDATE accounts
      SET name = COALESCE(?, name),
          picture = COALESCE(?, picture),
          is_pro = ?,
          plan_id = ?,
          expires_at = ?,
          payment_id = ?,
          pro_token = ?,
          device_id = COALESCE(?, device_id),
          updated_at = ?
      WHERE id = ?
    `);
    stmt.run(
      name || existing.name,
      picture || existing.picture,
      isPro ? 1 : 0,
      planId || existing.plan_id,
      expiresAt || existing.expires_at,
      paymentId || existing.payment_id,
      proToken || existing.pro_token,
      deviceId || existing.device_id,
      now,
      accountId
    );

    if (deviceId) {
      const linkStmt = db.prepare(`
        INSERT INTO device_links (device_id, account_id, created_at, last_seen)
        VALUES (?, ?, ?, ?)
        ON CONFLICT(device_id) DO UPDATE SET last_seen = excluded.last_seen
      `);
      linkStmt.run(deviceId, accountId, now, now);
    }

    return getAccountById(accountId);
  } else {
    const accountId = id || (isGuest ? `guest_${Date.now()}` : `usr_${Date.now()}`);
    const finalEmail = cleanEmail || `${accountId}@guest.snapbeat.app`;

    const stmt = db.prepare(`
      INSERT INTO accounts (
        id, email, name, picture, is_guest, is_pro, plan_id, expires_at,
        payment_id, pro_token, device_id, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `);

    stmt.run(
      accountId,
      finalEmail,
      name || (isGuest ? "Guest Creator" : finalEmail.split("@")[0]),
      picture || null,
      isGuest ? 1 : 0,
      isPro ? 1 : 0,
      planId,
      expiresAt,
      paymentId,
      proToken,
      deviceId,
      now,
      now
    );

    if (deviceId) {
      const linkStmt = db.prepare(`
        INSERT INTO device_links (device_id, account_id, created_at, last_seen)
        VALUES (?, ?, ?, ?)
        ON CONFLICT(device_id) DO UPDATE SET last_seen = excluded.last_seen
      `);
      linkStmt.run(deviceId, accountId, now, now);
    }

    return getAccountById(accountId);
  }
}

export function recordActivation({
  accountId,
  email,
  orderId,
  paymentId,
  gateway = "cashfree",
  planId,
  amount,
  currency = "INR",
  status = "PAID",
  expiresAt,
  proToken,
}) {
  const db = getDb();
  const activationId = `act_${Date.now()}_${Math.random().toString(36).slice(2, 7)}`;
  const now = new Date().toISOString();

  const stmt = db.prepare(`
    INSERT INTO activations (
      id, account_id, email, order_id, payment_id, gateway,
      plan_id, amount, currency, status, expires_at, pro_token, created_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(order_id) DO UPDATE SET
      status = excluded.status,
      payment_id = excluded.payment_id,
      pro_token = excluded.pro_token,
      expires_at = excluded.expires_at
  `);

  stmt.run(
    activationId,
    accountId,
    email,
    orderId,
    paymentId,
    gateway,
    planId,
    amount,
    currency,
    status,
    expiresAt,
    proToken,
    now
  );

  return { id: activationId, orderId, status };
}

export function linkGuestToAccount(guestDeviceId, targetEmail, targetName = "") {
  if (!guestDeviceId || !targetEmail) return null;
  const db = getDb();
  const guestAccount = getAccountByDeviceId(guestDeviceId);
  if (!guestAccount) return null;

  const targetAccount = upsertAccount({
    email: targetEmail,
    name: targetName,
    isGuest: false,
    isPro: guestAccount.isPro,
    planId: guestAccount.planId,
    expiresAt: guestAccount.expiresAt,
    paymentId: guestAccount.paymentId,
    proToken: guestAccount.proToken,
    deviceId: guestDeviceId,
  });

  // Re-link activations
  const updateActStmt = db.prepare(`
    UPDATE activations
    SET account_id = ?, email = ?
    WHERE account_id = ?
  `);
  updateActStmt.run(targetAccount.id, targetAccount.email, guestAccount.id);

  return targetAccount;
}

function formatAccountRow(row) {
  const isPro = Boolean(row.is_pro && (!row.expires_at || new Date(row.expires_at) > new Date()));
  return {
    id: row.id,
    email: row.email,
    name: row.name,
    picture: row.picture,
    isGuest: Boolean(row.is_guest),
    isPro,
    planId: row.plan_id,
    expiresAt: row.expires_at,
    paymentId: row.payment_id,
    proToken: row.pro_token,
    deviceId: row.device_id,
    createdAt: row.created_at,
    updatedAt: row.updated_at,
  };
}
