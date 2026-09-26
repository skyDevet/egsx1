// src/services/docExtractor.js
// ============================================================
// Browser-only document extraction with FULL verbose logging.
// ONNX Runtime + Tesseract loaded from CDN at runtime.
//
// Behavior:
//   • PDF               → ./pdfAna.js → text → POST /chat
//   • Image + YOLO ok   → YOLO detect → per-crop OCR → fields
//   • Image + YOLO fail → ./fieldExtractor.extractWithTess() fallback
// ============================================================

// ============================================================
// LOG HELPERS
// ============================================================
const TAG = '[docExtractor]';
const log   = (...a) => console.log(TAG, ...a);
const warn  = (...a) => console.warn(TAG, ...a);
const error = (...a) => console.error(TAG, ...a);
const group = (label) => console.group(TAG, label);
const groupEnd = () => console.groupEnd();
const timer = (label) => {
  const t0 = performance.now();
  log(`⏱️  ${label} … start`);
  return () => {
    const ms = (performance.now() - t0).toFixed(1);
    log(`⏱️  ${label} … done in ${ms}ms`);
    return ms;
  };
};

// ONNX Runtime Web - UMD
const ORT_CDN  = 'https://cdn.jsdelivr.net/npm/onnxruntime-web@1.18.0/dist/ort.min.js';
const ORT_WASM = 'https://cdn.jsdelivr.net/npm/onnxruntime-web@1.18.0/dist/';

// Tesseract.js - used ONLY for the YOLO per-crop OCR path
const TESS_CDN    = 'https://cdn.jsdelivr.net/npm/tesseract.js@5.1.0/dist/tesseract.esm.min.js';
const TESS_WORKER = 'https://cdn.jsdelivr.net/npm/tesseract.js@5.1.0/dist/worker.min.js';
const TESS_CORE   = 'https://cdn.jsdelivr.net/npm/tesseract.js-core@5.1.0';

const MODEL_URL = '/models/yolov8n-fields.onnx';
const MODEL_INPUT_SIZE = 640;
const DETECT_CONF = 0.35;
const NMS_IOU = 0.45;

const FIELD_NAMES = [
  'vin','chassis','motor_number','plate_number','owner_name',
  'make','model','year','color',
];

const FIELD_MAP = {
  vin:          'vinNumber',
  chassis:      'chassisNumber',
  motor_number: 'motorNumber',
  plate_number: 'plateNumber',
  owner_name:   'operatorName',
  make:         'manufacturer',
  model:        'vehicleModel',
  year:         'manufactureYear',
  color:        'color',
};

const VALIDATORS = {
  vinNumber:       /[A-HJ-NPR-Z0-9]{10,18}/i,
  chassisNumber:   /[A-HJ-NPR-Z0-9*\-]{10,25}/i,
  motorNumber:     /\d{3,15}/,
  plateNumber:     /[A-Z]{2,3}-?\d{2,4}-?[A-Z]?\d{3,6}/i,
  manufactureYear: /(?:19|20)\d{2}/,
  color:           /[A-Za-z\u1200-\u137F]{3,20}/,
};

// ============================================================
// CACHED HANDLES
// ============================================================
let _ort = null;
let _session = null;
let _Tesseract = null;
let _ocr = null;
let _fieldExtractor = null;
let _fieldExtractorTried = false;

