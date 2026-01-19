//
//  AnimatedBackground.swift
//  Glasscast - A Minimal Weather App
//
//  Created with AI assistance using Claude Code
//

import SwiftUI

struct AnimatedBackground: View {
    @State private var gradientRotation: Double = 0
    @State private var particleOffset1: CGFloat = 0
    @State private var particleOffset2: CGFloat = 0
    @State private var particleOffset3: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Base gradient
            AppColors.backgroundGradient
                .ignoresSafeArea()
            
            // Animated gradient overlay
            LinearGradient(
                colors: [
                    Color(red: 0.3, green: 0.5, blue: 0.9).opacity(0.1),
                    Color(red: 0.5, green: 0.3, blue: 0.8).opacity(0.1),
                    Color.clear
                ],
                startPoint: UnitPoint(
                    x: 0.5 + 0.3 * cos(gradientRotation * .pi / 180),
                    y: 0.5 + 0.3 * sin(gradientRotation * .pi / 180)
                ),
                endPoint: UnitPoint(
                    x: 0.5 - 0.3 * cos(gradientRotation * .pi / 180),
                    y: 0.5 - 0.3 * sin(gradientRotation * .pi / 180)
                )
            )
            .ignoresSafeArea()
            .blur(radius: 60)
            
            // Floating particles/circles
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.2),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .offset(
                        x: CGFloat(index) * 80 - 160 + particleOffset1,
                        y: CGFloat(index) * 60 - 120 + particleOffset2
                    )
                    .blur(radius: 30)
            }
            
            // Additional animated circles
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                    .offset(
                        x: CGFloat(index) * 120 - 120 + particleOffset3,
                        y: CGFloat(index) * 80 - 80 - particleOffset1
                    )
                    .blur(radius: 40)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            // Start background animations
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: true)) {
                gradientRotation = 360
            }
            
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                particleOffset1 = 50
            }
            
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                particleOffset2 = -40
            }
            
            withAnimation(.easeInOut(duration: 12).repeatForever(autoreverses: true)) {
                particleOffset3 = 60
            }
        }
    }
}
