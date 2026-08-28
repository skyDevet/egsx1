// ============================================================
// apiTasks.js - Capgo InAppBrowser Action Handler (VISIBLE MODE)
// ============================================================

import { InAppBrowser } from '@capgo/capacitor-inappbrowser';

let apiLogs = [];
let activeBrowsers = {};
let browserResults = {};

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
// CAPGO INAPPBROWSER CORE - VISIBLE BROWSER
// ============================================================

async function runCapgoScript(code, url = 'about:blank', hidden = false) {
  console.log('🌐 Running Capgo InAppBrowser script in VISIBLE mode...');
  
  try {
    // Open browser VISIBLY
    const { id } = await InAppBrowser.openWebView({
      url: url,
      hidden: hidden, // false = visible
      options: {
        showToolbar: true,
        showURL: true,
        toolbarColor: '#2563eb',
        navigationBarColor: '#1e293b'
      }
    });
    
    activeBrowsers[id] = { id, timestamp: Date.now(), url };
    
    // Wait for page to load
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    // Execute the script
    const result = await InAppBrowser.executeScript({
      id,
      js: `
        (async function() {
          try {
            ${code}
          } catch (error) {
            console.error('Script error:', error);
            return { success: false, error: error.message };
          }
        })();
      `
    });
    
    // Store result
    browserResults[id] = result;
    
    // Don't close automatically - let user see what happened
    console.log('✅ Capgo script executed, browser remains visible');
    return { ...result, browserId: id };
    
  } catch (error) {
    console.error('❌ Capgo error:', error.message);
    return { success: false, error: error.message };
  }
}

// ============================================================
// CLOSE BROWSER
// ============================================================

export async function closeBrowser(browserId) {
  try {
    await InAppBrowser.closeWebView({ id: browserId });
    delete activeBrowsers[browserId];
    delete browserResults[browserId];
    return { success: true };
  } catch (error) {
    return { success: false, error: error.message };
  }
}

export async function closeAllBrowsers() {
  for (const id of Object.keys(activeBrowsers)) {
    try {
      await InAppBrowser.closeWebView({ id });
    } catch (e) {
      console.error(`Failed to close browser ${id}:`, e);
    }
  }
  activeBrowsers = {};
  browserResults = {};
}

// ============================================================
// CAPGO SCRIPTS - NAVIGATE AND FILL FORMS
// ============================================================

function getLoginScript(username, password) {
  return `
    console.log('🔐 Starting login process...');
    
    // Navigate to login page
    window.location.href = 'https://iftms.motl.gov.et/auth/sign-in';
    
    // Wait for page to load
    await new Promise(resolve => {
      const checkInterval = setInterval(() => {
        if (document.querySelector('[name="phone_number"]')) {
          clearInterval(checkInterval);
          resolve();
        }
      }, 100);
      setTimeout(resolve, 10000);
    });
    
    console.log('📝 Filling login form...');
    
    // Fill login form
    const phoneField = document.querySelector('[name="phone_number"]');
    const passwordField = document.querySelector('input[type="password"]');
    const submitButton = document.querySelector('button[type="submit"]');
    
    if (phoneField) {
      phoneField.value = '${username}';
      phoneField.dispatchEvent(new Event('input', { bubbles: true }));
    }
    
    if (passwordField) {
      passwordField.value = '${password}';
      passwordField.dispatchEvent(new Event('input', { bubbles: true }));
    }
    
    console.log('✅ Form filled, submitting...');
    
    if (submitButton) {
      submitButton.click();
    }
    
    // Wait for navigation
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    const success = window.location.href.includes('dashboard');
    const url = window.location.href;
    
    console.log(success ? '✅ Login successful!' : '❌ Login failed');
    console.log('📍 Current URL:', url);
    
    return {
      success: success,
      url: url,
      message: success ? 'Login successful' : 'Login failed - check credentials'
    };
  `;
}

function getRegisterVehicleScript(vehicleData) {
  return `
    console.log('🚗 Starting vehicle registration...');
    
    window.location.href = 'https://iftms.motl.gov.et/vehicles/add';
    
    await new Promise(resolve => {
      const checkInterval = setInterval(() => {
        if (document.querySelector('[name="plateNumber"]')) {
          clearInterval(checkInterval);
          resolve();
        }
      }, 100);
      setTimeout(resolve, 10000);
    });
    
    console.log('📝 Filling vehicle form...');
    
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
      if (el) {
        el.value = value;
        el.dispatchEvent(new Event('input', { bubbles: true }));
        console.log(\`  ✅ Filled \${name}: \${value}\`);
      }
    });
    
    const submitButton = document.querySelector('button[type="submit"]');
    if (submitButton) {
      console.log('📤 Submitting form...');
      submitButton.click();
    }
    
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    const success = window.location.href.includes('success');
    console.log(success ? '✅ Vehicle registered!' : '❌ Registration failed');
    
    return {
      success: success,
      url: window.location.href
    };
  `;
}