// ============================================================
// FIELD EXTRACTOR FALLBACK LOADER
// ============================================================
async function loadTessFallback() {
  const FTAG = '[docExtractor:fallback]';
  const flog  = (...a) => console.log(FTAG, ...a);
  const fwarn = (...a) => console.warn(FTAG, ...a);
  const ferr  = (...a) => console.error(FTAG, ...a);

  if (_fieldExtractor) {
    flog('↷ ./fieldExtractor.js already cached');
    return _fieldExtractor;
  }
  if (_fieldExtractorTried && !_fieldExtractor) {
    flog('↷ ./fieldExtractor.js previously failed — skipping retry');
    return null;
  }

  _fieldExtractorTried = true;
  const done = timer('loadFieldExtractor');
  try {
    flog('🔵 dynamic import("./fieldExtractor.js") …');
    const mod = await import('./fieldExtractor.js');
    done();

    flog('   module keys:', Object.keys(mod));

    if (!mod || typeof mod.extractWithTess !== 'function') {
      fwarn('⚠️ ./fieldExtractor.js loaded but extractWithTess missing');
      _fieldExtractor = null;
      return null;
    }
    _fieldExtractor = mod;
    flog('✅ ./fieldExtractor.js loaded — extractWithTess available');
    return _fieldExtractor;
  } catch (e) {
    done();
    ferr('❌ failed to load ./fieldExtractor.js');
    ferr('   message:', e.message);
    ferr('   name   :', e.name);
    ferr('   stack  :', e.stack);
    _fieldExtractor = null;
    return null;
  }
}

async function runTessFallback(file, reason) {
  warn(`⚠️⚠️⚠️  YOLO path failed (${reason}) — REDIRECTING to ./fieldExtractor.js fallback`);
  log('   → calling loadTessFallback()');

  const fx = await loadTessFallback();

  if (!fx || typeof fx.extractWithTess !== 'function') {
    error('❌ fieldExtractor fallback unavailable — no extractWithTess export');
    error('   module :', fx);
    error('   returning null');
    return null;
  }

  log('   → calling fieldExtractor.extractWithTess(file) …');
  try {
    const result = await fx.extractWithTess(file);
    log('✅ fieldExtractor fallback complete');
    log('   result.source   :', result?.source);
    log('   result.fields   :', result?.fields);
    log('   field count     :', result?.fields ? Object.keys(result.fields).length : 0);
    log('   documentType    :', result?.documentType);
    log('   language        :', result?.language);
    log('   confidence      :', result?.confidence);
    log('   nlpResponse?    :', !!result?.nlpResponse);
    return result;
  } catch (e) {
    error('❌ fieldExtractor fallback THREW');
    error('   message:', e.message);
    error('   name   :', e.name);
    error('   stack  :', e.stack);
    return null;
  }
}

// ============================================================
// PDF PATH — uses ./pdfAna.js
// ============================================================
async function runPdfPath(file) {
  log('📄 PDF detected — routing through ./pdfAna.js');
  log('   name :', file.name);
  log('   size :', file.size, 'bytes');

  try {
    const { analyzePDF } = await import('./pdfAna.js');
    const done = timer('pdfAna.analyzePDF');
    const result = await analyzePDF(file);
    done();

    log('✅ PDF path complete');
    log('   text length :', result?.text?.length || 0);
    log('   response?   :', !!result?.response);

    return {
      fields: null,
      raw: null,
      source: 'pdf',
      text: result?.text || '',
      documentType: null,
      nlpResponse: result?.response || null,
    };
  } catch (e) {
    error('❌ PDF path threw:', e.message);
    return null;
  }
}

// ============================================================
// ORT LOADER
// ============================================================
async function loadOrt() {
  if (_ort) return _ort;
  log('🔵 loading ONNX Runtime from CDN:', ORT_CDN);

  await new Promise((res, rej) => {
    const s = document.createElement('script');
    s.src = ORT_CDN;
    s.onload = res;
    s.onerror = () => rej(new Error('ORT script load failed'));
    document.head.appendChild(s);
  });

  const g = window.ort;
  if (!g) throw new Error('window.ort undefined — UMD did not attach');

  _ort = g;
  _ort.env.wasm.numThreads = 1;
  _ort.env.wasm.simd = true;
  _ort.env.wasm.wasmPaths = ORT_WASM;

  log('  ✅ ort loaded. version:', _ort.env?.versions?.web);
  return _ort;
}

