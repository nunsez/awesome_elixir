import path from 'node:path';
import fs from 'node:fs';
import plugin from 'tailwindcss/plugin';

// Embeds Hero Icons (https://heroicons.com) into your app.css bundle
// See your `CoreComponents.icon/1` for more information.
//
const heroiconsPlugin = plugin(({ matchComponents, theme }) => {
  const iconsDir = path.join(__dirname, "./assets/vendor/heroicons/optimized");
  const values = {};
  const icons = [
    ["", "/24/outline"],
    ["-solid", "/24/solid"],
    ["-mini", "/20/solid"]
  ];

  icons.forEach(([suffix, dir]) => {
    const iconsPath = path.join(iconsDir, dir);
  
    fs.readdirSync(iconsPath).map((file) => {
      const name = path.basename(file, ".svg") + suffix;
      values[name] = { name, fullPath: path.join(iconsDir, dir, file) };
    });
  });

  matchComponents({
    "hero": ({ name, fullPath }) => {
      const  content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "");

      return {
        [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
        "-webkit-mask": `var(--hero-${name})`,
        "mask": `var(--hero-${name})`,
        "background-color": "currentColor",
        "vertical-align": "middle",
        "display": "inline-block",
        "width": theme("spacing.5"),
        "height": theme("spacing.5")
      };
    }
  }, { values });
});

/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./assets/js/**/*.{ts,tsx,js,jsx}",
    "./lib/*_web.ex",
    "./lib/*_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        brand: "#FD4F00"
      }
    }
  },
  plugins: [
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({ addVariant }) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({ addVariant }) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    heroiconsPlugin
  ]
};
