// src/services/fieldExtractor.js
// OCR (via ./tess.js) → classify → extract fields → hand result
// back into the nlpProcessor workflow via sendExtraction().
//
// sendExtraction() is a dedicated function inside nlpProcessor.js
// that POSTs ONLY the extracted payload to /chat with mode:'document'.
// No message string, no detectService, no ChatUI involvement.
//
// Public exports:
//   extractWithTess(file)              ← OCR + classify + fields + nlp hand-off
//   classifyDocument(text)             ← classification only
//   extractFields(text, documentType)  ← field extraction only

import { tessOcr } from './tess.js';
import { sendExtraction } from './nlpProcessor.js';

// ============================================================
// LOG HELPERS
// ============================================================
const TAG = '[fieldExtractor]';
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

// ============================================================
// RE-ENTRY GUARD
// ============================================================
let _extractInFlight = false;

// ============================================================
// CLASSIFICATION
// ============================================================
const CLASSIFIERS = [
    { type: 'Vehicle Registration Document', typeClass: 'type-government',  category: 'transportation', confidence: 0.9,
      rx: /(የሰሌዳ\s*ቁጥር|የተሽከርካሪው|የሻንሺ\s*ቁጥር|chassis\s*number|vehicle\s*description|plate\s*number)/i },
    { type: 'Insurance Policy Document',     typeClass: 'type-insurance',   category: 'insurance',      confidence: 0.9,
      rx: /(የመድን|ፖሊሲው\s*ቁጥር|policy\s*number|date\s*of|issuance|የአረቦን\s*መጠን|premium\s*tariff|policy\s*period)/i },
    { type: 'Academic Paper',                typeClass: 'type-research',    category: 'academic',       confidence: 0.8,
      rx: /(abstract|introduction|methodology|results|discussion|conclusion|references|bibliography)/i },
    { type: 'Legal Document',                typeClass: 'type-legal',       category: 'legal',          confidence: 0.7,
      rx: /(agreement|contract|clause|party|whereas|warranty|jurisdiction)/i },
    { type: 'Government Document',           typeClass: 'type-government',  category: 'government',     confidence: 0.75,
      rx: /(license|permit|national id|fayda id|government|identification|ዜግነት|ኢትዮጵያ)/i },
    { type: 'Financial Document',            typeClass: 'type-financial',   category: 'financial',      confidence: 0.6,
      rx: /(invoice|receipt|payment|amount|balance|statement|tax)/i },
];

