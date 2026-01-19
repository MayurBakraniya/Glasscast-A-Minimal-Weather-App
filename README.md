# Glasscast - A Minimal Weather App

A beautiful, minimal weather app built with SwiftUI featuring iOS 26 Liquid Glass design aesthetics, Supabase authentication, and OpenWeatherMap API integration.

![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-green.svg)

## Features

- ✨ **Liquid Glass Design** - Beautiful glass-morphism UI with translucent effects
- 🔐 **Authentication** - Secure sign up/login via Supabase
- 🌤️ **Current Weather** - Real-time weather data for selected cities
- 📅 **5-Day Forecast** - Extended weather predictions
- 🔍 **City Search** - Search and add favorite cities
- 💾 **Cloud Sync** - Favorite cities synced to Supabase
- ⚙️ **Settings** - Temperature unit toggle (°C/°F)
- 🔄 **Pull-to-Refresh** - Refresh weather data with a pull gesture
- 🎨 **Smooth Animations** - Polished transitions and interactions

## Design

The app design was created using **Google Stitch**:
- Design Project: [View on Google Stitch](https://stitch.withgoogle.com/projects/3904242175046082872)
- The design implements iOS 26 Liquid Glass aesthetics with glass-morphism effects
- All UI components follow the design system from the Stitch project

## Screenshots

*Add screenshots here after building the app*

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Active internet connection
- Supabase account (free tier)
- OpenWeatherMap API key (free tier)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd "Glasscast - A Minimal Weather App"
```

### 2. Install Dependencies

This project uses Swift Package Manager. Open the project in Xcode and:

1. Go to **File** → **Add Package Dependencies**
2. Add the Supabase Swift client:
   - URL: `https://github.com/supabase/supabase-swift`
   - Version: Latest

### 3. Configure Supabase

#### Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a free account
2. Create a new project
3. Note your project URL and anon key from Settings → API

#### Set Up Database

Run this SQL in the Supabase SQL Editor:

```sql
-- Create favorite_cities table
CREATE TABLE favorite_cities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  city_name TEXT NOT NULL,
  lat DOUBLE PRECISION NOT NULL,
  lon DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE favorite_cities ENABLE ROW LEVEL SECURITY;

-- Create policies for user-specific access
CREATE POLICY "Users can view own cities"
  ON favorite_cities FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own cities"
  ON favorite_cities FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own cities"
  ON favorite_cities FOR DELETE
  USING (auth.uid() = user_id);
```

### 4. Get OpenWeatherMap API Key

1. Go to [openweathermap.org](https://openweathermap.org/api)
2. Sign up for a free account
3. Navigate to API keys section
4. Copy your API key

### 5. Configure API Keys

Add your API keys to the project's `Info.plist`:

1. In Xcode, locate `Info.plist` (or create one if it doesn't exist)
2. Add the following keys:

```xml
<key>SUPABASE_URL</key>
<string>YOUR_SUPABASE_PROJECT_URL</string>
<key>SUPABASE_ANON_KEY</key>
<string>YOUR_SUPABASE_ANON_KEY</string>
<key>WEATHER_API_KEY</key>
<string>YOUR_OPENWEATHERMAP_API_KEY</string>
```

**Important**: Never commit API keys to version control. Consider using environment variables or a secrets file (excluded from git) for production.

### 6. Update App Entry Point

Ensure the project is configured to use `GlasscastApp` as the main entry point:

1. In Xcode, select the project in the navigator
2. Go to the target's **General** tab
3. Under **Deployment Info**, ensure iOS 17.0+ is selected
4. The app should automatically use `@main` in `GlasscastApp.swift`

### 7. Build and Run

1. Open the project in Xcode
2. Select a simulator or connected device
3. Press `Cmd + R` to build and run

## Project Structure

```
Glasscast - A Minimal Weather App/
├── Models/
│   └── WeatherModels.swift          # Data models
├── Services/
│   ├── SupabaseManager.swift        # Supabase client management
│   └── WeatherService.swift         # OpenWeatherMap API service
├── ViewModels/
│   ├── AuthenticationViewModel.swift # Auth state management
│   ├── WeatherViewModel.swift        # Weather data management
│   ├── CitiesViewModel.swift         # Favorite cities management
│   └── SettingsViewModel.swift      # App settings management
├── Views/
│   ├── RootView.swift               # Root navigation
│   ├── AuthView.swift               # Sign up/Sign in screen
│   ├── MainTabView.swift            # Tab bar container
│   ├── HomeView.swift               # Weather display
│   ├── CitySearchView.swift         # City search and favorites
│   └── SettingsView.swift           # Settings screen
├── GlasscastApp.swift               # App entry point
└── Info.plist                       # Configuration (API keys)
```

## Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture:

- **Models**: Data structures and API response models
- **Views**: SwiftUI views for UI presentation
- **ViewModels**: Business logic, state management, and data processing
- **Services**: API clients and external service integrations

## Design System

### Liquid Glass Effects

The app implements a custom glass-morphism design system with:
- Translucent containers with blur effects
- Gradient backgrounds
- Subtle borders and shadows
- Smooth animations

Custom modifier:
```swift
.glassEffect() // Applied to containers
```

### Color Palette

- **Background**: Dark blue/purple gradients
- **Text**: White with varying opacity
- **Accents**: Blue gradients for icons
- **Glass**: Ultra-thin material with custom opacity

## Usage

### First Launch

1. **Sign Up**: Create a new account with email and password
2. **Search Cities**: Use the Cities tab to search for weather locations
3. **Add Favorites**: Tap the + button to add cities to favorites
4. **View Weather**: Select a favorite city to see current weather and forecast
5. **Settings**: Toggle temperature units and manage account

### Features

- **Pull-to-Refresh**: Pull down on the home screen to refresh weather data
- **Temperature Units**: Switch between Celsius and Fahrenheit in Settings
- **Multiple Cities**: Add multiple favorite cities and switch between them
- **Cloud Sync**: All favorites are synced to your Supabase account

## Troubleshooting

### App Crashes on Launch

- Verify all API keys are correctly set in `Info.plist`
- Check that Supabase URL and keys are valid
- Ensure OpenWeatherMap API key has proper permissions

### Authentication Issues

- Verify Supabase project is active
- Check email confirmation settings in Supabase dashboard
- Ensure RLS policies are correctly configured

### Weather Data Not Loading

- Verify OpenWeatherMap API key is valid
- Check internet connectivity
- Ensure API key has not exceeded rate limits (free tier: 60 calls/minute)

### Cities Not Saving

- Verify Supabase database table exists
- Check RLS policies are enabled and correct
- Ensure user is authenticated

## Development

### Built With AI Assistance

This project was developed using **Claude Code** (Cursor) with AI-assisted development. See `CLAUDE.md` for context and development patterns.

### Key Technologies

- **SwiftUI**: Modern declarative UI framework
- **Supabase**: Backend-as-a-Service for auth and database
- **OpenWeatherMap API**: Weather data provider
- **Async/Await**: Modern concurrency patterns
- **MVVM**: Clean architecture pattern

## Security Notes

- API keys are stored in `Info.plist` (development)
- For production, consider:
  - Environment variables
  - Secure keychain storage
  - Server-side proxy for API calls
- Never commit API keys to version control
- Use `.gitignore` to exclude sensitive files

## License

This project is created as an assignment submission. All rights reserved.

## Acknowledgments

- [Supabase](https://supabase.com) for backend services
- [OpenWeatherMap](https://openweathermap.org) for weather data
- Apple for SwiftUI and iOS frameworks

## Contact

For questions or issues, please refer to the assignment submission guidelines.

---

**Built with ❤️ using AI-assisted development**
