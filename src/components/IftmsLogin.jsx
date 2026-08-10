// components/IfmtsLogin.jsx
import { useState, useEffect, useRef } from 'preact/hooks';

export function IfmtsLogin({ onLoginSuccess, onClose }) {
  const [status, setStatus] = useState('idle'); // idle, loading, success, error
  const [error, setError] = useState(null);
  const popupRef = useRef(null);
  const checkInterval = useRef(null);

  useEffect(() => {
    // Check if already logged in
    checkExistingSession();

    return () => {
      // Cleanup
      if (checkInterval.current) {
        clearInterval(checkInterval.current);
      }
      if (popupRef.current && !popupRef.current.closed) {
        popupRef.current.close();
      }
    };
  }, []);

  const checkExistingSession = async () => {
    try {
      console.log('🔍 Checking existing IFMTS session...');
      const response = await fetch('/api-auth/auth/me', {
        credentials: 'include',
        headers: {
          'Accept': 'application/json',
        }
      });
      
      if (response.ok) {
        const data = await response.json();
        console.log('✅ Already logged in:', data);
        setStatus('success');
        onLoginSuccess();
        return true;
      }
    } catch (error) {
      console.log('ℹ️ No existing session');
    }
    return false;
  };

  const openLoginPopup = () => {
    setStatus('loading');
    setError(null);

    // Open the IFMTS login page in a popup
    const width = 500;
    const height = 650;
    const left = (window.screen.width - width) / 2;
    const top = (window.screen.height - height) / 2;

    const popup = window.open(
      'https://iftms.motl.gov.et/auth/sign-in',
      'IFMTS Login',
      `width=${width},height=${height},left=${left},top=${top},menubar=no,toolbar=no,location=yes,status=no`
    );

    if (!popup) {
      setError('Popup blocked! Please allow popups for this site.');
      setStatus('error');
      return;
    }

    popupRef.current = popup;
    console.log('📱 IFMTS login popup opened');

    // Monitor popup for login completion
    checkInterval.current = setInterval(() => {
      try {
        // Check if popup was closed
        if (popup.closed) {
          clearInterval(checkInterval.current);
          console.log('📱 Popup closed');
          
          // Check if login was successful (session exists)
          checkExistingSession().then((loggedIn) => {
            if (loggedIn) {
              setStatus('success');
              onLoginSuccess();
            } else {
              setStatus('idle');
            }
          });
          return;
        }

        // Try to check if popup redirected to dashboard
        try {
          const popupUrl = popup.location.href;
          console.log('📍 Popup URL:', popupUrl);
          
          if (popupUrl.includes('/dashboard')) {
            console.log('✅ Login successful! Redirected to dashboard');
            clearInterval(checkInterval.current);
            setStatus('success');
            popup.close();
            
            // Wait a moment for session to be set
            setTimeout(() => {
              onLoginSuccess();
            }, 1000);
          }
        } catch (e) {
          // Cross-origin error - expected, ignore
        }
      } catch (e) {
        // Ignore errors
      }
    }, 800);

    // Timeout after 5 minutes
    setTimeout(() => {
      if (checkInterval.current) {
        clearInterval(checkInterval.current);
        if (popup && !popup.closed) {
          popup.close();
        }
        setError('Login timeout. Please try again.');
        setStatus('error');
      }
    }, 300000);
  };

  const handleRetry = () => {
    setStatus('idle');
    setError(null);
  };

  if (status === 'success') {
    return (
      <div class="ifmts-login-modal">
        <div class="ifmts-login-overlay"></div>
        <div class="ifmts-login-container">
          <div class="ifmts-login-header">
            <h3>✅ IFMTS Login</h3>
            <button class="close-btn" onClick={onClose}>×</button>
          </div>
          <div class="ifmts-login-body">
            <div class="login-success">
              ✅ Login successful! You are now connected to IFMTS.
            </div>
            <button class="btn-primary" onClick={onClose}>
              Continue
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div class="ifmts-login-modal">
      <div class="ifmts-login-overlay" onClick={onClose}></div>
      <div class="ifmts-login-container">
        <div class="ifmts-login-header">
          <h3>🔐 IFMTS Login</h3>
          <button class="close-btn" onClick={onClose}>×</button>
        </div>
        
        <div class="ifmts-login-body">
          <div class="login-info">
            <p>To sync your data with IFMTS, please log in to your IFMTS account.</p>
            <ul>
              <li>✓ A popup window will open</li>
              <li>✓ Enter your IFMTS credentials</li>
              <li>✓ The popup will close automatically after login</li>
            </ul>
          </div>

          {error && (
            <div class="login-error">
              ❌ {error}
            </div>
          )}

          {status === 'idle' && (
            <button 
              class="login-btn btn-primary" 
              onClick={openLoginPopup}
            >
              🔐 Login to IFMTS
            </button>
          )}

          {status === 'loading' && (
            <div class="login-loading">
              <div class="spinner"></div>
              <p>Opening IFMTS login...</p>
              <p class="hint">Please complete login in the popup window.</p>
              <button 
                class="cancel-btn btn-secondary" 
                onClick={() => {
                  if (popupRef.current && !popupRef.current.closed) {
                    popupRef.current.close();
                  }
                  setStatus('idle');
                }}
              >
                Cancel
              </button>
            </div>
          )}

          {status === 'error' && (
            <div class="login-error-actions">
              <button class="btn-primary" onClick={handleRetry}>
                🔄 Retry
              </button>
              <button class="btn-secondary" onClick={onClose}>
                Cancel
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}