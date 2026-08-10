// transformersModel.js - Model service following your existing pattern
// This loads transformers.js completely outside Vite's module system

let qaPipeline = null;
let modelLoaded = false;
let loadingProgress = 0;
let loadingStatus = 'Not started';
let errorMessage = null;

// Callback registry (matching your pattern)
let progressCallbacks = [];
let readyCallbacks = [];
let errorCallbacks = [];

// Load transformers from CDN via script tag (bypasses Vite)
async function loadTransformersCDN() {
  return new Promise((resolve, reject) => {
    // Check if already loaded
    if (window.transformers) {
      resolve(window.transformers);
      return;
    }
    
    const script = document.createElement('script');
    script.src = 'https://cdn.jsdelivr.net/npm/@xenova/transformers@2.17.0/dist/transformers.min.js';
    script.onload = () => {
      console.log('✅ Transformers.js loaded from CDN');
      resolve(window.transformers);
    };
    script.onerror = (err) => {
      console.error('❌ Failed to load Transformers.js:', err);
      reject(new Error('Failed to load Transformers.js from CDN'));
    };
    document.head.appendChild(script);
  });
}

// Initialize the model (call this after app starts)
export async function initTransformersModel() {
  if (modelLoaded) return;
  if (loadingStatus === 'Loading...') return;
  
  console.log('🔄 Initializing Transformers Model Service...');
  loadingStatus = 'Loading...';
  
  try {
    // Update progress
    progressCallbacks.forEach(cb => cb(5, 'Loading transformers.js from CDN...'));
    
    // Load transformers library
    const transformers = await loadTransformersCDN();
    const { pipeline, env } = transformers;
    
    // Configure for local models (your Flask serves these)
    env.localModelPath = '/models/';
    env.useBrowserCache = false;
    env.useFSCache = false;
    
    progressCallbacks.forEach(cb => cb(10, 'Initializing DistilBERT model...'));
    
    // Load the pipeline
    qaPipeline = await pipeline(
      'question-answering',
      'Xenova/distilbert-base-cased-distilled-squad',
      {
        quantized: true,
        progress_callback: (progress) => {
          if (progress && progress.progress) {
            const percent = Math.round(progress.progress * 100);
            loadingProgress = percent;
            progressCallbacks.forEach(cb => cb(percent, `Downloading model: ${percent}%`));
            console.log(`📥 Model download: ${percent}% - ${progress.file || ''}`);
          }
        }
      }
    );
    
    modelLoaded = true;
    loadingStatus = 'Ready';
    console.log('✅ Transformers model loaded successfully!');
    readyCallbacks.forEach(cb => cb());
    
  } catch (error) {
    console.error('❌ Transformers model error:', error);
    loadingStatus = 'Error';
    errorMessage = error.message;
    errorCallbacks.forEach(cb => cb(error.message));
  }
}

// Check if model is ready
export function isModelReady() {
  return modelLoaded && qaPipeline !== null;
}

// Get loading progress
export function getModelProgress() {
  return { progress: loadingProgress, status: loadingStatus, error: errorMessage };
}

// Ask a question using the loaded model
export async function askQuestion(question, context) {
  if (!modelLoaded || !qaPipeline) {
    throw new Error('Model not ready yet. Please wait for initialization.');
  }
  
  try {
    console.log('🤖 Asking question:', question);
    const result = await qaPipeline(question, context);
    return {
      answer: result.answer,
      score: result.score,
      confidence: (result.score * 100).toFixed(1)
    };
  } catch (error) {
    console.error('Error asking question:', error);
    throw error;
  }
}

// Register callbacks (matching your nlpProcessor pattern)
export function onProgress(callback) {
  progressCallbacks.push(callback);
}

export function onReady(callback) {
  readyCallbacks.push(callback);
}

export function onError(callback) {
  errorCallbacks.push(callback);
}

// Auto-initialize after a delay (lets app load first)
if (typeof window !== 'undefined') {
  // Wait for DOM to load, then initialize
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      setTimeout(() => initTransformersModel(), 500);
    });
  } else {
    setTimeout(() => initTransformersModel(), 500);
  }
}

// Export as object matching your pattern
export const transformersModel = {
  init: initTransformersModel,
  isReady: isModelReady,
  ask: askQuestion,
  getProgress: getModelProgress,
  onProgress,
  onReady,
  onError
};