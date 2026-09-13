import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import session from 'express-session';
import dotenv from 'dotenv';
import nlpRoutes from './routes/nlp.js';
import authRoutes from './routes/auth.js';
import { nlpProcessor } from './services/nlprocessor.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;

app.use(helmet({ contentSecurityPolicy: false, crossOriginEmbedderPolicy: false }));
app.use(cors({
  origin: process.env.ALLOWED_ORIGIN?.split(',') || ['http://localhost:3000', 'http://127.0.0.1:3000'],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Session-ID']
}));
app.use(morgan('dev'));
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true, limit: '1mb' }));
app.use(session({
  secret: process.env.SESSION_SECRET || 'dev-secret-change-me',
  resave: false,
  saveUninitialized: false,
  cookie: { secure: false, httpOnly: true, maxAge: 86400000 }
}));

app.locals.nlpProcessor = nlpProcessor;

app.get('/api/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: Date.now(), uptime: process.uptime() });
});

// Auth (Fayda + Google OIDC)
app.use('/auth', authRoutes);

// NLP
app.use('/api/nlp', nlpRoutes);

app.use((req, res) => res.status(404).json({ error: 'Not found' }));
app.use((err, req, res, next) => {
  console.error('Server Error:', err.message);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, '127.0.0.1', () => {
  console.log('');
  console.log('  ╔══════════════════════════════════════════════╗');
  console.log('  ║   🔒 AGIG NLP SERVER STARTED                 ║');
  console.log('  ╠══════════════════════════════════════════════╣');
  console.log(`  ║   URL:      http://127.0.0.1:${PORT}            ║`);
  console.log(`  ║   Mode:     ${process.env.NODE_ENV || 'development'}                      ║`);
  console.log('  ║   IP Protection: ENABLED                    ║');
  console.log('  ╚══════════════════════════════════════════════╝');
  console.log('');

  nlpProcessor.init().then(() => {
    console.log('✅ NLP Processor ready');
  }).catch(err => {
    console.error('❌ NLP init failed:', err.message);
  });
});