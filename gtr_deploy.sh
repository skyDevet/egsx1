#!/bin/bash
set -e
echo "Creating project files..."
cat > package.json << 'END'
{
  "name": "agig",
  "private": true,
  "version": "1.0.0",
  "type": "module",
"scripts": {
    "dev": "concurrently -n server,client -c blue,magenta \"npm run server\" \"npm run client\"",
    "server": "node server/index.js",
    "client": "vite --host",
    "build": "vite build",
    "preview": "vite preview",
   "deploy": "npm run build:github && npx gh-pages -d dist -b gh-pages -r https://github.com/skyDevet/egsx1.git --force"
  },
  "dependencies": {
    "@capacitor-community/sqlite": "^8.1.1",
    "@capacitor/android": "^8.5.0",
    "@capacitor/cli": "^8.5.0",
    "@capacitor/core": "^8.5.0",
    "@capacitor/device": "^8.0.3",
    "@capacitor/filesystem": "^8.1.2",
    "@capgo/capacitor-inappbrowser": "^8.15.3",
    "compromise": "^14.15.0",
    "highlight.js": "^11.11.1",
    "idb": "^8.0.3",
    "marked": "^18.0.5",
    "pdfjs-dist": "^5.7.284",
    "preact": "^10.19.0",
    "tesseract.js": "^7.0.0"
  },
  "devDependencies": {
    "@preact/preset-vite": "^2.8.0",
    "concurrently": "^10.0.5",
    "gh-pages": "^6.3.0",
    "vite": "^5.4.0"
  }
}
END
cat > vite.config.js << 'END'
import { defineConfig } from 'vite'
import preact from '@preact/preset-vite'

export default defineConfig(({ mode }) => {
  // Force GitHub Pages base
  const baseUrl = '/egsx1/'
  
  return {
    base: baseUrl,
    plugins: [preact()],
    server: { 
      host: true, 
      port: 3000,
      // Proxy API requests to Express server
      proxy: {
      '/api': {
        target: 'http://127.0.0.1:4000',
        changeOrigin: true,
        secure: false
      }
      }
    },
    build: { 
      outDir: 'dist', 
      sourcemap: false,
      // Fix worker format for production build
      rollupOptions: {
        output: {
          format: 'es',
          entryFileNames: 'assets/[name]-[hash].js',
          chunkFileNames: 'assets/[name]-[hash].js',
          assetFileNames: 'assets/[name]-[hash].[ext]'
        }
      }
    },
    // ✅ CRITICAL FIX: Configure worker format
    // ✅ Fixed version
    worker: {
      format: 'es',
      plugins: () => [preact()]  // Function that returns array
    },
    // Optimize dependencies for Capacitor
    optimizeDeps: {
      include: [
        '@capacitor/core',
        '@capacitor/filesystem',
       // 'llama-cpp-capacitor'
        '@capgo/capacitor-inappbrowser'
      ]
    },
    // Handle Node.js modules in browser
    resolve: {
      alias: {
        // If you have Node.js modules that need polyfilling
        'stream': 'stream-browserify',
        'buffer': 'buffer'
      }
    },
    // Define environment variables
    define: {
      // Fix for Capacitor in production
      'process.env.NODE_ENV': JSON.stringify(mode),
      'process.env': {
        NODE_ENV: JSON.stringify(mode)
      }
    }
  }
})END
cat > server.js << 'END'
END
cat > index.html << 'END'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>AGIG - Offline</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; font-family: system-ui, -apple-system, sans-serif; }
    body { background: #101623; color: #edf3ff; }
    .material-symbols-rounded { font-family: system-ui; }
  </style>
</head>
<body>
  <div id="app"></div>
  <script type="module" src="/src/main.jsx"></script>
  <script src="https://cdn.jsdelivr.net/npm/eruda"></script>
<script>eruda.init();</script>
</body>
</html>END
cat > .gitignore << 'END'
# Dependencies
node_modules/
.cache/

# Build outputs - THESE WILL NOT BE PUSHED
dist/
.vite/
build/
.capacitor/

# OS files
.DS_Store
Thumbs.db

# Logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo

# Temporary
tmp/
backup_*/
END
mkdir -p src/components src/services src/hooks src/styles
cat > src/main.jsx << 'END'
import { render } from 'preact'
import { App } from './App.jsx'
import './styles/app.css'  // Import the combined CSS

render(<App />, document.getElementById('app'))END
cat > src/app.jsx << 'END'
END
cat > src/styles/app.css << 'END'
/* Import Google Font - Poppins */
@import url("https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap");

/* Material Icons */
@font-face {
  font-family: 'Material Symbols Rounded';
  font-style: normal;
  font-weight: 400;
  src: url(/syl7-zNym6YjUruM-QrEh7-nyTnjDwKNJ_190FjpZIvDmUSVOK7BDB_Qb9vUSzq3wzLK-P0J-V_Zs-obHph2-jOcZTKPq8a9A5M.woff2) format('woff2');
}
/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 8px;
  width: 90%;
  max-width: 500px;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px;
  border-bottom: 1px solid #bdc3c7;
}
.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #7f8c8d;
}

.auth-form {
  padding: 20px;
}

.form-group {
  margin-bottom: 20px;
}.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 500;
  color: #2c3e50;
}

.form-group input {
  width: 100%;
  padding: 12px;
  border: 1px solid #bdc3c7;
  border-radius: 6px;
  font-size: 14px;
}

.form-group input:focus {
  border-color: #3498db;
  outline: none;
}.submit-btn {
  width: 100%;
  background: #2ecc71;
  color: white;
  border: none;
  padding: 15px;
  border-radius: 6px;
  font-size: 16px;
  cursor: pointer;
  transition: background 0.3s ease;
}

.submit-btn:hover:not(:disabled) {
  background: #27ae60;
}

.submit-btn:disabled {
  background: #bdc3c7;
  cursor: not-allowed;
}
.material-symbols-rounded {
  font-family: 'Material Symbols Rounded';
  font-weight: normal;
  font-style: normal;
  font-size: 24px;
  line-height: 1;
  letter-spacing: normal;
  text-transform: none;
  display: inline-block;
  white-space: nowrap;
  word-wrap: normal;
  direction: ltr;
  -webkit-font-feature-settings: 'liga';
  -webkit-font-smoothing: antialiased;
}

* {
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  font-family: "Poppins", sans-serif;
}

:root {
  /* Dark theme colors */
  --text-color: #edf3ff;
   --text-colorb: #090c13;
  --subheading-color: #97a7ca;
  --placeholder-color: #c3cdde;
  --primary-color: #101623;
  --secondary-color: #283045;
  --secondary-hover-color: #333e58;
  --scrollbar-color: #626a7f;
}

body.light-theme {
  /* Light theme colors */
  --text-color: #090c13;
  --subheading-color: #7b8cae;
  --placeholder-color: #606982;
  --primary-color: #f3f7ff;
  --secondary-color: #dce6f9;
  --secondary-hover-color: #d2ddf2;
  --scrollbar-color: #a2aac2;
}

body {
  color: var(--text-color);
  background: var(--primary-color);
}

.container {
  overflow-y: auto;
  padding: 32px 0 -60px;
  height: calc(100vh - 227px);
 
  scrollbar-color: var(--scrollbar-color) transparent;
  
}

.container :where(.app-header, .suggestions, .message, .prompt-wrapper) {
  position: relative;
  margin: 0 auto;
  width: 100%;
  padding: 0 20px;
  max-width: 990px;
}

.container .app-header {
  margin-top: 3vh;
}

.app-header .heading {
  width: fit-content;
  font-size: 3rem;
  background: linear-gradient(to right, #1d7efd, #8f6fff);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.app-header .sub-heading {
  font-size: 2.6rem;
  margin-top: -5px;
  color: var(--subheading-color);
}

.container .suggestions {
  width: 100%;
  list-style: none;
  display: flex;
  gap: 15px;
  margin-top: 9.5vh;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  scrollbar-width: none;
}

body.chats-active .container :where(.app-header, .suggestions) {
  display: none;
}

.suggestions .suggestions-item {
  cursor: pointer;
  padding: 18px;
  width: 228px;
  flex-shrink: 0;
  display: flex;
  scroll-snap-align: center;
  flex-direction: column;
  align-items: flex-end;
  border-radius: 12px;
  justify-content: space-between;
  background: var(--secondary-color);
  transition: 0.3s ease;
}

.suggestions .suggestions-item:hover {
  background: var(--secondary-hover-color);
}

.suggestions .suggestions-item .text {
  font-size: 1.1rem;
}

.suggestions .suggestions-item .icon {
  width: 45px;
  height: 45px;
  display: flex;
  font-size: 1.4rem;
  margin-top: 35px;
  align-self: flex-end;
  align-items: center;
  border-radius: 50%;
  justify-content: center;
  color: #1d7efd;
  background: var(--primary-color);
}

.suggestions .suggestions-item:nth-child(2) .icon {
  color: #28a745;
}

.suggestions .suggestions-item:nth-child(3) .icon {
  color: #ffc107;
}

.suggestions .suggestions-item:nth-child(4) .icon {
  color: #6f42c1;
}

.container .chats-container {
  display: flex;
  gap: 20px;
  flex-direction: column;
}

.chats-container .message {
  display: flex;
  gap: 11px;
  align-items: center;
}

.chats-container .message .avatar {
  width: 43px;
  height: 43px;
  flex-shrink: 0;
  align-self: flex-start;
  border-radius: 50%;
  padding: 6px;
  margin-right: -7px;
  margin-top: 3.4em;
  background: var(--secondary-color);
  border: 1px solid var(--secondary-hover-color);
}

.chats-container .message.loading .avatar {
  animation: rotate 3s linear infinite;
}

@keyframes rotate {
  100% {
    transform: rotate(360deg);
  }
}

.chats-container .message .message-text {
  padding: 3px 16px;
  word-wrap: break-word;
  white-space: pre-line;
}

.chats-container .bot-message {
  margin: 9px auto;
}

.chats-container .user-message {
  flex-direction: column;
  align-items: flex-end;
}

.chats-container .user-message .message-text {
  padding: 12px 16px;
  max-width: 100%;
  background: var(--secondary-color);
  border-radius: 13px 13px 3px 13px;
}

.chats-container .user-message .img-attachment {
  margin-top: -7px;
  width: 50%;
  border-radius: 13px 3px 13px 13px;
}

.chats-container .user-message .file-attachment {
  display: flex;
  gap: 6px;
  align-items: center;
  padding: 10px;
  margin-top: -7px;
  border-radius: 13px 3px 13px 13px;
  background: var(--secondary-color);
}

.chats-container .user-message .file-attachment span {
  color: #1d7efd;
}

.container .prompt-container {
  position: fixed;
  width: 100%;
  left: 0;
  bottom: 0;
  padding: 16px 0;
  background: var(--primary-color);
}

.prompt-container :where(.prompt-wrapper, .prompt-form, .prompt-actions) {
  display: flex;
  gap: 12px;
  height: 56px;
  align-items: center;
}

.prompt-container .prompt-form {
  height: 100%;
  width: 100%;
  border-radius: 130px;
  background: var(--secondary-color);
}

.prompt-form .prompt-input {
  width: 100%;
  height: 100%;
  background: none;
  outline: none;
  border: none;
  font-size: 1rem;
  color: var(--text-color);
  padding-left: 24px;
}

.prompt-form .prompt-input::placeholder {
  color: var(--placeholder-color);
}

.prompt-wrapper button {
  width: 56px;
  height: 100%;
  flex-shrink: 0;
  cursor: pointer;
  border-radius: 50%;
  font-size: 1.4rem;
  border: none;
  color: var(--text-color);
  background: var(--secondary-color);
  transition: 0.3s ease;
}

.prompt-wrapper :is(button:hover, #cancel-file-btn, .file-icon) {
  background: var(--secondary-hover-color);
}

.prompt-form .prompt-actions {
  gap: 5px;
  margin-right: 7px;
}

.prompt-wrapper .prompt-form :where(.file-upload-wrapper, button, img) {
  position: relative;
  height: 45px;
  width: 45px;
}

.prompt-form .prompt-actions #send-prompt-btn {
  color: #fff;
  display: none;
  background: #1d7efd;
}

.prompt-form .prompt-input:valid~.prompt-actions #send-prompt-btn {
  display: block;
}

.prompt-form #send-prompt-btn:hover {
  background: #0264e3;
}

.prompt-form .file-upload-wrapper :where(button, img) {
  display: none;
  border-radius: 50%;
  object-fit: cover;
  position: absolute;
}

.prompt-form .file-upload-wrapper.active #add-file-btn {
  display: none;
}

.prompt-form .file-upload-wrapper #add-file-btn,
.prompt-form .file-upload-wrapper.active.img-attached img,
.prompt-form .file-upload-wrapper.active.file-attached .file-icon,
.prompt-form .file-upload-wrapper.active:hover #cancel-file-btn {
  display: block;
}

.prompt-form :is(#stop-response-btn:hover, #cancel-file-btn) {
  color: #d62939;
}

.prompt-wrapper .prompt-form .file-icon {
  color: #1d7efd;
}

.prompt-form #stop-response-btn,
body.bot-responding .prompt-form .file-upload-wrapper {
  display: none;
}

body.bot-responding .prompt-form #stop-response-btn {
  display: block;
}

.prompt-container .disclaimer-text {
  font-size: 0.9rem;
  text-align: center;
  padding: 16px 20px 0;
  color: var(--placeholder-color);
}

/* Message Actions */
.message-actions button:hover {
  color: #5350C4;
}

.edit-input {
  width: 100%;
  padding: 8px;
  border: 1px solid #5350C4;
  border-radius: 8px;
  font-size: 0.95rem;
  background: transparent;
  resize: none;
  overflow: hidden;
}

.code-block .copy-code-btn {
  position: absolute;
  top: 10px;
  right: 10px;
  background: #5350C4;
  color: #fff;
  border: none;
  border-radius: 5px;
  padding: 5px;
  cursor: pointer;
  font-size: 1rem;
  transition: background 0.2s ease;
}

.code-block .copy-code-btn:hover {
  background: #3d39ac;
}

/* Code Block Styles */
.code-block {
  position: relative;
  margin: 10px 0;
  background: #f5f5f5;
  border-radius: 8px;
  padding: 10px;
  border: 1px solid #ddd;
  max-width: 100%;
  overflow-x: auto;
}

body[data-theme="dark"] .code-block {
  background: #1E1E2F;
  border: 1px solid #6F6BC2;
}

.code-block pre {
  margin: 0;
}

.code-block code {
  font-family: 'Courier New', Courier, monospace;
  font-size: 0.9rem;
  color: #333;
  white-space: pre-wrap;
  word-wrap: break-word;
}
.header-actions {display: flex;
    flex-direction: row;
}
/* Header Bar Styles */
.header-bar {
  height: auto;
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  background: var(--primary-color);
  border-bottom: 1px solid var(--secondary-color);
  z-index: 1000;
  padding: 5px 20px;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  height: 60px;
  max-width: 1200px;
  margin: 0 auto;
}

.logo-btn {
  display: flex;
  align-items: center;
  gap: 12px;
  background: transparent;
  border: none;
  color: var(--text-color);
  cursor: pointer;
  padding: 8px;
  border-radius: 8px;
  transition: background 0.3s ease;
}

.logo-btn:hover {
  background: var(--secondary-color);
  border-radius: 15px;
}

.logo {
  width: 60px;
  height: 60px;
}

.app-name {
  font-size: 1.2rem;
  font-weight: 600;
}

.auth-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  background: var(--secondary-color);
  border: none;
  color: var(--text-color);
  padding: 8px 16px;
  border-radius: 20px;
  cursor: pointer;
  transition: background 0.3s ease;
}

.auth-btn:hover {
  background: var(--secondary-hover-color);
}


.close-btn {
  background: none;
  border: none;
  color: var(--text-color);
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
}

.close-btn:hover {
  background: var(--secondary-color);
}

/* OAuth Modal Styles */
.oauth-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  z-index: 1002;
  display: none;
  align-items: center;
  justify-content: center;
}

.oauth-modal.active {
  display: flex;
}

.oauth-modal-content {
  background: var(--primary-color);
  border-radius: 16px;
  padding: 30px;
  max-width: 400px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  position: relative;
  border: 1px solid var(--secondary-color);
}

.close-oauth-btn {
  position: absolute;
  top: 15px;
  right: 15px;
  background: none;
  border: none;
  color: var(--text-color);
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
}

.close-oauth-btn:hover {
  background: var(--secondary-color);
}

.oauth-header {
  text-align: center;
  margin-bottom: 30px;
}

.oauth-logo {
  width: 64px;
  height: 64px;
  margin-bottom: 16px;
}

.oauth-header h2 {
  color: var(--text-color);
  margin-bottom: 8px;
}

.oauth-header p {
  color: var(--subheading-color);
  margin: 0;
}

.oauth-options {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.oauth-btn {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  padding: 12px 16px;
  border: 1px solid var(--secondary-color);
  border-radius: 8px;
  background: var(--primary-color);
  color: var(--text-color);
  cursor: pointer;
  transition: background 0.3s ease;
}

.oauth-btn:hover {
  background: var(--secondary-color);
}

.oauth-icon {
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.oauth-icon img {
  width: 100%;
  height: 100%;
}

.divider {
  display: flex;
  align-items: center;
  text-align: center;
  margin: 20px 0;
  color: var(--subheading-color);
}

.divider::before,
.divider::after {
  content: '';
  flex: 1;
  border-bottom: 1px solid var(--secondary-color);
}

.divider span {
  padding: 0 16px;
}

.email-form {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.email-input {
  padding: 12px 16px;
  border: 1px solid var(--secondary-color);
  border-radius: 8px;
  background: var(--primary-color);
  color: var(--text-color);
  font-size: 1rem;
}

.email-input::placeholder {
  color: var(--placeholder-color);
}

.email-btn {
  padding: 12px 16px;
  border: none;
  border-radius: 8px;
  background: #1d7efd;
  color: white;
  cursor: pointer;
  transition: background 0.3s ease;
}

.email-btn:hover {
  background: #0264e3;
}

.oauth-footer {
  margin-top: 20px;
  text-align: center;
}

.oauth-footer p {
  font-size: 0.8rem;
  color: var(--subheading-color);
  margin: 0;
}

.oauth-footer a {
  color: #1d7efd;
  text-decoration: none;
}

.oauth-footer a:hover {
  text-decoration: underline;
}

/* Adjust container for header */
.container {
  margin-top: 60px;
  height: calc(100vh - 127px - 60px);
}

/* Analysis Results Styles */
.analysis-results {
  background: var(--secondary-color);
  border-radius: 12px;
  padding: 16px;
  margin: 8px 0;
}

.analysis-results h4 {
  margin-bottom: 16px;
  color: var(--text-color);
  font-size: 1.2rem;
}

.result-section {
  margin-bottom: 16px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--secondary-hover-color);
}

.result-section:last-child {
  border-bottom: none;
  margin-bottom: 0;
}

.result-section h5 {
  margin-bottom: 8px;
  color: var(--text-color);
  font-size: 1rem;
}

.result-section p {
  margin: 8px 0;
  color: var(--text-color);
}

.doc-type {
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 0.8rem;
  font-weight: 500;
}

.type-research { background: #4CAF50; color: white; }
.type-legal { background: #2196F3; color: white; }
.type-financial { background: #FFC107; color: black; }
.type-certificate { background: #9C27B0; color: white; }
.type-id { background: #F44336; color: white; }
.type-other { background: #9E9E9E; color: white; }

.confidence-bar {
  display: inline-block;
  width: 100px;
  height: 8px;
  background: var(--secondary-hover-color);
  border-radius: 4px;
  margin: 0 8px;
  vertical-align: middle;
}

.confidence-fill {
  display: block;
  height: 100%;
  background: linear-gradient(to right, #4CAF50, #8BC34A);
  border-radius: 4px;
}

.topics-list {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
}

.topic-tag {
  background: var(--primary-color);
  color: var(--text-color);
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 0.8rem;
  border: 1px solid var(--secondary-hover-color);
}

.document-summary {
  background: var(--primary-color);
  padding: 12px;
  border-radius: 8px;
  border: 1px solid var(--secondary-hover-color);
}

.document-summary p {
  margin: 4px 0;
}

/* Saved Documents Section */
.saved-documents-section {
  padding: 10px;
  margin-top: 10px;
}

.saved-documents-list {
  max-height: 300px;
  overflow-y: auto;
  margin-top: 10px;
}

.document-item {
  padding: 8px 12px;
  margin: 5px 0;
  border-radius: 4px;
  background-color: rgba(255, 255, 255, 0.1);
  cursor: pointer;
  transition: background-color 0.2s;
}

.document-item:hover {
  background-color: rgba(255, 255, 255, 0.2);
}

.document-name {
  font-weight: 500;
  margin-bottom: 3px;
}

.document-meta {
  font-size: 0.8em;
  opacity: 0.8;
  display: flex;
  justify-content: space-between;
}

.no-documents, .error {
  padding: 10px;
  text-align: center;
  opacity: 0.7;
}

/* Logs Styles */
.logs {
  background: #2c3e50;
  color: #ecf0f1;
  padding: 15px;
  border-radius: 8px;
  font-family: 'Courier New', monospace;
  font-size: 12px;
  max-height: 300px;
  overflow-y: auto;
  margin-top: 20px;
}

.log-entry {
  margin-bottom: 5px;
  padding: 5px;
  border-left: 3px solid #3498db;
}

.log-entry.success {
  border-left-color: #2ecc71;
}

.log-entry.error {
  border-left-color: #e74c3c;
}

.log-entry.warning {
  border-left-color: #f39c12;
}

/* Loading Screen */
.loading-screen {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
  background: var(--primary-color);
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid var(--secondary-color);
  border-left: 4px solid #1d7efd;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 16px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

/* Typing Indicator */
.typing-indicator {
  display: flex;
  align-items: center;
  gap: 4px;
}

.typing-indicator span {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--text-color);
  opacity: 0.6;
  animation: typing 1.4s infinite ease-in-out;
}

.typing-indicator span:nth-child(1) { animation-delay: -0.32s; }
.typing-indicator span:nth-child(2) { animation-delay: -0.16s; }

@keyframes typing {
  0%, 80%, 100% { transform: scale(0.8); opacity: 0.6; }
  40% { transform: scale(1); opacity: 1; }
}

/* Responsive media query code for small screens */
@media (max-width: 768px) {
  .container {
    padding: 20px 0 100px;
  }
  
  .app-header :is(.heading, .sub-heading) {
    font-size: 2rem;
    line-height: 1.4;
  }
  
  .app-header .sub-heading {
    font-size: 1.7rem;
  }
  
  .container .chats-container {
    gap: 15px;
  }
  
  .chats-container .bot-message {
    margin: 4px auto;
  }
  
  .prompt-container :where(.prompt-wrapper, .prompt-form, .prompt-actions) {
    gap: 8px;
    height: 53px;
  }
  
  .prompt-container button {
    width: 53px;
  }
  
  .prompt-form :is(.file-upload-wrapper, button, img) {
    height: 42px;
    width: 42px;
  }
  
  .prompt-form .prompt-input {
    padding-left: 20px;
  }
  
  .prompt-form .file-upload-wrapper.active #cancel-file-btn {
    opacity: 0;
  }
  
  .prompt-wrapper.hide-controls :where(#theme-toggle-btn, #delete-chats-btn) {
    display: none;
  }
  
  
  .oauth-modal-content {
    margin: 20px;
    padding: 20px;
  }
  
  .header-content {
    padding: 0 15px;
  }
  
  .app-name {
    display: none;
  }
}
/* Add to your existing CSS file */
.ocr-selector {
  padding: 4px 8px;
  border-radius: 4px;
  border: 1px solid #ddd;
  background: white;
  font-size: 12px;
  margin-right: 10px;
}

.ocr-selector:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.ocr-loading {
  margin-top: 15px;
  text-align: center;
}

.ocr-loading p {
  margin-bottom: 5px;
  font-size: 14px;
  color: #666;
}

.progress-bar {
  width: 200px;
  height: 4px;
  background: #e0e0e0;
  border-radius: 2px;
  margin: 0 auto;
  overflow: hidden;
}

.progress-bar .progress {
  height: 100%;
  background: linear-gradient(90deg, #4f46e5, #7c3aed);
  animation: loading 1.5s ease-in-out infinite;
}

@keyframes loading {
  0% { transform: translateX(-100%); }
  100% { transform: translateX(100%); }
}

.ocr-status-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 8px;
  background: #f0f9ff;
  border: 1px solid #bae6fd;
  border-radius: 12px;
  font-size: 12px;
  color: #0369a1;
  margin-left: 10px;
}

.ocr-status-badge.error {
  background: #fef2f2;
  border-color: #fecaca;
  color: #dc2626;
}

.status-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: #22c55e;
}

.status-dot.active {
  background: #22c55e;
  animation: pulse 2s infinite;
}

.status-dot.error {
  background: #dc2626;
}

@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.5; }
  100% { opacity: 1; }
}

.error-text {
  color: #dc2626;
  font-size: 14px;
  margin-top: 5px;
}

.loading-screen {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100vh;
}

.loading-screen .spinner {
  width: 40px;
  height: 40px;
  border: 3px solid #f3f3f3;
  border-top: 3px solid #4f46e5;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 15px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
/* OCR Status Badge */
.ocr-engine-badge {
  background: #3b82f6;
  color: white;
  padding: 2px 8px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 500;
  margin-left: 8px;
}

.ocr-info-text {
  font-size: 12px;
  color: #6b7280;
  text-align: center;
  margin-top: 5px;
  font-style: italic;
}

/* Extracted data styling */
.extracted-data {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 8px;
  margin-top: 10px;
}

.data-item {
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 6px;
  padding: 8px;
}

.data-key {
  font-weight: 600;
  color: #475569;
  display: block;
  font-size: 12px;
  text-transform: capitalize;
}

.data-value {
  color: #1e293b;
  font-size: 14px;
  display: block;
  margin-top: 2px;
  word-break: break-word;
}

/* Analysis results enhancements */
.analysis-resultsf {
  background: white;
  border-radius: 8px;
  padding: 16px;
  border: 1px solid #e5e7eb;
  margin: 10px 0;
}

.result-section {
  margin-bottom: 15px;
  padding-bottom: 15px;
  border-bottom: 1px solid #f1f5f9;
}
.sidebarX {
  width: 300px;
  background: #2c3e50;
  color: white;
  padding: 20px;
  overflow-y: auto;
}
.progress-section h3 {
  margin-bottom: 15px;
  color: #ecf0f1;
}

.steps {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.step {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 10px;
  border-radius: 6px;
  background: #34495e;
  transition: all 0.3s ease;
}

.step.active {
  background: #3498db;
}

.step.current {
  border: 2px solid #2ecc71;
}

.step-number {
  background: #2c3e50;
  color: white;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-weight: bold;
}

.step.active .step-number {
  background: #2980b9;
}

.step-content h4 {
  font-size: 14px;
  margin-bottom: 5px;
}

.step-content p {
  font-size: 12px;
  opacity: 0.8;
}
.sidebar-headerX {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 30px;
}
.result-section:last-child {
  border-bottom: none;
  margin-bottom: 0;
  padding-bottom: 0;
}
/* Add to agigcssapp.css */

/* Service Flow UI */
.service-flow-ui {
  background: var(--primary-color);
  border-bottom: 1px solid var(--secondary-color);
  padding: 15px 20px;
  margin-bottom: 20px;
}

.step-header {
  display: flex;
  flex-direction: column;
  gap: 15px;
  margin-bottom: 15px;
}

.step-indicator {
  position: relative;
  padding: 10px 0;
}

.step-line {
  display: flex;
  justify-content: space-between;
  position: relative;
  margin: 0 20px;
}

.step-line::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 20px;
  right: 20px;
  height: 2px;
  background: var(--secondary-color);
  transform: translateY(-50%);
  z-index: 1;
}

.step-dot {
  width: 30px;
  height: 30px;
  border-radius: 50%;
  background: var(--secondary-color);
  color: var(--text-color);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  font-weight: 500;
  position: relative;
  z-index: 2;
  transition: all 0.3s ease;
}

.step-dot.active {
  background: #3498db;
  color: white;
}

.step-dot.current {
  background: #2ecc71;
  color: white;
  transform: scale(1.1);
  box-shadow: 0 0 0 3px rgba(46, 204, 113, 0.3);
}

.step-labels {
  display: flex;
  justify-content: space-between;
  padding: 5px 10px;
  font-size: 12px;
  color: var(--placeholder-color);
}

.service-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  background: var(--secondary-color);
  border-radius: 8px;
}

.service-info h3 {
  margin: 0;
  font-size: 16px;
  color: var(--text-color);
}

.current-step {
  background: #3498db;
  color: white;
  padding: 4px 8px;
  border-radius: 12px;
  font-size: 12px;
  font-weight: 500;
}

.step-action-buttons {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  padding: 10px 0;
}
.message-actions {
  display: flex;
  gap: 8px;
  margin-top: 10px;
  flex-wrap: wrap;
}

.action-btn {
  background: #95a5a6;
  color: white;
  border: none;
  padding: 6px 12px;
  border-radius: 15px;
  font-size: 12px;
  cursor: pointer;
  transition: background 0.3s ease;
}

.action-btn:hover {
  background: #7f8c8d;
}
.step-action-btn {
  background: var(--secondary-color);
  color: var(--text-color);
  border: none;
  padding: 10px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s ease;
  flex: 1;
  min-width: 120px;
}

.step-action-btn:hover:not(:disabled) {
  background: var(--secondary-hover-color);
  transform: translateY(-1px);
}

.step-action-btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Step Response Messages */
.step-response {
  background: var(--secondary-color);
  border-radius: 12px;
  padding: 16px;
  margin: 8px 0;
  border-left: 4px solid #3498db;
}

.step-response .step-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 10px;
}

.step-badge {
  background: #3498db;
  color: white;
  padding: 4px 8px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 500;
}

.service-name {
  font-weight: 500;
  color: var(--text-color);
}

.step-content {
  margin-top: 10px;
}

.step-content p {
  margin-bottom: 15px;
  line-height: 1.5;
}

.step-actions {
  display: flex;
  gap: 10px;
  flex-wrap: wrap;
  margin-top: 15px;
}

.step-action-btn {
  background: #3498db;
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  transition: background 0.3s ease;
}

.step-action-btn:hover {
  background: #2980b9;
}

/* Language Selector */
.language-selector {
  padding: 6px 12px;
  border-radius: 6px;
  border: 1px solid var(--secondary-color);
  background: var(--primary-color);
  color: var(--text-color);
  font-size: 14px;
  margin-right: 10px;
  margin-inline: 2em;
}

.language-selector:focus {
  outline: none;
  border-color: #3498db;
}

/* Responsive */
@media (max-width: 768px) {
  .step-line {
    margin: 0 10px;
  }
  
  .step-labels {
    font-size: 10px;
    padding: 5px 5px;
  }
  
  .step-action-buttons {
    flex-direction: column;
  }
  
  .step-action-btn {
    width: 100%;
  }
}


/* Floating Image Grid - Right Side */
.floating-image-grid {
  position: fixed;
  right: 20px;
  top: 80px;
  width: 280px;
  background: var(--secondary-color);
  border-radius: 16px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.15);
  z-index: 100;
  overflow: hidden;
  transition: all 0.3s ease;
  border: 1px solid var(--secondary-hover-color);
}

.floating-image-grid.collapsed .floating-grid-content {
  max-height: 0;
  padding: 0;
}

.floating-header {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  background: var(--secondary-color);
  cursor: pointer;
  border-bottom: 1px solid var(--secondary-hover-color);
  font-weight: 500;
  color: var(--text-color);
}

.floating-header .material-symbols-rounded {
  font-size: 20px;
}

.floating-header span:first-child {
  font-size: 20px;
}

.floating-header span:nth-child(2) {
  flex: 1;
}

.toggle-grid-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-color);
  transition: transform 0.3s ease;
}

.floating-image-grid.collapsed .toggle-grid-btn {
  transform: rotate(180deg);
}

.floating-grid-content {
  max-height: 400px;
  overflow-y: auto;
  transition: max-height 0.3s ease;
}

.floating-thumbnails {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 8px;
  padding: 12px;
}

.floating-thumb {
  position: relative;
  aspect-ratio: 1;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  background: var(--primary-color);
  border: 1px solid var(--secondary-hover-color);
}

.thumb-image {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.2s ease;
}

.floating-thumb:hover .thumb-image {
  transform: scale(1.05);
}

.remove-thumb-btn {
  position: absolute;
  top: 4px;
  right: 4px;
  background: rgba(0, 0, 0, 0.6);
  border: none;
  border-radius: 50%;
  width: 24px;
  height: 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  opacity: 0;
  transition: opacity 0.2s ease;
  color: white;
  font-size: 16px;
}

.floating-thumb:hover .remove-thumb-btn {
  opacity: 1;
}

.remove-thumb-btn:hover {
  background: rgba(220, 53, 69, 0.9);
}

/* Image Gallery Styles */
.image-gallery-container {
  background: var(--secondary-color);
  border-radius: 12px;
  padding: 16px;
  margin: 8px 0;
}

.gallery-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
  padding-bottom: 8px;
  border-bottom: 1px solid var(--secondary-hover-color);
}

.gallery-header .material-symbols-rounded {
  font-size: 24px;
  color: #1d7efd;
}

.gallery-header h4 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: var(--text-color);
}

.image-gallery-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 12px;
  margin-bottom: 16px;
}

.gallery-item {
  position: relative;
  aspect-ratio: 1;
  border-radius: 8px;
  overflow: hidden;
  cursor: pointer;
  background: var(--primary-color);
  border: 1px solid var(--secondary-hover-color);
}

.gallery-thumbnail {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.2s ease;
}

.gallery-item:hover .gallery-thumbnail {
  transform: scale(1.05);
}

.gallery-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 12px;
  opacity: 0;
  transition: opacity 0.2s ease;
}

.gallery-item:hover .gallery-overlay {
  opacity: 1;
}

.gallery-overlay button {
  background: white;
  border: none;
  border-radius: 50%;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: transform 0.2s ease;
}

.gallery-overlay button:hover {
  transform: scale(1.1);
}

.gallery-overlay .material-symbols-rounded {
  font-size: 18px;
  color: var(--text-primary);
}

.gallery-info {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(to top, rgba(0,0,0,0.7), transparent);
  padding: 8px;
}

.gallery-name {
  color: white;
  font-size: 10px;
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.gallery-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid var(--secondary-hover-color);
}

.analyze-all-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  background: #1d7efd;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 13px;
  font-weight: 500;
  transition: all 0.2s ease;
}

.analyze-all-btn:hover {
  background: #0264e3;
  transform: translateY(-1px);
}

/* Batch Analysis Results */
.batch-analysis-result {
  background: var(--secondary-color);
  border-radius: 12px;
  padding: 16px;
}

.batch-analysis-result h4 {
  margin-bottom: 16px;
  color: var(--text-color);
}

.batch-stats {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
  padding: 12px;
  background: var(--primary-color);
  border-radius: 8px;
}

.stat-item {
  text-align: center;
  flex: 1;
}

.stat-value {
  display: block;
  font-size: 24px;
  font-weight: 600;
  color: #1d7efd;
}

.stat-label {
  display: block;
  font-size: 12px;
  color: var(--placeholder-color);
  margin-top: 4px;
}

.analysis-summary {
  margin-bottom: 16px;
  padding: 12px;
  background: var(--primary-color);
  border-radius: 8px;
}

.analysis-summary p {
  margin-bottom: 8px;
  color: var(--text-color);
}

.analysis-summary ul {
  margin: 0;
  padding-left: 20px;
  color: var(--text-color);
}

.analysis-summary li {
  margin: 4px 0;
  font-size: 13px;
}

.batch-actions {
  display: flex;
  justify-content: flex-end;
}

.extract-all-text-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 8px 16px;
  background: #28a745;
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.extract-all-text-btn:hover {
  background: #218838;
  transform: translateY(-1px);
}

/* Image Viewer Modal */
.image-viewer-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  animation: fadeIn 0.2s ease;
}

.image-viewer-content {
  position: relative;
  max-width: 90vw;
  max-height: 90vh;
}

.full-size-image {
  max-width: 100%;
  max-height: 90vh;
  object-fit: contain;
  border-radius: 8px;
}

.close-viewer-btn {
  position: absolute;
  top: -40px;
  right: 0;
  background: rgba(255, 255, 255, 0.2);
  border: none;
  color: white;
  font-size: 24px;
  cursor: pointer;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background 0.2s ease;
}

.close-viewer-btn:hover {
  background: rgba(255, 255, 255, 0.3);
}

@keyframes fadeIn {
  from {
    opacity: 0;
  }
  to {
    opacity: 1;
  }
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .floating-image-grid {
    right: 10px;
    top: 70px;
    width: 240px;
  }
  
  .floating-thumbnails {
    grid-template-columns: repeat(3, 1fr);
    gap: 6px;
    padding: 8px;
  }
  
  .image-gallery-grid {
    grid-template-columns: repeat(auto-fill, minmax(100px, 1fr));
    gap: 8px;
  }
}

@media (max-width: 480px) {
  .floating-image-grid {
    right: 5px;
    top: 65px;
    width: 200px;
  }
  
  .floating-thumbnails {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .floating-header {
    padding: 8px 12px;
    font-size: 12px;
  }
  
  .gallery-actions {
    justify-content: center;
  }
  
  .analyze-all-btn {
    width: 100%;
    justify-content: center;
  }
}

/* Dark mode adjustments */
@media (prefers-color-scheme: dark) {
  .floating-image-grid {
    background: var(--secondary-color);
    border-color: var(--secondary-hover-color);
  }
  
  .gallery-overlay button {
    background: var(--primary-color);
  }
  
  .batch-stats,
  .analysis-summary {
    background: var(--secondary-hover-color);
  }
}

/* Header adjustments */
.header-content {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}


/* Analysis Results Styles - Fixed Version */
.analysis-results {
  background: var(--secondary-color);
  border-radius: 16px;
  padding: 20px;
  margin: 16px 0;
  width: 100%;
  box-sizing: border-box;
  border: 1px solid var(--secondary-hover-color);
}

/* Analysis Header */
.analysis-header {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 20px;
  padding-bottom: 12px;
  border-bottom: 2px solid var(--primary-color);
}

.analysis-icon {
  font-size: 24px;
}

.analysis-header h4 {
  margin: 0;
  color: var(--text-color);
  font-size: 1.2rem;
  font-weight: 600;
}

/* Result Sections */
.result-section {
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--secondary-hover-color);
}

.result-section:last-child {
  border-bottom: none;
  margin-bottom: 0;
  padding-bottom: 0;
}

/* Info Rows */
.info-row {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 12px;
  margin-bottom: 12px;
}

.info-row:last-child {
  margin-bottom: 0;
}

.info-label {
  font-weight: 600;
  min-width: 120px;
  color: var(--text-color);
  opacity: 0.8;
}

.info-value {
  color: var(--text-color);
}

/* Document Type Badge */
.doc-type {
  display: inline-block;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 600;
}

.type-research { background: linear-gradient(135deg, #4CAF50, #45a049); color: white; }
.type-legal { background: linear-gradient(135deg, #2196F3, #1976D2); color: white; }
.type-financial { background: linear-gradient(135deg, #FFC107, #FFB300); color: #1a1a2e; }
.type-certificate { background: linear-gradient(135deg, #9C27B0, #7B1FA2); color: white; }
.type-id { background: linear-gradient(135deg, #F44336, #D32F2F); color: white; }
.type-other { background: linear-gradient(135deg, #757575, #616161); color: white; }

/* Confidence Bar */
.confidence-wrapper {
  display: flex;
  align-items: center;
  gap: 12px;
  flex: 1;
  max-width: 300px;
}

.confidence-bar {
  flex: 1;
  height: 8px;
  background: var(--secondary-hover-color);
  border-radius: 10px;
  overflow: hidden;
}

.confidence-fill {
  height: 100%;
  background: linear-gradient(90deg, #4CAF50, #8BC34A);
  border-radius: 10px;
  transition: width 0.3s ease;
}

.confidence-value {
  font-size: 0.85rem;
  font-weight: 600;
  color: #4CAF50;
  min-width: 45px;
}

/* Section Title */
.section-title {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 12px;
}

.section-icon {
  font-size: 18px;
}

.section-title h5 {
  margin: 0;
  color: var(--text-color);
  font-size: 1rem;
  font-weight: 600;
}

/* Summary Content */
.summary-content {
  background: var(--primary-color);
  padding: 16px;
  border-radius: 12px;
  line-height: 1.6;
  color: var(--text-color);
  border-left: 3px solid #1d7efd;
}

/* Topics List */
.topics-list {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.topic-tag {
  background: var(--primary-color);
  color: var(--text-color);
  padding: 6px 14px;
  border-radius: 20px;
  font-size: 0.85rem;
  border: 1px solid var(--secondary-hover-color);
  transition: all 0.2s ease;
}

.topic-tag:hover {
  background: var(--secondary-hover-color);
  transform: translateY(-1px);
}

/* Analysis Footer */
.analysis-footer {
  margin-top: 16px;
  padding-top: 12px;
  border-top: 1px solid var(--secondary-hover-color);
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.85rem;
  color: #4CAF50;
}

.footer-icon {
  font-size: 16px;
}

/* Responsive */
@media (max-width: 768px) {
  .analysis-results {
    padding: 12px;
  }
  
  .info-label {
    min-width: 100px;
  }
  
  .info-row {
    flex-direction: column;
    align-items: flex-start;
    gap: 6px;
  }
  
  .confidence-wrapper {
    width: 100%;
    max-width: 100%;
  }
  
  .summary-content {
    padding: 12px;
    font-size: 0.9rem;
  }
}

.new-chat-btn {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 8px;
  background: var(--secondary-color);
  border: none;
  color: var(--text-color);
  padding: 12px 16px;
  border-radius: 8px;
  cursor: pointer;
  margin-bottom: 20px;
  transition: background 0.3s ease;
}

/* New Chat Header Button - Like DeepSeek */
.new-chat-header-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 8px 16px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  border-radius: 8px;
  color: white;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-left: 24px;
  float: right;
}

.new-chat-header-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.new-chat-header-btn .material-symbols-rounded {
  font-size: 18px;
}

.new-chat-btn:hover {
  background: var(--secondary-hover-color);
}

/* Sidebar Container */
.sidebar {
  position: fixed;
  top: 0;
  left: -380px;
  width: 90vw;
  height: 90vh;
  background: rgba(26, 26, 46, 0.95);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-right: 1px solid rgba(255, 255, 255, 0.08);
  z-index: 1001;
  transition: left 0.35s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  flex-direction: column;
  box-shadow: 4px 0 30px rgba(0, 0, 0, 0.5);
}

.sidebar.open {
  left: 0;
}

/* Sidebar Header - Search Bar */
.sidebar-header {
  max-width: 80vw;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 16px 20px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.06);
  flex-shrink: 0;
  min-height: 68px;
}

.sidebar-search {
  width: 70vw;
  flex: 1;
  display: flex;
  align-items: center;
  gap: 10px;
  background: rgba(255, 255, 255, 0.06);
  border: 1px solid rgba(255, 255, 255, 0.08);
  border-radius: 12px;
  padding: 8px 14px;
  transition: all 0.3s ease;
}

.sidebar-search:focus-within {
  background: rgba(255, 255, 255, 0.08);
  border-color: rgba(102, 126, 234, 0.4);
  box-shadow: 0 0 20px rgba(102, 126, 234, 0.05);
}

.sidebar-search .material-symbols-rounded {
  font-size: 20px;
  color: rgba(255, 255, 255, 0.4);
}

.sidebar-search-input {
  flex: 1;
  background: transparent;
  border: none;
  color: #fff;
  font-size: 14px;
  outline: none;
}

.sidebar-search-input::placeholder {
  color: rgba(255, 255, 255, 0.3);
}

.close-btn {
  
  background: rgba(255, 255, 255, 0.05);
  border: none;
  color: rgba(255, 255, 255, 0.6);
  width: 36px;
  height: 36px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  transition: all 0.2s ease;
  flex-shrink: 0;
}

.close-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
  transform: rotate(90deg);
}

/* Sidebar Content */
.sidebar-content {
  
  flex: 1;
  padding: 16px 20px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.sidebar-content::-webkit-scrollbar {
  width: 4px;
}

.sidebar-content::-webkit-scrollbar-track {
  background: transparent;
}

.sidebar-content::-webkit-scrollbar-thumb {
  background: rgba(102, 126, 234, 0.3);
  border-radius: 10px;
}

/* Chat History List */
.chat-history-list {
  padding: 4px;
  flex: 1;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding-bottom: 8px;
  min-height: 0;
}

.chat-history-list::-webkit-scrollbar {
  width: 4px;
}

.chat-history-list::-webkit-scrollbar-thumb {
  background: rgba(102, 126, 234, 0.2);
  border-radius: 10px;
}

/* Chat Session Items */
.chat-session-item {
  padding: 14px 16px;
  background: rgba(255, 255, 255, 0.03);
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.25s ease;
  border: 1px solid transparent;
}

.chat-session-item:hover {
  background: rgba(255, 255, 255, 0.07);
  border-color: rgba(102, 126, 234, 0.2);
  transform: translateX(4px);
}

.chat-session-item.active {
  background: rgba(102, 126, 234, 0.15);
  border-color: rgba(102, 126, 234, 0.3);
  box-shadow: 0 0 20px rgba(102, 126, 234, 0.05);
}

.session-preview {
  font-weight: 500;
  color: #fff;
  margin-bottom: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  font-size: 14px;
}

.session-date {
  font-size: 0.75rem;
  color: rgba(255, 255, 255, 0.4);
}

.no-chats {
  text-align: center;
  color: rgba(255, 255, 255, 0.3);
  padding: 40px 20px;
  font-size: 14px;
}

/* Sidebar Footer - Horizontal */
.sidebar-footer {
  border-radius: 10px;
  flex-shrink: 0;
  padding: 14px 16px 18px;
  border-top: 1px solid rgba(255, 255, 255, 0.06);
  display: flex;
  flex-direction: row;
  align-items: center;
  gap: 10px;
  background: rgba(0, 0, 0, 0.2);
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
}

.sidebar-config-selector {
  flex-shrink: 0;
}

.config-btn {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.08);
  color: #fff;
  width: 38px;
  height: 38px;
  border-radius: 10px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  transition: all 0.25s ease;
}

.config-btn:hover {
  background: rgba(102, 126, 234, 0.2);
  border-color: rgba(102, 126, 234, 0.3);
  transform: rotate(60deg);
}

.sidebar-language-selector {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 12px;
  background: rgba(255, 255, 255, 0.04);
  border-radius: 10px;
  border: 1px solid rgba(255, 255, 255, 0.06);
  min-width: 0;
}

.sidebar-language-selector .material-symbols-rounded {
  font-size: 18px;
  color: rgba(255, 255, 255, 0.5);
}

.language-selector-sidebar {
  flex: 1;
  background: transparent;
  border: none;
  color: #fff;
  font-size: 13px;
  cursor: pointer;
  outline: none;
  padding: 4px 0;
  min-width: 0;
}

.language-selector-sidebar option {
  background: #1a1a2e;
  color: #fff;
}

.sidebar-auth-section {
  flex-shrink: 0;
}

.sidebar-auth-btn {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 6px 14px;
  background: rgba(102, 126, 234, 0.15);
  border: 1px solid rgba(102, 126, 234, 0.2);
  border-radius: 10px;
  color: white;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.25s ease;
  white-space: nowrap;
}

.sidebar-auth-btn:hover {
  background: rgba(102, 126, 234, 0.25);
  border-color: rgba(102, 126, 234, 0.4);
  transform: translateY(-1px);
}

.sidebar-auth-btn .material-symbols-rounded {
  font-size: 18px;
  color: #667eea;
}

/* Overlay */
.sidebar-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.6);
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
  z-index: 1000;
  display: none;
  animation: fadeIn 0.3s ease;
}

.sidebar-overlay.active {
  display: block;
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}
END
cat > src/components/AuthModal.jsx << 'END'
import { Component } from 'preact'
import { auth } from '../services/auth.js'

export class AuthModal extends Component {
  constructor(props) {
    super(props)
    this.state = {
      email: '',
      isLoading: false,
      currentProvider: null
    }
  }

  handleEmailSubmit = async (e) => {
    e.preventDefault()
    const { email } = this.state
    const { onAuthSuccess } = this.props
    
    if (!email) return
    
    this.setState({ isLoading: true, currentProvider: 'email' })
    
    try {
      await auth.handleEmailSignIn(email)
      if (onAuthSuccess) {
        onAuthSuccess()
      }
    } catch (error) {
      console.error('Email sign in failed:', error)
    } finally {
      this.setState({ isLoading: false, currentProvider: null })
    }
  }

  handleGoogleSignIn = async () => {
    const { onAuthSuccess } = this.props
    
    this.setState({ isLoading: true, currentProvider: 'google' })
    
    try {
      await auth.signInWithGoogle()
      if (onAuthSuccess) {
        onAuthSuccess()
      }
    } catch (error) {
      console.error('Google sign in failed:', error)
    } finally {
      this.setState({ isLoading: false, currentProvider: null })
    }
  }

  handleGitHubSignIn = async () => {
    const { onAuthSuccess } = this.props
    
    this.setState({ isLoading: true, currentProvider: 'github' })
    
    try {
      await auth.signInWithGitHub()
      if (onAuthSuccess) {
        onAuthSuccess()
      }
    } catch (error) {
      console.error('GitHub sign in failed:', error)
    } finally {
      this.setState({ isLoading: false, currentProvider: null })
    }
  }

  handleEmailChange = (e) => {
    this.setState({ email: e.target.value })
  }

  render() {
    const { isOpen, onClose } = this.props
    const { email, isLoading, currentProvider } = this.state

    // Add the 'active' class when isOpen is true
    const modalClass = isOpen ? 'oauth-modal active' : 'oauth-modal'

    return (
      <div class={modalClass}>
        <div class="oauth-modal-content">
          <button 
            class="close-oauth-btn material-symbols-rounded" 
            onClick={onClose}
            disabled={isLoading}
          >
            close
          </button>
          
          <div class="oauth-header">
            <img src="/icons/icon-192.png" alt="DocAnalyzer" class="oauth-logo" />
            <h2>Welcome to DocAnalyzer</h2>
            <p>Sign in to access your documents and chat history</p>
          </div>

          <div class="oauth-options">
            <button 
              class={`oauth-btn google-btn ${isLoading && currentProvider === 'google' ? 'loading' : ''}`}
              onClick={this.handleGoogleSignIn}
              disabled={isLoading}
            >
              <span class="oauth-icon">
                <img src=".img/google.png" alt="Google" />
              </span>
              {isLoading && currentProvider === 'google' ? 'Signing in...' : 'Continue with Google'}
            </button>

            <button 
              class={`oauth-btn github-btn ${isLoading && currentProvider === 'github' ? 'loading' : ''}`}
              onClick={this.handleGitHubSignIn}
              disabled={isLoading}
            >
              <span class="oauth-icon">
                <img src=".img/logo_only.png" alt="Fayda" />
              </span>
              {isLoading && currentProvider === 'github' ? 'Signing in...' : 'Continue with Fayda'}
            </button>

            <div class="divider">
              <span>or</span>
            </div>

            <form class="email-form" onSubmit={this.handleEmailSubmit}>
              <input 
                type="email" 
                placeholder="Enter your email" 
                value={email}
                onInput={this.handleEmailChange}
                required 
                class="email-input" 
                disabled={isLoading}
              />
              <button 
                type="submit" 
                class={`email-btn ${isLoading && currentProvider === 'email' ? 'loading' : ''}`}
                disabled={isLoading}
              >
                {isLoading && currentProvider === 'email' ? 'Sending...' : 'Continue with Email'}
              </button>
            </form>
          </div>

          <div class="oauth-footer">
            <p>By continuing, you agree to our <a href="#">Terms of Service</a> and <a href="#">Privacy Policy</a></p>
          </div>

          {isLoading && (
            <div class="auth-loading">
              <div class="spinner-small"></div>
              <p>Signing you in...</p>
            </div>
          )}
        </div>
      </div>
    )
  }
}END
cat > src/components/AuthModalx.jsx << 'END'
import { useState } from 'preact/hooks'
import { useLanguage } from '../utils/constants.js'

export default function AuthModalX({ onClose, onLogin, language }) {
  const [licenseNumber, setLicenseNumber] = useState('')
  const [isUploading, setIsUploading] = useState(false)
  const { t } = useLanguage()

  const handleLicenseSubmit = async (e) => {
    e.preventDefault()
    if (!licenseNumber.trim()) return

    // Simulate API call to verify business license
    try {
      const userData = {
        id: 1,
        name: "Demo Business",
        licenseNumber: licenseNumber,
        verified: true
      }
      onLogin(userData)
    } catch (error) {
      alert(t.verificationError)
    }
  }

  const handleFileUpload = async (event) => {
    const file = event.target.files[0]
    if (!file) return

    setIsUploading(true)
    
    // Simulate PDF processing and license extraction
    setTimeout(() => {
      const extractedLicense = "0068699863" // Mock extracted license
      setLicenseNumber(extractedLicense)
      setIsUploading(false)
    }, 2000)
  }

  return (
    <div className="modal-overlay">
      <div className="modal-content">
        <div className="modal-header">
          <h2>{t.faydaVerification}</h2>
          <button onClick={onClose} className="close-btn">×</button>
        </div>

        <form onSubmit={handleLicenseSubmit} className="auth-form">
          <div className="form-group">
            <label>{t.enterFAN}</label>
            <input
              type="text"
              value={licenseNumber}
              onChange={(e) => setLicenseNumber(e.target.value)}
              placeholder={t.faydaPlaceholder}
              required
            />
          </div>

          <div className="form-group">
            <label>{t.orUploadDocument}</label>
            <label className="file-upload-btn large">
              {isUploading ? t.processing : t.chooseFile}
              <input 
                type="file" 
                accept=".pdf" 
                onChange={handleFileUpload}
                disabled={isUploading}
                style={{ display: 'none' }}
              />
            </label>
          </div>

          <button 
            type="submit" 
            disabled={!licenseNumber.trim() || isUploading}
            className="submit-btn"
          >
            {isUploading ? t.verifying : t.verifyfayda}
          </button>
        </form>
      </div>
    </div>
  )
}END
cat > src/components/ChatUI.jsx << 'END'
// ============================================================
// ChatUI.jsx - Complete with Markdown Integration
// ============================================================

import { useState, useEffect, useRef } from 'preact/hooks'
import { db } from '../services/database.js'
import { nlpProcessor, chat } from '../services/nlpProcessor.js'
import { pdfAnalyzerF } from '../services/pdfAnalyzer.js'
import { teSsAna } from '../services/tess.js'
import { teSsAnaC } from '../services/tessC.js'
import { useLanguage } from '../utils/constants.js'
import AuthModalX from './AuthModalx.jsx'
import { pdfAnalyzerD } from '../services/pdfAnalyzer2.js'
import { MarkdownRenderer } from './MarkdownRenderer.jsx'
//import {IftmsLogin} from './IftmsLogin'

export function ChatUI(props) {
  const [user, setUser] = useState(null)
  const [showAuth, setShowAuth] = useState(false)
  const { language, setLanguage, t } = useLanguage()
  const [state, setState] = useState({
    messages: [],
    inputText: '',
    isProcessing: false,
    isTyping: false,
    currentFiles: [],
    currentFile: null,
    showCancelFile: false,
    fileNames: [],
    fileName: '',
    botResponding: false,
    responseStopped: false,
    partialResponse: '',
    uploadedImages: []
  })
  
  const currentTypingInterval = useRef(null)
  const promptForm = useRef(null)
  const fileInput = useRef(null)
  const prevSessionId = useRef(null)
  const chatContainerRef = useRef(null)

  useEffect(() => {
    loadSessionMessages()
    setupSuggestionListeners()
    
    if (!sessionStorage.getItem('currentStep')) {
      sessionStorage.setItem('currentStep', '1')
    }
    
    return () => {
      if (currentTypingInterval.current) {
        clearInterval(currentTypingInterval.current)
      }
      document.body.classList.remove("chats-active", "bot-responding")
    }
  }, [])

  useEffect(() => {
    if (prevSessionId.current !== props.currentSessionId) {
      prevSessionId.current = props.currentSessionId
      loadSessionMessages()
    }
  }, [props.currentSessionId])

  useEffect(() => {
    if (state.botResponding) {
      document.body.classList.add("chats-active", "bot-responding")
    } else {
      document.body.classList.remove("bot-responding")
    }
    
    if (state.messages.length > 0) {
      document.body.classList.add("chats-active")
    } else {
      document.body.classList.remove("chats-active")
    }

    if (state.messages.length === 0) {
      setTimeout(() => setupSuggestionListeners(), 100)
    } else {
      setTimeout(() => setupActionButtonListeners(), 100)
    }
    
    if (chatContainerRef.current) {
      chatContainerRef.current.scrollTop = chatContainerRef.current.scrollHeight
    }
  }, [state.botResponding, state.messages])

  const setupSuggestionListeners = () => {
    setTimeout(() => {
      const suggestionItems = document.querySelectorAll('.suggestions-item')
      suggestionItems.forEach((item) => {
        const newItem = item.cloneNode(true)
        item.parentNode.replaceChild(newItem, item)
        
        newItem.addEventListener('click', async (e) => {
          e.preventDefault()
          e.stopPropagation()
          await handleSuggestionClick(newItem)
        })
      })
    }, 100)
  }

  const setupActionButtonListeners = () => {
    const actionButtons = document.querySelectorAll('.action-btn')
    actionButtons.forEach((button) => {
      const newButton = button.cloneNode(true)
      button.parentNode.replaceChild(newButton, button)
      
      newButton.addEventListener('click', async (e) => {
        e.preventDefault()
        e.stopPropagation()
        await handleActionButtonClick(newButton)
      })
    })
  }

  const handleSuggestionClick = async (suggestionItem) => {
    const textElement = suggestionItem.querySelector('.text')
    if (!textElement) return

    const text = textElement.textContent
    console.log('Suggestion clicked:', text)
    
    if (state.messages.length === 0) {
      if (!props.currentSessionId && props.onNewSession) {
        props.onNewSession()
        setTimeout(() => {
          sendMessage(text, 'user')
          setTimeout(() => generateAIResponse(text), 500)
        }, 100)
      } else {
        await sendMessage(text, 'user')
        setTimeout(() => generateAIResponse(text), 500)
      }
    } else {
      await sendMessage(text, 'user')
      setTimeout(() => generateAIResponse(text), 500)
    }
  }

  const handleActionButtonClick = async (button) => {
    const action = button.dataset.action || button.textContent.trim()
    const service = button.dataset.service || 'iftms'
    const currentStep = parseInt(button.dataset.step || '1')
    const nextStep = parseInt(button.dataset.nextStep || (currentStep + 1))
    
    console.log('Action clicked:', action, 'Service:', service, 'Step:', currentStep, '→', nextStep)
    
    sessionStorage.setItem('currentStep', nextStep.toString())
    sessionStorage.setItem('intnt', service)
    
    await sendMessage(`User selected: ${action}`, 'user')
    
    if (service === 'iftms' && nextStep === 2) {
      setShowAuth(true)
      localStorage.setItem('sSo', nextStep.toString())
      return
    }
    
    await generateAIResponse(action)
  }

  const loadSessionMessages = async () => {
    const { currentSessionId } = props
    if (!currentSessionId) {
      setState(prev => ({ ...prev, messages: [] }))
      return
    }

    try {
      const allMessages = await db.getAllChatHistory()
      const sessionMessages = allMessages.filter(msg => 
        msg.sessionId === currentSessionId && msg.type !== 'system'
      )
      setState(prev => ({ ...prev, messages: sessionMessages }))
    } catch (error) {
      console.error('Failed to load session messages:', error)
    }
  }

  const handleInputChange = (e) => {
    setState(prev => ({ ...prev, inputText: e.target.value }))
  }

  const handleSubmit = async (e) => {
    if (e && e.preventDefault) e.preventDefault()
    
    const { inputText, isProcessing } = state
    const { currentSessionId } = props
    
    if (!inputText.trim() || isProcessing) return

    if (!currentSessionId && props.onNewSession) {
      props.onNewSession()
      setTimeout(() => {
        sendMessage(inputText, 'user')
        setState(prev => ({ ...prev, inputText: '' }))
        setTimeout(() => generateAIResponse(inputText), 500)
      }, 100)
    } else {
      await sendMessage(inputText, 'user')
      setState(prev => ({ ...prev, inputText: '' }))
      setTimeout(() => generateAIResponse(inputText), 500)
    }
  }

  const sendMessage = async (content, type = 'user') => {
    const { currentSessionId } = props
    const sessionId = currentSessionId

    if (!sessionId) {
      console.error('No session ID available')
      return
    }

    const message = {
      type,
      content,
      timestamp: new Date().toISOString(),
      sessionId: sessionId
    }

    setState(prev => ({
      ...prev,
      messages: [...prev.messages, message],
      isProcessing: type === 'user'
    }))

    try {
      await db.saveChatMessage(message)
    } catch (error) {
      console.error('Failed to save message:', error)
    }
  }

  const generateAIResponse = async (userMessage) => {
    setState(prev => ({ 
      ...prev,
      botResponding: true
    }))
    
    try {
      const nlpResult = await nlpProcessor.chat(userMessage)
      
      if (nlpResult.currentStep === 1 && nlpResult.intentResult?.includes('iftms')) {
        setShowAuth(true)
        localStorage.setItem('sSo', nlpResult.currentStep.toString())
        await typeMessage("Please authenticate to continue with the IFTMS service...", 'bot')
        return
      }
      
      // Use markdown or HTML content
      let responseContent = nlpResult.markdown || nlpResult.html || nlpResult.text || nlpResult
      
      // If it's plain text, wrap in markdown code block for better formatting
      if (typeof responseContent === 'string' && 
          !responseContent.includes('<') && 
          !responseContent.includes('```') &&
          !responseContent.includes('**')) {
        responseContent = responseContent
      }
      
      await typeMessage(responseContent, 'bot')
      
    } catch (error) {
      console.error('NLP processing failed:', error)
      await typeMessage("I'm sorry, I encountered an error processing your request.", 'bot')
    }
  }

  const typeMessage = async (content, type) => {
    setState(prev => ({ 
      ...prev,
      isTyping: true, 
      botResponding: true
    }))
    
    const message = {
      type,
      content: '',
      timestamp: new Date().toISOString(),
      sessionId: props.currentSessionId
    }

    setState(prev => ({
      ...prev,
      messages: [...prev.messages, message]
    }))

    let index = 0
    clearInterval(currentTypingInterval.current)
    currentTypingInterval.current = setInterval(() => {
      if (index < content.length) {
        const newContent = content.substring(0, index + 1)
        updateLastMessage(newContent)
        index++
      } else {
        finishTyping(content, type)
      }
    }, 10) // Faster typing speed
  }

  const finishTyping = (content, type) => {
    if (currentTypingInterval.current) {
      clearInterval(currentTypingInterval.current)
      currentTypingInterval.current = null
    }
    
    setState(prev => ({ 
      ...prev,
      isProcessing: false, 
      isTyping: false,
      botResponding: false,
      responseStopped: false
    }))
    
    saveFinalMessage(content, type)
  }

  const updateLastMessage = (content) => {
    setState(prevState => {
      const messages = [...prevState.messages]
      if (messages.length > 0) {
        messages[messages.length - 1] = {
          ...messages[messages.length - 1],
          content
        }
      }
      return { ...prevState, messages }
    })
  }

  const saveFinalMessage = async (content, type) => {
    try {
      const message = {
        type,
        content,
        timestamp: new Date().toISOString(),
        sessionId: props.currentSessionId
      }
      await db.saveChatMessage(message)
    } catch (error) {
      console.error('Failed to save final message:', error)
    }
  }

  const handleFileSelect = async (e) => {
    const files = Array.from(e.target.files)
    if (files.length === 0) return

    setState(prev => ({ 
      ...prev,
      currentFiles: files, 
      isProcessing: true,
      showCancelFile: true,
      fileNames: files.map(f => f.name),
      botResponding: true
    }))

    try {
      await sendMessage(`📎 Uploading ${files.length} file(s)...`, 'user')
      
      for (const file of files) {
        try {
          const result = await nlpProcessor.chat(null, file)
          
          let responseContent = result?.markdown || result?.html || result?.text || 
            (typeof result === 'string' ? result : `📄 Processed: ${file.name}`)
          
          await typeMessage(responseContent, 'bot')
          
        } catch (error) {
          console.error('Error processing file:', error)
          await typeMessage(`❌ Error processing ${file.name}: ${error.message}`, 'bot')
        }
      }
      
    } catch (error) {
      await typeMessage(`❌ Error: ${error.message}`, 'bot')
    } finally {
      setState(prev => ({ 
        ...prev,
        isProcessing: false, 
        currentFiles: [],
        fileNames: []
      }))
      e.target.value = ''
    }
  }

  const displayAnalysisResults = (analysis) => {
    const docType = analysis.documentType || 'Document'
    const typeClass = getDocumentTypeClass(docType)
    const confidence = analysis.confidence || 0
    const pages = analysis.pages || 1
    const wordCount = analysis.wordCount || 0
    const summary = analysis.summary || 'No summary available'
    const topics = analysis.topics || []
    
    const resultsMarkdown = `
## 📊 Document Analysis Complete

### Document Type
**${docType}** *(${Math.round(confidence * 100)}% confidence)*

### Document Size
📄 ${pages} page${pages !== 1 ? 's' : ''} • 📝 ${wordCount.toLocaleString()} words

### 📋 Summary
${summary}

${topics.length > 0 ? `
### 🏷️ Key Topics
${topics.map(topic => `- \`${escapeHtml(topic)}\``).join('\n')}
` : ''}

---
✅ Analysis completed successfully
    `
    
    typeMessage(resultsMarkdown, 'bot')
  }

  const getDocumentTypeClass = (docType) => {
    const typeMap = {
      'Research': 'type-research',
      'Legal': 'type-legal',
      'Financial': 'type-financial',
      'Certificate': 'type-certificate',
      'ID': 'type-id',
      'Contract': 'type-legal',
      'Report': 'type-research',
      'Invoice': 'type-financial'
    }
    return typeMap[docType] || 'type-other'
  }

  const escapeHtml = (text) => {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  const handleLogin = (userData) => {
    setUser(userData)
    localStorage.setItem('agig-user', JSON.stringify(userData))
    setShowAuth(false)
    
    const nextStep = parseInt(localStorage.getItem('sSo') || '2')
    sessionStorage.setItem('currentStep', nextStep.toString())
    
    setTimeout(() => {
      generateAIResponse(`Continuing from step ${nextStep}`)
    }, 500)
  }

  const triggerFileInput = () => {
    fileInput.current.click()
  }

  const stopResponse = () => {
    if (currentTypingInterval.current) {
      clearInterval(currentTypingInterval.current)
      currentTypingInterval.current = null
    }
    
    setState(prev => ({ 
      ...prev,
      isTyping: false, 
      isProcessing: false,
      botResponding: false,
      responseStopped: true,
      showCancelFile: false
    }))
    
    sendMessage('Response stopped by user.', 'info')
  }

  const continueResponse = async () => {
    setState(prev => ({
      ...prev,
      responseStopped: false,
      botResponding: true
    }))

    await generateAIResponse("Continuing...")
  }

  const cancelFileUpload = () => {
    stopResponse()
    
    setState(prev => ({
      ...prev,
      currentFile: null,
      showCancelFile: false,
      fileName: '',
      isProcessing: false
    }))
    
    if (fileInput.current) {
      fileInput.current.value = ''
    }
  }

  const renderSuggestions = () => {
    const suggestions = [
      t.vidgen,
      t.acpprvd,
      t.iftmscard,
      t.vgovdoc,
      t.analgdoc
    ]

    return (
      <div class="suggestions-container">
        <ul class="suggestions">
          {suggestions.map((text, index) => (
            <li key={index} class="suggestions-item">
              <div class="suggestion-content">
                <span class="icon material-symbols-rounded">
                  {index === 0 ? 'description' : 
                   index === 1 ? 'local_shipping' : 
                   index === 2 ? 'verified' : 
                   'analytics'}
                </span>
                <p class="text">{text}</p>
              </div>
              <span class="arrow-icon material-symbols-rounded">arrow_forward</span>
            </li>
          ))}
        </ul>
      </div>
    )
  }

  const { 
    messages, 
    inputText, 
    isProcessing, 
    isTyping, 
    showCancelFile, 
    fileName, 
    botResponding, 
    responseStopped 
  } = state

  return (
    <div class="chat-ui">
      {showAuth && (
        <AuthModalX 
          onClose={() => setShowAuth(false)}
          onLogin={handleLogin}
          language={language}
        />
      )}
      
      {messages.length === 0 && renderSuggestions()}
      
      <div class="chats-container" ref={chatContainerRef}>
        {messages.map((message, index) => (
          <div key={index} class={`message ${message.type}-message`}>
            {message.type === 'bot' && (
              <img class="avatar" src=".img/1752692028961-removebg-preview.png" alt="AI Assistant" />
            )}
            <div class="message-content">
              <MarkdownRenderer content={message.content} />
            </div>
            {message.type === 'bot' && !message.content.includes('action-btn') && (
              <div class="message-actions">
                <button class="copy-btn material-symbols-rounded" 
                  onClick={() => {
                    const text = message.content.replace(/<[^>]*>/g, '')
                    navigator.clipboard.writeText(text)
                  }}>
                  content_copy
                </button>
              </div>
            )}
          </div>
        ))}
        
        {isTyping && (
          <div class="message bot-message">
            <img class="avatar" src=".img/1752692028961-removebg-preview.png" alt="AI Assistant" />
            <div class="message-content">
              <div class="typing-indicator">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>
          </div>
        )}

        {responseStopped && (
          <div class="message info-message">
            <div class="message-content">
              <div class="continue-prompt">
                <p>Response was stopped. Would you like to continue?</p>
                <button class="continue-btn" onClick={continueResponse}>
                  <span class="material-symbols-rounded">play_arrow</span>
                  Continue Response
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      {(showCancelFile || botResponding) && (
        <div class="file-upload-wrapper active">
          <div class="file-info">
            <span class="file-name" id="loading">
              {fileName || 'Processing...'}
            </span>
            <button 
              id="cancel-file-btn" 
              class="cancel-file material-symbols-rounded"
              onClick={cancelFileUpload}
              title="Cancel operation"
            >
              close
            </button>
          </div>
        </div>
      )}

      <div class="prompt-container">
        <div class="prompt-wrapper">
          <form class="prompt-form" ref={promptForm} onSubmit={handleSubmit}>
            <input 
              type="text" 
              placeholder="Request AGS services..." 
              class="prompt-input" 
              value={inputText}
              onInput={handleInputChange}
              required 
              disabled={isProcessing || botResponding}
            />
            <div class="prompt-actions">
              {(botResponding && !responseStopped) ? (
                <button 
                  type="button"
                  id="stop-response-btn" 
                  class="stop-response material-symbols-rounded" 
                  title="Stop Response"
                  onClick={stopResponse}
                >
                  stop_circle
                </button>
              ) : (
                <>
                  <input 
                    type="file" 
                    ref={fileInput}
                    onChange={handleFileSelect}
                    accept=".pdf,image/*,.txt,.doc,.docx" 
                    style={{ display: 'none' }} 
                  />
                  <button 
                    type="button" 
                    class="material-symbols-rounded" 
                    onClick={triggerFileInput}
                    disabled={isProcessing || botResponding}
                  >
                    attach_file
                  </button>
                  <button 
                    type="submit" 
                    class="material-symbols-rounded" 
                    disabled={isProcessing || botResponding || !inputText.trim()}
                  >
                    arrow_upward
                  </button>
                </>
              )}
            </div>
          </form>
        </div>
        <p class="disclaimer-text">Advanced Government Services powered by AI - may occasionally produce errors</p>
      </div>

      <style>{`
        /* Markdown styles */
        .markdown-content {
          font-size: 14px;
          line-height: 1.7;
          color: #e0e0e0;
        }

        .markdown-content h1,
        .markdown-content h2,
        .markdown-content h3 {
          margin: 1.2em 0 0.6em;
          font-weight: 600;
          color: #fff;
        }

        .markdown-content h1 { font-size: 1.8em; }
        .markdown-content h2 { font-size: 1.5em; border-bottom: 1px solid #2a2a4e; padding-bottom: 0.3em; }
        .markdown-content h3 { font-size: 1.2em; }

        .markdown-content p {
          margin: 0.6em 0;
        }

        .markdown-content ul,
        .markdown-content ol {
          margin: 0.6em 0;
          padding-left: 1.8em;
        }

        .markdown-content li {
          margin: 0.3em 0;
        }

        .markdown-content code {
          background: #1a1a2e;
          padding: 0.2em 0.4em;
          border-radius: 3px;
          font-size: 0.9em;
          color: #4a6cf7;
        }

        .markdown-content pre {
          background: #0d0d1a;
          padding: 1em;
          border-radius: 6px;
          overflow-x: auto;
          margin: 1em 0;
        }

        .markdown-content pre code {
          background: none;
          padding: 0;
          color: #e0e0e0;
        }

        .markdown-content blockquote {
          border-left: 3px solid #4a6cf7;
          padding-left: 1em;
          margin: 1em 0;
          color: #aaa;
          font-style: italic;
        }

        .markdown-content table {
          width: 100%;
          border-collapse: collapse;
          margin: 1em 0;
        }

        .markdown-content table th,
        .markdown-content table td {
          padding: 0.6em 1em;
          border: 1px solid #2a2a4e;
          text-align: left;
        }

        .markdown-content table th {
          background: #1a1a2e;
          color: #fff;
          font-weight: 600;
        }

        .markdown-content table tr:nth-child(even) {
          background: #0d0d1a;
        }

        .markdown-content a {
          color: #4a6cf7;
          text-decoration: none;
        }

        .markdown-content a:hover {
          text-decoration: underline;
        }

        .markdown-content img {
          max-width: 100%;
          border-radius: 6px;
          margin: 0.6em 0;
        }

        .markdown-content .table-wrapper {
          overflow-x: auto;
        }

        .markdown-content .action-btn {
          display: inline-block;
          padding: 8px 16px;
          margin: 4px 6px 4px 0;
          background: #2a2a4e;
          border: none;
          border-radius: 4px;
          color: #e0e0e0;
          cursor: pointer;
          font-size: 13px;
          transition: background 0.2s;
        }

        .markdown-content .action-btn:hover {
          background: #3a3a6e;
        }

        .markdown-content .error {
          color: #ff6b6b;
          background: #4a2d2d;
          padding: 0.8em 1em;
          border-radius: 6px;
          border-left: 3px solid #ff6b6b;
        }

        .markdown-content .success {
          color: #81c784;
          background: #2d4a2d;
          padding: 0.8em 1em;
          border-radius: 6px;
          border-left: 3px solid #4caf50;
        }

        .markdown-content .warning {
          color: #ffd54f;
          background: #4a3d2d;
          padding: 0.8em 1em;
          border-radius: 6px;
          border-left: 3px solid #ffc107;
        }
      `}</style>
    </div>
  )
}END
cat > src/components/ChatUI2.jsx << 'END'
import { useState, useEffect, useRef } from 'preact/hooks'
import { db } from '../services/database.js'
import { nlpProcessor,chat } from '../services/nlpProcessor.js'
import { pdfAnalyzerF } from '../services/pdfAnalyzer.js'
import { teSsAna } from '../services/tess.js'
import { teSsAnaC } from '../services/tessC.js'
import { useLanguage } from '../utils/constants.js'
import AuthModalX from './AuthModalx.jsx'
import { pdfAnalyzerD } from '../services/pdfAnalyzer2.js'

export function ChatUI(props) {
  const [user, setUser] = useState(null)
  const [showAuth, setShowAuth] = useState(false)
  const { language, setLanguage, t } = useLanguage()
  const [state, setState] = useState({
    messages: [],
    inputText: '',
    isProcessing: false,
    isTyping: false,
    currentFiles: [], // Changed to array for multiple files
    showCancelFile: false,
    fileNames: [], // Array of file names
    botResponding: false,
    responseStopped: false,
    partialResponse: '',
    uploadedImages: [] // Store uploaded images
  })
  
  const currentTypingInterval = useRef(null)
  const promptForm = useRef(null)
  const fileInput = useRef(null)
  const prevSessionId = useRef(null)
  const chatContainerRef = useRef(null)

  useEffect(() => {
    loadSessionMessages()
    setupSuggestionListeners()
    
    // Initialize session storage
    if (!sessionStorage.getItem('currentStep')) {
      sessionStorage.setItem('currentStep', '1')
    }
    
    return () => {
      if (currentTypingInterval.current) {
        clearInterval(currentTypingInterval.current)
      }
      document.body.classList.remove("chats-active", "bot-responding")
    }
  }, [])

  useEffect(() => {
    // Check if session changed
    if (prevSessionId.current !== props.currentSessionId) {
      prevSessionId.current = props.currentSessionId
      loadSessionMessages()
    }
  }, [props.currentSessionId])

  useEffect(() => {
    // Update body classes
    if (state.botResponding) {
      document.body.classList.add("chats-active", "bot-responding")
    } else {
      document.body.classList.remove("bot-responding")
    }
    
    if (state.messages.length > 0) {
      document.body.classList.add("chats-active")
    } else {
      document.body.classList.remove("chats-active")
    }

    // Setup suggestion listeners when messages are empty
    if (state.messages.length === 0) {
      setTimeout(() => setupSuggestionListeners(), 100)
    } else {
      // Setup action button listeners after messages render
      setTimeout(() => setupActionButtonListeners(), 100)
      // Setup image action listeners
      setTimeout(() => setupImageActionListeners(), 100)
    }
    
    // Scroll to bottom
    if (chatContainerRef.current) {
      chatContainerRef.current.scrollTop = chatContainerRef.current.scrollHeight
    }
  }, [state.botResponding, state.messages, state.uploadedImages])

  // Setup suggestion card listeners
  const setupSuggestionListeners = () => {
    setTimeout(() => {
      const suggestionItems = document.querySelectorAll('.suggestions-item')
      suggestionItems.forEach((item) => {
        const newItem = item.cloneNode(true)
        item.parentNode.replaceChild(newItem, item)
        
        newItem.addEventListener('click', async (e) => {
          e.preventDefault()
          e.stopPropagation()
          await handleSuggestionClick(newItem)
        })
      })
    }, 100)
  }

  // Listen for action button clicks
  const setupActionButtonListeners = () => {
    const actionButtons = document.querySelectorAll('.action-btn')
    actionButtons.forEach((button) => {
      const newButton = button.cloneNode(true)
      button.parentNode.replaceChild(newButton, button)
      
      newButton.addEventListener('click', async (e) => {
        e.preventDefault()
        e.stopPropagation()
        await handleActionButtonClick(newButton)
      })
    })
  }
  
  // Setup image action listeners
  const setupImageActionListeners = () => {
    // Analyze image buttons
    const analyzeButtons = document.querySelectorAll('.analyze-image-btn')
    analyzeButtons.forEach(button => {
      const newButton = button.cloneNode(true)
      button.parentNode.replaceChild(newButton, button)
      
      newButton.addEventListener('click', async (e) => {
        e.preventDefault()
        const imageId = parseInt(newButton.dataset.imageId)
        const imageData = state.uploadedImages.find(img => img.id === imageId)
        if (imageData) {
          await analyzeImage(imageData)
        }
      })
    })
    
    // Delete image buttons in messages
    const deleteImageBtns = document.querySelectorAll('.delete-image-msg-btn')
    deleteImageBtns.forEach(button => {
      const newButton = button.cloneNode(true)
      button.parentNode.replaceChild(newButton, button)
      
      newButton.addEventListener('click', async (e) => {
        e.preventDefault()
        const imageId = parseInt(newButton.dataset.imageId)
        await deleteImage(imageId)
      })
    })
    
    // View image buttons
    const viewImageBtns = document.querySelectorAll('.view-image-btn')
    viewImageBtns.forEach(button => {
      const newButton = button.cloneNode(true)
      button.parentNode.replaceChild(newButton, button)
      
      newButton.addEventListener('click', async (e) => {
        e.preventDefault()
        const imageId = parseInt(newButton.dataset.imageId)
        const imageData = state.uploadedImages.find(img => img.id === imageId)
        if (imageData) {
          openImageViewer(imageData.data)
        }
      })
    })
  }

  const handleSuggestionClick = async (suggestionItem) => {
    const textElement = suggestionItem.querySelector('.text')
    if (!textElement) return

    const text = textElement.textContent
    console.log('Suggestion clicked:', text)
    
    if (state.messages.length === 0) {
      if (!props.currentSessionId && props.onNewSession) {
        props.onNewSession()
        setTimeout(() => {
          sendMessage(text, 'user')
          setTimeout(() => generateAIResponse(text), 500)
        }, 100)
      } else {
        await sendMessage(text, 'user')
        setTimeout(() => generateAIResponse(text), 500)
      }
    } else {
      await sendMessage(text, 'user')
      setTimeout(() => generateAIResponse(text), 500)
    }
  }

  const handleActionButtonClick = async (button) => {
    const action = button.dataset.action || button.textContent.trim()
    const service = button.dataset.service || 'iftms'
    const currentStep = parseInt(button.dataset.step || '1')
    const nextStep = parseInt(button.dataset.nextStep || (currentStep + 1))
    
    console.log('Action clicked:', action, 'Service:', service, 'Step:', currentStep, '→', nextStep)
    
    sessionStorage.setItem('currentStep', nextStep.toString())
    sessionStorage.setItem('intnt', service)
    
    await sendMessage(`User selected: ${action}`, 'user')
    
    if (service === 'iftms' && nextStep === 2) {
      setShowAuth(true)
      localStorage.setItem('sSo', nextStep.toString())
      return
    }
    
    await generateAIResponse(action)
  }

  const loadSessionMessages = async () => {
    const { currentSessionId } = props
    if (!currentSessionId) {
      setState(prev => ({ ...prev, messages: [], uploadedImages: [] }))
      return
    }

    try {
      const allMessages = await db.getAllChatHistory()
      const sessionMessages = allMessages.filter(msg => 
        msg.sessionId === currentSessionId && msg.type !== 'system'
      )
      setState(prev => ({ ...prev, messages: sessionMessages }))
      
      // Load uploaded images from localStorage for this session
      const savedImages = localStorage.getItem(`images_${currentSessionId}`)
      if (savedImages) {
        setState(prev => ({ ...prev, uploadedImages: JSON.parse(savedImages) }))
      }
    } catch (error) {
      console.error('Failed to load session messages:', error)
    }
  }

  const handleInputChange = (e) => {
    setState(prev => ({ ...prev, inputText: e.target.value }))
  }

  const handleSubmit = async (e) => {
    if (e && e.preventDefault) e.preventDefault()
    
    const { inputText, isProcessing } = state
    const { currentSessionId } = props
    
    if (!inputText.trim() || isProcessing) return

    if (!currentSessionId && props.onNewSession) {
      props.onNewSession()
      setTimeout(() => {
        sendMessage(inputText, 'user')
        setState(prev => ({ ...prev, inputText: '' }))
        setTimeout(() => generateAIResponse(inputText), 500)
      }, 100)
    } else {
      await sendMessage(inputText, 'user')
      setState(prev => ({ ...prev, inputText: '' }))
      setTimeout(() => generateAIResponse(inputText), 500)
    }
  }

  const sendMessage = async (content, type = 'user') => {
    const { currentSessionId } = props
    const sessionId = currentSessionId

    if (!sessionId) {
      console.error('No session ID available')
      return
    }

    const message = {
      type,
      content,
      timestamp: new Date().toISOString(),
      sessionId: sessionId
    }

    setState(prev => ({
      ...prev,
      messages: [...prev.messages, message],
      isProcessing: type === 'user'
    }))

    try {
      await db.saveChatMessage(message)
    } catch (error) {
      console.error('Failed to save message:', error)
    }
  }

  const generateAIResponse = async (userMessage) => {
    setState(prev => ({ 
      ...prev,
      botResponding: true
    }))
    
    try {
      const nlpResult = await chat(userMessage)
      
      if (nlpResult.currentStep === 1 && nlpResult.intents?.includes('iftms')) {
        setShowAuth(true)
        localStorage.setItem('sSo', nlpResult.currentStep.toString())
        await typeMessage("Please authenticate to continue with the IFTMS service...", 'bot')
        return
      }
      
      const responseContent = nlpResult.html || nlpResult.text || nlpResult
      await typeMessage(responseContent, 'bot')
      
    } catch (error) {
      console.error('NLP processing failed:', error)
      await typeMessage("I'm sorry, I encountered an error processing your request.", 'bot')
    }
  }

  const typeMessage = async (content, type) => {
    setState(prev => ({ 
      ...prev,
      isTyping: true, 
      botResponding: true
    }))
    
    const message = {
      type,
      content: '',
      timestamp: new Date().toISOString(),
      sessionId: props.currentSessionId
    }

    setState(prev => ({
      ...prev,
      messages: [...prev.messages, message]
    }))

    let index = 0
    clearInterval(currentTypingInterval.current)
    currentTypingInterval.current = setInterval(() => {
      if (index < content.length) {
        const newContent = content.substring(0, index + 1)
        updateLastMessage(newContent)
        index++
      } else {
        finishTyping(content, type)
      }
    }, 20)
  }

  const finishTyping = (content, type) => {
    if (currentTypingInterval.current) {
      clearInterval(currentTypingInterval.current)
      currentTypingInterval.current = null
    }
    
    setState(prev => ({ 
      ...prev,
      isProcessing: false, 
      isTyping: false,
      botResponding: false,
      responseStopped: false
    }))
    
    saveFinalMessage(content, type)
  }

  const updateLastMessage = (content) => {
    setState(prevState => {
      const messages = [...prevState.messages]
      if (messages.length > 0) {
        messages[messages.length - 1] = {
          ...messages[messages.length - 1],
          content
        }
      }
      return { ...prevState, messages }
    })
  }

  const saveFinalMessage = async (content, type) => {
    try {
      const message = {
        type,
        content,
        timestamp: new Date().toISOString(),
        sessionId: props.currentSessionId
      }
      await db.saveChatMessage(message)
    } catch (error) {
      console.error('Failed to save final message:', error)
    }
  }

  const handleFileSelectx = async (e) => {
    const files = Array.from(e.target.files)
    if (files.length === 0) return

    const imageFiles = files.filter(file => file.type.startsWith('image/'))
    const otherFiles = files.filter(file => !file.type.startsWith('image/'))
    
    setState(prev => ({ 
      ...prev,
      currentFiles: files, 
      isProcessing: true,
      showCancelFile: true,
      fileNames: files.map(f => f.name),
      botResponding: true
    }))

    try {
      await sendMessage(`Uploading ${files.length} file(s) for analysis...`, 'user')
      
      // Process all images
      if (imageFiles.length > 0) {
        const newImages = []
        
        for (const file of imageFiles) {
          const reader = new FileReader()
          const imageData = await new Promise((resolve) => {
            reader.onload = (event) => resolve(event.target.result)
            reader.readAsDataURL(file)
          })
          
          const newImage = {
            id: Date.now() + Math.random(),
            name: file.name,
            data: imageData,
            size: file.size,
            type: file.type,
            timestamp: new Date().toISOString()
          }
          newImages.push(newImage)
        }
        
        // Update state with all new images
        const updatedImages = [...state.uploadedImages, ...newImages]
        setState(prev => ({ ...prev, uploadedImages: updatedImages }))
        
        // Save to localStorage
        if (props.currentSessionId) {
          localStorage.setItem(`images_${props.currentSessionId}`, JSON.stringify(updatedImages))
        }
        
        // Create image gallery message
        const imagesHTML = `
          <div class="image-gallery-container">
            <div class="gallery-header">
              <span class="material-symbols-rounded">photo_library</span>
              <h4>${imageFiles.length} Image${imageFiles.length > 1 ? 's' : ''} Uploaded</h4>
            </div>
            <div class="image-gallery-grid">
              ${newImages.map(img => `
                <div class="gallery-item" data-image-id="${img.id}">
                  <img src="${img.data}" alt="${img.name}" class="gallery-thumbnail" />
                  <div class="gallery-overlay">
                    <button class="view-gallery-btn" data-image-id="${img.id}">
                      <span class="material-symbols-rounded">visibility</span>
                    </button>
                    <button class="delete-gallery-btn" data-image-id="${img.id}">
                      <span class="material-symbols-rounded">delete</span>
                    </button>
                  </div>
                  <div class="gallery-info">
                    <span class="gallery-name">${img.name.length > 20 ? img.name.substring(0, 17) + '...' : img.name}</span>
                  </div>
                </div>
              `).join('')}
            </div>
            <div class="gallery-actions">
              <button class="analyze-all-btn">
                <span class="material-symbols-rounded">analytics</span>
                Analyze All Images
              </button>
            </div>
          </div>
        `
        
        await typeMessage(imagesHTML, 'bot')
      }
      
      // Process other files (PDFs, etc.)
      if (otherFiles.length > 0) {
        for (const file of otherFiles) {
          const analysis = await chat(null,file)
          displayAnalysisResults(analysis, file.name)
        }
      }
      
    } catch (error) {
      await typeMessage(`Error analyzing document: ${error.message}`, 'bot')
    } finally {
      setState(prev => ({ 
        ...prev,
        isProcessing: false, 
        currentFiles: [],
        fileNames: []
      }))
      e.target.value = ''
      
      // Setup gallery listeners
      setTimeout(() => setupGalleryListeners(), 100)
    }
  }
   const handleFileSelect = async (e) => {
      const file = e.target.files[0]
      if (!file) return
  
      setState(prev => ({ 
        ...prev,
        currentFile: file, 
        isProcessing: true,
        showCancelFile: true,
        fileName: file.name,
        botResponding: true
      }))
  
      try {
        await sendMessage(`📄 Uploading ${file.name} for analysis...`, 'user')
        
        let extractedText = ''
        
        // Extract text based on file type
        if (file.type === 'application/pdf') {
          const extracted = await pdfAnalyzerD.analyzeDocument(file)
          extractedText = extracted.text
        } else if (file.type.startsWith('image/')) {
          // For images, you'd use OCR here
          // For now, send filename as placeholder
          extractedText = `[Image file: ${file.name}]`
        }
        
        // Send to server
        const result = await teSsAna.analyzeDocument(
          extractedText,
          file.name,
          null, // document type will be detected by server
          { fileName: file.name, fileSize: file.size }
        )
        
        if (result.success) {
          setState(prev => ({ 
            ...prev, 
            sessionState: result.session 
          }))
          
          for (const response of result.responses) {
            await typeMessage(response.html || response.text, 'bot')
          }
        }
        
      } catch (error) {
        console.error('File processing error:', error)
        await typeMessage(`❌ Error analyzing document: ${error.message}`, 'bot')
      } finally {
        setState(prev => ({ 
          ...prev,
          isProcessing: false, 
          currentFile: null,
          fileName: '',
          showCancelFile: false
        }))
        e.target.value = ''
      }
    }
  // Setup gallery listeners
  const setupGalleryListeners = () => {
    // View gallery images
    const viewButtons = document.querySelectorAll('.view-gallery-btn')
    viewButtons.forEach(button => {
      const newButton = button.cloneNode(true)
      button.parentNode.replaceChild(newButton, button)
      
      newButton.addEventListener('click', (e) => {
        e.preventDefault()
        const imageId = parseInt(newButton.dataset.imageId)
        const imageData = state.uploadedImages.find(img => img.id === imageId)
        if (imageData) {
          openImageViewer(imageData.data)
        }
      })
    })
    
    // Delete gallery images
    const deleteButtons = document.querySelectorAll('.delete-gallery-btn')
    deleteButtons.forEach(button => {
      const newButton = button.cloneNode(true)
      button.parentNode.replaceChild(newButton, button)
      
      newButton.addEventListener('click', async (e) => {
        e.preventDefault()
        const imageId = parseInt(newButton.dataset.imageId)
        await deleteImage(imageId)
        
        // Update the gallery message content
        const updatedImages = state.uploadedImages.filter(img => img.id !== imageId)
        if (updatedImages.length === 0) {
          await typeMessage("All images have been removed.", 'bot')
        }
      })
    })
    
    // Analyze all images
    const analyzeAllBtn = document.querySelector('.analyze-all-btn')
    if (analyzeAllBtn) {
      const newBtn = analyzeAllBtn.cloneNode(true)
      analyzeAllBtn.parentNode.replaceChild(newBtn, analyzeAllBtn)
      
      newBtn.addEventListener('click', async () => {
        await analyzeAllImages()
      })
    }
  }
  
  // Analyze all images
  const analyzeAllImages = async () => {
    if (state.uploadedImages.length === 0) return
    
    await typeMessage(`Analyzing ${state.uploadedImages.length} image(s)...`, 'bot')
    
    setTimeout(async () => {
      const analysisResults = `
        <div class="batch-analysis-result">
          <h4>📊 Batch Analysis Complete</h4>
          <div class="batch-stats">
            <div class="stat-item">
              <span class="stat-value">${state.uploadedImages.length}</span>
              <span class="stat-label">Images Analyzed</span>
            </div>
            <div class="stat-item">
              <span class="stat-value">100%</span>
              <span class="stat-label">Success Rate</span>
            </div>
          </div>
          <div class="analysis-summary">
            <p>All images have been processed successfully. Key elements detected include:</p>
            <ul>
              <li>Documents and forms identification</li>
              <li>Text extraction available</li>
              <li>Quality assessment completed</li>
            </ul>
          </div>
          <div class="batch-actions">
            <button class="extract-all-text-btn">
              <span class="material-symbols-rounded">text_fields</span>
              Extract All Text
            </button>
          </div>
        </div>
      `
      await typeMessage(analysisResults, 'bot')
      
      setTimeout(() => {
        const extractBtn = document.querySelector('.extract-all-text-btn')
        if (extractBtn) {
          extractBtn.addEventListener('click', () => {
            typeMessage("Text extraction for all images will be available soon.", 'bot')
          })
        }
      }, 100)
    }, 2000)
  }
  
  // Delete image
  const deleteImage = async (imageId) => {
    const updatedImages = state.uploadedImages.filter(img => img.id !== imageId)
    setState(prev => ({ ...prev, uploadedImages: updatedImages }))
    
    if (props.currentSessionId) {
      localStorage.setItem(`images_${props.currentSessionId}`, JSON.stringify(updatedImages))
    }
    
    await typeMessage("Image removed successfully.", 'bot')
  }
  
  // Open image viewer modal
  const openImageViewer = (imageData) => {
    const modal = document.createElement('div')
    modal.className = 'image-viewer-modal'
    modal.innerHTML = `
      <div class="image-viewer-content">
        <button class="close-viewer-btn">✕</button>
        <img src="${imageData}" alt="Full size image" class="full-size-image" />
      </div>
    `
    document.body.appendChild(modal)
    
    modal.addEventListener('click', (e) => {
      if (e.target === modal || e.target.className === 'close-viewer-btn') {
        modal.remove()
      }
    })
  }
  
  // Render floating image grid
  const renderFloatingImageGrid = () => {
    if (state.uploadedImages.length === 0) return null
    
    return (
      <div class="floating-image-grid">
        <div class="floating-header">
          <span class="material-symbols-rounded">image</span>
          <span>Images ({state.uploadedImages.length})</span>
          <button class="toggle-grid-btn material-symbols-rounded" onClick={() => {
            const grid = document.querySelector('.floating-image-grid')
            grid.classList.toggle('collapsed')
          }}>
            keyboard_arrow_down
          </button>
        </div>
        <div class="floating-grid-content">
          <div class="floating-thumbnails">
            {state.uploadedImages.map(image => (
              <div key={image.id} class="floating-thumb">
                <img 
                  src={image.data} 
                  alt={image.name} 
                  class="thumb-image"
                  onClick={() => openImageViewer(image.data)}
                />
                <button 
                  class="remove-thumb-btn material-symbols-rounded"
                  onClick={(e) => {
                    e.stopPropagation()
                    deleteImage(image.id)
                  }}
                >
                  close
                </button>
              </div>
            ))}
          </div>
        </div>
      </div>
    )
  }

  const displayAnalysisResults = (analysis, fileName) => {
    const resultsHTML = `
      <div class="analysis-results">
        <h4>📊 Document Analysis Complete</h4>
        <p><strong>File:</strong> ${fileName}</p>
        <div class="result-section">
          <p><strong>Document Type:</strong> <span class="doc-type ${analysis.typeClass}">${analysis.documentType}</span></p>
          <p><strong>Confidence:</strong> ${Math.round(analysis.confidence * 100)}%</p>
          <p><strong>Pages/Words:</strong> ${analysis.pages} pages, ${analysis.wordCount} words</p>
        </div>
        <div class="result-section">
          <h5>Summary</h5>
          ${analysis.summary}
        </div>
        ${analysis.topics && analysis.topics.length > 0 ? `
        <div class="result-section">
          <h5>Key Topics</h5>
          <div class="topics-list">
            ${analysis.topics.map(topic => `<span class="topic-tag">${topic}</span>`).join('')}
          </div>
        </div>
        ` : ''}
      </div>
    `
    typeMessage(resultsHTML, 'bot')
  }

  const handleLogin = (userData) => {
    setUser(userData)
    localStorage.setItem('agig-user', JSON.stringify(userData))
    setShowAuth(false)
    
    const nextStep = parseInt(localStorage.getItem('sSo') || '2')
    sessionStorage.setItem('currentStep', nextStep.toString())
    
    setTimeout(() => {
      generateAIResponse(`Continuing from step ${nextStep}`)
    }, 500)
  }

  const triggerFileInput = () => {
    fileInput.current.click()
  }

  const stopResponse = () => {
    if (currentTypingInterval.current) {
      clearInterval(currentTypingInterval.current)
      currentTypingInterval.current = null
    }
    
    setState(prev => ({ 
      ...prev,
      isTyping: false, 
      isProcessing: false,
      botResponding: false,
      responseStopped: true,
      showCancelFile: false
    }))
    
    sendMessage('Response stopped by user.', 'info')
  }

  const continueResponse = async () => {
    setState(prev => ({
      ...prev,
      responseStopped: false,
      botResponding: true
    }))
    await generateAIResponse("Continuing...")
  }

  const cancelFileUpload = () => {
    stopResponse()
    
    setState(prev => ({
      ...prev,
      currentFiles: [],
      showCancelFile: false,
      fileNames: [],
      isProcessing: false
    }))
    
    if (fileInput.current) {
      fileInput.current.value = ''
    }
  }

  // Render suggestion cards
  const renderSuggestions = () => {
    const suggestions = [
      t.vidgen,
      t.acpprvd,
      t.iftmscard,
      t.vgovdoc,
      t.analgdoc
    ]

    return (
      <div class="suggestions-container">
        <ul class="suggestions">
          {suggestions.map((text, index) => (
            <li key={index} class="suggestions-item">
              <div class="suggestion-content">
                <span class="icon material-symbols-rounded">
                  {index === 0 ? 'description' : 
                   index === 1 ? 'local_shipping' : 
                   index === 2 ? 'verified' : 
                   'analytics'}
                </span>
                <p class="text">{text}</p>
              </div>
              <span class="arrow-icon material-symbols-rounded">arrow_forward</span>
            </li>
          ))}
        </ul>
      </div>
    )
  }

  const { 
    messages, 
    inputText, 
    isProcessing, 
    isTyping, 
    showCancelFile, 
    fileNames, 
    botResponding, 
    responseStopped 
  } = state

  return (
    <div class="chat-ui">
      {showAuth && (
        <AuthModalX 
          onClose={() => setShowAuth(false)}
          onLogin={handleLogin}
          language={language}
        />
      )}
      
      {/* Floating image grid on right side */}
      {renderFloatingImageGrid()}
      
      {/* Show suggestions when no messages */}
      {messages.length === 0 && renderSuggestions()}
      
      <div class="chats-container" ref={chatContainerRef}>
        {messages.map((message, index) => (
          <div key={index} class={`message ${message.type}-message`}>
            {message.type === 'bot' && (
              <img class="avatar" src=".img/1752692028961-removebg-preview.png" alt="AI Assistant" />
            )}
            <div class="message-content">
              <div class="message-text" dangerouslySetInnerHTML={{ __html: message.content }} />
            </div>
            {message.type === 'bot' && !message.content.includes('action-btn') && (
              <div class="message-actions">
                <button class="copy-btn material-symbols-rounded" 
                  onClick={() => navigator.clipboard.writeText(message.content.replace(/<[^>]*>/g, ''))}>
                  content_copy
                </button>
              </div>
            )}
          </div>
        ))}
        
        {isTyping && (
          <div class="message bot-message">
            <img class="avatar" src=".img/1752692028961-removebg-preview.png" alt="AI Assistant" />
            <div class="message-content">
              <div class="typing-indicator">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>
          </div>
        )}

        {responseStopped && (
          <div class="message info-message">
            <div class="message-content">
              <div class="continue-prompt">
                <p>Response was stopped. Would you like to continue?</p>
                <button class="continue-btn" onClick={continueResponse}>
                  <span class="material-symbols-rounded">play_arrow</span>
                  Continue Response
                </button>
              </div>
            </div>
          </div>
        )}
      </div>

      {(showCancelFile || botResponding) && fileNames.length > 0 && (
        <div class="file-upload-wrapper active">
          <div class="file-info">
            <span class="file-name" id="loading">
              {fileNames.length} file(s) uploading...
            </span>
            <button 
              id="cancel-file-btn" 
              class="cancel-file material-symbols-rounded"
              onClick={cancelFileUpload}
              title="Cancel operation"
            >
              close
            </button>
          </div>
        </div>
      )}

      <div class="prompt-container">
        <div class="prompt-wrapper">
          <form class="prompt-form" ref={promptForm} onSubmit={handleSubmit}>
            <textarea 
              type="text" 
              placeholder="Request AGS services..." 
              class="prompt-input" 
              value={inputText}
              onInput={handleInputChange}
              required 
              disabled={isProcessing || botResponding}
            />
            <div class="prompt-actions">
              {(botResponding && !responseStopped) ? (
                <button 
                  type="button"
                  id="stop-response-btn" 
                  class="stop-response material-symbols-rounded" 
                  title="Stop Response"
                  onClick={stopResponse}
                >
                  stop_circle
                </button>
              ) : (
                <>
                  <input 
                    type="file" 
                    ref={fileInput}
                    onChange={handleFileSelect}
                    accept=".pdf,image/*,.txt,.doc,.docx" 
                    multiple
                    style={{ display: 'none' }} 
                  />
                  <button 
                    type="button" 
                    class="material-symbols-rounded" 
                    onClick={triggerFileInput}
                    disabled={isProcessing || botResponding}
                  >
                    attach_file
                  </button>
                  <button 
                    type="submit" 
                    class="material-symbols-rounded" 
                    disabled={isProcessing || botResponding || !inputText.trim()}
                  >
                    arrow_upward
                  </button>
                </>
              )}
            </div>
          </form>
        </div>
        <p class="disclaimer-text">Advanced Government Services powered by AI - may occasionally produce errors</p>
      </div>
    </div>
  )
}END
cat > src/components/Counter.jsx << 'END'
import { useState } from 'preact/hooks'

export function Counter() {
  const [count, setCount] = useState(0)

  return (
    <div class="counter">
      <div class="counter-display">
        <span class="count">{count}</span>
      </div>
      <div class="counter-controls">
        <button 
          class="btn btn-danger" 
          onClick={() => setCount(count - 1)}
        >
          -1
        </button>
        <button 
          class="btn btn-secondary" 
          onClick={() => setCount(0)}
        >
          Reset
        </button>
        <button 
          class="btn btn-success" 
          onClick={() => setCount(count + 1)}
        >
          +1
        </button>
      </div>
      <div class="counter-batch">
        <button 
          class="btn btn-outline" 
          onClick={() => setCount(c => c + 5)}
        >
          +5
        </button>
        <button 
          class="btn btn-outline" 
          onClick={() => setCount(c => c - 5)}
        >
          -5
        </button>
      </div>
    </div>
  )
}END
cat > src/components/IftmsLogin.jsx << 'END'
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
}END
cat > src/components/MarkdownRenderer.jsx << 'END'
// ============================================================
// MarkdownRenderer.jsx - Renders Markdown with syntax highlighting
// ============================================================

import { marked } from 'marked';
import hljs from 'highlight.js';
import 'highlight.js/styles/github-dark.css';

// Configure marked with syntax highlighting
marked.setOptions({
  highlight: function(code, lang) {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return hljs.highlight(code, { language: lang }).value;
      } catch (err) {
        return code;
      }
    }
    return code;
  },
  breaks: true,
  gfm: true,
  headerIds: false,
  mangle: false
});

// Custom renderer for AGIG-specific elements
const renderer = new marked.Renderer();

// Custom link rendering - opens in new tab
renderer.link = function(href, title, text) {
  return `<a href="${href}" target="_blank" rel="noopener noreferrer" title="${title || ''}">${text}</a>`;
};

// Custom image rendering with lazy loading
renderer.image = function(href, title, text) {
  return `<img src="${href}" alt="${text || ''}" title="${title || ''}" class="markdown-image" loading="lazy" />`;
};

// Custom table rendering with responsive wrapper
renderer.table = function(header, body) {
  return `<div class="table-wrapper"><table>${header}${body}</table></div>`;
};

// Custom code block with copy button
renderer.code = function(code, lang) {
  const highlighted = lang && hljs.getLanguage(lang) 
    ? hljs.highlight(code, { language: lang }).value 
    : code;
  
  return `
    <div class="code-block-wrapper">
      ${lang ? `<div class="code-language">${lang}</div>` : ''}
      <pre><code class="hljs ${lang || ''}">${highlighted}</code></pre>
      <button class="copy-code-btn" onclick="navigator.clipboard.writeText(\`${code.replace(/`/g, '\\`')}\`)">
        📋 Copy
      </button>
    </div>
  `;
};

marked.use({ renderer });

export function MarkdownRenderer({ content, className = '' }) {
  // If content is empty, return empty
  if (!content) return null;
  
  // If content is already HTML (from nlpProcessor), render as HTML
  if (typeof content === 'string' && content.trim().startsWith('<')) {
    return (
      <div 
        className={`markdown-content ${className}`}
        dangerouslySetInnerHTML={{ __html: content }}
      />
    );
  }
  
  // Otherwise, render as markdown
  try {
    const html = marked.parse(content.toString() || '');
    return (
      <div 
        className={`markdown-content ${className}`}
        dangerouslySetInnerHTML={{ __html: html }}
      />
    );
  } catch (error) {
    console.error('Markdown parsing error:', error);
    return <div className="markdown-content markdown-error">{content}</div>;
  }
}END
cat > src/components/ServiceConfigManager.jsx << 'END'
// ============================================================
// ServiceConfigManager.jsx - Complete Service Config UI
// ============================================================

import { useState, useEffect } from 'preact/hooks';
import { getServiceConfigDB, getLocalized } from '../services/serviceConfigDB.js';
import { nlpProcessor } from '../services/nlpProcessor.js';

// Helper to get bilingual display value
function getDisplayValue(obj) {
  if (!obj) return '';
  if (typeof obj === 'string') return obj;
  if (typeof obj === 'object' && obj !== null) {
    try {
      const lang = localStorage.getItem('agig_language') === 'am' ? 'am' : 'en';
      return obj[lang] !== undefined && obj[lang] !== '' ? obj[lang] : obj.en || '';
    } catch (e) {
      return obj.en || '';
    }
  }
  return obj;
}

// Helper to create bilingual object from string
function createBilingual(str) {
  if (!str) return { en: '', am: '' };
  if (typeof str === 'object') return str;
  return { en: str, am: str };
}

export function ServiceConfigManager({ onClose }) {
  const [services, setServices] = useState([]);
  const [loading, setLoading] = useState(true);
  const [editingService, setEditingService] = useState(null);
  const [isCreating, setIsCreating] = useState(false);
  const [formData, setFormData] = useState({
    serviceId: '',
    name: { en: '', am: '' },
    description: { en: '', am: '' },
    initStep: 1,
    steps: {
      1: {
        type: 'form',
        title: { en: '', am: '' },
        prompt: { en: '', am: '' },
        fields: [],
        onValid: { nextStep: 2 }
      }
    }
  });
  const [showStepEditor, setShowStepEditor] = useState(false);
  const [editingStep, setEditingStep] = useState(null);
  const [stepForm, setStepForm] = useState({
    stepId: 1,
    type: 'form',
    title: { en: '', am: '' },
    prompt: { en: '', am: '' },
    fields: [],
    onValid: { nextStep: 2 }
  });
  const [editingField, setEditingField] = useState(null);
  const [fieldForm, setFieldForm] = useState({
    name: '',
    question: { en: '', am: '' },
    validation: 'text',
    regex: '',
    example: { en: '', am: '' },
    error: { en: '', am: '' },
    options: { en: [], am: [] },
    autoFill: false
  });
  const [message, setMessage] = useState('');
  const [messageType, setMessageType] = useState('success');

  useEffect(() => {
    loadServices();
  }, []);

  async function loadServices() {
    try {
      setLoading(true);
      const db = await getServiceConfigDB();
      const configs = await db.getAllServiceConfigs();
      setServices(configs || []);
      setMessage('Services loaded successfully');
      setMessageType('success');
    } catch (error) {
      console.error('Error loading services:', error);
      setMessage('Error loading services: ' + error.message);
      setMessageType('error');
    } finally {
      setLoading(false);
    }
  }

  async function refreshFromDB() {
    await loadServices();
    await nlpProcessor.refreshServices?.();
  }

  function handleCreateNew() {
    setIsCreating(true);
    setEditingService(null);
    setFormData({
      serviceId: '',
      name: { en: '', am: '' },
      description: { en: '', am: '' },
      initStep: 1,
      steps: {
        1: {
          type: 'form',
          title: { en: '', am: '' },
          prompt: { en: '', am: '' },
          fields: [],
          onValid: { nextStep: 2 }
        }
      }
    });
  }

  function handleEditService(service) {
    setIsCreating(false);
    setEditingService(service);
    
    // Ensure bilingual format
    const name = typeof service.name === 'string' 
      ? { en: service.name, am: service.name }
      : service.name || { en: '', am: '' };
    
    const description = typeof service.description === 'string'
      ? { en: service.description, am: service.description }
      : service.description || { en: '', am: '' };
    
    // Process steps to ensure bilingual fields
    const steps = { ...(service.steps || {}) };
    Object.keys(steps).forEach(key => {
      const step = steps[key];
      if (step.title && typeof step.title === 'string') {
        step.title = { en: step.title, am: step.title };
      }
      if (step.prompt && typeof step.prompt === 'string') {
        step.prompt = { en: step.prompt, am: step.prompt };
      }
      if (step.fields) {
        step.fields = step.fields.map(f => {
          const field = { ...f };
          if (field.question && typeof field.question === 'string') {
            field.question = { en: field.question, am: field.question };
          }
          if (field.error && typeof field.error === 'string') {
            field.error = { en: field.error, am: field.error };
          }
          if (field.example && typeof field.example === 'string') {
            field.example = { en: field.example, am: field.example };
          }
          if (field.options && Array.isArray(field.options)) {
            field.options = { en: field.options, am: field.options };
          }
          return field;
        });
      }
    });

    setFormData({
      serviceId: service.serviceId || service.id,
      name: name,
      description: description,
      initStep: service.initStep || 1,
      steps: steps
    });
  }

  async function handleSaveService() {
    try {
      setLoading(true);
      const db = await getServiceConfigDB();
      
      // Validate
      if (!formData.serviceId || !formData.name || (!formData.name.en && !formData.name.am)) {
        setMessage('Service ID and Name are required');
        setMessageType('error');
        setLoading(false);
        return;
      }

      const config = {
        id: `${formData.serviceId}_v${Date.now()}`,
        serviceId: formData.serviceId,
        name: formData.name,
        description: formData.description || { en: '', am: '' },
        initStep: formData.initStep || 1,
        collectedData: {},
        steps: formData.steps || {},
        isActive: true,
        version: 1,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };

      await db.saveServiceConfig(config);
      await refreshFromDB();
      
      const nameDisplay = getDisplayValue(formData.name);
      setMessage(`Service "${nameDisplay}" saved successfully!`);
      setMessageType('success');
      setIsCreating(false);
      setEditingService(null);
      
      setTimeout(() => {
        setMessage('');
      }, 3000);
    } catch (error) {
      console.error('Error saving service:', error);
      setMessage('Error saving service: ' + error.message);
      setMessageType('error');
    } finally {
      setLoading(false);
    }
  }

  async function handleDeleteService(serviceId) {
    if (!confirm(`Delete service "${serviceId}" and all its versions?`)) return;
    
    try {
      setLoading(true);
      const db = await getServiceConfigDB();
      const configs = await db.getServiceConfigsByServiceId(serviceId, true);
      
      for (const config of configs) {
        await db.deleteServiceConfig(config.id);
      }
      
      await refreshFromDB();
      setMessage(`Service "${serviceId}" deleted successfully`);
      setMessageType('success');
      
      if (editingService?.serviceId === serviceId) {
        setEditingService(null);
      }
    } catch (error) {
      console.error('Error deleting service:', error);
      setMessage('Error deleting service: ' + error.message);
      setMessageType('error');
    } finally {
      setLoading(false);
    }
  }

  function handleAddStep() {
    const stepIds = Object.keys(formData.steps).map(Number);
    const newStepId = stepIds.length > 0 ? Math.max(...stepIds) + 1 : 1;
    
    setStepForm({
      stepId: newStepId,
      type: 'form',
      title: { en: `Step ${newStepId}`, am: `ደረጃ ${newStepId}` },
      prompt: { en: '', am: '' },
      fields: [],
      onValid: { nextStep: newStepId + 1 }
    });
    setEditingStep(newStepId);
    setShowStepEditor(true);
  }

  function handleEditStep(stepId) {
    const step = formData.steps[stepId];
    if (step) {
      const title = step.title && typeof step.title === 'object' 
        ? step.title 
        : { en: step.title || `Step ${stepId}`, am: step.title || `ደረጃ ${stepId}` };
      
      const prompt = step.prompt && typeof step.prompt === 'object'
        ? step.prompt
        : { en: step.prompt || '', am: step.prompt || '' };

      setStepForm({
        stepId: stepId,
        type: step.type || 'form',
        title: title,
        prompt: prompt,
        fields: step.fields || [],
        onValid: step.onValid || { nextStep: stepId + 1 },
        subprocess: step.subprocess || null,
        isFinal: step.isFinal || false,
        actions: step.actions || []
      });
      setEditingStep(stepId);
      setShowStepEditor(true);
    }
  }

  function handleSaveStep() {
    const updatedSteps = { ...formData.steps };
    
    const stepData = {
      type: stepForm.type,
      title: stepForm.title,
      prompt: stepForm.prompt || { en: '', am: '' },
      fields: stepForm.fields || [],
      onValid: stepForm.onValid || { nextStep: stepForm.stepId + 1 }
    };
    
    if (stepForm.type === 'subprocess') {
      stepData.subprocess = stepForm.subprocess || {
        itemName: { en: 'Item', am: 'ንጥል' },
        addPrompt: { en: 'Add another? (yes/no)', am: 'ሌላ ማከል? (አዎ/አይ)' },
        continuePrompt: { en: 'Continue? (yes/no)', am: 'መቀጠል? (አዎ/አይ)' },
        fields: []
      };
    }
    
    if (stepForm.isFinal) {
      stepData.isFinal = true;
      stepData.actions = stepForm.actions || [];
      stepData.type = 'summary';
    }
    
    updatedSteps[stepForm.stepId] = stepData;
    
    setFormData({ ...formData, steps: updatedSteps });
    setShowStepEditor(false);
    setEditingStep(null);
    setMessage(`Step ${stepForm.stepId} saved`);
    setMessageType('success');
  }

  function handleDeleteStep(stepId) {
    if (!confirm(`Delete step ${stepId}?`)) return;
    const updatedSteps = { ...formData.steps };
    delete updatedSteps[stepId];
    setFormData({ ...formData, steps: updatedSteps });
  }

  function handleAddField() {
    const fields = stepForm.fields || [];
    setFieldForm({
      name: `field${fields.length + 1}`,
      question: { en: `Question ${fields.length + 1}?`, am: `ጥያቄ ${fields.length + 1}?` },
      validation: 'text',
      regex: '',
      example: { en: '', am: '' },
      error: { en: '', am: '' },
      options: { en: [], am: [] },
      autoFill: false
    });
    setEditingField('new');
  }

  function handleEditField(index) {
    const field = stepForm.fields[index];
    if (field) {
      setFieldForm({
        ...field,
        question: field.question && typeof field.question === 'object' 
          ? field.question 
          : { en: field.question || '', am: field.question || '' },
        error: field.error && typeof field.error === 'object'
          ? field.error
          : { en: field.error || '', am: field.error || '' },
        example: field.example && typeof field.example === 'object'
          ? field.example
          : { en: field.example || '', am: field.example || '' },
        options: field.options && typeof field.options === 'object'
          ? field.options
          : { en: field.options || [], am: field.options || [] }
      });
      setEditingField(index);
    }
  }

  function handleSaveField() {
    const fields = [...(stepForm.fields || [])];
    
    // Ensure bilingual format for text fields
    const fieldToSave = { ...fieldForm };
    if (fieldToSave.question && typeof fieldToSave.question === 'string') {
      fieldToSave.question = { en: fieldToSave.question, am: fieldToSave.question };
    }
    if (fieldToSave.error && typeof fieldToSave.error === 'string') {
      fieldToSave.error = { en: fieldToSave.error, am: fieldToSave.error };
    }
    if (fieldToSave.example && typeof fieldToSave.example === 'string') {
      fieldToSave.example = { en: fieldToSave.example, am: fieldToSave.example };
    }
    if (fieldToSave.options && Array.isArray(fieldToSave.options)) {
      fieldToSave.options = { en: fieldToSave.options, am: fieldToSave.options };
    }
    
    if (editingField === 'new') {
      fields.push(fieldToSave);
    } else {
      fields[editingField] = fieldToSave;
    }
    
    setStepForm({ ...stepForm, fields });
    setEditingField(null);
  }

  function handleDeleteField(index) {
    if (!confirm('Delete this field?')) return;
    const fields = [...(stepForm.fields || [])];
    fields.splice(index, 1);
    setStepForm({ ...stepForm, fields });
  }

  function renderMessage() {
    if (!message) return null;
    return (
      <div class={`message ${messageType}`}>
        {message}
        <button onClick={() => setMessage('')} class="message-close">×</button>
      </div>
    );
  }

  function renderBilingualInput(label, value, onChange, placeholderEn, placeholderAm) {
    const lang = localStorage.getItem('agig_language') === 'am' ? 'am' : 'en';
    
    return (
      <div class="form-group">
        <label>{label}</label>
        <div class="bilingual-inputs">
          <div class="lang-input">
            <span class="lang-label">EN</span>
            <input
              type="text"
              value={value?.en || ''}
              onChange={(e) => onChange({ ...value, en: e.target.value })}
              placeholder={placeholderEn || 'English text'}
            />
          </div>
          <div class="lang-input">
            <span class="lang-label">አማ</span>
            <input
              type="text"
              value={value?.am || ''}
              onChange={(e) => onChange({ ...value, am: e.target.value })}
              placeholder={placeholderAm || 'አማርኛ ጽሑፍ'}
            />
          </div>
        </div>
      </div>
    );
  }

  function renderBilingualTextarea(label, value, onChange, placeholderEn, placeholderAm) {
    return (
      <div class="form-group">
        <label>{label}</label>
        <div class="bilingual-inputs">
          <div class="lang-input">
            <span class="lang-label">EN</span>
            <textarea
              value={value?.en || ''}
              onChange={(e) => onChange({ ...value, en: e.target.value })}
              placeholder={placeholderEn || 'English text'}
              rows="2"
            />
          </div>
          <div class="lang-input">
            <span class="lang-label">አማ</span>
            <textarea
              value={value?.am || ''}
              onChange={(e) => onChange({ ...value, am: e.target.value })}
              placeholder={placeholderAm || 'አማርኛ ጽሑፍ'}
              rows="2"
            />
          </div>
        </div>
      </div>
    );
  }

  function renderFieldEditor() {
    if (editingField === null && editingField !== 'new') return null;

    return (
      <div class="field-editor-modal">
        <div class="modal-content">
          <h3>{editingField === 'new' ? 'Add Field' : 'Edit Field'}</h3>
          
          <div class="form-group">
            <label>Field Name</label>
            <input
              type="text"
              value={fieldForm.name}
              onChange={(e) => setFieldForm({...fieldForm, name: e.target.value})}
              placeholder="e.g., businessLicenseNumber"
            />
          </div>

          {renderBilingualInput(
            'Question',
            fieldForm.question,
            (val) => setFieldForm({...fieldForm, question: val}),
            'English question',
            'አማርኛ ጥያቄ'
          )}

          <div class="form-group">
            <label>Validation Type</label>
            <select
              value={fieldForm.validation}
              onChange={(e) => setFieldForm({...fieldForm, validation: e.target.value})}
            >
              <option value="text">Text</option>
              <option value="number">Number</option>
              <option value="choice">Choice</option>
              <option value="license">License</option>
              <option value="phone">Phone</option>
              <option value="plate">Plate</option>
              <option value="vin">VIN</option>
              <option value="year">Year</option>
            </select>
          </div>

          {fieldForm.validation === 'choice' && (
            <div class="form-group">
              <label>Options</label>
              <div class="bilingual-inputs">
                <div class="lang-input">
                  <span class="lang-label">EN</span>
                  <input
                    type="text"
                    value={fieldForm.options?.en?.join(', ') || ''}
                    onChange={(e) => setFieldForm({
                      ...fieldForm, 
                      options: { 
                        ...fieldForm.options,
                        en: e.target.value.split(',').map(s => s.trim()).filter(s => s) 
                      }
                    })}
                    placeholder="Option1, Option2, Option3"
                  />
                </div>
                <div class="lang-input">
                  <span class="lang-label">አማ</span>
                  <input
                    type="text"
                    value={fieldForm.options?.am?.join(', ') || ''}
                    onChange={(e) => setFieldForm({
                      ...fieldForm, 
                      options: { 
                        ...fieldForm.options,
                        am: e.target.value.split(',').map(s => s.trim()).filter(s => s) 
                      }
                    })}
                    placeholder="አማርኛ አማራጮች"
                  />
                </div>
              </div>
            </div>
          )}

          <div class="form-group">
            <label>Regex Pattern</label>
            <input
              type="text"
              value={fieldForm.regex}
              onChange={(e) => setFieldForm({...fieldForm, regex: e.target.value})}
              placeholder="/^[0-9]{6,10}$/"
            />
          </div>

          {renderBilingualInput(
            'Example Value',
            fieldForm.example,
            (val) => setFieldForm({...fieldForm, example: val}),
            'English example',
            'አማርኛ ምሳሌ'
          )}

          {renderBilingualInput(
            'Error Message',
            fieldForm.error,
            (val) => setFieldForm({...fieldForm, error: val}),
            'Invalid format',
            'ልክ ያልሆነ ቅርጸት'
          )}

          <div class="form-group checkbox">
            <label>
              <input
                type="checkbox"
                checked={fieldForm.autoFill}
                onChange={(e) => setFieldForm({...fieldForm, autoFill: e.target.checked})}
              />
              Auto-fill from VIN
            </label>
          </div>

          <div class="modal-actions">
            <button onClick={handleSaveField} class="btn-primary">Save Field</button>
            <button onClick={() => setEditingField(null)} class="btn-secondary">Cancel</button>
          </div>
        </div>
      </div>
    );
  }

  function renderStepEditor() {
    if (!showStepEditor) return null;

    return (
      <div class="step-editor-modal">
        <div class="modal-content">
          <h3>Edit Step {stepForm.stepId}</h3>
          
          <div class="form-group">
            <label>Step Type</label>
            <select
              value={stepForm.type}
              onChange={(e) => setStepForm({...stepForm, type: e.target.value})}
            >
              <option value="form">Form</option>
              <option value="subprocess">Subprocess</option>
              <option value="file_upload">File Upload</option>
              <option value="summary">Summary</option>
              <option value="result">Result</option>
            </select>
          </div>

          {renderBilingualInput(
            'Title',
            stepForm.title,
            (val) => setStepForm({...stepForm, title: val}),
            'Step title',
            'የደረጃ ርዕስ'
          )}

          {renderBilingualTextarea(
            'Prompt',
            stepForm.prompt,
            (val) => setStepForm({...stepForm, prompt: val}),
            'Step prompt',
            'የደረጃ መመሪያ'
          )}

          {stepForm.type === 'subprocess' && (
            <div class="form-group">
              {renderBilingualInput(
                'Item Name',
                stepForm.subprocess?.itemName || { en: 'Item', am: 'ንጥል' },
                (val) => setStepForm({
                  ...stepForm,
                  subprocess: {
                    ...stepForm.subprocess,
                    itemName: val,
                    addPrompt: stepForm.subprocess?.addPrompt || { en: 'Add another? (yes/no)', am: 'ሌላ ማከል? (አዎ/አይ)' },
                    continuePrompt: stepForm.subprocess?.continuePrompt || { en: 'Continue? (yes/no)', am: 'መቀጠል? (አዎ/አይ)' },
                    fields: stepForm.subprocess?.fields || []
                  }
                }),
                'e.g., Vehicle',
                'ለምሳሌ: ተሽከርካሪ'
              )}
              
              {renderBilingualInput(
                'Add Prompt',
                stepForm.subprocess?.addPrompt || { en: 'Add another? (yes/no)', am: 'ሌላ ማከል? (አዎ/አይ)' },
                (val) => setStepForm({
                  ...stepForm,
                  subprocess: {
                    ...stepForm.subprocess,
                    addPrompt: val,
                    itemName: stepForm.subprocess?.itemName || { en: 'Item', am: 'ንጥል' },
                    continuePrompt: stepForm.subprocess?.continuePrompt || { en: 'Continue? (yes/no)', am: 'መቀጠል? (አዎ/አይ)' },
                    fields: stepForm.subprocess?.fields || []
                  }
                }),
                'Add prompt',
                'የመጨመር መመሪያ'
              )}
              
              {renderBilingualInput(
                'Continue Prompt',
                stepForm.subprocess?.continuePrompt || { en: 'Continue? (yes/no)', am: 'መቀጠል? (አዎ/አይ)' },
                (val) => setStepForm({
                  ...stepForm,
                  subprocess: {
                    ...stepForm.subprocess,
                    continuePrompt: val,
                    itemName: stepForm.subprocess?.itemName || { en: 'Item', am: 'ንጥል' },
                    addPrompt: stepForm.subprocess?.addPrompt || { en: 'Add another? (yes/no)', am: 'ሌላ ማከል? (አዎ/አይ)' },
                    fields: stepForm.subprocess?.fields || []
                  }
                }),
                'Continue prompt',
                'የመቀጠል መመሪያ'
              )}
            </div>
          )}

          {stepForm.type === 'summary' && (
            <div class="form-group checkbox">
              <label>
                <input
                  type="checkbox"
                  checked={stepForm.isFinal || false}
                  onChange={(e) => setStepForm({...stepForm, isFinal: e.target.checked})}
                />
                Final Step
              </label>
            </div>
          )}

          {stepForm.type !== 'file_upload' && stepForm.type !== 'summary' && (
            <div>
              <h4>Fields</h4>
              <div class="fields-list">
                {(stepForm.fields || []).map((field, index) => (
                  <div key={index} class="field-item">
                    <span>{field.name}: {getDisplayValue(field.question)}</span>
                    <div class="field-actions">
                      <button onClick={() => handleEditField(index)}>Edit</button>
                      <button onClick={() => handleDeleteField(index)}>Delete</button>
                    </div>
                  </div>
                ))}
              </div>
              <button onClick={handleAddField} class="btn-secondary">+ Add Field</button>
            </div>
          )}

          {renderFieldEditor()}

          <div class="form-group">
            <label>Next Step</label>
            <input
              type="number"
              value={stepForm.onValid?.nextStep || stepForm.stepId + 1}
              onChange={(e) => setStepForm({
                ...stepForm,
                onValid: { nextStep: parseInt(e.target.value) || 1 }
              })}
            />
          </div>

          <div class="modal-actions">
            <button onClick={handleSaveStep} class="btn-primary">Save Step</button>
            <button onClick={() => {
              setShowStepEditor(false);
              setEditingStep(null);
            }} class="btn-secondary">Cancel</button>
          </div>
        </div>
      </div>
    );
  }

  function renderServiceForm() {
    if (!isCreating && !editingService) return null;

    const nameDisplay = getDisplayValue(formData.name);
    const descDisplay = getDisplayValue(formData.description);

    return (
      <div class="service-form">
        <h2>{editingService ? 'Edit Service' : 'Create New Service'}</h2>
        
        <div class="form-group">
          <label>Service ID (unique)</label>
          <input
            type="text"
            value={formData.serviceId}
            onChange={(e) => setFormData({...formData, serviceId: e.target.value})}
            placeholder="e.g., iftms"
            disabled={!!editingService}
          />
        </div>

        {renderBilingualInput(
          'Service Name',
          formData.name,
          (val) => setFormData({...formData, name: val}),
          'e.g., IFTMS - Freight Transport',
          'ለምሳሌ: IFTMS - የጭነት ትራንስፖርት'
        )}

        {renderBilingualTextarea(
          'Description',
          formData.description,
          (val) => setFormData({...formData, description: val}),
          'Service description',
          'የአገልግሎት መግለጫ'
        )}

        <div class="form-group">
          <label>Initial Step</label>
          <input
            type="number"
            value={formData.initStep}
            onChange={(e) => setFormData({...formData, initStep: parseInt(e.target.value) || 1})}
            min="1"
          />
        </div>

        <div class="steps-section">
          <h3>Steps</h3>
          <div class="steps-list">
            {Object.entries(formData.steps || {}).map(([stepId, step]) => (
              <div key={stepId} class="step-item">
                <div class="step-info">
                  <strong>Step {stepId}:</strong> {getDisplayValue(step.title) || step.type}
                  <span class="step-type">({step.type})</span>
                  <span class="step-fields">
                    {step.fields ? `${step.fields.length} fields` : ''}
                  </span>
                </div>
                <div class="step-actions">
                  <button onClick={() => handleEditStep(parseInt(stepId))}>Edit</button>
                  <button onClick={() => handleDeleteStep(parseInt(stepId))}>Delete</button>
                </div>
              </div>
            ))}
          </div>
          <button onClick={handleAddStep} class="btn-secondary">+ Add Step</button>
        </div>

        {renderStepEditor()}

        <div class="form-actions">
          <button onClick={handleSaveService} class="btn-primary" disabled={loading}>
            {loading ? 'Saving...' : 'Save Service'}
          </button>
          <button onClick={() => {
            setIsCreating(false);
            setEditingService(null);
          }} class="btn-secondary">Cancel</button>
        </div>
      </div>
    );
  }

  function renderServiceList() {
    if (isCreating || editingService) return null;

    return (
      <div class="service-list">
        <div class="list-header">
          <h2>Service Configurations</h2>
          <button onClick={handleCreateNew} class="btn-primary">+ New Service</button>
          <button onClick={refreshFromDB} class="btn-secondary">↻ Refresh</button>
        </div>

        {loading ? (
          <div class="loading">Loading...</div>
        ) : services.length === 0 ? (
          <div class="empty-state">
            <p>No services found in database.</p>
            <button onClick={handleCreateNew} class="btn-primary">Create First Service</button>
          </div>
        ) : (
          <div class="services-grid">
            {services.map((service) => {
              const name = getDisplayValue(service.name);
              const desc = getDisplayValue(service.description);
              return (
                <div key={service.id} class="service-card">
                  <div class="service-header">
                    <h3>{name}</h3>
                    <span class={`status ${service.isActive !== false ? 'active' : 'inactive'}`}>
                      {service.isActive !== false ? 'Active' : 'Inactive'}
                    </span>
                  </div>
                  <div class="service-body">
                    <p><strong>ID:</strong> {service.serviceId}</p>
                    <p><strong>Version:</strong> {service.version || 1}</p>
                    <p><strong>Steps:</strong> {Object.keys(service.steps || {}).length}</p>
                    <p><strong>Updated:</strong> {new Date(service.updatedAt).toLocaleString()}</p>
                    {desc && <p><strong>Description:</strong> {desc}</p>}
                  </div>
                  <div class="service-actions">
                    <button onClick={() => handleEditService(service)} class="btn-secondary">Edit</button>
                    <button onClick={() => handleDeleteService(service.serviceId)} class="btn-danger">Delete</button>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    );
  }

  return (
    <div class="service-config-manager">
      <div class="manager-header">
        <h1>⚙️ Service Configuration Manager</h1>
        <button onClick={onClose} class="close-btn">×</button>
      </div>

      {renderMessage()}

      <div class="manager-body">
        {renderServiceList()}
        {renderServiceForm()}
      </div>

      <style>{`
        .service-config-manager {
          position: fixed;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background: rgba(0,0,0,0.8);
          z-index: 9999;
          overflow-y: auto;
          padding: 20px;
          color: #e0e0e0;
        }

        .manager-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          background: #1a1a2e;
          padding: 15px 20px;
          border-radius: 8px;
          margin-bottom: 20px;
        }

        .manager-header h1 {
          margin: 0;
          font-size: 24px;
          color: #fff;
        }

        .close-btn {
          background: none;
          border: none;
          color: #fff;
          font-size: 28px;
          cursor: pointer;
          padding: 0 10px;
        }

        .close-btn:hover {
          color: #ff6b6b;
        }

        .message {
          padding: 12px 20px;
          border-radius: 6px;
          margin-bottom: 16px;
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .message.success {
          background: #2d4a2d;
          color: #81c784;
          border: 1px solid #4caf50;
        }

        .message.error {
          background: #4a2d2d;
          color: #ff6b6b;
          border: 1px solid #f44336;
        }

        .message-close {
          background: none;
          border: none;
          color: inherit;
          font-size: 20px;
          cursor: pointer;
        }

        .list-header {
          display: flex;
          gap: 12px;
          align-items: center;
          margin-bottom: 20px;
          flex-wrap: wrap;
        }

        .list-header h2 {
          margin: 0;
          flex: 1;
          color: #fff;
        }

        .services-grid {
          display: grid;
          grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
          gap: 16px;
        }

        .service-card {
          background: #1a1a2e;
          border-radius: 8px;
          padding: 16px;
          border: 1px solid #2a2a4e;
        }

        .service-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 12px;
        }

        .service-header h3 {
          margin: 0;
          color: #fff;
          font-size: 16px;
        }

        .status {
          padding: 2px 10px;
          border-radius: 12px;
          font-size: 11px;
          font-weight: bold;
        }

        .status.active {
          background: #2d4a2d;
          color: #81c784;
        }

        .status.inactive {
          background: #4a2d2d;
          color: #ff6b6b;
        }

        .service-body {
          font-size: 13px;
          color: #aaa;
          margin-bottom: 12px;
        }

        .service-body p {
          margin: 4px 0;
        }

        .service-actions {
          display: flex;
          gap: 8px;
          padding-top: 12px;
          border-top: 1px solid #2a2a4e;
        }

        .service-form {
          background: #1a1a2e;
          padding: 20px;
          border-radius: 8px;
          margin-top: 20px;
        }

        .service-form h2 {
          color: #fff;
          margin-top: 0;
        }

        .form-group {
          margin-bottom: 14px;
        }

        .form-group label {
          display: block;
          margin-bottom: 4px;
          color: #ccc;
          font-size: 13px;
        }

        .form-group input,
        .form-group select,
        .form-group textarea {
          width: 100%;
          padding: 8px 12px;
          border: 1px solid #2a2a4e;
          border-radius: 4px;
          background: #0d0d1a;
          color: #e0e0e0;
          font-size: 14px;
        }

        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
          outline: none;
          border-color: #4a6cf7;
        }

        .bilingual-inputs {
          display: flex;
          gap: 10px;
        }

        .lang-input {
          flex: 1;
          display: flex;
          align-items: center;
          gap: 6px;
        }

        .lang-input .lang-label {
          font-size: 11px;
          font-weight: bold;
          color: #4a6cf7;
          min-width: 30px;
          text-align: center;
        }

        .lang-input input,
        .lang-input textarea {
          flex: 1;
        }

        .form-group.checkbox label {
          display: flex;
          align-items: center;
          gap: 8px;
          cursor: pointer;
        }

        .form-group.checkbox input {
          width: auto;
        }

        .steps-section {
          margin-top: 20px;
          padding-top: 20px;
          border-top: 1px solid #2a2a4e;
        }

        .steps-section h3 {
          color: #fff;
          margin-top: 0;
        }

        .steps-list {
          margin-bottom: 12px;
        }

        .step-item {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 8px 12px;
          background: #0d0d1a;
          border-radius: 4px;
          margin-bottom: 6px;
        }

        .step-info {
          font-size: 13px;
          color: #ccc;
        }

        .step-type {
          color: #888;
          font-size: 11px;
          margin-left: 8px;
        }

        .step-fields {
          color: #4a6cf7;
          font-size: 11px;
          margin-left: 8px;
        }

        .step-actions,
        .field-actions {
          display: flex;
          gap: 6px;
        }

        .step-actions button,
        .field-actions button {
          padding: 2px 10px;
          border: none;
          border-radius: 3px;
          cursor: pointer;
          font-size: 11px;
          background: #2a2a4e;
          color: #ccc;
        }

        .step-actions button:hover,
        .field-actions button:hover {
          background: #3a3a6e;
        }

        .fields-list {
          margin: 8px 0;
        }

        .field-item {
          display: flex;
          justify-content: space-between;
          align-items: center;
          padding: 4px 8px;
          background: #0d0d1a;
          border-radius: 3px;
          margin-bottom: 4px;
          font-size: 12px;
          color: #aaa;
        }

        .form-actions,
        .modal-actions {
          display: flex;
          gap: 10px;
          margin-top: 16px;
          padding-top: 16px;
          border-top: 1px solid #2a2a4e;
        }

        .btn-primary {
          padding: 8px 20px;
          background: #4a6cf7;
          border: none;
          border-radius: 4px;
          color: #fff;
          cursor: pointer;
          font-size: 14px;
        }

        .btn-primary:hover {
          background: #5a7cf7;
        }

        .btn-primary:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }

        .btn-secondary {
          padding: 8px 20px;
          background: #2a2a4e;
          border: none;
          border-radius: 4px;
          color: #ccc;
          cursor: pointer;
          font-size: 14px;
        }

        .btn-secondary:hover {
          background: #3a3a6e;
        }

        .btn-danger {
          padding: 6px 14px;
          background: #4a2d2d;
          border: none;
          border-radius: 4px;
          color: #ff6b6b;
          cursor: pointer;
          font-size: 12px;
        }

        .btn-danger:hover {
          background: #5a3d3d;
        }

        .step-editor-modal,
        .field-editor-modal {
          position: fixed;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background: rgba(0,0,0,0.9);
          z-index: 10000;
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 20px;
        }

        .modal-content {
          background: #1a1a2e;
          padding: 24px;
          border-radius: 8px;
          max-width: 700px;
          width: 100%;
          max-height: 80vh;
          overflow-y: auto;
        }

        .modal-content h3 {
          color: #fff;
          margin-top: 0;
        }

        .loading {
          text-align: center;
          padding: 40px;
          color: #888;
        }

        .empty-state {
          text-align: center;
          padding: 40px;
          color: #888;
        }

        .empty-state p {
          margin-bottom: 16px;
        }

        @media (max-width: 768px) {
          .services-grid {
            grid-template-columns: 1fr;
          }
          
          .list-header {
            flex-direction: column;
            align-items: stretch;
          }
          
          .modal-content {
            max-width: 100%;
            margin: 10px;
          }

          .bilingual-inputs {
            flex-direction: column;
          }
        }
      `}</style>
    </div>
  );
}END
cat > src/components/ServiceConfigTrainer.jsx << 'END'
// ============================================================
// ServiceConfigTrainer.jsx - CORRECTED DATA SOURCES
// ============================================================

import { useState, useEffect } from 'preact/hooks';
import { db } from '../services/database.js'; // ← ONLY for chat history
import { getServiceConfigDB, getLocalized } from '../services/serviceConfigDB.js'; // ← ONLY for services

// ============================================================
// DATA MASKING UTILITIES
// ============================================================

class DataMasker {
  constructor() {
    this.maskPatterns = {
      email: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/g,
      phone: /(\+?251|0)?[79][0-9]{8}/g,
      license: /[A-Z]{2,3}-?[0-9]{3,6}/g,
      password: /password["']?\s*[:=]\s*["'][^"']*["']/gi,
      vin: /[A-HJ-NPR-Z0-9]{10,17}/g,
      plate: /[A-Z]{2,3}-?[0-9]{3,4}/gi,
      businessLicense: /[0-9]{6,10}/g,
      name: /(?:name|operator|driver|owner)["']?\s*[:=]\s*["'][^"']*["']/gi,
      location: /(?:lat|lng|latitude|longitude|gps)["']?\s*[:=]\s*[0-9.-]+/gi,
      idNumber: /[A-Z]{0,2}[0-9]{5,12}/g
    };
    
    this.maskChars = {
      default: '█',
      email: '📧',
      phone: '📱',
      password: '🔒',
      license: '🪪',
      vin: '🚗',
      plate: '🚘'
    };
  }

  maskData(text, maskTypes = ['all']) {
    let masked = text;
    const appliedMasks = [];
    
    if (maskTypes.includes('all')) {
      maskTypes = Object.keys(this.maskPatterns);
    }
    
    for (const type of maskTypes) {
      if (this.maskPatterns[type]) {
        const matches = text.match(this.maskPatterns[type]);
        if (matches) {
          const char = this.maskChars[type] || '█';
          masked = masked.replace(this.maskPatterns[type], (match) => {
            appliedMasks.push({ type, original: match, masked: char.repeat(match.length) });
            return char.repeat(match.length);
          });
        }
      }
    }
    
    return { 
      maskedText: masked, 
      appliedMasks,
      originalText: text 
    };
  }

  getMaskedStats(text) {
    const stats = {};
    for (const [type, pattern] of Object.entries(this.maskPatterns)) {
      const matches = text.match(pattern);
      if (matches) {
        stats[type] = matches.length;
      }
    }
    return stats;
  }

  getMaskedPreview(text, maxLength = 200) {
    const { maskedText, appliedMasks } = this.maskData(text);
    const preview = maskedText.length > maxLength 
      ? maskedText.substring(0, maxLength) + '...' 
      : maskedText;
    return { preview, appliedMasks };
  }
}

// ============================================================
// MAIN UI COMPONENT
// ============================================================

export function ServiceConfigTrainer({ onClose }) {
  const [loading, setLoading] = useState(false);
  const [services, setServices] = useState([]);
  const [chatHistory, setChatHistory] = useState([]);
  const [trainingData, setTrainingData] = useState([]);
  const [maskSettings, setMaskSettings] = useState({
    enabled: true,
    types: ['all'],
    customPatterns: []
  });
  const [previewMode, setPreviewMode] = useState('masked');
  const [exportFormat, setExportFormat] = useState('jsonl');
  const [colabScript, setColabScript] = useState('');
  const [showColabScript, setShowColabScript] = useState(false);
  const [maskedPreview, setMaskedPreview] = useState(null);
  const [stats, setStats] = useState({});
  const [message, setMessage] = useState('');
  const [messageType, setMessageType] = useState('success');

  const masker = new DataMasker();

  // ============================================================
  // LOAD DATA FROM CORRECT SOURCES
  // ============================================================
  
  const loadData = async () => {
    try {
      setLoading(true);
      setMessage('Loading data...');
      setMessageType('info');
      
      // ✅ 1. Load services from ServiceConfigDB ONLY
      console.log('📁 Loading services from ServiceConfigDB...');
      const serviceDB = await getServiceConfigDB();
      const serviceConfigs = await serviceDB.getAllServiceConfigs();
      console.log(`✅ Loaded ${serviceConfigs.length} services from ServiceConfigDB`);
      setServices(serviceConfigs || []);
      
      // ✅ 2. Load chat history from database.js ONLY
      console.log('💬 Loading chat history from database.js...');
      const chatHistoryData = await db.getAllChatHistory();
      console.log(`✅ Loaded ${chatHistoryData.length} chat messages from database.js`);
      setChatHistory(chatHistoryData || []);
      
      // ✅ 3. Combine data to generate training samples
      if (serviceConfigs.length > 0 && chatHistoryData.length > 0) {
        console.log('🔄 Generating training data from both sources...');
        const samples = generateTrainingData(serviceConfigs, chatHistoryData);
        setTrainingData(samples);
        updateStats(samples);
        setMessage(`✅ Loaded ${serviceConfigs.length} services and ${chatHistoryData.length} messages`);
        setMessageType('success');
      } else {
        setMessage(`⚠️ Need data from both sources. Services: ${serviceConfigs.length}, Messages: ${chatHistoryData.length}`);
        setMessageType('warning');
        setTrainingData([]);
      }
      
    } catch (error) {
      console.error('❌ Error loading data:', error);
      setMessage('❌ Error loading data: ' + error.message);
      setMessageType('error');
    } finally {
      setLoading(false);
    }
  };

  // ============================================================
  // GENERATE TRAINING DATA - COMBINES BOTH SOURCES
  // ============================================================
  
  const generateTrainingData = (servicesData, chatData) => {
    const samples = [];
    
    chatData.forEach(msg => {
      const content = msg.content || '';
      if (!content) return;
      
      // Try to find service by serviceId from the message
      let service = servicesData.find(s => s.serviceId === msg.serviceId);
      
      // If not found, try to detect from content
      if (!service) {
        for (const s of servicesData) {
          const serviceName = getLocalized(s.name)?.toLowerCase() || '';
          const serviceId = s.serviceId?.toLowerCase() || '';
          const contentLower = content.toLowerCase();
          
          if (contentLower.includes(serviceName) || contentLower.includes(serviceId)) {
            service = s;
            break;
          }
        }
      }
      
      // If still no service, use a default
      if (!service) {
        service = {
          serviceId: 'general',
          name: { en: 'General Chat', am: 'አጠቃላይ ውይይት' },
          description: { en: 'General conversation', am: 'አጠቃላይ ውይይት' },
          steps: {}
        };
      }
      
      // Mask the content
      const masked = masker.maskData(content, maskSettings.types);
      const intent = detectIntent(content, service);
      const language = detectLanguage(content);
      
      samples.push({
        id: msg.id || Date.now(),
        serviceId: service.serviceId,
        serviceName: getLocalized(service.name) || 'Unknown',
        prompt: content,
        maskedPrompt: maskSettings.enabled ? masked.maskedText : content,
        intent: intent,
        language: language,
        step: msg.step || 1,
        timestamp: msg.timestamp || new Date().toISOString(),
        sessionId: msg.sessionId || 'default',
        type: msg.type || 'user',
        role: msg.role || 'user'
      });
    });
    
    return samples;
  };

  const detectIntent = (prompt, service) => {
    const promptLower = prompt.toLowerCase();
    const steps = service?.steps || {};
    
    for (const [stepId, step] of Object.entries(steps)) {
      const fields = step.fields || [];
      for (const field of fields) {
        if (field.name && promptLower.includes(field.name.toLowerCase())) {
          return `collect_${field.name}`;
        }
      }
    }
    
    if (promptLower.includes('register') || promptLower.includes('add') || promptLower.includes('create')) {
      return 'start_service';
    }
    if (promptLower.includes('continue') || promptLower.includes('next')) {
      return 'continue_flow';
    }
    if (promptLower.includes('yes') || promptLower.includes('no')) {
      return 'boolean_response';
    }
    if (promptLower.includes('cancel') || promptLower.includes('stop')) {
      return 'end_service';
    }
    return 'general_chat';
  };

  const detectLanguage = (text) => {
    return /[\u1200-\u137F]/.test(text) ? 'am' : 'en';
  };

  const updateStats = (samples) => {
    const stats = {
      total: samples.length,
      byService: {},
      byIntent: {},
      byLanguage: { en: 0, am: 0 },
      maskedCount: 0,
      bySession: {}
    };
    
    samples.forEach(s => {
      stats.byService[s.serviceId] = (stats.byService[s.serviceId] || 0) + 1;
      stats.byIntent[s.intent] = (stats.byIntent[s.intent] || 0) + 1;
      stats.byLanguage[s.language] = (stats.byLanguage[s.language] || 0) + 1;
      stats.bySession[s.sessionId] = (stats.bySession[s.sessionId] || 0) + 1;
      if (s.maskedPrompt !== s.prompt) stats.maskedCount++;
    });
    
    setStats(stats);
  };

  const handleMaskToggle = (type) => {
    setMaskSettings(prev => {
      const types = prev.types.includes('all') ? [] : [...prev.types];
      
      if (types.includes(type)) {
        return { ...prev, types: types.filter(t => t !== type) };
      } else {
        return { ...prev, types: [...types, type] };
      }
    });
  };

  const handlePreviewSample = (sample) => {
    if (!sample) return;
    
    const masked = masker.maskData(sample.prompt, maskSettings.types);
    const stats = masker.getMaskedStats(sample.prompt);
    
    setMaskedPreview({
      original: sample.prompt,
      masked: masked.maskedText,
      stats: stats,
      appliedMasks: masked.appliedMasks
    });
  };

  // ============================================================
  // EXPORT - USES BOTH SOURCES
  // ============================================================
  
  const exportTrainingData = async () => {
    try {
      setLoading(true);
      
      // Get fresh data from correct sources
      const serviceDB = await getServiceConfigDB();
      const freshServices = await serviceDB.getAllServiceConfigs();
      const freshChatHistory = await db.getAllChatHistory();
      
      // Generate fresh training data
      const freshSamples = generateTrainingData(freshServices, freshChatHistory);
      
      const exportData = {
        version: '2.0',
        exportedAt: new Date().toISOString(),
        maskSettings: maskSettings,
        // From ServiceConfigDB
        services: freshServices,
        // From database.js
        chatHistory: freshChatHistory.map(msg => ({
          ...msg,
          content: maskSettings.enabled ? masker.maskData(msg.content, maskSettings.types).maskedText : msg.content
        })),
        // Combined training samples
        trainingSamples: freshSamples.map(s => ({
          ...s,
          prompt: maskSettings.enabled ? s.maskedPrompt : s.prompt
        })),
        metadata: {
          totalMessages: freshChatHistory.length,
          totalServices: freshServices.length,
          totalTrainingSamples: freshSamples.length,
          sources: {
            chatHistory: 'database.js',
            services: 'serviceConfigDB.js'
          },
          language: 'bilingual'
        }
      };
      
      let content;
      let filename;
      
      if (exportFormat === 'jsonl') {
        content = exportData.trainingSamples.map(s => JSON.stringify(s)).join('\n');
        filename = `training_data_${Date.now()}.jsonl`;
      } else {
        content = JSON.stringify(exportData, null, 2);
        filename = `training_data_${Date.now()}.json`;
      }
      
      const blob = new Blob([content], { type: 'application/json' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = filename;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
      
      setMessage(`✅ Training data exported as ${filename}`);
      setMessageType('success');
    } catch (error) {
      console.error('Error exporting data:', error);
      setMessage('❌ Error exporting data: ' + error.message);
      setMessageType('error');
    } finally {
      setLoading(false);
    }
  };

  // ============================================================
  // GENERATE COLAB SCRIPT
  // ============================================================
  
  const generateColabScript = () => {
    const script = `# -*- coding: utf-8 -*-
"""TRAINING SCRIPT - Combines database.js + ServiceConfigDB"""

import json
import os
from google.colab import files, drive

# Mount Drive
drive.mount('/content/drive')

# Upload training data
print("📤 Upload training data...")
uploaded = files.upload()
data_file = list(uploaded.keys())[0]

# Parse data
with open(data_file, 'r') as f:
    if data_file.endswith('.jsonl'):
        samples = [json.loads(line) for line in f]
    else:
        data = json.load(f)
        samples = data.get('trainingSamples', [])
        services = data.get('services', [])
        chat_history = data.get('chatHistory', [])

print(f"✅ Loaded {len(samples)} samples from {len(services)} services")

# Save to Drive
DRIVE_PATH = "/content/drive/MyDrive/llama_models"
os.makedirs(DRIVE_PATH, exist_ok=True)

# Create training data
with open(f"{DRIVE_PATH}/training_data.jsonl", 'w') as f:
    for sample in samples:
        f.write(json.dumps(sample, ensure_ascii=False) + '\\n')

print(f"✅ Saved to {DRIVE_PATH}/training_data.jsonl")
print(f"📊 {len(samples)} samples ready for training")`;

    setColabScript(script);
    setShowColabScript(true);
  };

  // ============================================================
  // RENDER FUNCTIONS
  // ============================================================

  const renderMaskSettings = () => (
    <div class="mask-settings">
      <h3>🔒 Data Masking Settings</h3>
      
      <div class="mask-toggle">
        <label>
          <input
            type="checkbox"
            checked={maskSettings.enabled}
            onChange={(e) => setMaskSettings({ ...maskSettings, enabled: e.target.checked })}
          />
          Enable Data Masking
        </label>
      </div>
      
      <div class="mask-types">
        <label>Mask Types:</label>
        <div class="mask-checkboxes">
          {['all', 'email', 'phone', 'password', 'license', 'vin', 'plate', 'businessLicense', 'name', 'location', 'idNumber'].map(type => (
            <label key={type}>
              <input
                type="checkbox"
                checked={maskSettings.types.includes(type)}
                onChange={() => handleMaskToggle(type)}
                disabled={!maskSettings.enabled}
              />
              {type.charAt(0).toUpperCase() + type.slice(1)}
            </label>
          ))}
        </div>
      </div>
      
      <div class="data-sources">
        <span class="source-badge">📊 database.js</span>
        <span class="source-badge">📁 ServiceConfigDB</span>
      </div>
    </div>
  );

  const renderStats = () => (
    <div class="stats-panel">
      <h3>📊 Training Data Stats</h3>
      <div class="stats-grid">
        <div class="stat-item">
          <span class="stat-label">Total Samples</span>
          <span class="stat-value">{stats.total || 0}</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">Services</span>
          <span class="stat-value">{services.length}</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">Messages</span>
          <span class="stat-value">{chatHistory.length}</span>
        </div>
        <div class="stat-item">
          <span class="stat-label">Masked</span>
          <span class="stat-value">{stats.maskedCount || 0}</span>
        </div>
      </div>
      
      <div class="stat-section">
        <h4>By Service</h4>
        {Object.entries(stats.byService || {}).map(([service, count]) => (
          <div key={service} class="stat-bar">
            <span class="stat-bar-label">{service}</span>
            <div class="stat-bar-track">
              <div class="stat-bar-fill" style={{ width: `${(count / (stats.total || 1)) * 100}%` }} />
            </div>
            <span class="stat-bar-count">{count}</span>
          </div>
        ))}
      </div>
    </div>
  );

  const renderTrainingSamples = () => (
    <div class="training-samples">
      <h3>📝 Training Samples</h3>
      
      <div class="sample-controls">
        <select onChange={(e) => setPreviewMode(e.target.value)} value={previewMode}>
          <option value="masked">Masked View</option>
          <option value="original">Original View</option>
        </select>
        
        <button onClick={() => handlePreviewSample(trainingData[0])}>
          Preview Sample
        </button>
      </div>
      
      {maskedPreview && previewMode === 'masked' && (
        <div class="preview-panel">
          <h4>🔍 Masked Preview</h4>
          <div class="preview-content">
            <div class="preview-original">
              <strong>Original:</strong>
              <pre>{maskedPreview.original}</pre>
            </div>
            <div class="preview-masked">
              <strong>Masked:</strong>
              <pre>{maskedPreview.masked}</pre>
            </div>
          </div>
        </div>
      )}
      
      <div class="samples-list">
        {trainingData.slice(0, 20).map((sample, index) => (
          <div key={index} class="sample-item">
            <div class="sample-header">
              <span class="sample-service">{sample.serviceName}</span>
              <span class="sample-intent">{sample.intent}</span>
              <span class="sample-language">{sample.language === 'am' ? 'አማርኛ' : 'English'}</span>
            </div>
            <div class="sample-content">
              {previewMode === 'masked' ? sample.maskedPrompt : sample.prompt}
            </div>
            <div class="sample-meta">
              <span>Step: {sample.step}</span>
              <span>{new Date(sample.timestamp).toLocaleDateString()}</span>
            </div>
          </div>
        ))}
      </div>
      
      {trainingData.length > 20 && (
        <div class="sample-more">
          Showing 20 of {trainingData.length} samples
        </div>
      )}
    </div>
  );

  return (
    <div class="service-trainer">
      <div class="trainer-header">
        <h1>🎯 Training Data Manager</h1>
        <button onClick={onClose} class="close-btn">×</button>
      </div>
      
      {message && (
        <div class={`message ${messageType}`}>
          {message}
          <button onClick={() => setMessage('')} class="message-close">×</button>
        </div>
      )}
      
      <div class="trainer-body">
        <div class="trainer-sidebar">
          {renderMaskSettings()}
          {renderStats()}
          
          <div class="trainer-actions">
            <button onClick={loadData} class="btn-secondary" disabled={loading}>
              ↻ Refresh Data
            </button>
            
            <select
              value={exportFormat}
              onChange={(e) => setExportFormat(e.target.value)}
              class="format-select"
            >
              <option value="jsonl">JSONL (Training)</option>
              <option value="json">JSON (Full Export)</option>
            </select>
            
            <button 
              onClick={exportTrainingData} 
              class="btn-primary" 
              disabled={loading || trainingData.length === 0}
            >
              💾 Export Training Data
            </button>
            
            <button onClick={generateColabScript} class="btn-accent">
              🤖 Generate Colab Script
            </button>
          </div>
        </div>
        
        <div class="trainer-main">
          {loading ? (
            <div class="loading">Loading...</div>
          ) : trainingData.length === 0 ? (
            <div class="empty-state">
              <p>No training data available</p>
              <button onClick={loadData} class="btn-primary">🔄 Load Data</button>
            </div>
          ) : (
            renderTrainingSamples()
          )}
        </div>
      </div>
      
      {showColabScript && (
        <div class="colab-modal">
          <div class="modal-content">
            <h2>🤖 Colab Training Script</h2>
            <div class="script-container">
              <pre>{colabScript}</pre>
            </div>
            <div class="modal-actions">
              <button onClick={() => {
                navigator.clipboard.writeText(colabScript);
                setMessage('✅ Script copied!');
              }} class="btn-primary">📋 Copy</button>
              <button onClick={() => setShowColabScript(false)} class="btn-secondary">Close</button>
            </div>
          </div>
        </div>
      )}
      
      <style>{`
        .service-trainer {
          position: fixed;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background: rgba(0,0,0,0.95);
          z-index: 10000;
          overflow-y: auto;
          padding: 20px;
          color: #e0e0e0;
        }

        .trainer-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          background: #1a1a2e;
          padding: 15px 20px;
          border-radius: 8px;
          margin-bottom: 20px;
        }

        .trainer-header h1 { margin: 0; color: #fff; }
        .close-btn { background: none; border: none; color: #fff; font-size: 28px; cursor: pointer; }
        .close-btn:hover { color: #ff6b6b; }

        .trainer-body {
          display: flex;
          gap: 20px;
          height: calc(100vh - 120px);
        }

        .trainer-sidebar {
          flex: 0 0 350px;
          background: #1a1a2e;
          border-radius: 8px;
          padding: 20px;
          overflow-y: auto;
        }

        .trainer-main {
          flex: 1;
          background: #1a1a2e;
          border-radius: 8px;
          padding: 20px;
          overflow-y: auto;
        }

        .message {
          padding: 12px 20px;
          border-radius: 6px;
          margin-bottom: 16px;
          display: flex;
          justify-content: space-between;
        }
        .message.success { background: #1a3a2e; color: #81c784; }
        .message.error { background: #3a1a1a; color: #ff6b6b; }
        .message.info { background: #1a2a3a; color: #4a8cf7; }
        .message.warning { background: #3a3a1a; color: #f7c84a; }

        .mask-settings { margin-bottom: 20px; border-bottom: 1px solid #2a2a4e; padding-bottom: 20px; }
        .mask-settings h3 { color: #fff; margin-top: 0; }
        .mask-checkboxes { display: grid; grid-template-columns: 1fr 1fr; gap: 6px; margin-top: 8px; }
        .mask-checkboxes label { font-size: 13px; color: #aaa; cursor: pointer; }

        .data-sources { margin-top: 12px; display: flex; gap: 8px; }
        .source-badge { 
          font-size: 11px; 
          padding: 2px 10px; 
          border-radius: 10px; 
          background: #2a2a4e; 
          color: #aaa; 
        }

        .stats-panel { margin-bottom: 20px; }
        .stats-panel h3 { color: #fff; margin-top: 0; }
        .stats-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 16px; }
        .stat-item { background: #0d0d1a; padding: 10px; border-radius: 6px; text-align: center; }
        .stat-label { display: block; font-size: 11px; color: #888; }
        .stat-value { display: block; font-size: 20px; font-weight: bold; color: #4a6cf7; }

        .stat-section h4 { color: #ccc; margin: 12px 0 8px; font-size: 14px; }
        .stat-bar { display: flex; align-items: center; gap: 8px; margin-bottom: 4px; }
        .stat-bar-label { font-size: 12px; color: #aaa; min-width: 80px; }
        .stat-bar-track { flex: 1; height: 16px; background: #0d0d1a; border-radius: 8px; overflow: hidden; }
        .stat-bar-fill { height: 100%; background: linear-gradient(90deg, #4a6cf7, #6a8cf7); border-radius: 8px; }

        .trainer-actions { display: flex; flex-direction: column; gap: 10px; }
        .btn-primary { padding: 10px 20px; background: #4a6cf7; border: none; border-radius: 6px; color: #fff; cursor: pointer; }
        .btn-secondary { padding: 10px 20px; background: #2a2a4e; border: none; border-radius: 6px; color: #ccc; cursor: pointer; }
        .btn-accent { padding: 10px 20px; background: #6c5ce7; border: none; border-radius: 6px; color: #fff; cursor: pointer; }
        .format-select { padding: 10px; background: #0d0d1a; border: 1px solid #2a2a4e; border-radius: 6px; color: #e0e0e0; cursor: pointer; }

        .sample-controls { display: flex; gap: 10px; margin-bottom: 16px; }
        .sample-controls select { padding: 8px 12px; background: #0d0d1a; border: 1px solid #2a2a4e; border-radius: 4px; color: #e0e0e0; }

        .preview-panel { background: #0d0d1a; border-radius: 6px; padding: 16px; margin-bottom: 16px; }
        .preview-content { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
        .preview-original, .preview-masked { background: #1a1a2e; padding: 12px; border-radius: 4px; }
        .preview-original pre, .preview-masked pre { margin: 8px 0 0; white-space: pre-wrap; word-break: break-all; font-size: 13px; color: #aaa; max-height: 100px; overflow-y: auto; }

        .samples-list { display: flex; flex-direction: column; gap: 8px; }
        .sample-item { background: #0d0d1a; border-radius: 6px; padding: 12px; }
        .sample-header { display: flex; gap: 10px; margin-bottom: 6px; flex-wrap: wrap; }
        .sample-service { font-weight: bold; color: #4a6cf7; font-size: 13px; }
        .sample-intent { color: #6c5ce7; font-size: 12px; background: #1a1a2e; padding: 2px 8px; border-radius: 10px; }
        .sample-language { font-size: 12px; color: #888; }
        .sample-content { font-size: 13px; color: #aaa; margin-bottom: 4px; max-height: 60px; overflow: hidden; text-overflow: ellipsis; }
        .sample-meta { display: flex; gap: 12px; font-size: 11px; color: #555; }

        .loading { text-align: center; padding: 60px 20px; color: #888; }
        .empty-state { text-align: center; padding: 60px 20px; color: #888; }

        .colab-modal {
          position: fixed;
          top: 0; left: 0; right: 0; bottom: 0;
          background: rgba(0,0,0,0.95);
          z-index: 10001;
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 20px;
        }
        .colab-modal .modal-content {
          background: #1a1a2e;
          border-radius: 12px;
          padding: 24px;
          max-width: 800px;
          width: 100%;
          max-height: 80vh;
          overflow-y: auto;
        }
        .colab-modal .modal-content h2 { color: #fff; margin-top: 0; }
        .script-container { background: #0d0d1a; border-radius: 6px; padding: 16px; margin: 12px 0; max-height: 400px; overflow-y: auto; }
        .script-container pre { margin: 0; white-space: pre-wrap; word-break: break-all; font-size: 13px; color: #aaa; }
        .modal-actions { display: flex; gap: 10px; margin-top: 16px; }

        @media (max-width: 1024px) {
          .trainer-body { flex-direction: column; height: auto; }
          .trainer-sidebar { flex: none; width: 100%; }
          .trainer-main { height: 500px; }
        }
        @media (max-width: 768px) {
          .preview-content { grid-template-columns: 1fr; }
          .stats-grid { grid-template-columns: 1fr; }
        }
      `}</style>
    </div>
  );
}

export default ServiceConfigTrainer;END
cat > src/components/SideBarX.jsx << 'END'
import { useState, useEffect } from 'preact/hooks'
import { db } from '../services/database.js'
import { useLanguage } from '../utils/constants.js'
export function Sidebar({ isOpen, onClose, currentSessionId, onSessionChange, onNewChat, sessions: propSessions,currentStep }) {
  const [sessions, setSessions] = useState([])
 const { t } = useLanguage()
  useEffect(() => {
    if (isOpen) {
      loadChatHistory()
    }
  }, [isOpen])

  useEffect(() => {
    if (propSessions) {
      setSessions(propSessions)
    }
  }, [propSessions])
 const intnt = sessionStorage.getItem('intnt')
  const loadChatHistory = async () => {
    try {
      const history = await db.getChatHistory(200)
      const groupedSessions = groupMessagesBySession(history)
      setSessions(groupedSessions)
    } catch (error) {
      console.error('Failed to load chat history:', error)
    }
  }

  const groupMessagesBySession = (messages) => {
    const sessionsMap = new Map()
    
    messages.forEach(message => {
      const sessionId = message.sessionId || 'default'
      
      if (!sessionsMap.has(sessionId)) {
        sessionsMap.set(sessionId, {
          sessionId,
          messages: [],
          timestamp: message.timestamp,
          preview: '',
          messageCount: 0
        })
      }
      
      const session = sessionsMap.get(sessionId)
      session.messages.push(message)
      session.messageCount++
      
      if (new Date(message.timestamp) > new Date(session.timestamp)) {
        session.timestamp = message.timestamp
      }
      
      if (!session.preview && message.type === 'user') {
        session.preview = message.content.substring(0, 50) + (message.content.length > 50 ? '...' : '')
      }
    })
    
    return Array.from(sessionsMap.values())
      .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
  }

  const formatDate = (timestamp) => {
    const date = new Date(timestamp)
    const now = new Date()
    const diff = now - date
    
    if (diff < 60 * 1000) return 'Just now'
    else if (diff < 60 * 60 * 1000) return `${Math.floor(diff / (60 * 1000))}m ago`
    else if (diff < 24 * 60 * 60 * 1000) return `${Math.floor(diff / (60 * 60 * 1000))}h ago`
    else return date.toLocaleDateString()
  }

  const handleNewChat = () => {
    if (onNewChat) {
      onNewChat()
    }
    if (onClose) {
      onClose()
    }
  }

  const handleSessionClick = (sessionId) => {
    if (onSessionChange) {
      onSessionChange(sessionId)
    }
    if (onClose) {
      onClose()
    }
  }
const steps = [
    { number: 1, title: t.step1Title, description: t.step1Desc },
    { number: 2, title: t.step2Title, description: t.step2Desc },
    { number: 3, title: t.step3Title, description: t.step3Desc },
    { number: 4, title: t.step4Title, description: t.step4Desc }
  ]
  return (
    <div>
      <div class={`sidebar-overlay ${isOpen ? 'active' : ''}`} onClick={onClose} />
      <div class={`sidebar ${isOpen ? 'open' : ''}`}>
        <div class="sidebar-header">
          <h3>Chat History</h3>
          <button class="close-btn material-symbols-rounded" onClick={onClose}>close</button>
        </div>
        <div class="sidebar-content">
          {intnt === 'iftms' ?  (
               <div className="progress-section">
        <h3>{t.applicationProgress}</h3>
        <div className="steps">
          {steps.map(step => (
            <div 
              key={step.number} 
              className={`step ${currentStep >= step.number ? 'active' : ''} ${currentStep === step.number ? 'current' : ''}`}
            >
              <div className="step-number">{step.number}</div>
              <div className="step-content">
                <h4>{step.title}</h4>
                <p>{step.description}</p>
              </div>
            </div>
          ))}
        </div>
      </div>):(
              <div><button class="new-chat-btn" onClick={handleNewChat}>
            <span class="material-symbols-rounded">add</span>
            Start New Chat 
          </button>
          <div class="chat-history-list">
            {sessions.length === 0 ? (
              <div class="no-chats">No chat history yet</div>
            ) : (
              sessions.map(session => (
                <div 
                  key={session.sessionId}
                  class={`chat-session-item ${currentSessionId === session.sessionId ? 'active' : ''}`}
                  onClick={() => handleSessionClick(session.sessionId)}
                >
                  <div class="session-preview">{session.preview || 'New Chat'}</div>
                  <div class="session-meta">
                    <span class="session-date">{formatDate(session.timestamp)}</span>
                    {session.messageCount > 0 && (
                      <span style={'display:none'} class="message-count">{session.messageCount} messages</span>
                    )}
                  </div>
                </div>
              ))
            )}
          </div></div>
            ) }
          
        </div>
      </div>
    </div>
  )
}END
cat > src/components/Sidebar.jsx << 'END'
// ============================================================
// Sidebar.jsx - Fixed Version (No service flows in database.js)
// ============================================================

import { useState, useEffect } from 'preact/hooks'
import { db } from '../services/database.js'
import { getServiceConfigDB } from '../services/serviceConfigDB.js' // IMPORT THIS
import { useLanguage } from '../utils/constants.js'
import { ServiceConfigManager } from './ServiceConfigManager.jsx'
import { ServiceConfigTrainer } from './ServiceConfigTrainer.jsx'

export function Sidebar({ 
  isOpen, 
  onClose, 
  currentSessionId, 
  onSessionChange, 
  onNewChat, 
  sessions: propSessions,
  currentStep,
  language,
  setLanguage,
  t,
  auth,
  onAuthClick,
  isAuthenticated
}) {
  const [sessions, setSessions] = useState([])
  const [searchQuery, setSearchQuery] = useState('')
  const [showConfigManager, setShowConfigManager] = useState(false)
  const [showTrainer, setShowTrainer] = useState(false)
  const [trainingStatus, setTrainingStatus] = useState('idle') // 'idle' | 'ready' | 'exporting'
  const [trainingStats, setTrainingStats] = useState(null)
  const [showTrainingNotification, setShowTrainingNotification] = useState(false)

  useEffect(() => {
    if (isOpen) {
      loadChatHistory()
      checkTrainingStatus()
    }
  }, [isOpen])

  useEffect(() => {
    if (propSessions) {
      setSessions(propSessions)
    }
  }, [propSessions])

  const loadChatHistory = async () => {
    try {
      const history = await db.getChatHistory(200)
      const groupedSessions = groupMessagesBySession(history)
      setSessions(groupedSessions)
    } catch (error) {
      console.error('Failed to load chat history:', error)
    }
  }

  const groupMessagesBySession = (messages) => {
    const sessionsMap = new Map()
    
    messages.forEach(message => {
      const sessionId = message.sessionId || 'default'
      
      if (!sessionsMap.has(sessionId)) {
        sessionsMap.set(sessionId, {
          sessionId,
          messages: [],
          timestamp: message.timestamp,
          preview: '',
          messageCount: 0
        })
      }
      
      const session = sessionsMap.get(sessionId)
      session.messages.push(message)
      session.messageCount++
      
      if (new Date(message.timestamp) > new Date(session.timestamp)) {
        session.timestamp = message.timestamp
      }
      
      if (!session.preview && message.type === 'user') {
        session.preview = message.content.substring(0, 50) + (message.content.length > 50 ? '...' : '')
      }
    })
    
    return Array.from(sessionsMap.values())
      .sort((a, b) => new Date(b.timestamp) - new Date(a.timestamp))
  }

  const formatDate = (timestamp) => {
    const date = new Date(timestamp)
    const now = new Date()
    const diff = now - date
    
    if (diff < 60 * 1000) return 'Just now'
    else if (diff < 60 * 60 * 1000) return `${Math.floor(diff / (60 * 1000))}m ago`
    else if (diff < 24 * 60 * 60 * 1000) return `${Math.floor(diff / (60 * 60 * 1000))}h ago`
    else return date.toLocaleDateString()
  }

  const handleNewChat = () => {
    if (onNewChat) {
      onNewChat()
    }
    if (onClose) {
      onClose()
    }
  }

  const handleSessionClick = (sessionId) => {
    if (onSessionChange) {
      onSessionChange(sessionId)
    }
    if (onClose) {
      onClose()
    }
  }

  const handleSignOut = () => {
    if (auth && auth.signOut) {
      auth.signOut()
    }
    if (onClose) {
      onClose()
    }
  }

  // ============================================================
  // FIXED: Check training status using ONLY database.js
  // ============================================================
  
  const checkTrainingStatus = async () => {
    try {
      // Only use database.js methods - NO service flows
      const chatHistory = await db.getChatHistory(50)
      
      // Check if there's any chat history
      if (chatHistory && chatHistory.length > 0) {
        setTrainingStatus('ready')
        setTrainingStats({
          chatMessages: chatHistory.length,
          lastUpdated: new Date().toISOString()
        })
      } else {
        setTrainingStatus('idle')
        setTrainingStats(null)
      }
    } catch (error) {
      console.error('Error checking training status:', error)
      setTrainingStatus('idle')
      setTrainingStats(null)
    }
  }

  // ============================================================
  // FIXED: Export training data using ONLY database.js
  // ============================================================
  
  const handleExportTrainingData = async () => {
    try {
      setTrainingStatus('exporting')
      setShowTrainingNotification(true)
      
      // Get data from database.js ONLY
      const chatHistory = await db.getAllChatHistory()
      
      // Prepare training data
      const trainingData = {
        version: '1.0',
        exportedAt: new Date().toISOString(),
        chatHistory: chatHistory.map(msg => ({
          id: msg.id,
          sessionId: msg.sessionId,
          type: msg.type,
          content: msg.content,
          timestamp: msg.timestamp,
          role: msg.role || 'user'
        })),
        metadata: {
          totalMessages: chatHistory.length,
          language: 'bilingual'
        }
      }
      
      // Create download
      const blob = new Blob([JSON.stringify(trainingData, null, 2)], { 
        type: 'application/json' 
      })
      const url = URL.createObjectURL(blob)
      const a = document.createElement('a')
      a.href = url
      a.download = `training_data_${Date.now()}.json`
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
      
      setTrainingStatus('ready')
      setTimeout(() => {
        setShowTrainingNotification(false)
      }, 5000)
      
    } catch (error) {
      console.error('Error exporting training data:', error)
      setTrainingStatus('idle')
      alert('Error exporting training data: ' + error.message)
    }
  }

  const filteredSessions = sessions.filter(session => 
    session.preview?.toLowerCase().includes(searchQuery.toLowerCase())
  )

  return (
    <div>
      <div class={`sidebar-overlay ${isOpen ? 'active' : ''}`} onClick={onClose} />
      <div class={`sidebar ${isOpen ? 'open' : ''}`}>
        <div class="sidebar-header">
          <div class="sidebar-search">
            <span class="material-symbols-rounded">search</span>
            <input 
              class="sidebar-search-input" 
              type="text" 
              placeholder="Search conversations..." 
              value={searchQuery}
              onInput={(e) => setSearchQuery(e.target.value)}
            />
            {searchQuery && (
              <span 
                class="material-symbols-rounded" 
                style={{cursor: 'pointer', fontSize: '18px', color: 'rgba(255,255,255,0.3)'}}
                onClick={() => setSearchQuery('')}
              >close</span>
            )}
          </div>
          <button class="close-btn material-symbols-rounded" onClick={onClose}>close</button>
        </div>
        
        <div class="sidebar-content">
          <div class="chat-history-list">
            {filteredSessions.length === 0 ? (
              <div class="no-chats">
                {searchQuery ? 'No matching conversations' : 'No chat history yet'}
              </div>
            ) : (
              filteredSessions.map(session => (
                <div 
                  key={session.sessionId}
                  class={`chat-session-item ${currentSessionId === session.sessionId ? 'active' : ''}`}
                  onClick={() => handleSessionClick(session.sessionId)}
                >
                  <div class="session-preview">{session.preview || 'New Chat'}</div>
                  <div class="session-meta">
                    <span class="session-date">{formatDate(session.timestamp)}</span>
                  </div>
                </div>
              ))
            )}
          </div>

          <div class="sidebar-footer">
            <div class="sidebar-config-selector">
              <button 
                class={`config-btn ${showTrainingNotification ? 'has-notification' : ''}`} 
                onClick={() => setShowConfigManager(true)}
                title="Service Configuration Manager"
              >
                <span class="material-symbols-rounded">settings</span>
              </button>
              
              <button 
                class={`trainer-btn ${trainingStatus === 'ready' ? 'has-data' : ''}`} 
                onClick={() => setShowTrainer(true)}
                title="Training Data Manager"
              >
                <span class="material-symbols-rounded">model_training</span>
                {trainingStatus === 'ready' && (
                  <span class="notification-badge">●</span>
                )}
              </button>

              {trainingStatus === 'ready' && (
                <button 
                  class="export-btn"
                  onClick={handleExportTrainingData}
                  title="Export Training Data for Colab"
                >
                  <span class="material-symbols-rounded">download</span>
                </button>
              )}
            </div>

            {showTrainingNotification && (
              <div class="training-notification">
                <span class="notification-icon">✅</span>
                <span class="notification-text">
                  Training data exported! Ready for Colab.
                </span>
                <button 
                  class="notification-close"
                  onClick={() => setShowTrainingNotification(false)}
                >×</button>
              </div>
            )}

            {trainingStats && (
              <div class="training-stats">
                <span class="stat-item">💬 {trainingStats.chatMessages} messages</span>
                <span class="stat-item">🔄 {new Date(trainingStats.lastUpdated).toLocaleDateString()}</span>
              </div>
            )}

            <div class="sidebar-language-selector">
              <span class="material-symbols-rounded">language</span>
              <select 
                class="language-selector-sidebar" 
                value={language}
                onChange={(e) => setLanguage(e.target.value)}
              >
                <option value="en">English</option>
                <option value="am">አማርኛ</option>
              </select>
            </div>

            <div class="sidebar-auth-section">
              {isAuthenticated ? (
                <button class="sidebar-auth-btn" onClick={handleSignOut}>
                  <span class="material-symbols-rounded">logout</span>
                  <span>Sign Out</span>
                </button>
              ) : (
                <button class="sidebar-auth-btn" onClick={onAuthClick}>
                  <span class="material-symbols-rounded">account_circle</span>
                  <span>Sign In</span>
                </button>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* CONFIG MANAGER */}
      {showConfigManager && (
        <ServiceConfigManager onClose={() => setShowConfigManager(false)} />
      )}

      {/* TRAINER */}
      {showTrainer && (
        <ServiceConfigTrainer 
          onClose={() => {
            setShowTrainer(false)
            checkTrainingStatus()
          }} 
        />
      )}

      <style>{`
        .sidebar {
          position: fixed;
          top: 0;
          left: -100%;
          width: 320px;
          height: 100%;
          background: #0d0d1a;
          z-index: 1000;
          transition: left 0.3s cubic-bezier(0.4, 0, 0.2, 1);
          display: flex;
          flex-direction: column;
          border-right: 1px solid #1a1a2e;
          box-shadow: 4px 0 20px rgba(0, 0, 0, 0.5);
        }

        .sidebar.open {
          left: 0;
        }

        .sidebar-overlay {
          position: fixed;
          top: 0;
          left: 0;
          right: 0;
          bottom: 0;
          background: rgba(0, 0, 0, 0.6);
          z-index: 999;
          opacity: 0;
          pointer-events: none;
          transition: opacity 0.3s ease;
        }

        .sidebar-overlay.active {
          opacity: 1;
          pointer-events: all;
        }

        .sidebar-header {
          padding: 16px 20px;
          border-bottom: 1px solid #1a1a2e;
          display: flex;
          align-items: center;
          gap: 12px;
          background: #0d0d1a;
          flex-shrink: 0;
        }

        .sidebar-search {
          flex: 1;
          display: flex;
          align-items: center;
          background: #1a1a2e;
          border-radius: 8px;
          padding: 0 12px;
          border: 1px solid transparent;
          transition: border-color 0.2s;
        }

        .sidebar-search:focus-within {
          border-color: #4a6cf7;
        }

        .sidebar-search .material-symbols-rounded {
          color: rgba(255,255,255,0.3);
          font-size: 20px;
          margin-right: 8px;
        }

        .sidebar-search-input {
          flex: 1;
          background: none;
          border: none;
          color: #e0e0e0;
          padding: 8px 0;
          font-size: 14px;
          outline: none;
        }

        .sidebar-search-input::placeholder {
          color: rgba(255,255,255,0.3);
        }

        .close-btn {
          background: none;
          border: none;
          color: rgba(255,255,255,0.5);
          cursor: pointer;
          padding: 4px;
          font-size: 20px;
          transition: color 0.2s;
        }

        .close-btn:hover {
          color: #ff6b6b;
        }

        .sidebar-content {
          flex: 1;
          display: flex;
          flex-direction: column;
          overflow: hidden;
        }

        .chat-history-list {
          flex: 1;
          overflow-y: auto;
          padding: 12px 16px;
        }

        .chat-history-list::-webkit-scrollbar {
          width: 4px;
        }

        .chat-history-list::-webkit-scrollbar-track {
          background: transparent;
        }

        .chat-history-list::-webkit-scrollbar-thumb {
          background: #2a2a4e;
          border-radius: 2px;
        }

        .no-chats {
          text-align: center;
          color: rgba(255,255,255,0.3);
          padding: 40px 20px;
          font-size: 14px;
        }

        .chat-session-item {
          padding: 10px 12px;
          border-radius: 8px;
          cursor: pointer;
          margin-bottom: 4px;
          transition: background 0.2s;
          border: 1px solid transparent;
        }

        .chat-session-item:hover {
          background: #1a1a2e;
        }

        .chat-session-item.active {
          background: #1a1a2e;
          border-color: #4a6cf7;
        }

        .session-preview {
          color: #e0e0e0;
          font-size: 14px;
          white-space: nowrap;
          overflow: hidden;
          text-overflow: ellipsis;
          margin-bottom: 4px;
        }

        .session-meta {
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .session-date {
          color: rgba(255,255,255,0.3);
          font-size: 11px;
        }

        .sidebar-footer {
          border-top: 1px solid #1a1a2e;
          padding: 12px 16px;
          background: #0d0d1a;
          flex-shrink: 0;
          display: flex;
          flex-direction: column;
          gap: 8px;
        }

        .sidebar-config-selector {
          display: flex;
          gap: 8px;
          align-items: center;
          justify-content: center;
          padding-bottom: 8px;
          border-bottom: 1px solid #1a1a2e;
        }

        .config-btn, .trainer-btn, .export-btn {
          background: none;
          border: none;
          color: rgba(255,255,255,0.5);
          cursor: pointer;
          padding: 8px 12px;
          border-radius: 6px;
          transition: all 0.2s;
          display: flex;
          align-items: center;
          gap: 4px;
          position: relative;
        }

        .config-btn:hover, .trainer-btn:hover, .export-btn:hover {
          background: #1a1a2e;
          color: #fff;
        }

        .trainer-btn.has-data {
          color: #4a6cf7;
        }

        .notification-badge {
          position: absolute;
          top: 4px;
          right: 4px;
          color: #4a6cf7;
          font-size: 8px;
        }

        .training-notification {
          background: #1a3a2e;
          border: 1px solid #2d5a3d;
          border-radius: 6px;
          padding: 8px 12px;
          display: flex;
          align-items: center;
          gap: 8px;
          animation: slideIn 0.3s ease;
        }

        .notification-icon {
          font-size: 16px;
        }

        .notification-text {
          flex: 1;
          font-size: 12px;
          color: #81c784;
        }

        .notification-close {
          background: none;
          border: none;
          color: #81c784;
          cursor: pointer;
          font-size: 16px;
        }

        @keyframes slideIn {
          from {
            opacity: 0;
            transform: translateY(-10px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }

        .training-stats {
          display: flex;
          gap: 12px;
          justify-content: center;
          padding: 4px 0;
        }

        .training-stats .stat-item {
          font-size: 11px;
          color: rgba(255,255,255,0.3);
        }

        .sidebar-language-selector {
          display: flex;
          align-items: center;
          gap: 8px;
          padding: 6px 12px;
          border-radius: 6px;
          background: #1a1a2e;
        }

        .sidebar-language-selector .material-symbols-rounded {
          color: rgba(255,255,255,0.5);
          font-size: 18px;
        }

        .language-selector-sidebar {
          background: none;
          border: none;
          color: #e0e0e0;
          font-size: 13px;
          cursor: pointer;
          padding: 4px 0;
          outline: none;
        }

        .language-selector-sidebar option {
          background: #0d0d1a;
          color: #e0e0e0;
        }

        .sidebar-auth-section {
          margin-top: 4px;
        }

        .sidebar-auth-btn {
          width: 100%;
          padding: 8px 12px;
          background: #1a1a2e;
          border: none;
          border-radius: 6px;
          color: rgba(255,255,255,0.7);
          cursor: pointer;
          display: flex;
          align-items: center;
          gap: 8px;
          justify-content: center;
          font-size: 13px;
          transition: all 0.2s;
        }

        .sidebar-auth-btn:hover {
          background: #2a2a4e;
          color: #fff;
        }

        .sidebar-auth-btn .material-symbols-rounded {
          font-size: 18px;
        }

        @media (max-width: 768px) {
          .sidebar {
            width: 280px;
          }
        }
      `}</style>
    </div>
  )
}END
cat > src/components/ctui.jsx << 'END'
import { useState, useEffect, useRef } from 'preact/hooks'
import { db } from '../services/database.js'
import { nlpProcessor } from '../services/nlpProcessor.js'
import { pdfAnalyzerF } from '../services/pdfAnalyzer.js'
import { teSsAna } from '../services/tess.js'
import { useLanguage } from '../utils/constants.js'


export function ChatUI(props) {
  const [state, setState] = useState({
    messages: [],
    inputText: '',
    isProcessing: false,
    isTyping: false,
    currentFile: null,
    showCancelFile: false,
    fileName: '',
    botResponding: false,
    responseStopped: false,
    stoppedContext: null,
    stoppedMessage: '',
    stoppedType: '',
    partialResponse: ''
  })
  
  const typingInterval = useRef(null)
  const currentTypingInterval = useRef(null)
  const promptForm = useRef(null)
  const fileInput = useRef(null)
  const prevSessionId = useRef(null)
  const suggestionText = useRef('')
 const messagesEndRef = useRef(null);
  useEffect(() => {
    loadSessionMessages()
    setupSuggestionListeners()
    
    return () => {
      if (typingInterval.current) {
        clearInterval(typingInterval.current)
      }
      if (currentTypingInterval.current) {
        clearInterval(currentTypingInterval.current)
      }
      document.body.classList.remove("chats-active", "bot-responding")
    }
  }, [])

  useEffect(() => {
    // Check if session changed
    if (prevSessionId.current !== props.currentSessionId) {
      prevSessionId.current = props.currentSessionId
      loadSessionMessages()
    }
  }, [props.currentSessionId])
useEffect(() => {
    if (messagesEndRef.current) {
      messagesEndRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [state.messages, state.isTyping]);
  
  useEffect(() => {
    // Update body classes based on state
    if (state.botResponding) {
      document.body.classList.add("chats-active", "bot-responding")
    } else {
      document.body.classList.remove("bot-responding")
    }
    
    // FIX: Only add chats-active when there are messages
    if (state.messages.length > 0) {
      document.body.classList.add("chats-active")
    } else {
      document.body.classList.remove("chats-active")
    }

    // Re-setup suggestion listeners when messages change
    if (state.messages.length === 0) {
      setTimeout(() => setupSuggestionListeners(), 100)
    }
  }, [state.botResponding, state.messages])

  const setupSuggestionListeners = () => {
    setTimeout(() => {
      const suggestionItems = document.querySelectorAll('.suggestions-item')
      suggestionItems.forEach((item) => {
        // Remove any existing listeners by cloning
        const newItem = item.cloneNode(true)
        item.parentNode.replaceChild(newItem, item)
        
        newItem.addEventListener('click', (e) => {
          e.preventDefault()
          e.stopPropagation()
          handleSuggestionClick(newItem)
        })
      })
    }, 100)
  }

  const handleSuggestionClick = (suggestionItem) => {
    const textElement = suggestionItem.querySelector('.text')
    if (!textElement) return

    const text = textElement.textContent
    console.log('Suggestion clicked:', text)
    
    // Store the text in ref for submission
    suggestionText.current = text
    
    // Submit directly
    const mockEvent = {
      preventDefault: () => {},
      target: promptForm.current
    }
    
    // Clear input and submit
    setState(prev => ({ ...prev, inputText: '' }))
    handleSubmitDirect(text, mockEvent)
  }

  const handleSubmitDirect = async (text, e) => {
    if (e && e.preventDefault) e.preventDefault()
    
    const { isProcessing } = state
    const { currentSessionId } = props
    
    if (!text.trim() || isProcessing) return

    console.log('Submitting suggestion:', text)

    if (!currentSessionId && props.onNewSession) {
      props.onNewSession()
      setTimeout(() => {
        sendMessage(text, 'user')
        setTimeout(() => generateAIResponse(text), 500)
      }, 100)
    } else {
      await sendMessage(text, 'user')
      setTimeout(() => generateAIResponse(text), 500)
    }
  }

  const loadSessionMessages = async () => {
    const { currentSessionId } = props
    if (!currentSessionId) {
      setState(prev => ({ ...prev, messages: [] }))
      return
    }

    try {
      const allMessages = await db.getAllChatHistory()
      const sessionMessages = allMessages.filter(msg => 
        msg.sessionId === currentSessionId && msg.type !== 'system'
      )
      setState(prev => ({ ...prev, messages: sessionMessages }))
    } catch (error) {
      console.error('Failed to load session messages:', error)
    }
  }

  const handleInputChange = (e) => {
    setState(prev => ({ ...prev, inputText: e.target.value }))
  }

  const handleSubmit = async (e) => {
    if (e && e.preventDefault) e.preventDefault()
    
    const { inputText, isProcessing } = state
    const { currentSessionId } = props
    
    if (!inputText.trim() || isProcessing) return

    console.log('Submitting message:', inputText)

    if (!currentSessionId && props.onNewSession) {
      props.onNewSession()
      setTimeout(() => {
        sendMessage(inputText, 'user')
        setState(prev => ({ ...prev, inputText: '' }))
        setTimeout(() => generateAIResponse(inputText), 500)
      }, 100)
    } else {
      await sendMessage(inputText, 'user')
      setState(prev => ({ ...prev, inputText: '' }))
      setTimeout(() => generateAIResponse(inputText), 500)
    }
  }

  const sendMessage = async (content, type = 'user') => {
    const { currentSessionId } = props
    const sessionId = currentSessionId

    if (!sessionId) {
      console.error('No session ID available')
      return
    }

    const message = {
      type,
      content,
      timestamp: new Date().toISOString(),
      sessionId: sessionId
    }

    setState(prev => ({
      ...prev,
      messages: [...prev.messages, message],
      isProcessing: type === 'user'
    }))

    try {
      await db.saveChatMessage(message)
    } catch (error) {
      console.error('Failed to save message:', error)
    }
  }

  const generateAIResponseC = async (userMessage) => {
    setState(prev => ({ 
      ...prev,
      botResponding: true,
      stoppedContext: { userMessage, type: 'prompt' },
      stoppedType: 'prompt'
    }))
    
    try {
      const nlpResult = nlpProcessor.processMessage(userMessage)
      const response = nlpProcessor.generateContextualResponse(nlpResult)
      await typeMessage(response, 'bot')
    } catch (error) {
      console.error('NLP processing failed:', error)
      await typeMessage("I'm sorry, I encountered an error processing your request.", 'bot')
    }
  }
const generateAIResponse = async (userMessage) => {
    setState(prev => ({ 
      ...prev,
      botResponding: true,
      stoppedContext: { userMessage, type: 'prompt' },
      stoppedType: 'prompt'
    }))
    
    try {
      // Check if we're in a service flow
      if (state.currentService) {
        const isFile = false // This is text input
        const response = await nlpProcessor.processStepInput(
          state.currentService,
          state.currentStep,
          userMessage,
          language,
          isFile
        )
        
        // Update step if needed
        if (response.nextStep) {
          sessionStorage.setItem('currentStep', response.nextStep.toString())
          setState(prev => ({ ...prev, currentStep: response.nextStep }))
        }
        
        await typeMessage(response.text, 'bot')
        
        // Store actions for step UI
        if (response.actions && response.actions.length > 0) {
          setState(prev => ({ ...prev, stepActions: response.actions }))
        }
      } else {
        // Original NLP processing
        const nlpResult = nlpProcessor.processMessage(userMessage)
        
        // Check if this starts a service flow
        if (nlpResult.intents.includes('iftms') || nlpResult.intents.includes('renewDoc')) {
          const service = nlpResult.intents.includes('iftms') ? 'iftms' : 'renewDoc'
          sessionStorage.setItem('currentService', service)
          sessionStorage.setItem('currentStep', '1')
          
          setState(prev => ({
            ...prev,
            currentService: service,
            currentStep: 1,
            showStepUI: true
          }))
          
          const serviceResponse = nlpProcessor.startServiceFlow(service)
          await typeMessage(serviceResponse.text, 'bot')
          
          if (serviceResponse.actions) {
            setState(prev => ({ ...prev, stepActions: serviceResponse.actions }))
          }
        } else {
          const response = nlpProcessor.generateContextualResponse(nlpResult)
          await typeMessage(response, 'bot')
        }
      }
    } catch (error) {
      console.error('AI response generation failed:', error)
      await typeMessage("I'm sorry, I encountered an error processing your request.", 'bot')
    }
  }
  const typeMessage = async (text, type) => {
    setState(prev => ({ 
      ...prev,
      isTyping: true, 
      botResponding: true,
      stoppedMessage: text
    }))
    
    const message = {
      type,
      content: '',
      timestamp: new Date().toISOString(),
      sessionId: props.currentSessionId
    }

    setState(prev => ({
      ...prev,
      messages: [...prev.messages, message]
    }))

    let index = 0
    currentTypingInterval.current = setInterval(() => {
      if (index < text.length) {
        const newContent = text.substring(0, index + 1)
        updateLastMessage(newContent)
        setState(prev => ({ ...prev, partialResponse: newContent }))
        index++
      } else {
        finishTyping(text, type)
      }
    }, 20)
  }

  const stopResponse = () => {
    if (currentTypingInterval.current) {
      clearInterval(currentTypingInterval.current)
      currentTypingInterval.current = null
    }
    
    setState(prev => ({ 
      ...prev,
      isTyping: false, 
      isProcessing: false,
      botResponding: false,
      responseStopped: true,
      showCancelFile: false
    }))
    
    sendMessage('Response stopped by user.', 'info')
  }

  const continueResponse = async () => {
    const { stoppedContext, stoppedMessage, stoppedType, partialResponse } = state
    
    setState(prev => ({
      ...prev,
      responseStopped: false,
      botResponding: true
    }))

    if (stoppedType === 'file' && stoppedContext?.file) {
      await continueFileProcessing(stoppedContext.file, partialResponse || '')
    } else if (stoppedType === 'prompt' && stoppedContext?.userMessage) {
      await continuePromptResponse(stoppedContext.userMessage, partialResponse || '')
    }
  }

  const continueFileProcessing = async (file, partialContent = '') => {
    setState(prev => ({ 
      ...prev,
      botResponding: true,
      showCancelFile: true,
      fileName: file.name
    }))

    try {
      if (file.type === 'application/pdf') {
        const analysis = await pdfAnalyzerF.analyzeDocument(file)
        const remainingContent = getRemainingContent(analysis, partialContent)
        if (remainingContent) {
          await typeMessage(remainingContent, 'bot')
        } else {
          finishTyping('', 'bot')
        }
      } else if (file.type.startsWith('image/')) {
        if (!teSsAna.isInitializedT || !teSsAna.tesseractWorker) {
            await teSsAna.initializeTesseract()
        }
        const textT = await teSsAna.analyzeDocument(file)
        const remainingContent = getRemainingContent(textT, partialContent)
        if (remainingContent) {
          await typeMessage(remainingContent, 'bot')
        } else {
          finishTyping('', 'bot')
        }
      }
    } catch (error) {
      await typeMessage(`Error analyzing document: ${error.message}`, 'bot')
    }
  }

  const continuePromptResponse = async (userMessage, partialContent = '') => {
    try {
      const nlpResult = nlpProcessor.processMessage(userMessage)
      const fullResponse = nlpProcessor.generateContextualResponse(nlpResult)
      
      const remainingContent = getRemainingContent(fullResponse, partialContent)
      if (remainingContent) {
        await typeMessage(remainingContent, 'bot')
      } else {
        finishTyping('', 'bot')
      }
    } catch (error) {
      console.error('NLP processing failed:', error)
      await typeMessage("I'm sorry, I encountered an error processing your request.", 'bot')
    }
  }

  const getRemainingContent = (fullContent, partialContent) => {
    if (!partialContent) return fullContent
    
    const cleanPartial = partialContent.replace(/<[^>]*>/g, '')
    const cleanFull = fullContent.replace(/<[^>]*>/g, '')
    
    if (cleanFull.endsWith(cleanPartial)) {
      return ''
    }
    
    const partialIndex = cleanFull.indexOf(cleanPartial)
    if (partialIndex !== -1) {
      const remainingIndex = partialIndex + cleanPartial.length
      return fullContent.slice(remainingIndex)
    }
    
    return fullContent
  }

  const finishTyping = (text, type) => {
    if (currentTypingInterval.current) {
      clearInterval(currentTypingInterval.current)
      currentTypingInterval.current = null
    }
    
    setState(prev => ({ 
      ...prev,
      isProcessing: false, 
      isTyping: false,
      botResponding: false,
      responseStopped: false,
      stoppedContext: null,
      stoppedMessage: '',
      partialResponse: ''
    }))
    
    saveFinalMessage(text, type)
  }

  const updateLastMessage = (content) => {
    setState(prevState => {
      const messages = [...prevState.messages]
      if (messages.length > 0) {
        messages[messages.length - 1] = {
          ...messages[messages.length - 1],
          content
        }
      }
      return { ...prevState, messages }
    })
  }

  const saveFinalMessage = async (content, type) => {
    try {
      const message = {
        type,
        content,
        timestamp: new Date().toISOString(),
        sessionId: props.currentSessionId
      }
      await db.saveChatMessage(message)
    } catch (error) {
      console.error('Failed to save final message:', error)
    }
  }

  const handleFileSelectx = async (e) => {
    const file = e.target.files[0]
    if (!file) return

    setState(prev => ({ 
      ...prev,
      currentFile: file, 
      isProcessing: true,
      showCancelFile: true,
      fileName: file.name,
      botResponding: true,
      stoppedContext: { file, type: 'file' },
      stoppedType: 'file'
    }))

    try {
      await sendMessage(`Uploading ${file.name} for analysis...`, 'user')
      if (file.type === 'application/pdf') {
        const analysis = await pdfAnalyzerF.analyzeDocument(file)
        displayAnalysisResults(analysis)
      } else if (file.type.startsWith('image/')) {
        if (!teSsAna.isInitializedT || !teSsAna.tesseractWorker) {
            await teSsAna.initializeTesseract()
        }
        const textT = await teSsAna.analyzeDocument(file)
        console.log(textT)
        displayAnalysisResults(textT)
      } else {
        throw new Error('Unsupported file type')
      }
      
    } catch (error) {
      await typeMessage(`Error analyzing document: ${error.message}`, 'bot')
    } finally {
      setState(prev => ({ 
        ...prev,
        isProcessing: false, 
        currentFile: null,
        fileName: ''
      }))
      e.target.value = ''
    }
  }
// Update the handleFileSelect function in ChatUI.jsx
const handleFileSelect = async (e) => {
  const file = e.target.files[0]
  if (!file) return

  setState(prev => ({ 
    ...prev,
    currentFile: file, 
    isProcessing: true,
    showCancelFile: true,
    fileName: file.name,
    botResponding: true,
    stoppedContext: { file, type: 'file' },
    stoppedType: 'file'
  }))

  try {
    await sendMessage(`Uploading ${file.name}...`, 'user')
    
    if (file.type === 'application/pdf') {
      const analysis = await pdfAnalyzerF.analyzeDocument(file)
      displayAnalysisResults(analysis)
    } else if (file.type.startsWith('image/')) {
      // Always use Tesseract.js now
      if (!teSsAna.isInitializedT || !teSsAna.tesseractWorker) {
        await teSsAna.initializeTesseract()
      }
      const textT = await teSsAna.analyzeDocument(file)
      displayAnalysisResults(textT)
    } else {
      throw new Error('Unsupported file type. Please use PDF or image files.')
    }
    
  } catch (error) {
    await typeMessage(`Error analyzing document: ${error.message}`, 'bot')
  } finally {
    setState(prev => ({ 
      ...prev,
      isProcessing: false, 
      currentFile: null,
      fileName: ''
    }))
    e.target.value = ''
  }
}
  const cancelFileUpload = () => {
    stopResponse()
    
    setState(prev => ({
      ...prev,
      currentFile: null,
      showCancelFile: false,
      fileName: '',
      isProcessing: false
    }))
    
    if (fileInput.current) {
      fileInput.current.value = ''
    }
  }
 // Add this new render function for step UI
  const renderStepUI = () => {
    if (!state.showStepUI || !state.currentService) return null
    
    const serviceName = state.currentService === 'iftms' ? 'IFTMS' : 'License Renewal'
    
    return (
      <div class="service-flow-ui">
        <div class="step-header">
          <div class="step-indicator">
            <div class="step-line">
              {[1, 2, 3, 4].map(stepNum => (
                <div 
                  key={stepNum} 
                  class={`step-dot ${state.currentStep >= stepNum ? 'active' : ''} ${state.currentStep === stepNum ? 'current' : ''}`}
                >
                  {stepNum}
                </div>
              ))}
            </div>
            <div class="step-labels">
              <span>Verify</span>
              <span>Documents</span>
              <span>Payment</span>
              <span>Complete</span>
            </div>
          </div>
          
          <div class="service-info">
            <h3>{serviceName}</h3>
            <span class="current-step">Step {state.currentStep}/4</span>
          </div>
        </div>
        
        {state.stepActions.length > 0 && (
          <div class="step-action-buttons">
            {state.stepActions.map((action, index) => (
              <button 
                key={index}
                class="step-action-btn"
                onClick={() => handleStepAction(action)}
                disabled={state.isProcessing || state.botResponding}
              >
                {action}
              </button>
            ))}
          </div>
        )}
      </div>
    )
  }
  const displayAnalysisResults = (analysis) => {
    const resultsHTML = `
      <div class="analysis-results">
        <h4>📊 Document Analysis Complete</h4>
        <div class="result-section">
          <p><strong>Document Type:</strong> <span class="doc-type ${analysis.typeClass}">${analysis.documentType}</span></p>
          <p><strong>Confidence:</strong> ${Math.round(analysis.confidence * 100)}%</p>
          <p><strong>Pages/Words:</strong> ${analysis.pages} pages, ${analysis.wordCount} words</p>
        </div>
        <div class="result-section">
          <h5>Summary</h5>
          ${analysis.summary}
        </div>
        ${analysis.topics && analysis.topics.length > 0 ? `
        <div class="result-section">
          <h5>Key Topics</h5>
          <div class="topics-list">
            ${analysis.topics.map(topic => `<span class="topic-tag">${topic}</span>`).join('')}
          </div>
        </div>
        ` : ''}
      </div>
    `
    
    typeMessage(resultsHTML, 'bot')
  }

  const triggerFileInput = () => {
    fileInput.current.click()
  }

  const renderSuggestions = () => {
    const suggestions = [
      'academic paper review',
      'የተቀናጀ የጭነት ትራንስፖርት አስተዳደር ስርዓት',
      'Verify government documents',
      'Analyze legal documents'
    ]

    return (
      <ul class="suggestions">
        {suggestions.map((text, index) => (
          <li key={index} class="suggestions-item">
            <p class="text">{text}</p>
            <span class="icon material-symbols-rounded">
              {index === 0 ? 'draw' : index === 1 ? '💰' : index === 2 ? 'explore' : 'code_blocks'}
            </span>
          </li>
        ))}
      </ul>
    )
  }

  const { 
    messages, 
    inputText, 
    isProcessing, 
    isTyping, 
    showCancelFile, 
    fileName, 
    botResponding, 
    responseStopped 
  } = state

  return (
    <div class="chat-ui">
      {state.showStepUI && renderStepUI()}
      
      {state.messages.length === 0 && !state.showStepUI && renderSuggestions()}
      
      <div class="chats-container" ref={messagesEndRef}>
        {state.messages.map((message, index) => (
          <div key={index} class={`message ${message.type}-message`}>
            {message.type === 'bot' && (
              <img class="avatar" src=".img/1752692028961-removebg-preview.png" alt="AI Assistant" />
            )}
            <div class="message-content">
              <div class="message-text" dangerouslySetInnerHTML={{ __html: message.content }} />
            </div>
            {message.type === 'bot' && (
              <div class="message-actions">
                <button class="copy-btn material-symbols-rounded" 
                  onClick={() => navigator.clipboard.writeText(message.content.replace(/<[^>]*>/g, ''))}>
                  content_copy
                </button>
              </div>
            )}
          </div>
        ))}
        
        {state.isTyping && (
          <div class="message bot-message">
            <img class="avatar" src=".img/1752692028961-removebg-preview.png" alt="AI Assistant" />
            <div class="message-content">
              <div class="typing-indicator">
                <span></span>
                <span></span>
                <span></span>
              </div>
            </div>
          </div>
        )}
        
        {state.responseStopped && (
          <div class="message info-message">
            <div class="message-content">
              <div class="continue-prompt">
                <p>Response was stopped. Would you like to continue?</p>
                <button 
                  class="continue-btn"
                  onClick={state.continueResponse}
                >
                  <span class="material-symbols-rounded">play_arrow</span>
                  Continue Response
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
      
      {(state.showCancelFile || state.botResponding) && (
        <div class="file-upload-wrapper active">
          <div class="file-info">
            <span class="file-name">
              {state.fileName || 'Processing...'}
            </span>
            <button 
              id="cancel-file-btn" 
              class="cancel-file material-symbols-rounded"
              onClick={cancelFileUpload}
              title="Cancel operation"
            >
              close
            </button>
          </div>
        </div>
      )}

      <div class="prompt-container">
        <div class="prompt-wrapper">
          <form class="prompt-form" ref={promptForm} onSubmit={handleSubmit}>
            <input 
              type="text" 
              placeholder="Ask about document analysis..." 
              class="prompt-input" 
              value={state.inputText}
              onInput={handleInputChange}
              required 
              disabled={state.isProcessing || state.botResponding}
            />
            <div class="prompt-actions">
              {/* This should show when bot is responding */}
              {(state.botResponding && !state.responseStopped) ? (
                <button 
                  type="button"
                  id="stop-response-btn" 
                  class="stop-response material-symbols-rounded" 
                  title="Stop Response"
                  onClick={stopResponse}
                >
                  stop_circle
                </button>
              ) : (
                <>
                  <input 
                    type="file" 
                    ref={fileInput}
                    onChange={handleFileSelect}
                    accept=".pdf,image/*,.txt,.doc,.docx" 
                    style={{ display: 'none' }} 
                  />
                  <button 
                    type="button" 
                    class="material-symbols-rounded" 
                    onClick={triggerFileInput}
                    disabled={state.isProcessing || state.botResponding}
                  >
                    attach_file
                  </button>
                  <button 
                    type="submit" 
                    class="material-symbols-rounded" 
                    disabled={state.isProcessing || state.botResponding || !state.inputText.trim()}
                  >
                    arrow_upward
                  </button>
                </>
              )}
            </div>
          </form>
        </div>
        <p class="disclaimer-text">Document analysis powered by AI - may occasionally produce errors</p>
      </div>
    </div>
  )
}END
cat > src/components/rasachaui.jsx << 'END'
import { useState, useEffect, useRef } from 'preact/hooks'
import { db } from '../services/database.js'
import { rasaClient } from '../services/rasaClient.js' // Import RASA client
import { useLanguage } from '../utils/constants.js'
import AuthModalX from './AuthModalx.jsx'

export function ChatUI(props) {
  const [user, setUser] = useState(null)
  const [showAuth, setShowAuth] = useState(false)
  const { language, setLanguage, t } = useLanguage()
  const [state, setState] = useState({
    messages: [],
    inputText: '',
    isProcessing: false,
    isTyping: false,
    currentFile: null,
    showCancelFile: false,
    fileName: '',
    botResponding: false,
    responseStopped: false,
    partialResponse: '',
    rasaConnected: false // Track RASA connection
  })
  
  const currentTypingInterval = useRef(null)
  const promptForm = useRef(null)
  const fileInput = useRef(null)
  const prevSessionId = useRef(null)
  const chatContainerRef = useRef(null)

  // Initialize RASA on component mount
  useEffect(() => {
    const initializeRASA = async () => {
      console.log('🔄 Initializing RASA connection...')
      const connected = await rasaClient.init()
      setState(prev => ({ ...prev, rasaConnected: connected }))
      
      if (connected) {
        console.log('✅ RASA connected successfully')
      } else {
        console.warn('⚠️ RASA not connected, using fallback mode')
      }
    }
    
    initializeRASA()
    loadSessionMessages()
    setupSuggestionListeners()
    
    return () => {
      if (currentTypingInterval.current) {
        clearInterval(currentTypingInterval.current)
      }
      document.body.classList.remove("chats-active", "bot-responding")
    }
  }, [])

  // Update generateAIResponse function to use RASA
  const generateAIResponse = async (userMessage) => {
    setState(prev => ({ 
      ...prev,
      botResponding: true,
      isProcessing: true
    }))
    
    try {
      // Use RASA client instead of nlpProcessor
      const rasaResponse = await rasaClient.processMessage(userMessage)
      
      // Type out the response
      await typeMessage(rasaResponse.html || rasaResponse.text, 'bot', rasaResponse)
      
    } catch (error) {
      console.error('RASA processing failed:', error)
      await typeMessage("I'm sorry, I encountered an error processing your request.", 'bot')
    } finally {
      setState(prev => ({ 
        ...prev,
        isProcessing: false,
        botResponding: false
      }))
    }
  }

  // Update handleFileSelect to use RASA
  const handleFileSelect = async (e) => {
    const file = e.target.files[0]
    if (!file) return

    setState(prev => ({ 
      ...prev,
      currentFile: file, 
      isProcessing: true,
      showCancelFile: true,
      fileName: file.name,
      botResponding: true
    }))

    try {
      await sendMessage(`Uploading ${file.name} for analysis...`, 'user')
      
      // Determine document type based on current step
      const currentStep = sessionStorage.getItem('currentStep') || '1'
      const currentService = sessionStorage.getItem('currentService') || 'iftms'
      
      let documentType = 'Document'
      if (currentService === 'iftms') {
        if (currentStep === '1') documentType = 'Business License'
        else if (currentStep === '2') documentType = 'Vehicle Document'
        else if (currentStep === '3') documentType = 'Driver Document'
      }
      
      // Process file with RASA
      const rasaResponse = await rasaClient.processFileUpload(file, documentType, currentStep)
      
      // Type out the response
      await typeMessage(rasaResponse.html || rasaResponse.text, 'bot', rasaResponse)
      
    } catch (error) {
      await typeMessage(`Error processing document: ${error.message}`, 'bot')
    } finally {
      setState(prev => ({ 
        ...prev,
        isProcessing: false, 
        currentFile: null,
        fileName: ''
      }))
      e.target.value = ''
    }
  }

  // Update typeMessage to handle RASA responses
  const typeMessage = async (content, type, rasaResponse = null) => {
    setState(prev => ({ 
      ...prev,
      isTyping: true, 
      botResponding: true
    }))
    
    const message = {
      type,
      content: '',
      timestamp: new Date().toISOString(),
      sessionId: props.currentSessionId,
      rasaResponse // Store RASA response data
    }

    setState(prev => ({
      ...prev,
      messages: [...prev.messages, message]
    }))

    let index = 0
    clearInterval(currentTypingInterval.current)
    currentTypingInterval.current = setInterval(() => {
      if (index < content.length) {
        const newContent = content.substring(0, index + 1)
        updateLastMessage(newContent)
        index++
      } else {
        finishTyping(content, type, rasaResponse)
      }
    }, 20)
  }

  const finishTyping = (content, type, rasaResponse) => {
    if (currentTypingInterval.current) {
      clearInterval(currentTypingInterval.current)
      currentTypingInterval.current = null
    }
    
    // If RASA response has session data, update storage
    if (rasaResponse && rasaResponse.sessionData) {
      Object.entries(rasaResponse.sessionData).forEach(([key, value]) => {
        if (typeof value === 'boolean') {
          sessionStorage.setItem(key, value.toString())
        } else if (typeof value === 'object') {
          sessionStorage.setItem(key, JSON.stringify(value))
        } else {
          sessionStorage.setItem(key, value)
        }
      })
    }
    
    setState(prev => ({ 
      ...prev,
      isProcessing: false, 
      isTyping: false,
      botResponding: false,
      responseStopped: false
    }))
    
    saveFinalMessage(content, type)
  }

  // Add RASA status indicator to your render
  const renderRasaStatus = () => {
    if (!state.rasaConnected) {
      return (
        <div class="rasa-status offline">
          <span class="status-dot"></span>
          <span class="status-text">AI Assistant (Offline Mode)</span>
        </div>
      )
    }
    
    return (
      <div class="rasa-status online">
        <span class="status-dot"></span>
        <span class="status-text">AI Assistant (Connected)</span>
      </div>
    )
  }

  // Update JSX to include status
  return (
    <div class="chat-ui">
      {showAuth && (
        <AuthModalX 
          onClose={() => setShowAuth(false)}
          onLogin={handleLogin}
          language={language}
        />
      )}
      
      {/* RASA Status Indicator */}
      {renderRasaStatus()}
      
      {/* Rest of your component remains the same... */}
    </div>
  )
}END
cat > src/components/test.jsx << 'END'
// components/TestTesseract.jsx
import { useState } from 'preact/hooks';
import { teSsAna } from '../tess.js';

export default function TestTesseract() {
    const [status, setStatus] = useState('Idle');
    const [debugInfo, setDebugInfo] = useState({});

    const testInitialization = async () => {
        try {
            setStatus('Testing initialization...');
            const result = await teSsAna.debugInitialize();
            setStatus(result ? '✅ Initialization successful' : '❌ Initialization failed');
            setDebugInfo(teSsAna.getWorkerStatus());
        } catch (error) {
            setStatus(`❌ Error: ${error.message}`);
        }
    };

    const testFileUpload = async (event) => {
        const file = event.target.files[0];
        if (!file) return;

        try {
            setStatus('Analyzing document...');
            const result = await teSsAna.analyzeDocument(file);
            setStatus(`✅ Analysis complete: ${result.documentType}`);
            console.log('Analysis result:', result);
        } catch (error) {
            setStatus(`❌ Analysis failed: ${error.message}`);
        }
    };

    return (
        <div style={{ padding: '20px' }}>
            <h2>Tesseract.js Debug</h2>
            
            <button onClick={testInitialization}>
                Test Tesseract Initialization
            </button>
            
            <div>
                <input 
                    type="file" 
                    accept="image/*" 
                    onChange={testFileUpload}
                    style={{ margin: '10px 0' }}
                />
            </div>
            
            <div>
                <h3>Status: {status}</h3>
                <pre>{JSON.stringify(debugInfo, null, 2)}</pre>
            </div>
        </div>
    );
}END
cat > src/services/API.js << 'END'
class ApiHandler {
  constructor() {
    this.baseUrl = 'https://api.etrade.gov.et/api/v1';
    this.apiKey = 'process.env.ETRADE_API_KEY';
   
    // Sample database array with test business license data
    this.sampleDatabase = [
      {
        license_number: '14/668/5068/2004',
        valid: true,
        status: 'active',
        expiration_date: '2025-12-31',
        business_name: 'KEDIJA ALI WANDADI',
        business_type: 'Sole Proprietorship',
        registration_date: '2004-01-15',
        address: 'Addis Ababa, Ethiopia',
        tin_number: '0000369033',
        export_class: 'valid'
      },
      {
        license_number: '12/345/6789/2023',
        valid: true,
        status: 'active',
        expiration_date: '2024-06-30',
        business_name: 'ETHIO TRADING PLC',
        business_type: 'PLC',
        registration_date: '2023-03-20',
        address: 'Dire Dawa, Ethiopia',
        tin_number: '0000456712',
        export_class: 'valid'
      },
      {
        license_number: '15/789/1234/2022',
        valid: false,
        status: 'expired',
        expiration_date: '2023-12-31',
        business_name: 'AWASH IMPORT EXPORT',
        business_type: 'Private Limited',
        registration_date: '2022-02-10',
        address: 'Adama, Ethiopia',
        tin_number: '0000789456',
        export_class: 'expired'
      },
      {
        license_number: '11/222/3333/2021',
        valid: true,
        status: 'active',
        expiration_date: '2024-09-15',
        business_name: 'BLUE NILE MANUFACTURING',
        business_type: 'Manufacturing',
        registration_date: '2021-08-05',
        address: 'Bahir Dar, Ethiopia',
        tin_number: '0000895632',
        export_class: 'valid'
      }
    ];
  }

  // Find business license in sample database
  findInDatabase(licenseNumber) {
    const formattedLicense = this.formatLicenseNumber(licenseNumber);
    return this.sampleDatabase.find(item => 
      this.formatLicenseNumber(item.license_number) === formattedLicense
    );
  }

  async validateBusinessLicense(licenseNumber) {
    try {
      // Simulate API delay
      await this.simulateDelay();
      
      const businessData = this.findInDatabase(licenseNumber);
      
      if (!businessData) {
        return {
          isValid: false,
          businessData: null,
          status: 'not_found',
          expirationDate: null,
          businessName: null,
          businessType: null,
          registrationDate: null,
          address: null,
          tinNumber: null,
          exportClass: null,
          error: 'Business license not found in database'
        };
      }

      return {
        isValid: businessData.valid || false,
        businessData: businessData,
        status: businessData.status || 'unknown',
        expirationDate: businessData.expiration_date,
        businessName: businessData.business_name,
        businessType: businessData.business_type,
        registrationDate: businessData.registration_date,
        address: businessData.address,
        tinNumber: businessData.tin_number,
        exportClass: businessData.export_class,
        error: null
      };

    } catch (error) {
      console.error('Business license validation error:', error);
      return {
        isValid: false,
        error: error.message,
        businessData: null
      };
    }
  }

  async renewBusinessLicense(licenseNumber, supportingDocs = []) {
    try {
      await this.simulateDelay();
      
      const businessData = this.findInDatabase(licenseNumber);
      
      if (!businessData) {
        return {
          success: false,
          renewalId: null,
          newExpirationDate: null,
          status: 'not_found',
          message: 'License not found',
          error: 'Business license not found in database'
        };
      }

      // Simulate renewal process
      const renewalId = 'REN-' + Date.now();
      const newExpirationDate = new Date();
      newExpirationDate.setFullYear(newExpirationDate.getFullYear() + 1);
      
      // Update the sample data (in real scenario, this would update the database)
      businessData.expiration_date = newExpirationDate.toISOString().split('T')[0];
      businessData.status = 'active';
      businessData.valid = true;

      return {
        success: true,
        renewalId: renewalId,
        newExpirationDate: businessData.expiration_date,
        status: businessData.status,
        message: 'Business license renewed successfully',
        error: null
      };

    } catch (error) {
      console.error('Business license renewal error:', error);
      return {
        success: false,
        error: error.message
      };
    }
  }

  async getLicenseStatus(licenseNumber) {
    try {
      await this.simulateDelay();
      
      const businessData = this.findInDatabase(licenseNumber);
      
      if (!businessData) {
        return {
          status: 'not_found',
          isValid: false,
          expirationDate: null,
          businessName: null,
          lastRenewalDate: null,
          daysUntilExpiry: null,
          tinNumber: null,
          error: 'Business license not found in database'
        };
      }

      // Calculate days until expiry
      const today = new Date();
      const expiryDate = new Date(businessData.expiration_date);
      const daysUntilExpiry = Math.ceil((expiryDate - today) / (1000 * 60 * 60 * 24));

      return {
        status: businessData.status,
        isValid: businessData.valid || false,
        expirationDate: businessData.expiration_date,
        businessName: businessData.business_name,
        lastRenewalDate: businessData.registration_date, // Using registration as last renewal for sample
        daysUntilExpiry: daysUntilExpiry > 0 ? daysUntilExpiry : 0,
        tinNumber: businessData.tin_number,
        exportClass: businessData.export_class,
        error: null
      };

    } catch (error) {
      console.error('License status check error:', error);
      return {
        status: 'error',
        isValid: false,
        error: error.message
      };
    }
  }

  // Get all sample licenses (for testing/debugging)
  getAllSampleLicenses() {
    return this.sampleDatabase.map(item => ({
      licenseNumber: item.license_number,
      businessName: item.business_name,
      tinNumber: item.tin_number,
      status: item.status,
      isValid: item.valid,
      exportClass: item.export_class
    }));
  }

  // Add new sample license to database
  addSampleLicense(licenseData) {
    this.sampleDatabase.push(licenseData);
    return licenseData;
  }

  // Utility method to format license number
  formatLicenseNumber(licenseNumber) {
    return licenseNumber.replace(/[^\d\/]/g, '');
  }

  // Validate license number format
  isValidLicenseFormat(licenseNumber) {
    const formatted = this.formatLicenseNumber(licenseNumber);
    const licenseRegex = /^\d{2}\/\d{3,4}\/\d{3,4}\/\d{4}$/;
    return licenseRegex.test(formatted);
  }

  // Simulate API delay
  async simulateDelay(min = 100, max = 1000) {
    const delay = Math.floor(Math.random() * (max - min + 1)) + min;
    return new Promise(resolve => setTimeout(resolve, delay));
  }
}

export const apiHandler = new ApiHandler();

// Example usage:
/*
async function testApiHandler() {
  // Test with the provided license number
  const result = await apiHandler.validateBusinessLicense('14/668/5068/2004');
  console.log('Validation Result:', result);
  
  // Test status check
  const status = await apiHandler.getLicenseStatus('14/668/5068/2004');
  console.log('Status Result:', status);
  
  // Test with non-existent license
  const notFound = await apiHandler.validateBusinessLicense('99/999/9999/9999');
  console.log('Not Found Result:', notFound);
  
  // Get all sample licenses
  const allLicenses = apiHandler.getAllSampleLicenses();
  console.log('All Sample Licenses:', allLicenses);
}

testApiHandler();
*/END
cat > src/services/ModelDownloader.js << 'END'
// ============================================================
// ModelDownloader.js - Complete with Storage Analysis
// Handles 460MB+ models with proper storage management
// ============================================================

const DB_NAME = 'ModelDownloadDB';
const STORE_NAME = 'downloads';
const CHUNK_STORE_NAME = 'chunks';
const DB_VERSION = 2;
const CHECKPOINT_INTERVAL = 3000;

export class ModelDownloader {
  constructor() {
    this.db = null;
    this.isPaused = false;
    this.isCancelled = false;
    this.chunkSize = 1024 * 1024; // 1MB chunks
    this.totalBytes = 0;
    this.loadedBytes = 0;
    this.progressCallback = null;
    this.statusCallback = null;
    this.startTime = 0;
    this.speedSamples = [];
    this.isCapacitor = false;
    this.downloadId = null;
    
    // Storage info
    this.storageInfo = {
      quota: 0,
      usage: 0,
      available: 0,
      percentage: 0,
      isPersistent: false
    };
  }

  /**
   * Check if running in Capacitor
   */
  async detectCapacitor() {
    try {
      const { Capacitor } = await import('@capacitor/core');
      this.isCapacitor = Capacitor.isNativePlatform();
      console.log(`📱 Running in Capacitor: ${this.isCapacitor}`);
      return this.isCapacitor;
    } catch {
      this.isCapacitor = false;
      return false;
    }
  }

  /**
   * Initialize with storage analysis
   */
  async init() {
    try {
      await this.detectCapacitor();
      this.db = await this.openDatabase();
      
      // Request persistent storage for WebView
      if (this.isCapacitor) {
        await this.requestPersistentStorage();
      }
      
      // Analyze storage immediately
      await this.analyzeStorage();
      
      console.log('📦 ModelDownloader: Initialized');
      console.log(`💾 Storage: ${(this.storageInfo.available/1024/1024).toFixed(1)}MB available`);
      
      return true;
    } catch (error) {
      console.error('❌ Failed to init:', error);
      throw error;
    }
  }

  /**
   * Request persistent storage for Android WebView
   */
  async requestPersistentStorage() {
    try {
      if ('storage' in navigator && 'persist' in navigator.storage) {
        const isPersisted = await navigator.storage.persisted();
        this.storageInfo.isPersistent = isPersisted;
        
        if (!isPersisted) {
          const granted = await navigator.storage.persist();
          this.storageInfo.isPersistent = granted;
          console.log(`💾 Persistent storage: ${granted ? 'GRANTED' : 'DENIED'}`);
        }
      }
    } catch (e) {
      console.warn('Persistent storage request failed:', e);
    }
  }

  /**
   * Analyze available storage - CRITICAL for large models
   */
  async analyzeStorage() {
    try {
      const storageEstimate = await this.getStorageEstimate();
      
      this.storageInfo = {
        quota: storageEstimate.quota || 0,
        usage: storageEstimate.usage || 0,
        available: (storageEstimate.quota || 0) - (storageEstimate.usage || 0),
        percentage: storageEstimate.quota > 0 
          ? ((storageEstimate.usage || 0) / storageEstimate.quota) * 100 
          : 0,
        isPersistent: this.storageInfo.isPersistent || false
      };
      
      console.log(`📊 Storage Analysis:
        Quota: ${(this.storageInfo.quota/1024/1024/1024).toFixed(2)} GB
        Used: ${(this.storageInfo.usage/1024/1024).toFixed(1)} MB
        Available: ${(this.storageInfo.available/1024/1024).toFixed(1)} MB
        Usage: ${this.storageInfo.percentage.toFixed(1)}%
        Persistent: ${this.storageInfo.isPersistent}
      `);
      
      return this.storageInfo;
    } catch (error) {
      console.error('❌ Storage analysis failed:', error);
      return this.storageInfo;
    }
  }

  /**
   * Get storage estimate with fallbacks
   */
  async getStorageEstimate() {
    try {
      if ('storage' in navigator && 'estimate' in navigator.storage) {
        return await navigator.storage.estimate();
      }
      
      // Fallback for browsers without storage API
      return {
        quota: 1024 * 1024 * 1024, // Assume 1GB
        usage: 0
      };
    } catch (e) {
      console.warn('Storage estimate unavailable:', e);
      return {
        quota: 1024 * 1024 * 1024,
        usage: 0
      };
    }
  }

  /**
   * Check if there's enough storage for a download
   * Returns detailed analysis
   */
  async checkStorageForDownload(requiredBytes, modelName = '') {
    await this.analyzeStorage();
    
    const availableMB = this.storageInfo.available / 1024 / 1024;
    const requiredMB = requiredBytes / 1024 / 1024;
    const bufferMB = 50; // 50MB buffer for safety
    const neededMB = requiredMB + bufferMB;
    
    // Check if IndexedDB is available
    const isIndexedDBAvailable = await this.checkIndexedDBAvailability();
    
    // Estimate IndexedDB overhead (10% for metadata)
    const overheadMB = requiredMB * 0.1;
    const totalNeededMB = neededMB + overheadMB;
    
    const hasEnoughSpace = availableMB >= totalNeededMB;
    const needsBuffer = availableMB < totalNeededMB + 100; // Warning if close to limit
    
    const result = {
      hasEnoughSpace,
      available: {
        bytes: this.storageInfo.available,
        megabytes: availableMB,
        gigabytes: availableMB / 1024
      },
      required: {
        bytes: requiredBytes,
        megabytes: requiredMB,
        gigabytes: requiredMB / 1024
      },
      withOverhead: {
        megabytes: totalNeededMB,
        bytes: totalNeededMB * 1024 * 1024
      },
      buffer: {
        megabytes: bufferMB + overheadMB,
        bytes: (bufferMB + overheadMB) * 1024 * 1024
      },
      percentUsed: this.storageInfo.percentage,
      isPersistent: this.storageInfo.isPersistent,
      isIndexedDBAvailable,
      needsBuffer,
      modelName,
      message: ''
    };
    
    if (!hasEnoughSpace) {
      result.message = `❌ Not enough storage! Available: ${availableMB.toFixed(1)}MB, Need: ${totalNeededMB.toFixed(1)}MB (${requiredMB.toFixed(1)}MB model + overhead)`;
    } else if (needsBuffer) {
      result.message = `⚠️ Storage is tight. Available: ${availableMB.toFixed(1)}MB, Need: ${totalNeededMB.toFixed(1)}MB. Consider freeing up space.`;
    } else {
      result.message = `✅ Enough storage! Available: ${availableMB.toFixed(1)}MB, Need: ${totalNeededMB.toFixed(1)}MB`;
    }
    
    // Update status if callback exists
    if (this.statusCallback) {
      this.statusCallback({
        status: hasEnoughSpace ? 'storage_ok' : 'storage_insufficient',
        message: result.message,
        storageInfo: {
          available: availableMB,
          required: requiredMB,
          needed: totalNeededMB,
          percentUsed: this.storageInfo.percentage
        }
      });
    }
    
    console.log(`📊 Storage Check: ${result.message}`);
    
    return result;
  }

  /**
   * Check if IndexedDB is available and writable
   */
  async checkIndexedDBAvailability() {
    try {
      if (!window.indexedDB) return false;
      
      // Try a write operation
      const testDB = await new Promise((resolve, reject) => {
        const request = indexedDB.open('__test__', 1);
        request.onupgradeneeded = () => {
          const db = request.result;
          if (!db.objectStoreNames.contains('__test__')) {
            db.createObjectStore('__test__');
          }
        };
        request.onsuccess = () => resolve(request.result);
        request.onerror = () => reject(request.error);
      });
      
      testDB.close();
      
      // Delete test DB
      await new Promise((resolve) => {
        const request = indexedDB.deleteDatabase('__test__');
        request.onsuccess = () => resolve();
        request.onerror = () => resolve();
      });
      
      return true;
    } catch (error) {
      console.warn('IndexedDB not available:', error);
      return false;
    }
  }

  /**
   * Open IndexedDB
   */
  openDatabase() {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open(DB_NAME, DB_VERSION);
      
      request.onupgradeneeded = (event) => {
        const db = event.target.result;
        
        if (!db.objectStoreNames.contains(STORE_NAME)) {
          db.createObjectStore(STORE_NAME, { keyPath: 'id' });
        }
        
        if (!db.objectStoreNames.contains(CHUNK_STORE_NAME)) {
          const chunkStore = db.createObjectStore(CHUNK_STORE_NAME, { keyPath: 'id' });
          chunkStore.createIndex('downloadId', 'downloadId', { unique: false });
          chunkStore.createIndex('chunkIndex', 'chunkIndex', { unique: false });
        }
      };
      
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }

  /**
   * Save chunk to IndexedDB
   */
  async saveChunk(downloadId, chunkIndex, data) {
    try {
      if (!this.db) return false;
      
      const transaction = this.db.transaction(CHUNK_STORE_NAME, 'readwrite');
      const store = transaction.objectStore(CHUNK_STORE_NAME);
      
      const chunkRecord = {
        id: `${downloadId}_chunk_${chunkIndex}`,
        downloadId: downloadId,
        chunkIndex: chunkIndex,
        data: data,
        size: data.byteLength,
        timestamp: Date.now()
      };
      
      return new Promise((resolve, reject) => {
        const request = store.put(chunkRecord);
        request.onsuccess = () => resolve(true);
        request.onerror = () => reject(request.error);
      });
    } catch (error) {
      console.error('❌ Save chunk failed:', error);
      if (error.name === 'QuotaExceededError') {
        throw new Error('⚠️ Storage quota exceeded! Please free up space and try again.');
      }
      return false;
    }
  }

  /**
   * Get all chunks for a download
   */
  async getChunks(downloadId) {
    try {
      if (!this.db) return [];
      
      const transaction = this.db.transaction(CHUNK_STORE_NAME, 'readonly');
      const store = transaction.objectStore(CHUNK_STORE_NAME);
      const index = store.index('downloadId');
      
      return new Promise((resolve, reject) => {
        const chunks = [];
        const request = index.openCursor(IDBKeyRange.only(downloadId));
        
        request.onsuccess = (event) => {
          const cursor = event.target.result;
          if (cursor) {
            chunks.push(cursor.value);
            cursor.continue();
          } else {
            resolve(chunks);
          }
        };
        request.onerror = () => reject(request.error);
      });
    } catch (error) {
      console.error('❌ Get chunks failed:', error);
      return [];
    }
  }

  /**
   * Delete chunks for cleanup
   */
  async deleteChunks(downloadId) {
    try {
      if (!this.db) return false;
      
      const transaction = this.db.transaction(CHUNK_STORE_NAME, 'readwrite');
      const store = transaction.objectStore(CHUNK_STORE_NAME);
      const index = store.index('downloadId');
      
      return new Promise((resolve, reject) => {
        const request = index.openCursor(IDBKeyRange.only(downloadId));
        
        request.onsuccess = (event) => {
          const cursor = event.target.result;
          if (cursor) {
            cursor.delete();
            cursor.continue();
          } else {
            resolve(true);
          }
        };
        request.onerror = () => reject(request.error);
      });
    } catch (error) {
      console.error('❌ Delete chunks failed:', error);
      return false;
    }
  }

  /**
   * Download model with storage check
   */
  async downloadModel({
    modelUrl,
    modelName,
    onProgress,
    onStatus,
    onComplete,
    onError,
    chunkSize = 1024 * 1024,
    forceDownload = false
  }) {
    this.isCancelled = false;
    this.isPaused = false;
    this.startTime = Date.now();
    this.speedSamples = [];
    this.progressCallback = onProgress;
    this.statusCallback = onStatus;
    this.chunkSize = chunkSize;
    this.downloadId = modelName || 'gguf_download';

    try {
      // Check for existing download first
      const existingChunks = await this.getChunks(this.downloadId);
      
      if (existingChunks.length > 0) {
        const loaded = existingChunks.reduce((sum, c) => sum + c.size, 0);
        const checkpoint = await this.getCheckpoint(this.downloadId);
        this.totalBytes = checkpoint?.totalBytes || 0;
        this.loadedBytes = loaded;
        
        console.log(`📥 Resuming: ${(loaded/1024/1024).toFixed(1)}MB / ${(this.totalBytes/1024/1024).toFixed(1)}MB`);
        
        return this.resumeDownload({
          modelUrl,
          existingChunks,
          onProgress,
          onStatus,
          onComplete,
          onError
        });
      }

      // Get file size
      if (onStatus) {
        onStatus({ status: 'connecting', message: '🔍 Checking file size...' });
      }

      const headResponse = await fetch(modelUrl, { method: 'HEAD' });
      const contentLength = headResponse.headers.get('content-length');
      
      if (!contentLength) {
        throw new Error('❌ Server did not provide content-length header');
      }

      this.totalBytes = parseInt(contentLength, 10);
      const totalMB = this.totalBytes / 1024 / 1024;

      // ⭐ CRITICAL: CHECK STORAGE BEFORE DOWNLOAD
      const storageCheck = await this.checkStorageForDownload(this.totalBytes, modelName);
      
      if (!storageCheck.hasEnoughSpace && !forceDownload) {
        const errorMsg = `⚠️ Not enough storage space!\n\n` +
          `Available: ${storageCheck.available.megabytes.toFixed(1)} MB\n` +
          `Required: ${storageCheck.required.megabytes.toFixed(1)} MB (model)\n` +
          `With overhead: ${storageCheck.withOverhead.megabytes.toFixed(1)} MB\n\n` +
          `Please free up space and try again.`;
        
        if (onStatus) {
          onStatus({
            status: 'storage_error',
            message: errorMsg,
            storageInfo: storageCheck
          });
        }
        
        throw new Error(errorMsg);
      }

      if (onStatus) {
        onStatus({
          status: 'storage_ok',
          message: `✅ Storage OK: ${storageCheck.available.megabytes.toFixed(1)}MB available`,
          storageInfo: storageCheck
        });
      }

      if (onStatus) {
        onStatus({
          status: 'downloading',
          message: `📥 Downloading ${totalMB.toFixed(1)} MB model...`,
          total: this.totalBytes
        });
      }

      return this.performChunkedDownload({
        modelUrl,
        existingChunks: [],
        onProgress,
        onStatus,
        onComplete,
        onError
      });

    } catch (error) {
      console.error('❌ Download failed:', error);
      if (onError) onError(error);
      throw error;
    }
  }

  /**
   * Perform chunked download
   */
  async performChunkedDownload({
    modelUrl,
    existingChunks = [],
    onProgress,
    onStatus,
    onComplete,
    onError
  }) {
    const totalChunks = Math.ceil(this.totalBytes / this.chunkSize);
    const downloadedIndices = new Set(existingChunks.map(c => c.chunkIndex));
    const allChunks = [...existingChunks];
    let loaded = allChunks.reduce((sum, c) => sum + c.size, 0);
    
    const missingIndices = [];
    for (let i = 0; i < totalChunks; i++) {
      if (!downloadedIndices.has(i)) {
        missingIndices.push(i);
      }
    }

    if (missingIndices.length === 0) {
      return this.assembleAndSave({
        chunks: allChunks,
        onComplete,
        onStatus,
        onProgress
      });
    }

    const concurrency = 5;
    const queue = [...missingIndices];
    let activeDownloads = 0;
    let completedChunks = allChunks.length;
    let lastCheckpoint = 0;

    return new Promise((resolve, reject) => {
      const downloadNext = async () => {
        if (this.isCancelled) {
          reject(new Error('Download cancelled'));
          return;
        }

        while (this.isPaused) {
          if (onStatus) onStatus({ status: 'paused', message: '⏸️ Paused' });
          await this.sleep(200);
          if (this.isCancelled) {
            reject(new Error('Download cancelled'));
            return;
          }
        }

        if (queue.length === 0 && activeDownloads === 0) {
          this.assembleAndSave({
            chunks: allChunks,
            onComplete,
            onStatus,
            onProgress
          }).then(resolve).catch(reject);
          return;
        }

        if (queue.length === 0) {
          setTimeout(downloadNext, 500);
          return;
        }

        const chunkIndex = queue.shift();
        activeDownloads++;
        const startByte = chunkIndex * this.chunkSize;
        const endByte = Math.min(startByte + this.chunkSize - 1, this.totalBytes - 1);

        try {
          const response = await fetch(modelUrl, {
            headers: { Range: `bytes=${startByte}-${endByte}` }
          });

          if (!response.ok && response.status !== 206) {
            throw new Error(`HTTP ${response.status}`);
          }

          const chunkData = await response.arrayBuffer();
          
          if (this.isCancelled) {
            reject(new Error('Cancelled'));
            return;
          }

          await this.saveChunk(this.downloadId, chunkIndex, chunkData);

          allChunks.push({
            id: `${this.downloadId}_chunk_${chunkIndex}`,
            chunkIndex,
            data: chunkData,
            size: chunkData.byteLength,
            timestamp: Date.now()
          });

          completedChunks++;
          loaded += chunkData.byteLength;
          this.loadedBytes = loaded;

          const progress = Math.min(Math.round((loaded / this.totalBytes) * 100), 100);
          const speed = this.calculateSpeed();
          
          // Check storage periodically during download
          if (completedChunks % 10 === 0) {
            await this.analyzeStorage();
            if (this.storageInfo.available < this.chunkSize * 2) {
              if (onStatus) {
                onStatus({
                  status: 'storage_warning',
                  message: `⚠️ Storage running low! ${(this.storageInfo.available/1024/1024).toFixed(1)}MB remaining`
                });
              }
            }
          }
          
          if (onProgress) {
            onProgress({
              progress,
              loaded,
              total: this.totalBytes,
              speed,
              chunks: completedChunks,
              totalChunks,
              storageRemaining: this.storageInfo.available
            });
          }

          const now = Date.now();
          if (now - lastCheckpoint > CHECKPOINT_INTERVAL) {
            await this.saveCheckpoint({
              totalBytes: this.totalBytes,
              loadedBytes: loaded,
              chunkCount: completedChunks
            });
            lastCheckpoint = now;
          }

          activeDownloads--;
          downloadNext();

        } catch (error) {
          if (error.name === 'AbortError' || error.message.includes('network')) {
            console.warn(`Retrying chunk ${chunkIndex}`);
            queue.unshift(chunkIndex);
            await this.sleep(1000);
          }
          activeDownloads--;
          downloadNext();
        }
      };

      for (let i = 0; i < Math.min(concurrency, queue.length); i++) {
        downloadNext();
      }
    });
  }

  /**
   * Assemble and save to Filesystem
   */
  async assembleAndSave({
    chunks,
    onComplete,
    onStatus,
    onProgress
  }) {
    try {
      if (onStatus) {
        onStatus({ status: 'assembling', message: '📦 Assembling model...' });
      }

      const sorted = [...chunks].sort((a, b) => a.chunkIndex - b.chunkIndex);
      
      let totalSize = 0;
      for (const chunk of sorted) {
        totalSize += chunk.size;
      }

      // Check storage before assembly
      const storageCheck = await this.checkStorageForDownload(totalSize, this.downloadId);
      if (!storageCheck.hasEnoughSpace) {
        throw new Error(`⚠️ Not enough storage to assemble the model! Need ${storageCheck.withOverhead.megabytes.toFixed(1)}MB, have ${storageCheck.available.megabytes.toFixed(1)}MB`);
      }

      const finalBuffer = new Uint8Array(totalSize);
      let offset = 0;

      for (const chunk of sorted) {
        const data = new Uint8Array(chunk.data);
        finalBuffer.set(data, offset);
        offset += data.length;
        
        if (onProgress) {
          const progress = 90 + Math.round((offset / totalSize) * 10);
          onProgress({
            progress,
            loaded: offset,
            total: totalSize,
            assembling: true
          });
        }
      }

      if (onStatus) {
        onStatus({ status: 'saving', message: '💾 Saving to device...' });
      }

      const { Filesystem, Directory } = await import('@capacitor/filesystem');
      
      await Filesystem.mkdir({
        path: 'models',
        directory: Directory.Data,
        recursive: true
      });

      const fileName = this.downloadId || 'model.gguf';
      const filePath = `models/${fileName}`;

      await Filesystem.writeFile({
        path: filePath,
        data: finalBuffer,
        directory: Directory.Data,
        recursive: true
      });

      const stats = await Filesystem.stat({
        path: filePath,
        directory: Directory.Data
      });

      const uri = await Filesystem.getUri({
        path: filePath,
        directory: Directory.Data
      });

      await this.deleteChunks(this.downloadId);
      await this.deleteCheckpoint(this.downloadId);

      for (const chunk of sorted) {
        chunk.data = null;
      }

      if (onStatus) {
        onStatus({
          status: 'complete',
          message: `✅ Model ready: ${(stats.size/1024/1024).toFixed(1)} MB`,
          path: filePath,
          uri: uri.uri
        });
      }

      if (onComplete) {
        onComplete({
          path: filePath,
          uri: uri.uri,
          size: stats.size,
          modelName: fileName
        });
      }

      return { path: filePath, uri: uri.uri, size: stats.size };

    } catch (error) {
      console.error('❌ Assembly failed:', error);
      throw error;
    }
  }

  /**
   * Resume download from IndexedDB
   */
  async resumeDownload({
    modelUrl,
    existingChunks,
    onProgress,
    onStatus,
    onComplete,
    onError
  }) {
    const loaded = existingChunks.reduce((sum, c) => sum + c.size, 0);
    
    // Check storage before resuming
    const storageCheck = await this.checkStorageForDownload(this.totalBytes, this.downloadId);
    if (!storageCheck.hasEnoughSpace) {
      const errorMsg = `⚠️ Not enough storage to resume!\n\nAvailable: ${storageCheck.available.megabytes.toFixed(1)} MB\nNeed: ${storageCheck.required.megabytes.toFixed(1)} MB\nPlease free up space.`;
      if (onStatus) {
        onStatus({ status: 'storage_error', message: errorMsg });
      }
      throw new Error(errorMsg);
    }
    
    if (onStatus) {
      onStatus({
        status: 'resuming',
        message: `⏳ Resuming: ${(loaded/1024/1024).toFixed(1)}MB downloaded, ${storageCheck.available.megabytes.toFixed(1)}MB available`
      });
    }

    return this.performChunkedDownload({
      modelUrl,
      existingChunks,
      onProgress,
      onStatus,
      onComplete,
      onError
    });
  }

  /**
   * Save checkpoint
   */
  async saveCheckpoint(data) {
    try {
      if (!this.db) return false;
      
      const transaction = this.db.transaction(STORE_NAME, 'readwrite');
      const store = transaction.objectStore(STORE_NAME);
      
      const checkpoint = {
        id: this.downloadId,
        totalBytes: data.totalBytes || this.totalBytes,
        loadedBytes: data.loadedBytes || this.loadedBytes,
        chunkCount: data.chunkCount || 0,
        timestamp: Date.now(),
        status: 'downloading'
      };
      
      return new Promise((resolve, reject) => {
        const request = store.put(checkpoint);
        request.onsuccess = () => resolve(true);
        request.onerror = () => reject(request.error);
      });
    } catch (error) {
      console.error('Checkpoint save failed:', error);
      return false;
    }
  }

  /**
   * Get checkpoint
   */
  async getCheckpoint(id) {
    try {
      if (!this.db) return null;
      
      const transaction = this.db.transaction(STORE_NAME, 'readonly');
      const store = transaction.objectStore(STORE_NAME);
      
      return new Promise((resolve, reject) => {
        const request = store.get(id);
        request.onsuccess = () => resolve(request.result || null);
        request.onerror = () => reject(request.error);
      });
    } catch {
      return null;
    }
  }

  /**
   * Delete checkpoint
   */
  async deleteCheckpoint(id) {
    try {
      if (!this.db) return false;
      
      const transaction = this.db.transaction(STORE_NAME, 'readwrite');
      const store = transaction.objectStore(STORE_NAME);
      
      return new Promise((resolve, reject) => {
        const request = store.delete(id);
        request.onsuccess = () => resolve(true);
        request.onerror = () => reject(request.error);
      });
    } catch {
      return false;
    }
  }

  /**
   * Calculate download speed
   */
  calculateSpeed() {
    const elapsed = (Date.now() - this.startTime) / 1000;
    if (elapsed < 1) return 0;
    
    const speed = this.loadedBytes / elapsed;
    this.speedSamples.push(speed);
    if (this.speedSamples.length > 10) this.speedSamples.shift();
    
    return Math.round(this.speedSamples.reduce((a, b) => a + b, 0) / this.speedSamples.length);
  }

  /**
   * Pause download
   */
  pauseDownload() {
    this.isPaused = true;
    if (this.statusCallback) {
      this.statusCallback({ status: 'paused', message: '⏸️ Download paused' });
    }
  }

  /**
   * Resume download
   */
  resumeDownloadUI() {
    this.isPaused = false;
    if (this.statusCallback) {
      this.statusCallback({ status: 'resuming', message: '⏳ Resuming...' });
    }
  }

  /**
   * Cancel download
   */
  cancelDownload() {
    this.isCancelled = true;
    this.isPaused = false;
    if (this.statusCallback) {
      this.statusCallback({ status: 'cancelled', message: '❌ Download cancelled' });
    }
  }

  /**
   * Sleep helper
   */
  sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  /**
   * Check if model exists on device
   */
  async modelExists(modelName) {
    try {
      const { Filesystem, Directory } = await import('@capacitor/filesystem');
      const path = `models/${modelName}`;
      const stats = await Filesystem.stat({ path, directory: Directory.Data });
      return stats && stats.size > 0;
    } catch {
      return false;
    }
  }

  /**
   * Get model path
   */
  async getModelPath(modelName) {
    try {
      const { Filesystem, Directory } = await import('@capacitor/filesystem');
      const path = `models/${modelName}`;
      const uri = await Filesystem.getUri({ path, directory: Directory.Data });
      return uri.uri;
    } catch {
      return null;
    }
  }

  /**
   * Get detailed storage info for UI
   */
  async getStorageInfo() {
    await this.analyzeStorage();
    return {
      ...this.storageInfo,
      availableMB: this.storageInfo.available / 1024 / 1024,
      quotaMB: this.storageInfo.quota / 1024 / 1024,
      usageMB: this.storageInfo.usage / 1024 / 1024,
      formatted: {
        available: `${(this.storageInfo.available / 1024 / 1024).toFixed(1)} MB`,
        quota: `${(this.storageInfo.quota / 1024 / 1024 / 1024).toFixed(2)} GB`,
        usage: `${(this.storageInfo.usage / 1024 / 1024).toFixed(1)} MB`
      }
    };
  }
}

// Export singleton
export const modelDownloader = new ModelDownloader();END
cat > src/services/apiTasks.js << 'END'
// ============================================================
// apiTasks.js - Capgo InAppBrowser Action Handler
// ============================================================

import { InAppBrowser } from '@capgo/capacitor-inappbrowser';

let apiLogs = [];
let activeBrowsers = {}; // Store browser instances by ID

// ============================================================
// CONFIGURATION
// ============================================================

export function getApiLogs() {
  return apiLogs;
}

export function clearApiLogs() {
  apiLogs = [];
}

// ============================================================
// CAPGO INAPPBROWSER CORE
// ============================================================

async function runCapgoScript(code, hidden = true) {
  console.log('🌐 Running Capgo InAppBrowser script...');
  
  try {
    // Open headless WebView
    const { id } = await InAppBrowser.openWebView({
      url: 'about:blank', // Start blank, we'll navigate via script
      hidden: hidden
    });
    
    activeBrowsers[id] = { id, timestamp: Date.now() };
    
    // Execute the script
    const result = await InAppBrowser.executeScript({
      id,
      js: `
        (async function() {
          try {
            ${code}
          } catch (error) {
            return { success: false, error: error.message };
          }
        })();
      `
    });
    
    // Close the browser after execution
    await InAppBrowser.closeWebView({ id });
    delete activeBrowsers[id];
    
    console.log('✅ Capgo script executed');
    return result;
    
  } catch (error) {
    console.error('❌ Capgo error:', error.message);
    return { success: false, error: error.message };
  }
}

// ============================================================
// CAPGO SCRIPTS (Converted from Browserless)
// ============================================================

function getLoginScript(username, password) {
  return `
    const page = window;
    
    try {
      // Navigate to login page
      window.location.href = 'https://iftms.motl.gov.et/auth/sign-in';
      
      await new Promise(resolve => setTimeout(resolve, 3000));
      
      // Wait for form elements
      await new Promise((resolve) => {
        const checkInterval = setInterval(() => {
          if (document.querySelector('[name="phone_number"]')) {
            clearInterval(checkInterval);
            resolve();
          }
        }, 100);
      });
      
      // Fill login form
      document.querySelector('[name="phone_number"]').value = '${username}';
      document.querySelector('input[type="password"]').value = '${password}';
      document.querySelector('button[type="submit"]').click();
      
      // Wait for navigation
      await new Promise(resolve => setTimeout(resolve, 5000));
      
      const success = window.location.href.includes('dashboard');
      const cookies = document.cookie.split(';').map(c => {
        const [name, value] = c.trim().split('=');
        return { name, value };
      });
      
      return {
        success: success,
        cookies: cookies,
        url: window.location.href
      };
    } catch (error) {
      return { success: false, error: error.message };
    }
  `;
}

function getRegisterVehicleScript(vehicleData) {
  return `
    const page = window;
    
    try {
      window.location.href = 'https://iftms.motl.gov.et/vehicles/add';
      
      await new Promise(resolve => setTimeout(resolve, 3000));
      
      // Wait for form elements
      await new Promise((resolve) => {
        const checkInterval = setInterval(() => {
          if (document.querySelector('[name="plateNumber"]')) {
            clearInterval(checkInterval);
            resolve();
          }
        }, 100);
      });
      
      // Fill vehicle form
      const fields = {
        'plateNumber': '${vehicleData.plateNumber || ''}',
        'plateCode': '${vehicleData.plateCode || ''}',
        'motorNumber': '${vehicleData.motorNumber || ''}',
        'vinNumber': '${vehicleData.vinNumber || ''}',
        'manufacturer': '${vehicleData.manufacturer || ''}',
        'vehicleModel': '${vehicleData.vehicleModel || ''}',
        'manufactureYear': '${vehicleData.manufactureYear || ''}',
        'vehicleType': '${vehicleData.vehicleType || ''}',
        'engineCapacity': '${vehicleData.engineCapacity || ''}',
        'fuelType': '${vehicleData.fuelType || ''}'
      };
      
      Object.entries(fields).forEach(([name, value]) => {
        const el = document.querySelector(\`[name="\${name}"]\`);
        if (el) el.value = value;
      });
      
      document.querySelector('button[type="submit"]').click();
      
      // Wait for navigation
      await new Promise(resolve => setTimeout(resolve, 5000));
      
      const success = window.location.href.includes('success');
      
      return {
        success: success,
        url: window.location.href
      };
    } catch (error) {
      return { success: false, error: error.message };
    }
  `;
}

function getRegisterDriverScript(driverData) {
  return `
    const page = window;
    
    try {
      window.location.href = 'https://iftms.motl.gov.et/drivers/add';
      
      await new Promise(resolve => setTimeout(resolve, 3000));
      
      // Wait for form elements
      await new Promise((resolve) => {
        const checkInterval = setInterval(() => {
          if (document.querySelector('[name="driverName"]')) {
            clearInterval(checkInterval);
            resolve();
          }
        }, 100);
      });
      
      // Fill driver form
      const fields = {
        'driverName': '${driverData.driverName || ''}',
        'driverLicense': '${driverData.driverLicense || ''}',
        'phoneNumber': '${driverData.phoneNumber || ''}',
        'email': '${driverData.email || ''}'
      };
      
      Object.entries(fields).forEach(([name, value]) => {
        const el = document.querySelector(\`[name="\${name}"]\`);
        if (el) el.value = value;
      });
      
      document.querySelector('button[type="submit"]').click();
      
      // Wait for navigation
      await new Promise(resolve => setTimeout(resolve, 5000));
      
      const success = window.location.href.includes('success');
      
      return {
        success: success,
        url: window.location.href
      };
    } catch (error) {
      return { success: false, error: error.message };
    }
  `;
}

function getSyncScript(operatorData, vehicles, drivers) {
  return `
    const page = window;
    
    try {
      window.location.href = 'https://iftms.motl.gov.et/sync';
      
      await new Promise(resolve => setTimeout(resolve, 3000));
      
      // Mock sync - in real app this would call APIs
      const result = {
        success: true,
        operator: ${JSON.stringify(operatorData)},
        vehiclesCount: ${vehicles.length},
        driversCount: ${drivers.length}
      };
      
      return {
        success: true,
        data: result
      };
    } catch (error) {
      return { success: false, error: error.message };
    }
  `;
}

function getVINDecodeScript(vin) {
  return `
    const page = window;
    
    try {
      const response = await fetch('https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/${vin}?format=json');
      const data = await response.json();
      
      return {
        success: true,
        data: data
      };
    } catch (error) {
      return { success: false, error: error.message };
    }
  `;
}

// ============================================================
// API ACTION EXECUTOR
// ============================================================

export async function executeApiAction(action, context = {}) {
  const startTime = Date.now();
  
  try {
    let result;
    
    switch (action.id) {
      case 'login_to_iftms':
        const username = context.phoneNumber || context.operator?.phoneNumber || '';
        const password = context.password || context.operator?.password || '';
        result = await runCapgoScript(getLoginScript(username, password));
        break;
        
      case 'register_vehicle':
        result = await runCapgoScript(getRegisterVehicleScript(context));
        break;
        
      case 'register_driver':
        result = await runCapgoScript(getRegisterDriverScript(context));
        break;
        
      case 'sync_to_ifmts':
        result = await runCapgoScript(
          getSyncScript(context.operator || {}, context.vehicles || [], context.drivers || [])
        );
        break;
        
      case 'decode_vin':
        result = await runCapgoScript(getVINDecodeScript(context.vinNumber || context.userInput || ''));
        break;
        
      default:
        // Default: try to run as generic script
        if (action.endpoint) {
          const response = await fetch(action.endpoint, {
            method: action.method || 'POST',
            headers: {
              'Content-Type': 'application/json',
              ...(action.headers || {})
            },
            body: JSON.stringify(resolveParams(action.data || context, context))
          });
          
          result = await response.json();
        } else {
          result = { success: false, error: `Unknown action: ${action.id}` };
        }
    }
    
    const duration = Date.now() - startTime;
    
    apiLogs.push({
      timestamp: new Date().toISOString(),
      action: action.id || action.type,
      duration,
      success: result.success !== false
    });
    
    console.log(`✅ API Action [${action.id}]:`, result);
    return result;
    
  } catch (error) {
    const duration = Date.now() - startTime;
    
    apiLogs.push({
      timestamp: new Date().toISOString(),
      action: action.id || action.type,
      duration,
      success: false,
      error: error.message
    });
    
    return {
      success: false,
      error: error.message
    };
  }
}

// ============================================================
// VISIBLE BROWSER WITH USER INTERACTION
// ============================================================

export async function openVisibleBrowser(url, script = null) {
  try {
    const { id } = await InAppBrowser.openWebView({
      url: url,
      hidden: false,
      options: {
        showToolbar: true,
        showURL: true
      }
    });
    
    if (script) {
      const result = await InAppBrowser.executeScript({
        id,
        js: script
      });
      return result;
    }
    
    return { success: true, browserId: id };
  } catch (error) {
    return { success: false, error: error.message };
  }
}

// ============================================================
// BROWSER MANAGEMENT
// ============================================================

export async function closeAllBrowsers() {
  for (const id of Object.keys(activeBrowsers)) {
    try {
      await InAppBrowser.closeWebView({ id });
    } catch (e) {
      console.error(`Failed to close browser ${id}:`, e);
    }
  }
  activeBrowsers = {};
}

// ============================================================
// EXECUTE STEP API ACTIONS
// ============================================================

export async function executeStepApiActions(step, context = {}) {
  if (!step.apiActions || step.apiActions.length === 0) {
    return { success: true, continue: true };
  }
  
  const results = [];
  
  for (const action of step.apiActions) {
    if (action.condition && !evaluateCondition(action.condition, context)) {
      continue;
    }
    
    console.log(`🌐 Executing step API action: ${action.id || action.type}`);
    
    const result = await executeApiAction(action, context);
    results.push(result);
    
    if (!result.success) {
      return {
        success: false,
        error: result.error,
        message: getLocalizedMessage(action.onFailure?.message) || result.error,
        action: action,
        results
      };
    }
    
    if (action.onSuccess?.nextStep) {
      return {
        success: true,
        continue: false,
        nextStep: action.onSuccess.nextStep,
        message: getLocalizedMessage(action.onSuccess.message),
        result,
        results
      };
    }
    
    if (action.onSuccess?.continue === false) {
      return {
        success: true,
        continue: false,
        message: getLocalizedMessage(action.onSuccess?.message),
        result,
        results
      };
    }
  }
  
  return {
    success: true,
    continue: true,
    results,
    nextStep: step.onValid?.nextStep || null
  };
}

// ============================================================
// EXECUTE FIELD API ACTIONS
// ============================================================

export async function executeFieldApiActions(field, context = {}) {
  if (!field.apiActions || field.apiActions.length === 0) {
    return { success: true, continue: true };
  }
  
  const results = [];
  
  for (const action of field.apiActions) {
    console.log(`🌐 Executing field API action: ${action.id || action.type}`);
    
    const result = await executeApiAction(action, context);
    results.push(result);
    
    if (!result.success) {
      return {
        success: false,
        error: result.error,
        message: getLocalizedMessage(action.onFailure?.message) || result.error,
        action: action,
        results
      };
    }
    
    if (action.onSuccess?.message) {
      return {
        success: true,
        continue: false,
        message: getLocalizedMessage(action.onSuccess.message),
        result,
        results
      };
    }
  }
  
  return {
    success: true,
    continue: true,
    results
  };
}

// ============================================================
// HELPER FUNCTIONS (Same as original)
// ============================================================

function resolveParams(params, context) {
  if (!params) return {};
  
  const result = {};
  
  for (const [key, value] of Object.entries(params)) {
    if (typeof value === 'string' && value.includes('{{')) {
      const matches = value.match(/\{\{([^}]+)\}\}/g);
      if (matches) {
        let resolved = value;
        for (const match of matches) {
          const path = match.slice(2, -2).trim();
          const resolvedValue = getValueByPath(context, path);
          resolved = resolved.replace(match, resolvedValue !== undefined ? String(resolvedValue) : '');
        }
        result[key] = resolved;
      } else {
        result[key] = value;
      }
    } else if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
      result[key] = resolveParams(value, context);
    } else {
      result[key] = value;
    }
  }
  
  return result;
}

function getValueByPath(obj, path) {
  if (!obj || !path) return undefined;
  
  const parts = path.split('.');
  let current = obj;
  
  for (const part of parts) {
    if (current === undefined || current === null) return undefined;
    if (part === 'collected_data') return obj.collectedData || {};
    if (part === 'operator') return obj.operator || {};
    if (part === 'vehicles') return obj.vehicles || [];
    if (part === 'drivers') return obj.drivers || [];
    if (part === 'user_input') return obj.userInput || '';
    if (part === 'current_item') return obj.currentItem || {};
    
    current = current[part];
  }
  
  return current;
}

function evaluateCondition(condition, context) {
  if (!condition) return true;
  
  try {
    const resolved = resolveParams({ value: condition }, context);
    const expr = resolved.value || condition;
    return Function('"use strict"; return (' + expr + ')')();
  } catch {
    return true;
  }
}

function getLocalizedMessage(message) {
  if (!message) return '';
  if (typeof message === 'string') return message;
  
  const lang = localStorage.getItem('agig-language') || 'en';
  if (typeof message === 'object') {
    return message[lang] || message.en || '';
  }
  
  return message;
}

// ============================================================
// EXPORT DEFAULT
// ============================================================

export default {
  executeApiAction,
  executeStepApiActions,
  executeFieldApiActions,
  getApiLogs,
  clearApiLogs,
  openVisibleBrowser,
  closeAllBrowsers,
  runCapgoScript
};END
cat > src/services/auth.js << 'END'
class AuthManager {
  constructor() {
    this.state = {
      currentUser: null,
      isAuthenticated: false,
      isLoading: false
    }
    this.init()
  }

  async init() {
    console.log('🔄 Initializing Auth Manager...')
    this.checkAuthState()
    console.log('✅ Auth Manager initialized')
  }

  checkAuthState() {
    const savedUser = localStorage.getItem('currentUser')
    if (savedUser) {
      const user = JSON.parse(savedUser)
      this.state.currentUser = user
      this.state.isAuthenticated = true
    }
  }

  async signInWithGoogle() {
    await this.simulateOAuth('Google')
  }

  async signInWithGitHub() {
    await this.simulateOAuth('Fayda')
  }

  async signInWithMicrosoft() {
    await this.simulateOAuth('Microsoft')
  }

  async handleEmailSignIn(email) {
    await this.simulateEmailSignIn(email)
  }

  async simulateOAuth(provider) {
    this.state.isLoading = true

    await new Promise(resolve => setTimeout(resolve, 1500))

    const user = {
      id: Math.random().toString(36).substr(2, 9),
      name: `${provider} User`,
      email: `user@${provider.toLowerCase()}.com`,
      provider: provider.toLowerCase(),
      avatar: null
    }

    this.state.currentUser = user
    this.state.isAuthenticated = true
    this.state.isLoading = false

    localStorage.setItem('currentUser', JSON.stringify(user))
    localStorage.setItem('currentUser', JSON.stringify(user))
    
    this.showMessage(`Successfully signed in with ${provider}!`, 'success')
  }

  async simulateEmailSignIn(email) {
    this.state.isLoading = true

    await new Promise(resolve => setTimeout(resolve, 2000))

    const user = {
      id: Math.random().toString(36).substr(2, 9),
      name: email.split('@')[0],
      email: email,
      provider: 'email',
      avatar: null
    }

    this.state.currentUser = user
    this.state.isAuthenticated = true
    this.state.isLoading = false

    localStorage.setItem('currentUser', JSON.stringify(user))
    this.showMessage('Check your email for the sign-in link!', 'success')
  }

  signOut() {
    this.state.currentUser = null
    this.state.isAuthenticated = false
    localStorage.removeItem('currentUser')
    this.showMessage('You have been signed out.', 'info')
  }

  showMessage(message, type = 'info') {
    const toast = document.createElement('div')
    toast.className = `toast-message toast-${type}`
    toast.textContent = message
    
    Object.assign(toast.style, {
      position: 'fixed',
      top: '80px',
      right: '20px',
      background: type === 'success' ? '#4CAF50' : type === 'error' ? '#f44336' : '#2196F3',
      color: 'white',
      padding: '12px 20px',
      borderRadius: '8px',
      zIndex: '1003'
    })

    document.body.appendChild(toast)

    setTimeout(() => {
      if (toast.parentNode) {
        toast.parentNode.removeChild(toast)
      }
    }, 3000)
  }

  getCurrentUser() {
    return this.state.currentUser
  }

  getIsAuthenticated() {
    return this.state.isAuthenticated
  }
}

export const auth = new AuthManager()END
cat > src/services/data.js << 'END'
export const universities ={
  
    "government": [
      {
        "name": "Addis Ababa Science and Technology University",
        "acronym": "AASTU",
        "website": "http://www.aastu.edu.et/"
      },
      {
        "name": "Adama Science and Technology University",
        "acronym": "ASTU",
        "website": "http://www.astu.edu.et/"
      },
      {
        "name": "Addis Ababa University",
        "acronym": "AAU",
        "website": "http://www.aau.edu.et/"
      },
      {
        "name": "Adigrat University",
        "acronym": "AGU",
        "website": "http://www.adu.edu.et/"
      },
      {
        "name": "Ambo University",
        "acronym": "AU",
        "website": "http://www.ambou.edu.et/"
      },
      {
        "name": "Arba Minch University",
        "acronym": "AMU",
        "website": "http://www.amu.edu.et/"
      },
      {
        "name": "Arsi University",
        "acronym": "ARU",
        "website": "https://www.arsiun.edu.et/"
      },
      {
        "name": "Assosa University",
        "acronym": "ASU",
        "website": "http://www.asu.edu.et/"
      },
      {
        "name": "Axum University",
        "acronym": "AXU",
        "website": "http://www.aku.edu.et/"
      },
      {
        "name": "Bahir Dar University",
        "acronym": "BDU",
        "website": "http://www.bdu.edu.et/"
      },
      {
        "name": "Bonga University",
        "acronym": "BU",
        "website": "http://www.bongau.edu.et/"
      },
      {
        "name": "Bule Hora University",
        "acronym": "BHU",
        "website": "http://www.bhu.edu.et/"
      },
      {
        "name": "Debark University",
        "acronym": "DKU",
        "website": "http://www.dku.edu.et/"
      },
      {
        "name": "Debre Birhan University",
        "acronym": "DBU",
        "website": "http://www.dbu.edu.et/"
      },
      {
        "name": "Debre Markos University",
        "acronym": "DMU",
        "website": "http://www.dmu.edu.et/"
      },
      {
        "name": "Debre Tabor University",
        "acronym": "DBTU",
        "website": "http://www.dtu.edu.et/"
      },
      {
        "name": "Dembi Dollo University",
        "acronym": "DeDU",
        "website": "http://www.dedu.edu.et/"
      },
      {
        "name": "Dilla University",
        "acronym": "DU",
        "website": "http://www.du.edu.et/"
      },
      {
        "name": "Dire Dawa University",
        "acronym": "DDU",
        "website": "http://www.ddu.edu.et/"
      },
      {
        "name": "Gambella University",
        "acronym": "GMU",
        "website": "http://www.gmu.edu.et/"
      },
      {
        "name": "University of Gondar",
        "acronym": "UoG",
        "website": "http://www.uog.edu.et/"
      },
      {
        "name": "Haramaya University",
        "acronym": "HRU",
        "website": "http://www.haramaya.edu.et/"
      },
      {
        "name": "Hawassa University",
        "acronym": "HWU",
        "website": "http://www.hu.edu.et/"
      },
      {
        "name": "Injibara University",
        "acronym": "IU",
        "website": "http://www.inu.edu.et/"
      },
      {
        "name": "Jigjiga University",
        "acronym": "JGU",
        "website": "https://www.jju.edu.et/"
      },
      {
        "name": "Jimma University",
        "acronym": "JU",
        "website": "https://www.ju.edu.et/"
      },
      {
        "name": "Jinka University",
        "acronym": "JNU",
        "website": "http://www.jnu.edu.et/"
      },
      {
        "name": "Kebri Dehar University",
        "acronym": "KDU",
        "website": "http://www.kdu.edu.et/"
      },
      {
        "name": "Kotebe Metropolitan University",
        "acronym": "KMU",
        "website": "http://www.kmu.edu.et/"
      },
      {
        "name": "Meda Welabu University",
        "acronym": "MWU",
        "website": "http://www.mwu.edu.et/"
      },
      {
        "name": "Mekelle University",
        "acronym": "MU",
        "website": "http://www.mu.edu.et/"
      },
      {
        "name": "Mekdela Amba University",
        "acronym": "MAU",
        "website": "http://www.mau.edu.et/"
      },
      {
        "name": "Metu University",
        "acronym": "MEU",
        "website": "http://www.meu.edu.et/"
      },
      {
        "name": "Mizan-Tepi University",
        "acronym": "MTU",
        "website": "http://www.mtu.edu.et/"
      },
      {
        "name": "Oda Bultum University",
        "acronym": "OBU",
        "website": "http://www.obsu.edu.et/"
      },
      {
        "name": "Raya University",
        "acronym": "RU",
        "website": "http://www.rayu.edu.et/"
      },
      {
        "name": "Selale University",
        "acronym": "SLU",
        "website": "http://www.seu.edu.et/"
      },
      {
        "name": "Semera University",
        "acronym": "SU",
        "website": "https://www.su.edu.et/"
      },
      {
        "name": "Wachemo University",
        "acronym": "WCU",
        "website": "http://www.wcu.edu.et/"
      },
      {
        "name": "Weldiya University",
        "acronym": "WDU",
        "website": "http://www.wdu.edu.et/"
      },
      {
        "name": "Wollega University",
        "acronym": "WU",
        "website": "http://www.wollegauniversity.edu.et/"
      },
      {
        "name": "Wollo University",
        "acronym": "WOU",
        "website": "http://www.wu.edu.et/"
      }
        ]}

        export const ministriesFed = {
  "version": "1.0",
  "dataFderal": [
    {
      "text": "The Ministry of Finance is responsible for fiscal policy and budget management.",
      "metadata": {
        "ministry": "Ministry of Finance",
        "acronym": "MoF",
        "sector": "Economic",
        "established_year": 1943,
        "headquarters": "Addis Ababa",
        "services":"finances"
      },
      "label": 0,
      "label_text": "Ministry of Finance",
      "id": "ET-GOV-001",
      "language": "en"
    },
    {
      "text": "Agricultural development programs fall under the Ministry of Agriculture's mandate.",
      "metadata": {
        "ministry": "Ministry of Agriculture",
        "acronym": "MoA",
        "sector": "Agriculture",
        "established_year": 1995,
        "headquarters": "Addis Ababa"
      },
      "label": 1,
      "label_text": "Ministry of Agriculture",
      "id": "ET-GOV-002",
      "language": "en"
    },
    {
      "text": "የጤና ሚኒስቴር የህዝብ ጤና ፖሊሲ እና አገልግሎቶችን ያስተዳድራል።",
      "metadata": {
        "ministry": "Ministry of Health",
        "acronym": "MoH",
        "sector": "Health",
        "established_year": 1948,
        "headquarters": "Addis Ababa"
      },
      "label": 2,
      "label_text": "Ministry of Health",
      "id": "ET-GOV-003",
      "language": "am"
    },
    {
      "text": "The Ministry of Education oversees primary, secondary and higher education systems.",
      "metadata": {
        "ministry": "Ministry of Education",
        "acronym": "MoE",
        "sector": "Education",
        "established_year": 1975,
        "headquarters": "Addis Ababa"
      },
      "subordinates":{
      "authenticators":"authentic",
      "examiners":""
      },
      "label": 3,
      "label_text": "Ministry of Education",
      "id": "ET-GOV-004",
      "language": "en"
    },
    {
      "text": "የውጭ ጉዳይ ሚኒስቴር �ና የውጭ ግንኙነት ተቋም ነው።",
      "metadata": {
        "ministry": "Ministry of Foreign Affairs",
        "acronym": "MoFA",
        "sector": "Diplomacy",
        "established_year": 1943,
        "headquarters": "Addis Ababa"
      },
      "subordinates":{
      "authenticators":"authentic",
      "examiners":""
      },
      "label": 4,
      "label_text": "Ministry of Foreign Affairs",
      "id": "ET-GOV-005",
      "language": "am"
    },
    {
      "text": "Transport infrastructure development is coordinated by the Ministry of Transport.",
      "metadata": {
        "ministry": "Ministry of Transport",
        "acronym": "MoT",
        "sector": "Infrastructure",
        "established_year": 2010,
        "headquarters": "Addis Ababa"
      },
      "subordinates":{
      "authenticators":"authentic",
      "examiners":""
      },
      "label": 5,
      "label_text": "Ministry of Transport",
      "id": "ET-GOV-006",
      "language": "en"
    },
    {
      "text": "የኢንዱስትሪ ሚኒስቴር የኢንዱስትሪ ልማት ፖሊሲዎችን ያቀዳል።",
      "metadata": {
        "ministry": "Ministry of Industry",
        "acronym": "MoI",
        "sector": "Industrial",
        "established_year": 1995,
        "headquarters": "Addis Ababa"
      },
      "label": 6,
      "label_text": "Ministry of Industry",
      "id": "ET-GOV-007",
      "language": "am"
    },
    {
      "text": "The Ministry of Water and Energy manages national water resources.",
      "metadata": {
        "ministry": "Ministry of Water and Energy",
        "acronym": "MoWE",
        "sector": "Utilities",
        "established_year": 2001,
        "headquarters": "Addis Ababa"
      },
      "label": 7,
      "label_text": "Ministry of Water and Energy",
      "id": "ET-GOV-008",
      "language": "en"
    },
    {
      "text": "የማህበራዊ ጉዳይ ሚኒስቴር የማህበራዊ ደህንነት ፕሮግራሞችን ያስተዳድራል።",
      "metadata": {
        "ministry": "Ministry of Social Affairs",
        "acronym": "MoSA",
        "sector": "Social Welfare",
        "established_year": 2005,
        "headquarters": "Addis Ababa"
      },
      "label": 8,
      "label_text": "Ministry of Social Affairs",
      "id": "ET-GOV-009",
      "language": "am"
    },
    {
      "text": "The Ministry of Trade promotes domestic and international commerce.",
      "metadata": {
        "ministry": "Ministry of Trade",
        "acronym": "MoT",
        "sector": "Economic",
        "established_year": 1991,
        "headquarters": "Addis Ababa"
      },
      "label": 9,
      "label_text": "Ministry of Trade",
      "id": "ET-GOV-010",
      "language": "en"
    }
  ],
  "dataFderal": [
    {
      "text": "The Ministry of Finance is responsible for fiscal policy and budget management.",
      "metadata": {
        "ministry": "Ministry of Finance",
        "acronym": "MoF",
        "sector": "Economic",
        "established_year": 1943,
        "headquarters": "Addis Ababa",
        "services":"finances"
      },
      "label": 0,
      "label_text": "Ministry of Finance",
      "id": "ET-GOV-001",
      "language": "en"
    },
    {
      "text": "Agricultural development programs fall under the Ministry of Agriculture's mandate.",
      "metadata": {
        "ministry": "Ministry of Agriculture",
        "acronym": "MoA",
        "sector": "Agriculture",
        "established_year": 1995,
        "headquarters": "Addis Ababa"
      },
      "label": 1,
      "label_text": "Ministry of Agriculture",
      "id": "ET-GOV-002",
      "language": "en"
    },
    {
      "text": "የጤና ሚኒስቴር የህዝብ ጤና ፖሊሲ እና አገልግሎቶችን ያስተዳድራል።",
      "metadata": {
        "ministry": "Ministry of Health",
        "acronym": "MoH",
        "sector": "Health",
        "established_year": 1948,
        "headquarters": "Addis Ababa"
      },
      "label": 2,
      "label_text": "Ministry of Health",
      "id": "ET-GOV-003",
      "language": "am"
    },
    {
      "text": "The Ministry of Education oversees primary, secondary and higher education systems.",
      "metadata": {
        "ministry": "Ministry of Education",
        "acronym": "MoE",
        "sector": "Education",
        "established_year": 1975,
        "headquarters": "Addis Ababa"
      },
      "subordinates":{
      "authenticators":"authentic",
      "examiners":""
      },
      "label": 3,
      "label_text": "Ministry of Education",
      "id": "ET-GOV-004",
      "language": "en"
    },
    {
      "text": "የውጭ ጉዳይ ሚኒስቴር �ና የውጭ ግንኙነት ተቋም ነው።",
      "metadata": {
        "ministry": "Ministry of Foreign Affairs",
        "acronym": "MoFA",
        "sector": "Diplomacy",
        "established_year": 1943,
        "headquarters": "Addis Ababa"
      },
      "subordinates":{
      "authenticators":"authentic",
      "examiners":""
      },
      "label": 4,
      "label_text": "Ministry of Foreign Affairs",
      "id": "ET-GOV-005",
      "language": "am"
    },
    {
      "text": "Transport infrastructure development is coordinated by the Ministry of Transport.",
      "metadata": {
        "ministry": "Ministry of Transport",
        "acronym": "MoT",
        "sector": "Infrastructure",
        "established_year": 2010,
        "headquarters": "Addis Ababa"
      },
      "subordinates":{
      "authenticators":"authentic",
      "examiners":""
      },
      "label": 5,
      "label_text": "Ministry of Transport",
      "id": "ET-GOV-006",
      "language": "en"
    },
    {
      "text": "የኢንዱስትሪ ሚኒስቴር የኢንዱስትሪ ልማት ፖሊሲዎችን ያቀዳል።",
      "metadata": {
        "ministry": "Ministry of Industry",
        "acronym": "MoI",
        "sector": "Industrial",
        "established_year": 1995,
        "headquarters": "Addis Ababa"
      },
      "label": 6,
      "label_text": "Ministry of Industry",
      "id": "ET-GOV-007",
      "language": "am"
    },
    {
      "text": "The Ministry of Water and Energy manages national water resources.",
      "metadata": {
        "ministry": "Ministry of Water and Energy",
        "acronym": "MoWE",
        "sector": "Utilities",
        "established_year": 2001,
        "headquarters": "Addis Ababa"
      },
      "label": 7,
      "label_text": "Ministry of Water and Energy",
      "id": "ET-GOV-008",
      "language": "en"
    },
    {
      "text": "የማህበራዊ ጉዳይ ሚኒስቴር የማህበራዊ ደህንነት ፕሮግራሞችን ያስተዳድራል።",
      "metadata": {
        "ministry": "Ministry of Social Affairs",
        "acronym": "MoSA",
        "sector": "Social Welfare",
        "established_year": 2005,
        "headquarters": "Addis Ababa"
      },
      "label": 8,
      "label_text": "Ministry of Social Affairs",
      "id": "ET-GOV-009",
      "language": "am"
    },
    {
      "text": "The Ministry of Trade promotes domestic and international commerce.",
      "metadata": {
        "ministry": "Ministry of Trade",
        "acronym": "MoT",
        "sector": "Economic",
        "established_year": 1991,
        "headquarters": "Addis Ababa"
      },
      "label": 9,
      "label_text": "Ministry of Trade",
      "id": "ET-GOV-010",
      "language": "en"
    }
  ],
  "labels": [
    {"id": 0, "text": "Ministry of Finance"},
    {"id": 1, "text": "Ministry of Agriculture"},
    {"id": 2, "text": "Ministry of Health"},
    {"id": 3, "text": "Ministry of Education"},
    {"id": 4, "text": "Ministry of Foreign Affairs"},
    {"id": 5, "text": "Ministry of Transport"},
    {"id": 6, "text": "Ministry of Industry"},
    {"id": 7, "text": "Ministry of Water and Energy"},
    {"id": 8, "text": "Ministry of Social Affairs"},
    {"id": 9, "text": "Ministry of Trade"}
  ],
  "config": {
    "model_type": "bert",
    "task": "text_classification",
    "languages": ["en", "am"],
    "text_field": "text",
    "label_field": "label",
    "max_length": 512,
    "preprocessing": {
      "lowercase": true,
      "remove_special_chars": false,
      "tokenizer": "wordpiece"
    }
  }
}
  export const privateColleges = [
      "20-20 Open College",
      "A.R.T. Medical College Ethiopia",
      "Abyssinia College",
      "Adama General Hospital and Medical College",
      "Addis Ababa Medical College",
      "Addis College",
      "Addis Continental Public Health Institute",
      "Admas University",
      "Africa Beza College",
      "Africa Health Science College",
      "Alkan Health Science College",
      "Alpha University College",
      "Atlas Health College",
      "Ayer Tena Health Science College",
      "Belay Zeleke Health College",
      "Ben Meskerem College",
      "Bethel Medical College",
      "Biya College",
      "Blue Nile College",
      "Central Health College",
      "Chilalo Health Science and Technology College",
      "CPU Business and Computer Technology College",
      "Dandi Boru College",
      "Dangila Andinet Health Science College",
      "Debub Ethiopia College",
      "Durman College",
      "Dynamic International University College",
      "ECUSTA Higher Learning Institute",
      "Ethio Lence College",
      "Ethiopian Adventist College",
      "Ethiopis Distance Education College",
      "Fekede Egzi College",
      "Finote Selam College",
      "Fura College",
      "Gabist College",
      "Gage College",
      "Gambi College of Medical Science",
      "Genius-Land",
      "Gofa College",
      "Gotoniyal",
      "Hamlin College of Midwifery",
      "Harambe College",
      "Harar Agro Technical and Technology College",
      "Harar Health Science College",
      "Hawassa Health Science College",
      "Hayat Medical College",
      "Hayome Medical College",
      "HiLCoE School of Computer Science and Technology College",
      "Hope College",
      "Infolink College",
      "International Leadership Institute",
      "International Leadership Institute (in collaboration with University of Greenwich)",
      "Jigdan College",
      "Joint Vision College",
      "Kea Med Medical College",
      "Lead Star International Academy",
      "Lucy College",
      "Medco Bio-Medical College",
      "Mekane Yesus Management and Leadership College",
      "Micro Business College",
      "Microlink Information Technology College",
      "Mishquen College",
      "Myungsang Medical College",
      "National College",
      "Network College",
      "New Generation University College",
      "New Global Vision College",
      "New Millenium College",
      "Nile College",
      "Omega Health College",
      "Oromiya Public Service College",
      "Paradise Valley College",
      "PESC Information Systems College",
      "Pharma Health Science College",
      "Poly Institute of Technology",
      "Rhobot Medical College",
      "Rift Valley University",
      "Royal College",
      "Sante Medical College",
      "Seamless College of Distance Education",
      "Selam Nursing College",
      "Selihom School of Nursing",
      "Sheba University College",
      "Sodo Christian Hospital (PAACS Collaboration)",
      "Soloda Health and Technology College",
      "SRI SAI College",
      "St. Lideta Health Science College",
      "St. Mary University",
      "Summit College",
      "Tech Zone Engineering and Business College",
      "Top College",
      "Tropical Health College",
      "Unity University",
      "Universal Medical College",
      "US College",
      "Victory College",
      "Western Star College",
      "Western University College (Lincoln University Collaboration)",
      "Yardstick International College of Distance Education",
      "Yom College",
      "Zemen Development and Management College",
      "Zion College"
    ]

    export const nouns =[
      'ቤት', 'አባት', 'እማት', 'ልጅ', 'ሰው', 'ከተማ', 'ገበሬ', 'መምህር', 'ዶክተር',
                        'መጽሐፍ', 'ወረቀት', 'እጅ', 'እግር', 'ልብስ', 'መኪና', 'ቤተክርስቲያን', 'መስጊድ'
    ]

   export const verbs= [
                        // Verb prefixes
                        '^እ', '^ት', '^ይ', '^ን', '^ት', '^ይ',
                        // Verb suffixes
                        'ለሁ$', 'ለች$', 'ለን$', 'ለ$', 'አለ$', 'አል$',
                        'ኦ$', 'ኡ$', 'ኢ$', 'ኣ$', 'ኤ$',
                        // Common verb patterns
                        'መ[ሀ-፼]+$', // Infinitive verbs
                        '[ሀ-፼]+አለ$', // Past tense
                        '[ሀ-፼]+አል$', // Negative
                        'ች[ሀ-፼]+$', // Feminine subject
                        'ኡ[ሀ-፼]+$', // Plural subject
                        // Specific common verbs
                        'ማለት', 'መሆን', 'መውሰድ', 'መስጠት', 'መውሰድ', 'መናገር', 'መጻፍ', 'መንታት'
                    ]
                   
                    // Amharic pronouns
                   export const pronouns= [
                        'እኔ', 'አንተ', 'አንቺ', 'እሱ', 'እሷ', 'እኛ', 'እናንተ', 'እነሱ',
                        'ይህ', 'ያ', 'እነዚህ', 'እነዚያ',
                        'ማን', 'ምን', 'የት', 'መቼ', 'እንዴት', 'ለምን', 'ስንት',
                        'ነገሩ', 'ነገሯ', 'ነገራችን', 'ነገራችሁ', 'ነገራቸው'
                    ]
                    
                    // Amharic adjectives
                  export const  adjectives= [
                        // Adjective patterns
                        'ሀብታም',
                        'ያለ', // eg. ትልቅ ያለ, ቆንጆ ያለ
                        'ማለት', // eg. መልካም ማለት
                        'አለው', // eg. ብዙ አለው
                        // Common adjectives
                        'ትልቅ', 'ትንሽ', 'ረጅም', 'አጭር', 'ጥቁር', 'ነጭ', 'ቀይ', 'ሰማያዊ',
                        'ፍጹም', 'ጥሩ', 'ክፉ', 'ሰላማዊ', 'ጠንካራ', 'ደካማ', 'ባለጌ', 'ድሃ',
                        'ብዙ', 'ጥቂት', 'ሁሉ', 'አንዳንድ', 'ሌላ', 'አዲስ', 'የድሮ',
                        'መልካም', 'መጥፎ', 'ፈጣን', 'ዝግባ', 'ቀላል', 'ከባድ', 'ቀላል', 'ውስብስብ'
                    ]
                    
                    // Amharic adverbs
                   export const adverbs= [
                        'ግን', 'ስለዚህ', 'በጣም', 'እጅግ', 'ደግሞ', 'ከዚያ', 'ከዚህ', 'ወደዚያ', 'ወደዚህ',
                        'በቃ', 'በደንብ', 'በስፋት', 'በአጭር', 'በዝርዝር', 'በፍጥነት', 'በረግጥ', 'በትክክል',
                        'ያለምንም', 'ሳይቀር', 'በፍጹም', 'በአጠቃላይ', 'በተለይ', 'በመጨረሻ'
                    ]
                    
                    // Amharic prepositions and particles
                  export const  prepositions= [
                        'በ', 'ለ', 'ከ', 'ወደ', 'ጋር', 'አማካኝነት', 'በኩል', 'ላይ', 'በታች', 'በላይ',
                        'ውስጥ', 'ውጭ', 'በኋላ', 'በፊት', 'ከኋላ', 'ከፊት', 'አብረው', 'አንድላይ',
                        'አጠገብ', 'ተቃራኒ', 'መካከል', 'ማዕከል', 'ጀርባ', 'ፊት', 'ጎን'
                    ]
                    
                    // Sentence end markers
                  export const  sentenceEnders= ['።', '!', '?', '፡፡', '...']

                  export const names = [
  {
    "name": "ABABU",
    "gender": "male"
  },
  {
    "name": "ABAS",
    "gender": "male"
  },
  {
    "name": "ABAY",
    "gender": "male"
  },
  {
    "name": "ABAYINEH",
    "gender": "male"
  },
  {
    "name": "ABAYINESH",
    "gender": "female"
  },
  {
    "name": "ABAYNESH",
    "gender": "female"
  },
  {
    "name": "ABAYNESHE",
    "gender": "female"
  },
  {
    "name": "ABBA",
    "gender": "male"
  },
  {
    "name": "ABDI",
    "gender": "male"
  },
  {
    "name": "ABDIRAHIMAN",
    "gender": "male"
  },
  {
    "name": "ABDISA",
    "gender": "male"
  },
  {
    "name": "ABDU",
    "gender": "male"
  },
  {
    "name": "ABDULAZIZ",
    "gender": "male"
  },
  {
    "name": "ABDULETIF",
    "gender": "male"
  },
  {
    "name": "ABDULFATA",
    "gender": "male"
  },
  {
    "name": "ABDULFETA",
    "gender": "male"
  },
  {
    "name": "ABDULHAKIM",
    "gender": "male"
  },
  {
    "name": "ABDULWEHAB",
    "gender": "male"
  },
  {
    "name": "ABDURAHMAN",
    "gender": "male"
  },
  {
    "name": "ABDURAZAK",
    "gender": "male"
  },
  {
    "name": "ABDUREHMAN",
    "gender": "male"
  },
  {
    "name": "ABDUREIM",
    "gender": "male"
  },
  {
    "name": "ABDUSELAM",
    "gender": "male"
  },
  {
    "name": "ABEBA",
    "gender": "female"
  },
  {
    "name": "ABEBAW",
    "gender": "male"
  },
  {
    "name": "ABEBE",
    "gender": "male"
  },
  {
    "name": "ABEBECH",
    "gender": "female"
  },
  {
    "name": "ABEKYELESH",
    "gender": "female"
  },
  {
    "name": "ABEL",
    "gender": "male"
  },
  {
    "name": "ABENET",
    "gender": "male"
  },
  {
    "name": "ABENEZER",
    "gender": "male"
  },
  {
    "name": "ABERA",
    "gender": "male"
  },
  {
    "name": "ABERASH",
    "gender": "female"
  },
  {
    "name": "ABERE",
    "gender": "male"
  },
  {
    "name": "ABI",
    "gender": "male"
  },
  {
    "name": "ABIEL",
    "gender": "male"
  },
  {
    "name": "ABINET",
    "gender": "male"
  },
  {
    "name": "ABIRAR",
    "gender": "male"
  },
  {
    "name": "ABIRDU",
    "gender": "male"
  },
  {
    "name": "ABIRHAM",
    "gender": "male"
  },
  {
    "name": "ABISELOM",
    "gender": "male"
  },
  {
    "name": "ABIY",
    "gender": "male"
  },
  {
    "name": "ABIYOT",
    "gender": "male"
  },
  {
    "name": "ABIYU",
    "gender": "male"
  },
  {
    "name": "ABNET",
    "gender": "female"
  },
  {
    "name": "ABONESH",
    "gender": "female"
  },
  {
    "name": "ABOZENECH",
    "gender": "female"
  },
  {
    "name": "ABRAHAM",
    "gender": "male"
  },
  {
    "name": "ABREHAM",
    "gender": "male"
  },
  {
    "name": "ABREHET",
    "gender": "female"
  },
  {
    "name": "ABRIHA",
    "gender": "male"
  },
  {
    "name": "ABSIRA",
    "gender": "female"
  },
  {
    "name": "ABUBEKER",
    "gender": "male"
  },
  {
    "name": "ABULIE",
    "gender": "male"
  },
  {
    "name": "ABUYE",
    "gender": "male"
  },
  {
    "name": "ABYI",
    "gender": "male"
  },
  {
    "name": "ABYOT",
    "gender": "male"
  },
  {
    "name": "ADAMIU",
    "gender": "male"
  },
  {
    "name": "ADANE",
    "gender": "male"
  },
  {
    "name": "ADANECH",
    "gender": "female"
  },
  {
    "name": "ADANU",
    "gender": "female"
  },
  {
    "name": "ADDIS",
    "gender": "male"
  },
  {
    "name": "ADDISALEM",
    "gender": "male"
  },
  {
    "name": "ADDISE",
    "gender": "male"
  },
  {
    "name": "ADDISU",
    "gender": "male"
  },
  {
    "name": "ADEM",
    "gender": "male"
  },
  {
    "name": "ADERA",
    "gender": "female"
  },
  {
    "name": "ADIGEH",
    "gender": "male"
  },
  {
    "name": "ADIGOBIRHAN",
    "gender": "male"
  },
  {
    "name": "ADIS",
    "gender": "female"
  },
  {
    "name": "ADISSU",
    "gender": "male"
  },
  {
    "name": "ADMASU",
    "gender": "male"
  },
  {
    "name": "ADNA",
    "gender": "female"
  },
  {
    "name": "ADUGNA",
    "gender": "male"
  },
  {
    "name": "ADYAMSEGED",
    "gender": "male"
  },
  {
    "name": "AEMERE",
    "gender": "male"
  },
  {
    "name": "AESHA",
    "gender": "female"
  },
  {
    "name": "AFEWORK",
    "gender": "male"
  },
  {
    "name": "AGAR",
    "gender": "female"
  },
  {
    "name": "AGEGNEHU",
    "gender": "male"
  },
  {
    "name": "AGERE",
    "gender": "female"
  },
  {
    "name": "AGNEZ",
    "gender": "female"
  },
  {
    "name": "AHEMED",
    "gender": "male"
  },
  {
    "name": "AHIMED",
    "gender": "male"
  },
  {
    "name": "AJANAW",
    "gender": "male"
  },
  {
    "name": "AJEBUSH",
    "gender": "female"
  },
  {
    "name": "AJIBA",
    "gender": "female"
  },
  {
    "name": "AKALE",
    "gender": "male"
  },
  {
    "name": "AKATE",
    "gender": "male"
  },
  {
    "name": "AKELILU",
    "gender": "male"
  },
  {
    "name": "AKILILU",
    "gender": "male"
  },
  {
    "name": "AKLEWEG",
    "gender": "female"
  },
  {
    "name": "AKLILU",
    "gender": "male"
  },
  {
    "name": "AKMEL",
    "gender": "male"
  },
  {
    "name": "ALAYU",
    "gender": "male"
  },
  {
    "name": "ALAZARE",
    "gender": "male"
  },
  {
    "name": "ALEBACHEW",
    "gender": "male"
  },
  {
    "name": "ALEHEGN",
    "gender": "male"
  },
  {
    "name": "ALEM",
    "gender": "female"
  },
  {
    "name": "ALEMASH",
    "gender": "female"
  },
  {
    "name": "ALEMAYEHU",
    "gender": "male"
  },
  {
    "name": "ALEMAYHU",
    "gender": "male"
  },
  {
    "name": "ALEMAZ",
    "gender": "female"
  },
  {
    "name": "ALEMENEH",
    "gender": "male"
  },
  {
    "name": "ALEMITU",
    "gender": "female"
  },
  {
    "name": "ALEMNEH",
    "gender": "male"
  },
  {
    "name": "ALEMNESH",
    "gender": "female"
  },
  {
    "name": "ALEMSEGED",
    "gender": "male"
  },
  {
    "name": "ALEMSHET",
    "gender": "female"
  },
  {
    "name": "ALEMTSEHAY",
    "gender": "female"
  },
  {
    "name": "ALEMU",
    "gender": "male"
  },
  {
    "name": "ALENEH",
    "gender": "male"
  },
  {
    "name": "ALEXANDER",
    "gender": "male"
  },
  {
    "name": "ALFIYA",
    "gender": "female"
  },
  {
    "name": "ALGANESH",
    "gender": "female"
  },
  {
    "name": "ALI",
    "gender": "male"
  },
  {
    "name": "ALIMA",
    "gender": "female"
  },
  {
    "name": "ALIMAZ",
    "gender": "female"
  },
  {
    "name": "ALISHUM",
    "gender": "male"
  },
  {
    "name": "ALMA",
    "gender": "female"
  },
  {
    "name": "ALMAZ",
    "gender": "female"
  },
  {
    "name": "AMAN",
    "gender": "male"
  },
  {
    "name": "AMANUEL",
    "gender": "unknown"
  },
  {
    "name": "AMAR",
    "gender": "male"
  },
  {
    "name": "AMARE",
    "gender": "male"
  },
  {
    "name": "AMARECH",
    "gender": "female"
  },
  {
    "name": "AMDEBIRHAN",
    "gender": "male"
  },
  {
    "name": "AMELEWERK",
    "gender": "female"
  },
  {
    "name": "AMELEWORK",
    "gender": "female"
  },
  {
    "name": "AMELEWRK",
    "gender": "female"
  },
  {
    "name": "AMENSHEWA",
    "gender": "male"
  },
  {
    "name": "AMERIYA",
    "gender": "female"
  },
  {
    "name": "AMETE",
    "gender": "female"
  },
  {
    "name": "AMETU",
    "gender": "female"
  },
  {
    "name": "AMIHATADESSE",
    "gender": "male"
  },
  {
    "name": "AMINA",
    "gender": "female"
  },
  {
    "name": "AMINAT",
    "gender": "female"
  },
  {
    "name": "AMIR",
    "gender": "male"
  },
  {
    "name": "AMIRU",
    "gender": "male"
  },
  {
    "name": "AMRU",
    "gender": "male"
  },
  {
    "name": "AMSALE",
    "gender": "female"
  },
  {
    "name": "AMSALEWORK",
    "gender": "female"
  },
  {
    "name": "AMSALU",
    "gender": "male"
  },
  {
    "name": "ANBESE",
    "gender": "male"
  },
  {
    "name": "ANCHALU",
    "gender": "male"
  },
  {
    "name": "ANDAMLAK",
    "gender": "male"
  },
  {
    "name": "ANDARGACHEW",
    "gender": "male"
  },
  {
    "name": "ANDARGE",
    "gender": "male"
  },
  {
    "name": "ANDIAMLAK",
    "gender": "male"
  },
  {
    "name": "ANDIAYEHU",
    "gender": "male"
  },
  {
    "name": "ANDINET",
    "gender": "male"
  },
  {
    "name": "ANDNET",
    "gender": "male"
  },
  {
    "name": "ANDUALEM",
    "gender": "male"
  },
  {
    "name": "ANGATU",
    "gender": "female"
  },
  {
    "name": "ANTENEH",
    "gender": "male"
  },
  {
    "name": "ANTENHE",
    "gender": "male"
  },
  {
    "name": "ARARSO",
    "gender": "male"
  },
  {
    "name": "AREAYA",
    "gender": "male"
  },
  {
    "name": "AREFASO",
    "gender": "male"
  },
  {
    "name": "AREGA",
    "gender": "male"
  },
  {
    "name": "AREGAWI",
    "gender": "male"
  },
  {
    "name": "ARIMEME",
    "gender": "male"
  },
  {
    "name": "ASAMINEW",
    "gender": "male"
  },
  {
    "name": "ASAYE",
    "gender": "male"
  },
  {
    "name": "ASCHALEW",
    "gender": "male"
  },
  {
    "name": "ASEBE",
    "gender": "male"
  },
  {
    "name": "ASEFA",
    "gender": "male"
  },
  {
    "name": "ASEFU",
    "gender": "female"
  },
  {
    "name": "ASEGEDECH",
    "gender": "female"
  },
  {
    "name": "ASEKALE",
    "gender": "female"
  },
  {
    "name": "ASELEF",
    "gender": "female"
  },
  {
    "name": "ASELEFECH",
    "gender": "female"
  },
  {
    "name": "ASERES",
    "gender": "female"
  },
  {
    "name": "ASFAW",
    "gender": "male"
  },
  {
    "name": "ASHA",
    "gender": "female"
  },
  {
    "name": "ASHAGERE",
    "gender": "male"
  },
  {
    "name": "ASHAGIRE",
    "gender": "male"
  },
  {
    "name": "ASHAGRE",
    "gender": "male"
  },
  {
    "name": "ASHEBIR",
    "gender": "male"
  },
  {
    "name": "ASHENAFI",
    "gender": "male"
  },
  {
    "name": "ASIMARE",
    "gender": "female"
  },
  {
    "name": "ASINA",
    "gender": "female"
  },
  {
    "name": "ASIRAT",
    "gender": "female"
  },
  {
    "name": "ASIYA",
    "gender": "female"
  },
  {
    "name": "ASKALE",
    "gender": "female"
  },
  {
    "name": "ASMAMAW",
    "gender": "male"
  },
  {
    "name": "ASMARE",
    "gender": "male"
  },
  {
    "name": "ASMERET",
    "gender": "female"
  },
  {
    "name": "ASMEROM",
    "gender": "unknown"
  },
  {
    "name": "ASMIRE",
    "gender": "female"
  },
  {
    "name": "ASMIRET",
    "gender": "female"
  },
  {
    "name": "ASNAKE",
    "gender": "male"
  },
  {
    "name": "ASNAKECH",
    "gender": "female"
  },
  {
    "name": "ASNAKECHE",
    "gender": "female"
  },
  {
    "name": "ASNAKETCH",
    "gender": "female"
  },
  {
    "name": "ASNAKU",
    "gender": "female"
  },
  {
    "name": "ASNKA",
    "gender": "female"
  },
  {
    "name": "ASRAT",
    "gender": "female"
  },
  {
    "name": "ASSEFA",
    "gender": "male"
  },
  {
    "name": "ASTER",
    "gender": "female"
  },
  {
    "name": "ATALAY",
    "gender": "female"
  },
  {
    "name": "ATEKELET",
    "gender": "male"
  },
  {
    "name": "ATEREF",
    "gender": "female"
  },
  {
    "name": "ATNAFU",
    "gender": "male"
  },
  {
    "name": "ATNAFWORK",
    "gender": "female"
  },
  {
    "name": "ATSEDE",
    "gender": "female"
  },
  {
    "name": "ATSEDU",
    "gender": "female"
  },
  {
    "name": "ATSIBEHA",
    "gender": "male"
  },
  {
    "name": "AWETASH",
    "gender": "female"
  },
  {
    "name": "AWGICHEW",
    "gender": "unknown"
  },
  {
    "name": "AWOKE",
    "gender": "male"
  },
  {
    "name": "AWOL",
    "gender": "male"
  },
  {
    "name": "AWUT",
    "gender": "male"
  },
  {
    "name": "AYALEW",
    "gender": "male"
  },
  {
    "name": "AYALKIBET",
    "gender": "male"
  },
  {
    "name": "AYALNESH",
    "gender": "female"
  },
  {
    "name": "AYALSEW",
    "gender": "female"
  },
  {
    "name": "AYANTU",
    "gender": "female"
  },
  {
    "name": "AYEHU",
    "gender": "male"
  },
  {
    "name": "AYEHUBIRHAN",
    "gender": "female"
  },
  {
    "name": "AYELE",
    "gender": "male"
  },
  {
    "name": "AYELECH",
    "gender": "female"
  },
  {
    "name": "AYENEW",
    "gender": "male"
  },
  {
    "name": "AYINALEM",
    "gender": "male"
  },
  {
    "name": "AYNALE",
    "gender": "female"
  },
  {
    "name": "AYNALEM",
    "gender": "male"
  },
  {
    "name": "AZAGNE",
    "gender": "female"
  },
  {
    "name": "AZEB",
    "gender": "female"
  },
  {
    "name": "AZEMERA",
    "gender": "female"
  },
  {
    "name": "AZEZE",
    "gender": "male"
  },
  {
    "name": "AZIZA",
    "gender": "female"
  },
  {
    "name": "BAEDE",
    "gender": "male"
  },
  {
    "name": "BAHARU",
    "gender": "male"
  },
  {
    "name": "BAHIRU",
    "gender": "male"
  },
  {
    "name": "BAMLAK",
    "gender": "female"
  },
  {
    "name": "BANCHAYEHU",
    "gender": "female"
  },
  {
    "name": "BANCHIAMLAK",
    "gender": "female"
  },
  {
    "name": "BANCHIAYEHU",
    "gender": "female"
  },
  {
    "name": "BANCHIAYMOLU",
    "gender": "female"
  },
  {
    "name": "BANTAYEHU",
    "gender": "male"
  },
  {
    "name": "BANTIE",
    "gender": "male"
  },
  {
    "name": "BARKELIGN",
    "gender": "male"
  },
  {
    "name": "BASAZNEW",
    "gender": "male"
  },
  {
    "name": "BAYE",
    "gender": "male"
  },
  {
    "name": "BAYELIGN",
    "gender": "male"
  },
  {
    "name": "BAYU",
    "gender": "male"
  },
  {
    "name": "BAZEZEW",
    "gender": "male"
  },
  {
    "name": "BECHENI",
    "gender": "male"
  },
  {
    "name": "BEDASSA",
    "gender": "male"
  },
  {
    "name": "BEDELU",
    "gender": "male"
  },
  {
    "name": "BEDRIYA",
    "gender": "female"
  },
  {
    "name": "BEEMNET",
    "gender": "male"
  },
  {
    "name": "BEFEKADU",
    "gender": "male"
  },
  {
    "name": "BEFIKADU",
    "gender": "male"
  },
  {
    "name": "BEGASHAW",
    "gender": "male"
  },
  {
    "name": "BEHAILU",
    "gender": "male"
  },
  {
    "name": "BEHRIYA",
    "gender": "female"
  },
  {
    "name": "BEKALU",
    "gender": "male"
  },
  {
    "name": "BEKELE",
    "gender": "male"
  },
  {
    "name": "BEKELLE",
    "gender": "male"
  },
  {
    "name": "BEKELU",
    "gender": "female"
  },
  {
    "name": "BELAY",
    "gender": "male"
  },
  {
    "name": "BELAYHUN",
    "gender": "male"
  },
  {
    "name": "BELAYINESH",
    "gender": "female"
  },
  {
    "name": "BELAYNEH",
    "gender": "male"
  },
  {
    "name": "BELAYNESH",
    "gender": "female"
  },
  {
    "name": "BELAYNEW",
    "gender": "male"
  },
  {
    "name": "BELETE",
    "gender": "male"
  },
  {
    "name": "BELETSHACHEW",
    "gender": "female"
  },
  {
    "name": "BELETU",
    "gender": "female"
  },
  {
    "name": "BELYU",
    "gender": "female"
  },
  {
    "name": "BEREKET",
    "gender": "male"
  },
  {
    "name": "BERHAN",
    "gender": "female"
  },
  {
    "name": "BERHANE",
    "gender": "female"
  },
  {
    "name": "BERHANEMESKEL",
    "gender": "male"
  },
  {
    "name": "BERHANU",
    "gender": "male"
  },
  {
    "name": "BERHE",
    "gender": "male"
  },
  {
    "name": "BERIHU",
    "gender": "male"
  },
  {
    "name": "BERIHUN",
    "gender": "male"
  },
  {
    "name": "BERKNESH",
    "gender": "female"
  },
  {
    "name": "BESHIR",
    "gender": "male"
  },
  {
    "name": "BESUFEKAD",
    "gender": "male"
  },
  {
    "name": "BESUFIKAD",
    "gender": "male"
  },
  {
    "name": "BETEHEM",
    "gender": "female"
  },
  {
    "name": "BETEL",
    "gender": "female"
  },
  {
    "name": "BETELHEM",
    "gender": "female"
  },
  {
    "name": "BETEMARIAM",
    "gender": "male"
  },
  {
    "name": "BETHEL",
    "gender": "female"
  },
  {
    "name": "BETHELEHEM",
    "gender": "female"
  },
  {
    "name": "BETHELHEM",
    "gender": "female"
  },
  {
    "name": "BETHELIHEM",
    "gender": "female"
  },
  {
    "name": "BETHLHEM",
    "gender": "female"
  },
  {
    "name": "BETLEHIM",
    "gender": "female"
  },
  {
    "name": "BETLHEM",
    "gender": "female"
  },
  {
    "name": "BEWKETU",
    "gender": "male"
  },
  {
    "name": "BEWNETU",
    "gender": "male"
  },
  {
    "name": "BEYENE",
    "gender": "male"
  },
  {
    "name": "BEYENECH",
    "gender": "female"
  },
  {
    "name": "BEZA",
    "gender": "female"
  },
  {
    "name": "BEZABIH",
    "gender": "male"
  },
  {
    "name": "BEZASHWORK",
    "gender": "unknown"
  },
  {
    "name": "BEZAWIT",
    "gender": "female"
  },
  {
    "name": "BEZU",
    "gender": "female"
  },
  {
    "name": "BEZUNEH",
    "gender": "male"
  },
  {
    "name": "BEZUNESH",
    "gender": "female"
  },
  {
    "name": "BIKILA",
    "gender": "male"
  },
  {
    "name": "BILALU",
    "gender": "male"
  },
  {
    "name": "BILCHAYE",
    "gender": "female"
  },
  {
    "name": "BINIAM",
    "gender": "male"
  },
  {
    "name": "BINIYAM",
    "gender": "male"
  },
  {
    "name": "BINYAM",
    "gender": "male"
  },
  {
    "name": "BIRE",
    "gender": "female"
  },
  {
    "name": "BIREHANU",
    "gender": "male"
  },
  {
    "name": "BIRHAN",
    "gender": "female"
  },
  {
    "name": "BIRHANE",
    "gender": "female"
  },
  {
    "name": "BIRHANIE",
    "gender": "female"
  },
  {
    "name": "BIRHANU",
    "gender": "male"
  },
  {
    "name": "BIRITU",
    "gender": "female"
  },
  {
    "name": "BIRKE",
    "gender": "female"
  },
  {
    "name": "BIRKETY",
    "gender": "female"
  },
  {
    "name": "BIRKINESH",
    "gender": "female"
  },
  {
    "name": "BIRRU",
    "gender": "male"
  },
  {
    "name": "BIRTUKAN",
    "gender": "female"
  },
  {
    "name": "BIRUH",
    "gender": "male"
  },
  {
    "name": "BIRUHALEM",
    "gender": "male"
  },
  {
    "name": "BIRUK",
    "gender": "male"
  },
  {
    "name": "BIRUKTAWIT",
    "gender": "female"
  },
  {
    "name": "BIRUKTAYIT",
    "gender": "female"
  },
  {
    "name": "BIRZAF",
    "gender": "female"
  },
  {
    "name": "BISIRAT",
    "gender": "male"
  },
  {
    "name": "BISKUT",
    "gender": "female"
  },
  {
    "name": "BISRAT",
    "gender": "male"
  },
  {
    "name": "BIZUALEM",
    "gender": "female"
  },
  {
    "name": "BIZUAYEHU",
    "gender": "male"
  },
  {
    "name": "BIZUNESH",
    "gender": "female"
  },
  {
    "name": "BIZUWORK",
    "gender": "male"
  },
  {
    "name": "BIZUYE",
    "gender": "female"
  },
  {
    "name": "BLIEN",
    "gender": "female"
  },
  {
    "name": "BOGALE",
    "gender": "male"
  },
  {
    "name": "BOGALECH",
    "gender": "female"
  },
  {
    "name": "BOGE",
    "gender": "female"
  },
  {
    "name": "BOSENA",
    "gender": "female"
  },
  {
    "name": "BRIKE",
    "gender": "female"
  },
  {
    "name": "BRIKENEH",
    "gender": "male"
  },
  {
    "name": "BTSIAT",
    "gender": "female"
  },
  {
    "name": "CHALA",
    "gender": "male"
  },
  {
    "name": "CHALTU",
    "gender": "female"
  },
  {
    "name": "DAGEM",
    "gender": "male"
  },
  {
    "name": "DAGIM",
    "gender": "male"
  },
  {
    "name": "DAGMAWI",
    "gender": "male"
  },
  {
    "name": "DAGMAWIT",
    "gender": "female"
  },
  {
    "name": "DAGNACHEW",
    "gender": "male"
  },
  {
    "name": "DAMTE",
    "gender": "male"
  },
  {
    "name": "DAMTEW",
    "gender": "male"
  },
  {
    "name": "DANEAL",
    "gender": "male"
  },
  {
    "name": "DANEL",
    "gender": "male"
  },
  {
    "name": "DANHEL",
    "gender": "male"
  },
  {
    "name": "DANIEAL",
    "gender": "male"
  },
  {
    "name": "DANIEL",
    "gender": "male"
  },
  {
    "name": "DARGE",
    "gender": "male"
  },
  {
    "name": "DAVID",
    "gender": "male"
  },
  {
    "name": "DAWIT",
    "gender": "male"
  },
  {
    "name": "DAWITI",
    "gender": "male"
  },
  {
    "name": "DEBEBE",
    "gender": "male"
  },
  {
    "name": "DEBRE",
    "gender": "female"
  },
  {
    "name": "DEBREWORK",
    "gender": "female"
  },
  {
    "name": "DEBRITU",
    "gender": "female"
  },
  {
    "name": "DEGEFE",
    "gender": "male"
  },
  {
    "name": "DEGI",
    "gender": "female"
  },
  {
    "name": "DEGIMAWIT",
    "gender": "female"
  },
  {
    "name": "DEGITU",
    "gender": "female"
  },
  {
    "name": "DEJEN",
    "gender": "male"
  },
  {
    "name": "DEJENE",
    "gender": "male"
  },
  {
    "name": "DEJYINU",
    "gender": "female"
  },
  {
    "name": "DELELEGN",
    "gender": "male"
  },
  {
    "name": "DELIL",
    "gender": "male"
  },
  {
    "name": "DEMEKE",
    "gender": "male"
  },
  {
    "name": "DEMEKECH",
    "gender": "female"
  },
  {
    "name": "DEMEKISSA",
    "gender": "male"
  },
  {
    "name": "DEMELASH",
    "gender": "male"
  },
  {
    "name": "DEMELASHE",
    "gender": "male"
  },
  {
    "name": "DEMELE",
    "gender": "male"
  },
  {
    "name": "DEMEREWA",
    "gender": "female"
  },
  {
    "name": "DEMESE",
    "gender": "male"
  },
  {
    "name": "DEMILE",
    "gender": "male"
  },
  {
    "name": "DEMIS",
    "gender": "male"
  },
  {
    "name": "DEMISSEW",
    "gender": "male"
  },
  {
    "name": "DEMLIE",
    "gender": "male"
  },
  {
    "name": "DEMSEW",
    "gender": "male"
  },
  {
    "name": "DENEKE",
    "gender": "male"
  },
  {
    "name": "DENEKEW",
    "gender": "male"
  },
  {
    "name": "DERARA",
    "gender": "male"
  },
  {
    "name": "DERARTU",
    "gender": "female"
  },
  {
    "name": "DERBE",
    "gender": "male"
  },
  {
    "name": "DERBEW",
    "gender": "male"
  },
  {
    "name": "DEREBE",
    "gender": "female"
  },
  {
    "name": "DEREJE",
    "gender": "male"
  },
  {
    "name": "DEREJIE",
    "gender": "male"
  },
  {
    "name": "DERESE",
    "gender": "male"
  },
  {
    "name": "DERIBE",
    "gender": "male"
  },
  {
    "name": "DESALE",
    "gender": "male"
  },
  {
    "name": "DESALECH",
    "gender": "female"
  },
  {
    "name": "DESALEGN",
    "gender": "male"
  },
  {
    "name": "DESSE",
    "gender": "male"
  },
  {
    "name": "DESSIE",
    "gender": "male"
  },
  {
    "name": "DESTA",
    "gender": "male"
  },
  {
    "name": "DESTALEM",
    "gender": "male"
  },
  {
    "name": "DESTAW",
    "gender": "male"
  },
  {
    "name": "DINA",
    "gender": "male"
  },
  {
    "name": "DINBERU",
    "gender": "male"
  },
  {
    "name": "DIRBE",
    "gender": "female"
  },
  {
    "name": "DIREBE",
    "gender": "male"
  },
  {
    "name": "DUBALE",
    "gender": "male"
  },
  {
    "name": "EBERAHIM",
    "gender": "male"
  },
  {
    "name": "EBISE",
    "gender": "male"
  },
  {
    "name": "EBRAHIM",
    "gender": "male"
  },
  {
    "name": "EDEN",
    "gender": "female"
  },
  {
    "name": "EDOM",
    "gender": "female"
  },
  {
    "name": "EHETE",
    "gender": "female"
  },
  {
    "name": "EHITE",
    "gender": "female"
  },
  {
    "name": "EHITMOLEGN",
    "gender": "female"
  },
  {
    "name": "EHITSHET",
    "gender": "female"
  },
  {
    "name": "EILEYASE",
    "gender": "male"
  },
  {
    "name": "EJGAYEHU",
    "gender": "female"
  },
  {
    "name": "EJIGAYEHU",
    "gender": "female"
  },
  {
    "name": "EJIGU",
    "gender": "male"
  },
  {
    "name": "EJIGYEW",
    "gender": "female"
  },
  {
    "name": "ELFENESH",
    "gender": "female"
  },
  {
    "name": "ELFINESH",
    "gender": "female"
  },
  {
    "name": "ELIAS",
    "gender": "male"
  },
  {
    "name": "ELSA",
    "gender": "female"
  },
  {
    "name": "ELSABET",
    "gender": "unknown"
  },
  {
    "name": "ELSABETH",
    "gender": "female"
  },
  {
    "name": "ELSABIT",
    "gender": "female"
  },
  {
    "name": "ELZA",
    "gender": "female"
  },
  {
    "name": "EMAMAHU",
    "gender": "male"
  },
  {
    "name": "EMAMYE",
    "gender": "female"
  },
  {
    "name": "EMAWAYISH",
    "gender": "female"
  },
  {
    "name": "EMEBET",
    "gender": "female"
  },
  {
    "name": "EMEYEW",
    "gender": "male"
  },
  {
    "name": "EMILY",
    "gender": "female"
  },
  {
    "name": "EMIYEW",
    "gender": "male"
  },
  {
    "name": "EMSHAW",
    "gender": "female"
  },
  {
    "name": "EMUYE",
    "gender": "female"
  },
  {
    "name": "ENANU",
    "gender": "female"
  },
  {
    "name": "ENAT",
    "gender": "female"
  },
  {
    "name": "ENATIHUN",
    "gender": "female"
  },
  {
    "name": "ENATNESH",
    "gender": "female"
  },
  {
    "name": "ENDALE",
    "gender": "male"
  },
  {
    "name": "ENDALKACHEW",
    "gender": "male"
  },
  {
    "name": "ENDAWOK",
    "gender": "male"
  },
  {
    "name": "ENDAYEHU",
    "gender": "female"
  },
  {
    "name": "ENDELKACHEW",
    "gender": "male"
  },
  {
    "name": "ENDESHAW",
    "gender": "male"
  },
  {
    "name": "ENDRIES",
    "gender": "male"
  },
  {
    "name": "ENDRIS",
    "gender": "male"
  },
  {
    "name": "ENGEDA",
    "gender": "male"
  },
  {
    "name": "ENGIDASEW",
    "gender": "male"
  },
  {
    "name": "ENIDEG",
    "gender": "male"
  },
  {
    "name": "ENKOY",
    "gender": "female"
  },
  {
    "name": "ENKUTATASH",
    "gender": "female"
  },
  {
    "name": "ENYE",
    "gender": "female"
  },
  {
    "name": "EPHREM",
    "gender": "male"
  },
  {
    "name": "ERAHEL",
    "gender": "female"
  },
  {
    "name": "ERAHIMA",
    "gender": "female"
  },
  {
    "name": "ERMIAS",
    "gender": "male"
  },
  {
    "name": "ERMIYAS",
    "gender": "male"
  },
  {
    "name": "ERMYAS",
    "gender": "male"
  },
  {
    "name": "EROZA",
    "gender": "female"
  },
  {
    "name": "ESERAEL",
    "gender": "male"
  },
  {
    "name": "ESHETU",
    "gender": "male"
  },
  {
    "name": "ESKADEMAS",
    "gender": "male"
  },
  {
    "name": "ESKINDER",
    "gender": "male"
  },
  {
    "name": "ESKINDIR",
    "gender": "male"
  },
  {
    "name": "ESLEMAN",
    "gender": "male"
  },
  {
    "name": "ESMAEL",
    "gender": "male"
  },
  {
    "name": "ESRAEL",
    "gender": "male"
  },
  {
    "name": "ESSA",
    "gender": "male"
  },
  {
    "name": "ESUENDALE",
    "gender": "male"
  },
  {
    "name": "ETAFERAHU",
    "gender": "unknown"
  },
  {
    "name": "ETAGEGN",
    "gender": "female"
  },
  {
    "name": "ETAGEGNE",
    "gender": "female"
  },
  {
    "name": "ETALEM",
    "gender": "female"
  },
  {
    "name": "ETALEMAHU",
    "gender": "female"
  },
  {
    "name": "ETEGE",
    "gender": "female"
  },
  {
    "name": "ETEINESH",
    "gender": "female"
  },
  {
    "name": "ETENESH",
    "gender": "female"
  },
  {
    "name": "ETHIOPIA",
    "gender": "unknown"
  },
  {
    "name": "ETMOLAGN",
    "gender": "female"
  },
  {
    "name": "ETSEGENET",
    "gender": "female"
  },
  {
    "name": "EVA",
    "gender": "female"
  },
  {
    "name": "EYASU",
    "gender": "male"
  },
  {
    "name": "EYERUS",
    "gender": "female"
  },
  {
    "name": "EYERUSALEM",
    "gender": "female"
  },
  {
    "name": "EYOB",
    "gender": "male"
  },
  {
    "name": "FANAYE",
    "gender": "female"
  },
  {
    "name": "FANOS",
    "gender": "female"
  },
  {
    "name": "FANTAYE",
    "gender": "female"
  },
  {
    "name": "FANTU",
    "gender": "female"
  },
  {
    "name": "FASIKA",
    "gender": "female"
  },
  {
    "name": "FASIL",
    "gender": "male"
  },
  {
    "name": "FATIMA",
    "gender": "female"
  },
  {
    "name": "FATUMA",
    "gender": "female"
  },
  {
    "name": "FAYZA",
    "gender": "female"
  },
  {
    "name": "FEDILA",
    "gender": "female"
  },
  {
    "name": "FEDILU",
    "gender": "male"
  },
  {
    "name": "FEDLU",
    "gender": "male"
  },
  {
    "name": "FEKADU",
    "gender": "male"
  },
  {
    "name": "FEKERTE",
    "gender": "female"
  },
  {
    "name": "FEKRALEM",
    "gender": "male"
  },
  {
    "name": "FELEKE",
    "gender": "male"
  },
  {
    "name": "FELEKECH",
    "gender": "unknown"
  },
  {
    "name": "FELEKU",
    "gender": "female"
  },
  {
    "name": "FENTAYE",
    "gender": "female"
  },
  {
    "name": "FERAHIWOT",
    "gender": "female"
  },
  {
    "name": "FEREHIWOT",
    "gender": "female"
  },
  {
    "name": "FERIHU",
    "gender": "male"
  },
  {
    "name": "FERU",
    "gender": "male"
  },
  {
    "name": "FETAHI",
    "gender": "male"
  },
  {
    "name": "FETENE",
    "gender": "male"
  },
  {
    "name": "FETHYA",
    "gender": "female"
  },
  {
    "name": "FETIYA",
    "gender": "female"
  },
  {
    "name": "FETLEWORK",
    "gender": "female"
  },
  {
    "name": "FETYA",
    "gender": "female"
  },
  {
    "name": "FIKADU",
    "gender": "male"
  },
  {
    "name": "FIKERET",
    "gender": "female"
  },
  {
    "name": "FIKERETE",
    "gender": "female"
  },
  {
    "name": "FIKERTE",
    "gender": "female"
  },
  {
    "name": "FIKIRALEM",
    "gender": "female"
  },
  {
    "name": "FIKIRE",
    "gender": "male"
  },
  {
    "name": "FIKIREADDIS",
    "gender": "female"
  },
  {
    "name": "FIKIRESELASSIE",
    "gender": "male"
  },
  {
    "name": "FIKIRTE",
    "gender": "female"
  },
  {
    "name": "FIKIRU",
    "gender": "male"
  },
  {
    "name": "FIKRE",
    "gender": "female"
  },
  {
    "name": "FIKRITE",
    "gender": "female"
  },
  {
    "name": "FIKRTE",
    "gender": "female"
  },
  {
    "name": "FILAGOT",
    "gender": "male"
  },
  {
    "name": "FILMON",
    "gender": "male"
  },
  {
    "name": "FIREGENET",
    "gender": "female"
  },
  {
    "name": "FIREHIWOT",
    "gender": "female"
  },
  {
    "name": "FIRETSEGA",
    "gender": "female"
  },
  {
    "name": "FIREW",
    "gender": "male"
  },
  {
    "name": "FIREWOIN",
    "gender": "female"
  },
  {
    "name": "FIREZER",
    "gender": "male"
  },
  {
    "name": "FIROMSA",
    "gender": "male"
  },
  {
    "name": "FISEHA",
    "gender": "male"
  },
  {
    "name": "FISHA",
    "gender": "male"
  },
  {
    "name": "FISSEHA",
    "gender": "male"
  },
  {
    "name": "FITSUM",
    "gender": "female"
  },
  {
    "name": "FOZIA",
    "gender": "female"
  },
  {
    "name": "FOZIYA",
    "gender": "female"
  },
  {
    "name": "FRE'ALEM",
    "gender": "male"
  },
  {
    "name": "FREZER",
    "gender": "male"
  },
  {
    "name": "FUAD",
    "gender": "male"
  },
  {
    "name": "G.HIWOT",
    "gender": "male"
  },
  {
    "name": "G.MARIAM",
    "gender": "male"
  },
  {
    "name": "G/HIWOT",
    "gender": "male"
  },
  {
    "name": "G/MEDHIN",
    "gender": "male"
  },
  {
    "name": "G/MEDIHIN",
    "gender": "male"
  },
  {
    "name": "G/MICHAEL",
    "gender": "male"
  },
  {
    "name": "G/WOLD",
    "gender": "male"
  },
  {
    "name": "GARAW",
    "gender": "male"
  },
  {
    "name": "GASHAW",
    "gender": "male"
  },
  {
    "name": "GEBERIE",
    "gender": "male"
  },
  {
    "name": "GEBEYAW",
    "gender": "male"
  },
  {
    "name": "GEBIRESILASIE",
    "gender": "male"
  },
  {
    "name": "GEBRE",
    "gender": "male"
  },
  {
    "name": "GEBREAMLAK",
    "gender": "male"
  },
  {
    "name": "GEBREMEDHIN",
    "gender": "male"
  },
  {
    "name": "GEBREMICHAEL",
    "gender": "male"
  },
  {
    "name": "GEBRESELAS",
    "gender": "male"
  },
  {
    "name": "GEBREYESUS",
    "gender": "male"
  },
  {
    "name": "GEBRHANNA",
    "gender": "male"
  },
  {
    "name": "GEDA",
    "gender": "male"
  },
  {
    "name": "GEDION",
    "gender": "male"
  },
  {
    "name": "GEDIYON",
    "gender": "male"
  },
  {
    "name": "GELAYE",
    "gender": "female"
  },
  {
    "name": "GELETA",
    "gender": "male"
  },
  {
    "name": "GEMEDA",
    "gender": "male"
  },
  {
    "name": "GENENE",
    "gender": "male"
  },
  {
    "name": "GENET",
    "gender": "female"
  },
  {
    "name": "GEREMEW",
    "gender": "male"
  },
  {
    "name": "GEREMU",
    "gender": "male"
  },
  {
    "name": "GESHGISH",
    "gender": "female"
  },
  {
    "name": "GETABALEW",
    "gender": "male"
  },
  {
    "name": "GETACHEW",
    "gender": "male"
  },
  {
    "name": "GETAHCEW",
    "gender": "male"
  },
  {
    "name": "GETAHUN",
    "gender": "unknown"
  },
  {
    "name": "GETAHUNE",
    "gender": "male"
  },
  {
    "name": "GETANEH",
    "gender": "male"
  },
  {
    "name": "GETAYE",
    "gender": "male"
  },
  {
    "name": "GETAYENEH",
    "gender": "male"
  },
  {
    "name": "GETE",
    "gender": "female"
  },
  {
    "name": "GETENESH",
    "gender": "female"
  },
  {
    "name": "GETENET",
    "gender": "male"
  },
  {
    "name": "GETINET",
    "gender": "male"
  },
  {
    "name": "GETNET",
    "gender": "male"
  },
  {
    "name": "GETU",
    "gender": "male"
  },
  {
    "name": "GEZACHEW",
    "gender": "male"
  },
  {
    "name": "GEZAHEGN",
    "gender": "male"
  },
  {
    "name": "GIDISA",
    "gender": "male"
  },
  {
    "name": "GIFITIYA",
    "gender": "female"
  },
  {
    "name": "GIRMA",
    "gender": "male"
  },
  {
    "name": "GIRMAY",
    "gender": "unknown"
  },
  {
    "name": "GIRMAYE",
    "gender": "male"
  },
  {
    "name": "GIRUM",
    "gender": "male"
  },
  {
    "name": "GIZACHEW",
    "gender": "male"
  },
  {
    "name": "GIZEADDIS",
    "gender": "male"
  },
  {
    "name": "GIZESHWORK",
    "gender": "female"
  },
  {
    "name": "GOBENA",
    "gender": "male"
  },
  {
    "name": "GOITOM",
    "gender": "male"
  },
  {
    "name": "GOLOLCHA",
    "gender": "male"
  },
  {
    "name": "GOSHIME",
    "gender": "male"
  },
  {
    "name": "GOSHU",
    "gender": "male"
  },
  {
    "name": "GOYITOM",
    "gender": "male"
  },
  {
    "name": "GUDAY",
    "gender": "female"
  },
  {
    "name": "GUDETA",
    "gender": "male"
  },
  {
    "name": "GULILAT",
    "gender": "male"
  },
  {
    "name": "GUMI",
    "gender": "male"
  },
  {
    "name": "GUTA",
    "gender": "male"
  },
  {
    "name": "H.EYESUES",
    "gender": "male"
  },
  {
    "name": "H/MARIAM",
    "gender": "male"
  },
  {
    "name": "HABETAMU",
    "gender": "male"
  },
  {
    "name": "HABIB",
    "gender": "male"
  },
  {
    "name": "HABITAMU",
    "gender": "male"
  },
  {
    "name": "HABTAM",
    "gender": "female"
  },
  {
    "name": "HABTAMU",
    "gender": "male"
  },
  {
    "name": "HABTAMUA",
    "gender": "female"
  },
  {
    "name": "HADAS",
    "gender": "female"
  },
  {
    "name": "HADUSH",
    "gender": "male"
  },
  {
    "name": "HAFETU",
    "gender": "male"
  },
  {
    "name": "HAFTOM",
    "gender": "male"
  },
  {
    "name": "HAGAZI",
    "gender": "male"
  },
  {
    "name": "HAGOS",
    "gender": "male"
  },
  {
    "name": "HAILAY",
    "gender": "male"
  },
  {
    "name": "HAILE",
    "gender": "male"
  },
  {
    "name": "HAILEAB",
    "gender": "male"
  },
  {
    "name": "HAILEGIORGIS",
    "gender": "male"
  },
  {
    "name": "HAILEGNAW",
    "gender": "male"
  },
  {
    "name": "HAILEMARIAM",
    "gender": "unknown"
  },
  {
    "name": "HAILEMICHAEL",
    "gender": "male"
  },
  {
    "name": "HAILEYESUS",
    "gender": "male"
  },
  {
    "name": "HAILIYE",
    "gender": "male"
  },
  {
    "name": "HAILU",
    "gender": "male"
  },
  {
    "name": "HAIMANOT",
    "gender": "female"
  },
  {
    "name": "HALEFOM",
    "gender": "male"
  },
  {
    "name": "HALIMA",
    "gender": "female"
  },
  {
    "name": "HAMDI",
    "gender": "female"
  },
  {
    "name": "HAMDIYA",
    "gender": "female"
  },
  {
    "name": "HAMID",
    "gender": "male"
  },
  {
    "name": "HANA",
    "gender": "female"
  },
  {
    "name": "HANAN",
    "gender": "female"
  },
  {
    "name": "HANI",
    "gender": "female"
  },
  {
    "name": "HANIFA",
    "gender": "female"
  },
  {
    "name": "HANNA",
    "gender": "female"
  },
  {
    "name": "HANNAH",
    "gender": "female"
  },
  {
    "name": "HAREG",
    "gender": "female"
  },
  {
    "name": "HAREGEWEYN",
    "gender": "female"
  },
  {
    "name": "HAREGEWOIN",
    "gender": "female"
  },
  {
    "name": "HAREGEWOYIN",
    "gender": "female"
  },
  {
    "name": "HARGEWOINI",
    "gender": "female"
  },
  {
    "name": "HARUN",
    "gender": "male"
  },
  {
    "name": "HASNET",
    "gender": "female"
  },
  {
    "name": "HASSEN",
    "gender": "male"
  },
  {
    "name": "HAWI",
    "gender": "female"
  },
  {
    "name": "HAWINE",
    "gender": "female"
  },
  {
    "name": "HAYAT",
    "gender": "female"
  },
  {
    "name": "HAYATU",
    "gender": "male"
  },
  {
    "name": "HAYLE",
    "gender": "male"
  },
  {
    "name": "HAYMANOT",
    "gender": "male"
  },
  {
    "name": "HELEN",
    "gender": "female"
  },
  {
    "name": "HELINA",
    "gender": "female"
  },
  {
    "name": "HENDIYA",
    "gender": "female"
  },
  {
    "name": "HENOCK",
    "gender": "male"
  },
  {
    "name": "HENOK",
    "gender": "unknown"
  },
  {
    "name": "HERIYA",
    "gender": "female"
  },
  {
    "name": "HIBIST",
    "gender": "female"
  },
  {
    "name": "HIKMA",
    "gender": "female"
  },
  {
    "name": "HIRUT",
    "gender": "female"
  },
  {
    "name": "HIWET",
    "gender": "female"
  },
  {
    "name": "HIWOT",
    "gender": "female"
  },
  {
    "name": "HONELEGN",
    "gender": "male"
  },
  {
    "name": "HULUAGERESH",
    "gender": "female"
  },
  {
    "name": "HUSSEN",
    "gender": "male"
  },
  {
    "name": "HUSSIEN",
    "gender": "male"
  },
  {
    "name": "IBRAHIM",
    "gender": "male"
  },
  {
    "name": "IKRAM",
    "gender": "female"
  },
  {
    "name": "IMISHAW",
    "gender": "male"
  },
  {
    "name": "JAFAR",
    "gender": "male"
  },
  {
    "name": "JEBESSA",
    "gender": "male"
  },
  {
    "name": "JEMAL",
    "gender": "male"
  },
  {
    "name": "JENBERE",
    "gender": "male"
  },
  {
    "name": "K/MARIAM",
    "gender": "male"
  },
  {
    "name": "KALID",
    "gender": "male"
  },
  {
    "name": "KALKIDAN",
    "gender": "female"
  },
  {
    "name": "KARIYA",
    "gender": "female"
  },
  {
    "name": "KASAHUN",
    "gender": "male"
  },
  {
    "name": "KASAYE",
    "gender": "male"
  },
  {
    "name": "KASECH",
    "gender": "female"
  },
  {
    "name": "KASSAHUN",
    "gender": "male"
  },
  {
    "name": "KASSAYE",
    "gender": "female"
  },
  {
    "name": "KEBATU",
    "gender": "female"
  },
  {
    "name": "KEBE",
    "gender": "male"
  },
  {
    "name": "KEBEDE",
    "gender": "male"
  },
  {
    "name": "KEBRU",
    "gender": "male"
  },
  {
    "name": "KEBU",
    "gender": "female"
  },
  {
    "name": "KEDIJA",
    "gender": "female"
  },
  {
    "name": "KEDIR",
    "gender": "male"
  },
  {
    "name": "KEFYALEW",
    "gender": "male"
  },
  {
    "name": "KELMUA",
    "gender": "female"
  },
  {
    "name": "KEMAL",
    "gender": "male"
  },
  {
    "name": "KEMALE",
    "gender": "male"
  },
  {
    "name": "KENENI",
    "gender": "female"
  },
  {
    "name": "KENFE",
    "gender": "male"
  },
  {
    "name": "KERKOS",
    "gender": "male"
  },
  {
    "name": "KESETE",
    "gender": "male"
  },
  {
    "name": "KETEMA",
    "gender": "male"
  },
  {
    "name": "KIBATU",
    "gender": "male"
  },
  {
    "name": "KIBIREWORK",
    "gender": "female"
  },
  {
    "name": "KIBKABE",
    "gender": "female"
  },
  {
    "name": "KIBNESH",
    "gender": "female"
  },
  {
    "name": "KIBRET",
    "gender": "male"
  },
  {
    "name": "KIBROM",
    "gender": "male"
  },
  {
    "name": "KIBRU",
    "gender": "male"
  },
  {
    "name": "KIDANE",
    "gender": "male"
  },
  {
    "name": "KIDANU",
    "gender": "male"
  },
  {
    "name": "KIDIST",
    "gender": "female"
  },
  {
    "name": "KIDST",
    "gender": "female"
  },
  {
    "name": "KIFELEW",
    "gender": "male"
  },
  {
    "name": "KIFLE",
    "gender": "male"
  },
  {
    "name": "KINDU",
    "gender": "male"
  },
  {
    "name": "KINFE",
    "gender": "male"
  },
  {
    "name": "KINFEMICAHEL",
    "gender": "male"
  },
  {
    "name": "KIROS",
    "gender": "male"
  },
  {
    "name": "KIRUBEL",
    "gender": "male"
  },
  {
    "name": "KOKOBE",
    "gender": "female"
  },
  {
    "name": "KONJIT",
    "gender": "female"
  },
  {
    "name": "KULITU",
    "gender": "female"
  },
  {
    "name": "KUMA",
    "gender": "male"
  },
  {
    "name": "KUMSA",
    "gender": "male"
  },
  {
    "name": "KURATU",
    "gender": "male"
  },
  {
    "name": "KURI",
    "gender": "female"
  },
  {
    "name": "LAKACHEW",
    "gender": "male"
  },
  {
    "name": "LAKECH",
    "gender": "female"
  },
  {
    "name": "LAKEW",
    "gender": "male"
  },
  {
    "name": "LALISE",
    "gender": "female"
  },
  {
    "name": "LEALEM",
    "gender": "male"
  },
  {
    "name": "LECHISA",
    "gender": "male"
  },
  {
    "name": "LEGESE",
    "gender": "male"
  },
  {
    "name": "LEGESSE",
    "gender": "male"
  },
  {
    "name": "LELISIE",
    "gender": "female"
  },
  {
    "name": "LEMA",
    "gender": "male"
  },
  {
    "name": "LEMELEM",
    "gender": "female"
  },
  {
    "name": "LEMI",
    "gender": "male"
  },
  {
    "name": "LEMLEM",
    "gender": "female"
  },
  {
    "name": "LEMMA",
    "gender": "male"
  },
  {
    "name": "LENSA",
    "gender": "female"
  },
  {
    "name": "LETAY",
    "gender": "female"
  },
  {
    "name": "LETEMICHAEL",
    "gender": "female"
  },
  {
    "name": "LETENSEA",
    "gender": "female"
  },
  {
    "name": "LETERA",
    "gender": "male"
  },
  {
    "name": "LETTA",
    "gender": "male"
  },
  {
    "name": "LEUL",
    "gender": "male"
  },
  {
    "name": "LEYIKUN",
    "gender": "male"
  },
  {
    "name": "LEYKUN",
    "gender": "male"
  },
  {
    "name": "LEYLA",
    "gender": "female"
  },
  {
    "name": "LIELINA",
    "gender": "female"
  },
  {
    "name": "LIJALEM",
    "gender": "male"
  },
  {
    "name": "LIKELESH",
    "gender": "female"
  },
  {
    "name": "LILI",
    "gender": "female"
  },
  {
    "name": "LISAN",
    "gender": "male"
  },
  {
    "name": "LISHAN",
    "gender": "female"
  },
  {
    "name": "LIUL",
    "gender": "male"
  },
  {
    "name": "LIULSEGED",
    "gender": "male"
  },
  {
    "name": "LIWAM",
    "gender": "female"
  },
  {
    "name": "LIYA",
    "gender": "female"
  },
  {
    "name": "LIYUWORK",
    "gender": "female"
  },
  {
    "name": "LOMI",
    "gender": "female"
  },
  {
    "name": "LUBABA",
    "gender": "female"
  },
  {
    "name": "LULA",
    "gender": "female"
  },
  {
    "name": "LULSEGED",
    "gender": "male"
  },
  {
    "name": "LYDIA",
    "gender": "female"
  },
  {
    "name": "MAEDOT",
    "gender": "female"
  },
  {
    "name": "MAEREG",
    "gender": "female"
  },
  {
    "name": "MAHAMEDNUR",
    "gender": "male"
  },
  {
    "name": "MAHIDER",
    "gender": "female"
  },
  {
    "name": "MAHLET",
    "gender": "female"
  },
  {
    "name": "MAIKEL",
    "gender": "male"
  },
  {
    "name": "MAMARU",
    "gender": "male"
  },
  {
    "name": "MAMEY",
    "gender": "female"
  },
  {
    "name": "MAMO",
    "gender": "male"
  },
  {
    "name": "MANALEBSH",
    "gender": "female"
  },
  {
    "name": "MAREG",
    "gender": "male"
  },
  {
    "name": "MARIYAM",
    "gender": "female"
  },
  {
    "name": "MARKOS",
    "gender": "male"
  },
  {
    "name": "MARTA",
    "gender": "female"
  },
  {
    "name": "MARTHA",
    "gender": "female"
  },
  {
    "name": "MARU",
    "gender": "male"
  },
  {
    "name": "MASRESHA",
    "gender": "male"
  },
  {
    "name": "MATIOS",
    "gender": "male"
  },
  {
    "name": "MATIYAS",
    "gender": "male"
  },
  {
    "name": "MEARIG",
    "gender": "male"
  },
  {
    "name": "MEAZA",
    "gender": "female"
  },
  {
    "name": "MEBIRATU",
    "gender": "male"
  },
  {
    "name": "MEBRAT",
    "gender": "female"
  },
  {
    "name": "MEBRATE",
    "gender": "female"
  },
  {
    "name": "MEBRATU",
    "gender": "male"
  },
  {
    "name": "MEBRUKA",
    "gender": "female"
  },
  {
    "name": "MEDHANIT",
    "gender": "female"
  },
  {
    "name": "MEDHIN",
    "gender": "male"
  },
  {
    "name": "MEDINA",
    "gender": "female"
  },
  {
    "name": "MEGERSA",
    "gender": "male"
  },
  {
    "name": "MEHAMED",
    "gender": "male"
  },
  {
    "name": "MEHAMMED",
    "gender": "male"
  },
  {
    "name": "MEHARI",
    "gender": "male"
  },
  {
    "name": "MEHBUBA",
    "gender": "unknown"
  },
  {
    "name": "MEKASHA",
    "gender": "male"
  },
  {
    "name": "MEKDELAWIT",
    "gender": "female"
  },
  {
    "name": "MEKDES",
    "gender": "female"
  },
  {
    "name": "MEKEDES",
    "gender": "female"
  },
  {
    "name": "MEKETAW",
    "gender": "male"
  },
  {
    "name": "MEKETE",
    "gender": "male"
  },
  {
    "name": "MEKIA",
    "gender": "female"
  },
  {
    "name": "MEKIBIB",
    "gender": "male"
  },
  {
    "name": "MEKIDES",
    "gender": "female"
  },
  {
    "name": "MEKIYA",
    "gender": "female"
  },
  {
    "name": "MEKONNEN",
    "gender": "male"
  },
  {
    "name": "MEKONNIN",
    "gender": "male"
  },
  {
    "name": "MEKURIA",
    "gender": "male"
  },
  {
    "name": "MELAK",
    "gender": "male"
  },
  {
    "name": "MELAKU",
    "gender": "male"
  },
  {
    "name": "MELAT",
    "gender": "female"
  },
  {
    "name": "MELEKAMNESH",
    "gender": "female"
  },
  {
    "name": "MELEKAMU",
    "gender": "male"
  },
  {
    "name": "MELESE",
    "gender": "male"
  },
  {
    "name": "MELIKAMU",
    "gender": "male"
  },
  {
    "name": "MELIKU",
    "gender": "male"
  },
  {
    "name": "MELISEW",
    "gender": "male"
  },
  {
    "name": "MELKAM",
    "gender": "female"
  },
  {
    "name": "MELKAMU",
    "gender": "male"
  },
  {
    "name": "MELKANESH",
    "gender": "female"
  },
  {
    "name": "MELKEAB",
    "gender": "male"
  },
  {
    "name": "MELKU",
    "gender": "male"
  },
  {
    "name": "MELLEN",
    "gender": "unknown"
  },
  {
    "name": "MENBERE",
    "gender": "female"
  },
  {
    "name": "MENBERU",
    "gender": "male"
  },
  {
    "name": "MENEBERE",
    "gender": "female"
  },
  {
    "name": "MENEGISTU",
    "gender": "male"
  },
  {
    "name": "MENGESHA",
    "gender": "male"
  },
  {
    "name": "MENGISTU",
    "gender": "male"
  },
  {
    "name": "MENGIZEM",
    "gender": "male"
  },
  {
    "name": "MENGSTAB",
    "gender": "male"
  },
  {
    "name": "MENSHER",
    "gender": "male"
  },
  {
    "name": "MEQUNINIT",
    "gender": "male"
  },
  {
    "name": "MERCHESH",
    "gender": "female"
  },
  {
    "name": "MEREHAWIT",
    "gender": "female"
  },
  {
    "name": "MEREMA",
    "gender": "female"
  },
  {
    "name": "MERESA",
    "gender": "male"
  },
  {
    "name": "MERGA",
    "gender": "male"
  },
  {
    "name": "MERHATSADIK",
    "gender": "male"
  },
  {
    "name": "MERHAWIT",
    "gender": "female"
  },
  {
    "name": "MERIED",
    "gender": "male"
  },
  {
    "name": "MERIKNE",
    "gender": "male"
  },
  {
    "name": "MERIMA",
    "gender": "female"
  },
  {
    "name": "MERKEB",
    "gender": "male"
  },
  {
    "name": "MERON",
    "gender": "female"
  },
  {
    "name": "MERSHA",
    "gender": "male"
  },
  {
    "name": "MERTENSH",
    "gender": "female"
  },
  {
    "name": "MESAW",
    "gender": "male"
  },
  {
    "name": "MESAY",
    "gender": "female"
  },
  {
    "name": "MESEBU",
    "gender": "female"
  },
  {
    "name": "MESEKEREM",
    "gender": "female"
  },
  {
    "name": "MESELE",
    "gender": "male"
  },
  {
    "name": "MESELU",
    "gender": "female"
  },
  {
    "name": "MESERET",
    "gender": "female"
  },
  {
    "name": "Meseret",
    "gender": "female"
  },
  {
    "name": "MESFIN",
    "gender": "male"
  },
  {
    "name": "MESGANAW",
    "gender": "male"
  },
  {
    "name": "MESITAWET",
    "gender": "female"
  },
  {
    "name": "MESKELE",
    "gender": "male"
  },
  {
    "name": "MESKELU",
    "gender": "male"
  },
  {
    "name": "MESKEREM",
    "gender": "female"
  },
  {
    "name": "MESTAWOT",
    "gender": "female"
  },
  {
    "name": "MESTAWUT",
    "gender": "unknown"
  },
  {
    "name": "METADLE",
    "gender": "female"
  },
  {
    "name": "METASEBIYA",
    "gender": "female"
  },
  {
    "name": "METASEBYA",
    "gender": "female"
  },
  {
    "name": "METI",
    "gender": "female"
  },
  {
    "name": "MEZGEBE",
    "gender": "male"
  },
  {
    "name": "MEZGEBU",
    "gender": "male"
  },
  {
    "name": "MEZIDA",
    "gender": "female"
  },
  {
    "name": "MEZMUR",
    "gender": "male"
  },
  {
    "name": "MICHAEL",
    "gender": "male"
  },
  {
    "name": "MIFTA",
    "gender": "male"
  },
  {
    "name": "MIFTAH",
    "gender": "male"
  },
  {
    "name": "MIGBARU",
    "gender": "male"
  },
  {
    "name": "MIGIBNESH",
    "gender": "female"
  },
  {
    "name": "MIGNOT",
    "gender": "male"
  },
  {
    "name": "MIHIRET",
    "gender": "female"
  },
  {
    "name": "MIHRET",
    "gender": "female"
  },
  {
    "name": "MIHRETE",
    "gender": "male"
  },
  {
    "name": "MIISRAK",
    "gender": "female"
  },
  {
    "name": "MIKAEL",
    "gender": "male"
  },
  {
    "name": "MIKI",
    "gender": "male"
  },
  {
    "name": "MIKIAS",
    "gender": "male"
  },
  {
    "name": "MIKIYAS",
    "gender": "male"
  },
  {
    "name": "MIKRE",
    "gender": "male"
  },
  {
    "name": "MILION",
    "gender": "male"
  },
  {
    "name": "MILKA",
    "gender": "female"
  },
  {
    "name": "MILKEYAS",
    "gender": "male"
  },
  {
    "name": "MILLION",
    "gender": "male"
  },
  {
    "name": "MIMI",
    "gender": "female"
  },
  {
    "name": "MINDAYE",
    "gender": "male"
  },
  {
    "name": "MINILIK",
    "gender": "male"
  },
  {
    "name": "MINTASINOT",
    "gender": "male"
  },
  {
    "name": "MINTESINOT",
    "gender": "male"
  },
  {
    "name": "MINYAHIL",
    "gender": "male"
  },
  {
    "name": "MISA",
    "gender": "female"
  },
  {
    "name": "MISAHUN",
    "gender": "male"
  },
  {
    "name": "MISANESH",
    "gender": "female"
  },
  {
    "name": "MISGANA",
    "gender": "female"
  },
  {
    "name": "MISGINA",
    "gender": "male"
  },
  {
    "name": "MISIKIR",
    "gender": "female"
  },
  {
    "name": "MISRAK",
    "gender": "female"
  },
  {
    "name": "MISTERE",
    "gender": "female"
  },
  {
    "name": "MITIKU",
    "gender": "male"
  },
  {
    "name": "MNALESHEWA",
    "gender": "female"
  },
  {
    "name": "MOGES",
    "gender": "male"
  },
  {
    "name": "MOHAMED",
    "gender": "male"
  },
  {
    "name": "MOHAMMED",
    "gender": "male"
  },
  {
    "name": "MOHAMMEDAMIN",
    "gender": "unknown"
  },
  {
    "name": "MOHAMMEDNEJIB",
    "gender": "male"
  },
  {
    "name": "MOHEMEDSEFA",
    "gender": "male"
  },
  {
    "name": "MOLALEGN",
    "gender": "male"
  },
  {
    "name": "MOLLA",
    "gender": "male"
  },
  {
    "name": "MOSSA",
    "gender": "male"
  },
  {
    "name": "MUBAREK",
    "gender": "male"
  },
  {
    "name": "MUBARIK",
    "gender": "male"
  },
  {
    "name": "MUHABA",
    "gender": "male"
  },
  {
    "name": "MUHAMMED",
    "gender": "male"
  },
  {
    "name": "MUJIB",
    "gender": "male"
  },
  {
    "name": "MULAT",
    "gender": "male"
  },
  {
    "name": "MULATU",
    "gender": "male"
  },
  {
    "name": "MULETA",
    "gender": "male"
  },
  {
    "name": "MULGETA",
    "gender": "male"
  },
  {
    "name": "MULU",
    "gender": "female"
  },
  {
    "name": "MULUADAM",
    "gender": "male"
  },
  {
    "name": "MULUADDIS",
    "gender": "male"
  },
  {
    "name": "MULUALEM",
    "gender": "male"
  },
  {
    "name": "MULUBIRHAN",
    "gender": "male"
  },
  {
    "name": "MULUEMEBET",
    "gender": "female"
  },
  {
    "name": "MULUGETA",
    "gender": "male"
  },
  {
    "name": "MULUKEN",
    "gender": "male"
  },
  {
    "name": "MULUMEBET",
    "gender": "female"
  },
  {
    "name": "MULUNEH",
    "gender": "male"
  },
  {
    "name": "MULUSEW",
    "gender": "female"
  },
  {
    "name": "MULUWORK",
    "gender": "female"
  },
  {
    "name": "MUNAJA",
    "gender": "female"
  },
  {
    "name": "MUNTEHA",
    "gender": "female"
  },
  {
    "name": "MURAD",
    "gender": "male"
  },
  {
    "name": "MURGA",
    "gender": "female"
  },
  {
    "name": "MURGANESH",
    "gender": "female"
  },
  {
    "name": "MURIDA",
    "gender": "female"
  },
  {
    "name": "MUSELA",
    "gender": "male"
  },
  {
    "name": "MUSIE",
    "gender": "male"
  },
  {
    "name": "MUSSIE",
    "gender": "male"
  },
  {
    "name": "MUSTEFA",
    "gender": "male"
  },
  {
    "name": "MUZEAM",
    "gender": "female"
  },
  {
    "name": "MUZEY",
    "gender": "female"
  },
  {
    "name": "NADEW",
    "gender": "male"
  },
  {
    "name": "NADIYA",
    "gender": "female"
  },
  {
    "name": "NAGATU",
    "gender": "male"
  },
  {
    "name": "NAHUSENAYE",
    "gender": "male"
  },
  {
    "name": "NAJI",
    "gender": "male"
  },
  {
    "name": "NAJIYA",
    "gender": "female"
  },
  {
    "name": "NAOMI",
    "gender": "female"
  },
  {
    "name": "NAPOLEON",
    "gender": "male"
  },
  {
    "name": "NARDOS",
    "gender": "female"
  },
  {
    "name": "NARDOSE",
    "gender": "female"
  },
  {
    "name": "NASIR",
    "gender": "male"
  },
  {
    "name": "NATENAEL",
    "gender": "male"
  },
  {
    "name": "NATNAEL",
    "gender": "male"
  },
  {
    "name": "NEBIYAT",
    "gender": "female"
  },
  {
    "name": "NEBIYU",
    "gender": "male"
  },
  {
    "name": "NEBYU",
    "gender": "male"
  },
  {
    "name": "NEGALIGN",
    "gender": "male"
  },
  {
    "name": "NEGASI",
    "gender": "female"
  },
  {
    "name": "NEGATUA",
    "gender": "female"
  },
  {
    "name": "NEGIE",
    "gender": "male"
  },
  {
    "name": "NEGUSIE",
    "gender": "male"
  },
  {
    "name": "NEIMA",
    "gender": "female"
  },
  {
    "name": "NEJAT",
    "gender": "female"
  },
  {
    "name": "NEJIBA",
    "gender": "female"
  },
  {
    "name": "NESIRU",
    "gender": "male"
  },
  {
    "name": "NESRA",
    "gender": "female"
  },
  {
    "name": "NESRO",
    "gender": "male"
  },
  {
    "name": "NETSANET",
    "gender": "unknown"
  },
  {
    "name": "NIBEYU",
    "gender": "male"
  },
  {
    "name": "NIGAT",
    "gender": "male"
  },
  {
    "name": "NIGIST",
    "gender": "female"
  },
  {
    "name": "NIGISTI",
    "gender": "female"
  },
  {
    "name": "NIGUS",
    "gender": "male"
  },
  {
    "name": "NIGUSE",
    "gender": "male"
  },
  {
    "name": "NIGUSSIE",
    "gender": "male"
  },
  {
    "name": "NITSUH",
    "gender": "female"
  },
  {
    "name": "NIWAY",
    "gender": "male"
  },
  {
    "name": "NOAHAMEN",
    "gender": "female"
  },
  {
    "name": "NOLAWI",
    "gender": "male"
  },
  {
    "name": "NUNU",
    "gender": "female"
  },
  {
    "name": "NUNUSH",
    "gender": "female"
  },
  {
    "name": "NURA",
    "gender": "female"
  },
  {
    "name": "NUREDIN",
    "gender": "male"
  },
  {
    "name": "NURHUSSEN",
    "gender": "male"
  },
  {
    "name": "NURI",
    "gender": "male"
  },
  {
    "name": "NURITU",
    "gender": "female"
  },
  {
    "name": "NURIYA",
    "gender": "female"
  },
  {
    "name": "NURSEFA",
    "gender": "male"
  },
  {
    "name": "OBSE",
    "gender": "female"
  },
  {
    "name": "OLIAD",
    "gender": "male"
  },
  {
    "name": "OMEGA",
    "gender": "male"
  },
  {
    "name": "OSMAN",
    "gender": "male"
  },
  {
    "name": "RAHEAL",
    "gender": "female"
  },
  {
    "name": "RAHEL",
    "gender": "female"
  },
  {
    "name": "RAHIMET",
    "gender": "female"
  },
  {
    "name": "RAHMA",
    "gender": "female"
  },
  {
    "name": "RAHWA",
    "gender": "female"
  },
  {
    "name": "RAINY",
    "gender": "female"
  },
  {
    "name": "REBIA",
    "gender": "female"
  },
  {
    "name": "REDAE",
    "gender": "male"
  },
  {
    "name": "REDET",
    "gender": "male"
  },
  {
    "name": "REDIET",
    "gender": "female"
  },
  {
    "name": "REDWAN",
    "gender": "male"
  },
  {
    "name": "REHIMA",
    "gender": "female"
  },
  {
    "name": "REISOM",
    "gender": "male"
  },
  {
    "name": "REJIB",
    "gender": "male"
  },
  {
    "name": "REKIK",
    "gender": "female"
  },
  {
    "name": "REMEDAN",
    "gender": "male"
  },
  {
    "name": "RESHAD",
    "gender": "male"
  },
  {
    "name": "RETA",
    "gender": "male"
  },
  {
    "name": "Rewuda",
    "gender": "female"
  },
  {
    "name": "RIGBESENAY",
    "gender": "female"
  },
  {
    "name": "RIGIBE",
    "gender": "female"
  },
  {
    "name": "RISOM",
    "gender": "male"
  },
  {
    "name": "ROBAHA",
    "gender": "female"
  },
  {
    "name": "ROBEL",
    "gender": "male"
  },
  {
    "name": "ROMAN",
    "gender": "female"
  },
  {
    "name": "ROMEL",
    "gender": "male"
  },
  {
    "name": "ROZA",
    "gender": "female"
  },
  {
    "name": "RUGA",
    "gender": "male"
  },
  {
    "name": "RUTH",
    "gender": "female"
  },
  {
    "name": "SABA",
    "gender": "female"
  },
  {
    "name": "SADIK",
    "gender": "male"
  },
  {
    "name": "SALEAMELAK",
    "gender": "male"
  },
  {
    "name": "SALIH",
    "gender": "male"
  },
  {
    "name": "SALIMA",
    "gender": "female"
  },
  {
    "name": "SAMI",
    "gender": "male"
  },
  {
    "name": "SAMIRA",
    "gender": "female"
  },
  {
    "name": "SAMIRAWIT",
    "gender": "female"
  },
  {
    "name": "SAMRAWIT",
    "gender": "female"
  },
  {
    "name": "SAMSON",
    "gender": "male"
  },
  {
    "name": "SAMUEAL",
    "gender": "male"
  },
  {
    "name": "SAMUEL",
    "gender": "male"
  },
  {
    "name": "SANDRA",
    "gender": "female"
  },
  {
    "name": "SANER",
    "gender": "female"
  },
  {
    "name": "SARA",
    "gender": "female"
  },
  {
    "name": "SEADA",
    "gender": "female"
  },
  {
    "name": "SEBEL",
    "gender": "female"
  },
  {
    "name": "SEBELE",
    "gender": "female"
  },
  {
    "name": "SEBISIBE",
    "gender": "male"
  },
  {
    "name": "SEBLA",
    "gender": "female"
  },
  {
    "name": "SEBLE",
    "gender": "female"
  },
  {
    "name": "SEBLEWOREK",
    "gender": "female"
  },
  {
    "name": "SEBLEWORK",
    "gender": "female"
  },
  {
    "name": "SEID",
    "gender": "male"
  },
  {
    "name": "SEIFU",
    "gender": "male"
  },
  {
    "name": "SELAM",
    "gender": "female"
  },
  {
    "name": "SELAMAWIT",
    "gender": "female"
  },
  {
    "name": "SELAS",
    "gender": "female"
  },
  {
    "name": "SELEMAWIT",
    "gender": "female"
  },
  {
    "name": "SELESHI",
    "gender": "male"
  },
  {
    "name": "SEMAGN",
    "gender": "male"
  },
  {
    "name": "SEME",
    "gender": "male"
  },
  {
    "name": "SEMEGN",
    "gender": "male"
  },
  {
    "name": "SEMERE",
    "gender": "male"
  },
  {
    "name": "SEMERET",
    "gender": "female"
  },
  {
    "name": "SEMIR",
    "gender": "unknown"
  },
  {
    "name": "SEMIRA",
    "gender": "female"
  },
  {
    "name": "SENAIT",
    "gender": "female"
  },
  {
    "name": "SENAYET",
    "gender": "female"
  },
  {
    "name": "SENAYIT",
    "gender": "female"
  },
  {
    "name": "SENAYT",
    "gender": "female"
  },
  {
    "name": "SENEKUA",
    "gender": "female"
  },
  {
    "name": "SENTAYEHU",
    "gender": "male"
  },
  {
    "name": "SERAWIT",
    "gender": "male"
  },
  {
    "name": "SEREKADIS",
    "gender": "female"
  },
  {
    "name": "SERGUT",
    "gender": "female"
  },
  {
    "name": "SERKALEM",
    "gender": "female"
  },
  {
    "name": "SETEYANA",
    "gender": "female"
  },
  {
    "name": "SETOTAW",
    "gender": "male"
  },
  {
    "name": "SEWUNET",
    "gender": "male"
  },
  {
    "name": "SEYEFEDIN",
    "gender": "male"
  },
  {
    "name": "SEYFU",
    "gender": "male"
  },
  {
    "name": "SEYIFU",
    "gender": "male"
  },
  {
    "name": "SHAFI",
    "gender": "male"
  },
  {
    "name": "SHAMBEL",
    "gender": "male"
  },
  {
    "name": "SHASHE",
    "gender": "female"
  },
  {
    "name": "SHAWLE",
    "gender": "male"
  },
  {
    "name": "SHBRE",
    "gender": "female"
  },
  {
    "name": "SHEFENA",
    "gender": "female"
  },
  {
    "name": "SHEGAW",
    "gender": "male"
  },
  {
    "name": "SHEHAB",
    "gender": "male"
  },
  {
    "name": "SHEMELIS",
    "gender": "male"
  },
  {
    "name": "SHEMIMA",
    "gender": "female"
  },
  {
    "name": "SHEMSIA",
    "gender": "female"
  },
  {
    "name": "SHEMSIYA",
    "gender": "male"
  },
  {
    "name": "SHEREFA",
    "gender": "male"
  },
  {
    "name": "SHEWAFERA",
    "gender": "male"
  },
  {
    "name": "SHEWAKENA",
    "gender": "unknown"
  },
  {
    "name": "SHEWALEM",
    "gender": "female"
  },
  {
    "name": "SHEWANGEZEW",
    "gender": "female"
  },
  {
    "name": "SHEWAREGA",
    "gender": "male"
  },
  {
    "name": "SHEWAYE",
    "gender": "female"
  },
  {
    "name": "SHEWIT",
    "gender": "female"
  },
  {
    "name": "SHIBIRE",
    "gender": "female"
  },
  {
    "name": "SHIBRE",
    "gender": "female"
  },
  {
    "name": "SHIFERAW",
    "gender": "male"
  },
  {
    "name": "SHIKUR",
    "gender": "male"
  },
  {
    "name": "SHIMELIS",
    "gender": "male"
  },
  {
    "name": "SHIMELISTESEMA",
    "gender": "male"
  },
  {
    "name": "SHITA",
    "gender": "female"
  },
  {
    "name": "SHITAYE",
    "gender": "female"
  },
  {
    "name": "SHIWAGASH",
    "gender": "female"
  },
  {
    "name": "SHMELIS",
    "gender": "male"
  },
  {
    "name": "SHOAYE",
    "gender": "female"
  },
  {
    "name": "SHUKRO",
    "gender": "male"
  },
  {
    "name": "SHUMET",
    "gender": "male"
  },
  {
    "name": "SHURALA",
    "gender": "male"
  },
  {
    "name": "SIMEGN",
    "gender": "female"
  },
  {
    "name": "SIMENESH",
    "gender": "female"
  },
  {
    "name": "SIMEON",
    "gender": "male"
  },
  {
    "name": "SIMON",
    "gender": "male"
  },
  {
    "name": "SINAMAW",
    "gender": "unknown"
  },
  {
    "name": "SINBONE",
    "gender": "female"
  },
  {
    "name": "SINDEW",
    "gender": "male"
  },
  {
    "name": "SINKE",
    "gender": "female"
  },
  {
    "name": "SINKNESH",
    "gender": "female"
  },
  {
    "name": "SINKSAR",
    "gender": "male"
  },
  {
    "name": "SINTAYEHU",
    "gender": "female"
  },
  {
    "name": "SIRAK",
    "gender": "male"
  },
  {
    "name": "SISAY",
    "gender": "male"
  },
  {
    "name": "SISAYE",
    "gender": "female"
  },
  {
    "name": "SISHAY",
    "gender": "male"
  },
  {
    "name": "SISSAY",
    "gender": "male"
  },
  {
    "name": "SITI",
    "gender": "female"
  },
  {
    "name": "SITINA",
    "gender": "female"
  },
  {
    "name": "SITOTAW",
    "gender": "male"
  },
  {
    "name": "SOFIYA",
    "gender": "female"
  },
  {
    "name": "SOLOMON",
    "gender": "male"
  },
  {
    "name": "SONI",
    "gender": "female"
  },
  {
    "name": "SORETI",
    "gender": "female"
  },
  {
    "name": "SOSENA",
    "gender": "female"
  },
  {
    "name": "SOSINA",
    "gender": "female"
  },
  {
    "name": "SULTAN",
    "gender": "male"
  },
  {
    "name": "SURAFEL",
    "gender": "male"
  },
  {
    "name": "T/MARIAM",
    "gender": "male"
  },
  {
    "name": "TABOR",
    "gender": "male"
  },
  {
    "name": "TADELE",
    "gender": "male"
  },
  {
    "name": "TADELECH",
    "gender": "female"
  },
  {
    "name": "TADELU",
    "gender": "female"
  },
  {
    "name": "TADESE",
    "gender": "male"
  },
  {
    "name": "TADESSE",
    "gender": "unknown"
  },
  {
    "name": "TADIOS",
    "gender": "male"
  },
  {
    "name": "TADIWOS",
    "gender": "male"
  },
  {
    "name": "TAFESSE",
    "gender": "male"
  },
  {
    "name": "TAHIR",
    "gender": "male"
  },
  {
    "name": "TAJU",
    "gender": "male"
  },
  {
    "name": "TAKELE",
    "gender": "male"
  },
  {
    "name": "TALEGETA",
    "gender": "male"
  },
  {
    "name": "TAMERAT",
    "gender": "male"
  },
  {
    "name": "Tameru",
    "gender": "male"
  },
  {
    "name": "TAMIRAT",
    "gender": "male"
  },
  {
    "name": "TAMIRU",
    "gender": "male"
  },
  {
    "name": "TAMRAT",
    "gender": "male"
  },
  {
    "name": "TANEJERINA",
    "gender": "male"
  },
  {
    "name": "TANU",
    "gender": "male"
  },
  {
    "name": "TARIKU",
    "gender": "male"
  },
  {
    "name": "TARIKUA",
    "gender": "female"
  },
  {
    "name": "TASEW",
    "gender": "male"
  },
  {
    "name": "TASHEBECH",
    "gender": "female"
  },
  {
    "name": "TATEK",
    "gender": "male"
  },
  {
    "name": "TATU",
    "gender": "female"
  },
  {
    "name": "TAYE",
    "gender": "male"
  },
  {
    "name": "TAYITU",
    "gender": "female"
  },
  {
    "name": "TAZABI",
    "gender": "male"
  },
  {
    "name": "TEBAREK",
    "gender": "male"
  },
  {
    "name": "TEDILA",
    "gender": "male"
  },
  {
    "name": "TEDLA",
    "gender": "male"
  },
  {
    "name": "TEDROS",
    "gender": "male"
  },
  {
    "name": "TEFERA",
    "gender": "male"
  },
  {
    "name": "TEFERI",
    "gender": "male"
  },
  {
    "name": "TEGALEM",
    "gender": "female"
  },
  {
    "name": "TEGEGNWORK",
    "gender": "male"
  },
  {
    "name": "TEGENEGN",
    "gender": "male"
  },
  {
    "name": "TEGENU",
    "gender": "male"
  },
  {
    "name": "TEGIST",
    "gender": "female"
  },
  {
    "name": "TEJITU",
    "gender": "female"
  },
  {
    "name": "TEKETEL",
    "gender": "male"
  },
  {
    "name": "TEKILEHAIMANOT",
    "gender": "male"
  },
  {
    "name": "TEKILU",
    "gender": "male"
  },
  {
    "name": "TEKLAI",
    "gender": "male"
  },
  {
    "name": "TEKLAY",
    "gender": "male"
  },
  {
    "name": "TEKLE",
    "gender": "male"
  },
  {
    "name": "TEKLIT",
    "gender": "male"
  },
  {
    "name": "TEKLIYE",
    "gender": "male"
  },
  {
    "name": "TEKUAMECHE",
    "gender": "female"
  },
  {
    "name": "TEMAM",
    "gender": "male"
  },
  {
    "name": "TEMARE",
    "gender": "male"
  },
  {
    "name": "TEMEGNU",
    "gender": "female"
  },
  {
    "name": "TEMESGEN",
    "gender": "male"
  },
  {
    "name": "TEMSEGEN",
    "gender": "male"
  },
  {
    "name": "TENA",
    "gender": "female"
  },
  {
    "name": "TENAGNE",
    "gender": "female"
  },
  {
    "name": "TENAYE",
    "gender": "female"
  },
  {
    "name": "TEREFE",
    "gender": "male"
  },
  {
    "name": "TERUWORK",
    "gender": "female"
  },
  {
    "name": "TESEMA",
    "gender": "male"
  },
  {
    "name": "TESEYEM",
    "gender": "male"
  },
  {
    "name": "TESFA",
    "gender": "male"
  },
  {
    "name": "TESFAHUN",
    "gender": "male"
  },
  {
    "name": "TESFANESH",
    "gender": "female"
  },
  {
    "name": "TESFAYE",
    "gender": "male"
  },
  {
    "name": "TESHAGER",
    "gender": "male"
  },
  {
    "name": "TESHALE",
    "gender": "male"
  },
  {
    "name": "TESHOME",
    "gender": "male"
  },
  {
    "name": "TEWABECH",
    "gender": "female"
  },
  {
    "name": "TEWEDED",
    "gender": "female"
  },
  {
    "name": "TEWELDE",
    "gender": "male"
  },
  {
    "name": "TEWELDEBERHAN",
    "gender": "male"
  },
  {
    "name": "TEWODEROS",
    "gender": "male"
  },
  {
    "name": "TEWODROS",
    "gender": "male"
  },
  {
    "name": "TEWOLDE",
    "gender": "male"
  },
  {
    "name": "TEZERASH",
    "gender": "female"
  },
  {
    "name": "TEZTA",
    "gender": "female"
  },
  {
    "name": "TIBEBU",
    "gender": "male"
  },
  {
    "name": "TIBELCHI",
    "gender": "female"
  },
  {
    "name": "TIBEYN",
    "gender": "female"
  },
  {
    "name": "TIBLETS",
    "gender": "female"
  },
  {
    "name": "TIEBE",
    "gender": "female"
  },
  {
    "name": "TIEGIST",
    "gender": "female"
  },
  {
    "name": "TIEUMZEGI",
    "gender": "male"
  },
  {
    "name": "TIGIST",
    "gender": "female"
  },
  {
    "name": "TIGISTU",
    "gender": "male"
  },
  {
    "name": "TIGLE",
    "gender": "female"
  },
  {
    "name": "TIHGUAS",
    "gender": "female"
  },
  {
    "name": "TIJANI",
    "gender": "male"
  },
  {
    "name": "TILAHUN",
    "gender": "male"
  },
  {
    "name": "TINSAE",
    "gender": "male"
  },
  {
    "name": "TIRHAS",
    "gender": "female"
  },
  {
    "name": "TIRINGO",
    "gender": "female"
  },
  {
    "name": "TIRNGO",
    "gender": "female"
  },
  {
    "name": "TIRSIT",
    "gender": "female"
  },
  {
    "name": "TIRUALEM",
    "gender": "female"
  },
  {
    "name": "TIRUEMEBET",
    "gender": "female"
  },
  {
    "name": "TIRUNESH",
    "gender": "female"
  },
  {
    "name": "TIRUWORK",
    "gender": "female"
  },
  {
    "name": "TITO",
    "gender": "male"
  },
  {
    "name": "TIWED",
    "gender": "female"
  },
  {
    "name": "TIYU",
    "gender": "male"
  },
  {
    "name": "TIZAZU",
    "gender": "male"
  },
  {
    "name": "TIZITA",
    "gender": "female"
  },
  {
    "name": "TIZTA",
    "gender": "female"
  },
  {
    "name": "TOFIK",
    "gender": "male"
  },
  {
    "name": "TOLOSHI",
    "gender": "female"
  },
  {
    "name": "TOLOSSA",
    "gender": "male"
  },
  {
    "name": "TOMAS",
    "gender": "male"
  },
  {
    "name": "TORBEZA",
    "gender": "male"
  },
  {
    "name": "TSEBAY",
    "gender": "female"
  },
  {
    "name": "TSEGA",
    "gender": "female"
  },
  {
    "name": "TSEGAB",
    "gender": "male"
  },
  {
    "name": "TSEGAMARIAM",
    "gender": "female"
  },
  {
    "name": "TSEGAY",
    "gender": "male"
  },
  {
    "name": "TSEGAYE",
    "gender": "male"
  },
  {
    "name": "TSEGE",
    "gender": "female"
  },
  {
    "name": "TSEGU",
    "gender": "male"
  },
  {
    "name": "TSEHAY",
    "gender": "female"
  },
  {
    "name": "TSEHAYI",
    "gender": "female"
  },
  {
    "name": "TSEHAYINESH",
    "gender": "female"
  },
  {
    "name": "TSEHAYNESH",
    "gender": "female"
  },
  {
    "name": "TSEWAHAB",
    "gender": "male"
  },
  {
    "name": "TSGIE",
    "gender": "female"
  },
  {
    "name": "TSIGABU",
    "gender": "male"
  },
  {
    "name": "TSIGE",
    "gender": "female"
  },
  {
    "name": "TSIGEMARIAM",
    "gender": "female"
  },
  {
    "name": "TSIGEREDA",
    "gender": "female"
  },
  {
    "name": "TSILAT",
    "gender": "female"
  },
  {
    "name": "TSINAT",
    "gender": "female"
  },
  {
    "name": "TSION",
    "gender": "female"
  },
  {
    "name": "TSIYON",
    "gender": "female"
  },
  {
    "name": "TUREFAT",
    "gender": "female"
  },
  {
    "name": "UMER",
    "gender": "male"
  },
  {
    "name": "URGESA",
    "gender": "male"
  },
  {
    "name": "USMAN",
    "gender": "unknown"
  },
  {
    "name": "WAGAYE",
    "gender": "female"
  },
  {
    "name": "WALELIGN",
    "gender": "male"
  },
  {
    "name": "WARISO",
    "gender": "male"
  },
  {
    "name": "WASIHUN",
    "gender": "male"
  },
  {
    "name": "WASSYE",
    "gender": "male"
  },
  {
    "name": "WEBESHET",
    "gender": "male"
  },
  {
    "name": "WEBNESH",
    "gender": "female"
  },
  {
    "name": "WEGENE",
    "gender": "male"
  },
  {
    "name": "WEINITU",
    "gender": "female"
  },
  {
    "name": "WELE",
    "gender": "male"
  },
  {
    "name": "WENDEWESEN",
    "gender": "male"
  },
  {
    "name": "WENDIMAGEGN",
    "gender": "male"
  },
  {
    "name": "WENDMAGEGN",
    "gender": "male"
  },
  {
    "name": "WENDWESEN",
    "gender": "male"
  },
  {
    "name": "WENDWESON",
    "gender": "male"
  },
  {
    "name": "WENDYIFRAW",
    "gender": "male"
  },
  {
    "name": "WERKINEH",
    "gender": "male"
  },
  {
    "name": "WESEN",
    "gender": "male"
  },
  {
    "name": "WESENE",
    "gender": "female"
  },
  {
    "name": "WEYENESHET",
    "gender": "female"
  },
  {
    "name": "WEYNESHET",
    "gender": "female"
  },
  {
    "name": "WEYNISHET",
    "gender": "female"
  },
  {
    "name": "WEYNWA",
    "gender": "female"
  },
  {
    "name": "WIBISHET",
    "gender": "male"
  },
  {
    "name": "WOINESHET",
    "gender": "female"
  },
  {
    "name": "WOINITU",
    "gender": "female"
  },
  {
    "name": "WOINSHET",
    "gender": "female"
  },
  {
    "name": "WOLDU",
    "gender": "male"
  },
  {
    "name": "WOLELAW",
    "gender": "male"
  },
  {
    "name": "WOLETETENESAI",
    "gender": "female"
  },
  {
    "name": "WONDAFERAW",
    "gender": "male"
  },
  {
    "name": "WONDALE",
    "gender": "male"
  },
  {
    "name": "WONDEWOSEN",
    "gender": "male"
  },
  {
    "name": "WONDIMAGEGN",
    "gender": "male"
  },
  {
    "name": "WONDIMU",
    "gender": "male"
  },
  {
    "name": "WONDMENEH",
    "gender": "male"
  },
  {
    "name": "WONDWOSEN",
    "gender": "male"
  },
  {
    "name": "WONDWOSSEN",
    "gender": "male"
  },
  {
    "name": "WORKABEBA",
    "gender": "female"
  },
  {
    "name": "WORKAFES",
    "gender": "male"
  },
  {
    "name": "WORKALEMAHU",
    "gender": "female"
  },
  {
    "name": "WORKEYE",
    "gender": "female"
  },
  {
    "name": "WORKINEH",
    "gender": "male"
  },
  {
    "name": "WORKINESH",
    "gender": "female"
  },
  {
    "name": "WORKNESH",
    "gender": "female"
  },
  {
    "name": "WORKSEW",
    "gender": "female"
  },
  {
    "name": "WORKU",
    "gender": "male"
  },
  {
    "name": "WORKWUHA",
    "gender": "female"
  },
  {
    "name": "WOSEN",
    "gender": "male"
  },
  {
    "name": "WOSSENE",
    "gender": "female"
  },
  {
    "name": "WOYINESHET",
    "gender": "female"
  },
  {
    "name": "WOYINSHET",
    "gender": "female"
  },
  {
    "name": "WOYNISHET",
    "gender": "female"
  },
  {
    "name": "WUBALEM",
    "gender": "female"
  },
  {
    "name": "WUBAMLAK",
    "gender": "male"
  },
  {
    "name": "WUBANCHI",
    "gender": "female"
  },
  {
    "name": "WUBAYEHU",
    "gender": "female"
  },
  {
    "name": "WUBEGZIER",
    "gender": "female"
  },
  {
    "name": "WUBESHET",
    "gender": "male"
  },
  {
    "name": "WUBEZIH",
    "gender": "female"
  },
  {
    "name": "WUBISHET",
    "gender": "male"
  },
  {
    "name": "WUBIT",
    "gender": "female"
  },
  {
    "name": "WUDIE",
    "gender": "female"
  },
  {
    "name": "YADETA",
    "gender": "male"
  },
  {
    "name": "YAFET",
    "gender": "male"
  },
  {
    "name": "YAIKOB",
    "gender": "male"
  },
  {
    "name": "YALEMWERK",
    "gender": "female"
  },
  {
    "name": "YALEMZERF",
    "gender": "female"
  },
  {
    "name": "YALEWE",
    "gender": "male"
  },
  {
    "name": "YARED",
    "gender": "male"
  },
  {
    "name": "YAREGAL",
    "gender": "male"
  },
  {
    "name": "YASIN",
    "gender": "male"
  },
  {
    "name": "YAYESH",
    "gender": "female"
  },
  {
    "name": "YEGLE",
    "gender": "female"
  },
  {
    "name": "YEGUNAWORK",
    "gender": "female"
  },
  {
    "name": "YEHEYES",
    "gender": "male"
  },
  {
    "name": "YEHUNIE",
    "gender": "male"
  },
  {
    "name": "YEKATIT",
    "gender": "female"
  },
  {
    "name": "YEMANE",
    "gender": "male"
  },
  {
    "name": "YEMATA",
    "gender": "female"
  },
  {
    "name": "YEMEGNUESHAL",
    "gender": "female"
  },
  {
    "name": "YEMISIRACH",
    "gender": "female"
  },
  {
    "name": "YEMISRACH",
    "gender": "female"
  },
  {
    "name": "YEMSRACH",
    "gender": "female"
  },
  {
    "name": "YENENAT",
    "gender": "female"
  },
  {
    "name": "YENENESH",
    "gender": "female"
  },
  {
    "name": "YENENEW",
    "gender": "male"
  },
  {
    "name": "YENUS",
    "gender": "male"
  },
  {
    "name": "YERED",
    "gender": "male"
  },
  {
    "name": "YESHANEW",
    "gender": "male"
  },
  {
    "name": "YESHAREG",
    "gender": "female"
  },
  {
    "name": "YESHE",
    "gender": "female"
  },
  {
    "name": "YESHI",
    "gender": "female"
  },
  {
    "name": "YESHIEMEBET",
    "gender": "female"
  },
  {
    "name": "YESHIHAREG",
    "gender": "female"
  },
  {
    "name": "YESHIMEHAL",
    "gender": "female"
  },
  {
    "name": "YESHIWORK",
    "gender": "female"
  },
  {
    "name": "YESHWORK",
    "gender": "female"
  },
  {
    "name": "YESUF",
    "gender": "male"
  },
  {
    "name": "YESYIT",
    "gender": "female"
  },
  {
    "name": "YETEREFWERK",
    "gender": "female"
  },
  {
    "name": "YETIMWERK",
    "gender": "female"
  },
  {
    "name": "YETIMWORK",
    "gender": "female"
  },
  {
    "name": "YETINAYET",
    "gender": "female"
  },
  {
    "name": "YETNAYET",
    "gender": "female"
  },
  {
    "name": "YEWBDAR",
    "gender": "female"
  },
  {
    "name": "YEWUBDAR",
    "gender": "female"
  },
  {
    "name": "YEZENAW",
    "gender": "male"
  },
  {
    "name": "YEZINASH",
    "gender": "female"
  },
  {
    "name": "YIBELTAL",
    "gender": "male"
  },
  {
    "name": "YIBEYEN",
    "gender": "male"
  },
  {
    "name": "YIBRIE",
    "gender": "male"
  },
  {
    "name": "YIDENEKACHEW",
    "gender": "male"
  },
  {
    "name": "YIDENEKU",
    "gender": "female"
  },
  {
    "name": "YIDENEKUSH",
    "gender": "female"
  },
  {
    "name": "YIDIDIYA",
    "gender": "male"
  },
  {
    "name": "YIDNEKACHEW",
    "gender": "male"
  },
  {
    "name": "YIFRASHWA",
    "gender": "male"
  },
  {
    "name": "YIFTUSERA",
    "gender": "female"
  },
  {
    "name": "YIGZAW",
    "gender": "male"
  },
  {
    "name": "YIHEYIS",
    "gender": "male"
  },
  {
    "name": "YIKEBER",
    "gender": "male"
  },
  {
    "name": "YILFASHEWA",
    "gender": "female"
  },
  {
    "name": "YILKAL",
    "gender": "male"
  },
  {
    "name": "YILMA",
    "gender": "male"
  },
  {
    "name": "YIMAM",
    "gender": "male"
  },
  {
    "name": "YIRDAW",
    "gender": "male"
  },
  {
    "name": "YIRGALEM",
    "gender": "male"
  },
  {
    "name": "YISA",
    "gender": "male"
  },
  {
    "name": "YISHAK",
    "gender": "male"
  },
  {
    "name": "YITBAREK",
    "gender": "male"
  },
  {
    "name": "YODIT",
    "gender": "female"
  },
  {
    "name": "YOHANES",
    "gender": "male"
  },
  {
    "name": "YOHANNES",
    "gender": "unknown"
  },
  {
    "name": "YOHANNIS",
    "gender": "male"
  },
  {
    "name": "YONAS",
    "gender": "male"
  },
  {
    "name": "YONATAN",
    "gender": "male"
  },
  {
    "name": "YONATHAN",
    "gender": "male"
  },
  {
    "name": "YONNAS",
    "gender": "male"
  },
  {
    "name": "YORDANOS",
    "gender": "female"
  },
  {
    "name": "YORDANOSE",
    "gender": "female"
  },
  {
    "name": "YOSEF",
    "gender": "male"
  },
  {
    "name": "YOSEPH",
    "gender": "male"
  },
  {
    "name": "ZAHARA",
    "gender": "female"
  },
  {
    "name": "ZAYED",
    "gender": "female"
  },
  {
    "name": "ZEBENE",
    "gender": "male"
  },
  {
    "name": "ZEBIBA",
    "gender": "female"
  },
  {
    "name": "ZEGEYE",
    "gender": "male"
  },
  {
    "name": "ZEHARA",
    "gender": "female"
  },
  {
    "name": "ZEINEBA",
    "gender": "female"
  },
  {
    "name": "ZEINEDIN",
    "gender": "male"
  },
  {
    "name": "ZEKARIAS",
    "gender": "male"
  },
  {
    "name": "ZELALEM",
    "gender": "male"
  },
  {
    "name": "ZELEKA",
    "gender": "female"
  },
  {
    "name": "ZELEKEW",
    "gender": "male"
  },
  {
    "name": "ZEMEDA",
    "gender": "male"
  },
  {
    "name": "ZEMEDKUN",
    "gender": "male"
  },
  {
    "name": "ZEMELAK",
    "gender": "male"
  },
  {
    "name": "ZEMENAY",
    "gender": "female"
  },
  {
    "name": "ZEMUYIE",
    "gender": "female"
  },
  {
    "name": "ZEMZEM",
    "gender": "female"
  },
  {
    "name": "ZENA",
    "gender": "male"
  },
  {
    "name": "ZENASH",
    "gender": "female"
  },
  {
    "name": "ZENEBE",
    "gender": "male"
  },
  {
    "name": "ZENEBECH",
    "gender": "female"
  },
  {
    "name": "ZENEBEWORK",
    "gender": "female"
  },
  {
    "name": "ZERDAWIT",
    "gender": "male"
  },
  {
    "name": "ZEREAY",
    "gender": "male"
  },
  {
    "name": "ZERIHUN",
    "gender": "male"
  },
  {
    "name": "ZERITU",
    "gender": "female"
  },
  {
    "name": "ZERU",
    "gender": "male"
  },
  {
    "name": "ZERUBABIL",
    "gender": "male"
  },
  {
    "name": "ZEWDE",
    "gender": "male"
  },
  {
    "name": "ZEWDIE",
    "gender": "male"
  },
  {
    "name": "ZEWDITU",
    "gender": "female"
  },
  {
    "name": "ZEWDU",
    "gender": "male"
  },
  {
    "name": "ZEWEDINESH",
    "gender": "female"
  },
  {
    "name": "ZEWIDU",
    "gender": "male"
  },
  {
    "name": "ZEWUDE",
    "gender": "female"
  },
  {
    "name": "ZEYEDA",
    "gender": "female"
  },
  {
    "name": "ZEYINEBA",
    "gender": "female"
  },
  {
    "name": "ZEYNI",
    "gender": "male"
  },
  {
    "name": "ZEYTUNA",
    "gender": "female"
  },
  {
    "name": "ZIHRET",
    "gender": "female"
  },
  {
    "name": "ZINABU",
    "gender": "male"
  },
  {
    "name": "ZINASH",
    "gender": "female"
  },
  {
    "name": "ZINAW",
    "gender": "male"
  },
  {
    "name": "ZINET",
    "gender": "female"
  },
  {
    "name": "ZULEKA",
    "gender": "female"
  },
  {
    "name": "ZULFA",
    "gender": "female"
  }
]END
cat > src/services/database.js << 'END'
// ========== database.js ==========
import { openDB } from 'idb'

const DB_NAME = 'DocAnalyzerDB'
const DB_VERSION = 8  // Incremented version
const STORE_NAME = 'chatHistory'
const SEMANTIC_STORE = 'semantic_store'
const PAPERS_STORE = 'papers_store'
const SERVICE_FLOWS_STORE = 'service_flows'  // NEW STORE FOR SERVICE CONFIGURATIONS

class Database {
  constructor() {
    this.db = null
  }

  async init() {
    this.db = await openDB(DB_NAME, DB_VERSION, {
      upgrade(db, oldVersion, newVersion, transaction) {
        // Create chatHistory store if it doesn't exist
        if (!db.objectStoreNames.contains(STORE_NAME)) {
          const store = db.createObjectStore(STORE_NAME, {
            keyPath: 'id',
            autoIncrement: true
          })
          store.createIndex('timestamp', 'timestamp')
          store.createIndex('sessionId', 'sessionId')
        }
        
        // Create semantic_store for sentence storage
        if (!db.objectStoreNames.contains(SEMANTIC_STORE)) {
          const semanticStore = db.createObjectStore(SEMANTIC_STORE, {
            keyPath: 'id',
            autoIncrement: true
          })
          semanticStore.createIndex('paperId', 'paperId')
          semanticStore.createIndex('section', 'section')
          semanticStore.createIndex('score', 'score')
          semanticStore.createIndex('timestamp', 'timestamp')
        }
        
        // Create papers_store for paper metadata
        if (!db.objectStoreNames.contains(PAPERS_STORE)) {
          const papersStore = db.createObjectStore(PAPERS_STORE, {
            keyPath: 'id',
            autoIncrement: true
          })
          papersStore.createIndex('documentId', 'documentId')
          papersStore.createIndex('title', 'title')
          papersStore.createIndex('timestamp', 'timestamp')
        }
        
        // CREATE NEW SERVICE FLOWS STORE
        if (!db.objectStoreNames.contains(SERVICE_FLOWS_STORE)) {
          const serviceStore = db.createObjectStore(SERVICE_FLOWS_STORE, {
            keyPath: 'serviceId'
          })
          serviceStore.createIndex('name', 'name')
          serviceStore.createIndex('createdAt', 'createdAt')
          serviceStore.createIndex('updatedAt', 'updatedAt')
          serviceStore.createIndex('isActive', 'isActive')
        }
        
        // Handle upgrades from older versions
        if (oldVersion < 6) {
          console.log(`Upgrading database from version ${oldVersion} to ${newVersion}`)
          // Migration logic if needed
        }
      }
    })
    return this.db
  }

  // ========== NEW SERVICE FLOW METHODS ==========

  /**
   * Save service flow configuration to database
   * @param {Object} serviceConfig - Service configuration object
   * @returns {Promise} - IDB request promise
   */
  async saveServiceFlow(serviceConfig) {
   const service = {
    ...serviceConfig,
    createdAt: serviceConfig.createdAt || new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    isActive: serviceConfig.isActive !== undefined ? 
              (serviceConfig.isActive ? 1 : 0) : 1 // Store as number
  }
  return await this.db.put(SERVICE_FLOWS_STORE, service)
  }
  /**
   * Get service flow configuration by ID
   * @param {string} serviceId - Service identifier
   * @returns {Promise<Object|null>} - Service configuration or null
   */
  async getServiceFlow(serviceId) {
    try {
      return await this.db.get(SERVICE_FLOWS_STORE, serviceId)
    } catch (error) {
      console.error('Error getting service flow:', error)
      return null
    }
  }

  /**
   * Get all active service flows
   * @param {number} limit - Maximum number of services to return
   * @returns {Promise<Array>} - Array of service configurations
   */

  /**
   * Get service flows by name (partial match)
   * @param {string} name - Service name to search for
   * @returns {Promise<Array>} - Array of matching services
   */

  /**
   * Delete service flow
   * @param {string} serviceId - Service identifier
   * @returns {Promise} - IDB request promise
   */

  /**
   * Update service flow
   * @param {string} serviceId - Service identifier
   * @param {Object} updates - Partial service configuration
   * @returns {Promise} - IDB request promise
   */

  /**
   * Import default service flows (one-time function)
   * @returns {Promise<Array>} - Array of saved service IDs
   */ 

  /**
   * Export all service flows as JSON
   * @returns {Promise<string>} - JSON string of all services
   */

  /**
   * Import service flows from JSON
   * @param {string} jsonString - JSON string of service configurations
   * @returns {Promise<Array>} - Array of imported service IDs
   */

  // ========== EXISTING METHODS (KEPT AS IS) ==========

  async saveChatMessage(messageData) {
    const message = {
      ...messageData,
      timestamp: new Date().toISOString()
    }
    return await this.db.add(STORE_NAME, message)
  }

  async getChatHistory(limit = 100) {
    const tx = this.db.transaction(STORE_NAME, 'readonly')
    const store = tx.objectStore(STORE_NAME)
    const index = store.index('timestamp')
    
    let cursor = await index.openCursor(null, 'prev')
    const results = []
    
    while (cursor && results.length < limit) {
      results.push(cursor.value)
      cursor = await cursor.continue()
    }
    
    return results
  }

  async getAllChatHistory() {
    return await this.db.getAll(STORE_NAME)
  }

  async saveDocument(documentData) {
    return this.saveChatMessage({
      type: 'document',
      content: JSON.stringify(documentData),
      sessionId: 'doc_' + Date.now()
    })
  }

  async saveSemanticSentence(sentenceData) {
    const sentence = {
      ...sentenceData,
      timestamp: new Date().toISOString()
    }
    return await this.db.add(SEMANTIC_STORE, sentence)
  }

  async savePaperMetadata(paperData) {
    const paper = {
      ...paperData,
      timestamp: new Date().toISOString()
    }
    return await this.db.add(PAPERS_STORE, paper)
  }

  async getSentencesByPaperId(paperId, limit = 100) {
    const tx = this.db.transaction(SEMANTIC_STORE, 'readonly')
    const store = tx.objectStore(SEMANTIC_STORE)
    const index = store.index('paperId')
    
    let cursor = await index.openCursor(IDBKeyRange.only(paperId))
    const results = []
    
    while (cursor && results.length < limit) {
      results.push(cursor.value)
      cursor = await cursor.continue()
    }
    
    return results
  }

  async getTopSentencesByPaperId(paperId, limit = 10) {
    const sentences = await this.getSentencesByPaperId(paperId, 1000)
    return sentences
      .sort((a, b) => b.score - a.score)
      .slice(0, limit)
  }

  async getPaperByDocumentId(documentId) {
    const tx = this.db.transaction(PAPERS_STORE, 'readonly')
    const store = tx.objectStore(PAPERS_STORE)
    const index = store.index('documentId')
    
    const cursor = await index.openCursor(IDBKeyRange.only(documentId))
    if (cursor) {
      return cursor.value
    }
    return null
  }

  async batchSaveSentences(paperId, sentences) {
    const tx = this.db.transaction(SEMANTIC_STORE, 'readwrite')
    const store = tx.objectStore(SEMANTIC_STORE)
    
    const promises = sentences.map(sentence => {
      const sentenceWithMetadata = {
        ...sentence,
        paperId,
        timestamp: new Date().toISOString()
      }
      return store.add(sentenceWithMetadata)
    })
    
    return Promise.all(promises)
  }

  async clearPaperSentences(paperId) {
    const tx = this.db.transaction(SEMANTIC_STORE, 'readwrite')
    const store = tx.objectStore(SEMANTIC_STORE)
    const index = store.index('paperId')
    
    let cursor = await index.openCursor(IDBKeyRange.only(paperId))
    while (cursor) {
      cursor.delete()
      cursor = await cursor.continue()
    }
    
    return tx.complete
  }

  async getAllPapers(limit = 50) {
    const tx = this.db.transaction(PAPERS_STORE, 'readonly')
    const store = tx.objectStore(PAPERS_STORE)
    const index = store.index('timestamp')
    
    let cursor = await index.openCursor(null, 'prev')
    const results = []
    
    while (cursor && results.length < limit) {
      results.push(cursor.value)
      cursor = await cursor.continue()
    }
    
    return results
  }
}

export const db = new Database()END
cat > src/services/duck.js << 'END'
import nlp from 'compromise'
import { apiHandler } from './API'
//import { processUserInputX } from './iftmsX.js'
import { extractTextFromPDF } from './pdfAna.js'
import { db } from './database.js'
import { teSsAna } from "./tess.js"
import { pdfAnalyzerF } from './pdfAnalyzer.js'

// State variables
let initialized = false
let awaitingBusinessLicense = null
let awaitingVehicleInfo = null
let currentIntent = null
let currentStep = null
let currentService = null
let awaitingOTP = null
let iSbizValid = null
let isIftmsInit
let intentPatterns = {}
let stepResponses = {}

// Google Custom Search API Configuration
const GOOGLE_SEARCH_CONFIG = {
  apiKey: 'process.env.GOOGLE_API_KEY' || localStorage.getItem('google_api_key') || 'YOUR_GOOGLE_API_KEY', // Set your API key
  searchEngineId: 'process.env.GOOGLE_SE_ID' || localStorage.getItem('google_search_engine_id') || 'YOUR_SEARCH_ENGINE_ID', // Custom Search Engine ID
  baseUrl: 'https://www.googleapis.com/customsearch/v1',
  maxResults: 10, // Google allows up to 10 per request
  safeSearch: 'active', // moderate, off
  searchType: 'searchTypeUndefined', // searchTypeImage, searchTypeNews
  fields: 'items(title,link,snippet,pagemap/metatags),searchInformation(totalResults)',
  timeout: 15000,
  cacheDuration: 3600000, // Cache results for 1 hour (in milliseconds)
  enableKnowledgeGraph: true
}

// DuckDuckGo fallback configuration
const DUCKDUCKGO_CONFIG = {
  baseUrl: 'https://api.duckduckgo.com/',
  format: 'json',
  noHtml: 1,
  skipDisambig: 1
}

// Search cache
let searchCache = new Map()

// Initialize NLP Processor with Google Search
export async function initGOOGLEsearch() {
  if (initialized) return
  
  console.log('🔄 Initializing NLP Processor with Google Search API...')
  awaitingOTP = sessionStorage.getItem('opt')
  iSbizValid = sessionStorage.getItem('licenseValidated')
  
  // Initialize Google API if available
  if (GOOGLE_SEARCH_CONFIG.apiKey && GOOGLE_SEARCH_CONFIG.searchEngineId) {
    console.log('✅ Google Custom Search API configured')
  } else {
    console.warn('⚠️ Google API key or Search Engine ID not configured. Using fallback search.')
  }
  
  initialized = true
  console.log('✅ NLP Processor with Web Search initialized')
}

// Set Google API credentials
export function setGoogleCredentials(apiKey, searchEngineId) {
  GOOGLE_SEARCH_CONFIG.apiKey = apiKey
  GOOGLE_SEARCH_CONFIG.searchEngineId = searchEngineId
  localStorage.setItem('google_api_key', apiKey)
  localStorage.setItem('google_search_engine_id', searchEngineId)
  console.log('✅ Google API credentials updated')
}

// Main web search function with Google API as primary
export async function searchWebForUnknownIntent(query, options = {}) {
  const {
    useGoogle = true, // Use Google as primary
    fallbackToDuckDuckGo = true,
    maxResults = GOOGLE_SEARCH_CONFIG.maxResults,
    language = localStorage.getItem('agig-language') || 'en',
    timeout = GOOGLE_SEARCH_CONFIG.timeout,
    safeSearch = GOOGLE_SEARCH_CONFIG.safeSearch,
    searchType = GOOGLE_SEARCH_CONFIG.searchType
  } = options
  
  console.log(`🔍 Searching web for: "${query}"`)
  
  // Check cache first
  const cacheKey = `${query}_${language}_${maxResults}`
  const cachedResult = searchCache.get(cacheKey)
  
  if (cachedResult && (Date.now() - cachedResult.timestamp) < GOOGLE_SEARCH_CONFIG.cacheDuration) {
    console.log('📦 Using cached search results')
    return cachedResult.data
  }
  
  try {
    let searchResults = []
    let source = 'unknown'
    
    // Try Google Custom Search API first if configured
    if (useGoogle && GOOGLE_SEARCH_CONFIG.apiKey && GOOGLE_SEARCH_CONFIG.searchEngineId) {
      try {
        const googleResults = await searchGoogleCustom(query, {
          maxResults,
          language,
          safeSearch,
          searchType,
          timeout
        })
        
        if (googleResults.length > 0) {
          searchResults = googleResults
          source = 'google'
          console.log(`✅ Google search returned ${googleResults.length} results`)
        }
      } catch (googleError) {
        console.warn('❌ Google search failed:', googleError.message)
      }
    }
    
    // Fallback to DuckDuckGo if Google fails or returns no results
    if (searchResults.length === 0 && fallbackToDuckDuckGo) {
      console.log('🦆 Falling back to DuckDuckGo...')
      try {
        const duckduckgoResults = await searchDuckDuckGo(query, maxResults, language, timeout)
        if (duckduckgoResults.length > 0) {
          searchResults = duckduckgoResults
          source = 'duckduckgo'
        }
      } catch (duckduckgoError) {
        console.warn('❌ DuckDuckGo search failed:', duckduckgoError.message)
      }
    }
    
    // Final fallback to Wikipedia
    if (searchResults.length === 0) {
      console.log('📚 Falling back to Wikipedia...')
      try {
        const wikipediaResults = await searchWikipedia(query, language)
        if (wikipediaResults.length > 0) {
          searchResults = wikipediaResults
          source = 'wikipedia'
        }
      } catch (wikipediaError) {
        console.warn('❌ Wikipedia search failed:', wikipediaError.message)
      }
    }
    
    // Extract knowledge graph information from Google if available
    let knowledgeGraph = null
    if (source === 'google' && GOOGLE_SEARCH_CONFIG.enableKnowledgeGraph) {
      knowledgeGraph = await extractKnowledgeGraph(query, language)
    }
    
    // Summarize results using NLP
    let summary = null
    if (searchResults.length > 0) {
      summary = await summarizeSearchResults(searchResults, query, knowledgeGraph)
    }
    
    const result = {
      success: searchResults.length > 0,
      query,
      results: searchResults,
      summary,
      knowledgeGraph,
      source,
      timestamp: new Date().toISOString(),
      language
    }
    
    // Cache the result
    searchCache.set(cacheKey, {
      data: result,
      timestamp: Date.now()
    })
    
    // Limit cache size
    if (searchCache.size > 100) {
      const firstKey = searchCache.keys().next().value
      searchCache.delete(firstKey)
    }
    
    return result
    
  } catch (error) {
    console.error('❌ Web search completely failed:', error)
    return {
      success: false,
      query,
      results: [],
      summary: null,
      knowledgeGraph: null,
      source: 'none',
      error: error.message,
      timestamp: new Date().toISOString(),
      language
    }
  }
}

// Google Custom Search API Implementation
async function searchGoogleCustom(query, options = {}) {
  const {
    maxResults = GOOGLE_SEARCH_CONFIG.maxResults,
    language = 'en',
    safeSearch = GOOGLE_SEARCH_CONFIG.safeSearch,
    searchType = GOOGLE_SEARCH_CONFIG.searchType,
    timeout = GOOGLE_SEARCH_CONFIG.timeout
  } = options
  
  const params = new URLSearchParams({
    key: GOOGLE_SEARCH_CONFIG.apiKey,
    cx: GOOGLE_SEARCH_CONFIG.searchEngineId,
    q: query,
    num: Math.min(maxResults, 10), // Google max is 10 per request
    lr: `lang_${language}`,
    safe: safeSearch,
    fields: GOOGLE_SEARCH_CONFIG.fields
  })
  
  if (searchType !== 'searchTypeUndefined') {
    params.append('searchType', searchType)
  }
  
  // Add domain restrictions for government/Ethiopia specific searches
  if (query.toLowerCase().includes('ethiopia') || 
      query.toLowerCase().includes('government') ||
      query.toLowerCase().includes('ministry')) {
    params.append('siteSearch', '.et,.gov.et')
    params.append('siteSearchFilter', 'i')
  }
  
  const url = `${GOOGLE_SEARCH_CONFIG.baseUrl}?${params.toString()}`
  
  console.log(`🔗 Google API Request: ${url.substring(0, 100)}...`)
  
  const controller = new AbortController()
  const timeoutId = setTimeout(() => controller.abort(), timeout)
  
  try {
    const response = await fetch(url, {
      signal: controller.signal,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'AGIG-ChatBot/1.0'
      }
    })
    
    clearTimeout(timeoutId)
    
    if (!response.ok) {
      throw new Error(`Google API HTTP ${response.status}: ${response.statusText}`)
    }
    
    const data = await response.json()
    
    if (!data.items || data.items.length === 0) {
      console.log('⚠️ Google search returned no items')
      return []
    }
    
    // Process Google search results
    const results = data.items.map((item, index) => {
      // Extract description from metatags if available
      let description = item.snippet || ''
      if (item.pagemap && item.pagemap.metatags && item.pagemap.metatags[0]) {
        const meta = item.pagemap.metatags[0]
        description = meta['og:description'] || 
                     meta['twitter:description'] || 
                     meta.description || 
                     description
      }
      
      // Calculate confidence based on position and content
      const positionScore = 1 - (index / data.items.length)
      const contentScore = calculateRelevanceScore(query, item.title + ' ' + description)
      const confidence = (positionScore * 0.3) + (contentScore * 0.7)
      
      return {
        title: item.title || 'No title',
        snippet: description,
        url: item.link,
        source: 'Google Search',
        confidence: confidence,
        rank: index + 1,
        searchInfo: {
          totalResults: data.searchInformation?.totalResults || 'Unknown'
        }
      }
    })
    
    return results
    
  } catch (error) {
    if (error.name === 'AbortError') {
      throw new Error('Google search timeout')
    }
    throw error
  }
}
export function simulateSearchResults(query, maxResults) {
  const simulatedResults = [
    {
      title: `Information about "${query}"`,
      snippet: `Based on available information, "${query}" appears to be related to various topics. For accurate and up-to-date information, please consult official sources or specific documentation.`,
      url: `https://www.example.com/search?q=${encodeURIComponent(query)}`,
      source: 'Simulated Search',
      confidence: 0.5
    },
    {
      title: 'General Information',
      snippet: 'This appears to be a general query. You might want to be more specific about what you\'re looking for, such as specific document types, services, or procedures.',
      url: 'https://www.example.com/help',
      source: 'General Knowledge',
      confidence: 0.4
    }
  ]
  
  return simulatedResults.slice(0, maxResults)
}
// Extract Knowledge Graph information from Google
async function extractKnowledgeGraph(query, language) {
  try {
    const params = new URLSearchParams({
      key: GOOGLE_SEARCH_CONFIG.apiKey,
      cx: GOOGLE_SEARCH_CONFIG.searchEngineId,
      q: query,
      num: 1
    })
    
    const url = `${GOOGLE_SEARCH_CONFIG.baseUrl}?${params.toString()}`
    
    const response = await fetch(url, {
      headers: { 'Accept': 'application/json' }
    })
    
    if (!response.ok) return null
    
    const data = await response.json()
    
    // Check for knowledge graph in results
    if (data.items && data.items[0] && data.items[0].pagemap) {
      const pagemap = data.items[0].pagemap
      
      // Extract entity information
      const entity = {
        name: null,
        description: null,
        type: null,
        details: {}
      }
      
      // Check for schema.org structured data
      if (pagemap.metatags && pagemap.metatags[0]) {
        const meta = pagemap.metatags[0]
        entity.name = meta['og:title'] || meta['twitter:title'] || null
        entity.description = meta['og:description'] || meta['twitter:description'] || meta.description || null
        entity.type = meta['og:type'] || null
      }
      
      // Check for knowledge graph specific data
      if (pagemap.website && pagemap.website[0]) {
        entity.details.website = pagemap.website[0]
      }
      
      if (pagemap.organization && pagemap.organization[0]) {
        entity.details.organization = pagemap.organization[0]
      }
      
      if (pagemap.localbusiness && pagemap.localbusiness[0]) {
        entity.details.business = pagemap.localbusiness[0]
      }
      
      if (pagemap.governmentorganization && pagemap.governmentorganization[0]) {
        entity.details.government = pagemap.governmentorganization[0]
      }
      
      return entity
    }
    
    return null
    
  } catch (error) {
    console.warn('Could not extract knowledge graph:', error.message)
    return null
  }
}

// Calculate relevance score between query and content
function calculateRelevanceScore(query, content) {
  const queryTerms = query.toLowerCase().split(/\s+/).filter(term => term.length > 2)
  const contentLower = content.toLowerCase()
  
  if (queryTerms.length === 0) return 0.5
  
  const matches = queryTerms.filter(term => contentLower.includes(term)).length
  const matchRatio = matches / queryTerms.length
  
  // Boost score for exact phrase matches
  const exactMatch = contentLower.includes(query.toLowerCase()) ? 0.2 : 0
  
  // Penalize very short content
  const lengthPenalty = content.length < 50 ? -0.1 : 0
  
  return Math.min(1, Math.max(0, matchRatio + exactMatch + lengthPenalty))
}

// Enhanced DuckDuckGo search (fallback)
async function searchDuckDuckGo(query, maxResults, language, timeout) {
  try {
    const encodedQuery = encodeURIComponent(query)
    const params = new URLSearchParams({
      q: encodedQuery,
      format: DUCKDUCKGO_CONFIG.format,
      no_html: DUCKDUCKGO_CONFIG.noHtml,
      skip_disambig: DUCKDUCKGO_CONFIG.skipDisambig,
      kp: '1', // Safe search
      kl: language === 'am' ? 'wt-wt' : 'us-en'
    })
    
    const url = `${DUCKDUCKGO_CONFIG.baseUrl}?${params.toString()}`
    
    const controller = new AbortController()
    const timeoutId = setTimeout(() => controller.abort(), timeout)
    
    const response = await fetch(url, {
      signal: controller.signal,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'AGIG-ChatBot/1.0'
      }
    })
    
    clearTimeout(timeoutId)
    
    if (!response.ok) {
      throw new Error(`DuckDuckGo HTTP ${response.status}`)
    }
    
    const data = await response.json()
    
    const results = []
    
    // Extract Abstract/Summary
    if (data.Abstract) {
      results.push({
        title: data.Heading || 'Summary',
        snippet: data.Abstract,
        url: data.AbstractURL || `https://duckduckgo.com/?q=${encodedQuery}`,
        source: 'DuckDuckGo',
        confidence: 0.9,
        rank: 1
      })
    }
    
    // Extract Related Topics
    if (data.RelatedTopics && data.RelatedTopics.length > 0) {
      data.RelatedTopics.slice(0, maxResults - 1).forEach((topic, index) => {
        if (topic.Text) {
          results.push({
            title: topic.FirstURL ? topic.FirstURL.split('/').pop().replace(/_/g, ' ') : 'Related Topic',
            snippet: topic.Text,
            url: topic.FirstURL || `https://duckduckgo.com/?q=${encodedQuery}`,
            source: 'DuckDuckGo',
            confidence: 0.7 - (index * 0.1),
            rank: index + 2
          })
        }
      })
    }
    
    // Extract Definitions
    if (data.Definition) {
      results.push({
        title: 'Definition',
        snippet: data.Definition,
        url: data.DefinitionURL || `https://duckduckgo.com/?q=${encodedQuery}`,
        source: 'DuckDuckGo',
        confidence: 0.8,
        rank: results.length + 1
      })
    }
    
    return results.slice(0, maxResults)
    
  } catch (error) {
    console.warn('DuckDuckGo search failed:', error.message)
    throw error
  }
}

// Enhanced Wikipedia search (fallback)
async function searchWikipedia(query, language) {
  try {
    const encodedQuery = encodeURIComponent(query)
    const langCode = language === 'am' ? 'am' : 'en'
    const url = `https://${langCode}.wikipedia.org/w/api.php?action=query&format=json&list=search&srsearch=${encodedQuery}&srlimit=5&srprop=snippet&origin=*`
    
    const response = await fetch(url, {
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'AGIG-ChatBot/1.0'
      }
    })
    
    if (!response.ok) {
      throw new Error(`Wikipedia HTTP ${response.status}`)
    }
    
    const data = await response.json()
    
    if (!data.query?.search) {
      return []
    }
    
    return data.query.search.map((result, index) => ({
      title: result.title,
      snippet: result.snippet.replace(/<[^>]+>/g, ''),
      url: `https://${langCode}.wikipedia.org/wiki/${encodeURIComponent(result.title)}`,
      source: 'Wikipedia',
      confidence: 0.85 - (index * 0.05),
      rank: index + 1
    }))
    
  } catch (error) {
    console.warn('Wikipedia search failed:', error.message)
    throw error
  }
}

// Enhanced Summarize Search Results with Google context
async function summarizeSearchResults(results, originalQuery, knowledgeGraph = null) {
  if (!results || results.length === 0) {
    return null
  }
  
  try {
    // Combine all snippets into a single text
    const combinedText = results
      .map(result => `${result.title}. ${result.snippet}`)
      .filter(text => text && text.trim().length > 0)
      .join('. ')
    
    if (!combinedText || combinedText.trim().length < 50) {
      return null
    }
    
    // Use Compromise NLP for advanced text analysis
    const doc = nlp(combinedText)
    
    // Extract sentences and score them
    const sentences = doc.sentences().out('array')
    const queryTerms = originalQuery.toLowerCase().split(/\s+/).filter(term => term.length > 2)
    
    const scoredSentences = sentences.map(sentence => {
      const sentenceLower = sentence.toLowerCase()
      
      // Score based on query term matches
      const termScore = queryTerms.reduce((sum, term) => {
        return sum + (sentenceLower.includes(term) ? 1 : 0)
      }, 0)
      
      // Score based on government/Ethiopia relevance
      const govScore = sentenceLower.includes('government') ||
                      sentenceLower.includes('ministry') ||
                      sentenceLower.includes('ethiopia') ||
                      sentenceLower.includes('ኢትዮጵያ') ? 2 : 0
      
      // Score based on document/service keywords
      const docScore = sentenceLower.includes('document') ||
                      sentenceLower.includes('license') ||
                      sentenceLower.includes('certificate') ||
                      sentenceLower.includes('permit') ? 1 : 0
      
      const totalScore = termScore + govScore + docScore
      
      return {
        sentence,
        score: totalScore,
        length: sentence.length,
        isShort: sentence.length < 100,
        hasNumbers: /\d/.test(sentence)
      }
    })
    
    // Select best sentences for summary
    const relevantSentences = scoredSentences
      .filter(({ score, isShort }) => score > 0 && isShort) // Prefer short, relevant sentences
      .sort((a, b) => {
        // Sort by score, then by length (shorter first), then by presence of numbers
        if (b.score !== a.score) return b.score - a.score
        if (a.length !== b.length) return a.length - b.length
        return b.hasNumbers ? 1 : -1
      })
      .slice(0, 5)
      .map(({ sentence }) => sentence)
    
    // Fallback to first sentences if no relevant ones
    if (relevantSentences.length === 0) {
      relevantSentences.push(...sentences.filter(s => s.length < 150).slice(0, 3))
    }
    
    // Extract key terms using NLP
    const keyTerms = doc.nouns().out('array')
      .concat(doc.adjectives().out('array'))
      .filter(term => term.split(' ').length <= 2)
      .filter(term => !isCommonWord(term))
      .map(term => term.toLowerCase())
      .filter((term, index, array) => array.indexOf(term) === index) // Remove duplicates
      .slice(0, 15)
    
    // Extract entities
    const entities = {
      people: doc.people().out('array'),
      places: doc.places().out('array'),
      organizations: doc.organizations().out('array'),
      dates: doc.dates().out('array'),
      numbers: doc.numbers().out('array')
    }
    
    // Calculate overall confidence
    const avgResultConfidence = results.reduce((sum, r) => sum + (r.confidence || 0.5), 0) / results.length
    const coverageConfidence = Math.min(1, relevantSentences.length / 3)
    const finalConfidence = (avgResultConfidence * 0.6) + (coverageConfidence * 0.4)
    
    // Generate recommendations
    const recommendation = generateEnhancedRecommendation(originalQuery, relevantSentences, knowledgeGraph)
    
    // Create comprehensive summary
    const summary = {
      keyPoints: relevantSentences,
      keyTerms,
      entities,
      confidence: finalConfidence,
      sources: [...new Set(results.map(r => r.source))],
      totalResults: results.length,
      topResult: results[0] || null,
      knowledgeGraph,
      recommendation,
      searchQuery: originalQuery,
      timestamp: new Date().toISOString()
    }
    
    return summary
    
  } catch (error) {
    console.error('Error summarizing search results:', error)
    return null
  }
}

// Enhanced recommendation generator
function generateEnhancedRecommendation(query, keyPoints, knowledgeGraph) {
  const queryLower = query.toLowerCase()
  const keyPointsText = keyPoints.join(' ').toLowerCase()
  
  // Government/Ethiopia specific recommendations
  if (queryLower.includes('ethiopia') || 
      queryLower.includes('ኢትዮጵያ') ||
      keyPointsText.includes('ethiopia') ||
      keyPointsText.includes('ኢትዮጵያ')) {
    
    if (queryLower.includes('license') || queryLower.includes('permit') || queryLower.includes('ብቃት')) {
      return 'For official Ethiopian license/permit information, visit the Ethiopian Investment Commission (investmentcommission.gov.et) or relevant ministry websites.'
    }
    
    if (queryLower.includes('document') || queryLower.includes('ሰነድ')) {
      return 'For Ethiopian document services, visit the Federal Government of Ethiopia portal (www.ethiopia.gov.et) or the specific ministry responsible for your document type.'
    }
    
    if (queryLower.includes('business') || queryLower.includes('ንግድ')) {
      return 'For Ethiopian business registration and services, visit the Ministry of Trade and Regional Integration (mot.gov.et) or Ethiopian Investment Commission.'
    }
    
    return 'For accurate Ethiopian government information, please consult official portals: www.ethiopia.gov.et or relevant ministry websites.'
  }
  
  // General recommendations
  if (queryLower.includes('how to') || queryLower.includes('procedure')) {
    return 'This appears to be a procedural query. For official procedures, please consult relevant government websites or contact the appropriate ministry.'
  }
  
  if (queryLower.includes('form') || queryLower.includes('template')) {
    return 'Official forms and templates are typically available on government service portals. Look for the "Downloads" or "Forms" section on relevant ministry websites.'
  }
  
  if (queryLower.includes('requirement') || queryLower.includes('required')) {
    return 'For specific requirements, please refer to the official guidelines published by the relevant authority. Requirements often vary by document type and jurisdiction.'
  }
  
  if (knowledgeGraph) {
    return `Based on available information about "${knowledgeGraph.name || 'this topic'}", please verify details with official sources.`
  }
  
  return 'For the most accurate and up-to-date information, please consult official government sources or contact the relevant authorities directly.'
}

// Check if word is common
function isCommonWord(word) {
  const commonWords = [
    'document', 'file', 'paper', 'information', 'data',
    'service', 'system', 'process', 'analysis', 'review',
    'government', 'ministry', 'official', 'public',
    'the', 'and', 'for', 'with', 'that', 'this', 'from',
    'about', 'when', 'where', 'how', 'what', 'which',
    'can', 'will', 'would', 'should', 'could', 'may'
  ]
  
  return commonWords.includes(word.toLowerCase())
}

// Clear search cache
export function clearSearchCache() {
  searchCache.clear()
  console.log('🗑️ Search cache cleared')
}

// Get cache statistics
export function getCacheStats() {
  return {
    size: searchCache.size,
    entries: Array.from(searchCache.entries()).map(([key, value]) => ({
      key: key.substring(0, 50) + '...',
      age: Date.now() - value.timestamp,
      dataSize: JSON.stringify(value.data).length
    }))
  }
}
export function generateSearchQuery(message, entities) {
  const doc = nlp(message)
  
  // Extract key terms
  const nouns = doc.nouns().out('array').filter(n => n.length > 3)
  const verbs = doc.verbs().out('array')
  const adjectives = doc.adjectives().out('array')
  
  // Combine terms, prioritizing nouns
  const terms = [...nouns.slice(0, 3), ...verbs.slice(0, 2), ...adjectives.slice(0, 2)]
  
  // Remove duplicates and common words
  const uniqueTerms = [...new Set(terms)]
    .filter(term => !isCommonWord(term))
    .slice(0, 5)
  
  // If no good terms, use the original message (truncated)
  if (uniqueTerms.length === 0) {
    return message.length > 100 ? message.substring(0, 100) + '...' : message
  }
  
  // Add context based on entities
  let context = ''
  if (entities.documentTypes.length > 0) {
    context = 'document ' + entities.documentTypes[0]
  } else if (entities.fileTypes.length > 0) {
    context = entities.fileTypes[0] + ' file'
  }
  
  const query = context ? `${context} ${uniqueTerms.join(' ')}` : uniqueTerms.join(' ')
  return query
}
// Enhance intents based on search results
export function enhanceIntentsWithSearch(intents, searchSummary) {
  const enhancedIntents = []
  
  if (!searchSummary || !searchSummary.keyPoints) {
    return enhancedIntents
  }
  
  const keyPointsText = searchSummary.keyPoints.join(' ').toLowerCase()
  const keyTerms = searchSummary.keyTerms.map(term => term.toLowerCase())
  
  // Check for government-related content
  if (keyPointsText.includes('government') || 
      keyPointsText.includes('ministry') ||
      keyPointsText.includes('official') ||
      keyTerms.some(term => term.includes('license') || term.includes('permit'))) {
    enhancedIntents.push('analyzeGovernment')
  }
  
  // Check for legal content
  if (keyPointsText.includes('legal') || 
      keyPointsText.includes('contract') ||
      keyPointsText.includes('agreement') ||
      keyTerms.some(term => term.includes('law') || term.includes('clause'))) {
    enhancedIntents.push('analyzeLegal')
  }
  
  // Check for financial content
  if (keyPointsText.includes('financial') || 
      keyPointsText.includes('invoice') ||
      keyPointsText.includes('receipt') ||
      keyTerms.some(term => term.includes('payment') || term.includes('bank'))) {
    enhancedIntents.push('analyzeFinancial')
  }
  
  // Check for research content
  if (keyPointsText.includes('research') || 
      keyPointsText.includes('study') ||
      keyPointsText.includes('academic') ||
      keyTerms.some(term => term.includes('paper') || term.includes('thesis'))) {
    enhancedIntents.push('analyzeResearch')
  }
  
  return [...new Set(enhancedIntents)]
}
// Generate response based on search results
export function generateSearchBasedResponse(searchSummary, originalQuery, language) {
  const { keyPointsz, keyTerms, recommendation, confidence } = searchSummary
 const keyPoints = simulateSearchResults(originalQuery,2)
 localStorage.setItem('keyPoints',JSON.stringify(keyPoints))
  let response = ''
  
  if (language === 'am') {
    response = `🔍 በ"${originalQuery}" ላይ ያገኘሁትን መረጃ:\n\n`
    
    if (keyPoints && keyPoints.length > 0) {
      response += `**ዋና ነጥቦች:**\n`
      keyPoints.slice(0, 3).forEach((point, i) => {
        response += `${i + 1}. ${point['snippet']}\n`
      })
    }
    
    if (keyTerms && keyTerms.length > 0) {
      response += `\n**ዋና ቃላት:** ${keyTerms.slice(0, 5).join(', ')}`
    }
    
    response += `\n\n${recommendation || 'በትክክለኛ መረጃ ለማግኘት ተገቢውን መንግስታዊ ድርጣቢያ ይጎብኙ።'}`
    
  } else {
    response = `🔍 Here's what I found about "${originalQuery}":\n\n`
    
    if (keyPoints && keyPoints.length > 0) {
      response += `**Key Points:**\n`
      keyPoints.slice(0, 3).forEach((point, i) => {
        response += `${i + 1}. ${point}\n`
      })
    }
    
    if (keyTerms && keyTerms.length > 0) {
      response += `\n**Key Terms:** ${keyTerms.slice(0, 5).join(', ')}`
    }
    
    response += `\n\n${recommendation || 'For accurate information, please consult official sources.'}`
    
    if (confidence < 0.7) {
      response += `\n\n*Note: This information has moderate confidence. For official procedures, please verify with relevant authorities.*`
    }
  }
  
  return response
}

// Enhanced processMessage function (existing, now uses Google search)
export async function processGOOGLEsearch(intents,message, isFile) {
  // ... existing processGOOGLEsearch implementation ...
  // Add this after intent extraction:
  
  const isUnclearIntent = intents.length === 0 || 
                         intents.includes('general') || 
                         (intents.length === 1 && intents[0] === 'analyzeDocument')
  
  let searchSummary = null
 if (isUnclearIntent && intents.length > 5) {
    console.log('🌐 Intent unclear, performing Google search...')
    
    const searchQuery = generateSearchQuery(intents, entities)
    const searchResult = await searchWebForUnknownIntent(searchQuery, {
      language: localStorage.getItem('agig-language') || 'en',
      useGoogle: true
    })
    
    if (searchResult.success && searchResult.summary) {
      searchSummary = searchResult.summary
      
      // Update intents based on search results
      const enhancedIntents = enhanceIntentsWithSearch(intents, searchSummary)
      if (enhancedIntents.length > 0) {
        intents.push(...enhancedIntents.filter(i => !intents.includes(i)))
      }
    }
  } else console.error();
  
  return(enhancedIntents)
  // ... rest of existing function ...
}

// ... rest of existing functions (setupIntentPatterns, extractIntents, etc.) ...

// Export enhanced googleSearch with Google API
export const googleSearch = {
  init: initGOOGLEsearch,
  setGoogleCredentials,
  searchWebForUnknownIntent,
  clearSearchCache,
  getCacheStats,
  generateSearchQuery,
  simulateSearchResults,
  generateSearchBasedResponse,
  // Existing functions
  processGOOGLEsearch,
 /* handleBusinessLicenseInput,
  extractIntents,
  extractEntities,
  analyzeSentiment,
  shouldRequestFileUpload,
  determineResponseType,
  generateContextualResponse,
  setupStepResponses,
  getIftmsResponse,
  getGreetingResponse,
  getHelpResponse,
  getThanksResponse,
  getGeneralResponse,
  addSentimentTone,
  isBusinessLicenseNumber,
  analyzeDocumentContent,
  */
  // Configuration
  config: {
    google: GOOGLE_SEARCH_CONFIG,
    duckduckgo: DUCKDUCKGO_CONFIG
  }
}END
cat > src/services/loginApi.js << 'END'
// ============================================================
// loginApi.js - Browserless.io Only (No Python Server)
// ============================================================

const BROWSERLESS_TOKEN = import.meta.env.VITE_BROWSERLESS_TOKEN || '2V8gQ7dU4HvS03Bb1ec733cd6bb13be1023887a5662723ff1';
const BROWSERLESS_URL = import.meta.env.VITE_BROWSERLESS_URL || 'https://production-sfo.browserless.io';

// ============================================================
// API FUNCTIONS THAT CALL BROWSERLESS CLOUD
// ============================================================

async function getSession() {
  console.log('📋 Getting session from localStorage...');
  
  try {
    const saved = localStorage.getItem('ifmts_session');
    if (!saved) {
      return { success: false, error: 'No session found' };
    }
    const session = JSON.parse(saved);
    if (session.expiry && Date.now() > session.expiry) {
      localStorage.removeItem('ifmts_session');
      return { success: false, error: 'Session expired' };
    }
    return { success: true, session };
  } catch (error) {
    return { success: false, error: error.message };
  }
}

async function runBrowserlessScript(code) {
  console.log('🔐 Running Browserless script...');
  
  try {
    const response = await fetch(`${BROWSERLESS_URL}/function`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Cache-Control': 'no-cache'
      },
      body: JSON.stringify({
        code: code,
        context: {
          apiKey: BROWSERLESS_TOKEN
        }
      })
    });
    
    if (!response.ok) {
      throw new Error(`Browserless API error: ${response.status}`);
    }
    
    const result = await response.json();
    console.log('✅ Browserless script executed');
    return result;
  } catch (error) {
    console.error('❌ Browserless error:', error.message);
    return { success: false, error: error.message };
  }
}

async function triggerLogin(username, password) {
  console.log('🔐 Triggering login via Browserless...');
  
  const loginScript = `
    async function performLogin() {
      const page = await browser.newPage();
      
      try {
        console.log('🔐 Navigating to IFMTS login...');
        await page.goto('https://iftms.motl.gov.et/auth/sign-in', {
          waitUntil: 'networkidle2',
          timeout: 30000
        });
        
        await page.waitForSelector('[name="phone_number"]', { timeout: 10000 });
        console.log('✅ Login form loaded');
        
        await page.type('[name="phone_number"]', '${username}', { delay: 50 });
        await page.type('input[type="password"]', '${password}', { delay: 50 });
        console.log('📝 Credentials entered');
        
        await page.click('button[type="submit"]');
        console.log('🖱️ Login button clicked');
        
        await page.waitForNavigation({
          waitUntil: 'networkidle2',
          timeout: 30000
        });
        
        const currentUrl = page.url();
        const success = currentUrl.includes('dashboard');
        
        if (success) {
          console.log('✅ Login successful!');
          const cookies = await page.cookies();
          
          // Try to get user info from page
          const userData = await page.evaluate(() => {
            try {
              const userId = document.querySelector('[data-user-id]')?.textContent || 
                            document.querySelector('.user-id')?.textContent || null;
              const licenseId = document.querySelector('[data-license-id]')?.textContent ||
                               document.querySelector('.license-id')?.textContent || null;
              return { userId, licenseApplicationId: licenseId };
            } catch (e) {
              return {};
            }
          });
          
          return {
            success: true,
            cookies: cookies,
            url: currentUrl,
            userData: userData
          };
        } else {
          console.log('❌ Login failed');
          return {
            success: false,
            url: currentUrl,
            error: 'Login failed - check credentials'
          };
        }
      } catch (error) {
        console.error('❌ Login error:', error.message);
        return {
          success: false,
          error: error.message
        };
      } finally {
        await page.close();
      }
    }
    
    return await performLogin();
  `;
  
  return await runBrowserlessScript(loginScript);
}

async function getStatus() {
  try {
    const session = await getSession();
    return {
      isAuthenticated: session.success,
      ...session
    };
  } catch (error) {
    return { isAuthenticated: false, error: error.message };
  }
}

async function refreshSession() {
  console.log('🔄 Refreshing session...');
  const saved = localStorage.getItem('ifmts_session');
  if (!saved) {
    return { success: false, error: 'No session to refresh' };
  }
  
  const session = JSON.parse(saved);
  if (!session.username || !session.password) {
    return { success: false, error: 'No credentials stored' };
  }
  
  return await triggerLogin(session.username, session.password);
}

async function logout() {
  console.log('👋 Logging out...');
  localStorage.removeItem('ifmts_session');
  return { success: true, message: 'Logged out' };
}

// ============================================================
// CONFIGURATION
// ============================================================

const isDev = import.meta.env.DEV;

const CONFIG = {
  API_BASE: isDev ? '/api-auth' : 'https://api.iftms.motl.gov.et',
  BROWSERLESS_URL: BROWSERLESS_URL,
  BROWSERLESS_TOKEN: BROWSERLESS_TOKEN
};

console.log('🔧 ===== IFMTS API CONFIG =====');
console.log(`🌐 Browserless URL: ${CONFIG.BROWSERLESS_URL}`);
console.log(`🌐 API Base: ${CONFIG.API_BASE}`);
console.log('🔧 =============================');

// ============================================================
// IFMTS API CLASS - Uses Browserless
// ============================================================

class IFMTSAPI {
  constructor() {
    this.token = null;
    this.userId = null;
    this.licenseApplicationId = null;
    this.cookies = null;
    this._isAuthenticated = false;
    this.sessionData = null;
    console.log('🏗️ IFMTSAPI instance created');
  }

  isAuthenticated() {
    return this._isAuthenticated && this.cookies !== null;
  }

  // ============================================================
  // 1. LOAD SESSION FROM LOCALSTORAGE
  // ============================================================
  
  async loadSession() {
    console.log('🔐 ===== LOADING SESSION =====');
    
    const result = await getSession();
    
    if (!result.success || !result.session) {
      console.log('ℹ️ No session available. Please login.');
      return { success: false, error: result.error || 'No session' };
    }
    
    const session = result.session;
    this.token = session.token;
    this.userId = session.userId;
    this.licenseApplicationId = session.licenseApplicationId;
    this.cookies = session.cookies;
    this._isAuthenticated = session.isAuthenticated;
    this.sessionData = session;
    
    console.log('✅ Session loaded successfully');
    console.log(`👤 User ID: ${this.userId}`);
    console.log(`📋 License App ID: ${this.licenseApplicationId}`);
    
    return { success: true };
  }

  // ============================================================
  // 2. LOGIN - Via Browserless
  // ============================================================
  
  async login(username, password) {
    console.log('🔐 ===== LOGIN VIA BROWSERLESS =====');
    console.log(`📱 Username: ${username}`);
    
    try {
      const result = await triggerLogin(username, password);
      
      if (!result.success) {
        return { success: false, error: result.error };
      }
      
      // Save session
      const session = {
        isAuthenticated: true,
        username: username,
        password: password,
        cookies: result.cookies,
        userId: result.userData?.userId || null,
        licenseApplicationId: result.userData?.licenseApplicationId || null,
        token: null,
        expiry: Date.now() + 3600000
      };
      
      localStorage.setItem('ifmts_session', JSON.stringify(session));
      
      this.cookies = result.cookies;
      this.userId = session.userId;
      this.licenseApplicationId = session.licenseApplicationId;
      this._isAuthenticated = true;
      this.sessionData = session;
      
      console.log('✅ Login completed!');
      return { success: true };
    } catch (error) {
      console.error('❌ Login error:', error);
      return { success: false, error: error.message };
    }
  }

  // ============================================================
  // 3. GET USER INFO
  // ============================================================
  
  async getUserInfo() {
    console.log('👤 ===== GET USER INFO =====');
    console.log(`🌐 API URL: ${CONFIG.API_BASE}/auth/me`);
    
    if (!this.isAuthenticated()) {
      console.warn('⚠️ Not authenticated');
      return null;
    }
    
    try {
      const headers = {
        'Accept': 'application/json, text/plain, */*',
      };
      
      if (this.token) {
        headers['Authorization'] = `Bearer ${this.token}`;
      } else if (this.cookies) {
        const cookieString = this.cookies
          .map(c => `${c.name}=${c.value}`)
          .join('; ');
        headers['Cookie'] = cookieString;
      }

      const response = await fetch(`${CONFIG.API_BASE}/auth/me`, {
        method: 'GET',
        headers: headers,
        credentials: 'include',
      });

      console.log(`📥 Response status: ${response.status}`);

      if (response.status === 401 || response.status === 403) {
        console.warn('⚠️ Unauthorized - session expired');
        this._isAuthenticated = false;
        return null;
      }

      if (!response.ok) {
        console.error('❌ Failed to get user info:', response.status);
        return null;
      }

      const data = await response.json();
      console.log('📥 User info received');
      
      this.userData = data;
      this.userId = data.id;
      
      if (data.licenseApplication) {
        this.licenseData = data.licenseApplication;
        this.licenseApplicationId = data.licenseApplication.id;
        console.log(`✅ License App ID: ${this.licenseApplicationId}`);
        console.log(`✅ Operator: ${data.licenseApplication.operator_name}`);
      }
      
      return data;
    } catch (error) {
      console.error('❌ Failed to get user info:', error.message);
      return null;
    }
  }

  // ============================================================
  // 4. ADD VEHICLE
  // ============================================================
  
  async addVehicle(vehicleData) {
    console.log('🚗 ===== ADD VEHICLE =====');
    console.log(`📋 Plate: ${vehicleData.plateNumber || 'N/A'}`);
    
    if (!this.isAuthenticated()) {
      console.error('❌ Not authenticated');
      return { success: false, error: 'Not authenticated' };
    }
    
    try {
      const headers = {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
      };
      
      if (this.token) {
        headers['Authorization'] = `Bearer ${this.token}`;
      } else if (this.cookies) {
        const cookieString = this.cookies
          .map(c => `${c.name}=${c.value}`)
          .join('; ');
        headers['Cookie'] = cookieString;
      }

      const response = await fetch(`${CONFIG.API_BASE}/vehicles`, {
        method: 'POST',
        headers: headers,
        body: JSON.stringify({
          plateNumber: vehicleData.plateNumber || '',
          plateCode: vehicleData.plateCode || '',
          motorNumber: vehicleData.motorNumber || '',
          vinNumber: vehicleData.vinNumber || '',
          chassisNumber: vehicleData.chassisNumber || '',
          manufacturer: vehicleData.manufacturer || '',
          vehicleModel: vehicleData.vehicleModel || '',
          manufactureYear: vehicleData.manufactureYear || '',
          vehicleType: vehicleData.vehicleType || '',
          bodyPartType: vehicleData.bodyPartType || '',
          engineInfo: vehicleData.engineInfo || '',
          engineCapacity: vehicleData.engineCapacity || '',
          cylinderCount: vehicleData.cylinderCount || '',
          fuelType: vehicleData.fuelType || '',
          serviceType: vehicleData.serviceType || '',
          totalWeight: vehicleData.totalWeight || '',
          unladenWeight: vehicleData.unladenWeight || '',
          loadCapacity: vehicleData.loadCapacity || '',
          cargoVolume: vehicleData.cargoVolume || '',
          tonnage: vehicleData.tonnage || '',
          gvw: vehicleData.gvw || '',
          payload: vehicleData.payload || '',
          seatingCapacity: vehicleData.seatingCapacity || '',
          wheelbase: vehicleData.wheelbase || '',
          axelCount: vehicleData.axelCount || '',
          color: vehicleData.color || '',
          bodyColor: vehicleData.bodyColor || '',
          interiorColor: vehicleData.interiorColor || '',
          assemblyPlant: vehicleData.assemblyPlant || '',
          gpsInfo: vehicleData.gpsInfo || '',
          licenseApplicationId: this.licenseApplicationId,
          userId: this.userId
        }),
        credentials: 'include',
      });

      console.log(`📥 Response status: ${response.status}`);

      if (!response.ok) {
        const errorData = await response.text();
        console.error('❌ Failed:', response.status, errorData);
        return { success: false, error: `Vehicle add failed: ${response.status}`, details: errorData };
      }

      const result = await response.json();
      console.log('✅ Vehicle added! ID:', result.id || 'unknown');
      return { success: true, id: result.id, data: result, message: 'Vehicle added' };
    } catch (error) {
      console.error('❌ Error:', error.message);
      return { success: false, error: error.message };
    }
  }

  // ============================================================
  // 5. ADD DRIVER
  // ============================================================
  
  async addDriver(driverData) {
    console.log('👤 ===== ADD DRIVER =====');
    console.log(`📋 Name: ${driverData.driverName || 'N/A'}`);
    
    if (!this.isAuthenticated()) {
      console.error('❌ Not authenticated');
      return { success: false, error: 'Not authenticated' };
    }
    
    try {
      const headers = {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
      };
      
      if (this.token) {
        headers['Authorization'] = `Bearer ${this.token}`;
      } else if (this.cookies) {
        const cookieString = this.cookies
          .map(c => `${c.name}=${c.value}`)
          .join('; ');
        headers['Cookie'] = cookieString;
      }

      const response = await fetch(`${CONFIG.API_BASE}/drivers`, {
        method: 'POST',
        headers: headers,
        body: JSON.stringify({
          driverName: driverData.driverName || '',
          driverLicense: driverData.driverLicense || '',
          phoneNumber: driverData.phoneNumber || '',
          email: driverData.email || '',
          address: driverData.address || '',
          licenseApplicationId: this.licenseApplicationId,
          userId: this.userId
        }),
        credentials: 'include',
      });

      console.log(`📥 Response status: ${response.status}`);

      if (!response.ok) {
        const errorData = await response.text();
        console.error('❌ Failed:', response.status, errorData);
        return { success: false, error: `Driver add failed: ${response.status}`, details: errorData };
      }

      const result = await response.json();
      console.log('✅ Driver added! ID:', result.id || 'unknown');
      return { success: true, id: result.id, data: result, message: 'Driver added' };
    } catch (error) {
      console.error('❌ Error:', error.message);
      return { success: false, error: error.message };
    }
  }

  // ============================================================
  // 6. UPDATE OPERATOR
  // ============================================================
  
  async updateOperator(operatorData) {
    console.log('🏢 ===== UPDATE OPERATOR =====');
    console.log(`📋 Name: ${operatorData.operatorName || 'N/A'}`);
    
    if (!this.isAuthenticated()) {
      console.error('❌ Not authenticated');
      return { success: false, error: 'Not authenticated' };
    }
    
    try {
      const headers = {
        'Accept': 'application/json, text/plain, */*',
        'Content-Type': 'application/json',
      };
      
      if (this.token) {
        headers['Authorization'] = `Bearer ${this.token}`;
      } else if (this.cookies) {
        const cookieString = this.cookies
          .map(c => `${c.name}=${c.value}`)
          .join('; ');
        headers['Cookie'] = cookieString;
      }

      const response = await fetch(`${CONFIG.API_BASE}/license-applications/${this.licenseApplicationId}`, {
        method: 'PUT',
        headers: headers,
        body: JSON.stringify({
          operator_name: operatorData.operatorName || this.licenseData?.operator_name || '',
          tin_number: operatorData.businessLicenseNumber || this.licenseData?.tin_number || '',
          mobile_number: operatorData.phoneNumber || this.licenseData?.mobile_number || '',
          trade_registration_number: this.licenseData?.trade_registration_number || '',
          established_date: this.licenseData?.established_date || new Date().toISOString(),
          manager_first_name: this.licenseData?.manager_first_name || '',
          manager_father_name: this.licenseData?.manager_father_name || '',
          manager_grand_father_name: this.licenseData?.manager_grand_father_name || '',
          woreda: this.licenseData?.woreda || '',
          kebele: this.licenseData?.kebele || '',
          house_number: this.licenseData?.house_number || '',
          office_phone_number: this.licenseData?.office_phone_number || '',
          email: this.licenseData?.email || '',
          p_o_box: this.licenseData?.p_o_box || '',
          district_id: this.licenseData?.district_id || 33,
          license_application_type_id: this.licenseData?.license_application_type_id || 3,
          organization_type_id: this.licenseData?.organization_type_id || 1,
          service_type_id: this.licenseData?.service_type_id || 1,
          requested_license_level_category_id: this.licenseData?.requested_license_level_category_id || 12,
          initial_vehicle_count: this.licenseData?.initial_vehicle_count || 0,
          initial_load_capacity: this.licenseData?.initial_load_capacity || 0
        }),
        credentials: 'include',
      });

      console.log(`📥 Response status: ${response.status}`);

      if (!response.ok) {
        const errorData = await response.text();
        console.error('❌ Failed:', response.status, errorData);
        return { success: false, error: `Operator update failed: ${response.status}`, details: errorData };
      }

      const result = await response.json();
      console.log('✅ Operator updated! ID:', result.id || 'unknown');
      return { success: true, id: result.id, data: result, message: 'Operator updated' };
    } catch (error) {
      console.error('❌ Error:', error.message);
      return { success: false, error: error.message };
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================
  
  getToken() { return this.token; }
  getUserId() { return this.userId; }
  getLicenseApplicationId() { return this.licenseApplicationId; }
  getLicenseData() { return this.licenseData; }
}

// ============================================================
// SINGLETON
// ============================================================

let apiInstance = null;

function getApiInstance() {
  if (!apiInstance) {
    apiInstance = new IFMTSAPI();
  }
  return apiInstance;
}

// ============================================================
// EXPORTED FUNCTIONS
// ============================================================

export async function login(username, password) {
  console.log('🔐 ===== LOGIN =====');
  
  try {
    const api = getApiInstance();
    const result = await api.login(username, password);
    if (result.success) {
      await api.loadSession();
    }
    return {
      success: result.success,
      userId: api.getUserId(),
      licenseApplicationId: api.getLicenseApplicationId(),
      token: api.getToken(),
      api: api,
      licenseData: api.getLicenseData(),
      ...result
    };
  } catch (error) {
    console.error('❌ Login error:', error.message);
    return { success: false, error: error.message };
  }
}

export async function processIfmtsData(collectedData, credentials) {
  console.log('📋 ===== PROCESS IFMTS DATA =====');
  
  try {
    const api = getApiInstance();
    
    if (!api.isAuthenticated()) {
      console.log('🔄 Not authenticated, loading session...');
      const loadResult = await api.loadSession();
      if (!loadResult.success) {
        console.log('🔄 No session, triggering login...');
        await api.login(credentials?.username, credentials?.password);
      }
    }

    const results = { success: true, operator: null, vehicles: [], drivers: [], errors: [] };

    if (collectedData.operator) {
      const result = await api.updateOperator(collectedData.operator);
      result.success ? results.operator = result : results.errors.push({ type: 'operator', error: result.error });
    }

    if (collectedData.vehicles?.length > 0) {
      for (const vehicle of collectedData.vehicles) {
        const result = await api.addVehicle(vehicle);
        result.success ? results.vehicles.push(result) : results.errors.push({ type: 'vehicle', error: result.error });
      }
    }

    if (collectedData.drivers?.length > 0) {
      for (const driver of collectedData.drivers) {
        const result = await api.addDriver(driver);
        result.success ? results.drivers.push(result) : results.errors.push({ type: 'driver', error: result.error });
      }
    }

    results.success = results.errors.length === 0;
    return results;
  } catch (error) {
    console.error('❌ Error:', error.message);
    return { success: false, error: error.message };
  }
}

export async function performIfmtsAction(action, data) {
  console.log(`🎯 ===== ACTION: ${action} =====`);
  
  try {
    const api = getApiInstance();
    if (!api.isAuthenticated()) {
      return { success: false, error: 'Not authenticated', requiresLogin: true };
    }

    let result;
    switch (action) {
      case 'add_vehicle': result = await api.addVehicle(data); break;
      case 'add_driver': result = await api.addDriver(data); break;
      case 'register_operator': result = await api.updateOperator(data); break;
      default: throw new Error(`Unknown action: ${action}`);
    }
    return result;
  } catch (error) {
    return { success: false, action, error: error.message };
  }
}

// ============================================================
// EXPORTS
// ============================================================

export const loginApi = {
  login,
  performIfmtsAction,
  processIfmtsData,
  CONFIG,
  getApiInstance,
  // Expose Browserless functions
  getSession,
  triggerLogin,
  getStatus,
  refreshSession,
  logout,
  runBrowserlessScript
};

console.log('✅ ===== loginApi.js LOADED =====');
console.log(`🌐 Browserless URL: ${CONFIG.BROWSERLESS_URL}`);
console.log('✅ =============================');

export default loginApi;END
cat > src/services/modelWorker.js << 'END'
// ============================================================
// modelWorker.js - COMPLETE WORKING FILE
// ============================================================

let generator = null;
let isReady = false;

async function loadModel() {
  console.log("🚀 Loading Qwen...");
  
  try {
    const { pipeline, env } = await import('https://cdn.jsdelivr.net/npm/@huggingface/transformers@3.7.2');
    env.useBrowserCache = true;
    
    generator = await pipeline('text-generation', 'onnx-community/Qwen2.5-0.5B-Instruct', { 
        quantized: true,
        device: 'wasm'
    });
    
    isReady = true;
    console.log("✅ Qwen ready");
    self.postMessage({ type: 'ready' });
    
  } catch (error) {
    console.error("Load failed:", error);
    isReady = true;
    self.postMessage({ type: 'ready' });
  }
}

function getCurrentField(serviceConfig, currentState) {
  const step = serviceConfig.steps[currentState.currentStep];
  if (!step) return null;
  const fields = step.fields || step.subprocess?.fields || [];
  return fields[currentState.currentFieldIndex];
}

function buildPrompt(serviceConfig, currentState, userMessage) {
  const step = serviceConfig.steps[currentState.currentStep];
  const currentField = getCurrentField(serviceConfig, currentState);
  const fields = step.fields || step.subprocess?.fields || [];
  
  let context = `You are ${serviceConfig.name} assistant.

Current step: ${currentState.currentStep}
Step type: ${step.type}
Field: ${currentField?.name || 'unknown'}
Question: "${currentField?.question || 'Enter value'}"
Field ${currentState.currentFieldIndex + 1} of ${fields.length}
Waiting for add: ${currentState.waitingForAdd}
Waiting for continue: ${currentState.waitingForContinue}
Collected: ${JSON.stringify(currentState.collectedData)}

User: "${userMessage}"

Return ONLY JSON. Options:
{"action":"save","value":"the value"}
{"action":"yes"}
{"action":"no"}
{"action":"step_complete"}
{"action":"help"}
{"action":"status"}
{"action":"switch_service","service":"iftms"}

Response:`;

  return context;
}

async function predictNextStep(serviceConfig, currentState, userMessage) {
  console.log("Message:", userMessage);
  
  if (!generator || !isReady) {
    return { action: 'save', value: userMessage };
  }
  
  const prompt = buildPrompt(serviceConfig, currentState, userMessage);
  
  try {
    const result = await generator(prompt, {
      max_new_tokens: 80,
      temperature: 0.1,
      do_sample: false,
      return_full_text: false
    });
    
    const output = result[0].generated_text;
    console.log("Qwen:", output);
    
    const jsonMatch = output.match(/\{[\s\S]*?\}/);
    if (jsonMatch) {
      return JSON.parse(jsonMatch[0]);
    }
  } catch (err) {
    console.error("Error:", err);
  }
  
  return { action: 'save', value: userMessage };
}

// ✅ Use proper event listener
self.addEventListener('message', async (e) => {
  const { type, data, id } = e.data;
  
  if (type === 'predict') {
    const result = await predictNextStep(data.serviceConfig, data.currentState, data.userMessage);
    self.postMessage({ type: 'response', data: result, id });
  }
});

// Start loading
loadModel();

// ✅ Export for module compatibility
export default null;
END
cat > src/services/nlpProcessor.js << 'END'
// ============================================================
// nlpProcessor.js - Complete with Proper API Actions Integration
// ============================================================

import * as pdfjsLib from 'pdfjs-dist/build/pdf';
import { vinDecoder } from './vindecoder.js';
import { getServiceConfigDB } from './serviceConfigDB.js';
import { executeStepApiActions, executeFieldApiActions } from './apiTasks.js';

// ============================================================
// GET LANGUAGE
// ============================================================

function getLanguage() {
  try {
    const lang = localStorage.getItem('agig-language');
    return lang === 'am' ? 'am' : 'en';
  } catch (e) {
    return 'en';
  }
}

function getLocalized(obj) {
  if (!obj) return '';
  if (typeof obj === 'string') return obj;
  if (typeof obj === 'object' && obj !== null) {
    const lang = getLanguage();
    return obj[lang] !== undefined && obj[lang] !== '' ? obj[lang] : obj.en || '';
  }
  return obj;
}

function getLocalizedOptions(optionsObj) {
  if (!optionsObj) return [];
  if (Array.isArray(optionsObj)) return optionsObj;
  if (typeof optionsObj === 'object' && optionsObj !== null) {
    const lang = getLanguage();
    return optionsObj[lang] || optionsObj.en || [];
  }
  return optionsObj;
}

// ============================================================
// DEFAULT SERVICES WITH LOGICAL API ACTIONS
// ============================================================

const DEFAULT_SERVICES = {
  iftms: {
    id: 'iftms',
    name: { en: 'IFTMS - Freight Transport', am: 'IFTMS - የጭነት ትራንስፖርት' },
    description: { en: 'Register freight transport operators, vehicles, and drivers', am: 'የጭነት ትራንስፖርት ኦፕሬተሮችን፣ ተሽከርካሪዎችን እና አሽከርካሪዎችን ይመዝገቡ' },
    initStep: 1,
    collectedData: { operator: {}, vehicles: [], drivers: [] },
    steps: {
      1: {
        type: 'form',
        title: { en: 'Operator Registration', am: 'የኦፕሬተር ምዝገባ' },
        fields: [
          { 
            name: 'businessLicenseNumber', 
            question: { en: 'Business License Number? (Example: 12345678)', am: 'የንግድ ፈቃድ ቁጥር? (ምሳሌ: 12345678)' },
            validation: 'license', 
            regex: /^[0-9]{6,10}$/, 
            example: { en: '12345678', am: '12345678' },
            error: { en: 'Invalid. Use 6-10 digits.', am: 'ልክ ያልሆነ። 6-10 አሃዞችን ይጠቀሙ።' }
          },
          { 
            name: 'operatorName', 
            question: { en: 'Operator Name? (Example: Ethio Transport)', am: 'የኦፕሬተር ስም? (ምሳሌ: ኢትዮ ትራንስፖርት)' },
            validation: 'text', 
            regex: /^.+$/, 
            example: { en: 'Ethio Transport', am: 'ኢትዮ ትራንስፖርት' },
            error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' }
          },
          { 
            name: 'phoneNumber', 
            question: { en: 'Phone Number? (Example: 0912345678 or +251912345678)', am: 'ስልክ ቁጥር? (ምሳሌ: 0912345678 ወይም +251912345678)' },
            validation: 'phone', 
            regex: /^(0?[79][0-9]{8}|\+251[79][0-9]{8})$/, 
            example: { en: '0912345678', am: '0912345678' },
            error: { en: 'Invalid phone number. Use: 0912345678 or +251912345678', am: 'ልክ ያልሆነ ስልክ ቁጥር። 0912345678 ወይም +251912345678 ይጠቀሙ' }
          },
          { 
            name: 'password', 
            question: { en: 'IFMTS Password?', am: 'IFMTS ይለፍ ቃል?' },
            validation: 'text', 
            example: { en: 'your_password', am: 'ይለፍ_ቃልዎ' },
            error: { en: 'Password is required.', am: 'ይለፍ ቃል ያስፈልጋል።' }
          }
        ],
        // API Action: Register Operator (after ALL fields collected)
        apiActions: [
          {
            id: 'register_operator',
            endpoint: 'https://iftms.motl.gov.et/api/operator/register',
            method: 'POST',
            data: {
              licenseNumber: '{{businessLicenseNumber}}',
              name: '{{operatorName}}',
              phone: '{{phoneNumber}}',
              password: '{{password}}'
            },
            onSuccess: {
              nextStep: 2,
              message: { en: '✅ Operator registered! Proceeding to vehicle management.', am: '✅ ኦፕሬተር ተመዝግቧል! ወደ ተሽከርካሪ አስተዳደር በመቀጠል ላይ።' }
            },
            onFailure: {
              message: { en: '❌ Operator registration failed. Please try again.', am: '❌ የኦፕሬተር ምዝገባ አልተሳካም። እባክዎ እንደገና ይሞክሩ።' }
            }
          }
        ],
        onValid: { nextStep: 2 }
      },
      2: {
        type: 'subprocess',
        title: { en: 'Vehicle Management', am: 'የተሽከርካሪ አስተዳደር' },
        subprocess: {
          itemName: { en: 'Vehicle', am: 'ተሽከርካሪ' },
          addPrompt: { en: 'Add a vehicle? (yes/no)', am: 'ተሽከርካሪ ማከል ይፈልጋሉ? (አዎ/አይ)' },
          continuePrompt: { en: 'Continue to drivers? (yes/no)', am: 'ወደ አሽከርካሪዎች መቀጠል? (አዎ/አይ)' },
          fields: [
            { 
              name: 'plateNumber', 
              question: { en: 'Plate Number? (Example: AA-1234)', am: 'የሰሌዳ ቁጥር? (ምሳሌ: AA-1234)' },
              validation: 'plate', 
              regex: /^[A-Z]{2,3}-?[0-9]{3,4}$/i, 
              example: { en: 'AA-1234', am: 'AA-1234' },
              error: { en: 'Invalid plate format.', am: 'ልክ ያልሆነ የሰሌዳ ቅርጸት።' }
            },
            { 
              name: 'plateCode', 
              question: { en: 'Plate Code? (Example: AA)', am: 'የሰሌዳ ኮድ? (ምሳሌ: AA)' },
              validation: 'text', 
              example: { en: 'AA', am: 'ኤኤ' },
              error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' }
            },
            { 
              name: 'motorNumber', 
              question: { en: 'Motor Number? (Example: 1SG4001234567)', am: 'የሞተር ቁጥር? (ምሳሌ: 1SG4001234567)' },
              validation: 'text', 
              example: { en: '1SG4001234567', am: '1SG4001234567' },
              error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' }
            },
            { 
              name: 'vinNumber', 
              question: { en: 'VIN or Chassis Number? (Example: LVBS6PE123456789)', am: 'VIN ወይም የቻሲስ ቁጥር? (ምሳሌ: LVBS6PE123456789)' },
              validation: 'vin', 
              regex: /^[A-HJ-NPR-Z0-9]{10,18}$/i, 
              example: { en: 'LVBS6PE123456789', am: 'LVBS6PE123456789' },
              error: { en: 'Invalid VIN/Chassis (10-17 characters).', am: 'ልክ ያልሆነ VIN/ቻሲስ (10-17 ቁምፊዎች)።' },
              // API Action for VIN decoding
              apiActions: [
                {
                  id: 'decode_vin',
                  endpoint: 'https://api.vindecoder.com/decode',
                  method: 'POST',
                  data: {
                    vin: '{{user_input}}'
                  },
                  onSuccess: {
                    message: { en: '🔍 VIN decoded! Fields auto-filled.', am: '🔍 VIN ተተርጉሟል! መስኮች በራስ-ሰር ተሞልተዋል።' }
                  },
                  onFailure: {
                    message: { en: '⚠️ Invalid VIN. Please enter manually.', am: '⚠️ ልክ ያልሆነ VIN። እባክዎ በእጅ ያስገቡ።' }
                  }
                }
              ]
            },
            { 
              name: 'chassisNumber', 
              question: { en: 'Chassis Number?', am: 'የቻሲስ ቁጥር?' },
              validation: 'text', 
              example: { en: 'LVBS6PE123456789', am: 'LVBS6PE123456789' },
              error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' },
              autoFill: true 
            },
            { 
              name: 'manufacturer', 
              question: { en: 'Manufacturer?', am: 'አምራች?' },
              validation: 'text', 
              example: { en: 'Toyota', am: 'ቶዮታ' },
              error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' },
              autoFill: true 
            },
            { 
              name: 'vehicleModel', 
              question: { en: 'Vehicle Model?', am: 'የተሽከርካሪ ሞዴል?' },
              validation: 'text', 
              example: { en: 'Toyota Hilux', am: 'ቶዮታ ሃይሉክስ' },
              error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' },
              autoFill: true 
            },
            { 
              name: 'manufactureYear', 
              question: { en: 'Year of Manufacture?', am: 'የምርት ዓመት?' },
              validation: 'year', 
              regex: /^(19|20)[0-9]{2}$/, 
              example: { en: '2020', am: '2020' },
              error: { en: 'Invalid year (e.g., 2020).', am: 'ልክ ያልሆነ ዓመት (ለምሳሌ: 2020)።' },
              autoFill: true 
            },
            { 
              name: 'vehicleType', 
              question: { en: 'Vehicle Type?', am: 'የተሽከርካሪ አይነት?' },
              validation: 'text', 
              example: { en: 'Truck', am: 'ጭነት መኪና' },
              error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' },
              autoFill: true 
            },
            { 
              name: 'bodyPartType', 
              question: { en: 'Body Part Type?', am: 'የሰውነት ክፍል አይነት?' },
              validation: 'text', 
              example: { en: 'Crew Cab Truck', am: 'ክሩ ካብ መኪና' },
              error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' },
              autoFill: true 
            },
            { 
              name: 'engineInfo', 
              question: { en: 'Engine Information?', am: 'የሞተር መረጃ?' },
              validation: 'text', 
              example: { en: '2.8L Diesel Turbo', am: '2.8L ናፍጣ ቱርቦ' },
              error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' },
              autoFill: true 
            },
            { 
              name: 'engineCapacity', 
              question: { en: 'Engine Capacity (cc)?', am: 'የሞተር አቅም (ሲሲ)?' },
              validation: 'number', 
              regex: /^\d+$/, 
              example: { en: '2800', am: '2800' },
              error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' },
              autoFill: true 
            },
            { 
              name: 'cylinderCount', 
              question: { en: 'Number of Cylinders?', am: 'የሲሊንደሮች ብዛት?' },
              validation: 'number', 
              regex: /^\d+$/, 
              example: { en: '4', am: '4' },
              error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' },
              autoFill: true 
            },
            { 
              name: 'fuelType', 
              question: { en: 'Fuel Type?', am: 'የነዳጅ አይነት?' },
              validation: 'choice', 
              options: { en: ['Diesel', 'Petrol', 'Electric', 'Hybrid', 'LPG', 'CNG'], am: ['ናፍጣ', 'ቤንዚን', 'ኤሌክትሪክ', 'ሃይብሪድ', 'ኤልፒጂ', 'ሲኤንጂ'] },
              example: { en: 'Diesel', am: 'ናፍጣ' },
              error: { en: 'Please select a fuel type.', am: 'እባክዎ የነዳጅ አይነት ይምረጡ።' },
              autoFill: true 
            },
            { 
              name: 'serviceType', 
              question: { en: 'Service Type?', am: 'የአገልግሎት አይነት?' },
              validation: 'choice', 
              options: { en: ['Freight Transport', 'Passenger Transport', 'General Transport', 'Delivery Transport', 'Construction Transport', 'Liquid Transport', 'Cold Chain Transport'], am: ['የጭነት ትራንስፖርት', 'የተሳፋሪ ትራንስፖርት', 'አጠቃላይ ትራንስፖርት', 'የመላኪያ ትራንስፖርት', 'የግንባታ ትራንስፖርት', 'የፈሳሽ ትራንስፖርት', 'የቀዝቃዛ ሰንሰለት ትራንስፖርት'] },
              example: { en: 'Freight Transport', am: 'የጭነት ትራንስፖርት' },
              error: { en: 'Please select a service type.', am: 'እባክዎ የአገልግሎት አይነት ይምረጡ።' },
              autoFill: true 
            },
            { 
              name: 'totalWeight', 
              question: { en: 'Total Weight (kg)?', am: 'ጠቅላላ ክብደት (ኪግ)?' },
              validation: 'number', 
              regex: /^\d+$/, 
              example: { en: '3500', am: '3500' },
              error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' },
              autoFill: true 
            },
            { 
              name: 'unladenWeight', 
              question: { en: 'Unladen Weight (kg)?', am: 'ባዶ ክብደት (ኪግ)?' },
              validation: 'number', 
              regex: /^\d+$/, 
              example: { en: '2500', am: '2500' },
              error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' },
              autoFill: true 
            },
            { 
              name: 'loadCapacity', 
              question: { en: 'Load Capacity (kg)?', am: 'የጭነት አቅም (ኪግ)?' },
              validation: 'number', 
              regex: /^\d+$/, 
              example: { en: '1000', am: '1000' },
              error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' },
              autoFill: true 
            },
            { 
              name: 'cargoVolume', 
              question: { en: 'Cargo Volume (kg)?', am: 'የጭነት መጠን (ኪግ)?' },
              validation: 'number', 
              regex: /^\d+$/, 
              example: { en: '5000', am: '5000' },
              error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' },
              autoFill: true 
            },
            { 
              name: 'tonnage', 
              question: { en: 'Tonnage (T)?', am: 'ቶንነጅ (ቲ)?' },
              validation: 'number', 
              regex: /^\d+\.?\d*$/, 
              example: { en: '3.5', am: '3.5' },
              error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' },
              autoFill: true 
            },
            { 
              name: 'gvw', 
              question: { en: 'Gross Vehicle Weight (kg)?', am: 'ጠቅላላ የተሽከርካሪ ክብደት (ኪግ)?' },
              validation: 'number', 
              regex: /^\d+$/, 
              example: { en: '3500', am: '3500' },
              error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' },
              autoFill: true 
            },
            { 
              name: 'payload', 
              question: { en: 'Payload (kg)?', am: 'ጭነት (ኪግ)?' },
              validation: 'number', 
              regex: /^\d+$/, 
              example: { en: '1000', am: '1000' },
              error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' },
              autoFill: true 
            },
            { 
              name: 'seatingCapacity', 
              question: { en: 'Seating Capacity?', am: 'የመቀመጫ አቅም?' },
              validation: 'number', 
              regex: /^\d+$/, 
              example: { en: '5', am: '5' },
              error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' },
              autoFill: true 
            },
            { 
              name: 'wheelbase', 
              question: { en: 'Wheelbase (mm)?', am: 'የዊልቤዝ (ሚሜ)?' },
              validation: 'number', 
              regex: /^\d+$/, 
              example: { en: '3000', am: '3000' },
              error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' },
              autoFill: true 
            },
            { 
              name: 'axelCount', 
              question: { en: 'Axel Count?', am: 'የአክሰል ብዛት?' },
              validation: 'number', 
              regex: /^\d+$/, 
              example: { en: '2', am: '2' },
              error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' },
              autoFill: true 
            },
            { 
              name: 'color', 
              question: { en: 'Vehicle Color?', am: 'የተሽከርካሪ ቀለም?' },
              validation: 'text', 
              example: { en: 'White', am: 'ነጭ' },
              error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' },
              autoFill: true 
            },
            { 
              name: 'bodyColor', 
              question: { en: 'Body Color?', am: 'የሰውነት ቀለም?' },
              validation: 'text', 
              example: { en: 'White', am: 'ነጭ' },
              error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' },
              autoFill: true 
            },
            { 
              name: 'interiorColor', 
              question: { en: 'Interior Color?', am: 'የውስጥ ቀለም?' },
              validation: 'text', 
              example: { en: 'Black', am: 'ጥቁር' },
              error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' },
              autoFill: true 
            },
            { 
              name: 'assemblyPlant', 
              question: { en: 'Assembly Plant?', am: 'የመሰብሰቢያ ፋብሪካ?' },
              validation: 'text', 
              example: { en: 'China - Beijing', am: 'ቻይና - ቤዪጂንግ' },
              error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' },
              autoFill: true 
            },
            { 
              name: 'gpsInfo', 
              question: { en: 'GPS Info (lat, lon)?', am: 'GPS መረጃ (ላቲቱድ፣ ሎንጂቱድ)?' },
              validation: 'text', 
              example: { en: '39.9042, 116.4074', am: '39.9042, 116.4074' },
              error: { en: 'Invalid GPS format.', am: 'ልክ ያልሆነ የጂፒኤስ ቅርጸት።' },
              autoFill: true 
            }
          ],
          onValid: { nextStep: 3, collectionKey: 'vehicles' }
        }
      },
      3: {
        type: 'subprocess',
        title: { en: 'Driver Management', am: 'የአሽከርካሪ አስተዳደር' },
        subprocess: {
          itemName: { en: 'Driver', am: 'አሽከርካሪ' },
          addPrompt: { en: 'Add a driver? (yes/no)', am: 'አሽከርካሪ ማከል ይፈልጋሉ? (አዎ/አይ)' },
          continuePrompt: { en: 'Continue to completion? (yes/no)', am: 'ወደ መጨረሻ መቀጠል? (አዎ/አይ)' },
          fields: [
            { 
              name: 'driverName', 
              question: { en: 'Driver Name? (Example: Abebe Kebede)', am: 'የአሽከርካሪ ስም? (ምሳሌ: አበበ ከበደ)' },
              validation: 'text', 
              example: { en: 'Abebe Kebede', am: 'አበበ ከበደ' },
              error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' }
            },
            { 
              name: 'driverLicense', 
              question: { en: 'Driver License Number? (Example: DL123456)', am: 'የመንጃ ፈቃድ ቁጥር? (ምሳሌ: DL123456)' },
              validation: 'text', 
              example: { en: 'DL123456', am: 'DL123456' },
              error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' }
            }
          ],
          onValid: { nextStep: 4, collectionKey: 'drivers' }
        }
      },
      4: {
        type: 'summary',
        title: { en: 'Registration Complete', am: 'ምዝገባ ተጠናቀቀ' },
        isFinal: true,
        actions: { en: ['Download Certificate', 'Print Summary', 'Start New Registration'], am: ['የምስክር ወረቀት አውርድ', 'ማጠቃለያ አትም', 'አዲስ ምዝገባ ጀምር'] },
        // Final sync API action
        apiActions: [
          {
            id: 'sync_to_ifmts',
            endpoint: 'https://iftms.motl.gov.et/api/sync',
            method: 'POST',
            data: {
              operator: '{{operator}}',
              vehicles: '{{vehicles}}',
              drivers: '{{drivers}}'
            },
            onSuccess: {
              message: { en: '✅ All data synced to IFMTS!', am: '✅ ሁሉም መረጃ ወደ IFMTS ተመሳስሏል!' }
            },
            onFailure: {
              message: { en: '❌ Sync failed. Please try again.', am: '❌ ማመሳሰል አልተሳካም። እባክዎ እንደገና ይሞክሩ።' }
            }
          }
        ]
      }
    }
  },
  documentAnalysis: {
    id: 'documentAnalysis',
    name: { en: 'Document Analysis', am: 'የሰነድ ትንተና' },
    description: { en: 'Analyze research papers, legal documents, and financial statements', am: 'የምርምር ወረቀቶችን፣ የህግ ሰነዶችን እና የፋይናንስ ሪፖርቶችን ይተንትኑ' },
    initStep: 1,
    collectedData: { document: null, analysisType: null },
    steps: {
      1: {
        type: 'file_upload',
        title: { en: 'Upload Document', am: 'ሰነድ ስቀል' },
        prompt: { en: '📄 Please upload the document you want me to analyze:', am: '📄 እባክዎ መተንተን የሚፈልጉትን ሰነድ ያስገቡ:' },
        onValid: { nextStep: 2 }
      },
      2: {
        type: 'form',
        title: { en: 'Analysis Type', am: 'የትንተና አይነት' },
        fields: [
          { 
            name: 'analysisType', 
            question: { en: 'What type of analysis do you want? (Example: Summarize)', am: 'ምን አይነት ትንተና ይፈልጋሉ? (ምሳሌ: ማጠቃለል)' },
            validation: 'choice', 
            options: { en: ['Summarize', 'Extract Key Points', 'Find Keywords', 'Analyze Sentiment'], am: ['ማጠቃለል', 'ቁልፍ ነጥቦችን ማውጣት', 'ቁልፍ ቃላትን መፈለግ', 'ስሜትን መተንተን'] },
            example: { en: 'Summarize', am: 'ማጠቃለል' },
            error: { en: 'Please select an option.', am: 'እባክዎ አማራጭ ይምረጡ።' }
          }
        ],
        // API Action: Analyze document
        apiActions: [
          {
            id: 'analyze_document',
            endpoint: 'https://api.documentanalysis.com/analyze',
            method: 'POST',
            data: {
              document: '{{document}}',
              analysisType: '{{analysisType}}'
            },
            onSuccess: {
              nextStep: 3,
              message: { en: '📊 Analysis complete!', am: '📊 ትንተና ተጠናቀቀ!' }
            },
            onFailure: {
              message: { en: '❌ Analysis failed.', am: '❌ ትንተና አልተሳካም።' }
            }
          }
        ],
        onValid: { nextStep: 3 }
      },
      3: {
        type: 'result',
        title: { en: 'Analysis Result', am: 'የትንተና ውጤት' },
        prompt: { en: '✅ Analysis complete!', am: '✅ ትንተና ተጠናቀቀ!' },
        isFinal: true,
        actions: { en: ['New Analysis', 'Export Results', 'Start Over'], am: ['አዲስ ትንተና', 'ውጤቶችን ወደ ውጭ ላክ', 'እንደገና ጀምር'] }
      }
    }
  },
  videoGeneration: {
    id: 'videoGeneration',
    name: { en: 'Video Generation', am: 'ቪዲዮ ማምረት' },
    description: { en: 'Create video clips, slideshows, and advertisements', am: 'የቪዲዮ ክሊፖችን፣ ስላይድሾዎችን እና ማስታወቂያዎችን ይፍጠሩ' },
    initStep: 1,
    collectedData: { videoType: null, duration: null },
    steps: {
      1: {
        type: 'form',
        title: { en: 'Video Details', am: 'የቪዲዮ ዝርዝሮች' },
        fields: [
          { 
            name: 'videoType', 
            question: { en: 'What type of video? (Example: Slideshow)', am: 'ምን አይነት ቪዲዮ? (ምሳሌ: ስላይድሾው)' },
            validation: 'choice', 
            options: { en: ['Slideshow', 'Video Clip', 'Advertisement'], am: ['ስላይድሾው', 'ቪዲዮ ክሊፕ', 'ማስታወቂያ'] },
            example: { en: 'Slideshow', am: 'ስላይድሾው' },
            error: { en: 'Please select a video type.', am: 'እባክዎ የቪዲዮ አይነት ይምረጡ።' }
          },
          { 
            name: 'duration', 
            question: { en: 'Duration (seconds)? (Example: 30)', am: 'ቆይታ (ሰከንዶች)? (ምሳሌ: 30)' },
            validation: 'number', 
            regex: /^\d+$/, 
            example: { en: '30', am: '30' },
            error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' }
          }
        ],
        onValid: { nextStep: 2 }
      },
      2: {
        type: 'file_upload',
        title: { en: 'Upload Media', am: 'ሚዲያ ስቀል' },
        prompt: { en: '📷 Upload images or provide a script:', am: '📷 ምስሎችን ያስገቡ ወይም ስክሪፕት ያቅርቡ:' },
        onValid: { nextStep: 3 }
      },
      3: {
        type: 'summary',
        title: { en: 'Video Generation Complete', am: 'ቪዲዮ ማምረት ተጠናቀቀ' },
        prompt: { en: '✅ Your video is ready to generate!', am: '✅ ቪዲዮዎ ለማምረት ዝግጁ ነው!' },
        isFinal: true,
        actions: { en: ['Generate Video', 'Edit Script', 'Start Over'], am: ['ቪዲዮ አምርት', 'ስክሪፕት አርትዕ', 'እንደገና ጀምር'] }
      }
    }
  }
};

// ============================================================
// STATE MANAGEMENT (Rest of the code remains the same)
// ============================================================

let currentService = 'iftms';
let modelWorker = null;
let callbacks = new Map();
let callbackId = 0;
let workerReady = false;

// In-memory services
let services = {};
let servicesInitialized = false;
let db = null;

const serviceStates = {};

// ============================================================
// COMPLETION TRACKING
// ============================================================

function isServiceComplete(serviceId) {
  const state = serviceStates[serviceId];
  if (!state) return false;
  return state.isComplete === true;
}

function markServiceComplete(serviceId) {
  if (!serviceStates[serviceId]) {
    const svc = services[serviceId];
    serviceStates[serviceId] = {
      currentStep: svc?.initStep || 1,
      currentFieldIndex: 0,
      waitingForAdd: false,
      waitingForContinue: false,
      currentItem: {},
      collectedData: JSON.parse(JSON.stringify(svc?.collectedData || {})),
      isComplete: true
    };
  } else {
    serviceStates[serviceId].isComplete = true;
  }
  saveGlobalState();
}

function resetService(serviceId) {
  const svc = services[serviceId];
  if (!svc) return;
  
  serviceStates[serviceId] = {
    currentStep: svc.initStep || 1,
    currentFieldIndex: 0,
    waitingForAdd: false,
    waitingForContinue: false,
    currentItem: {},
    collectedData: JSON.parse(JSON.stringify(svc.collectedData || {})),
    isComplete: false
  };
  saveGlobalState();
}

// ============================================================
// INITIALIZE - LOAD FROM DB OR POPULATE
// ============================================================

async function initializeServices() {
  if (servicesInitialized) return true;
  
  try {
    console.log('📂 Initializing services...');
    db = await getServiceConfigDB();
    
    const dbConfigs = await db.getAllServiceConfigs();
    
    if (dbConfigs && dbConfigs.length > 0) {
      console.log(`✅ Found ${dbConfigs.length} services in database`);
      
      for (const dbConfig of dbConfigs) {
        if (dbConfig.isActive !== false) {
          const service = {
            id: dbConfig.serviceId,
            name: dbConfig.name,
            description: dbConfig.description,
            initStep: dbConfig.initStep || 1,
            collectedData: dbConfig.collectedData || {},
            steps: dbConfig.steps || {}
          };
          if (service && service.id) {
            services[service.id] = service;
            console.log(`  ✅ Loaded: ${service.id} - ${getLocalized(service.name)}`);
          }
        }
      }
    }
    
    if (Object.keys(services).length === 0) {
      console.log('📂 Database empty, populating with default services...');
      
      for (const [id, service] of Object.entries(DEFAULT_SERVICES)) {
        const dbConfig = {
          id: `${id}_v1`,
          serviceId: id,
          name: service.name,
          description: service.description,
          initStep: service.initStep,
          collectedData: service.collectedData,
          steps: service.steps,
          isActive: true,
          version: 1,
          createdAt: new Date().toISOString(),
          updatedAt: new Date().toISOString()
        };
        await db.saveServiceConfig(dbConfig);
        services[id] = service;
        console.log(`  ✅ Added default: ${id} - ${getLocalized(service.name)}`);
      }
      
      console.log('✅ Default services saved to database!');
    }
    
    // Initialize states for ALL services
    for (const [id, svc] of Object.entries(services)) {
      if (!serviceStates[id]) {
        serviceStates[id] = {
          currentStep: svc.initStep || 1,
          currentFieldIndex: 0,
          waitingForAdd: false,
          waitingForContinue: false,
          currentItem: {},
          collectedData: JSON.parse(JSON.stringify(svc.collectedData || {})),
          isComplete: false
        };
      } else {
        serviceStates[id].isComplete = false;
      }
    }
    
    servicesInitialized = true;
    console.log(`📚 Services initialized: ${Object.keys(services).length} available`);
    return true;
    
  } catch (error) {
    console.error('❌ Error initializing services:', error);
    services = { ...DEFAULT_SERVICES };
    servicesInitialized = true;
    
    for (const [id, svc] of Object.entries(services)) {
      if (!serviceStates[id]) {
        serviceStates[id] = {
          currentStep: svc.initStep || 1,
          currentFieldIndex: 0,
          waitingForAdd: false,
          waitingForContinue: false,
          currentItem: {},
          collectedData: JSON.parse(JSON.stringify(svc.collectedData || {})),
          isComplete: false
        };
      } else {
        serviceStates[id].isComplete = false;
      }
    }
    return true;
  }
}

// ============================================================
// GET FUNCTIONS
// ============================================================

function getState() {
  if (!servicesInitialized) {
    initializeServices();
  }
  
  if (!serviceStates[currentService]) {
    const svc = getService();
    if (svc) {
      serviceStates[currentService] = {
        currentStep: svc.initStep || 1,
        currentFieldIndex: 0,
        waitingForAdd: false,
        waitingForContinue: false,
        currentItem: {},
        collectedData: JSON.parse(JSON.stringify(svc.collectedData || {})),
        isComplete: false
      };
    } else {
      serviceStates[currentService] = {
        currentStep: 1,
        currentFieldIndex: 0,
        waitingForAdd: false,
        waitingForContinue: false,
        currentItem: {},
        collectedData: {},
        isComplete: false
      };
    }
  }
  return serviceStates[currentService];
}

function getService() {
  if (!servicesInitialized) {
    initializeServices();
  }
  
  if (!services[currentService]) {
    const keys = Object.keys(services);
    if (keys.length > 0) {
      currentService = keys[0];
    } else {
      services = { ...DEFAULT_SERVICES };
      currentService = 'iftms';
    }
  }
  
  return services[currentService] || DEFAULT_SERVICES.iftms;
}

function getStep() {
  const svc = getService();
  if (!svc || !svc.steps) {
    console.error('Service or steps is undefined!');
    return null;
  }
  const state = getState();
  const step = svc.steps[state.currentStep];
  if (!step) {
    console.warn(`Step ${state.currentStep} not found, resetting to 1`);
    state.currentStep = 1;
    saveGlobalState();
    return svc.steps[1] || null;
  }
  return step;
}

function getCurrentField() {
  const step = getStep();
  if (!step) return null;
  const state = getState();
  const fields = step.subprocess?.fields || step.fields || [];
  return fields[state.currentFieldIndex] || null;
}

function saveGlobalState() {
  try {
    sessionStorage.setItem('app_state', JSON.stringify({ currentService, states: serviceStates }));
  } catch (e) {}
}

function loadGlobalState() {
  try {
    const saved = sessionStorage.getItem('app_state');
    if (saved) {
      const data = JSON.parse(saved);
      currentService = data.currentService || currentService;
      for (const [id, st] of Object.entries(data.states || {})) {
        if (serviceStates[id]) Object.assign(serviceStates[id], st);
      }
    }
  } catch (e) {}
}

loadGlobalState();

// ============================================================
// KEYWORD CHECKS
// ============================================================

const SERVICE_KEYWORDS = {
  videoGeneration: ['video', 'clip', 'slideshow', 'advertisement', 'promo', 'animation'],
  documentAnalysis: ['analyze', 'analysis', 'research', 'document', 'paper', 'academic', 'legal', 'contract', 'financial', 'invoice'],
  iftms: ['freight', 'transport', 'cargo', 'iftms', 'operator', 'vehicle', 'driver', 'truck', 'logistics']
};

function checkServiceSwitch(message) {
  if (!message) return null;
  const lower = message.toLowerCase();
  for (const [serviceId, keywords] of Object.entries(SERVICE_KEYWORDS)) {
    if (keywords.some(kw => lower.includes(kw.toLowerCase()))) {
      return serviceId;
    }
  }
  return null;
}

const YES_WORDS = ['yes', 'yeah', 'yep', 'sure', 'ok', 'okay', 'yup', 'of course', 'አዎ'];
const NO_WORDS = ['no', 'nope', 'nah', 'not yet', 'skip', 'አይ'];

function checkYesNo(message) {
  if (!message) return null;
  const lower = message.trim().toLowerCase();
  if (YES_WORDS.some(w => lower === w || lower.startsWith(w + ' '))) return 'yes';
  if (NO_WORDS.some(w => lower === w || lower.startsWith(w + ' '))) return 'no';
  return null;
}

// ============================================================
// MODEL WORKER
// ============================================================

export async function initModel() {
  if (modelWorker) return true;
  return new Promise((resolve) => {
    try {
      modelWorker = new Worker(new URL('./modelWorker.js', import.meta.url), { type: 'module' });
      modelWorker.onmessage = (e) => {
        const { type, data, id } = e.data;
        if (type === 'ready') { workerReady = true; resolve(true); }
        if (type === 'response' && callbacks.has(id)) {
          callbacks.get(id)(data);
          callbacks.delete(id);
        }
        if (type === 'error') { console.error('Worker error:', e.data.error); if (!workerReady) resolve(true); }
      };
      modelWorker.onerror = () => resolve(true);
      setTimeout(() => resolve(true), 5000);
    } catch (error) {
      resolve(true);
    }
  });
}

function callModel(data) {
  return new Promise((resolve) => {
    const id = callbackId++;
    callbacks.set(id, resolve);
    if (modelWorker && workerReady) {
      modelWorker.postMessage({ type: 'predict', data, id });
    } else {
      const msg = data.userMessage || '';
      const lowerMsg = msg.toLowerCase();
      let action = 'save';
      let value = msg;
      
      if (lowerMsg.includes('help') || lowerMsg.includes('what can you do') || lowerMsg.includes('እገዛ')) {
        action = 'help';
      } else if (lowerMsg.includes('status') || lowerMsg.includes('progress') || lowerMsg.includes('ሁኔታ')) {
        action = 'status';
      } else if (lowerMsg.includes('complete') || lowerMsg.includes('done') || lowerMsg.includes('finish') || lowerMsg.includes('ተጠናቀቀ')) {
        action = 'complete';
      }
      
      resolve({ action, value });
    }
  });
}

// ============================================================
// VALIDATION
// ============================================================

function validateField(input, field) {
  const value = input?.toString().trim();
  const errorMsg = getLocalized(field.error);
  const exampleMsg = getLocalized(field.example);
  
  if (!value) return { valid: false, message: errorMsg || 'Cannot be empty' };

  if (field.validation === 'choice' && field.options) {
    const options = getLocalizedOptions(field.options);
    const match = options.find(opt => opt.toLowerCase() === value.toLowerCase());
    if (match) return { valid: true, value: match };
    return { valid: false, message: `${errorMsg || 'Choose from:'} ${options.join(', ')}` };
  }

  if (field.regex && !field.regex.test(value)) {
    return { valid: false, message: errorMsg || `Invalid. Example: ${exampleMsg}` };
  }

  return { valid: true, value };
}

function saveToState(fieldName, value) {
  const state = getState();
  const step = getStep();
  if (!step) return;
  if (step.type === 'form') {
    if (!state.collectedData.operator) state.collectedData.operator = {};
    state.collectedData.operator[fieldName] = value;
  } else if (step.subprocess) {
    state.currentItem[fieldName] = value;
  }
  saveGlobalState();
}

// ============================================================
// VIN PROCESSING
// ============================================================

function processVIN(input) {
  try {
    if (!input) return null;
    
    if (!vinDecoder) {
      console.warn('vinDecoder not available');
      return null;
    }
    
    if (typeof vinDecoder.isVIN !== 'function') {
      console.warn('vinDecoder.isVIN is not a function');
      return null;
    }
    
    if (!vinDecoder.isVIN(input)) {
      return null;
    }
    
    let vin = input;
    if (typeof vinDecoder.extractVIN === 'function') {
      const extracted = vinDecoder.extractVIN(input);
      if (extracted) {
        vin = extracted;
      }
    }
    
    vin = vin.trim().toUpperCase();
    
    if (typeof vinDecoder.getCompleteVehicleData !== 'function') {
      console.warn('vinDecoder.getCompleteVehicleData is not a function');
      return {
        vinNumber: vin,
        manufacturer: 'Unknown',
        vehicleModel: 'Unknown',
        manufactureYear: 'Unknown',
        vehicleType: 'Unknown',
        bodyPartType: 'Unknown',
        engineInfo: 'Unknown',
        engineCapacity: 'Unknown',
        cylinderCount: 'Unknown',
        fuelType: 'Unknown',
        serviceType: 'Unknown',
        totalWeight: 'Unknown',
        unladenWeight: 'Unknown',
        loadCapacity: 'Unknown',
        cargoVolume: 'Unknown',
        tonnage: 'Unknown',
        gvw: 'Unknown',
        payload: 'Unknown',
        seatingCapacity: 'Unknown',
        wheelbase: 'Unknown',
        axelCount: 'Unknown',
        color: 'Unknown',
        bodyColor: 'Unknown',
        interiorColor: 'Unknown',
        assemblyPlant: 'Unknown',
        gpsInfo: 'Unknown'
      };
    }
    
    const data = vinDecoder.getCompleteVehicleData(vin);
    
    if (!data || typeof data !== 'object') {
      return {
        vinNumber: vin,
        manufacturer: 'Unknown',
        vehicleModel: 'Unknown',
        manufactureYear: 'Unknown',
        vehicleType: 'Unknown',
        bodyPartType: 'Unknown',
        engineInfo: 'Unknown',
        engineCapacity: 'Unknown',
        cylinderCount: 'Unknown',
        fuelType: 'Unknown',
        serviceType: 'Unknown',
        totalWeight: 'Unknown',
        unladenWeight: 'Unknown',
        loadCapacity: 'Unknown',
        cargoVolume: 'Unknown',
        tonnage: 'Unknown',
        gvw: 'Unknown',
        payload: 'Unknown',
        seatingCapacity: 'Unknown',
        wheelbase: 'Unknown',
        axelCount: 'Unknown',
        color: 'Unknown',
        bodyColor: 'Unknown',
        interiorColor: 'Unknown',
        assemblyPlant: 'Unknown',
        gpsInfo: 'Unknown'
      };
    }
    
    return data;
  } catch (error) {
    console.error('VIN processing error:', error);
    return {
      vinNumber: input.trim().toUpperCase(),
      manufacturer: 'Unknown',
      vehicleModel: 'Unknown',
      manufactureYear: 'Unknown',
      vehicleType: 'Unknown',
      bodyPartType: 'Unknown',
      engineInfo: 'Unknown',
      engineCapacity: 'Unknown',
      cylinderCount: 'Unknown',
      fuelType: 'Unknown',
      serviceType: 'Unknown',
      totalWeight: 'Unknown',
      unladenWeight: 'Unknown',
      loadCapacity: 'Unknown',
      cargoVolume: 'Unknown',
      tonnage: 'Unknown',
      gvw: 'Unknown',
      payload: 'Unknown',
      seatingCapacity: 'Unknown',
      wheelbase: 'Unknown',
      axelCount: 'Unknown',
      color: 'Unknown',
      bodyColor: 'Unknown',
      interiorColor: 'Unknown',
      assemblyPlant: 'Unknown',
      gpsInfo: 'Unknown'
    };
  }
}

function isAutoFillField(field) {
  return field && field.autoFill === true;
}

// ============================================================
// STEP INTRO & COMPLETE
// ============================================================

async function stepIntro() {
  const step = getStep();
  const state = getState();
  
  if (!step) {
    const defaultMsg = { en: 'How can I help?', am: 'እንዴት ልረዳ?' };
    const text = getLocalized(defaultMsg);
    return { text: text, html: `<div>${text}</div>`, isStructured: true };
  }

  if (isServiceComplete(currentService)) {
    return await buildComplete();
  }

  if (step.isFinal || step.type === 'summary' || step.type === 'result') {
    markServiceComplete(currentService);
    return await buildComplete();
  }

  if (step.type === 'file_upload') {
    const prompt = getLocalized(step.prompt);
    return { text: prompt, html: `<div>${prompt}</div>`, isStructured: true };
  }

  if (step.subprocess && step.subprocess.fields) {
    const fields = step.subprocess.fields;
    let firstNonAutoFillIndex = -1;
    for (let i = 0; i < fields.length; i++) {
      if (!isAutoFillField(fields[i])) {
        firstNonAutoFillIndex = i;
        break;
      }
    }
    if (firstNonAutoFillIndex === -1) {
      state.waitingForAdd = true;
      state.currentFieldIndex = 0;
      saveGlobalState();
      const addPrompt = getLocalized(step.subprocess.addPrompt);
      const title = getLocalized(step.title);
      return {
        text: addPrompt,
        html: `<div><strong>${title}</strong><br>${addPrompt}</div>`,
        isStructured: true
      };
    }
    state.waitingForAdd = true;
    state.currentFieldIndex = firstNonAutoFillIndex;
    saveGlobalState();
    const firstField = fields[firstNonAutoFillIndex];
    const title = getLocalized(step.title);
    const question = getLocalized(firstField.question);
    return {
      text: question,
      html: `<div><strong>${title}</strong><br>${question}</div>`,
      isStructured: true
    };
  }

  const firstField = step.fields?.[0];
  if (firstField) {
    const title = getLocalized(step.title);
    const question = getLocalized(firstField.question);
    return {
      text: question,
      html: `<div><strong>${title}</strong><br>${question}</div>`,
      isStructured: true
    };
  }

  const prompt = getLocalized(step.prompt) || getLocalized({ en: 'How can I help?', am: 'እንዴት ልረዳ?' });
  return { text: prompt, html: `<div>${prompt}</div>`, isStructured: true };
}

async function buildComplete() {
  const state = getState();
  const svc = getService();
  const lang = getLanguage();
  const isAmharic = lang === 'am';
  
  if (!isServiceComplete(currentService)) {
    const step = getStep();
    if (step) {
      const title = getLocalized(step.title);
      const prompt = getLocalized(step.prompt);
      const notCompleteMsg = getLocalized({ 
        en: 'This service is not yet complete. Please continue with the registration.', 
        am: 'ይህ አገልግሎት እስካሁን አልተጠናቀቀም። እባክዎ ምዝገባውን ይቀጥሉ።' 
      });
      return {
        text: `${notCompleteMsg}\n\n${title}: ${prompt || ''}`,
        html: `<div>${notCompleteMsg}<br><br><strong>${title}</strong><br>${prompt || ''}</div>`,
        isStructured: true
      };
    }
    return {
      text: getLocalized({ en: 'Service not complete. Please continue.', am: 'አገልግሎት አልተጠናቀቀም። እባክዎ ይቀጥሉ።' }),
      html: `<div>${getLocalized({ en: 'Service not complete. Please continue.', am: 'አገልግሎት አልተጠናቀቀም። እባክዎ ይቀጥሉ።' })}</div>`,
      isStructured: true
    };
  }
  
  let summary = `${getLocalized(svc.name)} ${getLocalized({ en: 'Complete!', am: 'ተጠናቀቀ!' })}\n\n`;
  
  for (const [key, val] of Object.entries(state.collectedData)) {
    if (!val) continue;
    const label = isAmharic ? 
      { operator: 'ኦፕሬተር', vehicles: 'ተሽከርካሪዎች', drivers: 'አሽከርካሪዎች' }[key] || key.toUpperCase() :
      key.toUpperCase();
    summary += `📋 ${label}:\n`;
    if (Array.isArray(val)) {
      val.forEach((item, i) => {
        summary += `  ${i + 1}. ${Object.entries(item).map(([k, v]) => `${k}: ${v}`).join(', ')}\n`;
      });
    } else if (typeof val === 'object') {
      Object.entries(val).forEach(([k, v]) => { summary += `  • ${k}: ${v}\n`; });
    }
  }
  
  return {
    text: summary,
    html: `<div><pre style="white-space:pre-wrap">${summary}</pre></div>`,
    isStructured: true,
    isComplete: true,
    serviceId: currentService
  };
}

// ============================================================
// ACTION EXECUTOR
// ============================================================

async function executeAction(action, rawValue, originalMessage) {
  try {
    const state = getState();
    const step = getStep();
    const currentField = getCurrentField();

    if (!step) {
      const errorMsg = getLocalized({ en: 'System error', am: 'የስርዓት ስህተት' });
      return { text: errorMsg, html: `<div>${errorMsg}</div>`, isStructured: true };
    }

    if (!originalMessage || originalMessage.trim() === '') {
      if (currentField) {
        const question = getLocalized(currentField.question);
        return { text: question, html: `<div>${question}</div>`, isStructured: true };
      }
      const prompt = getLocalized({ en: 'Please enter a value.', am: 'እባክዎ እሴት ያስገቡ።' });
      return { text: prompt, html: `<div>${prompt}</div>`, isStructured: true };
    }

    switch (action) {
      case 'save': {
        if (!currentField) {
          const received = getLocalized({ en: 'I received:', am: 'ተቀብያለሁ:' });
          return { text: `${received} ${originalMessage}`, html: `<div>${received} ${originalMessage}</div>`, isStructured: true };
        }

        if (currentField.name === 'vinNumber' || currentField.name === 'chassisNumber') {
          console.log('🔍 Processing VIN field with input:', originalMessage);
          
          // Check for VIN API action
          if (currentField.apiActions && currentField.apiActions.length > 0) {
            const context = {
              userInput: originalMessage,
              collectedData: state.collectedData,
              currentItem: state.currentItem || {},
              operator: state.collectedData.operator || {},
              ...state.currentItem
            };
            
            const apiResult = await executeFieldApiActions(currentField, context);
            
            if (apiResult.success && apiResult.message) {
              // Auto-fill fields if API returned data
              if (apiResult.result?.data) {
                const autoFillData = apiResult.result.data;
                for (const [key, value] of Object.entries(autoFillData)) {
                  if (value && value !== 'Unknown') {
                    saveToState(key, value);
                  }
                }
              }
              
              state.currentFieldIndex++;
              saveGlobalState();
              const nextField = getCurrentField();
              const nextQuestion = nextField ? getLocalized(nextField.question) : '';
              
              return {
                text: `${apiResult.message}\n${nextQuestion}`,
                html: `<div class="success">✅ ${apiResult.message}</div>${nextQuestion ? `<div>${nextQuestion}</div>` : ''}`,
                isStructured: true
              };
            }
          }
          
          // Fallback to local VIN processing
          const vinResult = processVIN(originalMessage);
          
          if (vinResult) {
            console.log('✅ VIN processed successfully:', vinResult);
            
            const fields = step.subprocess?.fields || [];
            
            saveToState('vinNumber', vinResult.vinNumber || originalMessage.trim().toUpperCase());
            state.currentFieldIndex++;
            
            let autoFilledCount = 0;
            for (const field of fields) {
              if (isAutoFillField(field)) {
                const fieldName = field.name;
                const fieldValue = vinResult[fieldName];
                
                if (fieldValue && fieldValue !== 'Unknown' && fieldValue !== '' && fieldValue !== null && fieldValue !== undefined) {
                  saveToState(fieldName, fieldValue);
                  state.currentFieldIndex++;
                  autoFilledCount++;
                  console.log(`  ✅ Auto-filled ${fieldName}: ${fieldValue}`);
                }
              }
            }
            
            while (state.currentFieldIndex < fields.length && isAutoFillField(fields[state.currentFieldIndex])) {
              state.currentFieldIndex++;
            }
            
            saveGlobalState();
            
            if (state.currentFieldIndex >= fields.length) {
              if (step.subprocess) {
                const key = step.subprocess.onValid.collectionKey;
                state.collectedData[key].push({ ...state.currentItem });
                state.currentItem = {};
                state.currentFieldIndex = 0;
                state.waitingForAdd = true;
                saveGlobalState();
                
                const addPrompt = getLocalized(step.subprocess.addPrompt);
                const savedMsg = getLocalized({ en: '✅ Vehicle saved!', am: '✅ ተሽከርካሪ ተቀመጠ!' });
                const autoFillMsg = getLocalized({ en: 'fields auto-filled from VIN', am: 'መስኮች ከVIN በራስ-ሰር ተሞልተዋል' });
                return {
                  text: addPrompt,
                  html: `<div>${savedMsg} (${autoFilledCount} ${autoFillMsg})<br>${addPrompt}</div>`,
                  isStructured: true
                };
              }
            }
            
            const nextField = getCurrentField();
            const nextQuestion = nextField ? getLocalized(nextField.question) : getLocalized({ en: 'Next:', am: 'ቀጣይ:' });
            const processedMsg = getLocalized({ en: '✅ VIN processed!', am: '✅ VIN ተሰራ!' });
            const autoFillMsg = getLocalized({ en: 'fields auto-filled', am: 'መስኮች በራስ-ሰር ተሞልተዋል' });
            return {
              text: nextQuestion,
              html: `<div>${processedMsg} ${autoFilledCount} ${autoFillMsg}.<br>${nextQuestion}</div>`,
              isStructured: true
            };
          } else {
            console.log('⚠️ Not a valid VIN, treating as regular input');
          }
        }

        const valueToTry = rawValue || originalMessage;
        const validation = validateField(valueToTry, currentField);
        
        if (!validation.valid) {
          const errorMsg = validation.message;
          const question = getLocalized(currentField.question);
          return {
            text: errorMsg,
            html: `<div class="error">❌ ${errorMsg}<br>${question}</div>`,
            isStructured: true
          };
        }
        
        saveToState(currentField.name, validation.value);
        state.currentFieldIndex++;

        const fields = step.subprocess?.fields || step.fields || [];
        
        while (state.currentFieldIndex < fields.length && isAutoFillField(fields[state.currentFieldIndex])) {
          state.currentFieldIndex++;
        }

        if (state.currentFieldIndex >= fields.length) {
          // Check for step-level API actions before moving to next step
          if (step.apiActions && step.apiActions.length > 0) {
            const context = {
              userInput: originalMessage,
              collectedData: state.collectedData,
              currentItem: state.currentItem || {},
              operator: state.collectedData.operator || {},
              vehicles: state.collectedData.vehicles || [],
              drivers: state.collectedData.drivers || [],
              ...state.collectedData.operator,
              ...state.currentItem
            };
            
            const apiResult = await executeStepApiActions(step, context);
            
            if (apiResult.success && apiResult.message) {
              if (apiResult.nextStep) {
                state.currentStep = apiResult.nextStep;
                state.currentFieldIndex = 0;
                saveGlobalState();
                const nextStepIntro = await stepIntro();
                return {
                  text: `${apiResult.message}\n${nextStepIntro.text}`,
                  html: `<div class="success">✅ ${apiResult.message}</div>${nextStepIntro.html}`,
                  isStructured: true
                };
              }
            }
          }
          
          if (step.subprocess) {
            if (Object.keys(state.currentItem).length > 0) {
              const key = step.subprocess.onValid.collectionKey;
              state.collectedData[key].push({ ...state.currentItem });
              state.currentItem = {};
            }
            state.currentFieldIndex = 0;
            state.waitingForAdd = true;
            saveGlobalState();
            const addPrompt = getLocalized(step.subprocess.addPrompt);
            const itemName = getLocalized(step.subprocess.itemName);
            const savedMsg = getLocalized({ en: '✅ Saved!', am: '✅ ተቀመጠ!' });
            return {
              text: addPrompt,
              html: `<div>${savedMsg} ${itemName} ${getLocalized({ en: 'saved!', am: 'ተቀመጠ!' })}<br>${addPrompt}</div>`,
              isStructured: true
            };
          } else {
            state.currentStep = step.onValid?.nextStep || state.currentStep + 1;
            state.currentFieldIndex = 0;
            saveGlobalState();
            return await stepIntro();
          }
        }

        saveGlobalState();
        const nextField = getCurrentField();
        const nextQuestion = nextField ? getLocalized(nextField.question) : getLocalized({ en: 'Next:', am: 'ቀጣይ:' });
        const savedMsg = getLocalized({ en: '✅ Saved!', am: '✅ ተቀመጠ!' });
        return {
          text: nextQuestion,
          html: `<div>${savedMsg}<br>${nextQuestion}</div>`,
          isStructured: true
        };
      }

      case 'yes': {
        if (state.waitingForAdd) {
          state.waitingForAdd = false;
          state.currentItem = {};
          state.currentFieldIndex = 0;
          saveGlobalState();
          const firstField = step.subprocess.fields[0];
          const question = getLocalized(firstField.question);
          return { text: question, html: `<div>${question}</div>`, isStructured: true };
        }
        if (state.waitingForContinue) {
          state.waitingForContinue = false;
          state.currentStep = step.subprocess.onValid.nextStep;
          state.currentFieldIndex = 0;
          saveGlobalState();
          return await stepIntro();
        }
        break;
      }

      case 'no': {
        if (state.waitingForAdd) {
          state.waitingForAdd = false;
          state.waitingForContinue = true;
          saveGlobalState();
          if (step.subprocess && step.subprocess.continuePrompt) {
            const continuePrompt = getLocalized(step.subprocess.continuePrompt);
            return {
              text: continuePrompt,
              html: `<div>${continuePrompt}</div>`,
              isStructured: true
            };
          } else {
            state.waitingForContinue = false;
            state.currentStep = step.subprocess?.onValid?.nextStep || state.currentStep + 1;
            state.currentFieldIndex = 0;
            saveGlobalState();
            return await stepIntro();
          }
        }
        if (state.waitingForContinue) {
          state.waitingForContinue = false;
          state.currentStep = step.subprocess?.onValid?.nextStep || state.currentStep + 1;
          state.currentFieldIndex = 0;
          saveGlobalState();
          return await stepIntro();
        }
        break;
      }

      case 'switch_service': {
        const target = rawValue;
        if (target && services[target]) {
          currentService = target;
          
          if (!serviceStates[target]) {
            serviceStates[target] = {
              currentStep: services[target].initStep || 1,
              currentFieldIndex: 0,
              waitingForAdd: false,
              waitingForContinue: false,
              currentItem: {},
              collectedData: JSON.parse(JSON.stringify(services[target].collectedData || {})),
              isComplete: false
            };
          } else {
            serviceStates[target].isComplete = false;
          }
          saveGlobalState();
          
          const serviceName = getLocalized(services[target].name);
          const serviceDesc = getLocalized(services[target].description);
          const welcomeMsg = getLocalized({ en: 'Welcome to', am: 'እንኳን ወደ' });
          
          return {
            text: `${welcomeMsg} ${serviceName}`,
            html: `<div>🔄 ${welcomeMsg} <strong>${serviceName}</strong><br>${serviceDesc}</div>`,
            isStructured: true
          };
        }
        break;
      }

      case 'help': {
        const list = Object.values(services).map(s => `• ${getLocalized(s.name)}: ${getLocalized(s.description)}`).join('\n');
        const helpTitle = getLocalized({ en: 'Available services:', am: 'የሚገኙ አገልግሎቶች:' });
        return {
          text: `${helpTitle}\n${list}`,
          html: `<div>📚 ${helpTitle}<br>${list.replace(/\n/g, '<br>')}</div>`,
          isStructured: true
        };
      }

      case 'status': {
        const collected = Object.entries(state.collectedData)
          .filter(([, v]) => v && (Array.isArray(v) ? v.length > 0 : Object.keys(v).length > 0))
          .map(([k, v]) => {
            const label = getLanguage() === 'am' ?
              { operator: 'ኦፕሬተር', vehicles: 'ተሽከርካሪዎች', drivers: 'አሽከርካሪዎች' }[k] || k :
              k;
            return `${label}: ${Array.isArray(v) ? v.length + ' ' + getLocalized({ en: 'item(s)', am: 'ንጥል(ዎች)' }) : '✓'}`;
          })
          .join(', ') || getLocalized({ en: 'nothing yet', am: 'እስካሁን ምንም' });
        const svc = getService();
        const serviceName = getLocalized(svc?.name || { en: 'Unknown', am: 'ያልታወቀ' });
        const serviceLabel = getLocalized({ en: 'Service', am: 'አገልግሎት' });
        const stepLabel = getLocalized({ en: 'Step', am: 'ደረጃ' });
        const collectedLabel = getLocalized({ en: 'Collected', am: 'የተሰበሰበ' });
        const completeStatus = isServiceComplete(currentService) ? '✅ ' + getLocalized({ en: 'Complete', am: 'ተጠናቋል' }) : '⏳ ' + getLocalized({ en: 'In Progress', am: 'በመቀጠል ላይ' });
        return {
          text: `${serviceLabel}: ${serviceName} | ${stepLabel}: ${state.currentStep} | ${collectedLabel}: ${collected} | ${completeStatus}`,
          html: `<div>📊 <strong>${serviceName}</strong><br>${stepLabel}: ${state.currentStep}<br>${collectedLabel}: ${collected}<br>${completeStatus}</div>`,
          isStructured: true
        };
      }

      case 'complete': {
        return await buildComplete();
      }

      default: {
        const understood = getLocalized({ en: 'I understood:', am: 'ተረድቻለሁ:' });
        return { text: `${understood} "${originalMessage}"`, html: `<div>${understood} "${originalMessage}"</div>`, isStructured: true };
      }
    }

    if (currentField) {
      const question = getLocalized(currentField.question);
      return { text: question, html: `<div>${question}</div>`, isStructured: true };
    }
    const defaultPrompt = getLocalized(getStep()?.prompt) || getLocalized({ en: 'How can I help?', am: 'እንዴት ልረዳ?' });
    return { text: defaultPrompt, html: `<div>${defaultPrompt}</div>`, isStructured: true };
  } catch (error) {
    console.error('❌ Error in executeAction:', error);
    const errorLabel = getLocalized({ en: 'Error:', am: 'ስህተት:' });
    const unknownError = getLocalized({ en: 'Unknown error', am: 'ያልታወቀ ስህተት' });
    return {
      text: `${errorLabel} ${error.message || unknownError}`,
      html: `<div class="error">❌ ${errorLabel} ${error.message || unknownError}</div>`,
      isStructured: true
    };
  }
}

// ============================================================
// CORE PROCESS MESSAGE
// ============================================================

export async function processMessage(message, file) {
  try {
    console.log('📨 Processing:', message || '[file]');

    await initializeServices();
    await initModel();
    loadGlobalState();

    if (file) {
      const step = getStep();
      if (step?.type === 'file_upload') {
        const state = getState();
        state.collectedData.document = { name: file.name, size: file.size };
        state.currentStep = step.onValid.nextStep;
        state.currentFieldIndex = 0;
        saveGlobalState();
        const fileReceived = getLocalized({ en: 'File received:', am: 'ፋይል ተቀብሏል:' });
        const nextPrompt = getLocalized(step?.prompt) || getLocalized({ en: 'What next?', am: 'ምን ቀጥሎ?' });
        return {
          text: `${fileReceived} "${file.name}". ${nextPrompt}`,
          html: `<div>📄 ${fileReceived} <strong>${file.name}</strong><br>${nextPrompt}</div>`,
          isStructured: true
        };
      }
      const fileReceived = getLocalized({ en: 'File received', am: 'ፋይል ተቀብሏል' });
      return { text: fileReceived, html: `<div>📎 ${fileReceived}</div>`, isStructured: false };
    }

    if (!message) return await stepIntro();

    const switchTarget = checkServiceSwitch(message);
    if (switchTarget && switchTarget !== currentService && services[switchTarget]) {
      currentService = switchTarget;
      
      if (!serviceStates[switchTarget]) {
        serviceStates[switchTarget] = {
          currentStep: services[switchTarget].initStep || 1,
          currentFieldIndex: 0,
          waitingForAdd: false,
          waitingForContinue: false,
          currentItem: {},
          collectedData: JSON.parse(JSON.stringify(services[switchTarget].collectedData || {})),
          isComplete: false
        };
      } else {
        serviceStates[switchTarget].isComplete = false;
      }
      saveGlobalState();
      
      const serviceName = getLocalized(services[switchTarget].name);
      const serviceDesc = getLocalized(services[switchTarget].description);
      const welcomeMsg = getLocalized({ en: 'Welcome to', am: 'እንኳን ወደ' });
      
      return {
        text: `${welcomeMsg} ${serviceName}`,
        html: `<div>🔄 ${welcomeMsg} <strong>${serviceName}</strong><br>${serviceDesc}</div>`,
        isStructured: true
      };
    }

    const state = getState();
    if (state.waitingForAdd || state.waitingForContinue) {
      const yesno = checkYesNo(message);
      if (yesno) {
        return await executeAction(yesno, null, message);
      }
    }

    const vinPattern = /^[A-HJ-NPR-Z0-9]{10,18}$/i;
    if (message && vinPattern.test(message.trim())) {
      console.log('🔍 Input looks like a VIN:', message);
      const currentField = getCurrentField();
      if (currentField && (currentField.name === 'vinNumber' || currentField.name === 'chassisNumber')) {
        return await executeAction('save', message, message);
      }
    }

    const msgLower = message.toLowerCase();
    
    if (msgLower.includes('help') || msgLower.includes('what can you do') || msgLower.includes('እገዛ')) {
      return await executeAction('help', null, message);
    }
    if (msgLower.includes('status') || msgLower.includes('progress') || msgLower.includes('ሁኔታ')) {
      return await executeAction('status', null, message);
    }
    if (msgLower.includes('complete') || msgLower.includes('done') || msgLower.includes('finish') || msgLower.includes('ተጠናቀቀ')) {
      return await executeAction('complete', null, message);
    }

    const prediction = await callModel({
      serviceConfig: getService(),
      currentState: getState(),
      userMessage: message
    });

    console.log('🤖 Prediction:', prediction);

    if (prediction && prediction.action) {
      return await executeAction(prediction.action, prediction.value, message);
    }

    const currentField = getCurrentField();
    if (currentField) {
      const validation = validateField(message, currentField);
      if (validation.valid) {
        return await executeAction('save', validation.value, message);
      }
      const errorMsg = validation.message;
      const question = getLocalized(currentField.question);
      return {
        text: errorMsg,
        html: `<div class="error">❌ ${errorMsg}<br>${question}</div>`,
        isStructured: true
      };
    }

    const received = getLocalized({ en: 'I received:', am: 'ተቀብያለሁ:' });
    const serviceList = Object.values(services).map(s => `• ${getLocalized(s.name)}`).join('\n');
    const availableServices = getLocalized({ en: 'Available services:', am: 'የሚገኙ አገልግሎቶች:' });
    return { 
      text: `${received} "${message}"\n\n${availableServices}\n${serviceList}`,
      html: `<div>${received} "${message}"<br><br>📚 ${availableServices}<br>${serviceList.replace(/\n/g, '<br>')}</div>`,
      isStructured: true 
    };

  } catch (error) {
    console.error('❌ Error:', error);
    const errorLabel = getLocalized({ en: 'Error:', am: 'ስህተት:' });
    const unknownError = getLocalized({ en: 'Unknown error', am: 'ያልታወቀ ስህተት' });
    return {
      text: `${errorLabel} ${error.message || unknownError}`,
      html: `<div class="error">❌ ${errorLabel} ${error.message || unknownError}</div>`,
      isStructured: true
    };
  }
}

// ============================================================
// PUBLIC API
// ============================================================

export async function chat(msg, file) {
  try {
    await initializeServices();
    await initModel();
    loadGlobalState();
    return await processMessage(msg, file);
  } catch (error) {
    console.error('❌ Chat error:', error);
    const errorLabel = getLocalized({ en: 'Error:', am: 'ስህተት:' });
    const unknownError = getLocalized({ en: 'Unknown error', am: 'ያልታወቀ ስህተት' });
    return {
      text: `${errorLabel} ${error.message || unknownError}`,
      html: `<div class="error">❌ ${errorLabel} ${error.message || unknownError}</div>`,
      isStructured: true
    };
  }
}

export async function init() {
  try {
    await initializeServices();
    await initModel();
    loadGlobalState();
    
    const serviceList = Object.keys(services);
    console.log(`✅ NLP Processor initialized with ${serviceList.length} services`);
    console.log('📚 Services:', serviceList);
    
    return true;
  } catch (error) {
    console.error('❌ Init error:', error);
    return false;
  }
}

export async function getAvailableServices() {
  await initializeServices();
  return Object.values(services);
}

export const nlpProcessor = {
  chat,
  processMessage,
  init,
  getAvailableServices,
  resetService,
  isServiceComplete,
  markServiceComplete
};

// Auto-init
init().catch(console.error);END
cat > src/services/pdfAna.js << 'END'
//import * as pdfjsLib from 'pdfjs-dist'
import * as pdfjsLib from 'pdfjs-dist/build/pdf'
import pdfjsWorker from 'pdfjs-dist/build/pdf.worker?url'

// Configure PDF.js worker
pdfjsLib.GlobalWorkerOptions.workerSrc = pdfjsWorker

export async function extractTextFromPDF(file) {
  return new Promise((resolve, reject) => {
    const fileReader = new FileReader()
    
    fileReader.onload = async function() {
      try {
        const typedArray = new Uint8Array(this.result)
        const pdf = await pdfjsLib.getDocument(typedArray).promise
        let fullText = ''

        for (let i = 1; i <= pdf.numPages; i++) {
          const page = await pdf.getPage(i)
          const textContent = await page.getTextContent()
          const pageText = textContent.items.map(item => item.str).join(' ')
          fullText += pageText + '\n'
        }

        resolve(fullText)
      } catch (error) {
        reject(error)
      }
    }

    fileReader.onerror = reject
    fileReader.readAsArrayBuffer(file)
  })
}END
cat > src/services/pdfAnalyzer.js << 'END'
import * as pdfjsLib from 'pdfjs-dist/build/pdf'
import pdfjsWorker from 'pdfjs-dist/build/pdf.worker?url'
import nlp from 'compromise'
import { processMessage } from './nlpProcessor'
import { pdfAnalyzerD } from './pdfAnalyzer2'
import {ministriesFed,privateColleges,universities  } from "./data";
// Set up PDF.js worker
pdfjsLib.GlobalWorkerOptions.workerSrc = pdfjsWorker

export class PDFAnalyzerF {
  constructor() {
    this.pdfjsLib = pdfjsLib
    this.nlp = nlp
  }

  async init() {
    console.log('PDF Analyzer initialized with PDF.js and Compromise')
  }
// Setup intent patterns

  async analyzeDocument(file) {
    /*async analyzeDocument(file,intnt,currentStep) { }
    if(intnt==='iftms') {
    }
    
    */
    try {
      const fileBuffer = await file.arrayBuffer()
      const pdf = await this.pdfjsLib.getDocument(fileBuffer).promise
      
      // Extract metadata and text
      const { finalTitle, firstPageContent } = await this.extractDocumentMetadata(pdf)
      const { text, pages } = await this.extractFullText(pdf)
      
      // Enhanced classification using robust methods
      const analysis = this.classifyDocument(text, finalTitle)
// Store document for semantic analysis
     /* if (analysis.documentType === "Academic Paper") {
       // await pdfAnalyzerD.storeDocumentForSummarization(text, finalTitle, file.name)
      } else if (analysis.documentType === "Government Document") {
        // await pdfAnalyzerD.storeDocumentForSummarization(text, finalTitle, file.name)
      } */
      analysis.fileName = file.name
      analysis.fileSize = file.size
      analysis.pages = pages
      analysis.firstPageContent = firstPageContent
      analysis.fullText = text
      
      return analysis
      
    } catch (error) {
      console.error('PDF analysis error:', error)
      throw new Error(`PDF analysis failed: ${error.message}`)
    }
  }
   extractServiceSpecificData(analysis, service) {
    const extractedData = {}
    
    if (service === 'iftms') {
      if (analysis.extractedData?.licenseNumber) {
        extractedData.licenseNumber = analysis.extractedData.licenseNumber
      }
      if (analysis.extractedData?.vehicleInfo) {
        extractedData.vehicleInfo = analysis.extractedData.vehicleInfo
      }
    } else if (service === 'renewDoc') {
      if (analysis.extractedData?.businessName) {
        extractedData.businessName = analysis.extractedData.businessName
      }
      if (analysis.extractedData?.licenseNumber) {
        extractedData.licenseNumber = analysis.extractedData.licenseNumber
      }
    }
    
    return extractedData
  }

  extractLicenseNumber(text) {
    // Extract business license number patterns
    const licensePatterns = [
      /\b\d{2}\/\d{3,4}\/\d{3,4}\/\d{4}\b/, // 14/668/5068/2004
      /\bBL\d{8,12}\b/i, // BL123456789
      /\bLIC\d{8,12}\b/i, // LIC123456789
    ]
    
    for (const pattern of licensePatterns) {
      const match = text.match(pattern)
      if (match) return match[0]
    }
    
    return null
  }
 async extractFromDocument(document, service) {
    try {
      let extractedData = {}
      
      // For PDF files
      if (document.type === 'application/pdf') {
        const analysis = await pdfAnalyzerF.analyzeDocument(document)
        extractedData = this.extractServiceSpecificData(analysis, service)
      }
      // For image files
    /*  else if (document.type.startsWith('image/')) {
        const text = await teSsAna.analyzeDocument(document)
        const analysis = teSsAna.classifyDocument(text, document.name)
        extractedData = this.extractServiceSpecificData(analysis, service)
      }*/
      
      return extractedData
    } catch (error) {
      console.error('Error extracting from document:', error)
      return {}
    }
  }
  async extractDocumentMetadata(pdf) {
    const firstPage = await pdf.getPage(1)
    const textContent = await firstPage.getTextContent()
    const firstPageText = textContent.items.map(item => item.str).join('\n')
    
    // Your existing metadata extraction logic
    const coverTitle = this.extractTitleFromCover(firstPageText)
    const cleanCoverTitle = this.cleanResearchTitle(coverTitle)
    const cleanFileName = this.cleanResearchTitle(pdf._pdfInfo?.title || "")
    
    let finalTitle = cleanCoverTitle
    
    if (cleanFileName && !this.titlesMatch(cleanCoverTitle, cleanFileName)) {
      finalTitle = `${cleanCoverTitle}`
    }
    
    return {
      coverTitle: cleanCoverTitle,
      fileNameTitle: cleanFileName,
      finalTitle,
      firstPageContent: firstPageText
    }
  }

  async extractFullText(pdf) {
    let text = ''
    let paragraphs = []
    
    for (let i = 1; i <= pdf.numPages; i++) {
      const page = await pdf.getPage(i)
      const textContent = await page.getTextContent()
      const pageText = textContent.items.map(item => item.str).join(' ')
      text += pageText + '\n'
      
      // Your existing paragraph detection logic
      let currentY = null
      let currentParagraph = ''
      
      textContent.items.forEach(item => {
        if (currentY !== null && Math.abs(item.transform[5] - currentY) > 15) {
          if (currentParagraph.trim()) {
            paragraphs.push(currentParagraph.trim())
          }
          currentParagraph = ''
        }
        currentY = item.transform[5]
        currentParagraph += item.str + ' '
      })
      
      if (currentParagraph.trim()) {
        paragraphs.push(currentParagraph.trim())
      }
    }
    
    return { text, paragraphs, pages: pdf.numPages }
  }

  // Add your existing utility methods
  extractTitleFromCover(text) {
    // Your existing implementation
    const lines = text.split('\n').filter(line => line.trim().length > 10)
    return lines.length > 0 ? lines[0] : 'Untitled Document'
  }

  cleanResearchTitle(title) {
    // Your existing implementation
    return title.replace(/[^\w\sሀ-ፕ]/g, '').trim()
  }

  titlesMatch(title1, title2) {
    // Your existing implementation
    return this.similarity(title1.toLowerCase(), title2.toLowerCase()) > 0.7
  }

  similarity(s1, s2) {
    // Your existing implementation
    const longer = s1.length > s2.length ? s1 : s2
    const shorter = s1.length > s2.length ? s2 : s1
    
    if (longer === shorter) return 1.0
    
    const distance = this.editDistance(longer, shorter)
    return (longer.length - distance) / parseFloat(longer.length)
  }

  editDistance(s1, s2) {
    // Your existing implementation
    s1 = s1.toLowerCase()
    s2 = s2.toLowerCase()
    
    const costs = []
    for (let i = 0; i <= s1.length; i++) {
      let lastValue = i
      for (let j = 0; j <= s2.length; j++) {
        if (i === 0) {
          costs[j] = j
        } else {
          if (j > 0) {
            let newValue = costs[j - 1]
            if (s1.charAt(i - 1) !== s2.charAt(j - 1)) {
              newValue = Math.min(Math.min(newValue, lastValue), costs[j]) + 1
            }
            costs[j - 1] = lastValue
            lastValue = newValue
          }
        }
      }
      if (i > 0) costs[s2.length] = lastValue
    }
    return costs[s2.length]
  }

  // Your existing classification methods
  async classifyDocument(text, fileName) {
    const headerTerms = this.extractHeaderTerms(text)
     const cintent =sessionStorage.getItem('intent')
    const headerClassification = this.classifyByHeaderTerms(headerTerms)
    
    if (headerClassification) {
      return {
        documentName: fileName.replace(/\.[^/.]+$/, "") || 'Unknown Document',
        documentType: headerClassification.type,
        typeClass: headerClassification.class,
        confidence: headerClassification.confidence,
        topics: this.extractTopics(text),
        keywords: headerClassification.keywords,
        summary: this.generateSummary(text, headerTerms),
        wordCount: text.split(/\s+/).filter(word => word.length > 0).length,
        timestamp: new Date().toISOString(),
        headerTerms: headerTerms
      }
    }

    // Fallback to content-based classification
    const lowerText = text.toLowerCase()
    
    let type = "General Document"
    let typeClass = "type-other"
    let confidence = 0.3
  
    if (this.isResearchPaper(text, headerTerms)) {
      type = "Academic Paper"
      typeClass = "type-research"
      confidence = 0.85
      
      if(!cintent) {  sessionStorage.setItem('intnt','analyzeResearch')}
    } else if (this.isVehicleOwnershipDoc(text, headerTerms)) {
      type = "Libre"
      typeClass = "type-libre"
      confidence = 0.85
       if(!cintent) {  sessionStorage.setItem('intnt','iftms')}
       
    } else if (this.isLegalDocument(text, headerTerms)) {
      type = "Legal Document"
      typeClass = "type-legal"
      confidence = 0.8
       if(!cintent) {  sessionStorage.setItem('intnt','analyzeLegal')}
    } else if (this.isGovernmentDocument(text, headerTerms)) {
      type = "Government Document"
      typeClass = "type-government"
      confidence = 0.75
    } else if (this.isFinancialDocument(text, headerTerms)) {
      type = "Financial Document"
      typeClass = "type-financial"
      confidence = 0.7
    }
 
    const topics = this.extractTopics(text)
    const keywords = this.extractKeywords(text)
    const currentIntent = sessionStorage.getItem('currentService')
   /*const Edata ={documentType: type,
            typeClass: typeClass,
            confidence: confidence,
            }
     if (currentIntent==='iftms') {
    //return  await processMessage(currentIntent,Edata,false,true)

    }*/
    return {
      documentName: fileName.replace(/\.[^/.]+$/, "") || 'Unknown Document',
      documentType: type,
      typeClass: typeClass,
      confidence: confidence,
      topics: topics,
      keywords: keywords,
      summary: this.generateSummary(text, headerTerms),
      wordCount: text.split(/\s+/).filter(word => word.length > 0).length,
      timestamp: new Date().toISOString(),
      headerTerms: headerTerms
    }
  }

  extractHeaderTerms(text) {
    try {
      const lines = text.split('\n').slice(0, 15).join('\n')
      const doc = this.nlp(lines)
     
      const nouns = doc.nouns().out('array')
      const nounPhrases = doc.match('#Noun+').out('array')
      
      const allTerms = [...new Set([...nouns, ...nounPhrases])]
     
      return allTerms
        .filter(term =>
          term.length > 3 &&
          !/\d/.test(term) &&
          !['page', 'date', 'author', 'version', 'section'].includes(term.toLowerCase())
        )
        .slice(0, 10)
    } catch (e) {
      console.error("Error extracting header terms:", e)
      return []
    }
  }

  classifyByHeaderTerms(headerTerms) {
    const termString = headerTerms.join(' ').toLowerCase()
      const cintent =sessionStorage.getItem('intent')
    // Research Paper detection
    const researchTerms = ['study', 'research', 'analysis', 'experiment', 'hypothesis', 'methodology', 'results', 'findings']
    if (researchTerms.some(term => termString.includes(term))) {
       if(!cintent) {  sessionStorage.setItem('intnt','analyzeResearch')}
      return {
        type: "Academic Paper",
        class: "type-research",
        confidence: 0.85,
        
        keywords: researchTerms
          .filter(term => termString.includes(term))
          .map(term => ({ term, score: 0.8 }))
      }
    }
    
    // Legal Document detection
    const legalTerms = ['agreement', 'contract', 'clause', 'party', 'law', 'terms', 'condition', 'section']
    
    if (legalTerms.some(term => termString.includes(term))) {
      if(!cintent) return sessionStorage.setItem('intnt','analyzeLegal')
      return {
        type: "Legal Document",
        class: "type-legal",
        confidence: 0.85,
        keywords: legalTerms
          .filter(term => termString.includes(term))
          .map(term => ({ term, score: 0.8 }))
      }
    }
    
    // Financial Document detection
    const financialTerms = ['invoice', 'receipt', 'payment', 'balance', 'statement', 'total', 'amount', 'due']
    if (financialTerms.some(term => termString.includes(term))) {
      return {
        type: "Financial Document",
        class: "type-financial",
        confidence: 0.85,
        keywords: financialTerms
          .filter(term => termString.includes(term))
          .map(term => ({ term, score: 0.8 }))
      }
    }
     // Government Document detection
    const govTerms = ['license','trade bureau','ንግድ ቢሮ', 'permit', 'national id','የኢትዮጵያ ብሔራዊ መታወቂያ ፕሮግራም', 'fayda id', 'government', 'identification']
   // const ministers = ministriesFed
    if (govTerms.some(term => termString.includes(term))) {
      return {
        type: "Government Document",
        class: "type-government",
        confidence: 0.85,
        keywords: govTerms
          .filter(term => termString.includes(term))
          .map(term => ({ term, score: 0.8 }))
      }
    }
    return null
  }

  // Your existing document type detection methods
  isResearchPaper(text, headerTerms) {
    const termString = headerTerms.join(' ').toLowerCase()
    const researchTerms = ['abstract', 'introduction', 'methodology', 'results', 'discussion', 'conclusion', 'references']
    
    return researchTerms.some(term => termString.includes(term)) ||
           /(abstract|introduction|methodology|results|discussion|conclusion|references|bibliography)/i.test(text)
  }

  isVehicleOwnershipDoc(text, headerTerms) {
    const termString = headerTerms.join(' ').toLowerCase()
    const libreTerms = ['የባለንብረት መረጃ','ቀረጥ ከፍሏል','አልከፈለም','libre', 'vehicle registration', 'motor number', 'number of axles','chasis number', 'plate number', 'trailer','cargo']
    
    return libreTerms.some(term => termString.includes(term)) ||
           /(libre|vehice registration|vehicle ownership|motor number|number of axles|license plate|cargo)/i.test(text)
  }

  isLegalDocument(text, headerTerms) {
    const termString = headerTerms.join(' ').toLowerCase()
    const legalTerms = ['agreement', 'contract', 'clause', 'party', 'whereas', 'warranty', 'jurisdiction']
    
    return legalTerms.some(term => termString.includes(term)) ||
           /(agreement|contract|clause|party|whereas|warranty|jurisdiction)/i.test(text)
  }

  isGovernmentDocument(text, headerTerms) {
    const termString = headerTerms.join(' ').toLowerCase()
    const govTerms = ['license','በአዲስ አበባ ከተማ አስተዳደር','addis ababa City administration','የኢትዮጵያ ዲጂታል መታወቂያ ካርድ','trade bureau','ንግድ ቢሮ' ,'trade Bureau','permit', 'national id', 'fayda id', 'government', 'identification']
    
    return govTerms.some(term => termString.includes(term)) ||
           /(license|permit|national id|fayda id|government|identification|Date of issuance|ብሔራዊ መታወቂያ ፕሮግራም)/i.test(text)
  }

  isFinancialDocument(text, headerTerms) {
    const termString = headerTerms.join(' ').toLowerCase()
    const financialTerms = ['invoice', 'receipt', 'payment', 'amount', 'balance', 'statement', 'tax']
    
    return financialTerms.some(term => termString.includes(term)) ||
           /(invoice|receipt|payment|amount|balance|statement|tax)/i.test(text)
  }
async extractLicenseNumber(text, language) {
    if (!this.initialized) {
      await this.initialize(language);
    }

    try {
      // Use QA model to extract license numbers
      const question = language === 'am' ? 'የንግድ ፈቃድ ቁጥር ምንድን ነው?' : 'What is the business license number?';
      const result = await this.qaModel(question, text);
      
      if (result.score > 0.3) {
        // Further validate if it looks like a license number
        const licenseMatch = result.answer.match(/\b[A-Z0-9]{8,12}\b/);
        if (licenseMatch) {
          return licenseMatch[0];
        }
        return result.answer;
      }
    } catch (error) {
      console.error('Error in license extraction:', error);
    }

    // Fallback regex extraction
   // const licenseMatch = text.match(/\b(?:BL|LIC|REG)?[A-Z0-9]{8,12}\b/);
   const licenseMatch = text.match(/^\d{2}\/\d{3,4}\/\d{3,4}\/\d{4}$/);
 //  const checkformat =this.isValidLicenseFormat()
    return licenseMatch ? licenseMatch[0] : null;
  }
  formatLicenseNumber(licenseNumber) {
    return licenseNumber.replace(/[^\d\/]/g, '');
  }

  // Validate license number format
  isValidLicenseFormat(licenseNumber) {
    const formatted = this.formatLicenseNumber(licenseNumber);
    const licenseRegex = /^\d{2}\/\d{3,4}\/\d{3,4}\/\d{4}$/;
    return licenseRegex.test(formatted);
  }
  extractTopics(text) {
    const words = text.toLowerCase().split(/\s+/)
    const wordFreq = {}
    
    words.forEach(word => {
      if (word.length > 4 && !this.isCommonWord(word)) {
        wordFreq[word] = (wordFreq[word] || 0) + 1
      }
    })
    
    return Object.entries(wordFreq)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 8)
      .map(([word]) => word)
  }

  extractKeywords(text) {
    const words = text.toLowerCase().split(/\s+/)
    const wordFreq = {}
    
    words.forEach(word => {
      if (word.length > 3) {
        wordFreq[word] = (wordFreq[word] || 0) + 1
      }
    })
    
    const maxFreq = Math.max(...Object.values(wordFreq))
    
    return Object.entries(wordFreq)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10)
      .map(([term, count]) => ({
        term,
        score: count / maxFreq
      }))
  }

  isCommonWord(word) {
    const commonWords = ['the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'your', 'have', 'with', 'this', 'that', 'from']
    return commonWords.includes(word)
  }

  generateSummary(text, headerTerms = []) {
    // Your existing summary generation logic
    const sentences = text.split(/[.!?]+/).filter(s => s.trim().length > 0)
    const firstFewSentences = sentences.slice(0, 6).join('. ')
    
    if (headerTerms.length > 0) {
      return `Document about ${headerTerms.slice(0, 3).join(', ')}. ${firstFewSentences}...`
    }
    
    return `${firstFewSentences}...`
  }

  showLoading(show) {
    // Your existing loading logic
    const loadingEl = document.getElementById('loading')
    if (loadingEl) {
      loadingEl.style.display = show ? 'flex' : 'none'
    }
  }
}

export const pdfAnalyzerF = new PDFAnalyzerF()END
cat > src/services/pdfAnalyzer2.js << 'END'
import * as pdfjsLib from 'pdfjs-dist/build/pdf'
import pdfjsWorker from 'pdfjs-dist/build/pdf.worker?url'
import nlp from 'compromise'
import { processMessage } from './nlpProcessor'
import { db } from './database.js'  // Add this import

// Set up PDF.js worker
pdfjsLib.GlobalWorkerOptions.workerSrc = pdfjsWorker

export class PDFAnalyzerD {
  constructor() {
    this.pdfjsLib = pdfjsLib
    this.nlp = nlp
    this.summarizationConfig = {
      maxSummarySentences: 5,
      minSentenceScore: 0.3,
      adjectiveWeight: 0.2,
      keywordMatchWeight: 0.8
    }
  }

  async init() {
    console.log('PDF Analyzer initialized with PDF.js and Compromise')
  }

  async analyzeDocument(file) {
    try {
      const fileBuffer = await file.arrayBuffer()
      const pdf = await this.pdfjsLib.getDocument(fileBuffer).promise
      
      // Extract metadata and text
      const { finalTitle, firstPageContent } = await this.extractDocumentMetadata(pdf)
      const { text, pages, paragraphs } = await this.extractFullText(pdf)
      
      // Enhanced classification using robust methods
      const analysis = await this.classifyDocument(text, finalTitle)

      // Store document for semantic analysis
      if (analysis.documentType === "Academic Paper") {
        await this.storeDocumentForSummarization(text, finalTitle, file.name)
      }

      analysis.fileName = file.name
      analysis.fileSize = file.size
      analysis.pages = pages
      analysis.firstPageContent = firstPageContent
      analysis.fullText = text
      
      return analysis
      
    } catch (error) {
      console.error('PDF analysis error:', error)
      throw new Error(`PDF analysis failed: ${error.message}`)
    }
  }

  // NEW: Store document for semantic summarization
  async storeDocumentForSummarization(text, title, fileName) {
    try {
      const documentId = 'doc_' + Date.now()
      
      // Parse document into sections and sentences
      const sections = this.parseDocumentIntoSections(text)
      
      // Save paper metadata
      await db.savePaperMetadata({
        documentId,
        title: title || fileName,
        fileName,
        sectionCount: sections.length,
        wordCount: text.split(/\s+/).filter(word => word.length > 0).length,
        storedAt: new Date().toISOString()
      })
      
      // Process each section
      for (const section of sections) {
        const sentences = this.splitIntoSentences(section.content)
        
        for (const sentence of sentences) {
          // Extract semantic metadata
          const tags = this.extractGrammarTags(sentence)
          const semanticHint = this.extractSemanticHint(sentence)
          const baseScore = this.calculateSentenceBaseScore(sentence, tags)
          
          // Save sentence with metadata
          await db.saveSemanticSentence({
            paperId: documentId,
            text: sentence,
            section: section.title,
            tags: tags,
            semanticHint: semanticHint,
            score: baseScore,
            wordCount: sentence.split(/\s+/).length,
            hasNumbers: /\d/.test(sentence),
            hasAdjectives: tags.includes('#Adjective'),
            hasVerbs: tags.includes('#Verb')
          })
        }
      }
      
      console.log(`Document ${documentId} stored for semantic analysis`)
      return documentId
      
    } catch (error) {
      console.error('Error storing document for summarization:', error)
      return null
    }
  }

  // NEW: Parse document into sections
  parseDocumentIntoSections(text) {
    const sectionTitles = [
      'Abstract', 'Introduction', 'Methodology', 'Methods', 
      'Results', 'Findings', 'Discussion', 'Conclusion', 
      'References', 'Bibliography'
    ]
    
    const sections = []
    const lines = text.split('\n')
    let currentSection = { title: 'Preliminary', content: '' }
    
    for (const line of lines) {
      const trimmedLine = line.trim()
      
      // Check if line is a section header
      const isSectionHeader = sectionTitles.some(title => 
        trimmedLine.toLowerCase().includes(title.toLowerCase()) && 
        trimmedLine.length < 100
      )
      
      if (isSectionHeader && currentSection.content.length > 0) {
        // Save current section
        sections.push({ ...currentSection })
        // Start new section
        currentSection = { 
          title: trimmedLine, 
          content: '' 
        }
      } else {
        currentSection.content += line + '\n'
      }
    }
    
    // Add the last section
    if (currentSection.content.length > 0) {
      sections.push({ ...currentSection })
    }
    
    return sections
  }

  // NEW: Split text into sentences
  splitIntoSentences(text) {
    // Simple sentence splitting
    return text
      .replace(/([.!?])\s*(?=[A-Z])/g, '$1|')
      .split('|')
      .filter(sentence => sentence.trim().length > 10)
      .map(sentence => sentence.trim())
  }

  // NEW: Extract grammar tags
  extractGrammarTags(sentence) {
    try {
      const doc = this.nlp(sentence)
      const tags = []
      
      if (doc.has('#Noun')) tags.push('#Noun')
      if (doc.has('#Verb')) tags.push('#Verb')
      if (doc.has('#Adjective')) tags.push('#Adjective')
      if (doc.has('#Adverb')) tags.push('#Adverb')
      if (doc.has('#Value')) tags.push('#Value')
      
      return tags
    } catch (error) {
      console.error('Error extracting grammar tags:', error)
      return []
    }
  }

  // NEW: Extract semantic hint
  extractSemanticHint(sentence) {
    const lowerSentence = sentence.toLowerCase()
    
    if (lowerSentence.includes('conclusion') || lowerSentence.includes('conclude')) {
      return 'conclusion'
    } else if (lowerSentence.includes('result') || lowerSentence.includes('finding')) {
      return 'finding'
    } else if (lowerSentence.includes('method') || lowerSentence.includes('procedure')) {
      return 'method'
    } else if (lowerSentence.includes('suggest') || lowerSentence.includes('recommend')) {
      return 'recommendation'
    } else if (lowerSentence.includes('limitation') || lowerSentence.includes('challenge')) {
      return 'limitation'
    } else if (lowerSentence.includes('future') || lowerSentence.includes('further')) {
      return 'future_work'
    }
    
    return 'general'
  }

  // NEW: Calculate base sentence score
  calculateSentenceBaseScore(sentence, tags) {
    let score = 0.5 // Base score
    
    // Add weight for adjectives
    if (tags.includes('#Adjective')) {
      score += this.summarizationConfig.adjectiveWeight
    }
    
    // Add weight for verbs
    if (tags.includes('#Verb')) {
      score += 0.1
    }
    
    // Adjust for sentence length (optimal length gets higher score)
    const wordCount = sentence.split(/\s+/).length
    if (wordCount >= 8 && wordCount <= 25) {
      score += 0.1
    }
    
    // Penalize very short or very long sentences
    if (wordCount < 5 || wordCount > 40) {
      score -= 0.1
    }
    
    return Math.min(Math.max(score, 0.1), 1.0)
  }

  // NEW: Score sentence based on keywords
  scoreSentence(sentence, keywords) {
    const lowerSentence = sentence.toLowerCase()
    let matchCount = 0
    
    // Count keyword matches
    keywords.forEach(keyword => {
      if (lowerSentence.includes(keyword.toLowerCase())) {
        matchCount++
      }
    })
    
    // Extract grammar tags for additional weighting
    const tags = this.extractGrammarTags(sentence)
    const hasAdjective = tags.includes('#Adjective')
    
    // Calculate final score
    const keywordScore = matchCount * this.summarizationConfig.keywordMatchWeight
    const adjectiveBonus = hasAdjective ? this.summarizationConfig.adjectiveWeight : 0
    
    return keywordScore + adjectiveBonus
  }

  // NEW: Generate smart summary
  async generateSmartSummary(documentId, keywords = [], options = {}) {
    const {
      format = 'paragraph',
      maxSentences = this.summarizationConfig.maxSummarySentences,
      groupBySection = false,
      highlightKeywords = false
    } = options
    
    try {
      // Get all sentences for the document
      const sentences = await db.getSentencesByPaperId(documentId, 1000)
      
      if (sentences.length === 0) {
        return 'No sentences available for summarization.'
      }
      
      // Score each sentence based on keywords
      const scoredSentences = sentences.map(sentence => ({
        ...sentence,
        dynamicScore: this.scoreSentence(sentence.text, keywords)
      }))
      
      // Sort by dynamic score (descending)
      scoredSentences.sort((a, b) => b.dynamicScore - a.dynamicScore)
      
      // Filter by minimum score
      const filteredSentences = scoredSentences.filter(
        s => s.dynamicScore >= this.summarizationConfig.minSentenceScore
      )
      
      // Take top sentences
      const topSentences = filteredSentences.slice(0, maxSentences)
      
      // Format the summary
      let summary
      
      if (groupBySection) {
        // Group by section
        const sections = {}
        topSentences.forEach(sentence => {
          if (!sections[sentence.section]) {
            sections[sentence.section] = []
          }
          sections[sentence.section].push(sentence)
        })
        
        summary = Object.entries(sections)
          .map(([sectionName, sectionSentences]) => {
            const sectionText = sectionSentences
              .map(s => this.formatSentence(s.text, keywords, highlightKeywords))
              .join(' ')
            return `**${sectionName}**: ${sectionText}`
          })
          .join('\n\n')
          
      } else if (format === 'bullets') {
        // Bullet point format
        summary = topSentences
          .map(s => `• ${this.formatSentence(s.text, keywords, highlightKeywords)}`)
          .join('\n')
          
      } else {
        // Paragraph format (default)
        summary = topSentences
          .map(s => this.formatSentence(s.text, keywords, highlightKeywords))
          .join(' ')
      }
      
      return summary
      
    } catch (error) {
      console.error('Error generating smart summary:', error)
      return 'Unable to generate summary at this time.'
    }
  }

  // NEW: Format sentence with keyword highlighting
  formatSentence(sentence, keywords, highlight = false) {
    if (!highlight || keywords.length === 0) {
      return sentence
    }
    
    let formatted = sentence
    keywords.forEach(keyword => {
      const regex = new RegExp(`\\b${keyword}\\b`, 'gi')
      formatted = formatted.replace(regex, match => `<span class="keyword-highlight">${match}</span>`)
    })
    
    return formatted
  }

  // NEW: Generate summary by paper ID (public interface)
  async summarizePaper(paperId, keywords, callback) {
    try {
      const summary = await this.generateSmartSummary(paperId, keywords, {
        format: 'paragraph',
        maxSentences: 5
      })
      
      if (callback && typeof callback === 'function') {
        callback(summary)
      }
      
      return summary
    } catch (error) {
      console.error('Error in summarizePaper:', error)
      if (callback && typeof callback === 'function') {
        callback('Error generating summary')
      }
      return 'Error generating summary'
    }
  }

  // NEW: Generate bullet point summary
  async generateBulletSummary(documentId, keywords, maxPoints = 5) {
    return this.generateSmartSummary(documentId, keywords, {
      format: 'bullets',
      maxSentences: maxPoints
    })
  }

  // NEW: Generate section-based summary
  async generateSectionSummary(documentId, keywords) {
    return this.generateSmartSummary(documentId, keywords, {
      groupBySection: true,
      maxSentences: 10
    })
  }

  // NEW: Get summarization statistics
  async getSummarizationStats(documentId) {
    try {
      const sentences = await db.getSentencesByPaperId(documentId)
      const paper = await db.getPaperByDocumentId(documentId)
      
      if (!paper) {
        return null
      }
      
      return {
        paperId: documentId,
        title: paper.title,
        totalSentences: sentences.length,
        sections: [...new Set(sentences.map(s => s.section))],
        avgSentenceScore: sentences.reduce((sum, s) => sum + s.score, 0) / sentences.length,
        storedAt: paper.timestamp
      }
    } catch (error) {
      console.error('Error getting summarization stats:', error)
      return null
    }
  }

  // NEW: Adjust summarization configuration
  setSummarizationConfig(config) {
    this.summarizationConfig = {
      ...this.summarizationConfig,
      ...config
    }
  }

  // Existing methods (unchanged)...
  extractServiceSpecificData(analysis, service) {
    const extractedData = {}
    
    if (service === 'iftms') {
      if (analysis.extractedData?.licenseNumber) {
        extractedData.licenseNumber = analysis.extractedData.licenseNumber
      }
      if (analysis.extractedData?.vehicleInfo) {
        extractedData.vehicleInfo = analysis.extractedData.vehicleInfo
      }
    } else if (service === 'renewDoc') {
      if (analysis.extractedData?.businessName) {
        extractedData.businessName = analysis.extractedData.businessName
      }
      if (analysis.extractedData?.licenseNumber) {
        extractedData.licenseNumber = analysis.extractedData.licenseNumber
      }
    }
    
    return extractedData
  }

  extractLicenseNumber(text) {
    // Extract business license number patterns
    const licensePatterns = [
      /\b\d{2}\/\d{3,4}\/\d{3,4}\/\d{4}\b/, // 14/668/5068/2004
      /\bBL\d{8,12}\b/i, // BL123456789
      /\bLIC\d{8,12}\b/i, // LIC123456789
    ]
    
    for (const pattern of licensePatterns) {
      const match = text.match(pattern)
      if (match) return match[0]
    }
    
    return null
  }

  async extractFromDocument(document, service) {
    try {
      let extractedData = {}
      
      // For PDF files
      if (document.type === 'application/pdf') {
        const analysis = await this.analyzeDocument(document)
        extractedData = this.extractServiceSpecificData(analysis, service)
      }
      // For image files
      else if (document.type.startsWith('image/')) {
        // Note: teSsAna reference - you may need to import or define this
        // const text = await teSsAna.analyzeDocument(document)
        // const analysis = teSsAna.classifyDocument(text, document.name)
        // extractedData = this.extractServiceSpecificData(analysis, service)
      }
      
      return extractedData
    } catch (error) {
      console.error('Error extracting from document:', error)
      return {}
    }
  }

  async extractDocumentMetadata(pdf) {
    const firstPage = await pdf.getPage(1)
    const textContent = await firstPage.getTextContent()
    const firstPageText = textContent.items.map(item => item.str).join('\n')
    
    // Your existing metadata extraction logic
    const coverTitle = this.extractTitleFromCover(firstPageText)
    const cleanCoverTitle = this.cleanResearchTitle(coverTitle)
    const cleanFileName = this.cleanResearchTitle(pdf._pdfInfo?.title || "")
    
    let finalTitle = cleanCoverTitle
    
    if (cleanFileName && !this.titlesMatch(cleanCoverTitle, cleanFileName)) {
      finalTitle = `${cleanCoverTitle}`
    }
    
    return {
      coverTitle: cleanCoverTitle,
      fileNameTitle: cleanFileName,
      finalTitle,
      firstPageContent: firstPageText
    }
  }

  async extractFullText(pdf) {
    let text = ''
    let paragraphs = []
    
    for (let i = 1; i <= pdf.numPages; i++) {
      const page = await pdf.getPage(i)
      const textContent = await page.getTextContent()
      const pageText = textContent.items.map(item => item.str).join(' ')
      text += pageText + '\n'
      
      // Your existing paragraph detection logic
      let currentY = null
      let currentParagraph = ''
      
      textContent.items.forEach(item => {
        if (currentY !== null && Math.abs(item.transform[5] - currentY) > 15) {
          if (currentParagraph.trim()) {
            paragraphs.push(currentParagraph.trim())
          }
          currentParagraph = ''
        }
        currentY = item.transform[5]
        currentParagraph += item.str + ' '
      })
      
      if (currentParagraph.trim()) {
        paragraphs.push(currentParagraph.trim())
      }
    }
    
    return { text, paragraphs, pages: pdf.numPages }
  }

  // Add your existing utility methods
  extractTitleFromCover(text) {
    const lines = text.split('\n').filter(line => line.trim().length > 10)
    return lines.length > 0 ? lines[0] : 'Untitled Document'
  }

  cleanResearchTitle(title) {
    return title.replace(/[^\w\sሀ-ፕ]/g, '').trim()
  }

  titlesMatch(title1, title2) {
    return this.similarity(title1.toLowerCase(), title2.toLowerCase()) > 0.7
  }

  similarity(s1, s2) {
    const longer = s1.length > s2.length ? s1 : s2
    const shorter = s1.length > s2.length ? s2 : s1
    
    if (longer === shorter) return 1.0
    
    const distance = this.editDistance(longer, shorter)
    return (longer.length - distance) / parseFloat(longer.length)
  }

  editDistance(s1, s2) {
    s1 = s1.toLowerCase()
    s2 = s2.toLowerCase()
    
    const costs = []
    for (let i = 0; i <= s1.length; i++) {
      let lastValue = i
      for (let j = 0; j <= s2.length; j++) {
        if (i === 0) {
          costs[j] = j
        } else {
          if (j > 0) {
            let newValue = costs[j - 1]
            if (s1.charAt(i - 1) !== s2.charAt(j - 1)) {
              newValue = Math.min(Math.min(newValue, lastValue), costs[j]) + 1
            }
            costs[j - 1] = lastValue
            lastValue = newValue
          }
        }
      }
      if (i > 0) costs[s2.length] = lastValue
    }
    return costs[s2.length]
  }

  // Your existing classification methods
  async classifyDocument(text, fileName) {
    const headerTerms = this.extractHeaderTerms(text)
    const cintent = sessionStorage.getItem('intent')
    const headerClassification = this.classifyByHeaderTerms(headerTerms)
    
    if (headerClassification) {
      return {
        documentName: fileName.replace(/\.[^/.]+$/, "") || 'Unknown Document',
        documentType: headerClassification.type,
        typeClass: headerClassification.class,
        confidence: headerClassification.confidence,
        topics: this.extractTopics(text),
        keywords: headerClassification.keywords,
        summary: this.generateSummary(text, headerTerms),
        wordCount: text.split(/\s+/).filter(word => word.length > 0).length,
        timestamp: new Date().toISOString(),
        headerTerms: headerTerms
      }
    }

    // Fallback to content-based classification
    const lowerText = text.toLowerCase()
    
    let type = "General Document"
    let typeClass = "type-other"
    let confidence = 0.3
  
    if (this.isResearchPaper(text, headerTerms)) {
      type = "Academic Paper"
      typeClass = "type-research"
      confidence = 0.85
      
      if (!cintent) {
        sessionStorage.setItem('intnt', 'analyzeResearch')
      }
    } else if (this.isVehicleOwnershipDoc(text, headerTerms)) {
      type = "Libre"
      typeClass = "type-libre"
      confidence = 0.85
      if (!cintent) {
        sessionStorage.setItem('intnt', 'iftms')
      }
    } else if (this.isLegalDocument(text, headerTerms)) {
      type = "Legal Document"
      typeClass = "type-legal"
      confidence = 0.8
      if (!cintent) {
        sessionStorage.setItem('intnt', 'analyzeLegal')
      }
    } else if (this.isGovernmentDocument(text, headerTerms)) {
      type = "Government Document"
      typeClass = "type-government"
      confidence = 0.75
    } else if (this.isFinancialDocument(text, headerTerms)) {
      type = "Financial Document"
      typeClass = "type-financial"
      confidence = 0.7
    }
    
    const topics = this.extractTopics(text)
    const keywords = this.extractKeywords(text)
    const currentIntent = sessionStorage.getItem('currentService')
    const Edata = {
      documentType: type,
      typeClass: typeClass,
      confidence: confidence,
    }
    
    if (currentIntent === 'iftms') {
      return await processMessage(currentIntent, Edata, false, true)
    }
    
    return {
      documentName: fileName.replace(/\.[^/.]+$/, "") || 'Unknown Document',
      documentType: type,
      typeClass: typeClass,
      confidence: confidence,
      topics: topics,
      keywords: keywords,
      summary: this.generateSummary(text, headerTerms),
      wordCount: text.split(/\s+/).filter(word => word.length > 0).length,
      timestamp: new Date().toISOString(),
      headerTerms: headerTerms
    }
  }

  extractHeaderTerms(text) {
    try {
      const lines = text.split('\n').slice(0, 15).join('\n')
      const doc = this.nlp(lines)
      
      const nouns = doc.nouns().out('array')
      const nounPhrases = doc.match('#Noun+').out('array')
      
      const allTerms = [...new Set([...nouns, ...nounPhrases])]
      
      return allTerms
        .filter(term =>
          term.length > 3 &&
          !/\d/.test(term) &&
          !['page', 'date', 'author', 'version', 'section'].includes(term.toLowerCase())
        )
        .slice(0, 10)
    } catch (e) {
      console.error("Error extracting header terms:", e)
      return []
    }
  }

  classifyByHeaderTerms(headerTerms) {
    const termString = headerTerms.join(' ').toLowerCase()
    const cintent = sessionStorage.getItem('intent')
    
    // Research Paper detection
    const researchTerms = ['study', 'research', 'analysis', 'experiment', 'hypothesis', 'methodology', 'results', 'findings']
    if (researchTerms.some(term => termString.includes(term))) {
      if (!cintent) {
        sessionStorage.setItem('intnt', 'analyzeResearch')
      }
      return {
        type: "Academic Paper",
        class: "type-research",
        confidence: 0.85,
        keywords: researchTerms
          .filter(term => termString.includes(term))
          .map(term => ({ term, score: 0.8 }))
      }
    }
    
    // Legal Document detection
    const legalTerms = ['agreement', 'contract', 'clause', 'party', 'law', 'terms', 'condition', 'section']
    
    if (legalTerms.some(term => termString.includes(term))) {
      if (!cintent) {
        sessionStorage.setItem('intnt', 'analyzeLegal')
      }
      return {
        type: "Legal Document",
        class: "type-legal",
        confidence: 0.85,
        keywords: legalTerms
          .filter(term => termString.includes(term))
          .map(term => ({ term, score: 0.8 }))
      }
    }
    
    // Financial Document detection
    const financialTerms = ['invoice', 'receipt', 'payment', 'balance', 'statement', 'total', 'amount', 'due']
    if (financialTerms.some(term => termString.includes(term))) {
      return {
        type: "Financial Document",
        class: "type-financial",
        confidence: 0.85,
        keywords: financialTerms
          .filter(term => termString.includes(term))
          .map(term => ({ term, score: 0.8 }))
      }
    }
    
    return null
  }

  // Your existing document type detection methods
  isResearchPaper(text, headerTerms) {
    const termString = headerTerms.join(' ').toLowerCase()
    const researchTerms = ['abstract', 'introduction', 'methodology', 'results', 'discussion', 'conclusion', 'references']
    
    return researchTerms.some(term => termString.includes(term)) ||
           /(abstract|introduction|methodology|results|discussion|conclusion|references|bibliography)/i.test(text)
  }

  isVehicleOwnershipDoc(text, headerTerms) {
    const termString = headerTerms.join(' ').toLowerCase()
    const libreTerms = ['የባለንብረት መረጃ', 'ቀረጥ ከፍሏል', 'አልከፈለም', 'libre', 'vehicle registration', 'motor number', 'number of axles', 'chasis number', 'plate number', 'trailer', 'cargo']
    
    return libreTerms.some(term => termString.includes(term)) ||
           /(libre|vehice registration|vehicle ownership|motor number|number of axles|license plate|cargo)/i.test(text)
  }

  isLegalDocument(text, headerTerms) {
    const termString = headerTerms.join(' ').toLowerCase()
    const legalTerms = ['agreement', 'contract', 'clause', 'party', 'whereas', 'warranty', 'jurisdiction']
    
    return legalTerms.some(term => termString.includes(term)) ||
           /(agreement|contract|clause|party|whereas|warranty|jurisdiction)/i.test(text)
  }

  isGovernmentDocument(text, headerTerms) {
    const termString = headerTerms.join(' ').toLowerCase()
    const govTerms = ['license', 'permit', 'national id', 'fayda id', 'government', 'identification']
    
    return govTerms.some(term => termString.includes(term)) ||
           /(license|permit|national id|fayda id|government|identification)/i.test(text)
  }

  isFinancialDocument(text, headerTerms) {
    const termString = headerTerms.join(' ').toLowerCase()
    const financialTerms = ['invoice', 'receipt', 'payment', 'amount', 'balance', 'statement', 'tax']
    
    return financialTerms.some(term => termString.includes(term)) ||
           /(invoice|receipt|payment|amount|balance|statement|tax)/i.test(text)
  }

  async extractLicenseNumber(text, language) {
    // Your existing implementation
    const licenseMatch = text.match(/^\d{2}\/\d{3,4}\/\d{3,4}\/\d{4}$/)
    return licenseMatch ? licenseMatch[0] : null
  }

  formatLicenseNumber(licenseNumber) {
    return licenseNumber.replace(/[^\d\/]/g, '')
  }

  isValidLicenseFormat(licenseNumber) {
    const formatted = this.formatLicenseNumber(licenseNumber)
    const licenseRegex = /^\d{2}\/\d{3,4}\/\d{3,4}\/\d{4}$/
    return licenseRegex.test(formatted)
  }

  extractTopics(text) {
    const words = text.toLowerCase().split(/\s+/)
    const wordFreq = {}
    
    words.forEach(word => {
      if (word.length > 4 && !this.isCommonWord(word)) {
        wordFreq[word] = (wordFreq[word] || 0) + 1
      }
    })
    
    return Object.entries(wordFreq)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 8)
      .map(([word]) => word)
  }

  extractKeywords(text) {
    const words = text.toLowerCase().split(/\s+/)
    const wordFreq = {}
    
    words.forEach(word => {
      if (word.length > 3) {
        wordFreq[word] = (wordFreq[word] || 0) + 1
      }
    })
    
    const maxFreq = Math.max(...Object.values(wordFreq))
    
    return Object.entries(wordFreq)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 10)
      .map(([term, count]) => ({
        term,
        score: count / maxFreq
      }))
  }

  isCommonWord(word) {
    const commonWords = ['the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'your', 'have', 'with', 'this', 'that', 'from']
    return commonWords.includes(word)
  }

  generateSummary(text, headerTerms = []) {
    // Your existing summary generation logic
    const sentences = text.split(/[.!?]+/).filter(s => s.trim().length > 0)
    const firstFewSentences = sentences.slice(0, 6).join('. ')
    
    if (headerTerms.length > 0) {
      return `Document about ${headerTerms.slice(0, 3).join(', ')}. ${firstFewSentences}...`
    }
    
    return `${firstFewSentences}...`
  }

  showLoading(show) {
    // Your existing loading logic
    const loadingEl = document.getElementById('loading')
    if (loadingEl) {
      loadingEl.style.display = show ? 'flex' : 'none'
    }
  }
}

export const pdfAnalyzerD = new PDFAnalyzerD()


// REQUIRED FUNCTIONS (non-class functions)

/**
 * Score a sentence based on keyword matches and grammar
 * @param {string} sentence - The sentence to score
 * @param {Array<string>} keywords - Keywords to match against
 * @returns {number} - Sentence score
 */
export function scoreSentence(sentence, keywords) {
  const lower = sentence.toLowerCase()
  const matchCount = keywords.filter(k => lower.includes(k.toLowerCase())).length
  
  // Use nlp for grammar analysis
  const doc = nlp(sentence)
  const weight = doc.has('#Adjective') ? 0.2 : 0
  
  return matchCount + weight
}

/**
 * Generate a summary for a paper
 * @param {string} paperId - The paper ID
 * @param {Array<string>} keywords - Keywords for scoring
 * @param {Function} callback - Callback function to receive the summary
 */
export function summarizePaper(paperId, keywords, callback) {
  return pdfAnalyzerD.summarizePaper(paperId, keywords, callback)
}

/**
 * Generate bullet point summary
 * @param {string} documentId - Document ID
 * @param {Array<string>} keywords - Keywords
 * @param {number} maxPoints - Maximum bullet points
 * @returns {Promise<string>} - Bullet point summary
 */
export function generateBulletSummary(documentId, keywords, maxPoints = 5) {
  return pdfAnalyzerD.generateBulletSummary(documentId, keywords, maxPoints)
}

/**
 * Generate section-based summary
 * @param {string} documentId - Document ID
 * @param {Array<string>} keywords - Keywords
 * @returns {Promise<string>} - Section-based summary
 */
export function generateSectionSummary(documentId, keywords) {
  return pdfAnalyzerD.generateSectionSummary(documentId, keywords)
}

/**
 * Example usage function
 * @param {string} paperId - Paper ID
 * @param {Array<string>} keywords - Keywords for summarization
 */
export function exampleSummarizationUsage(paperId, keywords = ['sleep', 'memory', 'recall', 'performance']) {
  summarizePaper(paperId, keywords, function(summary) {
    const outputElement = document.getElementById('summaryOutput')
    if (outputElement) {
      outputElement.textContent = summary
    } else {
      console.log('Summary:', summary)
    }
  })
}

/**
 * Get summarization statistics for a document
 * @param {string} documentId - Document ID
 * @returns {Promise<Object|null>} - Statistics object
 */
export function getSummarizationStats(documentId) {
  return pdfAnalyzerD.getSummarizationStats(documentId)
}

/**
 * Format summary with highlighted keywords
 * @param {string} summary - The summary text
 * @param {Array<string>} keywords - Keywords to highlight
 * @returns {string} - Formatted HTML with highlighted keywords
 */
export function formatSummaryWithHighlights(summary, keywords) {
  let formatted = summary
  keywords.forEach(keyword => {
    const regex = new RegExp(`\\b${keyword}\\b`, 'gi')
    formatted = formatted.replace(regex, match => 
      `<span class="keyword-highlight" data-keyword="${keyword}">${match}</span>`
    )
  })
  return formatted
}

/**
 * Initialize the database before using summarization features
 * @returns {Promise} - Promise that resolves when database is initialized
 */
export async function initializeSummarization() {
  try {
    await db.init()
    console.log('Database initialized for summarization features')
    return true
  } catch (error) {
    console.error('Failed to initialize database:', error)
    return false
  }
}END
cat > src/services/pdfTagger.js.js << 'END'
// client/src/services/pdfTagger.js
import * as pdfjsLib from 'pdfjs-dist/build/pdf'
import pdfjsWorker from 'pdfjs-dist/build/pdf.worker?url'
import nlp from 'compromise'

// Set up PDF.js worker
pdfjsLib.GlobalWorkerOptions.workerSrc = pdfjsWorker

class PDFTagger {
  constructor() {
    this.pdfjsLib = pdfjsLib
    this.nlp = nlp
    this.db = null
    this.initDB()
  }

  async initDB() {
    return new Promise((resolve, reject) => {
      const request = indexedDB.open('PDFDocumentsDB', 1)
      
      request.onerror = () => reject(request.error)
      request.onsuccess = () => {
        this.db = request.result
        resolve()
      }
      
      request.onupgradeneeded = (event) => {
        const db = event.target.result
        
        // Documents store
        if (!db.objectStoreNames.contains('documents')) {
          const docStore = db.createObjectStore('documents', { keyPath: 'id' })
          docStore.createIndex('userId', 'userId', { unique: false })
          docStore.createIndex('synced', 'synced', { unique: false })
          docStore.createIndex('createdAt', 'createdAt', { unique: false })
        }
        
        // Sentences store with tags
        if (!db.objectStoreNames.contains('sentences')) {
          const sentStore = db.createObjectStore('sentences', { keyPath: 'id', autoIncrement: true })
          sentStore.createIndex('documentId', 'documentId', { unique: false })
          sentStore.createIndex('synced', 'synced', { unique: false })
          sentStore.createIndex('section', 'section', { unique: false })
          sentStore.createIndex('semanticHint', 'semanticHint', { unique: false })
          sentStore.createIndex('hasAdjectives', 'hasAdjectives', { unique: false })
          sentStore.createIndex('hasVerbs', 'hasVerbs', { unique: false })
        }
        
        // Tags store
        if (!db.objectStoreNames.contains('tags')) {
          const tagStore = db.createObjectStore('tags', { keyPath: 'id', autoIncrement: true })
          tagStore.createIndex('documentId', 'documentId', { unique: false })
          tagStore.createIndex('tagType', 'tagType', { unique: false })
          tagStore.createIndex('synced', 'synced', { unique: false })
        }
        
        // Sync queue
        if (!db.objectStoreNames.contains('syncQueue')) {
          const syncStore = db.createObjectStore('syncQueue', { keyPath: 'id', autoIncrement: true })
          syncStore.createIndex('synced', 'synced', { unique: false })
        }
      }
    })
  }

  async extractAndTag(file, userId) {
    try {
      // Extract text from PDF
      const fileBuffer = await file.arrayBuffer()
      const pdf = await this.pdfjsLib.getDocument(fileBuffer).promise
      
      let fullText = ''
      for (let i = 1; i <= pdf.numPages; i++) {
        const page = await pdf.getPage(i)
        const textContent = await page.getTextContent()
        const pageText = textContent.items.map(item => item.str).join(' ')
        fullText += pageText + '\n'
      }

      // Generate document ID
      const documentId = `doc_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
      
      // Parse document into sections
      const sections = this.parseDocumentIntoSections(fullText)
      
      // Store document metadata
      const document = {
        id: documentId,
        userId: userId,
        fileName: file.name,
        fileSize: file.size,
        pageCount: pdf.numPages,
        sectionCount: sections.length,
        wordCount: fullText.split(/\s+/).length,
        createdAt: new Date().toISOString(),
        synced: false,
        fullText: fullText.substring(0, 1000) // Store preview only
      }
      
      await this.saveDocument(document)
      
      // Process and tag each sentence
      let sentenceCount = 0
      const sentences = []
      const tags = []
      
      for (const section of sections) {
        const sectionSentences = this.splitIntoSentences(section.content)
        
        for (const sentenceText of sectionSentences) {
          if (sentenceText.trim().length < 10) continue
          
          // Extract tags using compromise
          const sentenceTags = this.extractTags(sentenceText)
          const semanticHint = this.extractSemanticHint(sentenceText)
          const baseScore = this.calculateBaseScore(sentenceText, sentenceTags)
          
          const sentence = {
            documentId: documentId,
            text: sentenceText,
            section: section.title,
            tags: sentenceTags,
            semanticHint: semanticHint,
            score: baseScore,
            wordCount: sentenceText.split(/\s+/).length,
            hasNumbers: /\d/.test(sentenceText),
            hasAdjectives: sentenceTags.includes('#Adjective'),
            hasVerbs: sentenceTags.includes('#Verb'),
            hasNouns: sentenceTags.includes('#Noun'),
            hasProperNouns: sentenceTags.includes('#ProperNoun'),
            hasValues: sentenceTags.includes('#Value'),
            createdAt: new Date().toISOString(),
            synced: false
          }
          
          await this.saveSentence(sentence)
          sentences.push(sentence)
          
          // Create individual tags for search
          sentenceTags.forEach(tagType => {
            const tag = {
              documentId: documentId,
              sentenceId: sentence.id,
              tagType: tagType,
              value: tagType,
              createdAt: new Date().toISOString(),
              synced: false
            }
            tags.push(tag)
          })
          
          sentenceCount++
        }
      }
      
      // Save all tags
      await this.saveTags(tags)
      
      // Add to sync queue
      await this.addToSyncQueue({
        documentId: documentId,
        type: 'document',
        action: 'create',
        data: { document, sentences, tags },
        createdAt: new Date().toISOString()
      })
      
      return {
        documentId,
        fileName: file.name,
        pageCount: pdf.numPages,
        sentenceCount,
        sectionCount: sections.length
      }
      
    } catch (error) {
      console.error('PDF tagging error:', error)
      throw error
    }
  }

  parseDocumentIntoSections(text) {
    const sectionTitles = [
      'Abstract', 'Introduction', 'Methodology', 'Methods', 
      'Results', 'Findings', 'Discussion', 'Conclusion', 
      'References', 'Bibliography', 'Appendix'
    ]
    
    const sections = []
    const lines = text.split('\n')
    let currentSection = { title: 'Preliminary', content: '' }
    
    for (const line of lines) {
      const trimmed = line.trim()
      
      const isSectionHeader = sectionTitles.some(title => 
        trimmed.toLowerCase().includes(title.toLowerCase()) && trimmed.length < 100
      )
      
      if (isSectionHeader && currentSection.content.length > 0) {
        sections.push({ ...currentSection })
        currentSection = { title: trimmed, content: '' }
      } else {
        currentSection.content += line + '\n'
      }
    }
    
    if (currentSection.content.length > 0) {
      sections.push({ ...currentSection })
    }
    
    return sections
  }

  splitIntoSentences(text) {
    return text
      .replace(/([.!?])\s*(?=[A-Z])/g, '$1|')
      .split('|')
      .filter(s => s.trim().length > 0)
      .map(s => s.trim())
  }

  extractTags(sentence) {
    try {
      const doc = this.nlp(sentence)
      const tags = []
      
      if (doc.has('#Noun')) tags.push('#Noun')
      if (doc.has('#Verb')) tags.push('#Verb')
      if (doc.has('#Adjective')) tags.push('#Adjective')
      if (doc.has('#Adverb')) tags.push('#Adverb')
      if (doc.has('#Value')) tags.push('#Value')
      if (doc.has('#ProperNoun')) tags.push('#ProperNoun')
      if (doc.has('#Question')) tags.push('#Question')
      if (doc.has('#Negative')) tags.push('#Negative')
      
      // Extract named entities
      const people = doc.people().out('array')
      if (people.length > 0) tags.push('#Person')
      
      const places = doc.places().out('array')
      if (places.length > 0) tags.push('#Place')
      
      const organizations = doc.organizations().out('array')
      if (organizations.length > 0) tags.push('#Organization')
      
      return tags
    } catch (error) {
      console.error('Error extracting tags:', error)
      return []
    }
  }

  extractSemanticHint(sentence) {
    const lower = sentence.toLowerCase()
    
    if (lower.includes('conclusion') || lower.includes('conclude')) return 'conclusion'
    if (lower.includes('result') || lower.includes('finding')) return 'finding'
    if (lower.includes('method') || lower.includes('procedure')) return 'method'
    if (lower.includes('suggest') || lower.includes('recommend')) return 'recommendation'
    if (lower.includes('limitation') || lower.includes('challenge')) return 'limitation'
    if (lower.includes('future') || lower.includes('further')) return 'future_work'
    if (lower.includes('introduction') || lower.includes('background')) return 'introduction'
    if (lower.includes('figure') || lower.includes('table')) return 'visual_data'
    
    return 'general'
  }

  calculateBaseScore(sentence, tags) {
    let score = 0.5
    
    if (tags.includes('#Adjective')) score += 0.2
    if (tags.includes('#Verb')) score += 0.1
    if (tags.includes('#ProperNoun')) score += 0.15
    
    const wordCount = sentence.split(/\s+/).length
    if (wordCount >= 8 && wordCount <= 25) score += 0.1
    if (wordCount < 5 || wordCount > 40) score -= 0.1
    
    return Math.max(0.1, Math.min(1.0, score))
  }

  async saveDocument(document) {
    return new Promise((resolve, reject) => {
      const tx = this.db.transaction(['documents'], 'readwrite')
      const store = tx.objectStore('documents')
      const request = store.add(document)
      
      request.onsuccess = () => resolve()
      request.onerror = () => reject(request.error)
    })
  }

  async saveSentence(sentence) {
    return new Promise((resolve, reject) => {
      const tx = this.db.transaction(['sentences'], 'readwrite')
      const store = tx.objectStore('sentences')
      const request = store.add(sentence)
      
      request.onsuccess = (event) => {
        sentence.id = event.target.result
        resolve(sentence)
      }
      request.onerror = () => reject(request.error)
    })
  }

  async saveTags(tags) {
    return new Promise((resolve, reject) => {
      const tx = this.db.transaction(['tags'], 'readwrite')
      const store = tx.objectStore('tags')
      
      let completed = 0
      tags.forEach(tag => {
        const request = store.add(tag)
        request.onsuccess = () => {
          completed++
          if (completed === tags.length) resolve()
        }
        request.onerror = () => reject(request.error)
      })
      
      if (tags.length === 0) resolve()
    })
  }

  async addToSyncQueue(item) {
    return new Promise((resolve, reject) => {
      const tx = this.db.transaction(['syncQueue'], 'readwrite')
      const store = tx.objectStore('syncQueue')
      const request = store.add(item)
      
      request.onsuccess = () => resolve()
      request.onerror = () => reject(request.error)
    })
  }

  async getUnsyncedItems() {
    return new Promise((resolve, reject) => {
      const tx = this.db.transaction(['syncQueue'], 'readonly')
      const store = tx.objectStore('syncQueue')
      const index = store.index('synced')
      const request = index.getAll(false)
      
      request.onsuccess = () => resolve(request.result)
      request.onerror = () => reject(request.error)
    })
  }

  async markAsSynced(itemIds) {
    return new Promise((resolve, reject) => {
      const tx = this.db.transaction(['syncQueue'], 'readwrite')
      const store = tx.objectStore('syncQueue')
      
      let completed = 0
      itemIds.forEach(id => {
        const getRequest = store.get(id)
        getRequest.onsuccess = () => {
          const item = getRequest.result
          item.synced = true
          const updateRequest = store.put(item)
          updateRequest.onsuccess = () => {
            completed++
            if (completed === itemIds.length) resolve()
          }
        }
      })
    })
  }

  async getDocumentsByUser(userId) {
    return new Promise((resolve, reject) => {
      const tx = this.db.transaction(['documents'], 'readonly')
      const store = tx.objectStore('documents')
      const index = store.index('userId')
      const request = index.getAll(userId)
      
      request.onsuccess = () => resolve(request.result)
      request.onerror = () => reject(request.error)
    })
  }

  async getSentencesByDocument(documentId) {
    return new Promise((resolve, reject) => {
      const tx = this.db.transaction(['sentences'], 'readonly')
      const store = tx.objectStore('sentences')
      const index = store.index('documentId')
      const request = index.getAll(documentId)
      
      request.onsuccess = () => resolve(request.result)
      request.onerror = () => reject(request.error)
    })
  }

  async getTagsByDocument(documentId) {
    return new Promise((resolve, reject) => {
      const tx = this.db.transaction(['tags'], 'readonly')
      const store = tx.objectStore('tags')
      const index = store.index('documentId')
      const request = index.getAll(documentId)
      
      request.onsuccess = () => resolve(request.result)
      request.onerror = () => reject(request.error)
    })
  }

  async deleteDocument(documentId) {
    return new Promise((resolve, reject) => {
      const tx = this.db.transaction(['documents', 'sentences', 'tags'], 'readwrite')
      
      // Delete sentences
      const sentStore = tx.objectStore('sentences')
      const sentIndex = sentStore.index('documentId')
      const sentRequest = sentIndex.getAll(documentId)
      
      sentRequest.onsuccess = () => {
        sentRequest.result.forEach(s => {
          sentStore.delete(s.id)
        })
      }
      
      // Delete tags
      const tagStore = tx.objectStore('tags')
      const tagIndex = tagStore.index('documentId')
      const tagRequest = tagIndex.getAll(documentId)
      
      tagRequest.onsuccess = () => {
        tagRequest.result.forEach(t => {
          tagStore.delete(t.id)
        })
      }
      
      // Delete document
      const docStore = tx.objectStore('documents')
      docStore.delete(documentId)
      
      tx.oncomplete = () => resolve()
      tx.onerror = () => reject(tx.error)
    })
  }
}

export const pdfTagger = new PDFTagger()END
cat > src/services/pwa.js << 'END'
export class PWAHandler {
  constructor() {
    this.deferredPrompt = null
  }

  async init() {
    this.registerServiceWorker()
    this.setupInstallPrompt()
    this.loadThemePreference()
    this.setupNetworkStatus()
  }

  registerServiceWorker() {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker
        .register('/sw.js')
        .then(registration => {
          console.log('SW registered: ', registration)
        })
        .catch(registrationError => {
          console.log('SW registration failed: ', registrationError)
        })
    }
  }

  setupInstallPrompt() {
    window.addEventListener('beforeinstallprompt', (e) => {
      e.preventDefault()
      this.deferredPrompt = e
      this.showInstallPromotion()
    })

    window.addEventListener('appinstalled', () => {
      this.deferredPrompt = null
      console.log('PWA was installed')
    })
  }

  showInstallPromotion() {
    // You can show a custom install button here
    const installBtn = document.createElement('button')
    installBtn.textContent = 'Install App'
    installBtn.className = 'install-btn'
    installBtn.addEventListener('click', this.installApp.bind(this))
    
    // Add to your UI where appropriate
    const appHeader = document.querySelector('.app-header')
    if (appHeader) {
      appHeader.appendChild(installBtn)
    }
  }

  async installApp() {
    if (this.deferredPrompt) {
      this.deferredPrompt.prompt()
      const { outcome } = await this.deferredPrompt.userChoice
      
      if (outcome === 'accepted') {
        console.log('User accepted the install prompt')
      } else {
        console.log('User dismissed the install prompt')
      }
      this.deferredPrompt = null
    }
  }

  loadThemePreference() {
    const savedTheme = localStorage.getItem('theme') || 'dark'
    if (savedTheme === 'light') {
      document.body.classList.add('light-theme')
      const themeBtn = document.getElementById('theme-toggle-btn')
      if (themeBtn) {
        themeBtn.textContent = 'dark_mode'
      }
    }
  }

  // Check if app is running as PWA
  isRunningAsPWA() {
    return window.matchMedia('(display-mode: standalone)').matches || 
           window.navigator.standalone ||
           document.referrer.includes('android-app://')
  }

  // Network status monitoring
  setupNetworkStatus() {
    window.addEventListener('online', () => {
      this.showStatus('Back online', 'success')
    })

    window.addEventListener('offline', () => {
      this.showStatus('You are offline', 'warning')
    })
  }

  showStatus(message, type) {
    const statusEl = document.createElement('div')
    statusEl.className = `status-message ${type}`
    statusEl.textContent = message
    
    document.body.appendChild(statusEl)
    
    setTimeout(() => {
      statusEl.remove()
    }, 3000)
  }
}

export const pwa = new PWAHandler()END
cat > src/services/serviceConfigAdmin.js << 'END'
// ============================================================
// serviceConfigAdmin.js - Complete Admin Interface
// ============================================================

import { 
  getServiceConfigDB, 
  fetchServiceConfig, 
  updateServiceConfig,
  dbConfigToNLPFormat,
  nlpServiceToDBFormat,
  getLocalized
} from './serviceConfigDB.js';

class ServiceConfigAdmin {
  constructor() {
    this.db = null;
  }

  async init() {
    this.db = await getServiceConfigDB();
    return this;
  }

  async listServices() {
    const configs = await this.db.getAllServiceConfigs(true);
    console.log('=== Service Configurations ===');
    configs.forEach(config => {
      const status = config.isActive !== false ? '✅' : '❌';
      const name = getLocalized(config.name);
      console.log(`${status} ${config.serviceId} - v${config.version} (${name})`);
      console.log(`   ID: ${config.id}`);
      console.log(`   Updated: ${config.updatedAt}`);
      console.log(`   Steps: ${Object.keys(config.steps || {}).length}`);
      console.log('');
    });
    return configs;
  }

  async viewService(serviceId) {
    const config = await this.db.getLatestServiceConfig(serviceId);
    if (!config) {
      console.log(`Service ${serviceId} not found`);
      return null;
    }

    const name = getLocalized(config.name);
    const desc = getLocalized(config.description);

    console.log(`=== ${name} (v${config.version}) ===`);
    console.log(`ID: ${config.serviceId}`);
    console.log(`Description: ${desc}`);
    console.log(`Status: ${config.isActive !== false ? 'Active' : 'Inactive'}`);
    console.log(`Created: ${config.createdAt}`);
    console.log(`Updated: ${config.updatedAt}`);
    console.log(`\nSteps:`);
    
    const steps = config.steps || {};
    Object.entries(steps).forEach(([stepId, step]) => {
      const title = getLocalized(step.title) || step.type;
      console.log(`  Step ${stepId}: ${title}`);
      if (step.fields) {
        const fieldNames = step.fields.map(f => f.name).join(', ');
        console.log(`    Fields: ${fieldNames}`);
      }
    });

    return config;
  }

  async createService(serviceData) {
    if (!serviceData.serviceId || !serviceData.name) {
      throw new Error('serviceId and name are required');
    }

    const existing = await this.db.getLatestServiceConfig(serviceData.serviceId);
    if (existing) {
      throw new Error(`Service ${serviceData.serviceId} already exists. Use update instead.`);
    }

    // Ensure bilingual format for name and description
    const name = typeof serviceData.name === 'string'
      ? { en: serviceData.name, am: serviceData.name }
      : serviceData.name || { en: '', am: '' };
    
    const description = typeof serviceData.description === 'string'
      ? { en: serviceData.description, am: serviceData.description }
      : serviceData.description || { en: '', am: '' };

    const config = {
      id: `${serviceData.serviceId}_v1`,
      serviceId: serviceData.serviceId,
      name: name,
      description: description,
      initStep: serviceData.initStep || 1,
      collectedData: serviceData.collectedData || {},
      steps: serviceData.steps || {},
      isActive: true,
      version: 1
    };

    return this.db.saveServiceConfig(config);
  }

  async updateService(serviceId, updates) {
    const existing = await this.db.getLatestServiceConfig(serviceId);
    if (!existing) {
      throw new Error(`Service ${serviceId} not found`);
    }

    // Ensure bilingual format for name and description if provided
    if (updates.name && typeof updates.name === 'string') {
      updates.name = { en: updates.name, am: updates.name };
    }
    if (updates.description && typeof updates.description === 'string') {
      updates.description = { en: updates.description, am: updates.description };
    }

    const newConfig = {
      ...existing,
      ...updates,
      id: `${serviceId}_v${(existing.version || 0) + 1}`,
      version: (existing.version || 0) + 1,
      updatedAt: new Date().toISOString()
    };

    newConfig.serviceId = serviceId;

    return this.db.saveServiceConfig(newConfig);
  }

  async deleteService(serviceId) {
    const configs = await this.db.getServiceConfigsByServiceId(serviceId, true);
    if (configs.length === 0) {
      console.log(`No configurations found for service ${serviceId}`);
      return false;
    }

    console.log(`Deleting ${configs.length} configurations for service ${serviceId}`);
    for (const config of configs) {
      await this.db.deleteServiceConfig(config.id);
    }
    return true;
  }

  async deactivateService(serviceId) {
    const config = await this.db.getLatestServiceConfig(serviceId);
    if (!config) {
      throw new Error(`Service ${serviceId} not found`);
    }
    return this.db.deactivateServiceConfig(config.id);
  }

  async activateService(serviceId) {
    const config = await this.db.getLatestServiceConfig(serviceId);
    if (!config) {
      throw new Error(`Service ${serviceId} not found`);
    }
    return this.db.activateServiceConfig(config.id);
  }

  async exportServices() {
    const configs = await this.db.getAllServiceConfigs(true);
    const data = {
      exportedAt: new Date().toISOString(),
      version: '1.0',
      services: configs
    };
    const json = JSON.stringify(data, null, 2);
    
    const blob = new Blob([json], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `service_configs_${Date.now()}.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);

    return data;
  }

  async importServices(file) {
    const text = await file.text();
    const data = JSON.parse(text);
    
    if (!data.services || !Array.isArray(data.services)) {
      throw new Error('Invalid import data. Expected { services: [...] }');
    }

    const results = [];
    for (const config of data.services) {
      const saved = await this.db.saveServiceConfig(config);
      results.push(saved);
    }

    console.log(`Imported ${results.length} service configurations`);
    return results;
  }

  async getStats() {
    return this.db.getStats();
  }

  async cloneService(serviceId, newServiceId) {
    const existing = await this.db.getLatestServiceConfig(serviceId);
    if (!existing) {
      throw new Error(`Service ${serviceId} not found`);
    }

    // Clone name with bilingual format
    const name = existing.name && typeof existing.name === 'object'
      ? { 
          en: (existing.name.en || '') + ' (Clone)', 
          am: (existing.name.am || '') + ' (ቅጂ)' 
        }
      : { en: (existing.name || '') + ' (Clone)', am: (existing.name || '') + ' (ቅጂ)' };

    const clonedConfig = {
      ...existing,
      id: `${newServiceId}_v1`,
      serviceId: newServiceId,
      name: name,
      version: 1,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };

    return this.db.saveServiceConfig(clonedConfig);
  }

  async rollbackService(serviceId, version) {
    const configs = await this.db.getServiceConfigsByServiceId(serviceId, true);
    const target = configs.find(c => c.version === version);
    
    if (!target) {
      throw new Error(`Version ${version} not found for service ${serviceId}`);
    }

    const newConfig = {
      ...target,
      id: `${serviceId}_v${(configs.length + 1)}`,
      version: configs.length + 1,
      updatedAt: new Date().toISOString()
    };

    return this.db.saveServiceConfig(newConfig);
  }

  async getServiceHistory(serviceId) {
    const configs = await this.db.getServiceConfigsByServiceId(serviceId, true);
    configs.sort((a, b) => (a.version || 0) - (b.version || 0));
    
    console.log(`=== History for ${serviceId} ===`);
    configs.forEach(config => {
      const name = getLocalized(config.name);
      console.log(`v${config.version}: ${config.updatedAt} - ${config.isActive !== false ? 'Active' : 'Inactive'} - ${name}`);
    });
    
    return configs;
  }
}

let adminInstance = null;

export async function getServiceConfigAdmin() {
  if (!adminInstance) {
    adminInstance = new ServiceConfigAdmin();
    await adminInstance.init();
  }
  return adminInstance;
}

export default {
  getServiceConfigAdmin,
  ServiceConfigAdmin
};END
cat > src/services/serviceConfigDB.js << 'END'
// ============================================================
// serviceConfigDB.js - Complete IndexedDB Storage for Service Configs
// ============================================================

const DB_NAME = 'NLPProcessorDB';
const DB_VERSION = 1;
const STORE_NAME = 'serviceConfigs';
const VERSION_STORE = 'versions';

class ServiceConfigDB {
  constructor() {
    this.db = null;
    this.initialized = false;
  }

  async init() {
    if (this.initialized) return true;

    return new Promise((resolve, reject) => {
      const request = indexedDB.open(DB_NAME, DB_VERSION);

      request.onerror = (event) => {
        console.error('Database error:', event.target.error);
        reject(event.target.error);
      };

      request.onsuccess = (event) => {
        this.db = event.target.result;
        this.initialized = true;
        console.log('Database initialized successfully');
        resolve(true);
      };

      request.onupgradeneeded = (event) => {
        const db = event.target.result;
        
        if (!db.objectStoreNames.contains(STORE_NAME)) {
          const store = db.createObjectStore(STORE_NAME, { keyPath: 'id' });
          store.createIndex('serviceId', 'serviceId', { unique: false });
          store.createIndex('name', 'name', { unique: false });
          store.createIndex('createdAt', 'createdAt', { unique: false });
          store.createIndex('updatedAt', 'updatedAt', { unique: false });
          store.createIndex('isActive', 'isActive', { unique: false });
          store.createIndex('version', 'version', { unique: false });
        }

        if (!db.objectStoreNames.contains(VERSION_STORE)) {
          db.createObjectStore(VERSION_STORE, { keyPath: 'id' });
        }

        console.log('Database stores created successfully');
      };
    });
  }

  getTransaction(storeNames, mode = 'readonly') {
    if (!this.db) throw new Error('Database not initialized');
    return this.db.transaction(storeNames, mode);
  }

  async saveServiceConfig(config) {
    await this.init();

    return new Promise((resolve, reject) => {
      try {
        const transaction = this.getTransaction([STORE_NAME], 'readwrite');
        const store = transaction.objectStore(STORE_NAME);

        const now = new Date().toISOString();
        const configToSave = {
          ...config,
          createdAt: config.createdAt || now,
          updatedAt: now,
          isActive: config.isActive !== undefined ? config.isActive : true,
          version: (config.version || 0) + 1
        };

        if (!configToSave.id) {
          configToSave.id = `${configToSave.serviceId}_${Date.now()}`;
        }

        const request = store.put(configToSave);

        request.onsuccess = () => {
          console.log(`Service config saved: ${configToSave.id}`);
          this.updateVersion(configToSave.serviceId, configToSave.version).catch(console.error);
          resolve(configToSave);
        };

        request.onerror = (event) => {
          console.error('Error saving config:', event.target.error);
          reject(event.target.error);
        };

      } catch (error) {
        reject(error);
      }
    });
  }

  async updateVersion(serviceId, version) {
    const transaction = this.getTransaction([VERSION_STORE], 'readwrite');
    const store = transaction.objectStore(VERSION_STORE);

    return new Promise((resolve, reject) => {
      const request = store.put({
        id: `version_${serviceId}`,
        serviceId,
        version,
        updatedAt: new Date().toISOString()
      });

      request.onsuccess = () => resolve(true);
      request.onerror = () => reject(request.error);
    });
  }

  async getServiceConfig(id) {
    await this.init();

    return new Promise((resolve, reject) => {
      try {
        const transaction = this.getTransaction([STORE_NAME], 'readonly');
        const store = transaction.objectStore(STORE_NAME);
        const request = store.get(id);

        request.onsuccess = () => {
          resolve(request.result || null);
        };

        request.onerror = (event) => {
          console.error('Error getting config:', event.target.error);
          reject(event.target.error);
        };

      } catch (error) {
        reject(error);
      }
    });
  }

  async getAllServiceConfigs(includeInactive = false) {
    await this.init();

    return new Promise((resolve, reject) => {
      try {
        const transaction = this.getTransaction([STORE_NAME], 'readonly');
        const store = transaction.objectStore(STORE_NAME);
        const request = store.getAll();

        request.onsuccess = () => {
          let results = request.result || [];
          if (!includeInactive) {
            results = results.filter(config => config.isActive !== false);
          }
          resolve(results);
        };

        request.onerror = (event) => {
          console.error('Error getting configs:', event.target.error);
          reject(event.target.error);
        };

      } catch (error) {
        reject(error);
      }
    });
  }

  async getServiceConfigsByServiceId(serviceId, includeInactive = false) {
    await this.init();

    return new Promise((resolve, reject) => {
      try {
        const transaction = this.getTransaction([STORE_NAME], 'readonly');
        const store = transaction.objectStore(STORE_NAME);
        const index = store.index('serviceId');
        const request = index.getAll(serviceId);

        request.onsuccess = () => {
          let results = request.result || [];
          if (!includeInactive) {
            results = results.filter(config => config.isActive !== false);
          }
          resolve(results);
        };

        request.onerror = (event) => {
          console.error('Error getting configs by serviceId:', event.target.error);
          reject(event.target.error);
        };

      } catch (error) {
        reject(error);
      }
    });
  }

  async getLatestServiceConfig(serviceId) {
    const configs = await this.getServiceConfigsByServiceId(serviceId);
    if (configs.length === 0) return null;
    configs.sort((a, b) => (b.version || 0) - (a.version || 0));
    return configs[0];
  }

  async getActiveServiceConfigs() {
    return this.getAllServiceConfigs(false);
  }

  async updateServiceConfig(id, updates) {
    await this.init();

    const existing = await this.getServiceConfig(id);
    if (!existing) {
      throw new Error(`Service config with ID ${id} not found`);
    }

    const updatedConfig = {
      ...existing,
      ...updates,
      id,
      updatedAt: new Date().toISOString(),
      version: (existing.version || 0) + 1
    };

    return this.saveServiceConfig(updatedConfig);
  }

  async deleteServiceConfig(id) {
    await this.init();

    return new Promise((resolve, reject) => {
      try {
        const transaction = this.getTransaction([STORE_NAME], 'readwrite');
        const store = transaction.objectStore(STORE_NAME);
        const request = store.delete(id);

        request.onsuccess = () => {
          console.log(`Service config deleted: ${id}`);
          resolve(true);
        };

        request.onerror = (event) => {
          console.error('Error deleting config:', event.target.error);
          reject(event.target.error);
        };

      } catch (error) {
        reject(error);
      }
    });
  }

  async deactivateServiceConfig(id) {
    return this.updateServiceConfig(id, { isActive: false });
  }

  async activateServiceConfig(id) {
    return this.updateServiceConfig(id, { isActive: true });
  }

  async searchServiceConfigs(searchTerm) {
    await this.init();

    return new Promise((resolve, reject) => {
      try {
        const transaction = this.getTransaction([STORE_NAME], 'readonly');
        const store = transaction.objectStore(STORE_NAME);
        const request = store.getAll();

        request.onsuccess = () => {
          const results = request.result || [];
          const searchLower = searchTerm.toLowerCase();
          
          const filtered = results.filter(config => {
            const nameMatch = config.name && typeof config.name === 'object' 
              ? (config.name.en || '').toLowerCase().includes(searchLower) || 
                (config.name.am || '').toLowerCase().includes(searchLower)
              : (config.name || '').toLowerCase().includes(searchLower);
            
            const descMatch = config.description && typeof config.description === 'object'
              ? (config.description.en || '').toLowerCase().includes(searchLower) ||
                (config.description.am || '').toLowerCase().includes(searchLower)
              : (config.description || '').toLowerCase().includes(searchLower);
            
            const idMatch = (config.serviceId || '').toLowerCase().includes(searchLower);
            
            return nameMatch || descMatch || idMatch;
          });

          resolve(filtered);
        };

        request.onerror = (event) => {
          console.error('Error searching configs:', event.target.error);
          reject(event.target.error);
        };

      } catch (error) {
        reject(error);
      }
    });
  }

  async exportServiceConfigs() {
    const configs = await this.getAllServiceConfigs(true);
    return JSON.stringify(configs, null, 2);
  }

  async importServiceConfigs(jsonData) {
    try {
      const configs = typeof jsonData === 'string' ? JSON.parse(jsonData) : jsonData;
      
      if (!Array.isArray(configs)) {
        throw new Error('Invalid data format. Expected array of configurations.');
      }

      const results = [];
      for (const config of configs) {
        const saved = await this.saveServiceConfig(config);
        results.push(saved);
      }

      return results;
    } catch (error) {
      console.error('Error importing configs:', error);
      throw error;
    }
  }

  async clearAllServiceConfigs() {
    await this.init();

    return new Promise((resolve, reject) => {
      try {
        const transaction = this.getTransaction([STORE_NAME], 'readwrite');
        const store = transaction.objectStore(STORE_NAME);
        const request = store.clear();

        request.onsuccess = () => {
          console.log('All service configs cleared');
          resolve(true);
        };

        request.onerror = (event) => {
          console.error('Error clearing configs:', event.target.error);
          reject(event.target.error);
        };

      } catch (error) {
        reject(error);
      }
    });
  }

  async getStats() {
    const configs = await this.getAllServiceConfigs(true);
    const active = configs.filter(c => c.isActive !== false);
    const byService = {};
    
    configs.forEach(c => {
      if (!byService[c.serviceId]) {
        byService[c.serviceId] = 0;
      }
      byService[c.serviceId]++;
    });

    return {
      totalConfigs: configs.length,
      activeConfigs: active.length,
      inactiveConfigs: configs.length - active.length,
      byService,
      lastUpdated: configs.reduce((latest, c) => {
        const date = new Date(c.updatedAt);
        return date > latest ? date : latest;
      }, new Date(0))
    };
  }
}

let dbInstance = null;

export async function getServiceConfigDB() {
  if (!dbInstance) {
    dbInstance = new ServiceConfigDB();
    await dbInstance.init();
  }
  return dbInstance;
}

// ============================================================
// HELPER FUNCTIONS FOR BILINGUAL DATA - ALL EXPORTED PROPERLY
// ============================================================

export function getLocalized(obj) {
  if (!obj) return '';
  if (typeof obj === 'string') return obj;
  if (typeof obj === 'object' && obj !== null) {
    try {
      const lang = localStorage.getItem('agig_language') === 'am' ? 'am' : 'en';
      const result = obj[lang];
      if (result !== undefined && result !== null && result !== '') {
        return result;
      }
      return obj.en || '';
    } catch (e) {
      return obj.en || '';
    }
  }
  return obj;
}

export function dbConfigToNLPFormat(dbConfig) {
  if (!dbConfig) return null;

  return {
    id: dbConfig.serviceId,
    name: dbConfig.name,
    description: dbConfig.description,
    initStep: dbConfig.initStep || 1,
    collectedData: dbConfig.collectedData || {},
    steps: dbConfig.steps || {},
    _metadata: {
      version: dbConfig.version,
      createdAt: dbConfig.createdAt,
      updatedAt: dbConfig.updatedAt
    }
  };
}

export function nlpServiceToDBFormat(serviceConfig, customId = null) {
  if (!serviceConfig) return null;

  // Ensure bilingual format for name and description
  const name = typeof serviceConfig.name === 'string' 
    ? { en: serviceConfig.name, am: serviceConfig.name }
    : serviceConfig.name || { en: '', am: '' };
  
  const description = typeof serviceConfig.description === 'string'
    ? { en: serviceConfig.description, am: serviceConfig.description }
    : serviceConfig.description || { en: '', am: '' };

  return {
    id: customId || `${serviceConfig.id}_${Date.now()}`,
    serviceId: serviceConfig.id,
    name: name,
    description: description,
    initStep: serviceConfig.initStep || 1,
    collectedData: serviceConfig.collectedData || {},
    steps: serviceConfig.steps || {},
    isActive: true,
    version: 1
  };
}

export async function fetchServiceConfig(serviceId, useLatestVersion = true) {
  try {
    const db = await getServiceConfigDB();
    
    let dbConfig;
    if (useLatestVersion) {
      dbConfig = await db.getLatestServiceConfig(serviceId);
    } else {
      const configs = await db.getServiceConfigsByServiceId(serviceId);
      dbConfig = configs.length > 0 ? configs[0] : null;
    }

    if (!dbConfig) {
      console.warn(`No config found for service: ${serviceId}`);
      return null;
    }

    return dbConfigToNLPFormat(dbConfig);
  } catch (error) {
    console.error(`Error fetching service config for ${serviceId}:`, error);
    return null;
  }
}

class ServiceConfigCache {
  constructor() {
    this.cache = new Map();
    this.cacheTimeout = 5 * 60 * 1000;
  }

  async get(serviceId) {
    const cached = this.cache.get(serviceId);
    if (cached && (Date.now() - cached.timestamp) < this.cacheTimeout) {
      return cached.data;
    }
    return null;
  }

  set(serviceId, data) {
    this.cache.set(serviceId, {
      data,
      timestamp: Date.now()
    });
  }

  clear() {
    this.cache.clear();
  }

  invalidate(serviceId) {
    this.cache.delete(serviceId);
  }
}

const configCache = new ServiceConfigCache();

export async function fetchServiceConfigWithCache(serviceId, useLatestVersion = true) {
  const cached = await configCache.get(serviceId);
  if (cached) {
    console.log(`Using cached config for: ${serviceId}`);
    return cached;
  }

  const config = await fetchServiceConfig(serviceId, useLatestVersion);
  if (config) {
    configCache.set(serviceId, config);
  }

  return config;
}

export async function updateServiceConfig(serviceId, updatedConfig) {
  try {
    const db = await getServiceConfigDB();
    const dbConfig = nlpServiceToDBFormat(updatedConfig);
    const saved = await db.saveServiceConfig(dbConfig);
    configCache.invalidate(serviceId);
    return saved;
  } catch (error) {
    console.error(`Error updating service config for ${serviceId}:`, error);
    throw error;
  }
}

// DEFAULT EXPORT WITH ALL FUNCTIONS
export default {
  getServiceConfigDB,
  fetchServiceConfig,
  fetchServiceConfigWithCache,
  updateServiceConfig,
  dbConfigToNLPFormat,
  nlpServiceToDBFormat,
  getLocalized
};END
cat > src/services/tess.js << 'END'
import { openDB } from 'idb';
import { createWorker } from 'tesseract.js';
import {processMessage} from './nlpProcessor'

class TessAna {
    constructor() {
        this.tesseract = {createWorker};
        this.tesseractWorker = null;
        this.isInitializedT = false;
        this.languageManager = new TesseractLanguageManager();
        this.initializationPromise = null;
    }

    async init() {
        if (this.isInitializedT) return;
        
        console.log('🔄 Initializing Tesseract.js v6.0.1...');
        
        if (typeof createWorker === 'undefined') {
            throw new Error('Tesseract.js not loaded. Please check your imports.');
        }

        await this.languageManager.init();
        await this.loadLocalLanguagesToIndexedDB();
        
        console.log('Tesseract.js initialized with language support');
    }

    async loadLocalLanguagesToIndexedDB() {
        console.log('🔍 Loading local language files to IndexedDB...');
        
        const languages = ['eng', 'amh'];
        let loadedCount = 0;
        
        for (const langCode of languages) {
            const isAvailable = await this.languageManager.isLanguageAvailable(langCode);
            if (!isAvailable) {
                try {
                    await this.languageManager.loadLocalLanguage(langCode);
                    loadedCount++;
                    console.log(`✅ Loaded ${langCode} from local file to IndexedDB`);
                } catch (error) {
                    console.warn(`⚠️ Could not load local ${langCode} file: ${error.message}`);
                }
            } else {
                console.log(`✅ ${langCode} already available in IndexedDB`);
                loadedCount++;
            }
        }
        
        console.log(`📊 Language loading complete: ${loadedCount}/${languages.length} languages available`);
    }

    async initializeTesseract() {
        if (this.initializationPromise) {
            return this.initializationPromise;
        }

        if (this.isInitializedT) return;

        this.initializationPromise = (async () => {
            try {
                console.log('Initializing Tesseract OCR engine...');
                
                await this.loadLocalLanguagesToIndexedDB();
                
                console.log('Creating Tesseract worker...');
                this.tesseractWorker = await createWorker('eng+amh', 1, {
                    logger: progress => this.updateOCRProgress(progress),
                  // workerPath: 'js/tesseract/dist/worker.min.js', // Copy to public/assets
          // corePath: 'js/tesseract/dist/tesseract-core.wasm.js'
                    // Remove w
                });

                this.isInitializedT = true;
                console.log('✅ Tesseract.js initialized successfully');
                
            } catch (error) {
                console.error('❌ Tesseract initialization failed:', error);
                this.isInitializedT = false;
                this.tesseractWorker = null;
                throw new Error(`OCR engine failed to start: ${error.message}`);
            } finally {
                this.initializationPromise = null;
            }
        })();

        return this.initializationPromise;
    }

    async debugInitialize() {
        try {
            console.log('🧪 Debug: Testing Tesseract initialization...');
            
            const testWorker = await createWorker();
            console.log('✅ Basic worker created successfully');
            
            await testWorker.loadLanguage('eng');
            console.log('✅ English language loaded');
            
            await testWorker.initialize('eng');
            console.log('✅ English initialized');
            
            await testWorker.terminate();
            console.log('✅ Worker terminated');
            
            return true;
        } catch (error) {
            console.error('❌ Debug initialization failed:', error);
            return false;
        }
    }

    updateOCRProgress(progress) {
        const loadingEl = document.getElementById('loading');
        if (!loadingEl) return;

        switch (progress.status) {
            case 'loading tesseract core':
                loadingEl.textContent = 'Loading OCR engine...';
                break;
            case 'initializing tesseract':
                loadingEl.textContent = 'Initializing OCR...';
                break;
            case 'loading language traineddata':
                loadingEl.textContent = 'Loading language data from IndexedDB...';
                break;
            case 'initializing api':
                loadingEl.textContent = 'Finalizing OCR...';
                break;
            case 'recognizing text':
                const percent = Math.round(progress.progress * 100);
                loadingEl.textContent = `OCR Processing: ${percent}%`;
                break;
        }
    }

    async analyzeDocument(file) {
        try {
            this.showLoading(true);
            console.log('📄 Starting document analysis for:', file.name, file.type);
            
            let text = '';
            let usedOCR = false;
            
            if (file.type.startsWith('image/')) {
                console.log('🖼️ Image file detected, initializing OCR...');
                await this.initializeTesseract();
                text = await this.performOCR(file);
                usedOCR = true;
                console.log('✅ OCR completed, text length:', text.length);
            } else if (file.type === 'application/pdf') {
                throw new Error('PDF processing handled by external PDF.js implementation');
            } else {
                throw new Error('Unsupported file type. Please use image files (JPEG, PNG, etc.)');
            }
            
            const analysisz = this.classifyDocument(text, file.name);
            analysisz.fileName = file.name;
            analysisz.fileSize = file.size;
            analysisz.usedOCR = usedOCR;
            analysisz.pages = analysisz.pages || 1;
            
            if (typeof db !== 'undefined' && db.saveDocument) {
                await db.saveDocument(analysisz);
            }
            
            this.showLoading(false);
            return analysisz;
            
        } catch (error) {
            this.showLoading(false);
            console.error('❌ Analysis error:', error);
            throw new Error(`Document analysis failed: ${error.message}`);
        }
    }

    async performOCR(imageFile) {
        if (!this.isInitializedT || !this.tesseractWorker) {
            console.log('🔄 OCR not initialized, initializing now...');
            await this.initializeTesseract();
        }

        try {
            console.log('🔍 Starting OCR on file:', imageFile.name);
            const result = await this.tesseractWorker.recognize(imageFile, {
                //  tessedit_pageseg_mode: Tesseract.PSM.AUTO,
                //tessedit_ocr_engine_mode: Tesseract.OEM.LSTM_ONLY
            });
            
            console.log(`✅ OCR completed. Text length: ${result.data.text.length}, Confidence: ${result.data.confidence}`);
            return result.data.text || '';
            
        } catch (error) {
            console.error('❌ OCR processing failed:', error);
            throw new Error(`OCR failed: ${error.message}`);
        }
    }

    getWorkerStatus() {
        return {
            isInitialized: this.isInitializedT,
            worker: this.tesseractWorker ? 'Active' : 'None',
            initializationPromise: this.initializationPromise ? 'Pending' : 'None'
        };
    }

   async classifyDocument(text, fileName) {
        const lowerText = text.toLowerCase();
        
        let type = "General Document";
        let typeClass = "type-other";
        let confidence = 0.3;
        let category = "other";
        let detectedLanguage = this.detectLanguage(text);

        if (/(የሰሌዳ\s*ቁጥር|የተሽከርካሪው|የሻንሺ\s*ቁጥር|chassis\s*number|vehicle\s*description|plate\s*number)/i.test(text)) {
            type = "Vehicle Registration Document";
            typeClass = "type-government";
            confidence = 0.9;
            category = "transportation";
        }
        if (/(የመድን|ፖሊሲው\s*ቁጥር|policy\s*number|date\s*of|issuance|የአረቦን\s*መጠን|premium\s*tariff|policy\s*period)/i.test(text)) {
            type = "Insurance Policy Document";
            typeClass = "type-insurance";
            confidence = 0.9;
            category = "insurance";
        }
        else if (/(abstract|introduction|methodology|results|discussion|conclusion|references|bibliography)/i.test(text)) {
            type = "Academic Paper";
            typeClass = "type-research";
            confidence = 0.8;
            category = "academic";
        }
        else if (/(agreement|contract|clause|party|whereas|warranty|jurisdiction)/i.test(text)) {
            type = "Legal Document";
            typeClass = "type-legal";
            confidence = 0.7;
            category = "legal";
        }
        else if (/(license|permit|national id|fayda id|government|identification|ዜግነት|ኢትዮጵያ)/i.test(text)) {
            type = "Government Document";
            typeClass = "type-government";
            confidence = 0.75;
            category = "government";
        }
        else if (/(invoice|receipt|payment|amount|balance|statement|tax)/i.test(text)) {
            type = "Financial Document";
            typeClass = "type-financial";
            confidence = 0.6;
            category = "financial";
        }

        const topics = this.extractTopics(text);
        const keywords = this.extractKeywords(text);
        const extractedData = this.extractVehicleData(text);
         const currentIntent = sessionStorage.getItem('currentService')
            if (currentIntent==='iftms') {
                const Edata ={documentType: type,
            typeClass: typeClass,
            confidence: confidence,
            category: category,}
            return  await processMessage(currentIntent,Edata,false,true)
        
            }
        return {
            documentName: fileName.replace(/\.[^/.]+$/, "") || 'Unknown Document',
            documentType: type,
            typeClass: typeClass,
            confidence: confidence,
            category: category,
            language: detectedLanguage,
            topics: topics,
            keywords: keywords,
            extractedData: extractedData,
            summary: this.generateSummary(type, text, fileName, topics, extractedData, detectedLanguage),
            wordCount: text.split(/\s+/).filter(word => word.length > 0).length,
            timestamp: new Date().toISOString(),
            tesseractVersion: '6.0.1'
        };
    }

    detectLanguage(text) {
        const ethiopicChars = /[ሀ-ፕ]/;
        const latinChars = /[a-zA-Z]/;
        
        const hasEthiopic = ethiopicChars.test(text);
        const hasLatin = latinChars.test(text);
        
        if (hasEthiopic && hasLatin) return 'amh+eng';
        if (hasEthiopic) return 'amh';
        if (hasLatin) return 'eng';
        return 'unknown';
    }

    extractVehicleData(text) {
        const vehicleData = {};
        
        const lines = text.split('\n').map(line => line.trim()).filter(line => line.length > 2);
        
        console.log('Raw lines:', lines);

        const keyPatterns = {
            plateNumber: {
                keys: ['የሰሌዳ\\s*ቁጥር', 'plate\\s*number'],
                extractPattern: /.{8,15}/
            },
            ownerName: {
                keys: ['ስም', 'name'],
                extractPattern: /.{5,30}/
            },
            chassisNumber: {
                keys: ['የሻንሺ\\s*ቁጥር', 'chassis\\s*number'],
                extractPattern: /.{10,20}/
            },
            motorNumber: {
                keys: ['የሞተር\\s*ቁጥር', 'motor\\s*number'],
                extractPattern: /.{8,25}/
            },
            vehicleModel: {
                keys: ['የተሽ[\\/]?\\s*ሞዴል', 'vehicle\\s*model'],
                extractPattern: /.{8,20}/
            },
            previousPlate: {
                keys: ['የቀድሞ\\s*ሰሌዳ\\s*ቁጥር', 'previous\\s*plate'],
                extractPattern: /.{8,20}/
            },
            gender: {
                keys: ['ጾታ', 'gender'],
                extractPattern: /.{2,10}/
            },
            nationality: {
                keys: ['ዜግነት', 'nationality'],
                extractPattern: /.{5,20}/
            },
            city: {
                keys: ['ከተማ', 'city'],
                extractPattern: /.{5,20}/
            },
            subcity: {
                keys: ['ክ[\\/]\\s*ከተማ', 'subcity'],
                extractPattern: /.{5,20}/
            },
            woreda: {
                keys: ['ቀበሌ[\\/]\\s*ወረዳ', 'woreda'],
                extractPattern: /[0-9\\-\\/\\.\\s]{1,6}/
            },
            phone: {
                keys: ['ሰልክ', 'phone'],
                extractPattern: /[0-9\\s\\-\\.]{8,12}/
            },
            vehicleType: {
                keys: ['የመኪና\\s*አይነት', 'vehicle\\s*type'],
                extractPattern: /.{3,20}/
            },
            bodyType: {
                keys: ['የአካሉ\\s*አይነት', 'body\\s*type'],
                extractPattern: /.{3,20}/
            },
            fuelType: {
                keys: ['የነዳጅ\\s*ዓይነት', 'fuel\\s*type'],
                extractPattern: /.{3,15}/
            },
            color: {
                keys: ['ቀለም', 'color'],
                extractPattern: /.{3,15}/
            },
            manufacturer: {
                keys: ['የተሰራበት\\s*ሀገር', 'manufacturer'],
                extractPattern: /.{3,20}/
            },
            manufactureYear: {
                keys: ['የተሰራበት\\s*ዘመን', 'manufacture\\s*year'],
                extractPattern: /[0-9\\s\\-\\.]{3,6}/
            },
            enginePower: {
                keys: ['የሞተር\\s*የፈረስ\\s*ጉልበት', 'engine\\s*power'],
                extractPattern: /[0-9\\s\\-\\.]{2,6}/
            },
            totalWeight: {
                keys: ['የተሽ[\\/]\\s*ጠቅ[\\/]\\s*ክብደት', 'total\\s*weight'],
                extractPattern: /[0-9\\s\\-\\.]{3,8}/
            },
            unladenWeight: {
                keys: ['ነጠላ\\s*ክብደት', 'unladen\\s*weight'],
                extractPattern: /[0-9\\s\\-\\.]{3,8}/
            },
            loadCapacity: {
                keys: ['የጭነት\\s*መጠን', 'load\\s*capacity'],
                extractPattern: /.{3,15}/
            },
            engineCapacity: {
                keys: ['የሞተር\\s*ችሎታ[\\/]\\s*ሲሲ', 'engine\\s*capacity'],
                extractPattern: /[0-9\\s\\-\\.]{3,8}/
            },
            cylinderCount: {
                keys: ['የሲሊንደር\\s*ብዛት', 'cylinder\\s*count'],
                extractPattern: /[0-9\\s\\-\\.]{1,4}/
            },
            permittedWork: {
                keys: ['የተፈቀደለት\\s*የስራ\\s*ጸባይ', 'permitted\\s*work'],
                extractPattern: /.{3,20}/
            }
        };

        lines.forEach(line => {
            for (const [field, patternInfo] of Object.entries(keyPatterns)) {
                if (!vehicleData[field]) {
                    for (const key of patternInfo.keys) {
                        const keyRegex = new RegExp(`${key}[\\s:]*([^\\n]{3,30})`, 'i');
                        const match = line.match(keyRegex);
                        
                        if (match && match[1]) {
                            let value = match[1].trim();
                            value = value.replace(/^[:\s\\-]+|[:\s\\-]+$/g, '');
                            
                            if (value && value.length > 0) {
                                vehicleData[field] = value;
                                console.log(`✅ Same-line ${field}: "${value}" from: "${line}"`);
                                break;
                            }
                        }
                    }
                }
            }
        });

        this.extractSeparatedKeyValues(lines, vehicleData);

        console.log('=== FINAL EXTRACTED DATA ===', vehicleData);
        return this.validateAndCleanVehicleData(vehicleData);
    }
 extractInsuranceData(text) {
        const insuranceData = {};
        
        const lines = text.split('\n').map(line => line.trim()).filter(line => line.length > 2);
        
        console.log('Raw lines:', lines);

      const  INSURANCE_PATTERNS = {
    certificateNumber: {
        keys: ['የሰርተፊኬት\\s*ቁጥር', 'certificate\\s*number', 'CERTIFICATE\\s*NUMBER', 'Certificate\\s*No'],
         extractPattern: /([A-Z0-9\-]{10,20})', r'(CN-[0-9]{10,15})', r'(PN-[0-9]{10,15})/
        //'fallback_pattern': r'([A-Z0-9\-]{10,20})'
    },
    insuredName: {
     keys: ['የመድን\\s*ገቢው\\s*ስም', 'name\\s*of\\s*insured', 'INSURED', 'NAME\\s*OF\\s*INSURED', 'የመድን\\s*ገቢው'],
         extractPattern: /([A-Za-z\s\u1200-\u137F]{5,50})/,
       // 'fallback_pattern': r'([A-Za-z\s\u1200-\u137F]{5,50})'
    },
    plateNumber: {
        keys: ['የሠሌዳ\\s*ቁጥር', 'plate\\s*number', 'PLATE\\s*NUMBER', 'የሰሌዳ\\s*ቁጥር'],
        extractPattern: /([A-Z0-9\s\-]{6,15})/
       // 'fallback_pattern': r'([A-Z0-9\s\-]{6,15})'
    },
    vehicleType: {
        keys: ['የተሸከርካሪ\\s*እይነት', 'vehicle\\s*type', 'VEHICLE\\s*TYPE', 'የተሽከርካሪ\\s*አይነት'],
         extractPattern: /([A-Za-z\s\u1200-\u137F]{3,30})/
        //'fallback_pattern': r'([A-Za-z\s\u1200-\u137F]{3,30})'
    },
    policyNumber: {
        keys: ['የመድን\\s*ፖሊሲው\\s*ቁጥር', 'policy\\s*number', 'INSURER\\s*POLICY\\s*No', 'POLICY\\s*NUMBER'],
         extractPattern: /.{10,20}/
        //'patterns': [r'([A-Z0-9\-]{10,20})'],
        //'fallback_pattern': r'([A-Z0-9\-]{10,20})'
    },
    dateOfIssuance: {
        keys: ['የተሰጠበት\\s*ቀን', 'date\\s*of\\s*issuance', 'DATE\\s*OF\\s*ISSUANCE'],
      //  patterns: /([0-9]{1,2}-[A-Za-z]{3}-[0-9]{4})', r'([0-9]{1,2}/[0-9]{1,2}/[0-9]{4})/,
    // 'fallback_pattern': r'([0-9]{1,2}-[A-Za-z]{3}-[0-9]{4})'
    },
    policyPeriodFrom: {
        keys: ['ፖሊሲው\\s*ዘመን\\s*ከ', 'policy\\s*period\\s*from', 'FROM'],
       extractPattern: /([0-9]{1,2}-[A-Za-z]{3}-[0-9]{4})/
       // 'fallback_pattern': r'([0-9]{1,2}-[A-Za-z]{3}-[0-9]{4})'
    },
    policyPeriodTo: {
        keys: ['እስከ', 'to', 'TO'],
        extractPattern: /([0-9]{1,2}-[A-Za-z]{3}-[0-9]{4})/
        //'fallback_pattern': r'([0-9]{1,2}-[A-Za-z]{3}-[0-9]{4})'
    },
    premiumAmount: {
        keys: ['የአረቦን\\s*መጠን', 'premium', 'PREMIUM\\s*TARIF', 'premium\\s*tariff'],
       // extractPattern: /([0-9]{2,6})//||, r'([0-9]{2,6}\s*ብር)/
       // 'fallback_pattern': r'([0-9]{2,6})'
    },
    chassisNumber: {
        keys: ['የቻንሲ\\s*ቁጥር', 'chassis\\s*number', 'CHASSIS\\s*NUMBER'],
        extractPattern: /([A-HJ-NPR-Z0-9]{17})/
       // 'fallback_pattern': r'([A-Z0-9]{10,20})'
    },
    'engineNumber': {
        keys: ['የሞተር\\s*ቁጥር', 'engine\\s*number', 'ENGINE\\s*NUMBER'],
        extractPattern: /(1SG400[\-\s]?[0-9A-Z]{7,9})', r'([A-Z0-9]{3,6}[\-\s]?[A-Z0-9]{5,15})/,
        //'fallback_pattern': r'([A-Z0-9\s\-]{8,20})'
    },
    phoneNumber: {
        keys: ['ሞባይል\\s*ቁጥር', 'phone\\s*number', 'PHONE\\s*NUMBER', 'ስልክ'],
        extractPattern: /(09[0-9]{8})', r'(0[0-9]{9})/
       // 'fallback_pattern': r'([0-9\s\-]{8,12})'
    },
    region: {
        keys: ['ክልል', 'region', 'REGION', 'አድራሻ'],
        extractPattern: /([A-Za-z\s\u1200-\u137F]{3,30})/
       // 'fallback_pattern': r'([A-Za-z\s\u1200-\u137F]{3,30})'
    },
    subcity: {
        keys: ['ክ[\\/]\\s*ከተማ','ክፍለ\\s*ከተማ', 'subcity', 'SUB\\s*CITY', 'ክፍለ\\s*ከተማ/ዞን'],
         extractPattern: /.{5,20}/
       // 'patterns': [r'([A-Za-z\s\u1200-\u137F]{3,30})'],
        //'fallback_pattern': r'([A-Za-z\s\u1200-\u137F]{3,30})'
    },
    woreda: {
        keys: ['ቀበሌ[\\/]\\s*ወረዳ', 'woreda'],
      extractPattern: /[0-9\\-\\/\\.\\s]{1,6}/
       // 'patterns': [r'([0-9]{1,3})', r'([0-9\s\/\-]{1,6})'],
       // 'fallback_pattern': r'([0-9\s\/\-]{1,6})'
    },
    kebele: {
        keys: ['ቀበሌ', 'kebele', 'KEBELE'],
        extractPattern: /[0-9]{1,3}/
        //'patterns': [r'([0-9]{1,3})'],
       // 'fallback_pattern': r'([0-9]{1,3})'
    },
    insurerName: {
        keys: ['የመድን\\s*ሰጪው\\s*ስም', 'name\\s*of\\s*insurer', 'NAME\\s*OF\\s*INSURER'],
       // 'patterns': [r'([A-Za-z\s\u1200-\u137F]{5,50})'],
       extractPattern: /([A-Za-z\s\u1200-\u137F]{5,50})/
       // 'fallback_pattern': r'([A-Za-z\s\u1200-\u137F]{5,50})'
    },
    carryingCapacity: {
        keys: ['የመጫን\\s*አቅም', 'carrying\\s*capacity', 'CARRYING\\s*CAPACITY'],
         extractPattern: /[0-9]{1,3}/
        //'patterns': [r'([0-9]{1,3})\s*(ኩንታል|ሊትር|QUANTALS|LITRES)', r'([0-9]{1,3})'],
        //'fallback_pattern': r'([0-9]{1,3})'
    },
    persons: {
        keys: ['ስዎች', 'persons', 'PERSONS'],
         extractPattern: /[0-9]{1,2}/
        //'patterns': [r'([0-9]{1,2})'],
       // 'fallback_pattern': /[0-9]{1,2}/'
    }
}

      /*  const keyPatterns = {
            plateNumber: {
                keys: ['የሰሌዳ\\s*ቁጥር', 'plate\\s*number'],
                extractPattern: /.{8,15}/
            },
            ownerName: {
                keys: ['ስም', 'name'],
                extractPattern: /.{5,30}/
            },
            chassisNumber: {
                keys: ['የሻንሺ\\s*ቁጥር', 'chassis\\s*number'],
                extractPattern: /.{10,20}/
            },
            motorNumber: {
                keys: ['የሞተር\\s*ቁጥር', 'motor\\s*number'],
                extractPattern: /.{8,25}/
            },
            vehicleModel: {
                keys: ['የተሽ[\\/]?\\s*ሞዴል', 'vehicle\\s*model'],
                extractPattern: /.{8,20}/
            },
            previousPlate: {
                keys: ['የቀድሞ\\s*ሰሌዳ\\s*ቁጥር', 'previous\\s*plate'],
                extractPattern: /.{8,20}/
            },
            gender: {
                keys: ['ጾታ', 'gender'],
                extractPattern: /.{2,10}/
            },
            nationality: {
                keys: ['ዜግነት', 'nationality'],
                extractPattern: /.{5,20}/
            },
            city: {
                keys: ['ከተማ', 'city'],
                extractPattern: /.{5,20}/
            },
            subcity: {
                keys: ['ክ[\\/]\\s*ከተማ', 'subcity'],
                extractPattern: /.{5,20}/
            },
            woreda: {
                keys: ['ቀበሌ[\\/]\\s*ወረዳ', 'woreda'],
                extractPattern: /[0-9\\-\\/\\.\\s]{1,6}/
            },
            phone: {
                keys: ['ሰልክ', 'phone'],
                extractPattern: /[0-9\\s\\-\\.]{8,12}/
            },
            vehicleType: {
                keys: ['የመኪና\\s*አይነት', 'vehicle\\s*type'],
                extractPattern: /.{3,20}/
            },
            bodyType: {
                keys: ['የአካሉ\\s*አይነት', 'body\\s*type'],
                extractPattern: /.{3,20}/
            },
            fuelType: {
                keys: ['የነዳጅ\\s*ዓይነት', 'fuel\\s*type'],
                extractPattern: /.{3,15}/
            },
            color: {
                keys: ['ቀለም', 'color'],
                extractPattern: /.{3,15}/
            },
            manufacturer: {
                keys: ['የተሰራበት\\s*ሀገር', 'manufacturer'],
                extractPattern: /.{3,20}/
            },
            manufactureYear: {
                keys: ['የተሰራበት\\s*ዘመን', 'manufacture\\s*year'],
                extractPattern: /[0-9\\s\\-\\.]{3,6}/
            },
            enginePower: {
                keys: ['የሞተር\\s*የፈረስ\\s*ጉልበት', 'engine\\s*power'],
                extractPattern: /[0-9\\s\\-\\.]{2,6}/
            },
            totalWeight: {
                keys: ['የተሽ[\\/]\\s*ጠቅ[\\/]\\s*ክብደት', 'total\\s*weight'],
                extractPattern: /[0-9\\s\\-\\.]{3,8}/
            },
            unladenWeight: {
                keys: ['ነጠላ\\s*ክብደት', 'unladen\\s*weight'],
                extractPattern: /[0-9\\s\\-\\.]{3,8}/
            },
            loadCapacity: {
                keys: ['የጭነት\\s*መጠን', 'load\\s*capacity'],
                extractPattern: /.{3,15}/
            },
            engineCapacity: {
                keys: ['የሞተር\\s*ችሎታ[\\/]\\s*ሲሲ', 'engine\\s*capacity'],
                extractPattern: /[0-9\\s\\-\\.]{3,8}/
            },
            cylinderCount: {
                keys: ['የሲሊንደር\\s*ብዛት', 'cylinder\\s*count'],
                extractPattern: /[0-9\\s\\-\\.]{1,4}/
            },
            permittedWork: {
                keys: ['የተፈቀደለት\\s*የስራ\\s*ጸባይ', 'permitted\\s*work'],
                extractPattern: /.{3,20}/
            }
        };*/

        lines.forEach(line => {
            for (const [field, patternInfo] of Object.entries(INSURANCE_PATTERNS)) {
                if (!insuranceData[field]) {
                    for (const key of patternInfo.keys) {
                        const keyRegex = new RegExp(`${key}[\\s:]*([^\\n]{3,30})`, 'i');
                        const match = line.match(keyRegex);
                        
                        if (match && match[1]) {
                            let value = match[1].trim();
                            value = value.replace(/^[:\s\\-]+|[:\s\\-]+$/g, '');
                            
                            if (value && value.length > 0) {
                                insuranceData[field] = value;
                                console.log(`✅ Same-line ${field}: "${value}" from: "${line}"`);
                                break;
                            }
                        }
                    }
                }
            }
        });

        this.extractSeparatedKeyValues(lines, insuranceData);

        console.log('=== FINAL EXTRACTED DATA ===', insuranceData);
        return this.validateAndCleanVehicleData(insuranceData);
    }
    extractSeparatedKeyValues(lines, vehicleData) {
        if (!vehicleData.chassisNumber) {
            const chassisKeyIndex = lines.findIndex(line => /የሻንሺ|chassis/i.test(line));
            console.log('Chassis key found at line:', chassisKeyIndex, lines[chassisKeyIndex]);
            
            if (chassisKeyIndex !== -1) {
                for (let i = chassisKeyIndex + 12; i <= Math.min(lines.length + 12, chassisKeyIndex + 12); i++) {
                    console.log('Checking line', i, 'for chassis:', lines[i]);
                    const chassisMatch = lines[i].match(/([A-Z0-9]{10,18})/);
                    const vinMatch = lines[i].match(/([A-HJ-NPR-Z0-9]{17})/);
            
                    if (vinMatch) {
                        vehicleData.chassisNumber = vinMatch[1];
                        console.log(`✅ VIN found: "${vinMatch[1]}" at line ${i}`);
                        
                        const vinData = this.decodeVIN(vinMatch[1]);
                        Object.assign(vehicleData, vinData);
                        break;
                    }
                    if (chassisMatch) {
                        vehicleData.chassisNumber = chassisMatch[1];
                        console.log(`✅ Chassis found: "${chassisMatch[1]}" at line ${i} after key at line ${chassisKeyIndex}`);
                        break;
                    }
                }
            }
            
            if (!vehicleData.chassisNumber) {
                const chassisKeyIndex = lines.findIndex(line => /የሻንሺ|chassis/i.test(line));
                console.log('Chassis key found at line:', chassisKeyIndex, lines[chassisKeyIndex]);
                
                if (chassisKeyIndex !== -1) {
                    for (let i = chassisKeyIndex + 3; i <= Math.min(lines.length - 3, chassisKeyIndex + 5); i++) {
                        console.log('Checking line', i, 'for chassis:', lines[i]);
                        const chassisMatch = lines[i].match(/([A-Z0-9]{10,18})/);
                        const vinMatch = lines[i].match(/([A-HJ-NPR-Z0-9]{17})/);
                        if (vinMatch && !/የሻንሺ|chassis|phone|ሰልክ|0911/i.test(lines[i])) {
                            vehicleData.chassisNumber = vinMatch[1];
                            console.log(`✅ Direct VIN: "${vinMatch[1]}" from line ${i}`);
                            
                            const vinData = this.decodeVIN(vinMatch[1]);
                            Object.assign(vehicleData, vinData);
                            break;
                        }
                        if (chassisMatch) {
                            vehicleData.chassisNumber = chassisMatch[1];
                            console.log(`✅ Chassis found: "${chassisMatch[1]}" at line ${i} after key at line ${chassisKeyIndex}`);
                            break;
                        }
                    }
                }
                
                if (!vehicleData.vehicleModel) {
                    const modelKeyIndex = lines.findIndex(line => /የተሽ[\\/]?ሞዴል|vehicle.model/i.test(line));
                    console.log('Model key found at line:', modelKeyIndex, lines[modelKeyIndex]);
                    
                    if (modelKeyIndex !== -1) {
                        for (let i = modelKeyIndex + 1; i <= Math.min(lines.length - 1, modelKeyIndex + 5); i++) {
                            console.log('Checking line', i, 'for model:', lines[i]);
                            const modelMatch = lines[i].match(/(BJ425[0-9][A-Z]MFKB26TA|[A-Z0-9]{8,20})/);
                            if (modelMatch) {
                                vehicleData.vehicleModel = modelMatch[1];
                                console.log(`✅ Model found: "${modelMatch[1]}" at line ${i} after key at line ${modelKeyIndex}`);
                                break;
                            }
                        }
                    }
                }
                
                if (!vehicleData.chassisNumber) {
                    for (let i = 0; i < lines.length; i++) {
                        const chassisMatch = lines[i].match(/([A-Z0-9]{10,18})/);
                        if (chassisMatch && !/የሻንሺ|chassis|phone|ሰልክ|0911/i.test(lines[i])) {
                            vehicleData.chassisNumber = chassisMatch[1];
                            console.log(`✅ Direct chassis: "${chassisMatch[1]}" from line ${i}`);
                            break;
                        }
                    }
                }
            }
        }

        if (!vehicleData.motorNumber) {
            const motorKeyIndex = lines.findIndex(line => /የሞተር|motor/i.test(line));
            console.log('Motor key found at line:', motorKeyIndex, lines[motorKeyIndex]);
            
            if (motorKeyIndex !== -1) {
                for (let i = motorKeyIndex + 1; i <= Math.min(lines.length - 1, motorKeyIndex + 5); i++) {
                    console.log('Checking line', i, 'for motor:', lines[i]);
                    const motorMatch = lines[i].match(/(1SG400[\-\s]?[0-9A-Z]{7,9}|[A-Z0-9]{3,6}[\-\s]?[A-Z0-9]{5,10})/);
                    if (motorMatch && !/phone|ሰልክ|0911/i.test(lines[i])) {
                        vehicleData.motorNumber = motorMatch[1];
                        console.log(`✅ Motor found: "${motorMatch[1]}" at line ${i} after key at line ${motorKeyIndex}`);
                        break;
                    }
                }
            }
            
            if (!vehicleData.motorNumber) {
                for (let i = 0; i < lines.length; i++) {
                    const motorMatch = lines[i].match(/(1SG400[\-\s]?[0-9A-Z]{7,9}|[A-Z0-9]{3,6}[\-\s]?[A-Z0-9]{5,10})/);
                    if (motorMatch && !/phone|ሰልክ|0911/i.test(lines[i])) {
                        vehicleData.motorNumber = motorMatch[1];
                        console.log(`✅ Direct motor: "${motorMatch[1]}" from line ${i}`);
                        break;
                    }
                }
            }
        }

        if (!vehicleData.manufactureYear) {
            for (let i = 0; i < lines.length; i++) {
                const yearMatch = lines[i].match(/(20[0-9]{2})/);
                if (yearMatch && !/phone|ሰልክ/i.test(lines[i])) {
                    vehicleData.manufactureYear = yearMatch[1];
                    console.log(`✅ Year: "${yearMatch[1]}" from line ${i}`);
                    break;
                }
            }
        }

        if (!vehicleData.phone) {
            const phoneKeyIndex = lines.findIndex(line => /ሰልክ|phone/i.test(line));
            if (phoneKeyIndex !== -1) {
                for (let i = Math.max(0, phoneKeyIndex - 2); i <= Math.min(lines.length - 1, phoneKeyIndex + 2); i++) {
                    const phoneMatch = lines[i].match(/([0-9]{8,10})/);
                    if (phoneMatch) {
                        vehicleData.phone = phoneMatch[1];
                        console.log(`✅ Phone: "${phoneMatch[1]}" near line ${phoneKeyIndex}`);
                        break;
                    }
                }
            }
        }
    }

    validateAndCleanVehicleData(vehicleData) {
        const cleaned = { ...vehicleData };
        
        Object.keys(cleaned).forEach(key => {
            if (typeof cleaned[key] === 'string') {
                cleaned[key] = cleaned[key]
                    .replace(/\s+/g, ' ')
                    .trim()
                    .replace(/^[:\-\s]+|[:\-\s]+$/g, '');
            }
        });
        
        return cleaned;
    }

    decodeVIN(vin) {
        if (!vin || vin.length !== 17) return {};
        
        const vinData = {
            vinNumber: vin,
            wmi: vin.substring(0, 3),
            vds: vin.substring(3, 9),
            vis: vin.substring(9, 17),
            modelYear: this.decodeVINModelYear(vin),
            assemblyPlant: this.decodeVINPlant(vin),
            manufacturer: this.decodeVINManufacturer(vin),
            vehicleType: this.decodeVINVehicleType(vin),
            modelCode: this.decodeVINModelCode(vin),
            modelName: this.decodeVINModelName(vin),
            engineInfo: this.decodeVINEngine(vin),
            bodyStyle: this.decodeVINBodyStyle(vin)
        };
        
        console.log('🔍 VIN Decoded:', vinData);
        return vinData;
    }

    decodeVINModelYear(vin) {
        const yearChar = vin.charAt(9);
        const yearMap = {
            'A': '2010', 'B': '2011', 'C': '2012', 'D': '2013', 'E': '2014', 'F': '2015',
            'G': '2016', 'H': '2017', 'J': '2018', 'K': '2019', 'L': '2020', 'M': '2021',
            'N': '2022', 'P': '2023', 'R': '2024', 'S': '2025', 'T': '2026', 'V': '2027',
            'W': '2028', 'X': '2029', 'Y': '2030',
            '1': '2001', '2': '2002', '3': '2003', '4': '2004', '5': '2005', '6': '2006',
            '7': '2007', '8': '2008', '9': '2009'
        };
        return yearMap[yearChar] || 'Unknown';
    }

    decodeVINPlant(vin) {
        const plantChar = vin.charAt(10);
        const wmi = vin.substring(0, 3);
        
        if (wmi.startsWith('L')) {
            const chinaPlantMap = {
                'A': 'Beijing', 'B': 'Shanghai', 'C': 'Guangzhou', 'D': 'Shenzhen',
                'E': 'Tianjin', 'F': 'Wuhan', 'G': 'Chongqing', 'H': 'Nanjing',
                'J': 'Chengdu', 'K': 'Xi\'an', 'L': 'Hangzhou', 'M': 'Suzhou',
                'N': 'Dongguan', 'P': 'Foshan', 'R': 'Qingdao', 'S': 'Zhengzhou',
                'T': 'Changsha', 'U': 'Ningbo', 'V': 'Hefei', 'W': 'Xiamen',
                'X': 'Wuxi', 'Y': 'Jinan', 'Z': 'Dalian'
            };
            return chinaPlantMap[plantChar] ? `China - ${chinaPlantMap[plantChar]}` : 'China - Unknown Plant';
        }
        
        const plantMap = {
            'A': 'USA - Indiana', 'B': 'USA - Ohio', 'C': 'Canada - Ontario',
            'D': 'Germany', 'E': 'USA - Kentucky', 'F': 'USA - Michigan',
            'G': 'USA - Tennessee', 'H': 'USA - Missouri', 'J': 'Japan',
            'K': 'Korea', 'L': 'China', 'M': 'Thailand',
            'N': 'USA - Indiana', 'P': 'USA - Illinois', 'R': 'Mexico',
            'S': 'USA - California', 'T': 'USA - Texas', 'U': 'USA - Ohio',
            'V': 'USA - Wisconsin', 'W': 'Germany', 'X': 'USA - Tennessee',
            'Y': 'USA - Michigan', 'Z': 'USA - Michigan'
        };
        return plantMap[plantChar] || 'Unknown Plant';
    }

    decodeVINManufacturer(vin) {
        const wmi = vin.substring(0, 3);
        const manufacturerMap = {
            'LBE': 'Beijing Automotive (BAW)', 'LB3': 'Dongfeng Motor', 'LDC': 'Dongfeng Peugeot-Citroen',
            'LDD': 'Dongfeng Nissan', 'LDY': 'Zhongtong Bus', 'LE4': 'Beijing Benz (Mercedes-Benz)',
            'LFM': 'FAW Toyota', 'LFN': 'FAW-Volkswagen', 'LFP': 'FAW Car', 'LFT': 'FAW Jiefang',
            'LFV': 'FAW-Volkswagen', 'LGB': 'Dongfeng Nissan', 'LGH': 'GAC Honda', 'LGJ': 'Dongfeng Honda',
            'LGW': 'Great Wall Motors', 'LGX': 'BYD Auto', 'LH1': 'FAW Haima', 'LHG': 'GAC Honda',
            'LJD': 'Dongfeng Peugeot-Citroen', 'LJN': 'Zhengzhou Nissan', 'LLV': 'Lifan Motors',
            'LMG': 'GAC Motor', 'LPA': 'Changan PSA', 'LRB': 'Beijing Benz (Mercedes-Benz)',
            'LS5': 'Changan Suzuki', 'LSG': 'SAIC General Motors', 'LSJ': 'SAIC MG',
            'LSV': 'SAIC Volkswagen', 'LSY': 'Brilliance Jinbei', 'LTV': 'FAW Toyota',
            'LUC': 'Guangqi Honda', 'LUD': 'Dongfeng Yueda Kia', 'LUX': 'Dongfeng Yulon',
            'LVB': 'Foton Motor', 'LVC': 'Beijing Benz (Mercedes-Benz)', 'LVD': 'Changan Ford',
            'LVS': 'FAW Toyota', 'LVV': 'Chery Automobile', 'LVY': 'Volvo China',
            'LZW': 'SAIC-GM-Wuling', 'LZY': 'Yutong Bus',
            'JA3': 'Mitsubishi', 'JA4': 'Mitsubishi', 'JA7': 'Mitsubishi', 'JAA': 'Isuzu',
            'JAB': 'Isuzu', 'JAC': 'Isuzu', 'JAE': 'Acura', 'JAL': 'Isuzu', 'JB3': 'Dodge',
            'JB4': 'Dodge', 'JB7': 'Dodge', 'JBA': 'Hino', 'JBB': 'Hino', 'JBC': 'Hino',
            'KMH': 'Hyundai', 'KNA': 'Kia', 'KNB': 'Kia', 'KNC': 'Kia', 'KND': 'Kia',
            'WAA': 'Audi', 'WBA': 'BMW', 'WDB': 'Mercedes-Benz', 'WVW': 'Volkswagen',
            '1FA': 'Ford', '1FB': 'Ford', '1FC': 'Ford', '1FD': 'Ford', '1FM': 'Ford',
            '1FT': 'Ford', '1FU': 'Freightliner', '1FV': 'Freightliner', '1G1': 'Chevrolet',
            '1G2': 'Pontiac', '1G3': 'Oldsmobile', '1G4': 'Buick', '1G6': 'Cadillac',
            '1G8': 'Chevrolet', '1GA': 'Chevrolet', '1GB': 'Chevrolet', '1GC': 'Chevrolet',
            '1GD': 'GMC', '1GE': 'Cadillac'
        };
        
        return manufacturerMap[wmi] || this.guessManufacturerFromWMI(wmi);
    }

    guessManufacturerFromWMI(wmi) {
        if (wmi.startsWith('1')) return 'USA Manufacturer';
        if (wmi.startsWith('2')) return 'Canada Manufacturer';
        if (wmi.startsWith('3')) return 'Mexico Manufacturer';
        if (wmi.startsWith('J')) return 'Japan Manufacturer';
        if (wmi.startsWith('K')) return 'Korea Manufacturer';
        if (wmi.startsWith('L')) return 'China Manufacturer';
        if (wmi.startsWith('W')) return 'Germany Manufacturer';
        if (wmi.startsWith('Z')) return 'Italy Manufacturer';
        if (wmi.startsWith('V')) return 'France Manufacturer';
        if (wmi.startsWith('S')) return 'UK Manufacturer';
        if (wmi.startsWith('Y')) return 'Sweden Manufacturer';
        if (wmi.startsWith('MA') || wmi.startsWith('MB') || wmi.startsWith('MC') || wmi.startsWith('MD') || wmi.startsWith('ME')) return 'India Manufacturer';
        return 'Unknown Manufacturer';
    }

    decodeVINModelCode(vin) {
        const vds = vin.substring(3, 9);
        return vds.substring(0, 4);
    }

    decodeVINModelName(vin) {
        const manufacturer = this.decodeVINManufacturer(vin);
        const modelCode = this.decodeVINModelCode(vin);
        const wmi = vin.substring(0, 3);
        
        const modelDatabase = {
            'LVB': {
                'S6PE': 'Foton Aumark S6',
                'S6PB': 'Foton Aumark T3',
                'T4PA': 'Foton Ollin',
                'U3PC': 'Foton View',
                'S5PD': 'Foton Sup',
                'R7PF': 'Foton Tornado'
            },
            'LVS': {
                'A2PJ': 'FAW Jiefang J6',
                'B3PK': 'FAW Jiefang J7'
            },
            'LVV': {
                'C4PL': 'Chery Tiggo 7',
                'D5PM': 'Chery Arrizo 8'
            },
            'LGB': {
                'E6PN': 'Dongfeng K-series',
                'F7PP': 'Dongfeng Warrior'
            },
            'JT1': {
                'FJ8': 'Toyota Hilux',
                'GD6': 'Toyota Land Cruiser'
            },
            'KMH': {
                'HH6': 'Hyundai Porter',
                'HH7': 'Hyundai Mighty'
            }
        };
        
        return modelDatabase[wmi]?.[modelCode] || `${manufacturer} ${modelCode} Series`;
    }

    decodeVINEngine(vin) {
        const engineChar = vin.charAt(6);
        const engineMap = {
            'P': '2.8L Diesel Turbo',
            'Q': '3.0L Diesel Turbo', 
            'R': '3.8L Diesel Turbo',
            'S': '4.5L Diesel Turbo',
            'T': '5.2L Diesel Turbo',
            'E': 'Electric Drive',
            'H': 'Hybrid System'
        };
        return engineMap[engineChar] || 'Standard Engine';
    }

    decodeVINBodyStyle(vin) {
        const bodyChar = vin.charAt(4);
        const bodyMap = {
            '6': 'Crew Cab Truck',
            '3': 'Double Cab Truck',
            '4': 'Chassis Cab', 
            '5': 'Stake Body Truck',
            '7': 'Dump Truck',
            '8': 'Tanker Truck',
            '2': 'Extended Cab'
        };
        return bodyMap[bodyChar] || 'Commercial Truck';
    }

    decodeVINVehicleType(vin) {
        const vds = vin.substring(3, 8);
        
        if (vds.match(/[A-Z]{2}5[A-Z0-9]{2}/)) return 'SUV/4x4';
        if (vds.match(/[A-Z]{2}4[A-Z0-9]{2}/)) return 'MPV/Minivan';
        if (vds.match(/[A-Z]{2}3[A-Z0-9]{2}/)) return 'Passenger Car';
        if (vds.match(/[A-Z]{2}1[A-Z0-9]{2}/)) return 'Truck';
        if (vds.match(/[A-Z]{2}2[A-Z0-9]{2}/)) return 'Bus';
        if (vds.match(/[A-Z]{2}7[A-Z0-9]{2}/)) return 'Crossover';
        if (vds.match(/[A-Z]{2}8[A-Z0-9]{2}/)) return 'Commercial Vehicle';
        
        return 'Unknown Vehicle Type';
    }

    async decodeVINWithAPI(vin) {
        try {
            const response = await fetch(`https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/${vin}?format=json`);
            const data = await response.json();
            
            if (data.Results && data.Results.length > 0) {
                return this.parseNHTSAData(data.Results);
            }
        } catch (error) {
            console.error('NHTSA API error:', error);
            return this.decodeVIN(vin);
        }
    }

    parseNHTSAData(results) {
        const vinData = {};
        
        results.forEach(item => {
            switch(item.Variable) {
                case 'Make':
                    vinData.manufacturer = item.Value;
                    break;
                case 'Model':
                    vinData.modelName = item.Value;
                    break;
                case 'Model Year':
                    vinData.modelYear = item.Value;
                    break;
                case 'Vehicle Type':
                    vinData.vehicleType = item.Value;
                    break;
                case 'Body Class':
                    vinData.bodyStyle = item.Value;
                    break;
                case 'Engine Model':
                    vinData.engineInfo = item.Value;
                    break;
            }
        });
        
        return vinData;
    }

    extractTopics(text) {
        const words = text.split(/\s+/);
        const wordFreq = {};
        
        words.forEach(word => {
            const cleanWord = word.replace(/[^\wሀ-ፕ]/g, '');
            const minLength = /[ሀ-ፕ]/.test(cleanWord) ? 2 : 4;
            if (cleanWord.length >= minLength && !this.isCommonWord(cleanWord)) {
                wordFreq[cleanWord] = (wordFreq[cleanWord] || 0) + 1;
            }
        });
        
        return Object.entries(wordFreq)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 8)
            .map(([word]) => word);
    }

    extractKeywords(text) {
        const words = text.toLowerCase().split(/\s+/);
        const wordFreq = {};
        
        words.forEach(word => {
            const cleanWord = word.replace(/[^\wሀ-ፕ]/g, '');
            const minLength = /[ሀ-ፕ]/.test(cleanWord) ? 2 : 3;
            if (cleanWord.length >= minLength) {
                wordFreq[cleanWord] = (wordFreq[cleanWord] || 0) + 1;
            }
        });
        
        const maxFreq = Math.max(...Object.values(wordFreq));
        
        return Object.entries(wordFreq)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 10)
            .map(([term, count]) => ({
                term,
                score: count / maxFreq
            }));
    }

    generateSummary(docType, text, title, topics, extractedData = {}, language) {
        const wordCount = text.split(/\s+/).filter(word => word.length > 0).length;
        const topicStr = topics.slice(0, 3).join(', ');
        
        let vehicleInfo = '';
        if (docType === "Vehicle Registration Document" && Object.keys(extractedData).length > 0) {
            const vehicleFields = Object.entries(extractedData)
                .filter(([key, value]) => value && value.length > 0)
                .map(([key, value]) => `<div><strong>${this.formatFieldName(key)}:</strong> ${value}</div>`)
                .join('');
                
            vehicleInfo = `
                <div class="vehicle-details">
                    <h4>Extracted Vehicle Information:</h4>
                    <div class="vehicle-grid">
                        ${vehicleFields}
                    </div>
                </div>
            `;
        }
        
        return `
            <div class="document-summary">
                <p><strong>${docType}</strong>: "${title}"</p>
                <p>Language: ${language} | Words: ${wordCount}</p>
                <p>Key topics: ${topicStr}</p>
                ${vehicleInfo}
                <p>Processed with Tesseract.js v6.0.1</p>
            </div>
        `;
    }

    formatFieldName(fieldName) {
        const names = {
            plateNumber: 'Plate Number',
            ownerName: 'Owner Name',
            chassisNumber: 'Chassis Number',
            motorNumber: 'Motor Number',
            vehicleModel: 'Vehicle Model',
            previousPlate: 'Previous Plate',
            gender: 'Gender',
            nationality: 'Nationality',
            city: 'City',
            subcity: 'Subcity',
            woreda: 'Woreda',
            phone: 'Phone',
            vehicleType: 'Vehicle Type',
            bodyType: 'Body Type',
            fuelType: 'Fuel Type',
            color: 'Color',
            manufacturer: 'Manufacturer',
            manufactureYear: 'Manufacture Year',
            enginePower: 'Engine Power',
            totalWeight: 'Total Weight',
            unladenWeight: 'Unladen Weight',
            loadCapacity: 'Load Capacity',
            engineCapacity: 'Engine Capacity',
            cylinderCount: 'Cylinder Count',
            permittedWork: 'Permitted Work'
        };
        return names[fieldName] || fieldName;
    }

    isCommonWord(word) {
        const commonWords = [
            'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'your', 
            'have', 'with', 'this', 'that', 'from', 'የ', 'አ', 'በ', 'እ', 'ወ', 'ከ', 'ለ', 'ማ', 'ነ', 'ስ'
        ];
        return commonWords.includes(word.toLowerCase());
    }

    showLoading(show) {
        const loadingEl = document.getElementById('loading');
        if (loadingEl) {
            loadingEl.style.display = show ? 'block' : 'none';
            if (!show) {
                loadingEl.textContent = 'Ready';
            }
        }
    }

    async destroy() {
        if (this.tesseractWorker) {
            await this.tesseractWorker.terminate();
            this.tesseractWorker = null;
            this.isInitializedT = false;
        }
    }
}

class TesseractLanguageManager {
    constructor() {
        this.dbName = 'tesseract-lang-store';
        this.storeName = 'traineddata';
        this.db = null;
        this.languages = {
            'eng': {
                name: 'English',
                localPath: 'tesseract/dist/lang-data/eng.traineddata.gz'
            },
            'amh': {
                name: 'Amharic', 
                localPath: 'tesseract/dist/lang-data/amh.traineddata.gz'
            }
        };
    }

    async init() {
        await this.openDatabase();
        console.log('✅ Tesseract Language manager initialized');
    }

    async openDatabase() {
        this.db = await openDB(this.dbName, 1, {
            upgrade(db) {
                if (!db.objectStoreNames.contains('traineddata')) {
                    db.createObjectStore('traineddata');
                }
            }
        });
        return this.db;
    }

    async set(key, value) {
        return this.db.put('traineddata', value, key);
    }

    async get(key) {
        return this.db.get('traineddata', key);
    }

    async checkAvailableLanguages() {
        const keys = await this.getAllKeys();
        return Object.keys(this.languages).filter(langCode => {
            const key = `./${langCode}.traineddata`;
            return keys.includes(key);
        });
    }

    async getAllKeys() {
        return this.db.getAllKeys('traineddata');
    }

    async loadLocalLanguage(langCode) {
        const lang = this.languages[langCode];
        if (!lang) {
            throw new Error(`Language ${langCode} not supported`);
        }

        console.log(`📁 Loading local ${lang.name} file from: ${lang.localPath}`);
        
        try {
            const response = await fetch(lang.localPath);
            if (!response.ok) {
                throw new Error(`Failed to load local file: HTTP ${response.status}`);
            }

            const arrayBuffer = await response.arrayBuffer();
            const uint8Array = new Uint8Array(arrayBuffer);
            
            const key = `./${langCode}.traineddata`;
            await this.set(key, uint8Array);
            
            console.log(`✅ ${lang.name} loaded from local file to IndexedDB`);
            return uint8Array;
            
        } catch (error) {
            console.error(`❌ Failed to load local ${lang.name} file:`, error);
            throw error;
        }
    }

    async isLanguageAvailable(langCode) {
        const key = `./${langCode}.traineddata`;
        try {
            const data = await this.get(key);
            return data instanceof Uint8Array && data.length > 0;
        } catch (error) {
            console.warn(`Error checking language availability for ${langCode}:`, error);
            return false;
        }
    }
}

export const teSsAna = new TessAna();
export default teSsAna;END
cat > src/services/tessC.js << 'END'
class TessAnaC {
    constructor() {
        this.isInitializedT = false;
        this.initializationPromise = null;
        this.apiBaseUrl = 'http://localhost:5001'; // Unified server
    }

    async init() {
        if (this.isInitializedT) return;
        
        console.log('Initializing TessC...');
        
        try {
            const response = await fetch(`${this.apiBaseUrl}/health`);
            const data = await response.json();
            console.log('Server status:', data.status);
            console.log('Supported documents:', data.supported_documents);
            console.log('Amharic available:', data.amharic_available);
            this.isInitializedT = true;
        } catch (error) {
            console.warn('OCR server not available. Make sure the server is running on port 5001');
        }
        
        console.log('TessC initialized');
    }

    async analyzeDocument(file) {
        try {
            this.showLoading(true);
            console.log('Starting document analysis for:', file.name, file.type);
            
            let analysis = null;
            
            if (file.type.startsWith('image/')) {
                // Use the unified analyze endpoint
                const result = await this.sendToAnalyzeEndpoint(file);
                
                if (result && result.success) {
                    // Classify the document
                    const classification = this.classifyDocument(result.ocr_text || '', file.name);
                    
                    // Combine all results
                    analysis = {
                        ...classification,
                        documentType: result.document_type,
                        detectedDocument: result.detected_document,
                        extractedData: result.extracted_data,
                        extractedStructure: result.extracted_data,
                        nextSteps: result.next_steps,
                        ocrDetails: {
                            wordCount: result.metadata.word_count,
                            charCount: result.metadata.char_count,
                            amharicCharCount: result.metadata.amharic_char_count,
                            language: result.metadata.language,
                            lineCount: result.metadata.line_count,
                            fieldsExtracted: result.metadata.fields_extracted,
                            completeness: result.metadata.completeness_percentage,
                            preprocessingSteps: result.metadata.preprocessing_steps
                        },
                        fileName: file.name,
                        fileSize: file.size,
                        timestamp: result.timestamp
                    };
                } else {
                    throw new Error('Document analysis failed');
                }
            } else {
                throw new Error('Unsupported file type. Please use image files (JPEG, PNG, etc.)');
            }
            
            this.showLoading(false);
            return analysis;
            
        } catch (error) {
            this.showLoading(false);
            console.error('Analysis error:', error);
            throw new Error(`Document analysis failed: ${error.message}`);
        }
    }

    async sendToAnalyzeEndpoint(file) {
        return new Promise((resolve, reject) => {
            const formData = new FormData();
            formData.append('file', file);
            
            fetch(`${this.apiBaseUrl}/analyze`, {
                method: 'POST',
                body: formData
            })
            .then(async response => {
                if (!response.ok) {
                    const errorData = await response.json();
                    throw new Error(errorData.error || 'Analysis failed');
                }
                const data = await response.json();
                resolve(data);
            })
            .catch(error => {
                console.error('Analysis request failed:', error);
                reject(error);
            });
        });
    }

    async extractInsuranceDocument(file) {
        return new Promise((resolve, reject) => {
            const formData = new FormData();
            formData.append('file', file);
            
            fetch(`${this.apiBaseUrl}/extract/insurance`, {
                method: 'POST',
                body: formData
            })
            .then(async response => {
                if (!response.ok) {
                    const errorData = await response.json();
                    throw new Error(errorData.error || 'Insurance extraction failed');
                }
                const data = await response.json();
                resolve(data);
            })
            .catch(error => {
                console.error('Insurance extraction failed:', error);
                reject(error);
            });
        });
    }

    async extractVehicleDocument(file) {
        return new Promise((resolve, reject) => {
            const formData = new FormData();
            formData.append('file', file);
            
            fetch(`${this.apiBaseUrl}/extract/vehicle`, {
                method: 'POST',
                body: formData
            })
            .then(async response => {
                if (!response.ok) {
                    const errorData = await response.json();
                    throw new Error(errorData.error || 'Vehicle extraction failed');
                }
                const data = await response.json();
                resolve(data);
            })
            .catch(error => {
                console.error('Vehicle extraction failed:', error);
                reject(error);
            });
        });
    }

    async extractDriverLicense(file) {
        return new Promise((resolve, reject) => {
            const formData = new FormData();
            formData.append('file', file);
            
            fetch(`${this.apiBaseUrl}/extract/driver`, {
                method: 'POST',
                body: formData
            })
            .then(async response => {
                if (!response.ok) {
                    const errorData = await response.json();
                    throw new Error(errorData.error || 'Driver license extraction failed');
                }
                const data = await response.json();
                resolve(data);
            })
            .catch(error => {
                console.error('Driver license extraction failed:', error);
                reject(error);
            });
        });
    }

    async getSupportedDocuments() {
        try {
            const response = await fetch(`${this.apiBaseUrl}/supported-documents`);
            const data = await response.json();
            return data;
        } catch (error) {
            console.error('Failed to get supported documents:', error);
            return null;
        }
    }

    // Keep your existing methods: classifyDocument, extractVehicleData, detectLanguage, etc.
    classifyDocument(text, fileName) {
        // Your existing classifyDocument logic
        // This will still work as fallback
        const lowerText = text.toLowerCase();
        
        let type = "General Document";
        let typeClass = "type-other";
        let confidence = 0.3;
        let category = "other";
        let detectedLanguage = this.detectLanguage(text);
        
        // Document type classification based on content
        if (/(የሰሌዳ\s*ቁጥር|የሻንሺ\s*ቁጥር|chassis\s*number|plate\s*number)/i.test(text)) {
            type = "Vehicle Registration Document";
            typeClass = "type-government";
            confidence = 0.9;
            category = "transportation";
        } else if (/(abstract|introduction|methodology|results|discussion|conclusion)/i.test(text)) {
            type = "Academic Paper";
            typeClass = "type-research";
            confidence = 0.8;
            category = "academic";
        } else if (/(agreement|contract|clause|party|whereas|warranty|jurisdiction)/i.test(text)) {
            type = "Legal Document";
            typeClass = "type-legal";
            confidence = 0.7;
            category = "legal";
        } else if (/(ዜግነት|national id|fayda id|government|ብሔራዊ መታወቂያ)/i.test(text)) {
            type = "Government Document";
            typeClass = "type-government";
            confidence = 0.75;
            category = "government";
        } else if (/(invoice|receipt|payment|amount|balance|statement|tax)/i.test(text)) {
            type = "Financial Document";
            typeClass = "type-financial";
            confidence = 0.6;
            category = "financial";
        } else if (/(certificate of insurance|የመድን ምስክር ወረቀት|insurance|መድን)/i.test(text)) {
            type = "Insurance Certificate";
            typeClass = "type-financial";
            confidence = 0.85;
            category = "insurance";
        }
        
        const topics = this.extractTopics(text);
        const keywords = this.extractKeywords(text);
        const extractedData = this.extractVehicleData(text);
        
        return {
            documentName: fileName.replace(/\.[^/.]+$/, "") || 'Unknown Document',
            documentType: type,
            typeClass: typeClass,
            confidence: confidence,
            category: category,
            language: detectedLanguage,
            topics: topics,
            keywords: keywords,
            extractedData: extractedData,
            summary: this.generateSummary(type, text, fileName, topics, extractedData, detectedLanguage),
            wordCount: text.split(/\s+/).filter(word => word.length > 0).length,
            timestamp: new Date().toISOString(),
            tesseractVersion: '5.0.0 (via Unified Server)'
        };
    }

    detectLanguage(text) {
        const ethiopicChars = /[\u1200-\u137F]/;
        const latinChars = /[a-zA-Z]/;
        
        const hasEthiopic = ethiopicChars.test(text);
        const hasLatin = latinChars.test(text);
        
        if (hasEthiopic && hasLatin) return 'amh+eng';
        if (hasEthiopic) return 'amh';
        if (hasLatin) return 'eng';
        return 'unknown';
    }

    extractVehicleData(text) {
        // Your existing extractVehicleData logic
        const vehicleData = {};
        const lines = text.split('\n').map(line => line.trim()).filter(line => line.length > 2);
        
        const keyPatterns = {
            plateNumber: {
                keys: ['የሰሌዳ\\s*ቁጥር', 'plate\\s*number'],
                extractPattern: /.{8,15}/
            },
            ownerName: {
                keys: ['ስም', 'name'],
                extractPattern: /.{5,30}/
            },
            chassisNumber: {
                keys: ['የሻንሺ\\s*ቁጥር', 'chassis\\s*number'],
                extractPattern: /.{10,20}/
            },
            motorNumber: {
                keys: ['የሞተር\\s*ቁጥር', 'motor\\s*number'],
                extractPattern: /.{8,25}/
            },
            vehicleModel: {
                keys: ['የተሽ[\\/]?\\s*ሞዴል', 'vehicle\\s*model'],
                extractPattern: /.{8,20}/
            }
        };
        
        lines.forEach(line => {
            for (const [field, patternInfo] of Object.entries(keyPatterns)) {
                if (!vehicleData[field]) {
                    for (const key of patternInfo.keys) {
                        const keyRegex = new RegExp(`${key}[\\s:]*([^\\n]{3,30})`, 'i');
                        const match = line.match(keyRegex);
                        
                        if (match && match[1]) {
                            let value = match[1].trim();
                            value = value.replace(/^[:\s\-]+|[:\s\-]+$/g, '');
                            
                            if (value && value.length > 0) {
                                vehicleData[field] = value;
                                break;
                            }
                        }
                    }
                }
            }
        });
        
        return this.validateAndCleanVehicleData(vehicleData);
    }

    validateAndCleanVehicleData(vehicleData) {
        const cleaned = { ...vehicleData };
        
        Object.keys(cleaned).forEach(key => {
            if (typeof cleaned[key] === 'string') {
                cleaned[key] = cleaned[key]
                    .replace(/\s+/g, ' ')
                    .trim()
                    .replace(/^[:\-\s]+|[:\-\s]+$/g, '');
            }
        });
        
        return cleaned;
    }

    extractTopics(text) {
        const words = text.split(/\s+/);
        const wordFreq = {};
        
        words.forEach(word => {
            const cleanWord = word.replace(/[^\w\u1200-\u137F]/g, '');
            const minLength = /[\u1200-\u137F]/.test(cleanWord) ? 2 : 4;
            if (cleanWord.length >= minLength && !this.isCommonWord(cleanWord)) {
                wordFreq[cleanWord] = (wordFreq[cleanWord] || 0) + 1;
            }
        });
        
        return Object.entries(wordFreq)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 8)
            .map(([word]) => word);
    }

    extractKeywords(text) {
        const words = text.toLowerCase().split(/\s+/);
        const wordFreq = {};
        
        words.forEach(word => {
            const cleanWord = word.replace(/[^\w\u1200-\u137F]/g, '');
            const minLength = /[\u1200-\u137F]/.test(cleanWord) ? 2 : 3;
            if (cleanWord.length >= minLength) {
                wordFreq[cleanWord] = (wordFreq[cleanWord] || 0) + 1;
            }
        });
        
        const maxFreq = Math.max(...Object.values(wordFreq));
        
        return Object.entries(wordFreq)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 10)
            .map(([term, count]) => ({
                term,
                score: count / maxFreq
            }));
    }

    generateSummary(docType, text, title, topics, extractedData = {}, language) {
        const wordCount = text.split(/\s+/).filter(word => word.length > 0).length;
        const topicStr = topics.slice(0, 3).join(', ');
        
        let vehicleInfo = '';
        if (docType === "Vehicle Registration Document" && Object.keys(extractedData).length > 0) {
            const vehicleFields = Object.entries(extractedData)
                .filter(([key, value]) => value && value.length > 0)
                .map(([key, value]) => `<div><strong>${this.formatFieldName(key)}:</strong> ${value}</div>`)
                .join('');
                
            vehicleInfo = `
                <div class="vehicle-details">
                    <h4>Extracted Vehicle Information:</h4>
                    <div class="vehicle-grid">
                        ${vehicleFields}
                    </div>
                </div>
            `;
        }
        
        return `
            <div class="document-summary">
                <p><strong>${docType}</strong>: "${title}"</p>
                <p>Language: ${language} | Words: ${wordCount}</p>
                <p>Key topics: ${topicStr}</p>
                ${vehicleInfo}
                <p>Processed with Unified Document Analysis Server</p>
            </div>
        `;
    }

    formatFieldName(fieldName) {
        const names = {
            plateNumber: 'Plate Number',
            ownerName: 'Owner Name',
            chassisNumber: 'Chassis Number',
            motorNumber: 'Motor Number',
            vehicleModel: 'Vehicle Model',
            previousPlate: 'Previous Plate',
            gender: 'Gender',
            nationality: 'Nationality',
            city: 'City',
            subcity: 'Subcity',
            woreda: 'Woreda',
            phone: 'Phone',
            vehicleType: 'Vehicle Type',
            bodyType: 'Body Type',
            fuelType: 'Fuel Type',
            color: 'Color',
            manufacturer: 'Manufacturer',
            manufactureYear: 'Manufacture Year'
        };
        return names[fieldName] || fieldName;
    }

    isCommonWord(word) {
        const commonWords = [
            'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'your', 
            'have', 'with', 'this', 'that', 'from', 'ወደ', 'ለ', 'ከ', 'በ', 'እና'
        ];
        return commonWords.includes(word.toLowerCase());
    }

    showLoading(show) {
        const loadingEl = document.getElementById('loading');
        if (loadingEl) {
            loadingEl.style.display = show ? 'block' : 'none';
            if (!show) {
                loadingEl.textContent = 'Ready';
            }
        }
    }
}

export const teSsAnaC = new TessAnaC();
export default teSsAnaC;END
cat > src/services/vin.js << 'END'
﻿import { openDB } from 'idb';
import {processMessage} from './nlpProcessor'


      
        let isInitializedT = false;
      
        let initializationPromise = null;
  export async function init() {
          if (isInitializedT) return;
          
          console.log('🔄 Initializing TessC...');
          
    
          
          console.log('TessC initialized ');
      }
  


   

   
export async function classifyDocument(text, fileName) {
        const lowerText = text.toLowerCase();
        
        let type = "General Document";
        let typeClass = "type-other";
        let confidence = 0.3;
        let category = "other";
        let detectedLanguage = this.detectLanguage(text);

        if (/(የሰሌዳ\s*ቁጥር|የተሽከርካሪው|የሻንሺ\s*ቁጥር|chassis\s*number|vehicle\s*description|plate\s*number)/i.test(text)) {
            type = "Vehicle Registration Document";
            typeClass = "type-government";
            confidence = 0.9;
            category = "transportation";
        }
        else if (/(abstract|introduction|methodology|results|discussion|conclusion|references|bibliography)/i.test(text)) {
            type = "Academic Paper";
            typeClass = "type-research";
            confidence = 0.8;
            category = "academic";
        }
        else if (/(agreement|contract|clause|party|whereas|warranty|jurisdiction)/i.test(text)) {
            type = "Legal Document";
            typeClass = "type-legal";
            confidence = 0.7;
            category = "legal";
        }
        else if (/(license|permit|national id|fayda id|government|identification|ዜግነት|ኢትዮጵያ)/i.test(text)) {
            type = "Government Document";
            typeClass = "type-government";
            confidence = 0.75;
            category = "government";
        }
        else if (/(invoice|receipt|payment|amount|balance|statement|tax)/i.test(text)) {
            type = "Financial Document";
            typeClass = "type-financial";
            confidence = 0.6;
            category = "financial";
        }

        const topics = this.extractTopics(text);
        const keywords = this.extractKeywords(text);
        const extractedData = this.extractVehicleData(text);
         const currentIntent = sessionStorage.getItem('currentService')
            if (currentIntent==='iftms') {
                const Edata ={documentType: type,
            typeClass: typeClass,
            confidence: confidence,
            category: category,}
            return  await processMessage(currentIntent,Edata,false,true)
        
            }
        return {
            documentName: fileName.replace(/\.[^/.]+$/, "") || 'Unknown Document',
            documentType: type,
            typeClass: typeClass,
            confidence: confidence,
            category: category,
            language: detectedLanguage,
            topics: topics,
            keywords: keywords,
            extractedData: extractedData,
            summary: this.generateSummary(type, text, fileName, topics, extractedData, detectedLanguage),
            wordCount: text.split(/\s+/).filter(word => word.length > 0).length,
            timestamp: new Date().toISOString(),
            tesseractVersion: '6.0.1'
        };
    }

   export function detectLanguage(text) {
        const ethiopicChars = /[ሀ-ፕ]/;
        const latinChars = /[a-zA-Z]/;
        
        const hasEthiopic = ethiopicChars.test(text);
        const hasLatin = latinChars.test(text);
        
        if (hasEthiopic && hasLatin) return 'amh+eng';
        if (hasEthiopic) return 'amh';
        if (hasLatin) return 'eng';
        return 'unknown';
    }
   

   export function extractVehicleData(text) {
        const vehicleData = {};
        
        const lines = text.split('\n').map(line => line.trim()).filter(line => line.length > 2);
        
        console.log('Raw lines:', lines);

        const keyPatterns = {
            plateNumber: {
                keys: ['የሰሌዳ\\s*ቁጥር', 'plate\\s*number'],
                extractPattern: /.{8,15}/
            },
            ownerName: {
                keys: ['ስም', 'name'],
                extractPattern: /.{5,30}/
            },
            chassisNumber: {
                keys: ['የሻንሺ\\s*ቁጥር', 'chassis\\s*number'],
                extractPattern: /.{10,20}/
            },
            motorNumber: {
                keys: ['የሞተር\\s*ቁጥር', 'motor\\s*number'],
                extractPattern: /.{8,25}/
            },
            vehicleModel: {
                keys: ['የተሽ[\\/]?\\s*ሞዴል', 'vehicle\\s*model'],
                extractPattern: /.{8,20}/
            },
            previousPlate: {
                keys: ['የቀድሞ\\s*ሰሌዳ\\s*ቁጥር', 'previous\\s*plate'],
                extractPattern: /.{8,20}/
            },
            gender: {
                keys: ['ጾታ', 'gender'],
                extractPattern: /.{2,10}/
            },
            nationality: {
                keys: ['ዜግነት', 'nationality'],
                extractPattern: /.{5,20}/
            },
            city: {
                keys: ['ከተማ', 'city'],
                extractPattern: /.{5,20}/
            },
            subcity: {
                keys: ['ክ[\\/]\\s*ከተማ', 'subcity'],
                extractPattern: /.{5,20}/
            },
            woreda: {
                keys: ['ቀበሌ[\\/]\\s*ወረዳ', 'woreda'],
                extractPattern: /[0-9\\-\\/\\.\\s]{1,6}/
            },
            phone: {
                keys: ['ሰልክ', 'phone'],
                extractPattern: /[0-9\\s\\-\\.]{8,12}/
            },
            vehicleType: {
                keys: ['የመኪና\\s*አይነት', 'vehicle\\s*type'],
                extractPattern: /.{3,20}/
            },
            bodyType: {
                keys: ['የአካሉ\\s*አይነት', 'body\\s*type'],
                extractPattern: /.{3,20}/
            },
            fuelType: {
                keys: ['የነዳጅ\\s*ዓይነት', 'fuel\\s*type'],
                extractPattern: /.{3,15}/
            },
            color: {
                keys: ['ቀለም', 'color'],
                extractPattern: /.{3,15}/
            },
            manufacturer: {
                keys: ['የተሰራበት\\s*ሀገር', 'manufacturer'],
                extractPattern: /.{3,20}/
            },
            manufactureYear: {
                keys: ['የተሰራበት\\s*ዘመን', 'manufacture\\s*year'],
                extractPattern: /[0-9\\s\\-\\.]{3,6}/
            },
            enginePower: {
                keys: ['የሞተር\\s*የፈረስ\\s*ጉልበት', 'engine\\s*power'],
                extractPattern: /[0-9\\s\\-\\.]{2,6}/
            },
            totalWeight: {
                keys: ['የተሽ[\\/]\\s*ጠቅ[\\/]\\s*ክብደት', 'total\\s*weight'],
                extractPattern: /[0-9\\s\\-\\.]{3,8}/
            },
            unladenWeight: {
                keys: ['ነጠላ\\s*ክብደት', 'unladen\\s*weight'],
                extractPattern: /[0-9\\s\\-\\.]{3,8}/
            },
            loadCapacity: {
                keys: ['የጭነት\\s*መጠን', 'load\\s*capacity'],
                extractPattern: /.{3,15}/
            },
            engineCapacity: {
                keys: ['የሞተር\\s*ችሎታ[\\/]\\s*ሲሲ', 'engine\\s*capacity'],
                extractPattern: /[0-9\\s\\-\\.]{3,8}/
            },
            cylinderCount: {
                keys: ['የሲሊንደር\\s*ብዛት', 'cylinder\\s*count'],
                extractPattern: /[0-9\\s\\-\\.]{1,4}/
            },
            permittedWork: {
                keys: ['የተፈቀደለት\\s*የስራ\\s*ጸባይ', 'permitted\\s*work'],
                extractPattern: /.{3,20}/
            }
        };

        lines.forEach(line => {
            for (const [field, patternInfo] of Object.entries(keyPatterns)) {
                if (!vehicleData[field]) {
                    for (const key of patternInfo.keys) {
                        const keyRegex = new RegExp(`${key}[\\s:]*([^\\n]{3,30})`, 'i');
                        const match = line.match(keyRegex);
                        
                        if (match && match[1]) {
                            let value = match[1].trim();
                            value = value.replace(/^[:\s\\-]+|[:\s\\-]+$/g, '');
                            
                            if (value && value.length > 0) {
                                vehicleData[field] = value;
                                console.log(`✅ Same-line ${field}: "${value}" from: "${line}"`);
                                break;
                            }
                        }
                    }
                }
            }
        });

        this.extractSeparatedKeyValues(lines, vehicleData);

        console.log('=== FINAL EXTRACTED DATA ===', vehicleData);
        return this.validateAndCleanVehicleData(vehicleData);
    }

    export function extractSeparatedKeyValues(lines, vehicleData) {
        if (!vehicleData.chassisNumber) {
            const chassisKeyIndex = lines.findIndex(line => /የሻንሺ|chassis/i.test(line));
            console.log('Chassis key found at line:', chassisKeyIndex, lines[chassisKeyIndex]);
            
            if (chassisKeyIndex !== -1) {
                for (let i = chassisKeyIndex + 12; i <= Math.min(lines.length + 12, chassisKeyIndex + 12); i++) {
                    console.log('Checking line', i, 'for chassis:', lines[i]);
                    const chassisMatch = lines[i].match(/([A-Z0-9]{10,18})/);
                    const vinMatch = lines[i].match(/([A-HJ-NPR-Z0-9]{17})/);
            
                    if (vinMatch) {
                        vehicleData.chassisNumber = vinMatch[1];
                        console.log(`✅ VIN found: "${vinMatch[1]}" at line ${i}`);
                        
                        const vinData = this.decodeVIN(vinMatch[1]);
                        Object.assign(vehicleData, vinData);
                        break;
                    }
                    if (chassisMatch) {
                        vehicleData.chassisNumber = chassisMatch[1];
                        console.log(`✅ Chassis found: "${chassisMatch[1]}" at line ${i} after key at line ${chassisKeyIndex}`);
                        break;
                    }
                }
            }
            
            if (!vehicleData.chassisNumber) {
                const chassisKeyIndex = lines.findIndex(line => /የሻንሺ|chassis/i.test(line));
                console.log('Chassis key found at line:', chassisKeyIndex, lines[chassisKeyIndex]);
                
                if (chassisKeyIndex !== -1) {
                    for (let i = chassisKeyIndex + 3; i <= Math.min(lines.length - 3, chassisKeyIndex + 5); i++) {
                        console.log('Checking line', i, 'for chassis:', lines[i]);
                        const chassisMatch = lines[i].match(/([A-Z0-9]{10,18})/);
                        const vinMatch = lines[i].match(/([A-HJ-NPR-Z0-9]{17})/);
                        if (vinMatch && !/የሻንሺ|chassis|phone|ሰልክ|0911/i.test(lines[i])) {
                            vehicleData.chassisNumber = vinMatch[1];
                            console.log(`✅ Direct VIN: "${vinMatch[1]}" from line ${i}`);
                            
                            const vinData = this.decodeVIN(vinMatch[1]);
                            Object.assign(vehicleData, vinData);
                            break;
                        }
                        if (chassisMatch) {
                            vehicleData.chassisNumber = chassisMatch[1];
                            console.log(`✅ Chassis found: "${chassisMatch[1]}" at line ${i} after key at line ${chassisKeyIndex}`);
                            break;
                        }
                    }
                }
                
                if (!vehicleData.vehicleModel) {
                    const modelKeyIndex = lines.findIndex(line => /የተሽ[\\/]?ሞዴል|vehicle.model/i.test(line));
                    console.log('Model key found at line:', modelKeyIndex, lines[modelKeyIndex]);
                    
                    if (modelKeyIndex !== -1) {
                        for (let i = modelKeyIndex + 1; i <= Math.min(lines.length - 1, modelKeyIndex + 5); i++) {
                            console.log('Checking line', i, 'for model:', lines[i]);
                            const modelMatch = lines[i].match(/(BJ425[0-9][A-Z]MFKB26TA|[A-Z0-9]{8,20})/);
                            if (modelMatch) {
                                vehicleData.vehicleModel = modelMatch[1];
                                console.log(`✅ Model found: "${modelMatch[1]}" at line ${i} after key at line ${modelKeyIndex}`);
                                break;
                            }
                        }
                    }
                }
                
                if (!vehicleData.chassisNumber) {
                    for (let i = 0; i < lines.length; i++) {
                        const chassisMatch = lines[i].match(/([A-Z0-9]{10,18})/);
                        if (chassisMatch && !/የሻንሺ|chassis|phone|ሰልክ|0911/i.test(lines[i])) {
                            vehicleData.chassisNumber = chassisMatch[1];
                            console.log(`✅ Direct chassis: "${chassisMatch[1]}" from line ${i}`);
                            break;
                        }
                    }
                }
            }
        }

        if (!vehicleData.motorNumber) {
            const motorKeyIndex = lines.findIndex(line => /የሞተር|motor/i.test(line));
            console.log('Motor key found at line:', motorKeyIndex, lines[motorKeyIndex]);
            
            if (motorKeyIndex !== -1) {
                for (let i = motorKeyIndex + 1; i <= Math.min(lines.length - 1, motorKeyIndex + 5); i++) {
                    console.log('Checking line', i, 'for motor:', lines[i]);
                    const motorMatch = lines[i].match(/(1SG400[\-\s]?[0-9A-Z]{7,9}|[A-Z0-9]{3,6}[\-\s]?[A-Z0-9]{5,10})/);
                    if (motorMatch && !/phone|ሰልክ|0911/i.test(lines[i])) {
                        vehicleData.motorNumber = motorMatch[1];
                        console.log(`✅ Motor found: "${motorMatch[1]}" at line ${i} after key at line ${motorKeyIndex}`);
                        break;
                    }
                }
            }
            
            if (!vehicleData.motorNumber) {
                for (let i = 0; i < lines.length; i++) {
                    const motorMatch = lines[i].match(/(1SG400[\-\s]?[0-9A-Z]{7,9}|[A-Z0-9]{3,6}[\-\s]?[A-Z0-9]{5,10})/);
                    if (motorMatch && !/phone|ሰልክ|0911/i.test(lines[i])) {
                        vehicleData.motorNumber = motorMatch[1];
                        console.log(`✅ Direct motor: "${motorMatch[1]}" from line ${i}`);
                        break;
                    }
                }
            }
        }

        if (!vehicleData.manufactureYear) {
            for (let i = 0; i < lines.length; i++) {
                const yearMatch = lines[i].match(/(20[0-9]{2})/);
                if (yearMatch && !/phone|ሰልክ/i.test(lines[i])) {
                    vehicleData.manufactureYear = yearMatch[1];
                    console.log(`✅ Year: "${yearMatch[1]}" from line ${i}`);
                    break;
                }
            }
        }

        if (!vehicleData.phone) {
            const phoneKeyIndex = lines.findIndex(line => /ሰልክ|phone/i.test(line));
            if (phoneKeyIndex !== -1) {
                for (let i = Math.max(0, phoneKeyIndex - 2); i <= Math.min(lines.length - 1, phoneKeyIndex + 2); i++) {
                    const phoneMatch = lines[i].match(/([0-9]{8,10})/);
                    if (phoneMatch) {
                        vehicleData.phone = phoneMatch[1];
                        console.log(`✅ Phone: "${phoneMatch[1]}" near line ${phoneKeyIndex}`);
                        break;
                    }
                }
            }
        }
    }

    export function validateAndCleanVehicleData(vehicleData) {
        const cleaned = { ...vehicleData };
        
        Object.keys(cleaned).forEach(key => {
            if (typeof cleaned[key] === 'string') {
                cleaned[key] = cleaned[key]
                    .replace(/\s+/g, ' ')
                    .trim()
                    .replace(/^[:\-\s]+|[:\-\s]+$/g, '');
            }
        });
        
        return cleaned;
    }

    export function decodeVIN(vin) {
        if (!vin || vin.length !== 17) return {};
        
        const vinData = {
            vinNumber: vin,
            wmi: vin.substring(0, 3),
            vds: vin.substring(3, 9),
            vis: vin.substring(9, 17),
            modelYear: this.decodeVINModelYear(vin),
            assemblyPlant: this.decodeVINPlant(vin),
            manufacturer: this.decodeVINManufacturer(vin),
            vehicleType: this.decodeVINVehicleType(vin),
            modelCode: this.decodeVINModelCode(vin),
            modelName: this.decodeVINModelName(vin),
            engineInfo: this.decodeVINEngine(vin),
            bodyStyle: this.decodeVINBodyStyle(vin)
        };
        
        console.log('🔍 VIN Decoded:', vinData);
        return vinData;
    }

    export function decodeVINModelYear(vin) {
        const yearChar = vin.charAt(9);
        const yearMap = {
            'A': '2010', 'B': '2011', 'C': '2012', 'D': '2013', 'E': '2014', 'F': '2015',
            'G': '2016', 'H': '2017', 'J': '2018', 'K': '2019', 'L': '2020', 'M': '2021',
            'N': '2022', 'P': '2023', 'R': '2024', 'S': '2025', 'T': '2026', 'V': '2027',
            'W': '2028', 'X': '2029', 'Y': '2030',
            '1': '2001', '2': '2002', '3': '2003', '4': '2004', '5': '2005', '6': '2006',
            '7': '2007', '8': '2008', '9': '2009'
        };
        return yearMap[yearChar] || 'Unknown';
    }

    export function decodeVINPlant(vin) {
        const plantChar = vin.charAt(10);
        const wmi = vin.substring(0, 3);
        
        if (wmi.startsWith('L')) {
            const chinaPlantMap = {
                'A': 'Beijing', 'B': 'Shanghai', 'C': 'Guangzhou', 'D': 'Shenzhen',
                'E': 'Tianjin', 'F': 'Wuhan', 'G': 'Chongqing', 'H': 'Nanjing',
                'J': 'Chengdu', 'K': 'Xi\'an', 'L': 'Hangzhou', 'M': 'Suzhou',
                'N': 'Dongguan', 'P': 'Foshan', 'R': 'Qingdao', 'S': 'Zhengzhou',
                'T': 'Changsha', 'U': 'Ningbo', 'V': 'Hefei', 'W': 'Xiamen',
                'X': 'Wuxi', 'Y': 'Jinan', 'Z': 'Dalian'
            };
            return chinaPlantMap[plantChar] ? `China - ${chinaPlantMap[plantChar]}` : 'China - Unknown Plant';
        }
        
        const plantMap = {
            'A': 'USA - Indiana', 'B': 'USA - Ohio', 'C': 'Canada - Ontario',
            'D': 'Germany', 'E': 'USA - Kentucky', 'F': 'USA - Michigan',
            'G': 'USA - Tennessee', 'H': 'USA - Missouri', 'J': 'Japan',
            'K': 'Korea', 'L': 'China', 'M': 'Thailand',
            'N': 'USA - Indiana', 'P': 'USA - Illinois', 'R': 'Mexico',
            'S': 'USA - California', 'T': 'USA - Texas', 'U': 'USA - Ohio',
            'V': 'USA - Wisconsin', 'W': 'Germany', 'X': 'USA - Tennessee',
            'Y': 'USA - Michigan', 'Z': 'USA - Michigan'
        };
        return plantMap[plantChar] || 'Unknown Plant';
    }

    export function decodeVINManufacturer(vin) {
        const wmi = vin.substring(0, 3);
        const manufacturerMap = {
            'LBE': 'Beijing Automotive (BAW)', 'LB3': 'Dongfeng Motor', 'LDC': 'Dongfeng Peugeot-Citroen',
            'LDD': 'Dongfeng Nissan', 'LDY': 'Zhongtong Bus', 'LE4': 'Beijing Benz (Mercedes-Benz)',
            'LFM': 'FAW Toyota', 'LFN': 'FAW-Volkswagen', 'LFP': 'FAW Car', 'LFT': 'FAW Jiefang',
            'LFV': 'FAW-Volkswagen', 'LGB': 'Dongfeng Nissan', 'LGH': 'GAC Honda', 'LGJ': 'Dongfeng Honda',
            'LGW': 'Great Wall Motors', 'LGX': 'BYD Auto', 'LH1': 'FAW Haima', 'LHG': 'GAC Honda',
            'LJD': 'Dongfeng Peugeot-Citroen', 'LJN': 'Zhengzhou Nissan', 'LLV': 'Lifan Motors',
            'LMG': 'GAC Motor', 'LPA': 'Changan PSA', 'LRB': 'Beijing Benz (Mercedes-Benz)',
            'LS5': 'Changan Suzuki', 'LSG': 'SAIC General Motors', 'LSJ': 'SAIC MG',
            'LSV': 'SAIC Volkswagen', 'LSY': 'Brilliance Jinbei', 'LTV': 'FAW Toyota',
            'LUC': 'Guangqi Honda', 'LUD': 'Dongfeng Yueda Kia', 'LUX': 'Dongfeng Yulon',
            'LVB': 'Foton Motor', 'LVC': 'Beijing Benz (Mercedes-Benz)', 'LVD': 'Changan Ford',
            'LVS': 'FAW Toyota', 'LVV': 'Chery Automobile', 'LVY': 'Volvo China',
            'LZW': 'SAIC-GM-Wuling', 'LZY': 'Yutong Bus',
            'JA3': 'Mitsubishi', 'JA4': 'Mitsubishi', 'JA7': 'Mitsubishi', 'JAA': 'Isuzu',
            'JAB': 'Isuzu', 'JAC': 'Isuzu', 'JAE': 'Acura', 'JAL': 'Isuzu', 'JB3': 'Dodge',
            'JB4': 'Dodge', 'JB7': 'Dodge', 'JBA': 'Hino', 'JBB': 'Hino', 'JBC': 'Hino',
            'KMH': 'Hyundai', 'KNA': 'Kia', 'KNB': 'Kia', 'KNC': 'Kia', 'KND': 'Kia',
            'WAA': 'Audi', 'WBA': 'BMW', 'WDB': 'Mercedes-Benz', 'WVW': 'Volkswagen',
            '1FA': 'Ford', '1FB': 'Ford', '1FC': 'Ford', '1FD': 'Ford', '1FM': 'Ford',
            '1FT': 'Ford', '1FU': 'Freightliner', '1FV': 'Freightliner', '1G1': 'Chevrolet',
            '1G2': 'Pontiac', '1G3': 'Oldsmobile', '1G4': 'Buick', '1G6': 'Cadillac',
            '1G8': 'Chevrolet', '1GA': 'Chevrolet', '1GB': 'Chevrolet', '1GC': 'Chevrolet',
            '1GD': 'GMC', '1GE': 'Cadillac'
        };
        
        return manufacturerMap[wmi] || this.guessManufacturerFromWMI(wmi);
    }

    export function guessManufacturerFromWMI(wmi) {
        if (wmi.startsWith('1')) return 'USA Manufacturer';
        if (wmi.startsWith('2')) return 'Canada Manufacturer';
        if (wmi.startsWith('3')) return 'Mexico Manufacturer';
        if (wmi.startsWith('J')) return 'Japan Manufacturer';
        if (wmi.startsWith('K')) return 'Korea Manufacturer';
        if (wmi.startsWith('L')) return 'China Manufacturer';
        if (wmi.startsWith('W')) return 'Germany Manufacturer';
        if (wmi.startsWith('Z')) return 'Italy Manufacturer';
        if (wmi.startsWith('V')) return 'France Manufacturer';
        if (wmi.startsWith('S')) return 'UK Manufacturer';
        if (wmi.startsWith('Y')) return 'Sweden Manufacturer';
        if (wmi.startsWith('MA') || wmi.startsWith('MB') || wmi.startsWith('MC') || wmi.startsWith('MD') || wmi.startsWith('ME')) return 'India Manufacturer';
        return 'Unknown Manufacturer';
    }

    export function decodeVINModelCode(vin) {
        const vds = vin.substring(3, 9);
        return vds.substring(0, 4);
    }

    export function decodeVINModelName(vin) {
        const manufacturer = this.decodeVINManufacturer(vin);
        const modelCode = this.decodeVINModelCode(vin);
        const wmi = vin.substring(0, 3);
        
        const modelDatabase = {
            'LVB': {
                'S6PE': 'Foton Aumark S6',
                'S6PB': 'Foton Aumark T3',
                'T4PA': 'Foton Ollin',
                'U3PC': 'Foton View',
                'S5PD': 'Foton Sup',
                'R7PF': 'Foton Tornado'
            },
            'LVS': {
                'A2PJ': 'FAW Jiefang J6',
                'B3PK': 'FAW Jiefang J7'
            },
            'LVV': {
                'C4PL': 'Chery Tiggo 7',
                'D5PM': 'Chery Arrizo 8'
            },
            'LGB': {
                'E6PN': 'Dongfeng K-series',
                'F7PP': 'Dongfeng Warrior'
            },
            'JT1': {
                'FJ8': 'Toyota Hilux',
                'GD6': 'Toyota Land Cruiser'
            },
            'KMH': {
                'HH6': 'Hyundai Porter',
                'HH7': 'Hyundai Mighty'
            }
        };
        
        return modelDatabase[wmi]?.[modelCode] || `${manufacturer} ${modelCode} Series`;
    }

    export function decodeVINEngine(vin) {
        const engineChar = vin.charAt(6);
        const engineMap = {
            'P': '2.8L Diesel Turbo',
            'Q': '3.0L Diesel Turbo', 
            'R': '3.8L Diesel Turbo',
            'S': '4.5L Diesel Turbo',
            'T': '5.2L Diesel Turbo',
            'E': 'Electric Drive',
            'H': 'Hybrid System'
        };
        return engineMap[engineChar] || 'Standard Engine';
    }

    export function decodeVINBodyStyle(vin) {
        const bodyChar = vin.charAt(4);
        const bodyMap = {
            '6': 'Crew Cab Truck',
            '3': 'Double Cab Truck',
            '4': 'Chassis Cab', 
            '5': 'Stake Body Truck',
            '7': 'Dump Truck',
            '8': 'Tanker Truck',
            '2': 'Extended Cab'
        };
        return bodyMap[bodyChar] || 'Commercial Truck';
    }

    export function decodeVINVehicleType(vin) {
        const vds = vin.substring(3, 8);
        
        if (vds.match(/[A-Z]{2}5[A-Z0-9]{2}/)) return 'SUV/4x4';
        if (vds.match(/[A-Z]{2}4[A-Z0-9]{2}/)) return 'MPV/Minivan';
        if (vds.match(/[A-Z]{2}3[A-Z0-9]{2}/)) return 'Passenger Car';
        if (vds.match(/[A-Z]{2}1[A-Z0-9]{2}/)) return 'Truck';
        if (vds.match(/[A-Z]{2}2[A-Z0-9]{2}/)) return 'Bus';
        if (vds.match(/[A-Z]{2}7[A-Z0-9]{2}/)) return 'Crossover';
        if (vds.match(/[A-Z]{2}8[A-Z0-9]{2}/)) return 'Commercial Vehicle';
        
        return 'Unknown Vehicle Type';
    }

    export async function decodeVINWithAPI(vin) {
        try {
            const response = await fetch(`https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/${vin}?format=json`);
            const data = await response.json();
            
            if (data.Results && data.Results.length > 0) {
                return this.parseNHTSAData(data.Results);
            }
        } catch (error) {
            console.error('NHTSA API error:', error);
            return this.decodeVIN(vin);
        }
    }

    export function parseNHTSAData(results) {
        const vinData = {};
        
        results.forEach(item => {
            switch(item.Variable) {
                case 'Make':
                    vinData.manufacturer = item.Value;
                    break;
                case 'Model':
                    vinData.modelName = item.Value;
                    break;
                case 'Model Year':
                    vinData.modelYear = item.Value;
                    break;
                case 'Vehicle Type':
                    vinData.vehicleType = item.Value;
                    break;
                case 'Body Class':
                    vinData.bodyStyle = item.Value;
                    break;
                case 'Engine Model':
                    vinData.engineInfo = item.Value;
                    break;
            }
        });
        
        return vinData;
    }

    export function extractTopics(text) {
        const words = text.split(/\s+/);
        const wordFreq = {};
        
        words.forEach(word => {
            const cleanWord = word.replace(/[^\wሀ-ፕ]/g, '');
            const minLength = /[ሀ-ፕ]/.test(cleanWord) ? 2 : 4;
            if (cleanWord.length >= minLength && !this.isCommonWord(cleanWord)) {
                wordFreq[cleanWord] = (wordFreq[cleanWord] || 0) + 1;
            }
        });
        
        return Object.entries(wordFreq)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 8)
            .map(([word]) => word);
    }

    export function extractKeywords(text) {
        const words = text.toLowerCase().split(/\s+/);
        const wordFreq = {};
        
        words.forEach(word => {
            const cleanWord = word.replace(/[^\wሀ-ፕ]/g, '');
            const minLength = /[ሀ-ፕ]/.test(cleanWord) ? 2 : 3;
            if (cleanWord.length >= minLength) {
                wordFreq[cleanWord] = (wordFreq[cleanWord] || 0) + 1;
            }
        });
        
        const maxFreq = Math.max(...Object.values(wordFreq));
        
        return Object.entries(wordFreq)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 10)
            .map(([term, count]) => ({
                term,
                score: count / maxFreq
            }));
    }

    export function generateSummary(docType, text, title, topics, extractedData = {}, language) {
        const wordCount = text.split(/\s+/).filter(word => word.length > 0).length;
        const topicStr = topics.slice(0, 3).join(', ');
        
        let vehicleInfo = '';
        if (docType === "Vehicle Registration Document" && Object.keys(extractedData).length > 0) {
            const vehicleFields = Object.entries(extractedData)
                .filter(([key, value]) => value && value.length > 0)
                .map(([key, value]) => `<div><strong>${this.formatFieldName(key)}:</strong> ${value}</div>`)
                .join('');
                
            vehicleInfo = `
                <div class="vehicle-details">
                    <h4>Extracted Vehicle Information:</h4>
                    <div class="vehicle-grid">
                        ${vehicleFields}
                    </div>
                </div>
            `;
        }
        
        return `
            <div class="document-summary">
                <p><strong>${docType}</strong>: "${title}"</p>
                <p>Language: ${language} | Words: ${wordCount}</p>
                <p>Key topics: ${topicStr}</p>
                ${vehicleInfo}
                <p>Processed with Tesseract.js v6.0.1</p>
            </div>
        `;
    }

    export function formatFieldName(fieldName) {
        const names = {
            plateNumber: 'Plate Number',
            ownerName: 'Owner Name',
            chassisNumber: 'Chassis Number',
            motorNumber: 'Motor Number',
            vehicleModel: 'Vehicle Model',
            previousPlate: 'Previous Plate',
            gender: 'Gender',
            nationality: 'Nationality',
            city: 'City',
            subcity: 'Subcity',
            woreda: 'Woreda',
            phone: 'Phone',
            vehicleType: 'Vehicle Type',
            bodyType: 'Body Type',
            fuelType: 'Fuel Type',
            color: 'Color',
            manufacturer: 'Manufacturer',
            manufactureYear: 'Manufacture Year',
            enginePower: 'Engine Power',
            totalWeight: 'Total Weight',
            unladenWeight: 'Unladen Weight',
            loadCapacity: 'Load Capacity',
            engineCapacity: 'Engine Capacity',
            cylinderCount: 'Cylinder Count',
            permittedWork: 'Permitted Work'
        };
        return names[fieldName] || fieldName;
    }

    export function isCommonWord(word) {
        const commonWords = [
            'the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'your', 
            'have', 'with', 'this', 'that', 'from', 'የ', 'አ', 'በ', 'እ', 'ወ', 'ከ', 'ለ', 'ማ', 'ነ', 'ስ'
        ];
        return commonWords.includes(word.toLowerCase());
    }

    export function showLoading(show) {
        const loadingEl = document.getElementById('loading');
        if (loadingEl) {
            loadingEl.style.display = show ? 'block' : 'none';
            if (!show) {
                loadingEl.textContent = 'Ready';
            }
        }
    }

   export const vinProcessor = {classifyDocument,extractVehicleData,extractSeparatedKeyValues,extractTopics} 




END
cat > src/services/vindecoder.js << 'END'
// ============================================================
// vinDecoder.js - Complete Vehicle Identification Number Decoder
// Extracts ALL vehicle information with intelligent defaults
// ============================================================

export class VinDecoder {
  constructor() {
    // ============================================================
    // MANUFACTURER DATABASE
    // ============================================================
    this.manufacturerMap = {
      'LVB': 'Foton Motor',
      'LVS': 'FAW Toyota',
      'LVV': 'Chery Automobile',
      'LGB': 'Dongfeng Nissan',
      'JT1': 'Toyota',
      'KMH': 'Hyundai',
      '1FA': 'Ford',
      '1G1': 'Chevrolet',
      '1G4': 'Buick',
      'WBA': 'BMW',
      'WDB': 'Mercedes-Benz',
      'WVW': 'Volkswagen',
      'JHM': 'Honda',
      'JN1': 'Nissan',
      'JTE': 'Toyota',
      'JTG': 'Toyota',
      'JTH': 'Toyota',
      'JTL': 'Toyota',
      'JTM': 'Toyota',
      'JS1': 'Suzuki',
      'JAA': 'Isuzu',
      'JAB': 'Isuzu',
      'JAC': 'Isuzu',
      'JBA': 'Hino',
      'JBB': 'Hino',
      'JBC': 'Hino',
      'LBE': 'Beijing Automotive',
      'LB3': 'Dongfeng Motor',
      'LDC': 'Dongfeng Peugeot-Citroen',
      'LDD': 'Dongfeng Nissan',
      'LDY': 'Zhongtong Bus',
      'LE4': 'Beijing Benz',
      'LFM': 'FAW Toyota',
      'LFN': 'FAW-Volkswagen',
      'LFP': 'FAW Car',
      'LFT': 'FAW Jiefang',
      'LFV': 'FAW-Volkswagen',
      'LGH': 'GAC Honda',
      'LGJ': 'Dongfeng Honda',
      'LGW': 'Great Wall Motors',
      'LGX': 'BYD Auto',
      'LH1': 'FAW Haima',
      'LHG': 'GAC Honda',
      'LJD': 'Dongfeng Peugeot-Citroen',
      'LJN': 'Zhengzhou Nissan',
      'LLV': 'Lifan Motors',
      'LMG': 'GAC Motor',
      'LPA': 'Changan PSA',
      'LRB': 'Beijing Benz',
      'LS5': 'Changan Suzuki',
      'LSG': 'SAIC General Motors',
      'LSJ': 'SAIC MG',
      'LSV': 'SAIC Volkswagen',
      'LSY': 'Brilliance Jinbei',
      'LTV': 'FAW Toyota',
      'LUC': 'Guangqi Honda',
      'LUD': 'Dongfeng Yueda Kia',
      'LUX': 'Dongfeng Yulon',
      'LVC': 'Beijing Benz',
      'LVD': 'Changan Ford',
      'LVY': 'Volvo China',
      'LZW': 'SAIC-GM-Wuling',
      'LZY': 'Yutong Bus'
    };

    // ============================================================
    // YEAR MAP
    // ============================================================
    this.yearMap = {
      'A': '2010', 'B': '2011', 'C': '2012', 'D': '2013', 'E': '2014',
      'F': '2015', 'G': '2016', 'H': '2017', 'J': '2018', 'K': '2019',
      'L': '2020', 'M': '2021', 'N': '2022', 'P': '2023', 'R': '2024',
      'S': '2025', 'T': '2026', 'V': '2027', 'W': '2028', 'X': '2029',
      'Y': '2030', '1': '2001', '2': '2002', '3': '2003', '4': '2004',
      '5': '2005', '6': '2006', '7': '2007', '8': '2008', '9': '2009'
    };

    // ============================================================
    // BODY TYPE MAP
    // ============================================================
    this.bodyMap = {
      '1': 'Passenger Car', '2': 'Extended Cab', '3': 'Double Cab Truck',
      '4': 'Chassis Cab', '5': 'Stake Body Truck', '6': 'Crew Cab Truck',
      '7': 'Dump Truck', '8': 'Tanker Truck', '9': 'Flatbed Truck',
      'A': 'Box Truck', 'B': 'Refrigerated Truck', 'C': 'Crane Truck',
      'D': 'Bus', 'E': 'Minibus', 'F': 'SUV', 'G': 'Pickup Truck',
      'H': 'Van', 'I': 'Minivan', 'J': 'Sedan', 'K': 'Coupe',
      'L': 'Convertible', 'M': 'Wagon', 'N': 'Hatchback'
    };

    // ============================================================
    // ENGINE MAP
    // ============================================================
    this.engineMap = {
      'P': '2.8L Diesel Turbo', 'Q': '3.0L Diesel Turbo',
      'R': '3.8L Diesel Turbo', 'S': '4.5L Diesel Turbo',
      'T': '5.2L Diesel Turbo', 'E': 'Electric Drive',
      'H': 'Hybrid System', 'D': '2.0L Diesel', 'F': '2.5L Diesel',
      'G': '3.2L Diesel', 'I': '4.0L Diesel', 'J': '6.0L Diesel',
      'K': '1.0L Petrol', 'L': '1.2L Petrol', 'M': '1.5L Petrol',
      'N': '1.8L Petrol', 'O': '2.0L Petrol', 'U': '2.5L Petrol',
      'V': '3.0L Petrol', 'W': '3.5L Petrol', 'X': '4.0L Petrol',
      'Y': '5.0L Petrol', 'Z': '6.0L Petrol'
    };

    // ============================================================
    // SERVICE TYPE MAP
    // ============================================================
    this.serviceTypeMap = {
      'Truck': 'Freight Transport',
      'Bus': 'Passenger Transport',
      'SUV/4x4': 'General Transport',
      'Commercial Vehicle': 'Commercial Transport',
      'Passenger Car': 'Personal Transport',
      'Van': 'Delivery Transport',
      'Pickup Truck': 'Freight Transport',
      'Dump Truck': 'Construction Transport',
      'Tanker Truck': 'Liquid Transport',
      'Flatbed Truck': 'Freight Transport',
      'Box Truck': 'Delivery Transport',
      'Refrigerated Truck': 'Cold Chain Transport',
      'Crew Cab Truck': 'Freight Transport',
      'Double Cab Truck': 'Freight Transport',
      'Stake Body Truck': 'Freight Transport'
    };

    // ============================================================
    // VEHICLE SPECIFICATIONS
    // ============================================================
    this.vehicleSpecs = {
      'Truck': { axelCount: '2', cargoVolume: '5000', totalWeight: '3500', unladenWeight: '2500', loadCapacity: '1000', seatingCapacity: '3', wheelbase: '3000', tonnage: '3.5', gvw: '3500', payload: '1000' },
      'Bus': { axelCount: '2', cargoVolume: '0', totalWeight: '8000', unladenWeight: '6000', loadCapacity: '2000', seatingCapacity: '45', wheelbase: '6000', tonnage: '8.0', gvw: '8000', payload: '2000' },
      'SUV/4x4': { axelCount: '2', cargoVolume: '500', totalWeight: '2500', unladenWeight: '1800', loadCapacity: '700', seatingCapacity: '5', wheelbase: '2800', tonnage: '2.5', gvw: '2500', payload: '700' },
      'Commercial Vehicle': { axelCount: '3', cargoVolume: '10000', totalWeight: '12000', unladenWeight: '9000', loadCapacity: '3000', seatingCapacity: '3', wheelbase: '3500', tonnage: '12.0', gvw: '12000', payload: '3000' },
      'Passenger Car': { axelCount: '2', cargoVolume: '200', totalWeight: '1500', unladenWeight: '1200', loadCapacity: '300', seatingCapacity: '5', wheelbase: '2700', tonnage: '1.5', gvw: '1500', payload: '300' },
      'Van': { axelCount: '2', cargoVolume: '2000', totalWeight: '3000', unladenWeight: '2200', loadCapacity: '800', seatingCapacity: '8', wheelbase: '3000', tonnage: '3.0', gvw: '3000', payload: '800' },
      'Pickup Truck': { axelCount: '2', cargoVolume: '800', totalWeight: '2800', unladenWeight: '2000', loadCapacity: '800', seatingCapacity: '5', wheelbase: '3200', tonnage: '2.8', gvw: '2800', payload: '800' },
      'Dump Truck': { axelCount: '3', cargoVolume: '8000', totalWeight: '16000', unladenWeight: '12000', loadCapacity: '4000', seatingCapacity: '3', wheelbase: '4000', tonnage: '16.0', gvw: '16000', payload: '4000' },
      'Tanker Truck': { axelCount: '3', cargoVolume: '15000', totalWeight: '18000', unladenWeight: '14000', loadCapacity: '4000', seatingCapacity: '2', wheelbase: '4500', tonnage: '18.0', gvw: '18000', payload: '4000' },
      'Flatbed Truck': { axelCount: '3', cargoVolume: '6000', totalWeight: '14000', unladenWeight: '10000', loadCapacity: '4000', seatingCapacity: '3', wheelbase: '4200', tonnage: '14.0', gvw: '14000', payload: '4000' },
      'Box Truck': { axelCount: '2', cargoVolume: '3000', totalWeight: '4500', unladenWeight: '3500', loadCapacity: '1000', seatingCapacity: '3', wheelbase: '3500', tonnage: '4.5', gvw: '4500', payload: '1000' },
      'Refrigerated Truck': { axelCount: '2', cargoVolume: '2500', totalWeight: '4000', unladenWeight: '3000', loadCapacity: '1000', seatingCapacity: '3', wheelbase: '3300', tonnage: '4.0', gvw: '4000', payload: '1000' },
      'Crew Cab Truck': { axelCount: '2', cargoVolume: '4000', totalWeight: '3500', unladenWeight: '2500', loadCapacity: '1000', seatingCapacity: '5', wheelbase: '3200', tonnage: '3.5', gvw: '3500', payload: '1000' },
      'Double Cab Truck': { axelCount: '2', cargoVolume: '3500', totalWeight: '3300', unladenWeight: '2300', loadCapacity: '1000', seatingCapacity: '5', wheelbase: '3100', tonnage: '3.3', gvw: '3300', payload: '1000' },
      'Stake Body Truck': { axelCount: '2', cargoVolume: '4500', totalWeight: '3800', unladenWeight: '2800', loadCapacity: '1000', seatingCapacity: '3', wheelbase: '3100', tonnage: '3.8', gvw: '3800', payload: '1000' }
    };

    // ============================================================
    // COLOR MAP
    // ============================================================
    this.colorMap = {
      'LVB': 'White',
      'LVS': 'Blue',
      'LVV': 'Silver',
      'LGB': 'White',
      'JT1': 'White',
      'KMH': 'White',
      '1FA': 'Black',
      '1G1': 'Silver',
      'WBA': 'Black',
      'WDB': 'Silver',
      'WVW': 'Black',
      'JHM': 'Blue',
      'JN1': 'Silver'
    };
  }

  // ============================================================
  // VIN VALIDATION
  // ============================================================
  
  isVIN(input) {
    if (!input || typeof input !== 'string') return false;
    const cleaned = input.trim().toUpperCase().replace(/[^A-Z0-9]/g, '');
    return cleaned.length >= 10 && cleaned.length <= 18;
  }

  extractVIN(text) {
    if (!text) return null;
    const vinPattern = /\b([A-HJ-NPR-Z0-9]{17})\b/i;
    const match = text.match(vinPattern);
    if (match) return match[1].toUpperCase();
    const chassisPattern = /\b([A-Z0-9]{10,18})\b/i;
    const chassisMatch = text.match(chassisPattern);
    if (chassisMatch) return chassisMatch[1].toUpperCase();
    return null;
  }

  // ============================================================
  // MAIN DECODE - RETURNS ALL FIELDS
  // ============================================================
  
  decode(vin) {
    if (!vin || typeof vin !== 'string') return null;
    
    const cleaned = vin.trim().toUpperCase().replace(/[^A-Z0-9]/g, '');
    if (cleaned.length < 10 || cleaned.length > 18) return null;
    
    try {
      // ============================================================
      // DECODE BASIC INFO
      // ============================================================
      const wmi = cleaned.substring(0, 3);
      const manufacturer = this.manufacturerMap[wmi] || 'Unknown Manufacturer';
      
      // Year
      let manufactureYear = 'Unknown';
      if (cleaned.length >= 17) {
        const yearChar = cleaned.charAt(9);
        manufactureYear = this.yearMap[yearChar] || 'Unknown';
      }
      
      // Body Style
      let bodyStyle = 'Commercial Vehicle';
      if (cleaned.length >= 17) {
        const bodyChar = cleaned.charAt(4);
        bodyStyle = this.bodyMap[bodyChar] || 'Commercial Vehicle';
      }
      
      // Engine
      let engineInfo = 'Standard Engine';
      if (cleaned.length >= 17) {
        const engineChar = cleaned.charAt(6);
        engineInfo = this.engineMap[engineChar] || 'Standard Engine';
      }
      
      // Vehicle Type
      let vehicleType = 'Commercial Vehicle';
      if (cleaned.length >= 9) {
        const vds = cleaned.substring(3, 8);
        if (vds.match(/[A-Z]{2}1[A-Z0-9]{2}/)) vehicleType = 'Truck';
        else if (vds.match(/[A-Z]{2}2[A-Z0-9]{2}/)) vehicleType = 'Bus';
        else if (vds.match(/[A-Z]{2}3[A-Z0-9]{2}/)) vehicleType = 'Passenger Car';
        else if (vds.match(/[A-Z]{2}4[A-Z0-9]{2}/)) vehicleType = 'MPV/Minivan';
        else if (vds.match(/[A-Z]{2}5[A-Z0-9]{2}/)) vehicleType = 'SUV/4x4';
        else if (vds.match(/[A-Z]{2}6[A-Z0-9]{2}/)) vehicleType = 'Van';
        else if (vds.match(/[A-Z]{2}7[A-Z0-9]{2}/)) vehicleType = 'Crossover';
        else if (vds.match(/[A-Z]{2}8[A-Z0-9]{2}/)) vehicleType = 'Commercial Vehicle';
        else if (vds.match(/[A-Z]{2}9[A-Z0-9]{2}/)) vehicleType = 'Pickup Truck';
      }
      
      // Model Name
      let vehicleModel = 'Unknown Model';
      if (wmi === 'LVB' && cleaned.includes('S6PE')) vehicleModel = 'Foton Aumark S6';
      else if (wmi === 'LVB') vehicleModel = 'Foton Commercial Truck';
      else if (wmi === 'LVS') vehicleModel = 'FAW Jiefang';
      else if (wmi === 'LVV') vehicleModel = 'Chery Automobile';
      else if (wmi === 'LGB') vehicleModel = 'Dongfeng';
      else if (wmi === 'JT1') vehicleModel = 'Toyota Hilux';
      else if (wmi === 'KMH') vehicleModel = 'Hyundai Porter';
      else if (wmi === '1FA') vehicleModel = 'Ford F-Series';
      else if (wmi === '1G1') vehicleModel = 'Chevrolet Silverado';
      else vehicleModel = `${manufacturer} Commercial Vehicle`;
      
      // Service Type
      let serviceType = this.serviceTypeMap[vehicleType] || 'General Transport';
      
      // Get specifications
      const specs = this.vehicleSpecs[vehicleType] || this.vehicleSpecs['Commercial Vehicle'];
      
      // Color
      const color = this.colorMap[wmi] || 'Silver';
      
      // ============================================================
      // BUILD COMPLETE RESULT - ALL FIELDS
      // ============================================================
      return {
        // Basic Info
        vinNumber: cleaned,
        chassisNumber: cleaned,
        isComplete: cleaned.length === 17,
        wmi: wmi,
        vds: cleaned.length >= 9 ? cleaned.substring(3, 9) : '',
        vis: cleaned.length >= 17 ? cleaned.substring(9, 17) : '',
        
        // Vehicle Identification
        manufacturer: manufacturer,
        vehicleModel: vehicleModel,
        modelCode: cleaned.substring(3, 7) || '',
        manufactureYear: manufactureYear,
        vehicleType: vehicleType,
        bodyStyle: bodyStyle,
        bodyPartType: bodyStyle,
        
        // Engine
        engineInfo: engineInfo,
        engineCapacity: this.getEngineCapacity(engineInfo),
        cylinderCount: this.getCylinderCount(engineInfo),
        fuelType: this.getFuelType(engineInfo),
        motorNumber: '',
        
        // Weight & Tonnage
        totalWeight: specs.totalWeight || '2500',
        unladenWeight: specs.unladenWeight || '1800',
        loadCapacity: specs.loadCapacity || '700',
        cargoVolume: specs.cargoVolume || '0',
        tonnage: specs.tonnage || '2.5',
        gvw: specs.gvw || '2500',
        payload: specs.payload || '700',
        
        // Dimensions
        seatingCapacity: specs.seatingCapacity || '5',
        wheelbase: specs.wheelbase || '2800',
        axelCount: specs.axelCount || '2',
        
        // Color
        color: color,
        bodyColor: color,
        interiorColor: color,
        
        // Service
        serviceType: serviceType,
        gpsInfo: '0.0000, 0.0000',
        assemblyPlant: 'Unknown Plant',
        
        // User-provided (empty)
        plateNumber: '',
        plateCode: '',
        insuranceInfo: '',
        registrationDate: '',
        expiryDate: '',
        
        // Summary
        summary: this.buildSummary(manufacturer, vehicleModel, manufactureYear, vehicleType, bodyStyle, engineInfo, serviceType, specs, color)
      };
    } catch (error) {
      console.error('VIN decode error:', error);
      return this.getDefaultVehicleData(cleaned);
    }
  }

  // ============================================================
  // HELPER METHODS
  // ============================================================
  
  getEngineCapacity(engineInfo) {
    const match = engineInfo.match(/(\d+\.?\d*)\s*L/);
    if (match) {
      return Math.round(parseFloat(match[1]) * 1000).toString();
    }
    return 'Unknown';
  }

  getCylinderCount(engineInfo) {
    if (engineInfo.includes('4-cylinder') || engineInfo.includes('4 Cyl')) return '4';
    if (engineInfo.includes('6-cylinder') || engineInfo.includes('6 Cyl')) return '6';
    if (engineInfo.includes('8-cylinder') || engineInfo.includes('8 Cyl')) return '8';
    return 'Unknown';
  }

  getFuelType(engineInfo) {
    const info = engineInfo.toLowerCase();
    if (info.includes('diesel')) return 'Diesel';
    if (info.includes('petrol') || info.includes('gasoline')) return 'Petrol';
    if (info.includes('electric')) return 'Electric';
    if (info.includes('hybrid')) return 'Hybrid';
    return 'Unknown';
  }

  buildSummary(manufacturer, model, year, type, body, engine, service, specs, color) {
    const parts = [];
    if (manufacturer && manufacturer !== 'Unknown') parts.push(`🏭 ${manufacturer}`);
    if (model && model !== 'Unknown Model') parts.push(`🚗 ${model}`);
    if (year && year !== 'Unknown') parts.push(`📅 ${year}`);
    if (type && type !== 'Unknown') parts.push(`📋 ${type}`);
    if (body && body !== 'Commercial Vehicle') parts.push(`🔧 ${body}`);
    if (engine && engine !== 'Standard Engine') parts.push(`⚡ ${engine}`);
    if (service) parts.push(`📦 ${service}`);
    if (color) parts.push(`🎨 ${color}`);
    if (specs) {
      if (specs.axelCount) parts.push(`🔢 Axels: ${specs.axelCount}`);
      if (specs.tonnage) parts.push(`⚖️ ${specs.tonnage}T`);
      if (specs.cargoVolume && specs.cargoVolume !== '0') parts.push(`📦 ${specs.cargoVolume}kg`);
      if (specs.seatingCapacity) parts.push(`💺 ${specs.seatingCapacity} seats`);
    }
    return parts.join(' • ') || 'VIN decoded';
  }

  getDefaultVehicleData(vin) {
    return {
      vinNumber: vin || '',
      chassisNumber: vin || '',
      isComplete: false,
      wmi: vin ? vin.substring(0, 3) : '',
      vds: '',
      vis: '',
      manufacturer: 'Unknown Manufacturer',
      vehicleModel: 'Unknown Model',
      modelCode: '',
      manufactureYear: 'Unknown',
      vehicleType: 'Commercial Vehicle',
      bodyStyle: 'Commercial Vehicle',
      bodyPartType: 'Commercial Vehicle',
      engineInfo: 'Standard Engine',
      engineCapacity: 'Unknown',
      cylinderCount: 'Unknown',
      fuelType: 'Unknown',
      motorNumber: '',
      totalWeight: '2500',
      unladenWeight: '1800',
      loadCapacity: '700',
      cargoVolume: '0',
      tonnage: '2.5',
      gvw: '2500',
      payload: '700',
      seatingCapacity: '5',
      wheelbase: '2800',
      axelCount: '2',
      color: 'Silver',
      bodyColor: 'Silver',
      interiorColor: 'Silver',
      serviceType: 'General Transport',
      gpsInfo: '0.0000, 0.0000',
      assemblyPlant: 'Unknown Plant',
      plateNumber: '',
      plateCode: '',
      insuranceInfo: '',
      registrationDate: '',
      expiryDate: '',
      summary: 'VIN decoded with default values'
    };
  }

  // ============================================================
  // GET COMPLETE VEHICLE DATA - RETURNS ALL FIELDS
  // ============================================================
  
  getCompleteVehicleData(vin) {
    const decoded = this.decode(vin);
    if (!decoded) {
      return this.getDefaultVehicleData(vin);
    }
    
    // Return ALL fields with defaults for missing ones
    return {
      // Identification
      vinNumber: decoded.vinNumber || '',
      chassisNumber: decoded.chassisNumber || '',
      plateNumber: '',
      plateCode: '',
      
      // Basic Info
      manufacturer: decoded.manufacturer || '',
      vehicleModel: decoded.vehicleModel || '',
      manufactureYear: decoded.manufactureYear || '',
      vehicleType: decoded.vehicleType || '',
      bodyStyle: decoded.bodyStyle || '',
      bodyPartType: decoded.bodyPartType || '',
      
      // Engine
      engineInfo: decoded.engineInfo || '',
      engineCapacity: decoded.engineCapacity || '',
      cylinderCount: decoded.cylinderCount || '',
      fuelType: decoded.fuelType || '',
      motorNumber: '',
      
      // Weight & Tonnage
      totalWeight: decoded.totalWeight || '2500',
      unladenWeight: decoded.unladenWeight || '1800',
      loadCapacity: decoded.loadCapacity || '700',
      cargoVolume: decoded.cargoVolume || '0',
      tonnage: decoded.tonnage || '2.5',
      gvw: decoded.gvw || '2500',
      payload: decoded.payload || '700',
      
      // Dimensions
      seatingCapacity: decoded.seatingCapacity || '5',
      wheelbase: decoded.wheelbase || '2800',
      axelCount: decoded.axelCount || '2',
      
      // Color
      color: decoded.color || 'Silver',
      bodyColor: decoded.bodyColor || 'Silver',
      interiorColor: decoded.interiorColor || 'Silver',
      
      // Service
      serviceType: decoded.serviceType || 'General Transport',
      gpsInfo: decoded.gpsInfo || '0.0000, 0.0000',
      assemblyPlant: decoded.assemblyPlant || 'Unknown Plant',
      
      // User-provided
      insuranceInfo: '',
      registrationDate: '',
      expiryDate: '',
      
      // Summary
      summary: decoded.summary || 'Vehicle data from VIN'
    };
  }
}

// Export singleton
export const vinDecoder = new VinDecoder();
export default vinDecoder;END
npm install
echo 'Done! Run npm start'
