import math
from apps.complaints.models import PoliceStation

def haversine(lat1, lon1, lat2, lon2):
    R = 6371  # Earth radius in KM
    d_lat = math.radians(lat2 - lat1)
    d_lon = math.radians(lon2 - lon1)
    a = math.sin(d_lat/2)**2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(d_lon/2)**2
    return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

def find_nearest_station(latitude, longitude, min_priority):
    latitude = float(latitude)
    longitude = float(longitude)

    stations = PoliceStation.objects.filter(priority__gte=min_priority)
    nearest = None
    min_dist = float('inf')

    for station in stations:
        dist = haversine(latitude, longitude, station.latitude, station.longitude)
        if dist < min_dist:
            min_dist = dist
            nearest = station

    if nearest:
        return {
            "nearest_station": {
                "name": nearest.name,
                "latitude": nearest.latitude,
                "longitude": nearest.longitude,
                "priority": nearest.priority,
                "distance_km": round(min_dist, 2)
            }
        }
    else:
        return {"error": "No stations found for the given priority"}
