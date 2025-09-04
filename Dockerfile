FROM osrm/osrm-backend:latest

WORKDIR /data

# Remove dead stretch repos (security + updates)
RUN sed -i 's/deb.debian.org/archive.debian.org/g' /etc/apt/sources.list && \
    sed -i '/security.debian.org/d' /etc/apt/sources.list && \
    sed -i '/stretch-updates/d' /etc/apt/sources.list && \
    apt-get update && apt-get install -y wget unzip curl && rm -rf /var/lib/apt/lists/*

# Download OSM extract (Geofabrik → Wales)
RUN curl -L http://download.geofabrik.de/europe/wales-latest.osm.pbf -o wales.osm.pbf && \
    osrm-extract -p /opt/car.lua wales.osm.pbf && \
    osrm-partition wales.osrm && \
    osrm-customize wales.osrm

EXPOSE 5000

CMD ["osrm-routed", "--algorithm", "mld", "/data/wales.osrm"]
