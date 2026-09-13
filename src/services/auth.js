// ============================================================
// src/services/auth.js
// Frontend AuthManager — talks to /auth/* on the Cloudflare Worker
// Same public API as your original so no component breaks
// ============================================================

const AUTH_API = import.meta.env.VITE_AUTH_API || '/auth';
const TOKEN_KEY = 'auth_token';
const USER_KEY  = 'currentUser';

class AuthManager {
  constructor() {
    this.state = {
      currentUser: null,
      isAuthenticated: false,
      isLoading: false
    };
    this.init();
  }

  async init() {
    console.log('🔄 Initializing Auth Manager...');

    // Handle redirect back from /auth/success?token=...
    const params = new URLSearchParams(window.location.search);
    const urlToken = params.get('token');
    if (urlToken) {
      localStorage.setItem(TOKEN_KEY, urlToken);
      // Strip token from URL so it doesn't linger in history
      window.history.replaceState({}, '', window.location.pathname);
    }

    await this.checkAuthState();
    console.log('✅ Auth Manager initialized');
  }

  async checkAuthState() {
    const token = localStorage.getItem(TOKEN_KEY);

    // Clear any leftover fake user from the old version
    if (!token) {
      const legacy = localStorage.getItem(USER_KEY);
      if (legacy) localStorage.removeItem(USER_KEY);
      this.state.currentUser = null;
      this.state.isAuthenticated = false;
      return;
    }

    try {
      this.state.isLoading = true;
      const res = await fetch(`${AUTH_API}/me`, {
        headers: { Authorization: `Bearer ${token}` }
      });

      if (!res.ok) {
        this.signOut();
        return;
      }

      const data = await res.json();
      this.state.currentUser = data.user;
      this.state.isAuthenticated = true;
      localStorage.setItem(USER_KEY, JSON.stringify(data.user));
    } catch (err) {
      console.error('Auth check failed:', err);
      this.state.isAuthenticated = false;
      this.state.currentUser = null;
    } finally {
      this.state.isLoading = false;
    }
  }

  // ----------------------------------------------------------
  // Real OIDC — redirect the browser to the backend
  // ----------------------------------------------------------

  async signInWithFayda() {
    this.state.isLoading = true;
    window.location.href = `${AUTH_API}/fayda/login`;
  }

  async signInWithGoogle() {
    this.state.isLoading = true;
    window.location.href = `${AUTH_API}/google/login`;
  }

  // Aliases so existing UI buttons keep working
  async signInWithGitHub() {
    return this.signInWithFayda();
  }

  async signInWithMicrosoft() {
    this.showMessage('Microsoft sign-in not configured yet.', 'info');
  }

  async handleEmailSignIn(email) {
    this.showMessage('Email sign-in not configured yet.', 'info');
  }

  // ----------------------------------------------------------
  // Sign out
  // ----------------------------------------------------------

  signOut() {
    const token = localStorage.getItem(TOKEN_KEY);

    this.state.currentUser = null;
    this.state.isAuthenticated = false;
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);

    // Best-effort backend logout
    if (token) {
      fetch(`${AUTH_API}/logout`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` }
      }).catch(() => {});
    }

    this.showMessage('You have been signed out.', 'info');
  }

  // ----------------------------------------------------------
  // Helpers — same public API as before
  // ----------------------------------------------------------

  getToken() {
    return localStorage.getItem(TOKEN_KEY);
  }

  authHeaders() {
    const t = this.getToken();
    return t ? { Authorization: `Bearer ${t}` } : {};
  }

  showMessage(message, type = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast-message toast-${type}`;
    toast.textContent = message;

    Object.assign(toast.style, {
      position: 'fixed',
      top: '80px',
      right: '20px',
      background: type === 'success' ? '#4CAF50'
                : type === 'error'   ? '#f44336'
                : '#2196F3',
      color: 'white',
      padding: '12px 20px',
      borderRadius: '8px',
      zIndex: '1003'
    });

    document.body.appendChild(toast);
    setTimeout(() => {
      if (toast.parentNode) toast.parentNode.removeChild(toast);
    }, 3000);
  }

  getCurrentUser()     { return this.state.currentUser; }
  getIsAuthenticated() { return this.state.isAuthenticated; }
  getIsLoading()       { return this.state.isLoading; }
}

export const auth = new AuthManager();