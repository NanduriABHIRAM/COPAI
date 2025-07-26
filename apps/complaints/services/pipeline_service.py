import requests
import base64
import json
import os
import re
import sounddevice as sd
from scipy.io.wavfile import write

# ---------------- CONFIGURATION ----------------
BHASHINI_USER_ID = "b28c019adee44a078b47dd0ac16f14c5"
BHASHINI_ULB_KEY = "13c741914c-15ab-401b-8a06-d87b0c96f135"
BHASHINI_AUTH_TOKEN = "EQEJ3qIDET4FJWKY49d5jfyVXrKDoLV2B4_Xgo_DCBffwEbLW3WLOtenvl1SKm0r"

BHASHINI_PIPELINE_INFERENCE_API_ENDPOINT = "https://dhruva-api.bhashini.gov.in/services/inference/pipeline"
BHASHINI_ASR_MODEL_ID = "ai4bharat/conformer-hi-gpu--t4"
BHASHINI_NMT_MODEL_ID = "ai4bharat/indictrans-v2-all-gpu--t4"
BHASHINI_TTS_MODEL_ID = "Bhashini/IITM/TTS"

GEMINI_API_KEY = "AIzaSyAsJO83xKqHVCI27SrKKcOk_0Nncfqsncs"
GEMINI_API_URL = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={GEMINI_API_KEY}"

# ---------------- MIC RECORDING ----------------
def record_audio(output_path='input.wav', duration=6, fs=16000):
    print(f"🎙 Recording for {duration} seconds...")
    try:
        recording = sd.rec(int(duration * fs), samplerate=fs, channels=1, dtype='int16')
        sd.wait()
        write(output_path, fs, recording)
        print(f"Audio recorded and saved as {output_path}")
        return output_path
    except Exception as e:
        print(f"Mic recording failed: {e}")
        return None

# ---------------- HELPERS ----------------
def get_bhashini_headers():
    return {
        "userID": BHASHINI_USER_ID,
        "ulbKey": BHASHINI_ULB_KEY,
        "authorization": BHASHINI_AUTH_TOKEN,
        "Content-Type": "application/json"
    }

def get_audio_base64(audio_file_path):
    try:
        with open(audio_file_path, "rb") as audio_file:
            return base64.b64encode(audio_file.read()).decode("utf-8")
    except Exception as e:
        print(f"Error reading audio file: {e}")
        return None

def bhashini_pipeline_inference(payload):
    headers = get_bhashini_headers()
    try:
        response = requests.post(BHASHINI_PIPELINE_INFERENCE_API_ENDPOINT, headers=headers, json=payload)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Bhashini API error: {e}")
        if e.response is not None:
            print(" Response content:", e.response.text)
        return None

# ---------------- BHASHINI PIPELINE ----------------
def detect_language_from_audio(audio_file_path):
    print("🔍 Detecting language from audio...")
    audio_base64 = get_audio_base64(audio_file_path)
    if not audio_base64:
        return None

    payload = {
        "pipelineTasks": [
            {
                "taskType": "audio-lang-detection",
                "config": {
                    "serviceId": "bhashini/iitmandi/audio-lang-detection/gpu"
                }
            }
        ],
        "inputData": {
            "audio": [{"audioContent": audio_base64}]
        }
    }

    response = bhashini_pipeline_inference(payload)
    if response and response.get("pipelineResponse"):
        return response["pipelineResponse"][0].get("output", [{}])[0].get("langPrediction", [])[0].get("langCode", '')
    return None

def transcribe_and_detect_language(audio_file_path, assumed_language):
    print(" Transcribing with assumed language:", assumed_language)
    audio_base64 = get_audio_base64(audio_file_path)
    if not audio_base64:
        return None, None

    payload = {
        "pipelineTasks": [
            {
                "taskType": "asr",
                "config": {
                    "language": {"sourceLanguage": assumed_language},
                    "serviceId": BHASHINI_ASR_MODEL_ID,
                    "audioFormat": "wav",
                    "samplingRate": 16000,
                    "domain": "general"
                }
            }
        ],
        "inputData": {"audio": [{"audioContent": audio_base64}]}
    }

    response = bhashini_pipeline_inference(payload)
    if response and response.get("pipelineResponse"):
        output = response["pipelineResponse"][0].get("output", [{}])[0]
        transcript = output.get("source")
        detected_lang = output.get("config", {}).get("language", {}).get("sourceLanguage", assumed_language)
        return transcript, detected_lang
    return None, None