export function classifyDocument(text) {
    log('▶ classifyDocument()');
    log('  text length:', text.length);

    const language = detectLanguage(text);
    log('  language:', language);

    for (const c of CLASSIFIERS) {
        if (c.rx.test(text)) {
            log(`  🎯 matched → ${c.type}`);
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

function detectLanguage(text) {
    const hasEthiopic = /[ሀ-ፕ]/.test(text);
    const hasLatin    = /[a-zA-Z]/.test(text);
    if (hasEthiopic && hasLatin) return 'amh+eng';
    if (hasEthiopic) return 'amh';
    if (hasLatin)    return 'eng';
    return 'unknown';
}

// ============================================================
// FIELD PATTERNS (vehicle registration)
// ============================================================
const VEHICLE_PATTERNS = {
    plateNumber:      { keys: ['የሰሌዳ\\s*ቁጥር', 'plate\\s*number'] },
    ownerName:        { keys: ['ስም', 'name'] },
    chassisNumber:    { keys: ['የሻንሺ\\s*ቁጥር', 'chassis\\s*number'] },
    motorNumber:      { keys: ['የሞተር\\s*ቁጥር', 'motor\\s*number'] },
    vehicleModel:     { keys: ['የተሽ[\\/]?\\s*ሞዴል', 'vehicle\\s*model'] },
    previousPlate:    { keys: ['የቀድሞ\\s*ሰሌዳ\\s*ቁጥር', 'previous\\s*plate'] },
    gender:           { keys: ['ጾታ', 'gender'] },
    nationality:      { keys: ['ዜግነት', 'nationality'] },
    city:             { keys: ['ከተማ', 'city'] },
    subcity:          { keys: ['ክ[\\/]\\s*ከተማ', 'subcity'] },
    woreda:           { keys: ['ቀበሌ[\\/]\\s*ወረዳ', 'woreda'] },
    phone:            { keys: ['ሰልክ', 'phone'] },
    vehicleType:      { keys: ['የመኪና\\s*አይነት', 'vehicle\\s*type'] },
    bodyType:         { keys: ['የአካሉ\\s*አይነት', 'body\\s*type'] },
    fuelType:         { keys: ['የነዳጅ\\s*ዓይነት', 'fuel\\s*type'] },
    color:            { keys: ['ቀለም', 'color'] },
    manufacturer:     { keys: ['የተሰራበት\\s*ሀገር', 'manufacturer'] },
    manufactureYear:  { keys: ['የተሰራበት\\s*ዘመን', 'manufacture\\s*year'] },
    enginePower:      { keys: ['የሞተር\\s*የፈረስ\\s*ጉልበት', 'engine\\s*power'] },
    totalWeight:      { keys: ['የተሽ[\\/]\\s*ጠቅ[\\/]\\s*ክብደት', 'total\\s*weight'] },
    unladenWeight:    { keys: ['ነጠላ\\s*ክብደት', 'unladen\\s*weight'] },
    loadCapacity:     { keys: ['የጭነት\\s*መጠን', 'load\\s*capacity'] },
    engineCapacity:   { keys: ['የሞተር\\s*ችሎታ[\\/]\\s*ሲሲ', 'engine\\s*capacity'] },
    cylinderCount:    { keys: ['የሲሊንደር\\s*ብዛት', 'cylinder\\s*count'] },
    permittedWork:    { keys: ['የተፈቀደለት\\s*የስራ\\s*ጸባይ', 'permitted\\s*work'] },
};

// ============================================================
// FIELD PATTERNS (insurance)
// ============================================================
const INSURANCE_PATTERNS = {
    certificateNumber: { keys: ['የሰርተፊኬት\\s*ቁጥር', 'certificate\\s*number', 'CERTIFICATE\\s*NUMBER', 'Certificate\\s*No'] },
    insuredName:       { keys: ['የመድን\\s*ገቢው\\s*ስም', 'name\\s*of\\s*insured', 'INSURED', 'NAME\\s*OF\\s*INSURED', 'የመድን\\s*ገቢው'] },
    plateNumber:       { keys: ['የሠሌዳ\\s*ቁጥር', 'plate\\s*number', 'PLATE\\s*NUMBER', 'የሰሌዳ\\s*ቁጥር'] },
    vehicleType:       { keys: ['የተሸከርካሪ\\s*እይነት', 'vehicle\\s*type', 'VEHICLE\\s*TYPE', 'የተሽከርካሪ\\s*አይነት'] },
    policyNumber:      { keys: ['የመድን\\s*ፖሊሲው\\s*ቁጥር', 'policy\\s*number', 'INSURER\\s*POLICY\\s*No', 'POLICY\\s*NUMBER'] },
    dateOfIssuance:    { keys: ['የተሰጠበት\\s*ቀን', 'date\\s*of\\s*issuance', 'DATE\\s*OF\\s*ISSUANCE'] },
    policyPeriodFrom:  { keys: ['ፖሊሲው\\s*ዘመን\\s*ከ', 'policy\\s*period\\s*from', 'FROM'] },
    policyPeriodTo:    { keys: ['እስከ', 'to', 'TO'] },
    premiumAmount:     { keys: ['የአረቦን\\s*መጠን', 'premium', 'PREMIUM\\s*TARIF', 'premium\\s*tariff'] },
    chassisNumber:     { keys: ['የቻንሲ\\s*ቁጥር', 'chassis\\s*number', 'CHASSIS\\s*NUMBER'] },
    engineNumber:      { keys: ['የሞተር\\s*ቁጥር', 'engine\\s*number', 'ENGINE\\s*NUMBER'] },
    phoneNumber:       { keys: ['ሞባይል\\s*ቁጥር', 'phone\\s*number', 'PHONE\\s*NUMBER', 'ስልክ'] },
    region:            { keys: ['ክልል', 'region', 'REGION', 'አድራሻ'] },
    subcity:           { keys: ['ክ[\\/]\\s*ከተማ', 'ክፍለ\\s*ከተማ', 'subcity', 'SUB\\s*CITY'] },
    woreda:            { keys: ['ቀበሌ[\\/]\\s*ወረዳ', 'woreda'] },
    kebele:            { keys: ['ቀበሌ', 'kebele', 'KEBELE'] },
    insurerName:       { keys: ['የመድን\\s*ሰጪው\\s*ስም', 'name\\s*of\\s*insurer', 'NAME\\s*OF\\s*INSURER'] },
    carryingCapacity:  { keys: ['የመጫን\\s*አቅም', 'carrying\\s*capacity', 'CARRYING\\s*CAPACITY'] },
    persons:           { keys: ['ስዎች', 'persons', 'PERSONS'] },
};

// ============================================================
// FIELD EXTRACTION
// ============================================================
export function extractFields(text, documentType) {
    log('▶ extractFields()');
    log('  documentType:', documentType);

    const patterns =
        documentType === 'Insurance Policy Document' ? INSURANCE_PATTERNS :
        documentType === 'Vehicle Registration Document' ? VEHICLE_PATTERNS :
        null;

    if (!patterns) {
        log('  ↷ no pattern table for this type — returning empty fields');
        return {};
    }

    const lines = text.split('\n').map(l => l.trim()).filter(l => l.length > 2);
    log('  lines to scan:', lines.length);

    const fields = {};

    lines.forEach((line, idx) => {
        for (const [field, patternInfo] of Object.entries(patterns)) {
            if (fields[field]) continue;
            for (const key of patternInfo.keys) {
                const rx = new RegExp(`${key}[\\s:]*([^\\n]{3,30})`, 'i');
                const m = line.match(rx);
                if (m && m[1]) {
                    const value = m[1].trim().replace(/^[:\s\-]+|[:\s\-]+$/g, '');
                    if (value) {
                        fields[field] = value;
                        log(`  ✅ [line ${idx}] ${field} = ${JSON.stringify(value)}`);
                        break;
                    }
                }
            }
        }
    });

    extractSeparatedKeyValues(lines, fields);

    const cleaned = validateAndClean(fields);
    log('  ✅ extractFields done — field count:', Object.keys(cleaned).length);
    return cleaned;
}

function extractSeparatedKeyValues(lines, fields) {
    log('  ▶ extractSeparatedKeyValues()');

    if (!fields.chassisNumber) {
        const i = lines.findIndex(l => /የሻንሺ|chassis/i.test(l));
        if (i !== -1) {
            for (let j = i + 1; j <= Math.min(lines.length - 1, i + 5); j++) {
                const vinMatch = lines[j].match(/([A-HJ-NPR-Z0-9]{17})/);
                if (vinMatch && !/phone|ሰልክ|0911/i.test(lines[j])) {
                    fields.chassisNumber = vinMatch[1];
                    log(`  ✅ chassis(VIN) = ${vinMatch[1]} @ line ${j}`);
                    break;
                }
                const chMatch = lines[j].match(/([A-Z0-9]{10,18})/);
                if (chMatch) {
                    fields.chassisNumber = chMatch[1];
                    log(`  ✅ chassis = ${chMatch[1]} @ line ${j}`);
                    break;
                }
            }
        }
    }

    if (!fields.motorNumber) {
        const i = lines.findIndex(l => /የሞተር|motor/i.test(l));
        if (i !== -1) {
            for (let j = i + 1; j <= Math.min(lines.length - 1, i + 5); j++) {
                const m = lines[j].match(/(1SG400[\-\s]?[0-9A-Z]{7,9}|[A-Z0-9]{3,6}[\-\s]?[A-Z0-9]{5,10})/);
                if (m && !/phone|ሰልክ|0911/i.test(lines[j])) {
                    fields.motorNumber = m[1];
                    log(`  ✅ motor = ${m[1]} @ line ${j}`);
                    break;
                }
            }
        }
    }

    if (!fields.manufactureYear) {
        for (let i = 0; i < lines.length; i++) {
            const y = lines[i].match(/(20[0-9]{2})/);
            if (y && !/phone|ሰልክ/i.test(lines[i])) {
                fields.manufactureYear = y[1];
                log(`  ✅ year = ${y[1]} @ line ${i}`);
                break;
            }
        }
    }

    if (!fields.phone) {
        const i = lines.findIndex(l => /ሰልክ|phone/i.test(l));
        if (i !== -1) {
            for (let j = Math.max(0, i - 2); j <= Math.min(lines.length - 1, i + 2); j++) {
                const p = lines[j].match(/([0-9]{8,10})/);
                if (p) {
                    fields.phone = p[1];
                    log(`  ✅ phone = ${p[1]} @ line ${j}`);
                    break;
                }
            }
        }
    }
}

function validateAndClean(data) {
    const cleaned = { ...data };
    Object.keys(cleaned).forEach(k => {
        if (typeof cleaned[k] === 'string') {
            cleaned[k] = cleaned[k].replace(/\s+/g, ' ').trim().replace(/^[:\-\s]+|[:\-\s]+$/g, '');
        }
    });
    return cleaned;
}

// ============================================================
// MAIN — OCR → classify → extract → sendExtraction()
// ============================================================
export async function extractWithTess(file) {
    if (_extractInFlight) {
        warn('⚠️ extractWithTess re-entered while already running — bailing to prevent loop');
        return {
            fields: {}, raw: null, source: 'tess',
            documentType: 'General Document', language: 'unknown',
            confidence: 0, text: '', ocrConfidence: 0, nlpResponse: null,
        };
    }
    _extractInFlight = true;

    const t0 = performance.now();

    log('╔══════════════════════════════════════════╗');
    log('║  fieldExtractor.extractWithTess()        ║');
    log('╚══════════════════════════════════════════╝');
    log('file:', file?.name, '|', file?.type, '|', file?.size, 'bytes');

    try {
        log('▶ step 1/3: tessOcr.recognize(file)');
        const doneOcr = timer('OCR');
        const ocr = await tessOcr.recognize(file);
        doneOcr();
        log('  ✅ OCR text length:', ocr.text.length);

        log('▶ step 2/3: classifyDocument(text)');
        const cls = classifyDocument(ocr.text);
        log('  ✅ class:', cls);

        log('▶ step 3/3: extractFields(text, docType)');
        const fields = extractFields(ocr.text, cls.documentType);
        log('  ✅ field count:', Object.keys(fields).length);

        const result = {
            fields,
            raw: null,
            source: 'tess',
            documentType: cls.documentType,
            typeClass:    cls.typeClass,
            category:     cls.category,
            language:     cls.language,
            confidence:   cls.confidence,
            text:         ocr.text,
            ocrConfidence: ocr.confidence,
        };

        // ============================================================
        // Hand-off — sends ONLY the extracted payload to nlpProcessor's
        // sendExtraction(), which POSTs it to /chat with mode:'document'.
        // No message string, no detectService, no intent hijack.
        // ============================================================
        log('  📤 calling nlpProcessor.sendExtraction(result) …');

        let nlpResponse = null;
        try {
            nlpResponse = await sendExtraction(result);
            log('  ✅ sendExtraction returned:', nlpResponse);
        } catch (nlpErr) {
            warn('  ⚠️ sendExtraction threw — returning raw result anyway:', nlpErr.message);
        }

        const ms = (performance.now() - t0).toFixed(1);
        log(`✅ extractWithTess DONE in ${ms}ms`);
        return { ...result, nlpResponse };
    } catch (e) {
        const ms = (performance.now() - t0).toFixed(1);
        error(`❌ extractWithTess FAILED after ${ms}ms`);
        error('   message:', e.message);
        error('   stack  :', e.stack);
        throw e;
    } finally {
        _extractInFlight = false;
    }
}