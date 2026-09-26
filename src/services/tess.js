// src/services/tess.js
// OCR-only engine + back-compat wrapper.
//
// Public exports (preserved for existing importers):
//   export const teSsAna        (named)
//   export default teSsAna
//   export const tessOcr        (raw OCR, used by fieldExtractor.js)
//
// Classification + individual field extraction live in ./fieldExtractor.js
//
// NOTE on langPath:
//   tesseract.js does NOT ship *.traineddata.gz.
//   Omit langPath → tesseract.js auto-fetches from
//   https://cdn.jsdelivr.net/npm/@tesseract.js-data/<lang>/4.0.0

import { createWorker } from 'tesseract.js';

// ============================================================
// LOG HELPERS
// ============================================================
const TAG = '[tess]';
const log   = (...a) => console.log(TAG, ...a);
const warn  = (...a) => console.warn(TAG, ...a);
const error = (...a) => console.error(TAG, ...a);
const timer = (label) => {
    const t0 = performance.now();
    log(`⏱️  ${label} … start`);
    return () => {
        const ms = (performance.now() - t0).toFixed(1);
        log(`⏱️  ${label} … done in ${ms}ms`);
        return ms;
    };
};
const trunc = (s, n = 200) => {
    if (typeof s !== 'string') return s;
    return s.length > n ? s.slice(0, n) + `…(+${s.length - n})` : s;
};

// ============================================================
// CDN CONSTANTS
// ============================================================
const TESS_VERSION = '7.0.0';
const TESS_WORKER  = `https://cdn.jsdelivr.net/npm/tesseract.js@${TESS_VERSION}/dist/worker.min.js`;
const TESS_CORE    = `https://cdn.jsdelivr.net/npm/tesseract.js-core@${TESS_VERSION}`;

// ============================================================
// RAW OCR ENGINE — singleton worker wrapper
// ============================================================
class TessOCR {
    constructor() {
        log('🧱 constructor: new TessOCR()');
        this.worker = null;
        this.isReady = false;
        this.initPromise = null;
    }

    async init() {
        log('▶ init()');
        if (this.isReady) {
            log('  ↷ already initialized');
            return;
        }
        if (typeof createWorker === 'undefined') {
            error('❌ createWorker undefined — tesseract.js import broken');
            throw new Error('Tesseract.js not loaded. Please check your imports.');
        }
        await this.initializeWorker();
    }

    async initializeWorker() {
        if (this.initPromise) {
            log('  ↷ worker init already in-flight');
            return this.initPromise;
        }
        if (this.isReady) return;

        this.initPromise = (async () => {
            const done = timer('createWorker(eng+amh)');
            try {
                log(`  🔵 creating worker — Tesseract.js v${TESS_VERSION}`);
                log('     workerPath:', TESS_WORKER);
                log('     corePath  :', TESS_CORE);
                log('     langPath  : (default — @tesseract.js-data/<lang>/4.0.0)');

                this.worker = await createWorker('eng+amh', 1, {
                    workerPath: TESS_WORKER,
                    corePath:   TESS_CORE,
                    logger: (m) => this._onProgress(m),
                });

                done();
                this.isReady = true;
                log(`  ✅ worker ready — Tesseract.js v${TESS_VERSION}`);
            } catch (e) {
                done();
                error('❌ worker creation FAILED');
                error('   message:', e.message);
                error('   stack  :', e.stack);
                this.isReady = false;
                this.worker = null;
                throw new Error(`OCR engine failed to start: ${e.message}`);
            } finally {
                this.initPromise = null;
            }
        })();

        return this.initPromise;
    }

