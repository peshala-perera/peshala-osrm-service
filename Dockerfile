# Use official OSRM backend
FROM osrm/osrm-backend:latest

WORKDIR /data

# Install curl/unzip
RUN apt-get update && apt-get install -y curl unzip && rm -rf /var/lib/apt/lists/*

# Environment variable for PBF file URL
ENV OSM_PBF_URL="https://example.com/wales-latest.osm.pbf"

# Download pre-validated OSM PBF file
RUN curl -fSL $OSM_PBF_URL -o wales.osm.pbf

# Preprocess OSRM data
RUN osrm-extract -p /opt/car.lua wales.osm.pbf && \
    osrm-partition wales.osrm && \
    osrm-customize wales.osrm

# Expose OSRM routing port
EXPOSE 5000

# Start the OSRM server
CMD ["osrm-routed", "--algorithm", "mld", "/data/wales.osrm"]
