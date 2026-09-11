// ============================================================
// nlpProcessor.js (frontend) - thin client to the server
// Same public API as before, but now talks to Express
// ============================================================

const API_BASE = '/api/nlp';

function genSessionId() {
  return 'session_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
}

let sessionId = (typeof localStorage !== 'undefined' && localStorage.getItem('nlp_session_id')) || genSessionId();
if (typeof localStorage !== 'undefined') localStorage.setItem('nlp_session_id', sessionId);

let currentLanguage = 'en';

export async function init() {
  try {
    const res = await fetch(`${API_BASE}/health`);
    if (!res.ok) throw new Error(`Server returned ${res.status}`);
    return true;
  } catch (err) {
    console.error('❌ NLP server not reachable:', err.message);
    return false;
  }
}

export async function chat(msg, file) {
  const res = await fetch(`${API_BASE}/process`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Session-ID': sessionId
    },
    body: JSON.stringify({
      text: msg,
      sessionId,
      language: currentLanguage,
      file: file ? { name: file.name, size: file.size } : null
    })
  });

  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.message || err.error || `HTTP ${res.status}`);
  }

  const body = await res.json();
  return body.data;
}

export async function processMessage(msg, file) {
  return chat(msg, file);
}

export async function getAvailableServices() {
  const res = await fetch(`${API_BASE}/services`);
  const body = await res.json();
  return body.data || [];
}

export function resetService(serviceId) {
  return fetch(`${API_BASE}/reset/${serviceId}`, { method: 'POST' }).then(r => r.json());
}

export function setLanguage(lang) {
  currentLanguage = lang === 'am' ? 'am' : 'en';
}

export function getLanguage() {
  return currentLanguage;
}

export function isServiceComplete() { return false; }
export function markServiceComplete() {}

export const nlpProcessor = {
  chat,
  processMessage,
  init,
  getAvailableServices,
  resetService,
  isServiceComplete,
  markServiceComplete,
  setLanguage,
  getLanguage
};