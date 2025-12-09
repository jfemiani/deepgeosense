# DeepGeoSense

A base Docker image for GIS, Remote Sensing, and Machine Learning development. Built on Ubuntu 22.04 with PyTorch, CUDA support, and comprehensive geospatial libraries.

## Features

- **Base**: NVIDIA CUDA 11.8.0 with cuDNN 8 on Ubuntu 22.04
- **Python**: 3.10
- **Deep Learning**: PyTorch >= 1.13.0, torchvision >= 0.14.0
- **Geospatial**: GDAL, GEOS, PROJ, rasterio, pyproj, shapely, fiona, geopandas
- **ML/Data Science**: numpy, scipy, scikit-image, scikit-learn, opencv, matplotlib, pandas, networkx
- **Development**: Jupyter, IPython, tqdm

## Quick Start

### Pull from Docker Hub

```bash
docker pull <username>/deepgeosense:latest
```

### Run Interactively

```bash
docker run -it --rm <username>/deepgeosense:latest
```

### Run with GPU

```bash
docker run -it --rm --gpus all <username>/deepgeosense:latest
```

### Use as Base Image

```dockerfile
FROM <username>/deepgeosense:latest

# Add your project code
COPY . /app
WORKDIR /app

# Install project dependencies
RUN pip install -r requirements.txt
```

## Building Locally

### Build the Image

```bash
./build.sh [image-name] [tag]
```

Default: `./build.sh deepgeosense latest`

### Test the Image

```bash
docker run -it --rm deepgeosense:latest python -c "import torch, rasterio, shapely; print('✓ All imports successful')"
```

### Verify GPU Access

```bash
docker run -it --rm --gpus all deepgeosense:latest python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
```

## Publishing to Docker Hub

### Setup

1. Set your Docker Hub username:
   ```bash
   export DOCKER_USERNAME=yourusername
   ```

2. Build the image:
   ```bash
   ./build.sh deepgeosense 1.0.0
   ```

3. Publish:
   ```bash
   ./publish.sh deepgeosense 1.0.0
   ```

This will push both `yourusername/deepgeosense:1.0.0` and `yourusername/deepgeosense:latest`.

### Using GitHub Actions (Recommended)

The repository includes a GitHub Actions workflow that automatically builds and publishes the image on push to main or on tags.

1. Add Docker Hub credentials to GitHub secrets:
   - `DOCKER_USERNAME`: Your Docker Hub username
   - `DOCKER_TOKEN`: Your Docker Hub access token

2. Push a version tag:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

The workflow will automatically build and push the image.

## Using in Downstream Projects

### Example: trace_segmentation

```dockerfile
FROM <username>/deepgeosense:latest

WORKDIR /app

# Copy only requirements first for better caching
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy source code
COPY . .

# Install the package
RUN pip install -e .

CMD ["python", "-m", "muidc.trace.segmentation.inference"]
```

This approach:
- Eliminates rebuilding PyTorch and geospatial dependencies
- Significantly speeds up builds (from ~10 minutes to ~1 minute)
- Enables better layer caching
- Separates base environment from project code

## Installed Packages

### System Libraries
- GDAL 3.4.1 with Python bindings
- GEOS (geometry engine)
- PROJ (cartographic projections)
- libspatialindex (spatial indexing)

### Python Packages
- **Deep Learning**: torch, torchvision
- **Geospatial**: GDAL, rasterio, pyproj, shapely, fiona, geopandas
- **Scientific**: numpy, scipy, scikit-image, scikit-learn, opencv
- **Utilities**: tqdm, networkx, pandas, matplotlib
- **Development**: jupyter, ipython

## Environment Variables

- `PYTHONUNBUFFERED=1`: Real-time output from Python
- `TQDM_STDOUT=1`: Direct tqdm output to stdout for container logging
- `TQDM_DISABLE=0`: Enable progress bars
- `TQDM_DYNAMIC_NCOLS=1`: Adaptive progress bar width

## Version Compatibility

- CUDA: 11.8.0
- cuDNN: 8
- Ubuntu: 22.04
- Python: 3.10
- PyTorch: >= 1.13.0
- GDAL: 3.4.1

## License

MIT License - see LICENSE file for details

## Contributing

Contributions welcome! Please open an issue or pull request.

## Maintenance

To update dependencies, modify the Dockerfile and increment the version tag. The image follows semantic versioning.
