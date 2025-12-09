# DeepGeoSense Setup Guide

## Publishing to Docker Hub

### Option 1: Manual Publishing (Quick Start)

1. **Build locally**:
   ```bash
   ./build.sh deepgeosense 1.0.0
   ```

2. **Test the image**:
   ```bash
   docker run -it --rm deepgeosense:latest python -c "import torch, rasterio, shapely; print('✓ Works!')"
   ```

3. **Publish to Docker Hub**:
   ```bash
   export DOCKER_USERNAME=yourusername
   ./publish.sh deepgeosense 1.0.0
   ```

### Option 2: GitHub + Docker Hub Auto-Build (Recommended)

This is the preferred approach - Docker Hub will automatically rebuild whenever you push to GitHub.

#### Step 1: Create Public GitHub Repository

```bash
# Rename default branch to main
git branch -m master main

# Create repo on GitHub (via web or gh CLI):
gh repo create deepgeosense --public --source=. --remote=origin

# Or manually at: https://github.com/new
# Repository name: deepgeosense
# Description: Base Docker image for geospatial deep learning
# Public: YES
# Do NOT initialize with README (we already have one)

# Add remote and push
git remote add origin https://github.com/yourusername/deepgeosense.git
git push -u origin main
```

#### Step 2: Link Docker Hub to GitHub

1. **Create Docker Hub account** (if needed): https://hub.docker.com/signup

2. **Create Docker Hub repository**:
   - Go to https://hub.docker.com/repositories
   - Click "Create Repository"
   - Name: `deepgeosense`
   - Visibility: Public
   - Click "Create"

3. **Set up automated builds**:
   - In your Docker Hub repository, go to "Builds" tab
   - Click "Configure Automated Builds"
   - Link your GitHub account (if not already linked)
   - Select your `deepgeosense` repository
   - Configure build rules:
     - Source: `/Dockerfile`
     - Tag: `latest` for branch `main`
     - Tag: `{sourceref}` for tags matching `/^v[0-9.]+$/`

4. **Trigger first build**:
   - Click "Trigger" to start initial build
   - Or push a tag: `git tag v1.0.0 && git push origin v1.0.0`

#### Step 3: Using GitHub Actions (Alternative to Docker Hub Auto-Build)

If you prefer GitHub Actions over Docker Hub auto-build:

1. **Generate Docker Hub access token**:
   - Go to https://hub.docker.com/settings/security
   - Click "New Access Token"
   - Description: "GitHub Actions"
   - Access permissions: "Read, Write, Delete"
   - Copy the token (you won't see it again!)

2. **Add secrets to GitHub**:
   - Go to your GitHub repo settings
   - Settings → Secrets and variables → Actions
   - Add two secrets:
     - `DOCKER_USERNAME`: Your Docker Hub username
     - `DOCKER_TOKEN`: The access token you just created

3. **Push to trigger build**:
   ```bash
   git push origin main
   # Or tag a release:
   git tag v1.0.0
   git push origin v1.0.0
   ```

The GitHub Action will automatically build and push to Docker Hub.

## Which Method Should You Use?

### Use Manual Publishing if:
- Quick one-time builds
- Testing locally
- No need for automation

### Use Docker Hub Auto-Build if:
- Want Docker Hub to handle everything
- Simple setup (no tokens needed)
- Don't mind slower builds

### Use GitHub Actions if:
- Faster builds (GitHub's infrastructure is faster)
- More control over build process
- Want to run tests before publishing
- **Recommended for active development**

## Quick Decision Tree

```
Do you want automation?
├─ No → Use manual publishing (./build.sh && ./publish.sh)
└─ Yes → Do you need fast builds?
    ├─ No → Docker Hub Auto-Build (simplest)
    └─ Yes → GitHub Actions (requires token setup)
```

## Next Steps After Publishing

Once your image is on Docker Hub, update the trace_segmentation project to use it:

```dockerfile
# trace_segmentation/podman/Dockerfile
FROM yourusername/deepgeosense:latest

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
RUN pip install -e .

CMD ["python", "-m", "muidc.trace.segmentation.inference"]
```

This will reduce build time from ~10 minutes to ~1 minute!
