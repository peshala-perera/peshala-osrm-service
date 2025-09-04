# Use official OSRM backend image
FROM osrm/osrm-backend:latest

WORKDIR /data

# Install wget/unzip
RUN apt-get update && apt-get install -y wget unzip && rm -rf /var/lib/apt/lists/*

# Download OSM extract (Geofabrik → Wales)
RUN wget http://download.geofabrik.de/europe/wales-latest.osm.pbf -O wales.osm.pbf

# Run preprocessing inside Docker
RUN osrm-extract -p /opt/car.lua wales.osm.pbf && \
    osrm-partition wales.osrm && \
    osrm-customize wales.osrm

# Expose OSRM default port
EXPOSE 5000

# Start routing server
CMD ["osrm-routed", "--algorithm", "mld", "/data/wales.osrm"]
