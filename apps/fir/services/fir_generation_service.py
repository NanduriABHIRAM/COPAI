# apps/fir/services/fir_generation_service.py

from apps.complaints.services.pipeline_service import process_full_pipeline
from apps.fir.models import FIR


def auto_fill_fir_from_audio(audio_path: str) -> dict:
    # Run the full Bhashini-Gemini pipeline
    result = process_full_pipeline(audio_path)

    if not result or "translated_text" not in result or "gemini_response" not in result:
        return {"error": "Pipeline failed", "raw_result": result}

    language = result.get("detected_language")
    transcript = result.get("transcript")
    translated_text = result.get("translated_text")
    fir_data = result.get("gemini_response")

    if not fir_data or not isinstance(fir_data, dict):
        return {"error": "Gemini response missing or invalid", "raw": fir_data}

    # Save FIR to database
    fir_obj = FIR.objects.create(
        name=fir_data.get("name", ""),
        address=fir_data.get("address", ""),
        contact_number=fir_data.get("contact", ""),
        incident_date=fir_data.get("datetime", ""),
        incident_location=fir_data.get("location", ""),
        crime_type=fir_data.get("crime_type", ""),
        incident_details=fir_data.get("description", ""),
        original_transcript=transcript,
        summary=translated_text
    )

    return {
        "fir_id": fir_obj.id,
        "original_language": language,
        "transcript": transcript,
        "translated_text": translated_text,
        "fir_data": fir_data
    }
