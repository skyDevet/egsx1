// ============================================================
// nlpProcessor.js (frontend)
// Sends explicit mode: "stage" | "answer" | "chat"
// ============================================================

const API_BASE = '/api/nlp';

function genSessionId() {
  return 'session_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
}

let sessionId =
  (typeof localStorage !== 'undefined' && localStorage.getItem('nlp_session_id')) ||
  genSessionId();
if (typeof localStorage !== 'undefined') localStorage.setItem('nlp_session_id', sessionId);

let currentLanguage = 'en';

// Alias → canonical service id (must match DEFAULT_SERVICES keys on server)
const SERVICE_ALIASES = {
  'iftms': 'iftms', 'iftms card': 'iftms', 'iftms service': 'iftms',
  'iftms - freight transport': 'iftms',
  'freight transport': 'iftms', 'freight': 'iftms',
  'fayda': 'iftms', 'national id': 'iftms',

  'document analysis': 'documentAnalysis', 'analyze document': 'documentAnalysis',
  'documentanalysis': 'documentAnalysis',

  'video generation': 'videoGeneration', 'generate video': 'videoGeneration',
  'videogeneration': 'videoGeneration', 'slideshow': 'videoGeneration'
};

function detectService(text) {
  if (!text) return null;
  const lower = text.toLowerCase().trim();
  if (SERVICE_ALIASES[lower]) return SERVICE_ALIASES[lower];
  for (const [alias, id] of Object.entries(SERVICE_ALIASES)) {
    if (lower === alias) return id;
  }
  for (const [alias, id] of Object.entries(SERVICE_ALIASES)) {
    if (lower.includes(alias)) return id;
  }
  return null;
}

function isBareServiceName(text, serviceId) {
  if (!text || !serviceId) return false;
  const lower = text.toLowerCase().trim();
  const aliases = Object.entries(SERVICE_ALIASES)
    .filter(([, id]) => id === serviceId)
    .map(([a]) => a);
  return aliases.some(a => lower === a || lower === `${a} service`);
}

function isEmptyInput(text) {
  if (text === null || text === undefined) return true;
  if (typeof text !== 'string') return false;
  const t = text.trim();
  return t.length === 0 ||
    t === 'User selected:' ||
    (t.startsWith('User selected: ') && t.replace('User selected: ', '').trim().length === 0);
}

function normalizeInput(text) {
  if (!text || typeof text !== 'string') return '';
  let n = text.trim();
  if (n.startsWith('User selected: ')) n = n.replace('User selected: ', '').trim();
  return n;
}

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

/**
 * chat(msg, file, serviceHint)
 *
 *  serviceHint — canonical service id from a suggestion card click.
 *                Presence ⇒ mode = "stage" (present current step, no validation)
 *
 *  bare service name in text ⇒ mode = "stage"
 *  otherwise ⇒ mode = "answer" (or "chat" if no service context)
 */
export async function chat(msg, file, serviceHint = null) {
  if (isEmptyInput(msg) && !file && !serviceHint) {
    console.log('⏭️ chat: empty, skipping');
    return null;
  }

  const normalizedMsg = normalizeInput(msg);
  const hintedService = serviceHint || null;
  const keywordService = !hintedService ? detectService(normalizedMsg) : null;
  const serviceId = hintedService || keywordService;

  // ---- Decide mode ----
  let mode = 'chat';
  if (file) {
    mode = 'answer';
  } else if (serviceId) {
    const isStage = !!hintedService || isBareServiceName(normalizedMsg, serviceId);
    mode = isStage ? 'stage' : 'answer';
  }

  const payload = {
    text: normalizedMsg,
    sessionId,
    language: currentLanguage,
    mode,
    serviceId: serviceId || null,
    file: file ? { name: file.name, size: file.size } : null
  };

  console.log(`📤 mode=${mode} service=${serviceId || '-'} text="${normalizedMsg}"`);

  const res = await fetch(`${API_BASE}/process`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Session-ID': sessionId
    },
    body: JSON.stringify(payload)
  });

  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.message || err.error || `HTTP ${res.status}`);
  }

  const body = await res.json();
  return body.data || body;
}

export async function processMessage(msg, file, serviceHint) {
  return chat(msg, file, serviceHint);
}

export async function getAvailableServices() {
  const res = await fetch(`${API_BASE}/services`);
  const body = await res.json();
  return body.data || [];
}

export function resetService(serviceId) {
  return fetch(`${API_BASE}/reset/${serviceId}`, { method: 'POST' }).then(r => r.json());
}

export function setLanguage(lang) { currentLanguage = lang === 'am' ? 'am' : 'en'; }
export function getLanguage() { return currentLanguage; }
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
  getLanguage,
  detectService,
  isEmptyInput,
  normalizeInput
};