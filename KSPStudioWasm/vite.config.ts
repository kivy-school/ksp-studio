import { defineConfig } from "vite";
import swiftWasm from "@elementary-swift/vite-plugin-swift-wasm";

// The plugin derives its Swift configuration from vite's command alone —
// `serve` builds debug, `build` builds release — so `vite build` has no way to
// produce a debug wasm. `scripts/build_wasm.py --debug` sets this to ask for
// one; unset means release, which is what a plain `npm run build` gets.
const isDebug = process.env.KSP_WASM_CONFIGURATION === "debug";

export default defineConfig({
  plugins: [
    swiftWasm({
      useEmbeddedSDK: false,
      // wasm-opt runs `-Os --strip-debug`, which would throw away exactly what
      // a debug build is for.
      useWasmOpt: !isDebug,
      // Appended after the plugin's own `--configuration release`. `swift
      // build` takes the last occurrence, and the plugin passes these same
      // args to `--show-bin-path`, so it looks for the .wasm in the debug
      // directory it actually wrote to.
      extraBuildArgs: isDebug ? ["--configuration", "debug"] : [],
    }),
  ],
  server: {
    // Proxy API calls to the Django server (`ksp-studio`, run from the root
    // of the ksproject being edited) during development.
    proxy: {
      "/api": {
        target: "http://127.0.0.1:8000",
        changeOrigin: true,
      },
    },
  },
  build: {
    // Output to dist/ for the Django server to serve.
    outDir: "dist",
  },
});
