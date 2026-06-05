# 🌿 Bloomstep — Step Garden App

A wellness app where walking and drinking water grows your virtual garden.

## What This App Does

- **Steps from iPhone HealthKit** grow your nursery plants
- **Water intake logging** also feeds your plants — both are required for growth
- **Nursery system** — seeds start in a pot, grow through 4 stages, then get transplanted to your garden
- **Draggable garden** — place plants and decorations anywhere on a lush grass canvas
- **Day / Afternoon / Sunset / Night** sky modes with animated backgrounds
- **Coins system** — convert steps to coins, spend on premium seeds and decorations
- **Shop** — 7 plant types and 12 decorations with tiered pricing
- **Meditation** — guided 5/10/15 minute diaphragmatic breathing session with animated visuals
- **Health tracking** — water intake, weight log, step count
- **Daily affirmations** — a new motivational message every day
- **Disclaimer screen** — a heartfelt onboarding with two promise checkboxes

## Getting Started

### Prerequisites
- Node.js v18 or higher
- npm v9 or higher

### Install & Run

```bash
# Install dependencies
npm install

# Start the development server
npm run dev
```

Then open your browser to `http://localhost:5173`

### Build for Production

```bash
npm run build
```

## Project Structure

```
bloomstep/
├── index.html          # HTML entry point
├── vite.config.js      # Vite bundler config
├── package.json        # Dependencies
└── src/
    ├── main.jsx        # React root render
    └── App.jsx         # Entire application (single file)
```

## Tech Stack

- **React 18** — UI framework
- **Vite** — fast development server and bundler
- **Web Audio API** — sound effects (water, planting, coins, breathing)
- **CSS animations** — plant sway, float, twinkle effects
- **Google Fonts** — Baloo 2 + Nunito

## Notes for Devin / Developers

- The entire app lives in `src/App.jsx` — one self-contained file
- Steps are currently mocked as a static number (4,200). In the real iOS app, these come from Apple HealthKit via `react-native-health`
- The full native iOS build spec is in the `Bloomstep_Developer_Spec.docx` (ask the project owner)
- Colors, plant data, decoration data, and sky modes are all defined as constants at the top of App.jsx for easy editing
- Sound is generated procedurally using the Web Audio API — no audio files needed

## Color Palette

| Name | Hex |
|------|-----|
| Primary Green | `#2d5a27` |
| Active Green | `#43a047` |
| Soft Green | `#81c784` |
| Gold / Coins | `#f9a825` |
| Water Blue | `#1976d2` |
| Weight Purple | `#8e24aa` |
