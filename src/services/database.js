// ========== database.js ==========
import { openDB } from 'idb'

const DB_NAME = 'DocAnalyzerDB'
const DB_VERSION = 8  // Incremented version
const STORE_NAME = 'chatHistory'

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
      
        
        // Handle upgrades from older versions
        if (oldVersion < 6) {
          console.log(`Upgrading database from version ${oldVersion} to ${newVersion}`)
          // Migration logic if needed
        }
      }
    })
    return this.db
  }


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
}

export const db = new Database()