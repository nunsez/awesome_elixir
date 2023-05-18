import { defineConfig } from 'vite';
import solidPlugin from 'vite-plugin-solid';

const ENV = process.env.NODE_ENV || "development";
const isDev = () => ENV === "development" || ENV === "dev";
const isProd = () => ENV === "production" || ENV === "prod";

/** @param {import('vite').ConfigEnv} configEnv */
const maybeCloseStdin = (configEnv) => {
    if (configEnv.command === 'build') return;

    process.stdin.on('close', () => process.exit(0));
    process.stdin.resume();
};

export default defineConfig((command) => {
    maybeCloseStdin(command);

    /** @type {import('vite').UserConfigExport} */
    const config = {
        plugins: [solidPlugin()],
        publicDir: 'assets/static/',
        server: isDev() && {
            host: 'localhost',
            port: 5173,
            strictPort: true
        },
        build: {
            assetsDir: 'assets/',
            outDir: 'priv/static/',
            emptyOutDir: isDev(),
            manifest: false,
            sourcemap: isDev(),
            assetsInlineLimit: 0,
            rollupOptions: {
                input: ['assets/js/app.ts'],
                output: {
                    entryFileNames: 'assets/[name].js',
                    chunkFileNames: 'assets/[name].js',
                    assetFileNames: 'assets/[name][extname]'
                }
            }
        }
    };

    return config;
});
