# DeepGeoSense: Base Docker image for GIS/Remote Sensing/ML development
# Built on Ubuntu 22.04 with PyTorch, CUDA, and geospatial libraries

FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

LABEL maintainer="your-email@example.com"
LABEL description="Base image for geospatial deep learning with PyTorch and GDAL"
LABEL version="1.0.0"

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    python3.10-dev \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    ca-certificates \
    libgdal-dev \
    gdal-bin \
    libgeos-dev \
    libproj-dev \
    proj-bin \
    libspatialindex-dev \
    && rm -rf /var/lib/apt/lists/*

# Set up Python 3.10 as default
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 1 \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1

# Upgrade pip
RUN python3 -m pip install --upgrade pip setuptools wheel

# Install PyTorch with CUDA support (optimized for layer caching)
RUN pip3 install --no-cache-dir \
    'torch>=1.13.0' \
    'torchvision>=0.14.0'

# Install geospatial Python packages
RUN pip3 install --no-cache-dir \
    'GDAL==3.4.1' \
    'rasterio>=1.3.0' \
    'pyproj>=3.0.0' \
    'shapely>=2.0.0' \
    'fiona>=1.9.0' \
    'geopandas>=0.14.0'

# Install common ML/data science packages
RUN pip3 install --no-cache-dir \
    numpy>=1.24.0 \
    scipy>=1.10.0 \
    scikit-image>=0.20.0 \
    scikit-learn>=1.2.0 \
    opencv-python-headless>=4.7.0 \
    pillow>=9.4.0 \
    matplotlib>=3.7.0 \
    pandas>=2.0.0 \
    tqdm>=4.65.0 \
    networkx>=3.0 \
    jupyter>=1.0.0 \
    ipython>=8.12.0

# Set working directory
WORKDIR /workspace

# Configure tqdm for container environments
ENV TQDM_STDOUT=1
ENV TQDM_DISABLE=0
ENV TQDM_DYNAMIC_NCOLS=1

# Default command
CMD ["/bin/bash"]