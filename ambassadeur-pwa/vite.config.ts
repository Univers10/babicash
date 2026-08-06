import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['icon.svg'],
      manifest: {
        name: 'BabiCash Ambassadeur',
        short_name: 'Ambassadeur',
        description: 'Espace ambassadeur BabiCash — parrainage et commissions',
        lang: 'fr',
        theme_color: '#1B6B2F',
        background_color: '#0f1512',
        display: 'standalone',
        orientation: 'portrait',
        start_url: '/',
        icons: [
          {
            src: 'icon.svg',
            sizes: 'any',
            type: 'image/svg+xml',
            purpose: 'any maskable',
          },
        ],
      },
    }),
  ],
  server: { port: 5173, host: true },
})
