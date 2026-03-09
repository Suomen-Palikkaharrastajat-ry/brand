import { defineConfig } from "vite";
import tailwindcss from "@tailwindcss/vite";

export default {
  vite: {
    plugins: [tailwindcss()],
  },
  headTagsTemplate(context) {
    return `
<link rel="stylesheet" href="/style.css" />
<link rel="icon" type="image/x-icon" href="/favicon/favicon.ico" />
<link rel="icon" type="image/png" sizes="48x48" href="/favicon/favicon-48.png" />
<link rel="icon" type="image/png" sizes="32x32" href="/favicon/favicon-32.png" />
<link rel="icon" type="image/png" sizes="16x16" href="/favicon/favicon-16.png" />
<link rel="apple-touch-icon" sizes="180x180" href="/favicon/apple-touch-icon.png" />
    `;
  },
  preloadTagForFile(file) {
    if (file.endsWith(".js")) return true;
    if (file.endsWith(".ttf")) return true;
    return false;
  },
};
