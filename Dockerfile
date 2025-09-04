# Use Ubuntu-based image instead of old Stretch
FROM osrm/osrm-backend:latest

WORKDIR /data

# Replace Stretch repos with Debian archive
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list && \
    apt-get update && apt-get install -y wget unzip && rm -rf /var/lib/apt/lists/*

# Download OSM extract (Geofabrik → Wales)
RUN wget http://download.geofabrik.de/europe/wales-latest.osm.pbf -O wales.osm.pbf

# Run preprocessing inside Docker
RUN osrm-extract -p /opt/car.lua wales.osm.pbf && \
    osrm-partition wales.osrm && \
    osrm-customize wales.osrm

# Expose port
EXPOSE 5000

# Start OSRM routing server
CMD ["osrm-routed", "--algorithm", "mld", "/data/wales.osrm"]
