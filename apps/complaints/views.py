from django.http import JsonResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework import status
import tempfile
import base64
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .services import gps_routing as prs
from .services import pipeline_service as ps  # shortcut alias
from rest_framework.views import APIView
from .models import Complaint
from .serializers import ComplaintSerializer

@api_view(["POST"])
def process_full_pipeline(request):
    audio_file = request.FILES.get("audio")
    if not audio_file:
        return Response({"error": "No audio file provided"}, status=400)

    # Save audio to temp WAV file
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as tmp:
        tmp.write(audio_file.read())
        tmp_path = tmp.name

    # Step 1: Language Detection
    lang = ps.detect_language_from_audio(tmp_path)

    # Step 2: Transcription
    transcript, lang = ps.transcribe_and_detect_language(tmp_path, lang or "en")
    if not transcript:
        return Response({"error": "Transcription failed"}, status=500)

    # Step 3: Translate to English
    translated = ps.translate_text(transcript, lang, "en")

    # Step 4: Gemini Summary
    summary = ps.summarize_complaint(translated)
    if not summary:
        return Response({"error": "Summarization failed"}, status=500)

    # ✅ 3.a Save the summarized complaint to the database
    complaint_data = {
        "name": summary.get("name", "Unknown"),
        "address": summary.get("address", ""),
        "phone_number": "0000000000",  # default placeholder
        "description": summary.get("incident_description", "")
    }

    serializer = ComplaintSerializer(data=complaint_data)
    if serializer.is_valid():
        serializer.save()
    else:
        print("❌ Complaint serializer errors:", serializer.errors)

    # Step 5: TTS
    success = ps.text_to_speech(summary.get("incident_description", ""), lang, "output.wav")
    if not success:
        return Response({"error": "TTS generation failed"}, status=500)

    # Read audio as base64 to return to frontend
    with open("output.wav", "rb") as f:
        tts_audio_base64 = base64.b64encode(f.read()).decode("utf-8")

    # Detect missing fields
    missing_fields = [k for k, v in summary.items() if not v]

    return Response({
        "detected_language": lang,
        "transcript": transcript,
        "translated": translated,
        "summary": summary,
        "missing_fields": missing_fields,
        "tts_audio_base64": tts_audio_base64
    })
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .services.gps_routing import find_nearest_station
from django.http import JsonResponse
from rest_framework.decorators import api_view
import json
from .models import PoliceStation
from django.db.models import F, ExpressionWrapper, FloatField

@api_view(['POST'])
def get_priority_station(request):
    print("📍 get_priority_station view triggered")

    # Parse JSON safely
    try:
        if request.content_type == 'application/json':
            data = json.loads(request.body.decode('utf-8'))
        else:
            return JsonResponse({'error': 'Content-Type must be application/json'}, status=400)
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON'}, status=400)

    print("Parsed JSON:", data)

    latitude = data.get('latitude')
    longitude = data.get('longitude')
    min_priority = data.get('min_priority', 1)

    if latitude is None or longitude is None:
        return JsonResponse({'error': 'Missing required fields'}, status=400)

    try:
        latitude = float(latitude)
        longitude = float(longitude)
        min_priority = int(min_priority)
    except ValueError:
        return JsonResponse({'error': 'Invalid latitude, longitude, or priority'}, status=400)

    stations = PoliceStation.objects.annotate(
        distance=ExpressionWrapper(
            (F('latitude') - latitude) ** 2 + (F('longitude') - longitude) ** 2,
            output_field=FloatField()
        )
    ).filter(priority__gte=min_priority).order_by('distance', '-priority')

    nearest = stations.values('id', 'name', 'priority', 'distance').first()

    if nearest:
        return JsonResponse({
            'station_id': nearest['id'],
            'station_name': nearest['name'],
            'distance': nearest['distance'],
            'priority': nearest['priority']
        })
    else:
        return JsonResponse({'error': 'No suitable police station found'}, status=404)
    

class ComplaintListCreateView(APIView):
    def post(self, request):
        serializer = ComplaintSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def get(self, request):
        complaints = Complaint.objects.all().order_by('-date_submitted')
        serializer = ComplaintSerializer(complaints, many=True)
        return Response(serializer.data)
