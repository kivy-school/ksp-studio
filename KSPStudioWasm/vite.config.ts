import { defineConfig } from "vite";
import swiftWasm from "@elementary-swift/vite-plugin-swift-wasm";

export default defineConfig({
  plugins: [
    swiftWasm({
      useEmbeddedSDK: false,
    }),
  ],
  server: {
    // Proxy API calls to Vapor during development
    proxy: {
      "/api": {
        target: "http://127.0.0.1:8000",
        changeOrigin: true,
      },
    },
  },
  build: {
    // Output to dist/ for Vapor to serve
    outDir: "dist",
  },
});
