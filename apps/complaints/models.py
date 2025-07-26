# apps/complaints/models.py

from django.db import models

class Complaint(models.Model):
    name = models.CharField(max_length=100)
    address = models.TextField()
    phone_number = models.CharField(max_length=15)
    description = models.TextField()
    date_submitted = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} - {self.description[:30]}"
from django.db import models

class PoliceStation(models.Model):
    name = models.CharField(max_length=100)
    latitude = models.FloatField()
    longitude = models.FloatField()
    address = models.TextField()
    priority = models.IntegerField(default=1)  

    def __str__(self):
        return self.name
