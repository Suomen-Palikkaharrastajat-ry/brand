import { defineConfig } from "vite";
import elmTailwind from "elm-tailwind-classes/vite";
import tailwindcss from "@tailwindcss/vite";

export default {
  vite: {
    plugins: [elmTailwind(), tailwindcss()],
  },
  headTagsTemplate(context) {
    return `
<link rel="stylesheet" href="/style.css" />
    `;
  },
  preloadTagForFile(file) {
    if (file.endsWith(".js")) return true;
    if (file.endsWith(".ttf")) return true;
    return false;
  },
};