// ============================================================
// MODEL LOADER
// ============================================================
async function getSession() {
  group('MODEL LOADER');

  if (_session) {
    log('✅ model already cached in memory');
    groupEnd();
    return _session;
  }

  let ort;
  try {
    ort = await loadOrt();
  } catch (e) {
    error('❌ loadOrt failed:', e.message);
    groupEnd();
    return null;
  }

  log('🔵 loading ONNX model from:', MODEL_URL);

  log('step 1: HEAD check on', MODEL_URL);
  try {
    const head = await fetch(MODEL_URL, { method: 'HEAD' });
    log('  → HEAD status :', head.status, head.statusText);
    log('  → Content-Length:', head.headers.get('content-length'), 'bytes');
    log('  → Content-Type  :', head.headers.get('content-type'));
    if (!head.ok) {
      error('❌ model file NOT reachable — status', head.status);
      error('❌ expected at:', MODEL_URL);
      groupEnd();
      return null;
    }
    log('  ✅ model file reachable');
  } catch (e) {
    error('❌ HEAD request threw:', e.message);
    groupEnd();
    return null;
  }

  log('step 2: ort.InferenceSession.create()');
  const done = timer('InferenceSession.create');
  try {
    _session = await ort.InferenceSession.create(MODEL_URL, {
      executionProviders: ['wasm'],
    });
    done();
    log('  ✅ model loaded');
    log('  ✅ input names :', _session.inputNames);
    log('  ✅ output names:', _session.outputNames);
    groupEnd();
    return _session;
  } catch (e) {
    done();
    error('❌ ort.InferenceSession.create failed');
    error('   message :', e.message);
    error('   name    :', e.name);
    groupEnd();
    return null;
  }
}

// ============================================================
// TESSERACT LOADER (YOLO-side per-crop OCR only)
// ============================================================
async function loadTesseract() {
  if (_Tesseract) return _Tesseract;
  log('🔵 loading Tesseract from CDN:', TESS_CDN);
  const done = timer('import tesseract');
  try {
    const mod = await import(/* @vite-ignore */ TESS_CDN);
    done();
    _Tesseract = mod.default || mod;
    log('  ✅ tesseract module loaded');
    return _Tesseract;
  } catch (e) {
    done();
    error('❌ failed to import Tesseract from CDN:', e.message);
    throw e;
  }
}

async function getOcr() {
  group('TESSERACT LOADER');

  if (_ocr) {
    log('✅ tesseract worker already cached in memory');
    groupEnd();
    return _ocr;
  }

  const Tesseract = await loadTesseract();

  log('🔵 creating Tesseract worker (langs: eng + amh)');

  const done = timer('Tesseract.createWorker');
  try {
    _ocr = await Tesseract.createWorker(['eng', 'amh'], 1, {
      workerPath: TESS_WORKER,
      corePath:   TESS_CORE,
      langPath:   'https://tessdata.projectnaptha.com/4.0.0',
      logger: (m) => {
        if (!m || !m.status) return;
        const pct = (typeof m.progress === 'number')
          ? `${(m.progress * 100).toFixed(0)}%`
          : '';
        log(`   ⏳ tesseract: ${m.status} ${pct}`.trim());
      },
    });
    done();
    log('  ✅ tesseract worker created');

    await _ocr.setParameters({
      tessedit_pageseg_mode: '7',
      preserve_interword_spaces: '1',
    });
    log('  ✅ parameters set');

    groupEnd();
    return _ocr;
  } catch (e) {
    done();
    error('❌ Tesseract.createWorker failed:', e.message);
    groupEnd();
    return null;
  }
}

