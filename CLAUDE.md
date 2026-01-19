# CLAUDE.md - Glasscast Weather App Context

This file provides context for AI-assisted development of the Glasscast weather app. Use this to understand the project structure, architecture, and development patterns.

## Project Overview

**Glasscast** is a minimal weather app built with SwiftUI, featuring:
- iOS 26 Liquid Glass design aesthetic (glass-morphism effects)
- Supabase authentication and database
- OpenWeatherMap API integration
- MVVM architecture
- Clean, modern UI with smooth animations

## Architecture

### MVVM Pattern
- **Models**: Data structures (`WeatherModels.swift`)
- **Views**: SwiftUI views (`Views/` directory)
- **ViewModels**: Business logic and state management (`ViewModels/` directory)
- **Services**: API and backend services (`Services/` directory)

### Key Components

#### Models
- `WeatherResponse`: Current weather API response
- `ForecastResponse`: 5-day forecast API response
- `FavoriteCity`: User's favorite cities stored in Supabase
- `CurrentWeather`: Processed weather data for display
- `ForecastDay`: Daily forecast data

#### ViewModels
- `AuthenticationViewModel`: Handles Supabase auth (sign up, sign in, sign out)
- `WeatherViewModel`: Manages current weather and forecast data
- `CitiesViewModel`: Manages favorite cities and city search
- `SettingsViewModel`: Manages app settings (temperature unit)

#### Services
- `SupabaseManager`: Singleton for Supabase client configuration
- `WeatherService`: Handles OpenWeatherMap API calls

#### Views
- `RootView`: Root view that switches between auth and main app
- `AuthView`: Sign up/Sign in screen with glass effects
- `MainTabView`: Tab bar container for main app screens
- `HomeView`: Current weather and 5-day forecast
- `CitySearchView`: Search and manage favorite cities
- `SettingsView`: App settings and sign out

## Design System

### Liquid Glass Effects
The app uses a custom glass-morphism design system:

```swift
.glassEffect() // Custom modifier for glass containers
```

Key design elements:
- Gradient backgrounds (dark blue/purple)
- Translucent containers with blur effects
- White text with varying opacity
- Subtle borders and shadows
- Smooth animations and transitions

### Color Palette
- Background: Dark gradients (`Color(red: 0.1, green: 0.1, blue: 0.2)` to `Color(red: 0.2, green: 0.15, blue: 0.3)`)
- Text: White with opacity variations
- Accents: Blue gradients for icons
- Glass: `.ultraThinMaterial` with custom opacity

## API Integration

### OpenWeatherMap API
- Base URL: `https://api.openweathermap.org/data/2.5`
- Endpoints:
  - `/weather` - Current weather
  - `/forecast` - 5-day forecast
- API key stored in `Info.plist` as `WEATHER_API_KEY`
- Units: Metric (converted to °C/°F in app)

### Supabase
- Authentication: Email/password
- Database: `favorite_cities` table
  - Columns: `id`, `user_id`, `city_name`, `lat`, `lon`, `created_at`
  - RLS enabled for user-specific access
- Credentials stored in `Info.plist`:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`

## Configuration

### Required API Keys
Add to `Info.plist`:
```xml
<key>WEATHER_API_KEY</key>
<string>your_openweathermap_api_key</string>
<key>SUPABASE_URL</key>
<string>your_supabase_project_url</string>
<key>SUPABASE_ANON_KEY</key>
<string>your_supabase_anon_key</string>
```

### Supabase Setup
1. Create `favorite_cities` table:
```sql
CREATE TABLE favorite_cities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id) NOT NULL,
  city_name TEXT NOT NULL,
  lat DOUBLE PRECISION NOT NULL,
  lon DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

2. Enable RLS:
```sql
ALTER TABLE favorite_cities ENABLE ROW LEVEL SECURITY;

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

## Development Patterns

### Async/Await
All network calls use async/await:
```swift
func fetchData() async throws -> Data {
    // async implementation
}
```

### Error Handling
- Custom error types (`WeatherServiceError`)
- User-friendly error messages
- Retry mechanisms where appropriate

### State Management
- `@Published` properties in ViewModels
- `@StateObject` for view model ownership
- `@EnvironmentObject` for shared state

### Loading States
- `isLoading` flags in ViewModels
- Progress indicators in UI
- Disabled states during operations

## Common Tasks

### Adding a New Feature
1. Create model if needed
2. Add service method if API call required
3. Create/update ViewModel
4. Create/update View
5. Add navigation/routing if needed

### Debugging
- Check console for API errors
- Verify Supabase credentials
- Check network connectivity
- Validate API key permissions

### UI Improvements
- Maintain glass effect consistency
- Use consistent spacing (20, 30, 40)
- Follow color palette
- Add smooth animations

## File Structure
```
Glasscast - A Minimal Weather App/
├── Models/
│   └── WeatherModels.swift
├── Services/
│   ├── SupabaseManager.swift
│   └── WeatherService.swift
├── ViewModels/
│   ├── AuthenticationViewModel.swift
│   ├── WeatherViewModel.swift
│   ├── CitiesViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── RootView.swift
│   ├── AuthView.swift
│   ├── MainTabView.swift
│   ├── HomeView.swift
│   ├── CitySearchView.swift
│   └── SettingsView.swift
├── GlasscastApp.swift
└── Info.plist
```

## Testing Checklist
- [ ] Authentication flow (sign up, sign in, sign out)
- [ ] Weather data loading
- [ ] City search and add to favorites
- [ ] Temperature unit toggle
- [ ] Pull-to-refresh
- [ ] Error handling
- [ ] Loading states
- [ ] Navigation between screens

## Notes for AI Assistance

When working on this project:
1. Maintain MVVM architecture
2. Use async/await for all async operations
3. Follow the glass effect design system
4. Handle errors gracefully
5. Provide loading states
6. Keep code clean and well-commented
7. Use SwiftUI best practices
8. Ensure proper state management

## Future Enhancements (Bonus Features)
- Real-time sync with Supabase Realtime
- iOS widgets
- Haptic feedback
- Dark mode optimizations
- Advanced animations
- Weather maps
- Notifications
