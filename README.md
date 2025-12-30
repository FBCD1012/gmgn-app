# GMGN App - Copy Trading Platform

A pixel-perfect Flutter clone of GMGN.AI mobile application, featuring cryptocurrency copy trading functionality.

## Live Demo

**GitHub Pages:** https://fbcd1012.github.io/gmgn-app/

## Features

- **User Authentication** - Login/Register with email or social accounts (Telegram, Google, Phantom)
- **Wallet Overview** - Balance display, deposit functionality, transaction history
- **Copy Trading** - Follow top traders, configure copy settings, manage positions
- **Market Data** - Real-time token listings with price, volume, market cap
- **Monitor** - Track followed tokens and trending assets
- **Dark Theme** - Matches GMGN.AI's mobile interface

## Screenshots

| Home | Copy Trade | Assets |
|------|------------|--------|
| Discover trending tokens | Top traders ranking | Wallet & holdings |

## Tech Stack

- **Framework:** Flutter 3.38.5
- **State Management:** Provider with Selector pattern
- **Backend:** Mock API (simulated data)
- **Deployment:** GitHub Pages via GitHub Actions

## AI Tools Used

- **Claude Code (Anthropic)** - AI-assisted development with custom project constitution (CLAUDE.md)
- Based on self-built framework configuration for consistent code generation and UI matching

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── components/               # Reusable UI components
│   ├── g_image.dart
│   ├── g_list_items.dart
│   └── theme.dart
├── models/                   # Data models
│   ├── token.dart
│   ├── trader.dart
│   └── trade_history.dart
├── providers/                # State management
│   ├── auth_state.dart
│   ├── token_state.dart
│   ├── trader_state.dart
│   └── wallet_state.dart
├── screens/                  # Page screens
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── copy_trade_screen.dart
│   ├── copy_trade_settings_screen.dart
│   ├── trader_detail_screen.dart
│   ├── token_detail_screen.dart
│   ├── trade_history_screen.dart
│   ├── monitor_screen.dart
│   └── asset_screen.dart
├── services/                 # API & utilities
│   ├── mock_api.dart
│   └── image_cache_config.dart
└── widgets/                  # UI components
    ├── token_card.dart
    ├── deposit_sheet.dart
    ├── shimmer_loading.dart
    └── copy_trade/
        ├── trader_list_item.dart
        └── top_three_traders.dart
```

## Getting Started

### Prerequisites

- Flutter SDK 3.38.5+
- Dart SDK 3.8.0+

### Installation

```bash
# Clone the repository
git clone https://github.com/FBCD1012/gmgn-app.git
cd gmgn-app

# Install dependencies
flutter pub get

# Run in development
flutter run -d chrome
```

### Build for Production

```bash
# Build web release
flutter build web --release

# Serve locally
cd build/web && python3 -m http.server 8080
```

## Deployment

### GitHub Actions Workflow (`.github/workflows/deploy.yml`)

```yaml
Trigger: Push to main branch

Steps:
1. Checkout code
2. Setup Flutter 3.38.5
3. Run: flutter pub get
4. Run: flutter build web --release --base-href "/gmgn-app/"
5. Upload build/web as artifact
6. Deploy to GitHub Pages
```

### Deployment Flow

```
Developer pushes code to main
        ↓
GitHub Actions triggered automatically
        ↓
Flutter build web (production)
        ↓
Deploy to GitHub Pages
        ↓
Live at: https://fbcd1012.github.io/gmgn-app/
```

Build time: ~2-3 minutes

## Documentation

- [UX Flow Document](./docs/UX_FLOW.md) - User journey maps, wireframes, interaction flows

## Core Functionality

### 1. User Registration Flow
```
Open App → Tap Connect → Enter Email → Verify → Account Created
```

### 2. Copy Trade Flow
```
Browse Traders → View Detail → Tap "Copy Trade" → Configure Settings → Confirm
```

### 3. Token Discovery Flow
```
Home Screen → Filter (Hot/New/etc) → Tap Token → View Detail → Buy/Sell
```

## Performance Optimizations

- **Selector Pattern:** Precise widget rebuilds instead of full Consumer
- **RepaintBoundary:** Isolated animation repaints
- **Image Caching:** CachedNetworkImage with memory optimization
- **Shimmer Loading:** Skeleton screens during data fetch

## License

MIT License

## Acknowledgments

- UI Design Reference: [GMGN.AI](https://gmgn.ai)
- AI Assistant: [Claude Code](https://claude.ai) by Anthropic
- Framework: [Flutter](https://flutter.dev)

---

*Built with AI-assisted development*
