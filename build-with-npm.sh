#!/bin/bash

# Force npm installation on Render
echo "🔧 Forcing npm usage instead of Bun..."

# Remove any Bun-related files that might trigger Bun detection
rm -f bun.lockb
rm -f bun.lock

# Ensure we're in the frontend directory
cd mitraverify-frontend

# Remove Bun lock files in frontend too
rm -f bun.lockb
rm -f bun.lock

# Force npm installation with legacy peer deps
echo "📦 Installing with npm (legacy peer deps)..."
npm install --legacy-peer-deps --prefer-offline --no-audit --no-fund

# Build the project
echo "🏗️ Building Next.js project..."
npm run build

echo "✅ Build completed successfully!"