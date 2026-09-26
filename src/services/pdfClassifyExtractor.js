// src/services/pdfClassifyExtractor.js
// PDF text → classify → extract fields → send to backend
// Sends the extracted text as a plain `message` string via chat().
// No `extracted`, no `mode:'document'`. Same pipeline as typed input.

import { chat } from './nlpProcessor.js';

const TAG = '[pdfClassifyExtractor]';
const log   = (...a) => console.log(TAG, ...a);
const warn  = (...a) => console.warn(TAG, ...a);
const error = (...a) => console.error(TAG, ...a);

// ============================================================
// TEMP LOCAL DB — replaced later by /api/nlp/services fetch
// Shape: { [serviceId]: { [stepNumber]: { fields: [...] } } }
// ============================================================
const TEMP_LOCAL_DB = {
  iftms: {
    1: {
      fields: [
        { name: 'businessLicenseNumber',
          regex: '^[0-9]{6,10}$',
          expectedFrom: { en: 'Business License Certificate', am: 'የንግድ ፈቃድ ማረጋገጫ' } },
        { name: 'operatorName',
          regex: '^[A-Za-z\\u1200-\\u137F\\s.&]{3,60}$',
          expectedFrom: { en: 'Business License Certificate', am: 'የንግድ ፈቃድ ማረጋገጫ' } },
        { name: 'phoneNumber',
          regex: '(0?[79][0-9]{8}|\\+251[79][0-9]{8})',
          expectedFrom: { en: 'Business License Certificate', am: 'የንግድ ፈቃድ ማረጋገጫ' } },
      ],
    },
    2: {
      fields: [
        { name: 'plateNumber',
          regex: '[A-Z]{2,3}-?[0-9]{3,4}',
          expectedFrom: { en: 'Vehicle Registration Document (Libre)', am: 'የተሽከርካሪ ምዝገባ ሰነድ (ሊብሬ)' } },
        { name: 'vinNumber',
          regex: '[A-HJ-NPR-Z0-9]{10,18}',
          expectedFrom: { en: 'Vehicle Registration Document (Libre)', am: 'የተሽከርካሪ ምዝገባ ሰነድ (ሊብሬ)' } },
        { name: 'motorNumber',
          regex: '1SG400[-\\s]?[0-9A-Z]{7,9}',
          expectedFrom: { en: 'Vehicle Registration Document (Libre)', am: 'የተሽከርካሪ ምዝገባ ሰነድ (ሊብሬ)' } },
        { name: 'chassisNumber',
          regex: '[A-HJ-NPR-Z0-9]{10,25}',
          expectedFrom: { en: 'Vehicle Registration Document (Libre)', am: 'የተሽከርካሪ ምዝገባ ሰነድ (ሊብሬ)' } },
      ],
    },
    3: {
      fields: [
        { name: 'driverName',
          regex: '^[A-Za-z\\u1200-\\u137F\\s.]{3,60}$',
          expectedFrom: { en: "Driver's License", am: 'የመንጃ ፈቃድ' } },
        { name: 'driverLicense',
          regex: '[A-Z]{0,3}[0-9]{5,10}',
          expectedFrom: { en: "Driver's License", am: 'የመንጃ ፈቃድ' } },
      ],
    },
  },
  documentAnalysis: {
    2: {
      fields: [
        { name: 'analysisType',
          regex: '(summar|extract|keyword|sentiment|ማጠቃለል|ቁልፍ|ስሜት)',
          expectedFrom: { en: 'Any readable document', am: 'ማንኛውም የሚነበብ ሰነድ' } },
      ],
    },
  },
  videoGeneration: {
    1: {
      fields: [
        { name: 'videoType',
          regex: '(slideshow|clip|advert|ስላይድሾው|ቪዲዮ|ማስታወቂያ)',
          expectedFrom: { en: 'Any readable document', am: 'ማንኛውም የሚነበብ ሰነድ' } },
      ],
    },
  },
};

