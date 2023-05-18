import { defineConfig } from 'vite';
import solidPlugin from 'vite-plugin-solid';

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
        server: {
            host: 'localhost',
            port: 5173,
            strictPort: true
        },
        build: {
            assetsDir: 'assets/',
            outDir: 'priv/static/',
            emptyOutDir: true,
            manifest: false,
            sourcemap: true,
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
