@echo off
echo 🔧 Forcing npm usage instead of Bun...

REM Remove any Bun-related files that might trigger Bun detection
if exist bun.lockb del bun.lockb
if exist bun.lock del bun.lock

REM Ensure we're in the frontend directory
cd mitraverify-frontend

REM Remove Bun lock files in frontend too
if exist bun.lockb del bun.lockb
if exist bun.lock del bun.lock

REM Force npm installation with legacy peer deps
echo 📦 Installing with npm (legacy peer deps)...
npm install --legacy-peer-deps --prefer-offline --no-audit --no-fund

REM Build the project
echo 🏗️ Building Next.js project...
npm run build

echo ✅ Build completed successfully!