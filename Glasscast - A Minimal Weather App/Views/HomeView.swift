//
//  HomeView.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var citiesViewModel: CitiesViewModel
    
    @State private var appear = false
    
    @State private var backgroundAnimation: Bool = false
    
    var body: some View {
        ZStack {
            // Animated background
            AnimatedBackground()
            
            ScrollView {
                VStack(spacing: 0) {
                    if weatherViewModel.isLoading && weatherViewModel.currentWeather == nil {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                            .padding(.top, 100)
                    } else if let weather = weatherViewModel.currentWeather {
                        // Apple Weather-style Main Display
                        AppleWeatherMainView(weather: weather)
                            .padding(.top, 20)
                            .opacity(appear ? 1 : 0)
                            .offset(y: appear ? 0 : 30)
                        
                        // Hourly Forecast (Apple Weather style)
                        if !weatherViewModel.hourlyForecast.isEmpty {
                            HourlyForecastSection(forecast: weatherViewModel.hourlyForecast)
                                .padding(.top, 30)
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 30)
                        }
                        
                        // 10-Day Forecast (Apple Weather style)
                        if !weatherViewModel.forecast.isEmpty {
                            DailyForecastSection(forecast: weatherViewModel.forecast)
                                .padding(.top, 30)
                                .padding(.bottom, 30)
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 30)
                        }
                    } else if let error = weatherViewModel.errorMessage {
                        ErrorView(message: error) {
                            Task {
                                await weatherViewModel.refreshWeather()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 100)
                    } else {
                        EmptyStateView()
                            .padding(.horizontal, 20)
                            .padding(.top, 100)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .refreshable {
                await weatherViewModel.refreshWeather()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppColors.backgroundGradient, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appear = true
            }
            backgroundAnimation = true
        }
        .onChange(of: weatherViewModel.currentWeather) { oldValue, newValue in
            appear = false
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                appear = true
            }
        }
    }
}

// MARK: - Apple Weather Style Main View
struct AppleWeatherMainView: View {
    let weather: CurrentWeather
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @State private var iconScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 8) {
            // City Name
            Text(weather.cityName)
                .font(.system(size: 34, weight: .regular))
                .foregroundStyle(.white)
                .opacity(0.9)
            
            // Large Temperature (Apple Weather style)
            Text(weatherViewModel.formatTemperature(weather.temperature, unit: settingsViewModel.temperatureUnit))
                .font(.system(size: 96, weight: .thin))
                .foregroundStyle(.white)
                .padding(.top, 8)
            
            // Weather Condition
            Text(weather.description.capitalized)
                .font(.system(size: 28, weight: .regular))
                .foregroundStyle(.white)
                .opacity(0.9)
                .padding(.top, 8)
            
            // High/Low
            HStack(spacing: 16) {
                Text("H:\(weatherViewModel.formatTemperature(weather.high, unit: settingsViewModel.temperatureUnit))")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                    .opacity(0.9)
                
                Text("L:\(weatherViewModel.formatTemperature(weather.low, unit: settingsViewModel.temperatureUnit))")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                    .opacity(0.7)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Hourly Forecast Section (Apple Weather Style)
struct HourlyForecastSection: View {
    let forecast: [ForecastItem]
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hourly Forecast")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(Array(forecast.prefix(24).enumerated()), id: \.offset) { index, item in
                        HourlyForecastItem(item: item)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
        .background(.white.opacity(0.1))
        .background(.ultraThinMaterial.opacity(0.2))
    }
}

struct HourlyForecastItem: View {
    let item: ForecastItem
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    
    private var timeString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(item.dt))
        let formatter = DateFormatter()
        formatter.dateFormat = "ha"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text(timeString)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .opacity(0.8)
            
            AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(item.weather.first?.icon ?? "01d")@2x.png")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "cloud.sun.fill")
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(width: 40, height: 40)
            
            Text(weatherViewModel.formatTemperature(item.main.temp, unit: settingsViewModel.temperatureUnit))
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(.white)
        }
        .frame(width: 60)
    }
}

// MARK: - Daily Forecast Section (Apple Weather Style)
struct DailyForecastSection: View {
    let forecast: [ForecastDay]
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(forecast) { day in
                DailyForecastRow(day: day)
                    .padding(.horizontal, 20)
                
                if day.id != forecast.last?.id {
                    Divider()
                        .background(.white.opacity(0.2))
                        .padding(.horizontal, 20)
                }
            }
        }
        .padding(.vertical, 20)
        .background(.white.opacity(0.1))
        .background(.ultraThinMaterial.opacity(0.2))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

struct DailyForecastRow: View {
    let day: ForecastDay
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    
    private var dayName: String {
        let formatter = DateFormatter()
        let today = Calendar.current.startOfDay(for: Date())
        let dayDate = Calendar.current.startOfDay(for: day.date)
        
        if today == dayDate {
            return "Today"
        }
        formatter.dateFormat = "EEEE"
        return formatter.string(from: day.date)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Day Name
            Text(dayName)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 100, alignment: .leading)
            
