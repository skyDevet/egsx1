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
          { name: 'businessLicenseNumber', question: { en: 'Business License Number? (Example: 12345678)', am: 'የንግድ ፈቃድ ቁጥር? (ምሳሌ: 12345678)' }, validation: 'license', regex: '^[0-9]{6,10}$', example: { en: '12345678', am: '12345678' }, error: { en: 'Invalid. Use 6-10 digits.', am: 'ልክ ያልሆነ። 6-10 አሃዞችን ይጠቀሙ።' } },
          { name: 'operatorName', question: { en: 'Operator Name? (Example: Ethio Transport)', am: 'የኦፕሬተር ስም? (ምሳሌ: ኢትዮ ትራንስፖርት)' }, validation: 'text', regex: '^.+$', example: { en: 'Ethio Transport', am: 'ኢትዮ ትራንስፖርት' }, error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' } },
          { name: 'phoneNumber', question: { en: 'Phone Number? (Example: 0912345678 or +251912345678)', am: 'ስልክ ቁጥር? (ምሳሌ: 0912345678 ወይም +251912345678)' }, validation: 'phone', regex: '^(0?[79][0-9]{8}|\\+251[79][0-9]{8})$', example: { en: '0912345678', am: '0912345678' }, error: { en: 'Invalid phone number.', am: 'ልክ ያልሆነ ስልክ ቁጥር።' } },
          { name: 'password', question: { en: 'IFMTS Password?', am: 'IFMTS ይለፍ ቃል?' }, validation: 'text', example: { en: 'your_password', am: 'ይለፍ_ቃልዎ' }, error: { en: 'Password is required.', am: 'ይለፍ ቃል ያስፈልጋል።' } }
        ],
        apiActions: [
          {
            id: 'register_operator',
            endpoint: 'https://iftms.motl.gov.et/api/operator/register',
            method: 'POST',
            data: { licenseNumber: '{{businessLicenseNumber}}', name: '{{operatorName}}', phone: '{{phoneNumber}}', password: '{{password}}' },
            onSuccess: { nextStep: 2, message: { en: '✅ Operator registered! Proceeding to vehicle management.', am: '✅ ኦፕሬተር ተመዝግቧል! ወደ ተሽከርካሪ አስተዳደር በመቀጠል ላይ።' } },
            onFailure: { message: { en: '❌ Operator registration failed.', am: '❌ የኦፕሬተር ምዝገባ አልተሳካም።' } }
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
            { name: 'plateNumber', question: { en: 'Plate Number? (Example: AA-1234)', am: 'የሰሌዳ ቁጥር? (ምሳሌ: AA-1234)' }, validation: 'plate', regex: '^[A-Z]{2,3}-?[0-9]{3,4}$', example: { en: 'AA-1234', am: 'AA-1234' }, error: { en: 'Invalid plate format.', am: 'ልክ ያልሆነ የሰሌዳ ቅርጸት።' } },
            { name: 'plateCode', question: { en: 'Plate Code? (Example: AA)', am: 'የሰሌዳ ኮድ? (ምሳሌ: AA)' }, validation: 'text', example: { en: 'AA', am: 'ኤኤ' }, error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' } },
            { name: 'motorNumber', question: { en: 'Motor Number?', am: 'የሞተር ቁጥር?' }, validation: 'text', example: { en: '1SG4001234567', am: '1SG4001234567' }, error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' } },
            { name: 'vinNumber', question: { en: 'VIN or Chassis Number? (Example: LVBS6PE123456789)', am: 'VIN ወይም የቻሲስ ቁጥር? (ምሳሌ: LVBS6PE123456789)' }, validation: 'vin', regex: '^[A-HJ-NPR-Z0-9]{10,18}$', example: { en: 'LVBS6PE123456789', am: 'LVBS6PE123456789' }, error: { en: 'Invalid VIN/Chassis (10-17 characters).', am: 'ልክ ያልሆነ VIN/ቻሲስ (10-17 ቁምፊዎች)።' } },
            { name: 'chassisNumber', question: { en: 'Chassis Number?', am: 'የቻሲስ ቁጥር?' }, validation: 'text', example: { en: 'LVBS6PE123456789', am: 'LVBS6PE123456789' }, error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' }, autoFill: true },
            { name: 'manufacturer', question: { en: 'Manufacturer?', am: 'አምራች?' }, validation: 'text', example: { en: 'Toyota', am: 'ቶዮታ' }, error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' }, autoFill: true },
            { name: 'vehicleModel', question: { en: 'Vehicle Model?', am: 'የተሽከርካሪ ሞዴል?' }, validation: 'text', example: { en: 'Toyota Hilux', am: 'ቶዮታ ሃይሉክስ' }, error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' }, autoFill: true },
            { name: 'manufactureYear', question: { en: 'Year of Manufacture?', am: 'የምርት ዓመት?' }, validation: 'year', regex: '^(19|20)[0-9]{2}$', example: { en: '2020', am: '2020' }, error: { en: 'Invalid year (e.g., 2020).', am: 'ልክ ያልሆነ ዓመት (ለምሳሌ: 2020)።' }, autoFill: true },
            { name: 'vehicleType', question: { en: 'Vehicle Type?', am: 'የተሽከርካሪ አይነት?' }, validation: 'text', example: { en: 'Truck', am: 'ጭነት መኪና' }, error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' }, autoFill: true },
            { name: 'bodyPartType', question: { en: 'Body Part Type?', am: 'የሰውነት ክፍል አይነት?' }, validation: 'text', example: { en: 'Crew Cab Truck', am: 'ክሩ ካብ መኪና' }, error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' }, autoFill: true },
            { name: 'engineInfo', question: { en: 'Engine Information?', am: 'የሞተር መረጃ?' }, validation: 'text', example: { en: '2.8L Diesel Turbo', am: '2.8L ናፍጣ ቱርቦ' }, error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' }, autoFill: true },
            { name: 'engineCapacity', question: { en: 'Engine Capacity (cc)?', am: 'የሞተር አቅም (ሲሲ)?' }, validation: 'number', regex: '^\\d+$', example: { en: '2800', am: '2800' }, error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' }, autoFill: true },
            { name: 'cylinderCount', question: { en: 'Number of Cylinders?', am: 'የሲሊንደሮች ብዛት?' }, validation: 'number', regex: '^\\d+$', example: { en: '4', am: '4' }, error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' }, autoFill: true },
            { name: 'fuelType', question: { en: 'Fuel Type?', am: 'የነዳጅ አይነት?' }, validation: 'choice', options: { en: ['Diesel', 'Petrol', 'Electric', 'Hybrid', 'LPG', 'CNG'], am: ['ናፍጣ', 'ቤንዚን', 'ኤሌክትሪክ', 'ሃይብሪድ', 'ኤልፒጂ', 'ሲኤንጂ'] }, example: { en: 'Diesel', am: 'ናፍጣ' }, error: { en: 'Please select a fuel type.', am: 'እባክዎ የነዳጅ አይነት ይምረጡ።' }, autoFill: true },
            { name: 'serviceType', question: { en: 'Service Type?', am: 'የአገልግሎት አይነት?' }, validation: 'choice', options: { en: ['Freight Transport', 'Passenger Transport', 'General Transport', 'Delivery Transport', 'Construction Transport', 'Liquid Transport', 'Cold Chain Transport'], am: ['የጭነት ትራንስፖርት', 'የተሳፋሪ ትራንስፖርት', 'አጠቃላይ ትራንስፖርት', 'የመላኪያ ትራንስፖርት', 'የግንባታ ትራንስፖርት', 'የፈሳሽ ትራንስፖርት', 'የቀዝቃዛ ሰንሰለት ትራንስፖርት'] }, example: { en: 'Freight Transport', am: 'የጭነት ትራንስፖርት' }, error: { en: 'Please select a service type.', am: 'እባክዎ የአገልግሎት አይነት ይምረጡ።' }, autoFill: true },
            { name: 'totalWeight', question: { en: 'Total Weight (kg)?', am: 'ጠቅላላ ክብደት (ኪግ)?' }, validation: 'number', regex: '^\\d+$', example: { en: '3500', am: '3500' }, error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' }, autoFill: true },
            { name: 'unladenWeight', question: { en: 'Unladen Weight (kg)?', am: 'ባዶ ክብደት (ኪግ)?' }, validation: 'number', regex: '^\\d+$', example: { en: '2500', am: '2500' }, error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' }, autoFill: true },
            { name: 'loadCapacity', question: { en: 'Load Capacity (kg)?', am: 'የጭነት አቅም (ኪግ)?' }, validation: 'number', regex: '^\\d+$', example: { en: '1000', am: '1000' }, error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' }, autoFill: true },
            { name: 'cargoVolume', question: { en: 'Cargo Volume (kg)?', am: 'የጭነት መጠን (ኪግ)?' }, validation: 'number', regex: '^\\d+$', example: { en: '5000', am: '5000' }, error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' }, autoFill: true },
            { name: 'tonnage', question: { en: 'Tonnage (T)?', am: 'ቶንነጅ (ቲ)?' }, validation: 'number', regex: '^\\d+\\.?\\d*$', example: { en: '3.5', am: '3.5' }, error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' }, autoFill: true },
            { name: 'gvw', question: { en: 'Gross Vehicle Weight (kg)?', am: 'ጠቅላላ የተሽከርካሪ ክብደት (ኪግ)?' }, validation: 'number', regex: '^\\d+$', example: { en: '3500', am: '3500' }, error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' }, autoFill: true },
            { name: 'payload', question: { en: 'Payload (kg)?', am: 'ጭነት (ኪግ)?' }, validation: 'number', regex: '^\\d+$', example: { en: '1000', am: '1000' }, error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' }, autoFill: true },
            { name: 'seatingCapacity', question: { en: 'Seating Capacity?', am: 'የመቀመጫ አቅም?' }, validation: 'number', regex: '^\\d+$', example: { en: '5', am: '5' }, error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' }, autoFill: true },
            { name: 'wheelbase', question: { en: 'Wheelbase (mm)?', am: 'የዊልቤዝ (ሚሜ)?' }, validation: 'number', regex: '^\\d+$', example: { en: '3000', am: '3000' }, error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' }, autoFill: true },
            { name: 'axelCount', question: { en: 'Axel Count?', am: 'የአክሰል ብዛት?' }, validation: 'number', regex: '^\\d+$', example: { en: '2', am: '2' }, error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' }, autoFill: true },
            { name: 'color', question: { en: 'Vehicle Color?', am: 'የተሽከርካሪ ቀለም?' }, validation: 'text', example: { en: 'White', am: 'ነጭ' }, error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' }, autoFill: true },
            { name: 'bodyColor', question: { en: 'Body Color?', am: 'የሰውነት ቀለም?' }, validation: 'text', example: { en: 'White', am: 'ነጭ' }, error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' }, autoFill: true },
            { name: 'interiorColor', question: { en: 'Interior Color?', am: 'የውስጥ ቀለም?' }, validation: 'text', example: { en: 'Black', am: 'ጥቁር' }, error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' }, autoFill: true },
            { name: 'assemblyPlant', question: { en: 'Assembly Plant?', am: 'የመሰብሰቢያ ፋብሪካ?' }, validation: 'text', example: { en: 'China - Beijing', am: 'ቻይና - ቤዪጂንግ' }, error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' }, autoFill: true },
            { name: 'gpsInfo', question: { en: 'GPS Info (lat, lon)?', am: 'GPS መረጃ (ላቲቱድ፣ ሎንጂቱድ)?' }, validation: 'text', example: { en: '39.9042, 116.4074', am: '39.9042, 116.4074' }, error: { en: 'Invalid GPS format.', am: 'ልክ ያልሆነ የጂፒኤስ ቅርጸት።' }, autoFill: true }
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
            { name: 'driverName', question: { en: 'Driver Name? (Example: Abebe Kebede)', am: 'የአሽከርካሪ ስም? (ምሳሌ: አበበ ከበደ)' }, validation: 'text', example: { en: 'Abebe Kebede', am: 'አበበ ከበደ' }, error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' } },
            { name: 'driverLicense', question: { en: 'Driver License Number? (Example: DL123456)', am: 'የመንጃ ፈቃድ ቁጥር? (ምሳሌ: DL123456)' }, validation: 'text', example: { en: 'DL123456', am: 'DL123456' }, error: { en: 'Cannot be empty.', am: 'ባዶ መሆን አይችልም።' } }
          ],
          onValid: { nextStep: 4, collectionKey: 'drivers' }
        }
      },
      4: {
        type: 'summary',
        title: { en: 'Registration Complete', am: 'ምዝገባ ተጠናቀቀ' },
        isFinal: true,
        actions: { en: ['Download Certificate', 'Print Summary', 'Start New Registration'], am: ['የምስክር ወረቀት አውርድ', 'ማጠቃለያ አትም', 'አዲስ ምዝገባ ጀምር'] },
        apiActions: [
          { id: 'sync_to_ifmts', endpoint: 'https://iftms.motl.gov.et/api/sync', method: 'POST',
            data: { operator: '{{operator}}', vehicles: '{{vehicles}}', drivers: '{{drivers}}' },
            onSuccess: { message: { en: '✅ All data synced to IFMTS!', am: '✅ ሁሉም መረጃ ወደ IFMTS ተመሳስሏል!' } },
            onFailure: { message: { en: '❌ Sync failed.', am: '❌ ማመሳሰል አልተሳካም።' } } }
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
      1: { type: 'file_upload', title: { en: 'Upload Document', am: 'ሰነድ ስቀል' }, prompt: { en: '📄 Please upload the document you want me to analyze:', am: '📄 እባክዎ መተንተን የሚፈልጉትን ሰነድ ያስገቡ:' }, onValid: { nextStep: 2 } },
      2: {
        type: 'form',
        title: { en: 'Analysis Type', am: 'የትንተና አይነት' },
        fields: [
          { name: 'analysisType', question: { en: 'What type of analysis do you want? (Example: Summarize)', am: 'ምን አይነት ትንተና ይፈልጋሉ? (ምሳሌ: ማጠቃለል)' }, validation: 'choice', options: { en: ['Summarize', 'Extract Key Points', 'Find Keywords', 'Analyze Sentiment'], am: ['ማጠቃለል', 'ቁልፍ ነጥቦችን ማውጣት', 'ቁልፍ ቃላትን መፈለግ', 'ስሜትን መተንተን'] }, example: { en: 'Summarize', am: 'ማጠቃለል' }, error: { en: 'Please select an option.', am: 'እባክዎ አማራጭ ይምረጡ።' } }
        ],
        onValid: { nextStep: 3 }
      },
      3: { type: 'result', title: { en: 'Analysis Result', am: 'የትንተና ውጤት' }, prompt: { en: '✅ Analysis complete!', am: '✅ ትንተና ተጠናቀቀ!' }, isFinal: true, actions: { en: ['New Analysis', 'Export Results', 'Start Over'], am: ['አዲስ ትንተና', 'ውጤቶችን ወደ ውጭ ላክ', 'እንደገና ጀምር'] } }
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
          { name: 'videoType', question: { en: 'What type of video? (Example: Slideshow)', am: 'ምን አይነት ቪዲዮ? (ምሳሌ: ስላይድሾው)' }, validation: 'choice', options: { en: ['Slideshow', 'Video Clip', 'Advertisement'], am: ['ስላይድሾው', 'ቪዲዮ ክሊፕ', 'ማስታወቂያ'] }, example: { en: 'Slideshow', am: 'ስላይድሾው' }, error: { en: 'Please select a video type.', am: 'እባክዎ የቪዲዮ አይነት ይምረጡ።' } },
          { name: 'duration', question: { en: 'Duration (seconds)? (Example: 30)', am: 'ቆይታ (ሰከንዶች)? (ምሳሌ: 30)' }, validation: 'number', regex: '^\\d+$', example: { en: '30', am: '30' }, error: { en: 'Please enter a number.', am: 'እባክዎ ቁጥር ያስገቡ።' } }
        ],
        onValid: { nextStep: 2 }
      },
      2: { type: 'file_upload', title: { en: 'Upload Media', am: 'ሚዲያ ስቀል' }, prompt: { en: '📷 Upload images or provide a script:', am: '📷 ምስሎችን ያስገቡ ወይም ስክሪፕት ያቅርቡ:' }, onValid: { nextStep: 3 } },
      3: { type: 'summary', title: { en: 'Video Generation Complete', am: 'ቪዲዮ ማምረት ተጠናቀቀ' }, prompt: { en: '✅ Your video is ready to generate!', am: '✅ ቪዲዮዎ ለማምረት ዝግጁ ነው!' }, isFinal: true, actions: { en: ['Generate Video', 'Edit Script', 'Start Over'], am: ['ቪዲዮ አምርት', 'ስክሪፕት አርትዕ', 'እንደገና ጀምር'] } }
    }
  }
};

export { DEFAULT_SERVICES };
export default DEFAULT_SERVICES;