// ============================================================
// WARMUP
// ============================================================
export async function warmupDocExtractor() {
  log('╔═══════════════════════════════════════════════════════╗');
  log('║  WARMUP — preloading model + tesseract               ║');
  log('╚═══════════════════════════════════════════════════════╝');

  const total = timer('warmup total');

  log('▶ warmup: loading YOLOv8 model...');
  const model = await getSession();
  log('  warmup model    :', model ? '✅ OK' : '❌ FAILED');

  if (!model) {
    warn('⚠️ YOLOv8 model missing — warming ./fieldExtractor.js fallback instead');
    const fx = await loadTessFallback();
    const ok = !!fx;
    total();
    log('╔═══════════════════════════════════════════════════════╗');
    log(`║  WARMUP RESULT → model: ❌  fallback(fieldExtractor): ${ok ? '✅' : '❌'}`);
    log('╚═══════════════════════════════════════════════════════╝');
    return { model: false, ocr: false, fallback: ok, mode: 'fieldExtractor' };
  }

  log('▶ warmup: loading tesseract (yolo-side OCR)...');
  const ocr = await getOcr();
  log('  warmup tesseract:', ocr ? '✅ OK' : '❌ FAILED');

  total();
  log('╔═══════════════════════════════════════════════════════╗');
  log(`║  WARMUP RESULT → model: ✅  tesseract: ${ocr ? '✅' : '❌'}`);
  log('╚═══════════════════════════════════════════════════════╝');
  return { model: true, ocr: !!ocr, fallback: false, mode: 'yolo' };
}

// ============================================================
// IMAGE PREP
// ============================================================
async function bitmapFromFile(file) {
  log('▶ bitmapFromFile');
  const done = timer('createImageBitmap');
  const bmp = await createImageBitmap(file, { imageOrientation: 'from-image' });
  done();
  log('  ✅ bitmap:', bmp.width, 'x', bmp.height);
  return bmp;
}

function toTensor(bitmap) {
  log('▶ toTensor (letterbox to', MODEL_INPUT_SIZE, ')');
  const done = timer('toTensor');

  const size = MODEL_INPUT_SIZE;
  const canvas = new OffscreenCanvas(size, size);
  const ctx = canvas.getContext('2d');

  const scale = Math.min(size / bitmap.width, size / bitmap.height);
  const w = Math.round(bitmap.width * scale);
  const h = Math.round(bitmap.height * scale);
  const dx = (size - w) >> 1;
  const dy = (size - h) >> 1;

  ctx.fillStyle = '#808080';
  ctx.fillRect(0, 0, size, size);
  ctx.drawImage(bitmap, dx, dy, w, h);

  const { data } = ctx.getImageData(0, 0, size, size);
  const plane = size * size;
  const t = new Float32Array(3 * plane);
  for (let i = 0; i < plane; i++) {
    t[i]             = data[i * 4]     / 255;
    t[plane + i]     = data[i * 4 + 1] / 255;
    t[2 * plane + i] = data[i * 4 + 2] / 255;
  }
  done();

  return {
    tensor: new _ort.Tensor('float32', t, [1, 3, size, size]),
    meta: { scale, dx, dy, srcW: bitmap.width, srcH: bitmap.height },
  };
}

// ============================================================
// POST-PROCESSING
// ============================================================
function iou(a, b) {
  const x1 = Math.max(a[0], b[0]), y1 = Math.max(a[1], b[1]);
  const x2 = Math.min(a[2], b[2]), y2 = Math.min(a[3], b[3]);
  const inter = Math.max(0, x2 - x1) * Math.max(0, y2 - y1);
  const areaA = (a[2]-a[0]) * (a[3]-a[1]);
  const areaB = (b[2]-b[0]) * (b[3]-b[1]);
  return inter / (areaA + areaB - inter + 1e-6);
}

function nms(boxes, scores) {
  const order = scores.map((s, i) => [s, i]).sort((a, b) => b[0] - a[0]).map(x => x[1]);
  const keep = [];
  while (order.length) {
    const i = order.shift();
    keep.push(i);
    for (let j = order.length - 1; j >= 0; j--) {
      const k = order[j];
      if (iou(boxes[i], boxes[k]) > NMS_IOU) order.splice(j, 1);
    }
  }
  return keep;
}

