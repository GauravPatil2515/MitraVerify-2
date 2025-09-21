# MitraVerify Netlify Deployment Script

Write-Host "=== MitraVerify Netlify Deployment ===" -ForegroundColor Cyan
Write-Host "This script will build and deploy the frontend to Netlify" -ForegroundColor Yellow
Write-Host ""

# Check if we're in the frontend directory
$frontendPath = "c:\Users\GAURAV PATIL\Downloads\Mitra_Verify-2.0\mitraverify-frontend"

if (-not (Test-Path $frontendPath)) {
    Write-Host "❌ Frontend directory not found at: $frontendPath" -ForegroundColor Red
    exit 1
}

Set-Location $frontendPath

# Check for required tools
Write-Host "🔍 Checking prerequisites..." -ForegroundColor Yellow

# Check Node.js
try {
    $nodeVersion = node --version
    Write-Host "✅ Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js not found. Please install Node.js 18+ from https://nodejs.org" -ForegroundColor Red
    exit 1
}

# Check NPM
try {
    $npmVersion = npm --version
    Write-Host "✅ NPM: $npmVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ NPM not found" -ForegroundColor Red
    exit 1
}

# Check if package.json exists
if (-not (Test-Path "package.json")) {
    Write-Host "❌ package.json not found in frontend directory" -ForegroundColor Red
    exit 1
}

# Environment setup
Write-Host "🔧 Setting up environment..." -ForegroundColor Yellow

# Create .env.local if it doesn't exist
if (-not (Test-Path ".env.local")) {
    Write-Host "📝 Creating .env.local file..." -ForegroundColor Cyan
    @"
# Production Environment Variables
NEXT_PUBLIC_API_URL=https://your-backend-api.herokuapp.com
NEXT_PUBLIC_APP_NAME=MitraVerify
NEXT_PUBLIC_APP_VERSION=2.0
NEXT_PUBLIC_API_TIMEOUT=30000
NEXT_PUBLIC_MAX_FILE_SIZE=10485760
NEXT_PUBLIC_ENABLE_IMAGE_ANALYSIS=true
NEXT_PUBLIC_ENABLE_TEXT_ANALYSIS=true
NEXT_PUBLIC_ENABLE_EVIDENCE_RETRIEVAL=true
SITE_URL=https://mitraverify.netlify.app
"@ | Out-File -FilePath ".env.local" -Encoding UTF8
    
    Write-Host "⚠️  Please update .env.local with your production API URL!" -ForegroundColor Yellow
    $continue = Read-Host "Press Enter to continue or 'q' to quit and update the file first"
    if ($continue -eq 'q') {
        Write-Host "👉 Edit .env.local and run this script again" -ForegroundColor Yellow
        exit 0
    }
}

# Install dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
npm install --legacy-peer-deps
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
    exit 1
}

# Run type check
Write-Host "🔍 Running type check..." -ForegroundColor Yellow
npm run type-check
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Type check failed, but continuing..." -ForegroundColor Yellow
}

# Run linting
Write-Host "🧹 Running linter..." -ForegroundColor Yellow
npm run lint
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️  Linting issues found, but continuing..." -ForegroundColor Yellow
}

# Build the application
Write-Host "🏗️  Building application..." -ForegroundColor Yellow
npm run build
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Build completed successfully!" -ForegroundColor Green

# Check if Netlify CLI is installed
Write-Host "🔍 Checking Netlify CLI..." -ForegroundColor Yellow
try {
    $netlifyVersion = netlify --version
    Write-Host "✅ Netlify CLI: $netlifyVersion" -ForegroundColor Green
} catch {
    Write-Host "📥 Installing Netlify CLI..." -ForegroundColor Yellow
    npm install -g netlify-cli
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install Netlify CLI" -ForegroundColor Red
        Write-Host "👉 Install manually: npm install -g netlify-cli" -ForegroundColor Yellow
        exit 1
    }
}

# Deployment options
Write-Host ""
Write-Host "🚀 Ready to deploy!" -ForegroundColor Green
Write-Host "Choose deployment option:" -ForegroundColor Yellow
Write-Host "1. Deploy to production (live site)" -ForegroundColor White
Write-Host "2. Deploy preview (draft)" -ForegroundColor White
Write-Host "3. Just build (no deployment)" -ForegroundColor White
Write-Host ""

$choice = Read-Host "Enter your choice (1-3)"

switch ($choice) {
    "1" {
        Write-Host "🌐 Deploying to production..." -ForegroundColor Green
        netlify deploy --prod --dir=out
    }
    "2" {
        Write-Host "🔍 Deploying preview..." -ForegroundColor Yellow
        netlify deploy --dir=out
    }
    "3" {
        Write-Host "✅ Build completed. Files are ready in ./out directory" -ForegroundColor Green
        Write-Host "👉 You can manually upload the 'out' folder to Netlify" -ForegroundColor Cyan
    }
    default {
        Write-Host "❌ Invalid choice" -ForegroundColor Red
        exit 1
    }
}

if ($choice -eq "1" -or $choice -eq "2") {
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "🎉 Deployment successful!" -ForegroundColor Green
        Write-Host "📱 Your MitraVerify app is now live on Netlify!" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "1. Update your backend API URL in the environment variables" -ForegroundColor White
        Write-Host "2. Test the deployed application" -ForegroundColor White
        Write-Host "3. Configure custom domain (optional)" -ForegroundColor White
    } else {
        Write-Host "❌ Deployment failed" -ForegroundColor Red
        Write-Host "👉 Check the error messages above and try again" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "📚 Useful commands:" -ForegroundColor Cyan
Write-Host "• netlify status    - Check deployment status" -ForegroundColor White
Write-Host "• netlify open      - Open your site in browser" -ForegroundColor White
Write-Host "• netlify logs      - View deployment logs" -ForegroundColor White