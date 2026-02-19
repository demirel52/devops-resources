/** @type {import('tailwindcss').Config} */
module.exports = {
  // NOTE: Update this to include the paths to all of your component files.
  content: ["./App.{js,jsx,ts,tsx}", "./src/**/*.{js,jsx,ts,tsx}"],
  presets: [require("nativewind/preset")],
  theme: {
    extend: {
      colors: {
        primary: "#8B5CF6", // Purple accent
        secondary: "#D4AF37", // Gold accent
        luxury: {
          black: "#050505",
          gray: "#1A1A1A",
          darkGray: "#0F0F0F",
        }
      },
    },
  },
  plugins: [],
}
