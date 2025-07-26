from django.db import models

class FIR(models.Model):
    id = models.AutoField(primary_key=True)  # <-- Add this line explicitly
    name = models.CharField(max_length=100)
    address = models.TextField()
    contact_number = models.CharField(max_length=20)
    incident_date = models.CharField(max_length=100)
    incident_location = models.TextField()
    crime_type = models.CharField(max_length=100)
    incident_details = models.TextField()
    original_transcript = models.TextField()
    summary = models.TextField()

    def __str__(self):
        return f"FIR #{self.id} - {self.name}"
