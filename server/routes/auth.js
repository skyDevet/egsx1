// ============================================================
// server/routes/auth.js
// Express version of Fayda (eSignet) + Google OIDC
// ============================================================
import express from 'express';
import crypto from 'crypto';

const router = express.Router();

// ---------- config ----------
function cfg() {
  return {
    fayda: {
      clientId:    process.env.FAYDA_CLIENT_ID,
      privateKey:  process.env.FAYDA_PRIVATE_KEY,          // base64 JWK
      authUrl:     process.env.FAYDA_AUTH_URL     || 'https://esignet.ida.fayda.et/v1/esignet/oauth/v2/authorize',
      tokenUrl:    process.env.FAYDA_TOKEN_URL    || 'https://esignet.ida.fayda.et/v1/esignet/oauth/v2/token',
      userInfoUrl: process.env.FAYDA_USERINFO_URL || 'https://esignet.ida.fayda.et/v1/esignet/oidc/userinfo',
      redirectUri: process.env.FAYDA_REDIRECT_URI,
      scope:       process.env.FAYDA_SCOPE        || 'openid profile email phone'
    },
    google: {
      clientId:     process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET,
      authUrl:      'https://accounts.google.com/o/oauth2/v2/auth',
      tokenUrl:     'https://oauth2.googleapis.com/token',
      userInfoUrl:  'https://www.googleapis.com/oauth2/v3/userinfo',
      redirectUri:  process.env.GOOGLE_REDIRECT_URI
    },
    sessionSecret: process.env.SESSION_SECRET || 'change-me',
    appOrigin:     process.env.APP_ORIGIN || 'http://localhost:3000'
  };
}

// ---------- crypto helpers ----------
function base64UrlEncode(buf) {
  return Buffer.from(buf).toString('base64')
    .replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}
function base64UrlDecode(str) {
  const pad = str.length % 4 === 0 ? '' : '='.repeat(4 - (str.length % 4));
  return Buffer.from(str.replace(/-/g, '+').replace(/_/g, '/') + pad, 'base64');
}
function randomVerifier() {
  return base64UrlEncode(crypto.randomBytes(32));
}
function randomState() {
  return base64UrlEncode(crypto.randomBytes(16));
}
function sha256Challenge(verifier) {
  return base64UrlEncode(crypto.createHash('sha256').update(verifier).digest());
}

// ---------- session token (HMAC-signed) ----------
function hmac(secret, data) {
  return base64UrlEncode(crypto.createHmac('sha256', secret).update(data).digest());
}
function createSession(secret, user) {
  const payload = { user, iat: Date.now(), exp: Date.now() + 7 * 24 * 3600 * 1000 };
  const body = base64UrlEncode(Buffer.from(JSON.stringify(payload)));
  const sig = hmac(secret, body);
  return `${body}.${sig}`;
}
function verifySession(secret, token) {
  if (!token || !token.includes('.')) return null;
  const [body, sig] = token.split('.');
  const expected = hmac(secret, body);
  // constant-time compare
  if (sig.length !== expected.length) return null;
  if (!crypto.timingSafeEqual(Buffer.from(sig), Buffer.from(expected))) return null;
  try {
    const payload = JSON.parse(base64UrlDecode(body).toString('utf8'));
    if (payload.exp && payload.exp < Date.now()) return null;
    return payload.user;
  } catch { return null; }
}

// ---------- RSA client assertion (Fayda) ----------
function makeClientAssertion(privateJwk, clientId, audience) {
  const header = { alg: 'RS256', typ: 'JWT' };
  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: clientId, sub: clientId, aud: audience,
    iat: now, exp: now + 300, jti: randomState()
  };
  const headerB64  = base64UrlEncode(Buffer.from(JSON.stringify(header)));
  const payloadB64 = base64UrlEncode(Buffer.from(JSON.stringify(payload)));
  const signingInput = `${headerB64}.${payloadB64}`;

  const key = crypto.createPrivateKey({ key: privateJwk, format: 'jwk' });
  const sig = crypto.sign('sha256', Buffer.from(signingInput), {
    key,
    padding: crypto.constants.RSA_PKCS1_PADDING
  });
  return `${signingInput}.${base64UrlEncode(sig)}`;
}

// ---------- cookie helpers ----------
function setCookie(res, name, value, maxAgeSec = 300) {
  res.append('Set-Cookie',
    `${name}=${value}; HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=${maxAgeSec}`);
}

// ============================================================
// FAYDA
// ============================================================
router.get('/fayda/login', (req, res) => {
  const c = cfg().fayda;
  if (!c.clientId || !c.privateKey || !c.redirectUri) {
    return res.status(500).send('Fayda not configured');
  }

  const verifier  = randomVerifier();
  const challenge = sha256Challenge(verifier);
  const state     = randomState();

  const url = new URL(c.authUrl);
  url.searchParams.set('client_id', c.clientId);
  url.searchParams.set('redirect_uri', c.redirectUri);
  url.searchParams.set('response_type', 'code');
  url.searchParams.set('scope', c.scope);
  url.searchParams.set('state', state);
  url.searchParams.set('code_challenge', challenge);
  url.searchParams.set('code_challenge_method', 'S256');

  setCookie(res, 'fayda_verifier', verifier);
  setCookie(res, 'fayda_state', state);
  res.redirect(url.toString());
});