function decode(out, meta) {
  log('▶ decode detections');
  const dims = out.dims;
  log('  output dims:', dims);

  if (!Array.isArray(dims) || dims.length !== 3) {
    throw new Error(`Unexpected output dims: ${JSON.stringify(dims)} (model untrained?)`);
  }

  const [, ch, n] = dims;
  const nc = ch - 4;
  if (nc <= 0) {
    throw new Error(`Invalid channel count: ch=${ch} → nc=${nc} (model untrained?)`);
  }
  log('  classes:', nc, '| anchors:', n);

  const d = out.data;
  const boxes = [], scores = [], labels = [];

  for (let i = 0; i < n; i++) {
    let best = 0, bc = -1;
    for (let c = 0; c < nc; c++) {
      const s = d[(4 + c) * n + i];
      if (s > best) { best = s; bc = c; }
    }
    if (best < DETECT_CONF) continue;

    const cx = d[0 * n + i], cy = d[1 * n + i];
    const bw = d[2 * n + i], bh = d[3 * n + i];

    const x1 = ((cx - bw / 2) - meta.dx) / meta.scale;
    const y1 = ((cy - bh / 2) - meta.dy) / meta.scale;
    const x2 = ((cx + bw / 2) - meta.dx) / meta.scale;
    const y2 = ((cy + bh / 2) - meta.dy) / meta.scale;

    boxes.push([
      Math.max(0, Math.min(meta.srcW, x1)),
      Math.max(0, Math.min(meta.srcH, y1)),
      Math.max(0, Math.min(meta.srcW, x2)),
      Math.max(0, Math.min(meta.srcH, y2)),
    ]);
    scores.push(best); labels.push(bc);
  }

  log('  raw detections:', scores.length);
  const kept = nms(boxes, scores);
  log('  after NMS:', kept.length);

  return kept.map(i => ({ box: boxes[i], score: scores[i], label: labels[i] }));
}

// ============================================================
// CROP + OCR
// ============================================================
async function cropAndOcr(bitmap, box, label) {
  const [x1, y1, x2, y2] = box;
  const pad = 6, up = 2;
  const sx = Math.max(0, x1 - pad);
  const sy = Math.max(0, y1 - pad);
  const sw = Math.max(1, (x2 - x1) + pad * 2);
  const sh = Math.max(1, (y2 - y1) + pad * 2);

  const canvas = new OffscreenCanvas(sw * up, sh * up);
  const ctx = canvas.getContext('2d');
  ctx.imageSmoothingEnabled = true;
  ctx.imageSmoothingQuality = 'high';
  ctx.drawImage(bitmap, sx, sy, sw, sh, 0, 0, sw * up, sh * up);

  const img = ctx.getImageData(0, 0, canvas.width, canvas.height);
  const p = img.data;
  for (let i = 0; i < p.length; i += 4) {
    const g = p[i] * 0.299 + p[i+1] * 0.587 + p[i+2] * 0.114;
    const bw = g > 140 ? 255 : 0;
    p[i] = p[i+1] = p[i+2] = bw;
  }
  ctx.putImageData(img, 0, 0);

  const blob = await canvas.convertToBlob({ type: 'image/png' });

  const worker = await getOcr();
  if (!worker) throw new Error('No OCR worker available');

  const { data: { text, confidence } } = await worker.recognize(blob);
  const cleaned = (text || '').replace(/\s+/g, ' ').trim();
  log(`  ▶ OCR[${label}] = ${JSON.stringify(cleaned)} (conf ${confidence?.toFixed?.(1) ?? 'n/a'})`);
  return cleaned;
}

function pick(text, field) {
  const rx = VALIDATORS[field];
  if (rx) {
    const m = text.match(rx);
    if (m) return m[0];
  }
  const parts = text.split(' ').filter(Boolean);
  return parts.length ? parts[parts.length - 1] : '';
}

