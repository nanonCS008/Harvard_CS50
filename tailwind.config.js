/**** Tailwind CSS config ****/
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        ashPink: {
          50: '#fff1f7',
          100: '#ffe4f0',
          200: '#ffbfdb',
          300: '#ff98c5',
          400: '#ff6eae',
          500: '#f83f96',
          600: '#d11c77',
          700: '#a1145a',
          800: '#6f0c3e',
          900: '#3a061f'
        },
        ashPurple: {
          50: '#f5f2ff',
          100: '#ebe5ff',
          200: '#d4caff',
          300: '#bbaeff',
          400: '#a391ff',
          500: '#8a74ff',
          600: '#6a4cff',
          700: '#5438d6',
          800: '#3e27a6',
          900: '#281875'
        },
        ashBlue: {
          50: '#eef7ff',
          100: '#d8ecff',
          200: '#b0d8ff',
          300: '#87c3ff',
          400: '#5eaeff',
          500: '#3599ff',
          600: '#0a7ffc',
          700: '#0662c4',
          800: '#05478b',
          900: '#032e59'
        }
      }
    }
  },
  plugins: [],
};