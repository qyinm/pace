import { MetadataRoute } from 'next'
import { SITE_URL } from '@/lib/site'

export default function sitemap(): MetadataRoute.Sitemap {
  const currentDate = new Date()

  return [
    {
      url: SITE_URL,
      lastModified: currentDate,
      changeFrequency: 'weekly',
      priority: 1.0,
    },
    {
      url: `${SITE_URL}/#features`,
      lastModified: currentDate,
      changeFrequency: 'monthly',
      priority: 0.8,
    },
    {
      url: `${SITE_URL}/#download`,
      lastModified: currentDate,
      changeFrequency: 'monthly',
      priority: 0.9,
    },
  ]
}
