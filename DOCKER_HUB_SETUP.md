# Docker Hub Setup for deepgeosense

Follow these steps to set up automated builds from GitHub to Docker Hub.

## Step 1: Create Docker Hub Repository

1. Go to: https://hub.docker.com/repositories
2. Click **"Create Repository"** button (top right)
3. Fill in:
   - **Name**: `deepgeosense`
   - **Description**: `Base Docker image for geospatial deep learning with PyTorch, CUDA, and GDAL`
   - **Visibility**: **Public**
4. Click **"Create"**

## Step 2: Set Up GitHub Actions (Recommended)

### 2.1 Generate Docker Hub Access Token

1. Go to: https://hub.docker.com/settings/security
2. Click **"New Access Token"**
3. Fill in:
   - **Access Token Description**: `GitHub Actions - deepgeosense`
   - **Access permissions**: Select **"Read, Write, Delete"**
4. Click **"Generate"**
5. **IMPORTANT**: Copy the token immediately (you won't see it again!)
   - It looks like: `dckr_pat_abc123xyz...`

### 2.2 Add Secrets to GitHub

1. Go to your repository: `https://github.com/USERNAME/deepgeosense/settings/secrets/actions`
2. Click **"New repository secret"**
3. Add first secret:
   - **Name**: `DOCKER_USERNAME`
   - **Secret**: Your Docker Hub username
   - Click **"Add secret"**
4. Click **"New repository secret"** again
5. Add second secret:
   - **Name**: `DOCKER_TOKEN`
   - **Secret**: Paste the token you copied (starts with `dckr_pat_`)
   - Click **"Add secret"**

### 2.3 Trigger First Build

The GitHub Action is already configured in `.github/workflows/docker-publish.yml`.

**Option A: Push a tag (triggers versioned build)**
```bash
git tag v1.0.0
git push origin v1.0.0
```

**Option B: Push to main (triggers latest build)**
```bash
# Make a small change
git commit --allow-empty -m "Trigger Docker build"
git push origin main
```

**Option C: Manual trigger**
1. Go to: `https://github.com/USERNAME/deepgeosense/actions`
2. Click on "Build and Publish Docker Image" workflow
3. Click "Run workflow" → "Run workflow"

### 2.4 Monitor the Build

1. Go to: `https://github.com/USERNAME/deepgeosense/actions`
2. Watch the build progress (takes ~10-15 minutes first time)
3. When complete, your image will be at: `https://hub.docker.com/r/USERNAME/deepgeosense`

### 2.5 Test the Published Image

**Using Docker (rootless):**
```bash
docker pull USERNAME/deepgeosense:latest
docker run -it --rm USERNAME/deepgeosense:latest python -c "import torch, rasterio, shapely; print('✓ Success!')"
```

**Using Podman (rootless):**
```bash
podman pull USERNAME/deepgeosense:latest
podman run -it --rm USERNAME/deepgeosense:latest python -c "import torch, rasterio, shapely; print('✓ Success!')"
```

**Testing GPU access (requires elevated permissions):**
```bash
# Docker
sudo docker run -it --rm --gpus all USERNAME/deepgeosense:latest python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"

# Podman
sudo podman run -it --rm --security-opt=label=disable USERNAME/deepgeosense:latest python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
```

## What Happens Automatically?

Once set up, every time you:
- **Push to main** → Builds and pushes `USERNAME/deepgeosense:latest`
- **Push a tag like `v1.0.0`** → Builds and pushes:
  - `USERNAME/deepgeosense:1.0.0`
  - `USERNAME/deepgeosense:1.0`
  - `USERNAME/deepgeosense:1`
  - `USERNAME/deepgeosense:latest`

## Troubleshooting

### Build fails with "authentication required"
- Check that `DOCKER_USERNAME` and `DOCKER_TOKEN` secrets are set correctly
- Verify token has "Read, Write, Delete" permissions

### Can't find secrets page
- Make sure you're the repo owner/admin
- URL: `https://github.com/USERNAME/deepgeosense/settings/secrets/actions`

### Want to see what will be built?
Check the workflow file: `.github/workflows/docker-publish.yml`

## Next Steps

Once the image is published, use it as a base for your downstream projects:

```dockerfile
FROM USERNAME/deepgeosense:latest

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
RUN pip install -e .

CMD ["python", "-m", "your_module"]
```

This will reduce build times from ~10 minutes to ~1 minute!

## Using with Podman vs Docker

Both Docker and Podman can use this base image. Here's when elevated permissions are needed:

### Rootless Operations (No sudo required)
- `docker/podman pull` - Download images
- `docker/podman build` - Build new images
- `docker/podman run` - Run containers without GPU

### Operations Requiring Elevated Permissions (sudo required)
- **GPU access** - Both Docker and Podman need elevated permissions for NVIDIA GPU access
- **Rootful Podman** - More reliable for GPU workloads

### Example: Building a Downstream Project

**Rootless build (no GPU needed):**
```bash
# Docker
docker build -t myproject:latest .

# Podman
podman build -t myproject:latest .
```

**Rootful run with GPU:**
```bash
# Docker
sudo docker run -it --rm --gpus all -v $(pwd)/data:/data myproject:latest

# Podman
sudo podman run -it --rm --security-opt=label=disable \
  -e NVIDIA_VISIBLE_DEVICES=all \
  -e NVIDIA_DRIVER_CAPABILITIES=compute,utility \
  -v $(pwd)/data:/data:Z \
  myproject:latest
```

### Using with Podman Compose

Create a `docker-compose.yml`:
```yaml
version: '3.8'

services:
  myproject:
    build:
      context: .
      dockerfile: Dockerfile
    image: myproject:latest
    volumes:
      - ./data:/data:Z
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=compute,utility
    security_opt:
      - label=disable
```

Then run:
```bash
# Build (rootless)
podman-compose build

# Run with GPU (requires sudo for GPU access)
sudo podman-compose up
```
