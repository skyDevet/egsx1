// src/services/nlpP.js
import * as pdfjsLib from 'pdfjs-dist/build/pdf'
import pdfjsWorker from 'pdfjs-dist/build/pdf.worker?url'
import nlp from 'compromise'
import { pipeline } from '@xenova/transformers';
import { apiHandler } from './API'
import { db } from './database.js'
import { teSsAna } from "./tess.js"
import { pdfAnalyzerF } from './pdfAnalyzer.js'
import { generateSearchBasedResponse, simulateSearchResults } from './duck.js'
import { intentPatternsx } from "./intnts.js";
import { ministriesFed } from "./data.js";

pdfjsLib.GlobalWorkerOptions.workerSrc = pdfjsWorker

let initialized = false
let currentIntent = null
let currentStep = 0
let awaitingVehicleInfo = false
let isLibreValidated = null
let awaitingDriverInfo = null
let awaitingOTP = false
let isDriverValidated = null
let isInsValidated = null
let isIftmsInit = false
let arePhotosUp = false
let numPhotos = 3
let intentPatterns = {}
let stepResponses = {}
let awaitingPhotoUpload = null
let themeChosen = null
let chosenTheme = null

export async function initNLPProcessor() {
  if (initialized) return
  console.log('🔄 Initializing NLP Processor...')
  initialized = true
  console.log('✅ NLP Processor initialized')
}

export function setupGovPatterns() {
  govPatterns = ministriesFed
}

export function setupIntentPatterns() {
  intentPatterns = intentPatternsx
}

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
}

export function isContinuationMessage(text) {
  const lowerText = text.toLowerCase() 
  return lowerText.includes('continuing from') || 
         lowerText.includes('continuing...') ||
         lowerText.includes('continue from') ||
         lowerText.includes('ወደ ቀጣዩ ደረጃ') || 
         lowerText.includes('resume from') ||
         (lowerText.includes('step') && (lowerText.includes('continue') || lowerText.includes('resume')))
}

export function isActionButtonText(text) {
  const actionButtons = [
    'Upload Business License', 'Enter License Manually',
    'Upload Vehicle Documents', 'Add Another Vehicle',
    'Upload Driver Documents', 'Complete',
    'Download License', 'Start New Application',
    'Upload License', 'Enter License Number',
    'Upload Tax Certificate', 'Upload Other Documents',
    'Make Payment', 'Upload Payment Receipt',
    'Download New License', 'Print Certificate',
    'Verify and Continue', 'Browse File',
    'Continue Response', 'Resume', 'Continue'
  ]
  const lowerText = text.toLowerCase()
  return actionButtons.some(action => 
    lowerText.includes(action.toLowerCase().substring(0, 8))
  )
}

export function isResumeButton(text) {
  const resumeTexts = ['Continuing...','continue response', 'resume', 'continue', 'play_arrow']
  const lowerText = text.toLowerCase()
  return resumeTexts.some(resume => lowerText.includes(resume))
}

export function generateActionResponseHTML(text, service, currentStep, nextStep, language) {
  const stepResponses = {
    generateVideo: {
      1: ['Upload photos'],
      2: ['send video title'],
      3: ['choose theme'],
      4: ['Download video', 'Create New video']
    },
    iftms: {
      1: ['Upload Business License', 'Enter License Manually'],
      2: ['Upload Vehicle Documents', 'Add Another Vehicle'],
      3: ['Upload Driver Documents', 'Complete'],
      4: ['Download License', 'Start New Application']
    },
    renewDoc: {
      1: ['Upload License', 'Enter License Number'],
      2: ['Upload Tax Certificate', 'Upload Other Documents'],
      3: ['Make Payment', 'Upload Payment Receipt'],
      4: ['Download New License', 'Print Certificate']
    }
  }
  
  const actions = stepResponses[service]?.[nextStep || currentStep] || []
  
  return `
    <div class="message-content action-response" 
         data-service="${service}" 
         data-step="${currentStep}" 
         data-next-step="${nextStep}">
      <div class="action-text">
        <p>${text}</p>
      </div>
      ${actions.length > 0 ? `
      <div class="action-buttons">
        ${actions.map(action => `
          <button class="action-btn" 
                  data-action="${action}" 
                  data-service="${service}" 
                  data-step="${nextStep || currentStep}">
            ${action}
          </button>
        `).join('')}
      </div>
      ` : ''}
    </div>
  `
}

export function isVehicleChassisNumber(text) {
  if (!text || typeof text !== 'string') return false
  const cleanText = text.toString().trim().toUpperCase()
  if (cleanText.length !== 17) return false
  if (/[IOQ]/.test(cleanText)) return false
  if (!/^[A-HJ-NPR-Z0-9]{17}$/.test(cleanText)) return false
  return validateVinCheckDigit(cleanText)
}

export function validateVinCheckDigit(vin) {
  const transliteration = {
    '0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9,
    'A': 1, 'B': 2, 'C': 3, 'D': 4, 'E': 5, 'F': 6, 'G': 7, 'H': 8,
    'J': 1, 'K': 2, 'L': 3, 'M': 4, 'N': 5, 'P': 7, 'R': 9,
    'S': 2, 'T': 3, 'U': 4, 'V': 5, 'W': 6, 'X': 7, 'Y': 8, 'Z': 9
  }
  const weights = [8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2]
  let sum = 0
  for (let i = 0; i < 17; i++) {
    const char = vin[i]
    const value = transliteration[char]
    if (value === undefined) return false
    sum += value * weights[i]
  }
  const remainder = sum % 11
  const expectedCheckDigit = remainder === 10 ? 'X' : remainder.toString()
  const actualCheckDigit = vin[8]
  return actualCheckDigit === expectedCheckDigit
}

