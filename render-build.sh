#!/bin/bash
# Render build script for MitraVerify frontend

echo "🚀 Starting Render build for MitraVerify frontend..."

# Navigate to frontend directory
cd mitraverify-frontend

echo "📦 Installing dependencies..."
npm install --legacy-peer-deps

echo "🏗️ Building Next.js application..."
npm run build

echo "✅ Build completed successfully!"
echo "📁 Build output available in: mitraverify-frontend/out/"

# List output directory contents for verification
echo "📋 Build output contents:"
ls -la out/