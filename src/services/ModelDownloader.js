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
export const modelDownloader = new ModelDownloader();