export function handleActionButton(message) {
  const language = localStorage.getItem('agig-language') || 'en'
  const currentService = sessionStorage.getItem('intnt') || 'iftms'
  const currentStep = parseInt(sessionStorage.getItem('currentStep')) || 1
  
  const actionResponses = {
    'Upload Business License': {
      text: language === 'am' 
        ? 'እባክዎ የንግድ ፈቃድ ሰነድዎን ይስቀሉ። ፋይሉ ፒዲኤፍ ወይም ምስል ሊሆን ይችላል።'
        : 'Please upload your business license document. The file can be PDF or image format.',
      nextStep: currentStep
    },
    'Enter License Manually': {
      text: language === 'am'
        ? 'እባክዎ የንግድ ፈቃድ ቁጥርዎን ያስገቡ (ምሳሌ: 14/668/5068/2004)'
        : 'Please enter your business license number (e.g., 14/668/5068/2004)',
      nextStep: currentStep
    },
    'Verify and Continue': {
      text: language === 'am'
        ? '✅ ፈቃድ ቁጥር ተረጋግጧል! አሁን የተሽከርካሪዎን ሰነዶች ያስገቡ።'
        : '✅ License number verified! Now please upload your vehicle documents.',
      nextStep: currentStep + 1
    },
    'Upload Vehicle Documents': {
      text: language === 'am'
        ? 'እባክዎ የተሽከርካሪ ምዝገባ ሰነዶችዎን ይስቀሉ።'
        : 'Please upload your vehicle registration documents.',
      nextStep: currentStep
    },
    'Add Another Vehicle': {
      text: language === 'am'
        ? 'ሌላ ተሽከርካሪ ለመጨመር እባክዎ ሰነዶቹን ይስቀሉ።'
        : 'To add another vehicle, please upload the documents.',
      nextStep: currentStep
    },
    'Upload Driver Documents': {
      text: language === 'am'
        ? 'እባክዎ የሹፌር ፈቃድ እና የታደሰ መታወቂያ ሰነድ ይስቀሉ።'
        : "Please upload driver's license and national ID document.",
      nextStep: currentStep
    },
    'Complete': {
      text: language === 'am'
        ? 'ሁሉም ሰነዶች ተቀብለዋል። ማጠናቀቂያ ላይ ነው...'
        : 'All documents received. Finalizing...',
      nextStep: currentStep + 1
    },
    'Download License': {
      text: language === 'am'
        ? '✅ የጭነት መጓጓዣ ፈቃድዎ ተሰጥቷል። ሰነዱን ለማውረድ ከዚህ በታች ይጫኑ።'
        : '✅ Your freight transport license has been approved. Click below to download the document.',
      nextStep: null
    },
    'Start New Application': {
      text: language === 'am'
        ? 'ሌላ ተሽከርካሪ መጨመር ይፈልጋሉ?'
        : 'Would you like to add another vehicle?',
      nextStep: 2
    }
  }
  
  for (const [action, response] of Object.entries(actionResponses)) {
    if (message.toLowerCase().includes(action.toLowerCase().substring(0, 10))) {
      if (response.nextStep) {
        sessionStorage.setItem('currentStep', response.nextStep.toString())
      }
      return {
        text: response.text,
        html: generateActionResponseHTML(response.text, currentService, currentStep, response.nextStep, language),
        isStructured: true,
        responseType: 'action',
        nextStep: response.nextStep
      }
    }
  }
  
  return {
    text: language === 'am' ? 'እርምጃው ተከናውኗል።' : 'Action completed.',
    html: `<div class="action-message">${language === 'am' ? 'እርምጃው ተከናውኗል።' : 'Action completed.'}</div>`,
    isStructured: false,
    responseType: 'action'
  }
}

export function extractLicenseNumber(text) {
  const licensePatterns = [
    /\b\d{2}\/\d{3,4}\/\d{3,4}\/\d{4}\b/,
    /\bBL\d{8,12}\b/i,
    /\d{8,12}\b/i,
  ]
  for (const pattern of licensePatterns) {
    const match = text.match(pattern)
    if (match) return match[0]
  }
  return null
}

export function isNationalId(text) {
  if (!text || typeof text !== 'string') return { isValid: false, type: null, number: null, fullNumber: null }
  const cleanText = text.toString().trim().toUpperCase()
  const fcnRegex = /^FCN\s*(\d{16})$/i
  const fcnMatch = cleanText.match(fcnRegex)
  if (fcnMatch) {
    return { isValid: true, type: 'fcn', number: fcnMatch[1], fullNumber: cleanText }
  }
  const rawNumberRegex = /^(\d{16})$/
  const rawMatch = cleanText.match(rawNumberRegex)
  if (rawMatch) {
    return { isValid: true, type: 'fcn_raw', number: rawMatch[1], fullNumber: cleanText }
  }
  const alternativeFormats = [
    /^FAYDA\s*(\d{16})$/i,
    /^ID\s*(\d{16})$/i,
    /^NATIONAL\s*ID\s*(\d{16})$/i
  ]
  for (const pattern of alternativeFormats) {
    const match = cleanText.match(pattern)
    if (match) {
      return { isValid: true, type: 'alternative', number: match[1], fullNumber: cleanText }
    }
  }
  return { isValid: false, type: null, number: null, fullNumber: null }
}

export function validateNationalIdDetailed(text) {
  if (!text || typeof text !== 'string') {
    return { isValid: false, errors: ['No input provided'] }
  }
  const cleanText = text.toString().trim().toUpperCase()
  const errors = []
  const numbersOnly = cleanText.replace(/\D/g, '')
  if (numbersOnly.length !== 16) {
    errors.push(`Invalid length: expected 16 digits, got ${numbersOnly.length}`)
  }
  if (!/^\d+$/.test(numbersOnly)) {
    errors.push('Contains non-digit characters')
  }
  let formatted = ''
  if (cleanText.includes('FCN') || cleanText.includes('FAYDA')) {
    const prefix = cleanText.includes('FCN') ? 'FCN' : 'FAYDA'
    formatted = `${prefix} ${numbersOnly}`
  } else {
    formatted = `FCN ${numbersOnly}`
  }
  return {
    isValid: errors.length === 0,
    errors: errors,
    rawNumber: numbersOnly,
    formattedNumber: formatted,
    details: { prefix: cleanText.includes('FCN') ? 'FCN' : (cleanText.includes('FAYDA') ? 'FAYDA' : null), number: numbersOnly, length: numbersOnly.length }
  }
}

export function extractNationalId(text) {
  if (!text || typeof text !== 'string') return null
  const patterns = [
    /FCN\s*(\d{16})/i,
    /FAYDA\s*(\d{16})/i,
    /NATIONAL\s*ID\s*(\d{16})/i,
    /\b(\d{16})\b/
  ]
  for (const pattern of patterns) {
    const match = text.match(pattern)
    if (match) {
      return { fullMatch: match[0], number: match[1], formatted: `FCN ${match[1]}` }
    }
  }
  return null
}

