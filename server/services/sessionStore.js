// server/services/sessionStore.js
// Persistent session storage backed by Supabase.

import { getSupabaseClient } from './serviceConfigDB.js';

function getDb() {
  return getSupabaseClient();
}

const cache = new Map();               // sessionId -> { state, awaiting }
const writeTimers = new Map();         // sessionId -> timeout
const WRITE_DEBOUNCE_MS = 400;

export async function loadSession(sessionId) {
  if (!sessionId) return null;
  if (cache.has(sessionId)) return cache.get(sessionId);
  try {
    const db = await getDb();
    const { data, error } = await db
      .from('nlp_sessions')
      .select('state, awaiting')
      .eq('session_id', sessionId)
      .maybeSingle();

    if (error) { console.warn('⚠️ loadSession error:', error.message); return null; }
    if (!data) return null;

    const entry = { state: data.state || {}, awaiting: data.awaiting || null };
    cache.set(sessionId, entry);
    return entry;
  } catch (err) {
    console.warn('⚠️ loadSession exception:', err.message);
    return null;
  }
}

export function saveSession(sessionId, entry, { immediate = false } = {}) {
  if (!sessionId || !entry) return;
  cache.set(sessionId, entry);
  if (writeTimers.has(sessionId)) clearTimeout(writeTimers.get(sessionId));

  const doWrite = async () => {
    writeTimers.delete(sessionId);
    try {
      const db = await getDb();
      const { error } = await db
        .from('nlp_sessions')
        .upsert({
          session_id: sessionId,
          state: entry.state || {},
          awaiting: entry.awaiting || null,
          updated_at: new Date().toISOString()
        }, { onConflict: 'session_id' });
      if (error) console.warn('⚠️ saveSession error:', error.message);
    } catch (err) {
      console.warn('⚠️ saveSession exception:', err.message);
    }
  };

  if (immediate) return doWrite();
  const t = setTimeout(doWrite, WRITE_DEBOUNCE_MS);
  writeTimers.set(sessionId, t);
}

export async function deleteSession(sessionId) {
  if (!sessionId) return;
  cache.delete(sessionId);
  if (writeTimers.has(sessionId)) {
    clearTimeout(writeTimers.get(sessionId));
    writeTimers.delete(sessionId);
  }
  try {
    const db = await getDb();
    const { error } = await db.from('nlp_sessions').delete().eq('session_id', sessionId);
    if (error) console.warn('⚠️ deleteSession error:', error.message);
  } catch (err) {
    console.warn('⚠️ deleteSession exception:', err.message);
  }
}

export async function flushAll() {
  const pending = [...writeTimers.keys()];
  for (const sid of pending) {
    clearTimeout(writeTimers.get(sid));
    writeTimers.delete(sid);
    const entry = cache.get(sid);
    if (entry) await saveSession(sid, entry, { immediate: true });
  }
}