from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from apps.fir.models import FIR
from apps.fir.serializers import FIRSerializer
from apps.complaints.services.pipeline_service import process_full_pipeline
import tempfile

@api_view(['POST'])
def auto_generate_fir(request):
    audio_file = request.FILES.get('audio')
    if not audio_file:
        return Response({'error': 'No audio file provided'}, status=status.HTTP_400_BAD_REQUEST)

    try:
        # Save uploaded audio to temp file
        with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as tmp:
            for chunk in audio_file.chunks():
                tmp.write(chunk)
            temp_audio_path = tmp.name

        # Run full pipeline (ASR → Translation → Gemini → Back Translation → TTS)
        result = process_full_pipeline(temp_audio_path)

        summary = result.get("summary", {})
        original_transcript = result.get("transcript", "")

        if not summary or not isinstance(summary, dict):
            return Response({'error': 'Missing or invalid summary'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # Save FIR object
        fir_obj = FIR.objects.create(
            name=summary.get("name", "Unknown"),
            address=summary.get("address", "Unknown"),
            contact_number=summary.get("contact_number", "Unknown"),
            incident_date=summary.get("incident_date", "Unknown"),
            incident_location=summary.get("incident_location", "Unknown"),
            crime_type=summary.get("crime_type", "Unknown"),
            incident_details=summary.get("incident_details", "Unknown"),
            original_transcript=original_transcript,
            summary=str(summary)
        )

        # Serialize and return
        serializer = FIRSerializer(fir_obj)
        return Response({
            "message": "FIR generated successfully.",
            "fir_id": fir_obj.pk,  # Use .pk instead of .id for safety
            "fir_data": serializer.data
        }, status=status.HTTP_201_CREATED)

    except Exception as e:
        return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