export function parseNationalIdDocument(text) {
  if (!text || typeof text !== 'string') return null
  const result = {
    fcnNumber: null,
    firstName: null,
    middleName: null,
    lastName: null,
    fullName: null,
    dateOfBirth: null,
    sex: null,
    countryOfCitizenship: null,
    rawText: text
  }
  const fcnMatch = extractNationalId(text)
  if (fcnMatch) result.fcnNumber = fcnMatch.formatted
  const nameMatch = text.match(/Mesfin\s+Derbew\s+Gebrehiwot/i)
  if (nameMatch) {
    result.fullName = nameMatch[0]
    const nameParts = result.fullName.split(' ')
    if (nameParts.length >= 3) {
      result.firstName = nameParts[0]
      result.middleName = nameParts[1]
      result.lastName = nameParts[2]
    }
  }
  const dobMatch = text.match(/(\d{2}\/\d{2}\/\d{4})/)
  if (dobMatch) result.dateOfBirth = dobMatch[1]
  const sexMatch = text.match(/Male|Female|ወንድ|ሴት/i)
  if (sexMatch) result.sex = sexMatch[0]
  const countryMatch = text.match(/Ethiopian|ኢትዮጵያ/i)
  if (countryMatch) result.countryOfCitizenship = 'Ethiopia'
  return result
}

export async function processMessage(message, text, isFile, isImg) {
  await initNLPProcessor()
  setupIntentPatterns()
  setupGovPatterns()
  setupStepResponses()
  
  if (isFile) {
    const rslt = await extractLicenseNumber(text)
    iSbizValid = true
    console.log(rslt, text)
  }
  if (isImg) {
    sessionStorage.setItem('isLibreV', true)
    if (text['documentType'] === 'Vehicle Registration Document') {
      isLibreValidated = true
    }
    if (text['documentType'] === 'Government Document') {
      iSbizValid = true
      console.log(text['documentType'])
    }
  }
  
  sessionStorage.setItem('otp', awaitingOTP)
  sessionStorage.setItem('licenseValidated', iSbizValid)
  sessionStorage.setItem('isLibreValidated', isLibreValidated)
  
  if (isContinuationMessage(message)) {
    console.log('🔄 CONTINUATION MESSAGE DETECTED:', message)
    const stepMatch = message.match(/step\s*(\d+)/i)
    const stepNumber = stepMatch ? parseInt(stepMatch[1]) : (parseInt(sessionStorage.getItem('currentStep')) || 1)
    currentStep = stepNumber
    sessionStorage.setItem('currentStep', stepNumber.toString())
    const currentService = sessionStorage.getItem('intnt') || 'iftms'
    const stepR = await processStepInput([currentService], currentStep, 'neutral', '', localStorage.getItem('agig-language') || 'en', false)
    return {
      text: stepR.text,
      html: generateContinuationHTML(stepR, currentStep, localStorage.getItem('agig-language') || 'en'),
      isStructured: true,
      responseType: 'continuation',
      stepData: stepR
    }
  }
  
  if (isActionButtonText(message)) {
    console.log('🔘 ACTION BUTTON DETECTED:', message)
    return handleActionButton(message)
  }
  
  if (isResumeButton(message)) {
    console.log('▶️ RESUME BUTTON DETECTED:', message)
    return {
      text: "Continuing from where we left off...",
      html: `<div class="continue-message">Continuing from where we left off...</div>`,
      isStructured: false,
      responseType: 'continue'
    }
  }
  
  const doc = nlp(message)
  const intents = extractIntents(doc)
  const entities = extractEntities(doc)
  const sentiment = analyzeSentiment(doc)
  
  const primaryIntent = Array.isArray(intents) && intents.length > 0 ? intents[0] : 'general'
  
  if (currentIntent !== primaryIntent) {
    currentIntent = primaryIntent
    sessionStorage.setItem('intnt', currentIntent)
    if (!isFile && currentIntent === 'iftms') {
      currentStep = 1
      sessionStorage.setItem('currentStep', currentStep)
      isIftmsInit = true
      awaitingOTP = false
      awaitingBusinessLicense = true
    }
  }
  
  const storedStep = sessionStorage.getItem('currentStep')
  if (storedStep) {
    currentStep = parseInt(storedStep)
  }
  
  if (currentIntent === 'iftms') {
    const licenseValidated = sessionStorage.getItem('licenseValidated') === 'true'
    const isDriverValidatd = sessionStorage.getItem('isDriverValidated') === 'true'
    const isLibreValidatd = sessionStorage.getItem('isLibreValidated') === 'true'
    
    if (!isIftmsInit) {
      isIftmsInit = true
      currentStep = 1
      sessionStorage.setItem('currentStep', currentStep)
    }
    
    if (licenseValidated && currentStep < 2) {
      currentStep = 2
      sessionStorage.setItem('currentStep', currentStep)
      awaitingBusinessLicense = false
      awaitingVehicleInfo = true
    }
    if (isLibreValidatd && !isInsValidated && currentStep < 3) {
      currentStep = 3
      isLibreValidated = true
      sessionStorage.setItem('currentStep', currentStep)
      awaitingBusinessLicense = false
      awaitingVehicleInfo = false
      awaitingDriverInfo = true
    }
    if (isDriverValidatd && !isInsValidated && currentStep < 4) {
      currentStep = 4
      isDriverValidated = true
      isLibreValidated = true
      sessionStorage.setItem('currentStep', currentStep)
      awaitingBusinessLicense = false
      awaitingVehicleInfo = false
      awaitingDriverInfo = false
    }
    
    const iftmsResponse = await getIftmsResponse(currentIntent, currentStep, sentiment, message, localStorage.getItem('agig-language') || 'en', isFile)
    return generateContextualResponse({
      currentStep: currentStep,
      intents: [currentIntent],
      sentiment: sentiment,
      processedText: message,
      awaitingInput: true,
      language: localStorage.getItem('agig-language') || 'en',
      shouldUploadFile: false,
      responseType: 'iftms',
      customResponse: iftmsResponse
    })
  } else if (currentIntent === 'generateVideo') {
    const upPhotos = sessionStorage.getItem('#photosUp')
    if (!arePhotosUp) {
      awaitingPhotoUpload = true
      currentStep = 1
      sessionStorage.setItem('currentStep', currentStep)
    }
    if (arePhotosUp && !isTitleSet && currentStep < 2) {
      currentStep = 2
      upPhotos >= numPhotos
      sessionStorage.setItem('currentStep', currentStep)
      awaitingPhotoUpload = false
    }
    if (!awaitingPhotoUpload && awaitingVideoTheme && currentStep < 3) {
      currentStep = 3
      isTitleSet = true
      awaitingVideoTheme = true
      videoTitle = sessionStorage.getItem('videoTitle')
      chosenTheme = sessionStorage.getItem('chosenTheme')
      sessionStorage.setItem('currentStep', currentStep)
    }
    if (isTitleSet && currentStep < 4) {
      currentStep = 4
      isTitleSet = true
      sessionStorage.setItem('currentStep', currentStep)
    }
    const iftmsResponse = await getIftmsResponse(currentIntent, currentStep, sentiment, message, localStorage.getItem('agig-language') || 'en', isFile)
    return generateContextualResponse({
      currentStep: currentStep,
      intents: [currentIntent],
      sentiment: sentiment,
      processedText: message,
      awaitingInput: true,
      language: localStorage.getItem('agig-language') || 'en',
      shouldUploadFile: false,
      responseType: 'iftms',
      customResponse: iftmsResponse
    })
  } else {
    const responseType = determineResponseType(intents)
    if (responseType && (intents.length === 0 || intents.includes('general'))) {
      return generateSearchBasedResponse(responseType, message, localStorage.getItem('agig-language') || 'en')
    }
    return generateContextualResponse({
      intents: Array.isArray(intents) ? intents : [intents],
      currentStep: null,
      entities: entities,
      sentiment: sentiment,
      processedText: message,
      shouldUploadFile: false,
      responseType: responseType,
      awaitingInput: false
    })
  }
}

