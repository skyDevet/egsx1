// nlp.js
import express from 'express';
import rateLimit, { ipKeyGenerator } from 'express-rate-limit';
const router = express.Router();

const nlpLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  message: { error: 'Too many requests', code: 'RATE_LIMITED' },
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => {
  const sid = req.headers['x-session-id'];
  if (sid) return sid;
  return ipKeyGenerator(req.ip);
}
});

// ------------------------------------------------------------
// POST /api/nlp/chat
// Body: { message, file, sessionId, mode, serviceId, language }
// mode: "stage" | "answer" | "chat"
// ------------------------------------------------------------
router.post('/chat', nlpLimiter, async (req, res) => {
  try {
    const { message, text, file, sessionId, mode = 'chat', serviceId = null, language } = req.body;
    if (!sessionId) return res.status(400).json({ error: 'Missing sessionId' });

    const nlpProcessor = req.app.locals.nlpProcessor;
    if (!nlpProcessor) return res.status(500).json({ error: 'NLP processor not initialized' });
    if (language) nlpProcessor.setLanguage(language);

    // Accept both `message` (new client) and `text` (old client)
    const userText = message ?? text ?? null;

    const result = await nlpProcessor.chat(userText, file || null, sessionId, mode, serviceId);
    res.json({ success: true, data: result, timestamp: Date.now() });
  } catch (error) {
    console.error('chat error:', error.message);
    res.status(500).json({ error: 'Processing failed', message: error.message });
  }
});

// ------------------------------------------------------------
// Legacy POST /api/nlp/process (kept so older clients keep working)
// ------------------------------------------------------------
router.post('/process', nlpLimiter, async (req, res) => {
  try {
    const { text, sessionId, language, file } = req.body;
    if (!sessionId) return res.status(400).json({ error: 'Missing sessionId' });
    if (!text && !file) return res.status(400).json({ error: 'Missing text or file' });

    const nlpProcessor = req.app.locals.nlpProcessor;
    if (language) nlpProcessor.setLanguage(language);

    const result = await nlpProcessor.chat(text, file || null, sessionId);
    res.json({ success: true, data: result, timestamp: Date.now() });
  } catch (error) {
    console.error('Process error:', error.message);
    res.status(500).json({ error: 'Processing failed', message: error.message });
  }
});

// ------------------------------------------------------------
// POST /api/nlp/resume
// Body: { sessionId, language }
// ------------------------------------------------------------
router.post('/resume', nlpLimiter, async (req, res) => {
  try {
    const { sessionId, language } = req.body;
    if (!sessionId) return res.status(400).json({ error: 'Missing sessionId' });

    const nlpProcessor = req.app.locals.nlpProcessor;
    if (language) nlpProcessor.setLanguage(language);

    const result = await nlpProcessor.resume(sessionId);
    res.json({ success: true, data: result, timestamp: Date.now() });
  } catch (error) {
    console.error('resume error:', error.message);
    res.status(500).json({ error: 'Resume failed', message: error.message });
  }
});

// ------------------------------------------------------------
// POST /api/nlp/session-status
// Body: { sessionId }
// ------------------------------------------------------------
router.post('/session-status', async (req, res) => {
  try {
    const { sessionId } = req.body;
    if (!sessionId) return res.status(400).json({ error: 'Missing sessionId' });

    const nlpProcessor = req.app.locals.nlpProcessor;
    const status = await nlpProcessor.getSessionStatus(sessionId);
    res.json({ success: true, data: status });
  } catch (error) {
    console.error('session-status error:', error.message);
    res.status(500).json({ error: 'Status check failed', message: error.message });
  }
});

// ------------------------------------------------------------
// POST /api/nlp/end-session
// Body: { sessionId }
// ------------------------------------------------------------
router.post('/end-session', async (req, res) => {
  try {
    const { sessionId } = req.body;
    if (!sessionId) return res.status(400).json({ error: 'Missing sessionId' });

    const nlpProcessor = req.app.locals.nlpProcessor;
    const result = await nlpProcessor.endSession(sessionId);
    res.json({ success: true, data: result });
  } catch (error) {
    console.error('end-session error:', error.message);
    res.status(500).json({ error: 'End session failed', message: error.message });
  }
});

// ------------------------------------------------------------
// POST /api/nlp/set-language
// Body: { language, sessionId }
// ------------------------------------------------------------
router.post('/set-language', async (req, res) => {
  try {
    const { language } = req.body;
    const nlpProcessor = req.app.locals.nlpProcessor;
    nlpProcessor.setLanguage(language);
    res.json({ success: true, language: nlpProcessor.getLanguage() });
  } catch (error) {
    console.error('set-language error:', error.message);
    res.status(500).json({ error: 'Set language failed', message: error.message });
  }
});

// ------------------------------------------------------------
// GET /api/nlp/services
// ------------------------------------------------------------
router.get('/services', async (req, res) => {
  try {
    const nlpProcessor = req.app.locals.nlpProcessor;
    const services = await nlpProcessor.getAvailableServices();
    const safe = services.map(s => ({
      id: s.id,
      name: s.name,
      description: s.description,
      initStep: s.initStep
    }));
    res.json({ success: true, data: safe });
  } catch (error) {
    console.error('services error:', error.message);
    res.status(500).json({ error: 'Failed to fetch services' });
  }
});

// ------------------------------------------------------------
// POST /api/nlp/reset/:serviceId
// ------------------------------------------------------------
router.post('/reset/:serviceId', async (req, res) => {
  try {
    const nlpProcessor = req.app.locals.nlpProcessor;
    nlpProcessor.resetService(req.params.serviceId);
    res.json({ success: true });
  } catch (error) {
    console.error('reset error:', error.message);
    res.status(500).json({ error: 'Reset failed' });
  }
});

// ------------------------------------------------------------
// GET /api/nlp/health
// ------------------------------------------------------------
router.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: Date.now() });
});

export default router;