def translate_text(text, source_language, target_language):
    if not source_language:
        print("Source language is None! Using 'en' as fallback.")
        source_language = "en"

    print(f" Translating from {source_language} → {target_language}")
    payload = {
        "pipelineTasks": [
            {
                "taskType": "translation",
                "config": {
                    "language": {
                        "sourceLanguage": source_language,
                        "targetLanguage": target_language
                    },
                    "serviceId": BHASHINI_NMT_MODEL_ID,
                    "domain": "general"
                }
            }
        ],
        "inputData": {"input": [{"source": text}]}
    }

    response = bhashini_pipeline_inference(payload)
    if response and response.get("pipelineResponse"):
        return response["pipelineResponse"][0]["output"][0].get("target")
    return None

def generate_llm_response(prompt_text):
    print(" Generating response using Gemini...")
    payload = {
        "contents": [
            {
                "role": "user",
                "parts": [{"text": prompt_text}]
            }
        ]
    }

    try:
        response = requests.post(
            GEMINI_API_URL,
            headers={'Content-Type': 'application/json'},
            json=payload
        )
        response.raise_for_status()
        result = response.json()
        return result["candidates"][0]["content"]["parts"][0].get("text", "").strip()
    except Exception as e:
        print(f" Gemini error: {e}")
        return None

def summarize_complaint(translated_text):
    print(" Summarizing complaint using Gemini...")
    prompt = (
        "You are an assistant trained to extract key details from police complaints.\n"
        "Read the following statement and extract the following fields in JSON format:\n\n"
        "{\n"
        "  \"name\": \"\",\n"
        "  \"address\": \"\",\n"
        "  \"date_time\": \"\",\n"
        "  \"location\": \"\",\n"
        "  \"incident_description\": \"\"\n"
        "}\n\n"
        "If any field is missing, leave it as an empty string.\n\n"
        f"Complaint: {translated_text}"
    )

    raw_response = generate_llm_response(prompt)
    print("🔍 Gemini raw output:", raw_response)

    try:
        if raw_response is not None:
            match = re.search(r'\{[\s\S]*?\}', raw_response)
            if match:
                json_str = match.group()
                return json.loads(json_str)
            else:
                print(" No JSON object found in Gemini output.")
                return None
        else:
            print(" Gemini output is None.")
            return None
    except Exception as e:
        print(f" Failed to parse summary: {e}")
        return None

def text_to_speech(text, language, output_file_path):
    print(f"🗣 Converting text to speech in {language}...")
    clean_text = re.sub(r'[*_`]', '', text)
    payload = {
        "pipelineTasks": [
            {
                "taskType": "tts",
                "config": {
                    "language": {"sourceLanguage": language},
                    "serviceId": BHASHINI_TTS_MODEL_ID,
                    "gender": "male",
                    "audioFormat": "wav",
                    "domain": "general"
                }
            }
        ],
        "inputData": {"input": [{"source": clean_text}]}
    }

    response = bhashini_pipeline_inference(payload)
    try:
        if response is not None:
            audio_b64 = response.get("pipelineResponse", [{}])[0].get("audio", [{}])[0].get("audioContent")
            if audio_b64:
                with open(output_file_path, "wb") as f:
                    f.write(base64.b64decode(audio_b64))
                print(f" TTS output saved to: {output_file_path}")
                return True
            print(" TTS failed: No audioContent.")
            return False
        else:
            print(" TTS failed: No response from API.")
            return False
    except Exception as e:
        print(f"Error saving TTS audio: {e}")
        return False


def process_full_pipeline(audio_path: str) -> dict | None:
    """
    Complete pipeline from audio → transcription → translation → complaint summary.
    Returns FIR data dict or None if failed.
    """
    lang = detect_language_from_audio(audio_path)
    print(" Detected Language:", lang)

    transcript, lang = transcribe_and_detect_language(audio_path, lang or "en")
    print(" Transcript:", transcript)

    if not transcript:
        return None

    translated = translate_text(transcript, lang, "en")
    print(" Translated:", translated)

    summary = summarize_complaint(translated)
    print(" Summary:", summary)

    return summary  # Dictionary with keys like name, address, etc.
