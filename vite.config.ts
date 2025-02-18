import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react-swc'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          // Split large dependencies into separate chunks
          react: ['react', 'react-dom'], // Example splitting React into its own chunk
          capacitor: ['@capacitor/core'],
          // Add more libraries as needed
        },
      },
    },
  }
})