router.get('/fayda/callback', async (req, res) => {
  const c = cfg().fayda;
  const { code, state } = req.query;

  const savedVerifier = req.cookies?.fayda_verifier;
  const savedState    = req.cookies?.fayda_state;

  if (!code || !savedVerifier) return res.status(400).send('Missing code or verifier');
  if (!state || state !== savedState) return res.status(400).send('State mismatch');

  try {
    const assertion = makeClientAssertion(
      JSON.parse(c.privateKey),
      c.clientId,
      c.tokenUrl
    );

    const body = new URLSearchParams({
      grant_type: 'authorization_code',
      code,
      redirect_uri: c.redirectUri,
      client_id: c.clientId,
      code_verifier: savedVerifier,
      client_assertion_type: 'urn:ietf:params:oauth:client-assertion-type:jwt-bearer',
      client_assertion: assertion
    });

    const tokenRes = await fetch(c.tokenUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body
    });
    const tokens = await tokenRes.json();

    if (!tokenRes.ok || !tokens.access_token) {
      return res.status(400).send('Fayda token exchange failed: ' + JSON.stringify(tokens));
    }

    const userRes = await fetch(c.userInfoUrl, {
      headers: { Authorization: `Bearer ${tokens.access_token}` }
    });
    const profile = await userRes.json();

    const user = {
      id: profile.sub,
      name: profile.name || profile.given_name || 'Fayda User',
      email: profile.email || null,
      phone: profile.phone_number || null,
      provider: 'fayda',
      avatar: null,
      raw: profile
    };

    const session = createSession(cfg().sessionSecret, user);
    res.redirect(`${cfg().appOrigin}/auth/success?token=${session}`);
  } catch (err) {
    console.error('Fayda callback error:', err);
    res.status(500).send('Fayda login failed');
  }
});

// ============================================================
// GOOGLE
// ============================================================
router.get('/google/login', (req, res) => {
  const c = cfg().google;
  if (!c.clientId || !c.redirectUri) {
    return res.status(500).send('Google not configured');
  }

  const verifier  = randomVerifier();
  const challenge = sha256Challenge(verifier);
  const state     = randomState();

  const url = new URL(c.authUrl);
  url.searchParams.set('client_id', c.clientId);
  url.searchParams.set('redirect_uri', c.redirectUri);
  url.searchParams.set('response_type', 'code');
  url.searchParams.set('scope', 'openid email profile');
  url.searchParams.set('state', state);
  url.searchParams.set('code_challenge', challenge);
  url.searchParams.set('code_challenge_method', 'S256');

  setCookie(res, 'google_verifier', verifier);
  setCookie(res, 'google_state', state);
  res.redirect(url.toString());
});

router.get('/google/callback', async (req, res) => {
  const c = cfg().google;
  const { code, state } = req.query;

  const savedVerifier = req.cookies?.google_verifier;
  const savedState    = req.cookies?.google_state;

  if (!code || !savedVerifier) return res.status(400).send('Missing code or verifier');
  if (!state || state !== savedState) return res.status(400).send('State mismatch');

  try {
    const body = new URLSearchParams({
      client_id: c.clientId,
      client_secret: c.clientSecret,
      code,
      code_verifier: savedVerifier,
      grant_type: 'authorization_code',
      redirect_uri: c.redirectUri
    });

    const tokenRes = await fetch(c.tokenUrl, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body
    });
    const tokens = await tokenRes.json();

    if (!tokenRes.ok || !tokens.access_token) {
      return res.status(400).send('Google token exchange failed: ' + JSON.stringify(tokens));
    }

    const userRes = await fetch(c.userInfoUrl, {
      headers: { Authorization: `Bearer ${tokens.access_token}` }
    });
    const profile = await userRes.json();

    const user = {
      id: profile.sub,
      name: profile.name || profile.email,
      email: profile.email,
      phone: null,
      provider: 'google',
      avatar: profile.picture || null,
      raw: profile
    };

    const session = createSession(cfg().sessionSecret, user);
    res.redirect(`${cfg().appOrigin}/auth/success?token=${session}`);
  } catch (err) {
    console.error('Google callback error:', err);
    res.status(500).send('Google login failed');
  }
});

// ============================================================
// /auth/me and /auth/logout
// ============================================================
router.get('/me', (req, res) => {
  const authHeader = req.headers.authorization || '';
  const token = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : null;
  const user = verifySession(cfg().sessionSecret, token);
  if (!user) return res.status(401).json({ error: 'Unauthorized' });
  res.json({ user });
});

router.post('/logout', (req, res) => {
  // Stateless tokens — nothing to invalidate server-side.
  res.json({ ok: true });
});

export default router;