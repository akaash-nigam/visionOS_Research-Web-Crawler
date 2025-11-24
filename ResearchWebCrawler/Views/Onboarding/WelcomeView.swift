//
//  WelcomeView.swift
//  Research Web Crawler
//
//  Welcome screen shown on first launch
//

import SwiftUI

struct WelcomeView: View {
    let onComplete: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App icon/logo placeholder
            Image(systemName: "brain.head.profile")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)

            // Title
            VStack(spacing: 12) {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundStyle(.secondary)

                Text("Research Web Crawler")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }

            // Subtitle
            Text("Build your research in 3D space. Connect ideas with gestures. Discover relationships you never noticed.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)

            Spacer()

            // Action buttons
            VStack(spacing: 16) {
                Button(action: onComplete) {
                    Text("Start Tutorial")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                Button(action: onSkip) {
                    Text("Skip")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    WelcomeView(
        onComplete: {},
        onSkip: {}
    )
}