// ============================================================
// CLASSIFIERS (independent)
// ============================================================
const CLASSIFIERS = [
  { type: 'Vehicle Registration Document', typeClass: 'type-libre',
    category: 'transportation', confidence: 0.9,
    rx: /(libre|plate\s*number|chassis\s*number|motor\s*number|vin|የሰሌዳ\s*ቁጥር|የሻንሺ\s*ቁጥር)/i },
  { type: 'Insurance Policy Document', typeClass: 'type-insurance',
    category: 'insurance', confidence: 0.9,
    rx: /(insurance|policy\s*number|premium|ፖሊሲ|የመድን|አረቦን)/i },
  { type: 'Academic Paper', typeClass: 'type-research',
    category: 'academic', confidence: 0.85,
    rx: /(abstract|introduction|methodology|results|conclusion|references|bibliography)/i },
  { type: 'Legal Document', typeClass: 'type-legal',
    category: 'legal', confidence: 0.8,
    rx: /(agreement|contract|clause|party|whereas|warranty|jurisdiction)/i },
  { type: 'Government Document', typeClass: 'type-government',
    category: 'government', confidence: 0.85,
    rx: /(license|permit|national\s*id|fayda|government|identification|ብሔራዊ|መታወቂያ|ፈቃድ|ኢትዮጵያ)/i },
  { type: 'Financial Document', typeClass: 'type-financial',
    category: 'financial', confidence: 0.7,
    rx: /(invoice|receipt|payment|balance|statement|total|amount|due)/i },
];

// ============================================================
// FIELD PATTERNS (extraction helpers — independent)
// ============================================================
const FIELD_PATTERNS = {
  tin:          /(?:TIN|ቲን)[\s:]*([0-9]{10})/i,
  phone:        /((?:\+251|0)[79][0-9]{8})/,
  businessLic:  /(?:license|ፈቃድ)[^\d]{0,20}([0-9]{6,10})/i,
  plate:        /([A-Z]{2,3}-?[0-9]{3,4})/,
  vin:          /([A-HJ-NPR-Z0-9]{17})/,
  motorNumber:  /(1SG400[-\s]?[0-9A-Z]{7,9})/,
  policyNumber: /(?:policy|ፖሊሲ)[^\d]{0,20}([A-Z0-9-]{8,20})/i,
  amount:       /((?:ETB|ብር)?\s?[0-9][0-9,]*\.?[0-9]{0,2})/,
};

// ============================================================
// HELPERS
// ============================================================
function detectLanguage(text) {
  const hasEthiopic = /[ሀ-ፕ]/.test(text);
  const hasLatin    = /[a-zA-Z]/.test(text);
  if (hasEthiopic && hasLatin) return 'amh+eng';
  if (hasEthiopic) return 'amh';
  if (hasLatin)    return 'eng';
  return 'unknown';
}

function getServiceId() {
  try {
    return sessionStorage.getItem('intnt') ||
           sessionStorage.getItem('currentService') ||
           'iftms';
  } catch { return 'iftms'; }
}

function getCurrentStep() {
  try {
    const n = parseInt(sessionStorage.getItem('currentStep') || '1', 10);
    return Number.isFinite(n) && n > 0 ? n : 1;
  } catch { return 1; }
}

// ============================================================
// CLASSIFICATION
// ============================================================
export function classifyDocument(text) {
  log('▶ classifyDocument()');
  const language = detectLanguage(text);

  for (const c of CLASSIFIERS) {
    if (c.rx.test(text)) {
      log(`  🎯 → ${c.type}`);
      return {
        documentType: c.type,
        typeClass:    c.typeClass,
        category:     c.category,
        confidence:   c.confidence,
        language,
      };
    }
  }
  log('  ↷ no classifier matched — General Document');
  return {
    documentType: 'General Document',
    typeClass:    'type-other',
    category:     'other',
    confidence:   0.3,
    language,
  };
}