            // Weather Icon
            AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(day.icon)@2x.png")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "cloud.sun.fill")
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(width: 32, height: 32)
            
            Spacer()
            
            // High/Low Temperatures
            HStack(spacing: 20) {
                Text(weatherViewModel.formatTemperature(day.high, unit: settingsViewModel.temperatureUnit))
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 50, alignment: .trailing)
                
                Text(weatherViewModel.formatTemperature(day.low, unit: settingsViewModel.temperatureUnit))
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white)
                    .opacity(0.6)
                    .frame(width: 50, alignment: .trailing)
            }
        }
        .padding(.vertical, 12)
    }
}

struct CurrentWeatherCard: View {
    let weather: CurrentWeather
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @State private var pulse: Bool = false
    @State private var rotation: Double = 0
    @State private var floatOffset: CGFloat = 0
    @State private var glowIntensity: Double = 0.5
    @State private var rainOffset: CGFloat = 0
    @State private var flashOpacity: Double = 0
    
    // Determine animation type based on weather condition
    private var animationType: WeatherAnimationType {
        let condition = weather.condition.lowercased()
        let icon = weather.icon
        
        if condition.contains("clear") || icon.contains("01") {
            return .sunny
        } else if condition.contains("rain") || icon.contains("09") || icon.contains("10") {
            return .rainy
        } else if condition.contains("snow") || icon.contains("13") {
            return .snowy
        } else if condition.contains("thunder") || icon.contains("11") {
            return .stormy
        } else if condition.contains("wind") || icon.contains("50") {
            return .windy
        } else {
            return .cloudy
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // City Name
            VStack(spacing: 6) {
                Text(weather.cityName)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color(red: 0.4, green: 0.6, blue: 1.0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                Text(weather.country)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            
            // Weather Icon with animations
            ZStack {
                // Background glow effect for sunny weather
                if animationType == .sunny {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.yellow.opacity(glowIntensity * 0.3),
                                    Color.orange.opacity(glowIntensity * 0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .blur(radius: 20)
                }
                
                // Rain particles for rainy weather
                if animationType == .rainy {
                    ForEach(0..<8, id: \.self) { index in
                        Rectangle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 2, height: 15)
                            .offset(x: CGFloat(index - 4) * 15, y: rainOffset + CGFloat(index) * 10)
                            .opacity(0.7)
                    }
                }
                
                // Snow particles for snowy weather
                if animationType == .snowy {
                    ForEach(0..<12, id: \.self) { index in
                        Circle()
                            .fill(Color.white.opacity(0.8))
                            .frame(width: 4, height: 4)
                            .offset(
                                x: CGFloat(index - 6) * 20 + sin(rainOffset * 0.1) * 10,
                                y: rainOffset + CGFloat(index) * 8
                            )
                    }
                }
                
                // Weather Icon
                AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(weather.icon)@2x.png")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Image(systemName: weatherIconName)
                        .font(.system(size: 80))
                        .foregroundStyle(AppColors.accentGradient)
                }
                .frame(width: 130, height: 130)
                .scaleEffect(pulse ? 1.05 : 1.0)
                .rotationEffect(.degrees(rotation))
                .offset(y: floatOffset)
                .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: 10)
                .opacity(flashOpacity > 0 ? 1.0 : 0.9)
            }
            .frame(width: 160, height: 160)
            
            // Temperature with subtle animation
            Text(weatherViewModel.formatTemperature(weather.temperature, unit: settingsViewModel.temperatureUnit))
                .font(.system(size: 76, weight: .thin))
                .foregroundStyle(
                    LinearGradient(
                        colors: temperatureGradientColors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .scaleEffect(pulse ? 1.02 : 1.0)
                .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: pulse)
            
            // Condition
            Text(weather.description.capitalized)
                .font(.system(size: 21, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
                .textCase(.none)
            
            // High/Low
            HStack(spacing: 24) {
                VStack(spacing: 4) {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.8))
                    Text(weatherViewModel.formatTemperature(weather.high, unit: settingsViewModel.temperatureUnit))
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.white)
                }
                
                VStack(spacing: 4) {
                    Image(systemName: "arrow.down")
                        .font(.system(size: 14))
                        .foregroundStyle(.white.opacity(0.8))
                    Text(weatherViewModel.formatTemperature(weather.low, unit: settingsViewModel.temperatureUnit))
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .padding(.vertical, 8)
            
            // Humidity
            HStack(spacing: 10) {
                Image(systemName: "humidity")
                    .font(.system(size: 17))
                Text("\(weather.humidity)%")
                    .font(.system(size: 17, weight: .medium))
            }
            .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 28)
        .glassEffect()
        .onAppear {
            startWeatherAnimations()
        }
    }
    
    // Helper properties for animations
    private var weatherIconName: String {
        switch animationType {
        case .sunny: return "sun.max.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "cloud.snow.fill"
        case .stormy: return "cloud.bolt.fill"
        case .windy: return "wind"
        case .cloudy: return "cloud.fill"
        }
    }
    
    private var shadowColor: Color {
        switch animationType {
        case .sunny: return .yellow.opacity(0.4)
        case .rainy: return .blue.opacity(0.3)
        case .snowy: return .white.opacity(0.4)
        case .stormy: return .purple.opacity(0.4)
        case .windy: return .gray.opacity(0.3)
        case .cloudy: return .blue.opacity(0.3)
        }
    }
    
    private var shadowRadius: CGFloat {
        switch animationType {
        case .sunny: return 25
        case .stormy: return 30
        default: return 20
        }
    }
    
    private var temperatureGradientColors: [Color] {
        switch animationType {
        case .sunny:
            return [.white, Color.yellow.opacity(0.8), Color.orange.opacity(0.6)]
        case .rainy:
            return [.white, Color.blue.opacity(0.8), Color.cyan.opacity(0.6)]
        case .snowy:
            return [.white, Color.white.opacity(0.9), Color.blue.opacity(0.7)]
        case .stormy:
            return [.white, Color.purple.opacity(0.8), Color.blue.opacity(0.6)]
        case .windy:
            return [.white, Color.gray.opacity(0.8), Color.blue.opacity(0.6)]
        case .cloudy:
            return [.white, Color(red: 0.4, green: 0.6, blue: 1.0), Color.blue.opacity(0.7)]
        }
    }
    
    // Start weather-specific animations
    private func startWeatherAnimations() {
        // Base pulse animation for all weather types
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            pulse = true
        }
        
        switch animationType {
        case .sunny:
            // Rotating sun with glow
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                glowIntensity = 1.0
            }
            
        case .rainy:
            // Falling rain
            rainOffset = -50
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                rainOffset = 100
            }
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                floatOffset = 3
            }
            
