let r=null,l=!1;async function u(){console.log("🚀 Loading Qwen...");try{const{pipeline:s,env:e}=await import("https://cdn.jsdelivr.net/npm/@huggingface/transformers@3.7.2");e.useBrowserCache=!0,r=await s("text-generation","onnx-community/Qwen2.5-0.5B-Instruct",{quantized:!0,device:"wasm"}),l=!0,console.log("✅ Qwen ready"),self.postMessage({type:"ready"})}catch(s){console.error("Load failed:",s),l=!0,self.postMessage({type:"ready"})}}function d(s,e){var n;const t=s.steps[e.currentStep];return t?(t.fields||((n=t.subprocess)==null?void 0:n.fields)||[])[e.currentFieldIndex]:null}function p(s,e,t){var c;const o=s.steps[e.currentStep],n=d(s,e),a=o.fields||((c=o.subprocess)==null?void 0:c.fields)||[];return`You are ${s.name} assistant.

Current step: ${e.currentStep}
Step type: ${o.type}
Field: ${(n==null?void 0:n.name)||"unknown"}
Question: "${(n==null?void 0:n.question)||"Enter value"}"
Field ${e.currentFieldIndex+1} of ${a.length}
Waiting for add: ${e.waitingForAdd}
Waiting for continue: ${e.waitingForContinue}
Collected: ${JSON.stringify(e.collectedData)}

User: "${t}"

Return ONLY JSON. Options:
{"action":"save","value":"the value"}
{"action":"yes"}
{"action":"no"}
{"action":"step_complete"}
{"action":"help"}
{"action":"status"}
{"action":"switch_service","service":"iftms"}

Response:`}async function f(s,e,t){if(console.log("Message:",t),!r||!l)return{action:"save",value:t};const o=p(s,e,t);try{const a=(await r(o,{max_new_tokens:80,temperature:.1,do_sample:!1,return_full_text:!1}))[0].generated_text;console.log("Qwen:",a);const i=a.match(/\{[\s\S]*?\}/);if(i)return JSON.parse(i[0])}catch(n){console.error("Error:",n)}return{action:"save",value:t}}self.addEventListener("message",async s=>{const{type:e,data:t,id:o}=s.data;if(e==="predict"){const n=await f(t.serviceConfig,t.currentState,t.userMessage);self.postMessage({type:"response",data:n,id:o})}});u();