export async function processStepInput(intents, step, sentiment, message, language = 'am', isFile = false) {
  const lan = language || localStorage.getItem('agig-language') || 'am'
  const serviceIntent = Array.isArray(intents) ? intents[0] : intents
  localStorage.setItem('intnt', serviceIntent)
  if (!stepResponses[serviceIntent]) {
    return getDefaultResponse(lan)
  }
  const stepResponse = stepResponses[serviceIntent][step]
  if (!intents || !stepResponse) {
    return getDefaultResponse(lan)
  }
  let response = {
    text: stepResponse[lan] || stepResponse.en,
    actions: stepResponse.actions || [],
    nextStep: null,
    step: step,
    service: serviceIntent
  }
  if (serviceIntent === 'generateVideo') {
    switch(step) {
      case 1: response.nextStep = 2; break
      case 2: response.nextStep = 3; break
      case 3: response.nextStep = 4; break
      case 4: response.nextStep = null; break
    }
  } else {
    switch(step) {
      case 1: response.nextStep = 2; break
      case 2: response.nextStep = 3; break
      case 3: response.nextStep = 4; break
      case 4: response.nextStep = null; break
    }
  }
  return response
}

export function generateContinuationHTML(stepR, currentStep, language) {
  return `
    <div class="chat-messages">
      <div class="message sender">
        <div class="message-content">
          <p>🔄 ${language === 'am' ? 'ከደረጃ '+currentStep+' ቀጠል እያደረግን' : 'Continuing from step'} ${currentStep}...</p>
          <p>${stepR.text}</p>
          <div class="message-actions">
            ${stepR.actions && stepR.actions.length > 0 ? stepR.actions.map(action => 
              `<button class="action-btn" data-step="${stepR.step}" data-next-step="${stepR.nextStep}">
                ${action}
              </button>`
            ).join('') : ''}
            ${stepR.nextStep ? 
              `<button class="action-btn next-btn" data-step="${stepR.step}" data-next-step="${stepR.nextStep}">
                ${language === 'am' ? 'ወደ ቀጣዩ ደረጃ' : 'Next Step'} (${stepR.nextStep})
              </button>` : ''
            }
          </div>
        </div>
        <span class="timestamp">
          ${new Date().toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}
        </span>
      </div>
    </div>
  `
}

export async function handleBusinessLicenseInput(message, sessionId) {
  const cleanMessage = message.trim()
  if (apiHandler.isValidLicenseFormat(cleanMessage)) {
    try {
      const validationResult = await apiHandler.validateBusinessLicense(cleanMessage)
      if (validationResult.isValid) {
        sessionStorage.setItem('businessLicense', cleanMessage)
        sessionStorage.setItem('businessData', JSON.stringify(validationResult.businessData))
        sessionStorage.setItem('licenseValidated', 'true')
        iSbizValid = true
        return {
          success: true,
          message: `✅ Business License **${cleanMessage}** validated successfully!`,
          businessData: validationResult.businessData,
          nextStep: 'Please upload your business license certificate document for verification.'
        }
      } else {
        return {
          success: false,
          message: `❌ Invalid business license number. Please check the number and try again.`,
          error: validationResult.error
        }
      }
    } catch (error) {
      return {
        success: false,
        message: `❌ Error validating business license: ${error.message}. Please try again.`,
        error: error.message
      }
    }
  } else {
    return {
      success: false,
      message: '❌ Invalid format. Please provide business license number in format: **14/668/5068/2004**'
    }
  }
}

const INTENT_PRIORITY = {
  PRIMARY: 1,
  SECONDARY: 2,
  TERTIARY: 3
}

const intentCategories = {
  primary: {
    iftms: ['integrated freight management service', 'የተቀናጀ የጭነት ትራንስፖርት አስተዳደር ስርዓት', 'Ministry of Transport and Logistics', 'ትራንስፖርት እና ሎጂስቲክስ', 'Integrated Freight Transport management system', 'MOTL', 'IFTMS', 'iftms', 'ministry of transport and logistics', 'freight transport registration and renewal'],
    analyzeResearch: ['Analyze a research paper', 'የጥናትና ምርምር', 'analyze a research paper', 'research document analysis', 'academic paper review', 'study paper analysis', 'scientific paper'],
    analyzeLegal: ['analyze legal document', 'review contract', 'legal agreement analysis', 'contract review', 'legal doc'],
    analyzeGovernment: ['verify government document', 'የሰነዶች ማረጋገጫ', 'government id analysis', 'business license check', 'national id verification', 'fayda id analysis', 'renew certificate'],
    analyzeFinancial: ['analyze financial document', 'invoice review', 'receipt analysis', 'bank statement check', 'financial statement'],
    classifyDocument: ['what type of document is this', 'classify this document', 'document classification', 'what kind of document'],
    renewDoc: ['renew driver license', 'update trading license', 'renew business permit', 'renew business license certificate', 'update business license renewal', 'business license cancelation', 'renew trading licence', 'business registration certificate', 'update business license'],
    generateVideo: ['create video clip', 'video ad', 'ቪዲዮ ፍጠር', 'slide show']
  },
  secondary: {
    greeting: ['hello', 'hi', 'hey', 'greetings', 'good morning', 'good afternoon', 'ሰላም', 'እንዴት ነህ', 'እንዴት ነሽ'],
    thanks: ['thank you', 'አመሰግናለሁ', 'thanks', 'appreciate it', 'gracias', 'thank', 'merci'],
    help: ['help', 'what can you do', 'capabilities', 'features', 'እርዳታ', 'ምን ማድረግ ትችላለህ']
  },
  tertiary: {
    summaryRequest: ['summarize', 'give me a summary', 'brief overview', 'main points', 'ማጠቃለያ'],
    keywordRequest: ['keywords', 'key terms', 'important words', 'main topics', 'ቁልፍ ቃላት'],
    structureRequest: ['structure', 'how is this organized', 'document layout', 'sections', 'አወቃቀር']
  }
}

