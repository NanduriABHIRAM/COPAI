# apps/complaints/urls.py

from django.urls import path
from .views import get_priority_station, ComplaintListCreateView, process_full_pipeline  # ✅ import

urlpatterns = [
    path('', ComplaintListCreateView.as_view(), name='complaints'),
    path('get-priority-station/', get_priority_station),
    path('process-full-pipeline/', process_full_pipeline),  # ✅ this line is missing
]

print("✅ Complaints URLs loaded")
