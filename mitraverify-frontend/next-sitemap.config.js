/** @type {import('next-sitemap').IConfig} */
module.exports = {
  siteUrl: process.env.SITE_URL || 'https://mitraverify.netlify.app',
  generateRobotsTxt: true,
  sitemapSize: 7000,
  changefreq: 'daily',
  priority: 0.7,
  exclude: ['/admin/*', '/api/*'],
  alternateRefs: [
    {
      href: 'https://mitraverify.netlify.app/en',
      hreflang: 'en',
    },
    {
      href: 'https://mitraverify.netlify.app/hi',
      hreflang: 'hi',
    },
  ],
  robotsTxtOptions: {
    policies: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/admin', '/api'],
      },
    ],
    additionalSitemaps: [
      'https://mitraverify.netlify.app/sitemap.xml',
    ],
  },
};