export function extractIntents(doc) {
  const intents = { primary: [], secondary: [], tertiary: [], all: [] }
  const text = doc.text().toLowerCase()
  let primaryIntentFound = null
  
  for (const [intent, patterns] of Object.entries(intentCategories.primary)) {
    for (const pattern of patterns) {
      if (text.includes(pattern.toLowerCase())) {
        intents.primary.push(intent)
        intents.all.push(intent)
        primaryIntentFound = intent
        sessionStorage.setItem('intnt', intent)
        sessionStorage.setItem('currentService', intent)
        const currentStep = sessionStorage.getItem('currentStep')
        if (!currentStep || currentStep === '0' || currentStep === 'null') {
          sessionStorage.setItem('currentStep', '1')
        }
        console.log(`🎯 Primary intent detected: ${intent}`)
        break
      }
    }
    if (primaryIntentFound) break
  }
  
  if (!primaryIntentFound) {
    for (const [intent, patterns] of Object.entries(intentCategories.secondary)) {
      for (const pattern of patterns) {
        if (text.includes(pattern.toLowerCase())) {
          intents.secondary.push(intent)
          intents.all.push(intent)
          const existingIntent = sessionStorage.getItem('intnt')
          if (!existingIntent || existingIntent === 'general') {
            sessionStorage.setItem('intnt', intent)
          }
          console.log(`💬 Secondary intent detected: ${intent}`)
          break
        }
      }
    }
  }
  
  if (!primaryIntentFound && intents.secondary.length === 0) {
    for (const [intent, patterns] of Object.entries(intentCategories.tertiary)) {
      for (const pattern of patterns) {
        if (text.includes(pattern.toLowerCase())) {
          intents.tertiary.push(intent)
          intents.all.push(intent)
          console.log(`📝 Tertiary intent detected: ${intent}`)
          break
        }
      }
    }
  }
  
  if (!primaryIntentFound) {
    if (doc.has('analyze|review|check|verify|authorize|submit')) {
      if (!intents.all.length) {
        intents.all.push('analyzeDocument')
        console.log('🤖 NLP detected: analyzeDocument')
      }
    }
    if (doc.has('what #Adjective? type of document')) {
      if (!intents.all.includes('classifyDocument')) {
        intents.all.push('classifyDocument')
      }
    }
  }
  
  intents.all = [...new Set(intents.all)]
  
  const finalPrimaryIntent = intents.primary[0] || 
    (intents.secondary.length > 0 ? intents.secondary[0] : 
    (intents.tertiary.length > 0 ? intents.tertiary[0] : 
    (intents.all[0] || 'general')))
  
  const existingServiceIntent = sessionStorage.getItem('intnt')
  if (!existingServiceIntent || existingServiceIntent === 'general' || intents.primary.length > 0) {
    sessionStorage.setItem('intnt', finalPrimaryIntent)
    if (intents.primary.length > 0) {
      sessionStorage.setItem('currentService', finalPrimaryIntent)
    }
  }
  
  console.log(`📊 Final intents: primary=${intents.primary}, secondary=${intents.secondary}, tertiary=${intents.tertiary}`)
  console.log(`🏷️ Final selected intent: ${finalPrimaryIntent}`)
  
  return {
    primary: intents.primary,
    secondary: intents.secondary,
    tertiary: intents.tertiary,
    all: intents.all,
    main: finalPrimaryIntent,
    isPrimary: intents.primary.length > 0,
    isSecondary: intents.secondary.length > 0,
    isTertiary: intents.tertiary.length > 0
  }
}

export function hasIntentOfType(intents, type) {
  return intents[type] && intents[type].length > 0
}

export function getPrimaryIntent(intents) {
  return intents.primary[0] || null
}

export function getIntentsByCategory(intents, category) {
  return intents[category] || []
}

export function extractIntentsLegacy(doc) {
  const result = extractIntents(doc)
  return result.all
}

export function extractIntentxs(doc) {
  const intents = []
  const text = doc.text().toLowerCase()
  for (const [intent, patterns] of Object.entries(intentPatterns)) {
    for (const pattern of patterns) {
      if (text.includes(pattern.toLowerCase())) {
        intents.push(intent)
        sessionStorage.setItem('intnt', intent)
        sessionStorage.setItem('currentService', intent)
        break
      }
    }
  }
  if (doc.has('analyze|review|check|verify|authorize|submit')) {
    if (!intents.length) intents.push('analyzeDocument')
  }
  if (doc.has('what #Adjective? type of document')) {
    intents.push('classifyDocument')
  }
  if (doc.has('research paper|research|academic|scientific|paper study')) {
    if (!intents.includes('analyzeResearch')) intents.push('analyzeResearch')
  }
  if (doc.has('legal|contract|agreement|clause')) {
    if (!intents.includes('analyzeLegal')) intents.push('analyzeLegal')
  }
  if (doc.has('license|permit|freight|')) {
    if (!intents.includes('businessLicenseInput')) intents.push('businessLicenseInput')
  }
  if (doc.has('government|license|permit|id|verification') || doc.has('renew|renewal|permit|registration|ብቃት|ማረጋገጫ|bussiness|driving|trading|mining|building|certification|update|license|authorization')) {
    if (!intents.includes('analyzeGovernment')) intents.push('analyzeGovernment')
  }
  if (doc.has('renew|renewal|permit|registration|ብቃት|ማረጋገጫ|bussiness|driving|trading|mining|building|certification|update|license|authorization')) {
    if (!intents.includes('renewDoc')) intents.push('renewDoc')
  }
  if (doc.has('iftms|motl|freight|logistics|transport|ministry of transport')) {
    if (!intents.includes('iftms')) intents.push('iftms')
  }
  if (doc.has('financial|invoice|receipt|payment|bank')) {
    if (!intents.includes('analyzeFinancial')) intents.push('analyzeFinancial')
  }
  return [...new Set(intents)]
}

export function extractEntities(doc) {
  const entities = {
    documentTypes: extractDocumentTypes(doc),
    fileTypes: extractFileTypes(doc),
    actions: extractActions(doc),
    topics: extractTopics(doc)
  }
  return entities
}

