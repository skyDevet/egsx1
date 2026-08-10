// vite.config.js
import { defineConfig } from 'vite'
import preact from '@preact/preset-vite'

export default defineConfig({
  plugins: [preact()],
  base: '/egsx1/',
  server: {
    proxy: {
      '/api': {
        target: 'https://iftms.motl.gov.et',
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/api/, ''),
      },
      '/api-auth': {
        target: 'https://api.iftms.motl.gov.et',
        changeOrigin: true,
        secure: false,
        rewrite: (path) => path.replace(/^\/api-auth/, ''),
      }
    }
  }
})