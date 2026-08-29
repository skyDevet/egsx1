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
};