export async function extractDocumentTypes(doc) {
  const types = []
  const text = doc.text().toLowerCase()
  const documentTypeKeywords = {
    research: ['research paper', 'academic paper', 'scientific paper', 'thesis', 'dissertation'],
    iftms: ['iftms', 'libre', 'insurance', 'gps', 'driver license', 'bolo'],
    legal: ['contract', 'agreement', 'legal document', 'nda', 'non-disclosure'],
    government: ['id card', 'license', 'permit', 'registration certificate', 'registration slip', 'passport', 'fayda'],
    financial: ['invoice', 'receipt', 'statement', 'bill', 'financial document'],
    general: ['document', 'file', 'pdf', 'paper']
  }
  for (const [type, keywords] of Object.entries(documentTypeKeywords)) {
    if (keywords.some(keyword => text.includes(keyword))) {
      types.push(type)
    }
  }
  return types
}

export function extractFileTypes(doc) {
  const fileTypes = []
  const text = doc.text().toLowerCase()
  if (text.includes('pdf') || doc.has('.pdf')) fileTypes.push('pdf')
  if (text.includes('image') || doc.has('jpg|jpeg|png|gif')) fileTypes.push('image')
  if (text.includes('word') || doc.has('doc|docx')) fileTypes.push('word')
  if (text.includes('text') || doc.has('.txt')) fileTypes.push('text')
  return fileTypes
}

export function extractActions(doc) {
  const actions = []
  if (doc.has('analyze|review|check')) actions.push('analyze')
  if (doc.has('classify|identify|what type')) actions.push('classify')
  if (doc.has('summarize|brief|overview')) actions.push('summarize')
  if (doc.has('extract|find|get')) actions.push('extract')
  if (doc.has('verify|validate|authenticate')) actions.push('verify')
  if (doc.has('renew|update|edisat|permit|certificate')) actions.push('renew')
  return actions
}

export function extractTopics(doc) {
  const nouns = doc.nouns().out('array')
  const adjectives = doc.adjectives().out('array')
  const commonWords = ['document', 'file', 'paper', 'thing', 'stuff', 'what']
  return [...nouns, ...adjectives]
    .filter(word => word.length > 3 && !commonWords.includes(word.toLowerCase()))
    .slice(0, 5)
}

export function analyzeSentiment(doc) {
  const positive = doc.match('#Positive').length
  const negative = doc.match('#Negative').length
  const neutral = doc.match('#Neutral').length
  if (positive > negative && positive > neutral) return 'positive'
  if (negative > positive && negative > neutral) return 'negative'
  return 'neutral'
}

export function shouldRequestFileUpload(intents) {
  const uploadIntents = [
    'analyzeResearch', 'analyzeLegal', 'analyzeGovernment', 'renewDoc', 'iftms',
    'analyzeFinancial', 'classifyDocument', 'analyzeDocument'
  ]
  return uploadIntents.some(intent => intents.includes(intent))
}

export function determineResponseType(intents) {
  if (intents.includes('greeting')) return 'greeting'
  if (intents.includes('help')) return 'help'
  if (intents.includes('thanks')) return 'thanks'
  if (intents.includes('generateVideo')) return 'generateVideo'
  if (intents.includes('analyzeResearch')) return 'researchAnalysis'
  if (intents.includes('analyzeLegal')) return 'legalAnalysis'
  if (intents.includes('analyzeGovernment')) return 'governmentAnalysis'
  if (intents.includes('analyzeFinancial')) return 'financialAnalysis'
  if (intents.includes('classifyDocument')) return 'classification'
  if (intents.includes('renewDoc')) return 'renewDoc'
  if (intents.includes('iftms')) return 'iftms'
  if ((intents.includes('iftms')) && (intents.includes('status'))) return 'iftmsStatus'
  if ((intents.includes('iftmsk')) && (intents.includes('businessLicenseInput'))) return 'iftmsbusinessLicenseInput'
  return 'general'
}

export async function generateContextualResponse(nlpResult, documentAnalysis = null) {
  const { intents, currentStep, sentiment, processedText, awaitingInput, entities, responseType, customResponse } = nlpResult
  if (customResponse) return customResponse
  sessionStorage.setItem('currentService', currentIntent || intents[0])
  const language = localStorage.getItem('agig-language') || 'en'
  let response = ''
  if (responseType && (intents.length === 0 || intents.includes('general'))) {
    return generateSearchBasedResponse(responseType, processedText, language)
  }
  switch (responseType) {
    case 'greeting': response = getGreetingResponse(sentiment); break
    case 'help': response = getHelpResponse(); break
    case 'thanks': response = getThanksResponse(); break
    case 'iftmsStatus': response = getStatusResponse(); break
    case 'researchAnalysis': response = "I'd be happy to analyze research papers! Please upload a PDF research document, and I'll extract key information about the methodology, findings, conclusions, and research instruments."; break
    case 'renewDoc': response = "I'd be happy to renew your document permit! Please upload your previous PDF business license, your fyda id and all other supporting documents you have."; break
    case 'iftms': const iftmsResponse = await getIftmsResponse(intents, currentStep || 1, sentiment, processedText, awaitingInput, language, false); return iftmsResponse
    case 'legalAnalysis': response = "I can analyze legal documents like contracts and agreements. Upload your legal document, and I'll identify key clauses, parties involved, obligations, and important dates."; break
    case 'governmentAnalysis': response = "I specialize in government document verification. Upload documents like IDs, licenses, or permits, and I'll help verify their structure and identify key information."; break
    case 'financialAnalysis': response = "I can analyze financial documents including invoices, receipts, and statements. Upload your financial document for amount verification, date analysis, and pattern recognition."; break
    case 'classification': response = "I can classify documents by type! Upload any document, and I'll identify whether it's a research paper, legal document, government ID, financial record, or general document."; break
    default: response = getGeneralResponse(intents, entities, documentAnalysis)
  }
  response = addSentimentTone(response, sentiment)
  return response
}

