import express from 'express';
import rateLimit from 'express-rate-limit';

const router = express.Router();

const nlpLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  message: { error: 'Too many requests', code: 'RATE_LIMITED' },
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req) => req.headers['x-session-id'] || req.ip
});

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

router.get('/services', async (req, res) => {
  try {
    const nlpProcessor = req.app.locals.nlpProcessor;
    const services = await nlpProcessor.getAvailableServices();
    const safe = services.map(s => ({ id: s.id, name: s.name, description: s.description, initStep: s.initStep }));
    res.json({ success: true, data: safe });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch services' });
  }
});

router.post('/reset/:serviceId', async (req, res) => {
  try {
    const nlpProcessor = req.app.locals.nlpProcessor;
    nlpProcessor.resetService(req.params.serviceId);
    res.json({ success: true });
  } catch (error) {
    res.status(500).json({ error: 'Reset failed' });
  }
});

router.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: Date.now() });
});

export default router;
