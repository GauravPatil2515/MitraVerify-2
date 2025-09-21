# 🚀 Netlify Deployment Guide for MitraVerify

This guide will walk you through deploying the MitraVerify frontend to Netlify.

## 📋 Prerequisites

- Node.js 18+ installed
- NPM or Yarn package manager
- Netlify account (free tier available)
- Backend API deployed separately (Heroku, Railway, etc.)

## 🏗️ Project Structure

The MitraVerify project is structured as follows:
```
Mitra_Verify-2.0/
├── mitraverify-frontend/    # Next.js frontend (deploys to Netlify)
├── MitraVerify-Backend/     # FastAPI backend (deploy separately)
├── deploy-netlify.ps1       # Deployment script
└── README.md
```

## 🚀 Quick Deploy Options

### Option 1: Automated Script (Recommended)

1. **Run the deployment script:**
   ```powershell
   .\deploy-netlify.ps1
   ```

2. **Follow the prompts:**
   - The script will check prerequisites
   - Install dependencies
   - Build the application
   - Deploy to Netlify

### Option 2: Manual Deployment

1. **Navigate to frontend directory:**
   ```powershell
   cd mitraverify-frontend
   ```

2. **Install dependencies:**
   ```powershell
   npm install --legacy-peer-deps
   ```

3. **Configure environment variables:**
   - Copy `.env.example` to `.env.local`
   - Update `NEXT_PUBLIC_API_URL` with your backend URL

4. **Build the application:**
   ```powershell
   npm run build
   ```

5. **Deploy to Netlify:**
   ```powershell
   # Install Netlify CLI if not already installed
   npm install -g netlify-cli
   
   # Login to Netlify
   netlify login
   
   # Deploy
   netlify deploy --prod --dir=out
   ```

### Option 3: Git-based Deployment

1. **Push your code to GitHub**

2. **Connect to Netlify:**
   - Go to [Netlify](https://netlify.com)
   - Click "New site from Git"
   - Connect your GitHub repository
   - Select the `mitraverify-frontend` folder as base directory

3. **Configure build settings:**
   - **Build command:** `npm run build:netlify`
   - **Publish directory:** `out`
   - **Base directory:** `mitraverify-frontend`

## ⚙️ Configuration

### Environment Variables

Set these environment variables in Netlify dashboard:

| Variable | Example Value | Description |
|----------|---------------|-------------|
| `NEXT_PUBLIC_API_URL` | `https://your-api.herokuapp.com` | Backend API URL |
| `NEXT_PUBLIC_APP_NAME` | `MitraVerify` | Application name |
| `NEXT_PUBLIC_API_TIMEOUT` | `30000` | API request timeout (ms) |
| `NEXT_PUBLIC_MAX_FILE_SIZE` | `10485760` | Max file upload size (bytes) |
| `SITE_URL` | `https://mitraverify.netlify.app` | Your site URL |

### Build Settings

In Netlify dashboard:
- **Build command:** `npm run build:netlify`
- **Publish directory:** `out`
- **Base directory:** `mitraverify-frontend`
- **Node version:** `18`

### Domain Configuration

1. **Custom Domain (Optional):**
   - Go to Site settings > Domain management
   - Add your custom domain
   - Configure DNS records

2. **HTTPS:**
   - Automatically enabled by Netlify
   - Free SSL certificate included

## 🔧 Backend Deployment

The backend needs to be deployed separately. Recommended platforms:

### Heroku
```bash
# In MitraVerify-Backend directory
heroku create your-app-name
heroku buildpacks:add heroku/python
git subtree push --prefix=MitraVerify-Backend heroku main
```

### Railway
```bash
# Connect your GitHub repo to Railway
# Select MitraVerify-Backend as root directory
# Add environment variables in Railway dashboard
```

### Docker
```bash
# In MitraVerify-Backend directory
docker build -t mitraverify-backend .
docker run -p 8000:8000 mitraverify-backend
```

## 📊 Performance Optimization

The deployment includes several optimizations:

- **Static Export:** Generates static files for faster loading
- **Image Optimization:** Automatic image compression
- **Code Splitting:** Automatic code splitting for smaller bundles
- **Caching:** Optimized caching headers
- **Compression:** Gzip compression enabled
- **CDN:** Global CDN for fast content delivery

## 🧪 Testing the Deployment

After deployment:

1. **Test basic functionality:**
   - Visit your Netlify URL
   - Test text analysis
   - Test image upload
   - Verify API connection

2. **Check network requests:**
   - Open browser dev tools
   - Check if API calls are successful
   - Verify CORS headers

3. **Performance testing:**
   - Use Lighthouse for performance scores
   - Test on mobile devices
   - Check loading times

## 🚨 Troubleshooting

### Common Issues

1. **Build Fails:**
   ```bash
   # Check Node version
   node --version  # Should be 18+
   
   # Clear cache
   npm cache clean --force
   rm -rf node_modules package-lock.json
   npm install --legacy-peer-deps
   ```

2. **API Connection Issues:**
   - Verify `NEXT_PUBLIC_API_URL` is correct
   - Check CORS settings on backend
   - Ensure backend is deployed and accessible

3. **Environment Variables Not Working:**
   - Ensure variables start with `NEXT_PUBLIC_`
   - Redeploy after changing environment variables
   - Check variable names for typos

4. **Static Export Issues:**
   - Ensure no dynamic routes use `getServerSideProps`
   - Check for Node.js-specific code in client components
   - Use `next/image` with `unoptimized: true`

## 📈 Monitoring and Analytics

### Netlify Analytics
- Enable in Site settings > Analytics
- Track page views, unique visitors
- Monitor performance metrics

### Custom Analytics (Optional)
Add Google Analytics or other tracking:
```javascript
// In _app.tsx or layout component
export default function App({ Component, pageProps }) {
  useEffect(() => {
    // Add analytics code here
  }, []);
  
  return <Component {...pageProps} />;
}
```

## 🔄 CI/CD Pipeline

The repository includes GitHub Actions for automated deployment:

1. **Triggers:**
   - Push to `main` branch (production)
   - Push to `develop` branch (preview)
   - Pull requests (preview)

2. **Process:**
   - Install dependencies
   - Run type checking
   - Run linting
   - Build application
   - Deploy to Netlify

3. **Environment Setup:**
   Add these secrets to your GitHub repository:
   - `NETLIFY_AUTH_TOKEN`
   - `NETLIFY_SITE_ID`
   - `NEXT_PUBLIC_API_URL`

## 📝 Additional Resources

- [Netlify Documentation](https://docs.netlify.com/)
- [Next.js Static Export](https://nextjs.org/docs/advanced-features/static-html-export)
- [Netlify CLI Reference](https://cli.netlify.com/)
- [Environment Variables Guide](https://docs.netlify.com/configure-builds/environment-variables/)

## 🎯 Next Steps

After successful deployment:

1. **Configure monitoring** - Set up error tracking and performance monitoring
2. **Setup analytics** - Add Google Analytics or similar
3. **Optimize SEO** - Configure meta tags and sitemap
4. **Add custom domain** - Configure your own domain name
5. **Setup staging environment** - Create separate staging deployment

## 🆘 Support

If you encounter issues:

1. Check the [troubleshooting section](#-troubleshooting)
2. Review Netlify build logs
3. Check GitHub Actions logs (if using CI/CD)
4. Create an issue in the repository

---

**Happy Deploying! 🚀**