        case .snowy:
            // Falling snow
            rainOffset = -50
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rainOffset = 150
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                floatOffset = 5
            }
            
        case .stormy:
            // Flashing lightning
            withAnimation(.easeInOut(duration: 0.1).repeatForever(autoreverses: true)) {
                flashOpacity = 1.0
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                floatOffset = 4
            }
            
        case .windy:
            // Swaying motion
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                rotation = 15
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                floatOffset = 6
            }
            
        case .cloudy:
            // Gentle floating
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                floatOffset = 8
            }
        }
    }
}

// Weather animation types
enum WeatherAnimationType {
    case sunny
    case rainy
    case snowy
    case stormy
    case windy
    case cloudy
}

struct ForecastSection: View {
    let forecast: [ForecastDay]
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("5-Day Forecast")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 4)
                .padding(.bottom, 4)
            
            VStack(spacing: 12) {
                ForEach(forecast) { day in
                    ForecastRow(day: day)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .glassEffect()
    }
}

struct ForecastRow: View {
    let day: ForecastDay
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @State private var iconPulse: Bool = false
    
    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let today = Calendar.current.startOfDay(for: Date())
        let dayDate = Calendar.current.startOfDay(for: day.date)
        
        if today == dayDate {
            return "Today"
        }
        return formatter.string(from: day.date)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Day
            Text(dayName)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 100, alignment: .leading)
            
            // Icon with animation
            AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(day.icon)@1x.png")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .frame(width: 44, height: 44)
            .scaleEffect(iconPulse ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: iconPulse)
            
            Spacer()
            
            // High/Low
            HStack(spacing: 16) {
                Text(weatherViewModel.formatTemperature(day.high, unit: settingsViewModel.temperatureUnit))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .frame(minWidth: 50, alignment: .trailing)
                
                Text(weatherViewModel.formatTemperature(day.low, unit: settingsViewModel.temperatureUnit))
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                    .frame(minWidth: 50, alignment: .trailing)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(.white.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
        .onAppear {
            iconPulse = true
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.sun")
                .font(.system(size: 60))
                .foregroundStyle(.white.opacity(0.6))
            
            Text("No City Selected")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
            
            Text("Search and add a city to see weather")
                .font(.system(size: 16))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(40)
        .glassEffect()
        .padding(.horizontal, 30)
    }
}

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundStyle(.red.opacity(0.8))
            
            Text("Error")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
            
            Text(message)
                .font(.system(size: 14))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Retry", action: retryAction)
                .buttonStyle(GlassButtonStyle())
                .padding(.top, 8)
        }
        .padding(40)
        .glassEffect()
        .padding(.horizontal, 30)
    }
}
