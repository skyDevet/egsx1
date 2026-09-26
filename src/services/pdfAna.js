// src/services/pdfAna.js
// PDF → text (via pdfjs-dist) → handed to pdfClassifyExtractor.js
// which classifies, extracts, and POSTs to the backend.

import * as pdfjsLib from 'pdfjs-dist/build/pdf';
import pdfjsWorker from 'pdfjs-dist/build/pdf.worker?url';

pdfjsLib.GlobalWorkerOptions.workerSrc = pdfjsWorker;

const TAG = '[pdfAna]';
const log   = (...a) => console.log(TAG, ...a);
const error = (...a) => console.error(TAG, ...a);

// ------------------------------------------------------------
// Extract text from a PDF file
// ------------------------------------------------------------
export async function extractTextFromPDF(file) {
  return new Promise((resolve, reject) => {
    const fileReader = new FileReader();

    fileReader.onload = async function () {
      try {
        const typedArray = new Uint8Array(this.result);
        const pdf = await pdfjsLib.getDocument(typedArray).promise;
        let fullText = '';

        for (let i = 1; i <= pdf.numPages; i++) {
          const page = await pdf.getPage(i);
          const textContent = await page.getTextContent();
          const pageText = textContent.items.map(item => item.str).join(' ');
          fullText += pageText + '\n';
        }

        log(`✅ PDF text extracted: pages=${pdf.numPages} chars=${fullText.length}`);
        resolve(fullText);
      } catch (err) {
        error('PDF text extraction failed:', err.message);
        reject(err);
      }
    };

    fileReader.onerror = reject;
    fileReader.readAsArrayBuffer(file);
  });
}

// ------------------------------------------------------------
// Main entry — extract text, hand off to classifier/extractor
// ------------------------------------------------------------
export async function analyzePDF(file) {
  log('▶ analyzePDF:', file?.name, file?.size, 'bytes');
  const text = await extractTextFromPDF(file);

  const { classifyAndExtract } = await import('./pdfClassifyExtractor.js');
  const result = await classifyAndExtract(text, {
    fileName: file.name,
    fileSize: file.size,
    source: 'pdf',
  });

  return { text, response: result?.nlpResponse || null, result };
}