export function setupStepResponses() {
  stepResponses = {
    iftms: {
      1: {
        en: "Welcome to Integrated Freight Transport Management System! Let's start by verifying your business license. Please enter your business license number (format: 14/668/5068/2004) or upload your business license certificate.",
        am: "ወደ የተቀናጀ ጭነት የትራንስፖርት ማኔጅመንት ስርዓት እንኳን በደህና መጡ! የንግድ ፈቃድዎን በማረጋገጥ እንጀምር። እባክዎ የንግድ ፈቃድ ቁጥርዎን በምሳሌው መሰረት (ምሳሌ: 14/668/5068/2004) ያስገቡ ወይም የንግድ ፈቃድ ሰርተፊኬትዎን ይስቀሉ።",
        actions: ['Upload Business License', 'Enter License Manually']
      },
      2: {
        en: "Great! Business license verified. Now let's add your freight vehicle information. Please upload vehicle registration documents or provide vehicle details.",
        am: "ጥሩ! የንግድ ፈቃድ ተረጋግጧል። አሁን የጭነት ተሽከርካሪዎን መረጃ እንጨምር። እባክዎ የተሽከርካሪ ምዝገባ ሰነዶች ይስቀሉ ወይም የተሽከርካሪ ዝርዝሮችን ያቅርቡ።",
        actions: ['Upload Vehicle Documents', 'Add Another Vehicle']
      },
      3: {
        en: "Vehicle information recorded. Now we need driver information. Please upload driver's license and national ID.",
        am: "የተሽከርካሪ መረጃ ተመዝግቧል። አሁን የሹፌር መረጃ ያስፈልገናል። እባክዎ የሹፌር ፈቃድ እና የታደሰ መታወቂያ ሰነዶ ይስቀሉ።",
        actions: ['Upload Driver Documents', 'Complete']
      },
      4: {
        en: "All information verified! Your freight transport license has been approved for 1 year. Download your license certificate below.",
        am: "ሁሉም መረጃዎች ተረጋግጠዋል! የጭነት መጓጓዣ ፈቃድዎ ለ1 ዓመት ተሰጥቷል። የፈቃድ ሰርተፊኬትዎን ከዚህ በታች ያውርዱ።",
        actions: ['Download License', 'Start New Application']
      }
    },
    generateVideo: {
      1: {
        en: "Welcome to AGI video generator. Please upload a few photos to begin with.",
        am: "እባክዎ ወደ ቪዲዮ ስላይድ መቀየር የሚፈልጓችውን ምስሎች ይጫኑ",
        actions: ['Upload photos']
      },
      2: {
        en: "Great! Photos received. Now let's set a title for your video. Please send a video title.",
        am: "ጥሩ! ምስሎች ደርሰውኛል። አሁን የቪዲዮ ርእስ እንስጥ። እባክዎ የቪዲዮ ርዕስ ይላኩ።",
        actions: ['Choose title']
      },
      3: {
        en: "Now choose a theme for your video. Please select a theme (Modern, Classic, Corporate).",
        am: "አሁን ለቪዲዮዎ ጭብጥ ይምረጡ። እባክዎ ጭብጥ ይምረጡ።",
        actions: ['Choose theme', 'Complete']
      },
      4: {
        en: "Your video has been created! Download your video below or create a new one.",
        am: "ቪዲዮዎ ተዘጋጅቷል! ቪዲዮዎን ከዚህ በታች ያውርዱ ወይም አዲስ ይፍጠሩ።",
        actions: ['Download video', 'Create New video']
      }
    },
    renewDoc: {
      1: {
        en: "Welcome to Business License Renewal service! Let's start by verifying your existing license. Please enter your current business license number or upload your license certificate.",
        am: "ወደ የንግድ ፈቃድ እድሳት አገልግሎት እንኳን በደህና መጡ! ያለዎትን ፈቃድ በማረጋገጥ እንጀምር። እባክዎ የአሁኑ የንግድ ፈቃድ ቁጥርዎን ያስገቡ ወይም የፈቃድ ሰርተፊኬትዎን ይስቀሉ።",
        actions: ['Upload License', 'Enter License Number']
      },
      2: {
        en: "License verified. Please upload your latest tax clearance certificate and other required documents.",
        am: "ፈቃድ ተረጋግጧል። እባክዎ የቅርብ ጊዜ የታክስ ማጽዳት ሰርተፊኬትዎን እና ሌሎች የሚያስፈልጉ ሰነዶችን ይስቀሉ።",
        actions: ['Upload Tax Certificate', 'Upload Other Documents']
      },
      3: {
        en: "Documents received. Please make the payment for license renewal. Total amount: 5,000 ETB.",
        am: "ሰነዶች ተቀብለዋል። እባክዎ ለፈቃድ እድሳት ክፍያ ያድርጉ። አጠቃላይ መጠን: 5,000 ብር።",
        actions: ['Make Payment', 'Upload Payment Receipt']
      },
      4: {
        en: "Payment confirmed! Your business license has been renewed successfully. Download your new license certificate.",
        am: "ክፍያ ተረጋግጧል! የንግድ ፈቃድዎ በተሳካ ሁኔታ ዘምኗል። አዲሱን የፈቃድ ሰርተፊኬትዎን ያውርዱ።",
        actions: ['Download New License', 'Print Certificate']
      }
    }
  }
}

export function setupStepResponsesx() {
  stepResponses = {
    iftms: {
      1: {
        en: "Welcome to Integrated Freight Transport Management System! Let's start by verifying your business license.",
        am: "ወደ የተቀናጀ ጭነት የትራንስፖርት ማኔጅመንት ስርዓት እንኳን በደህና መጡ!",
        actions: ['Upload Business License', 'Enter License Manually']
      },
      2: {
        en: "Business license verified. Now add your freight vehicle information.",
        am: "የንግድ ፈቃድ ተረጋግጧል። አሁን የጭነት ተሽከርካሪዎን መረጃ ይጨምሩ።",
        actions: ['Upload Vehicle Documents', 'Add Another Vehicle']
      },
      3: {
        en: "Vehicle information recorded. Now provide driver information.",
        am: "የተሽከርካሪ መረጃ ተመዝግቧል። አሁን የሹፌር መረጃ ያስገቡ።",
        actions: ['Upload Driver Documents', 'Complete']
      },
      4: {
        en: "All information verified! License approved.",
        am: "ሁሉም መረጃዎች ተረጋግጠዋል! ፈቃድ ተሰጥቷል።",
        actions: ['Download License', 'Start New Application']
      }
    },
    generateVideo: {
      1: { en: "Upload photos to begin.", am: "ለመጀመር ፎቶዎችን ይስቀሉ።", actions: ['Upload photos'] },
      2: { en: "Photos received. Send a video title.", am: "ምስሎች ደርሰዋል። የቪዲዮ ርዕስ ይላኩ።", actions: ['Choose title'] },
      3: { en: "Choose a theme for your video.", am: "ለቪዲዮዎ ጭብጥ ይምረጡ።", actions: ['Choose theme', 'Complete'] },
      4: { en: "Video created! Download or create new.", am: "ቪዲዮ ተዘጋጅቷል!", actions: ['Download video', 'Create New video'] }
    },
    renewDoc: {
      1: { en: "Enter license number or upload certificate.", am: "የፈቃድ ቁጥር ያስገቡ ወይም ሰርተፊኬት ይስቀሉ።", actions: ['Upload License', 'Enter License Number'] },
      2: { en: "Upload tax clearance certificate.", am: "የታክስ ማጽዳት ሰርተፊኬት ይስቀሉ።", actions: ['Upload Tax Certificate', 'Upload Other Documents'] },
      3: { en: "Make payment of 5,000 ETB.", am: "ክፍያ ያድርጉ።", actions: ['Make Payment', 'Upload Payment Receipt'] },
      4: { en: "License renewed! Download new certificate.", am: "ፈቃድ ታድሷል!", actions: ['Download New License', 'Print Certificate'] }
    }
  }
}

