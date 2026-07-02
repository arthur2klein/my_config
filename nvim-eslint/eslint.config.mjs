// Fallback ESLint config for the Neovim eslint LSP, used only for projects
// that ship no config of their own (see before_init in lua/plugins/lsp.lua).
import reactHooks from "eslint-plugin-react-hooks";
import tseslint from "typescript-eslint";

export default [
    {
        files: ["**/*.{js,jsx,mjs,cjs,ts,tsx,mts,cts}"],
        languageOptions: {
            parser: tseslint.parser,
            parserOptions: {
                ecmaFeatures: {jsx: true},
                sourceType: "module",
            },
        },
        plugins: {"react-hooks": reactHooks},
        rules: {
            "react-hooks/rules-of-hooks": "error",
            "react-hooks/exhaustive-deps": "warn",
        },
    },
];