    _onProgress(progress) {
        if (!progress || !progress.status) return;
        const pct = (typeof progress.progress === 'number')
            ? ` ${(progress.progress * 100).toFixed(0)}%`
            : '';
        log(`   ⏳ tesseract: ${progress.status}${pct}`);

        const loadingEl = document.getElementById('loading');
        if (!loadingEl) return;

        switch (progress.status) {
            case 'loading tesseract core':       loadingEl.textContent = 'Loading OCR engine...'; break;
            case 'initializing tesseract':       loadingEl.textContent = 'Initializing OCR...'; break;
            case 'loading language traineddata': loadingEl.textContent = 'Loading language data...'; break;
            case 'initializing api':             loadingEl.textContent = 'Finalizing OCR...'; break;
            case 'recognizing text':
                loadingEl.textContent = `OCR Processing: ${Math.round(progress.progress * 100)}%`;
                break;
        }
    }

    async recognize(imageFile) {
        log('▶ recognize()');
        log('  name :', imageFile?.name);
        log('  type :', imageFile?.type);
        log('  size :', imageFile?.size, 'bytes');

        if (!imageFile) throw new Error('recognize(): no file provided');
        if (typeof imageFile.type !== 'string' || !imageFile.type.startsWith('image/')) {
            throw new Error(`recognize(): unsupported type "${imageFile.type}" — expected image/*`);
        }

        if (!this.isReady || !this.worker) {
            log('  ↷ worker not ready — initializing now');
            await this.initializeWorker();
        }

        const done = timer('worker.recognize');
        try {
            const result = await this.worker.recognize(imageFile);
            done();

            const text       = result?.data?.text || '';
            const confidence = result?.data?.confidence ?? 0;
            const words      = result?.data?.words || [];
            const lines      = result?.data?.lines || [];

            log(`  ✅ OCR done — chars=${text.length} words=${words.length} lines=${lines.length} conf=${confidence}`);
            log(`  📝 first 200 chars: ${JSON.stringify(trunc(text, 200))}`);

            return { text, confidence, words, lines };
        } catch (e) {
            done();
            error('❌ recognize FAILED');
            error('   message:', e.message);
            error('   stack  :', e.stack);
            throw new Error(`OCR failed: ${e.message}`);
        }
    }

    getStatus() {
        return {
            isReady: this.isReady,
            worker: this.worker ? 'Active' : 'None',
            initPromise: this.initPromise ? 'Pending' : 'None',
        };
    }

    async destroy() {
        log('▶ destroy()');
        if (this.worker) {
            try {
                await this.worker.terminate();
                log('  ✅ worker terminated');
            } catch (e) {
                warn('  ⚠️ terminate threw:', e.message);
            }
            this.worker = null;
            this.isReady = false;
        } else {
            log('  ↷ no worker to terminate');
        }
    }
}

// ============================================================
// SINGLETON (raw OCR)
// ============================================================
log('🧱 module eval: creating singleton tessOcr');
export const tessOcr = new TessOCR();

// ============================================================
// BACK-COMPAT WRAPPER — preserves the old public API name
// `teSsAna`. Delegates OCR + classification + field extraction
// + nlp hand-off to ./fieldExtractor.js
// ============================================================
class TessAna {
    constructor() {
        log('🧱 constructor: new TessAna() [compat wrapper]');
    }

    async init() {
        log('▶ [teSsAna] init()');
        return tessOcr.init();
    }

    /**
     * Old entry point — same name, same shape.
     * Delegates to fieldExtractor.extractWithTess(file).
     */
    async analyzeDocument(file) {
        log('▶ [teSsAna] analyzeDocument() — delegating to fieldExtractor');
        const { extractWithTess } = await import('./fieldExtractor.js');
        return extractWithTess(file);
    }

    /** Old helper — returns just the OCR text string. */
    async performOCR(imageFile) {
        log('▶ [teSsAna] performOCR()');
        const r = await tessOcr.recognize(imageFile);
        return r.text;
    }

    getWorkerStatus() {
        return tessOcr.getStatus();
    }

    async destroy() {
        log('▶ [teSsAna] destroy()');
        return tessOcr.destroy();
    }
}

export const teSsAna = new TessAna();
export default teSsAna;