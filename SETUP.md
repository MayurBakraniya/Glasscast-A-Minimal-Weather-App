# Setup Guide - Glasscast Weather App

This guide will walk you through setting up the Glasscast app with all required API keys and configurations.

## Prerequisites

- Xcode 15.0 or later
- iOS 17.0+ deployment target
- Active internet connection
- Supabase account (free tier)
- OpenWeatherMap account (free tier)

## Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up/login
2. Click "New Project"
3. Fill in:
   - **Name**: Glasscast (or any name)
   - **Database Password**: Choose a strong password (save it!)
   - **Region**: Choose closest to you
4. Wait for project to be created (2-3 minutes)

### Get Supabase Credentials

1. In your Supabase project, go to **Settings** → **API**
2. Copy the following:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (starts with `eyJ...`)

## Step 2: Set Up Supabase Database

1. In Supabase dashboard, go to **SQL Editor**
2. Click **New Query**
3. Paste and run this SQL:

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

4. Click **Run** to execute the SQL
5. Verify the table was created in **Table Editor**

## Step 3: Get OpenWeatherMap API Key

1. Go to [openweathermap.org](https://openweathermap.org/api)
2. Click **Sign Up** (top right)
3. Fill in the registration form
4. Verify your email
5. Log in and go to **API keys** section
6. Copy your **API key** (or generate a new one)

**Note**: Free tier allows 60 calls/minute and 1,000,000 calls/month

## Step 4: Configure Xcode Project

### Option A: Add to Info.plist (Recommended for Development)

1. In Xcode, locate or create `Info.plist` in your project
2. Right-click on the file → **Open As** → **Source Code**
3. Add these keys before the closing `</dict>` tag:

```xml
<key>SUPABASE_URL</key>
<string>YOUR_SUPABASE_PROJECT_URL</string>
<key>SUPABASE_ANON_KEY</key>
<string>YOUR_SUPABASE_ANON_KEY</string>
<key>WEATHER_API_KEY</key>
<string>YOUR_OPENWEATHERMAP_API_KEY</string>
```

**Example:**
```xml
<key>SUPABASE_URL</key>
<string>https://abcdefghijklmnop.supabase.co</string>
<key>SUPABASE_ANON_KEY</key>
<string>eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFiY2RlZmdoaWprbG1ub3AiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTYxNjIzOTAyMiwiZXhwIjoxOTMxODE1MDIyfQ.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx</string>
<key>WEATHER_API_KEY</key>
<string>1234567890abcdef1234567890abcdef</string>
```

### Option B: Use Environment Variables (Production)

For production apps, consider using:
- Xcode build configuration files
- Environment variables
- Secure keychain storage
- Server-side proxy

## Step 5: Add Supabase Swift Package

1. In Xcode, go to **File** → **Add Package Dependencies...**
2. Enter this URL: `https://github.com/supabase/supabase-swift`
3. Click **Add Package**
4. Select **Supabase** product
5. Click **Add Package**

## Step 6: Update App Entry Point

1. In Xcode, select your project in the navigator
2. Select the **Glasscast - A Minimal Weather App** target
3. Go to **Build Settings**
4. Search for "Info.plist File"
5. Ensure `Info.plist` path is correct

The app entry point is `GlasscastApp.swift` which uses `@main`.

## Step 7: Build and Run

1. Select a simulator (iPhone 15 Pro recommended) or connect a device
2. Press `Cmd + R` or click the **Play** button
3. The app should launch and show the authentication screen

## Step 8: Test the App

1. **Sign Up**: Create a new account with email/password
2. **Search Cities**: Go to Cities tab, search for "London" or "New York"
3. **Add Favorite**: Tap the + button to add a city
4. **View Weather**: Go to Home tab to see weather for your favorite city
5. **Settings**: Toggle temperature units and test sign out

## Troubleshooting

### "Supabase credentials not found"
- Verify `Info.plist` contains all three keys
- Check key names are exactly: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `WEATHER_API_KEY`
- Ensure no extra spaces or quotes in values

### "Failed to load favorite cities"
- Verify Supabase table was created correctly
- Check RLS policies are enabled
- Ensure user is authenticated

### "Invalid API key" (Weather)
- Verify OpenWeatherMap API key is correct
- Check API key hasn't exceeded rate limits
- Ensure key is active in OpenWeatherMap dashboard

### Authentication not working
- Verify Supabase project is active
- Check email confirmation settings in Supabase Auth settings
- Try creating a new account

### Build Errors
- Clean build folder: `Cmd + Shift + K`
- Delete DerivedData
- Restart Xcode
- Verify Swift Package dependencies are resolved

## Security Best Practices

⚠️ **IMPORTANT**: Never commit API keys to version control!

1. Add `Info.plist` to `.gitignore` if it contains secrets
2. Use environment variables for CI/CD
3. Consider using a secrets management service for production
4. Rotate API keys regularly
5. Use separate keys for development and production

## Next Steps

- Record your AI-assisted development workflow
- Take screenshots of the app
- Update README with screenshots
- Test on physical device
- Add any bonus features

## Support

If you encounter issues:
1. Check the README.md troubleshooting section
2. Review CLAUDE.md for architecture details
3. Verify all setup steps were completed
4. Check Supabase and OpenWeatherMap dashboards for errors

---

**Happy Coding! 🚀**