// ============================================================
// CURRENT-STEP EXPECTED-VALUE CHECK
// ============================================================
export function checkCurrentStep(text, serviceId, step) {
  log(`▶ checkCurrentStep(${serviceId}, step ${step})`);
  const svc = TEMP_LOCAL_DB[serviceId];
  if (!svc) {
    log('  ↷ unknown service — no fields');
    return { expectedField: null, expectedFrom: null, matched: {}, fieldFound: false };
  }
  const stepCfg = svc[step];
  if (!stepCfg || !Array.isArray(stepCfg.fields) || stepCfg.fields.length === 0) {
    log('  ↷ no fields for this step');
    return { expectedField: null, expectedFrom: null, matched: {}, fieldFound: false };
  }

  const matched = {};
  for (const f of stepCfg.fields) {
    if (!f.regex) continue;
    let rx;
    try { rx = new RegExp(f.regex, 'i'); } catch { continue; }
    const hit = text.match(rx);
    if (hit) {
      matched[f.name] = hit[0];
      log(`  ✅ ${f.name} = ${JSON.stringify(hit[0])}`);
    } else {
      log(`  ↷ ${f.name} not found`);
    }
  }

  const expectedField = stepCfg.fields[0]?.name || null;
  const expectedFrom  = stepCfg.fields[0]?.expectedFrom || null;
  const fieldFound    = Object.keys(matched).length > 0;

  return { expectedField, expectedFrom, matched, fieldFound };
}

// ============================================================
// GENERIC FIELD EXTRACTION
// ============================================================
export function extractFields(text) {
  log('▶ extractFields()');
  const out = {};
  for (const [name, rx] of Object.entries(FIELD_PATTERNS)) {
    const m = text.match(rx);
    if (m && m[1]) {
      out[name] = m[1].trim();
      log(`  ✅ ${name} = ${JSON.stringify(out[name])}`);
    }
  }
  return out;
}

// ============================================================
// MAIN
// ============================================================
export async function classifyAndExtract(text, meta = {}) {
  log('╔══════════════════════════════════════════╗');
  log('║  pdfClassifyExtractor.classifyAndExtract ║');
  log('╚══════════════════════════════════════════╝');
  log('  fileName:', meta.fileName, '| text length:', text?.length || 0);

  if (!text || !text.trim()) {
    warn('  ⚠️ empty text — nothing to send');
    return {
      fields: {}, raw: null, source: 'pdf',
      documentType: 'General Document', typeClass: 'type-other',
      category: 'other', language: 'unknown', confidence: 0,
      text: '', ocrConfidence: 0, nlpResponse: null,
    };
  }

  // 1. classification
  const cls = classifyDocument(text);

  // 2. current service / step from sessionStorage
  const serviceId = getServiceId();
  const step      = getCurrentStep();
  log(`  serviceId=${serviceId} | step=${step}`);

  // 3. current step's expected-value check
  const chk = checkCurrentStep(text, serviceId, step);

  // 4. generic field extraction
  const genericFields = extractFields(text);

  // 5. merge — step-matched fields win
  const fields = { ...genericFields, ...chk.matched };

  // 6. metadata (kept on return for caller inspection — NOT sent)
  const payload = {
    fields,
    raw: null,
    source: 'pdf',
    documentType: cls.documentType,
    typeClass:    cls.typeClass,
    category:     cls.category,
    language:     cls.language,
    confidence:   cls.confidence,
    text,
    ocrConfidence: 0,
    extractionMeta: {
      source:        'pdf',
      serviceId,
      currentStep:   step,
      expectedField: chk.expectedField,
      expectedFrom:  chk.expectedFrom,
      fieldFound:    chk.fieldFound,
      documentType:  cls.documentType,
      language:      cls.language,
    },
  };

  // 7. Send the extracted TEXT as a plain `message` string.
  //    Same pipeline as typed input — no `extracted`, no
  //    `mode:'document'`. The server treats it like a user message.
  const message = text.trim();
  log('  ▶ chat(message, null, null) …');
  log('    message preview:', message.slice(0, 200) + (message.length > 200 ? '…' : ''));

  let nlpResponse = null;
  try {
    nlpResponse = await chat(message, null, null);
    log('  ✅ chat() returned:', nlpResponse);
  } catch (e) {
    warn('  ⚠️ chat() threw:', e.message);
  }

  return { ...payload, nlpResponse };
}