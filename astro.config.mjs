import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
  output: 'static',
  server: {
    host: true
  },
  build: {
    assets: 'assets',
    inlineStylesheets: 'never'
  },
  vite: {
    build: {
      assetsInlineLimit: 0 // htmlにアセットを埋め込まないようにする
    }
  },
});