export async function generateVideo(params) {}

export async function getIftmsResponse(intents, step, sentiment, message, language = 'en', isFile = false) {
  const stepR = await processStepInput(intents, step, sentiment, message, language, isFile)
  localStorage.setItem('spr', JSON.stringify(stepR))
  const responseHTML = `
    <div class="chat-messages">
      <div class="message sender">
        <div class="message-content">
          <p>${stepR['text']}</p>
          <div class="message-actions">
            ${stepR.actions && stepR.actions.length > 0 ? stepR.actions.map(action => 
              `<button class="action-btn" data-step="${stepR.step}" data-next-step="${stepR.nextStep}">
                ${action}
              </button>`
            ).join('') : ''}
            ${stepR.nextStep ? 
              `<button class="action-btn next-btn" data-step="${stepR.step}" data-next-step="${stepR.nextStep}">
                ${language === 'am' ? 'ወደ ቀጣዩ ደረጃ' : 'Next Step'} (${stepR.nextStep})
              </button>` : ''
            }
          </div>
        </div>
        <span class="timestamp">
          ${new Date().toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})}
        </span>
      </div>
    </div>
  `
  return responseHTML
}

function getDefaultResponse(language) {
  return {
    text: language === 'am' ? 'እባክዎ የሚፈልጉትን አገልግሎት ይፅፉ።' : 'Please specify which service you need.',
    actions: [],
    nextStep: null,
    step: 0,
    service: 'general'
  }
}

export function getGreetingResponse(sentiment) {
  const greetings = {
    positive: ["Hello! 😊 Great to see you! How can I help you today?", "Hi there! 👋 Wonderful day for government services!", "Greetings! 🌟 Excited to assist you today!"],
    neutral: ["Hello! How can I assist you?", "Hi there! What service would you like?", "Greetings! I'm here to help with public services."],
    negative: ["Hello. I'm here to help with your needs.", "Hi. Let me know how I can assist.", "Greetings. How can I help you today?"]
  }
  const options = greetings[sentiment] || greetings.neutral
  return options[Math.floor(Math.random() * options.length)]
}

export function getHelpResponse() {
  return `
    <div class="help-response">
      <h4>📚 AGIG Service Capabilities:</h4>
      <ul>
        <li>🚚 <strong>IFTMS</strong> - Freight transport license registration</li>
        <li>🔬 <strong>Research Papers</strong> - Methodology analysis, findings extraction</li>
        <li>⚖️ <strong>Legal Documents</strong> - Clause identification, party analysis</li>
        <li>🏛️ <strong>Government IDs</strong> - Verification, structure analysis</li>
        <li>💰 <strong>Financial Documents</strong> - Amount verification, pattern recognition</li>
        <li>🎬 <strong>Video Generation</strong> - Create ads from photos</li>
        <li>🔄 <strong>License Renewal</strong> - Business license renewal service</li>
      </ul>
      <p>Just ask me about any of these services or upload a document!</p>
    </div>
  `
}

export function getThanksResponse() {
  const thanks = ["You're welcome! 😊", "Glad I could assist!", "You're welcome! Feel free to ask for more help anytime."]
  return thanks[Math.floor(Math.random() * thanks.length)]
}

export function getStatusResponse(service) {
  return `Your ${service} application is being processed. Status: In Progress`
}

export function getGeneralResponse(intents, entities, documentAnalysis) {
  if (documentAnalysis) return getDocumentSpecificResponse(documentAnalysis, entities)
  if (intents.length > 0) return "I understand you're interested in document analysis! Please upload a document or tell me more specifically what you'd like me to analyze."
  return "I'm here to help you with government services! You can use IFTMS for freight licenses, document analysis, legal review, video generation, or license renewal."
}

export function getDocumentSpecificResponse(analysis, entities) {
  const { documentType, topics, confidence } = analysis
  let response = `Based on your ${documentType.toLowerCase()}, `
  if (entities.actions.includes('summarize')) response += `I can provide a detailed summary. `
  if (entities.actions.includes('extract')) response += `I can extract specific information. `
  if (topics && topics.length > 0) response += `Main topics: ${topics.slice(0, 3).join(', ')}. `
  response += `Confidence: ${Math.round(confidence * 100)}%. What would you like to explore?`
  return response
}

export function addSentimentTone(response, sentiment) {
  if (sentiment === 'positive') return response.replace(/\./g, '!').replace(/I'm/g, "I'm absolutely")
  if (sentiment === 'negative') return response.replace(/\!/g, '.').replace(/great/g, 'able to')
  return response
}

export function isBusinessLicenseNumber(text) {
  const licenseRegex = /\b\d{2}\/\d{3,4}\/\d{4}\/\d{4}\b/
  return licenseRegex.test(text)
}

export function analyzeDocumentContent(text) {
  const doc = nlp(text)
  return {
    sentences: doc.sentences().length,
    paragraphs: text.split('\n\n').length,
    wordCount: doc.terms().length,
    averageSentenceLength: doc.terms().length / doc.sentences().length,
    keyPhrases: doc.nouns().out('array').filter(phrase => phrase.split(' ').length > 1).slice(0, 10),
    people: doc.people().out('array'),
    organizations: doc.organizations().out('array'),
    places: doc.places().out('array'),
    dates: doc.dates().out('array'),
    numbers: doc.values().out('array'),
    hasHeadings: doc.has('#TitleCase').length > 5,
    hasLists: doc.has('^#Cardinal').length > 3,
    hasQuestions: doc.has('?').length > 0
  }
}

export const nlpProcessor = {
  init: initNLPProcessor,
  isActionButtonText,
  processMessage,
  validateNationalIdDetailed,
  validateVinCheckDigit,
  isVehicleChassisNumber,
  processStepInput,
  generateContinuationHTML,
  isResumeButton,
  isContinuationMessage,
  handleActionButton,
  handleBusinessLicenseInput,
  extractIntents,
  extractEntities,
  extractLicenseNumber,
  extractTextFromPDF,
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
  analyzeDocumentContent
}