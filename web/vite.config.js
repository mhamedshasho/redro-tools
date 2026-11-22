import { defineConfig } from "vite";
import { VitePWA } from "vite-plugin-pwa";

export default defineConfig({
  base: "/redro-tools/",
  plugins: [
    VitePWA({
      registerType: "autoUpdate",
      includeAssets: ["redro-mark.svg"],
      manifest: {
        name: "Redro PDF to Word",
        short_name: "Redro PDF",
        description: "Offline PDF to Word converter",
        theme_color: "#e11d48",
        background_color: "#101115",
        display: "standalone",
        start_url: "/redro-tools/",
        icons: [{ src: "redro-mark.svg", sizes: "any", type: "image/svg+xml", purpose: "any maskable" }]
      },
      workbox: {
        globPatterns: ["**/*.{js,css,html,svg,woff2}"],
        maximumFileSizeToCacheInBytes: 12 * 1024 * 1024
      }
    })
  ]
});