// ============================================================
// MAIN
// ============================================================
export async function extractDocument(file) {
  const t0 = performance.now();
  log('╔═══════════════════════════════════════════════════════╗');
  log('║  EXTRACT — START                                     ║');
  log('╚═══════════════════════════════════════════════════════╝');
  log('file:', file?.name, '|', file?.type, '|', file?.size, 'bytes');

  if (!file) {
    error('❌ no file passed to extractDocument');
    return null;
  }

  // ─────────────────────────────────────────────────────
  // PDF branch — ./pdfAna.js
  // ─────────────────────────────────────────────────────
  if (file.type === 'application/pdf') {
    return await runPdfPath(file);
  }

  // ─────────────────────────────────────────────────────
  // Image branch — YOLO with fieldExtractor fallback
  // ─────────────────────────────────────────────────────
  try {
    log('▶ step 1/6: getSession() …');
    const session = await getSession();
    log('  getSession() returned:', session ? '✅ session' : '❌ null');

    if (!session) {
      return await runTessFallback(file, 'no session');
    }

    log('▶ step 1b/6: getOcr() …');
    const ocr = await getOcr();
    if (!ocr) {
      return await runTessFallback(file, 'no OCR worker');
    }

    log('▶ step 2/6: decode image');
    const bitmap = await bitmapFromFile(file);

    log('▶ step 3/6: build input tensor');
    const { tensor, meta } = toTensor(bitmap);

    log('▶ step 4/6: session.run()');
    const doneInfer = timer('session.run');
    const out = await session.run({ images: tensor });
    doneInfer();

    const outKey = Object.keys(out)[0];
    log('  output key:', outKey, '| dims:', out[outKey]?.dims, '| dtype:', out[outKey]?.type);

    log('▶ step 5/6: decode detections');
    const dets = decode(out[outKey], meta);
    if (dets.length === 0) {
      warn('⚠️ no detections above threshold — falling back to fieldExtractor');
      return await runTessFallback(file, 'zero detections');
    }

    log('▶ step 6/6: OCR per detection (' + dets.length + ' boxes)');
    const fields = {};
    const raw = {};
    for (const d of dets) {
      const label = FIELD_NAMES[d.label];
      if (!label) continue;
      const target = FIELD_MAP[label];
      if (!target) continue;

      const text = await cropAndOcr(bitmap, d.box, label);
      const value = pick(text, target);
      if (!value) continue;

      if (!raw[target] || raw[target].confidence < d.score) {
        raw[target] = { value, confidence: d.score, ocr: text };
        fields[target] = value;
      }
    }

    const elapsed = (performance.now() - t0).toFixed(1);
    log(`✅ EXTRACT — DONE (yolo) in ${elapsed}ms | fields=${Object.keys(fields).length}`);
    return { fields, raw, source: 'yolo' };

  } catch (yoloErr) {
    error('❌ YOLO path threw — falling back to fieldExtractor');
    error('   message:', yoloErr.message);
    error('   name   :', yoloErr.name);
    error('   stack  :', yoloErr.stack);
    return await runTessFallback(file, `yolo threw: ${yoloErr.message}`);
  }
}

// ============================================================
// DISPOSE
// ============================================================
export async function disposeExtractor() {
  log('▶ disposeExtractor()');

  _session = null;
  _fieldExtractor = null;
  _fieldExtractorTried = false;

  if (_ocr) {
    _ocr.terminate().catch((e) => warn('  ⚠️ ocr.terminate threw:', e?.message));
    _ocr = null;
  }

  try {
    const tess = await import('./tess.js');
    if (tess?.tessOcr?.destroy) {
      await tess.tessOcr.destroy();
      log('  ✅ tessOcr destroyed');
    }
  } catch (e) {
    warn('  ⚠️ dispose tess failed:', e?.message);
  }

  log('dispose: done');
}