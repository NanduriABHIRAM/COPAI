from django.urls import path
from .views import auto_generate_fir

urlpatterns = [
    path('auto-generate/', auto_generate_fir, name='auto-generate-fir'),
]