function getRegisterDriverScript(driverData) {
  return `
    console.log('👤 Starting driver registration...');
    
    window.location.href = 'https://iftms.motl.gov.et/drivers/add';
    
    await new Promise(resolve => {
      const checkInterval = setInterval(() => {
        if (document.querySelector('[name="driverName"]')) {
          clearInterval(checkInterval);
          resolve();
        }
      }, 100);
      setTimeout(resolve, 10000);
    });
    
    console.log('📝 Filling driver form...');
    
    const fields = {
      'driverName': '${driverData.driverName || ''}',
      'driverLicense': '${driverData.driverLicense || ''}',
      'phoneNumber': '${driverData.phoneNumber || ''}',
      'email': '${driverData.email || ''}'
    };
    
    Object.entries(fields).forEach(([name, value]) => {
      const el = document.querySelector(\`[name="\${name}"]\`);
      if (el) {
        el.value = value;
        el.dispatchEvent(new Event('input', { bubbles: true }));
        console.log(\`  ✅ Filled \${name}: \${value}\`);
      }
    });
    
    const submitButton = document.querySelector('button[type="submit"]');
    if (submitButton) {
      console.log('📤 Submitting form...');
      submitButton.click();
    }
    
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    const success = window.location.href.includes('success');
    console.log(success ? '✅ Driver registered!' : '❌ Registration failed');
    
    return {
      success: success,
      url: window.location.href
    };
  `;
}

function getSyncScript(operatorData, vehicles, drivers) {
  return `
    console.log('🔄 Starting sync process...');
    
    window.location.href = 'https://iftms.motl.gov.et/sync';
    
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    // Collect data from page
    const pageData = {
      operator: ${JSON.stringify(operatorData)},
      vehicles: ${JSON.stringify(vehicles)},
      drivers: ${JSON.stringify(drivers)}
    };
    
    console.log('📊 Data prepared for sync:', pageData);
    
    // Try to find and click sync button
    const syncButton = document.querySelector('button[type="submit"]') || 
                       document.querySelector('button:contains("Sync")');
    
    if (syncButton) {
      console.log('📤 Clicking sync button...');
      syncButton.click();
      await new Promise(resolve => setTimeout(resolve, 3000));
    }
    
    return {
      success: true,
      data: pageData,
      url: window.location.href
    };
  `;
}

function getVINDecodeScript(vin) {
  // VIN decoding - use fetch directly in app context instead
  return `
    console.log('🔍 Decoding VIN: ${vin}');
    
    // Return the VIN - app will handle the fetch
    return {
      success: true,
      action: 'decode_vin',
      vin: '${vin}'
    };
  `;
}

// ============================================================
// API ACTION EXECUTOR - WITH VISIBLE BROWSER
// ============================================================

export async function executeApiAction(action, context = {}) {
  const startTime = Date.now();
  
  try {
    let result;
    let browserId = null;
    
    console.log(`🎯 Executing action: ${action.id || action.type}`);
    
    switch (action.id) {
      case 'login_to_iftms':
      case 'login_operator':
        const username = context.phoneNumber || context.operator?.phoneNumber || '';
        const password = context.password || context.operator?.password || '';
        result = await runCapgoScript(getLoginScript(username, password), 'https://iftms.motl.gov.et/auth/sign-in', false);
        browserId = result.browserId;
        break;
        
      case 'register_vehicle':
        result = await runCapgoScript(getRegisterVehicleScript(context), 'https://iftms.motl.gov.et/vehicles/add', false);
        browserId = result.browserId;
        break;
        
      case 'register_driver':
        result = await runCapgoScript(getRegisterDriverScript(context), 'https://iftms.motl.gov.et/drivers/add', false);
        browserId = result.browserId;
        break;
        
      case 'sync_to_ifmts':
        result = await runCapgoScript(
          getSyncScript(context.operator || {}, context.vehicles || [], context.drivers || []),
          'https://iftms.motl.gov.et/sync',
          false
        );
        browserId = result.browserId;
        break;
        
      case 'decode_vin':
        // VIN decoding - fetch in app context (NOT in WebView)
        const vin = context.vinNumber || context.userInput || '';
        console.log('🔍 Decoding VIN in app context:', vin);
        try {
          const response = await fetch(`https://vpic.nhtsa.dot.gov/api/vehicles/decodevin/${vin}?format=json`);
          if (!response.ok) throw new Error(`HTTP ${response.status}`);
          const data = await response.json();
          result = { success: true, data };
        } catch (error) {
          result = { success: false, error: error.message };
        }
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
      success: result.success !== false,
      browserId: browserId
    });
    
    console.log(`✅ API Action [${action.id}] completed in ${duration}ms:`, result);
    return { ...result, browserId };
    
  } catch (error) {
    const duration = Date.now() - startTime;
    
    apiLogs.push({
      timestamp: new Date().toISOString(),
      action: action.id || action.type,
      duration,
      success: false,
      error: error.message
    });
    
    console.error(`❌ API Action [${action.id}] failed:`, error);
    
    return {
      success: false,
      error: error.message
    };
  }
}

// ============================================================
// GET BROWSER STATUS
// ============================================================

export function getActiveBrowsers() {
  return Object.values(activeBrowsers);
}

export function getBrowserResult(browserId) {
  return browserResults[browserId] || null;
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
// HELPER FUNCTIONS
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
  
  try {
    const lang = localStorage.getItem('agig-language') || 'en';
    if (typeof message === 'object') {
      return message[lang] || message.en || '';
    }
  } catch {
    return message.en || '';
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
  closeBrowser,
  closeAllBrowsers,
  getActiveBrowsers,
  getBrowserResult,
  runCapgoScript
};