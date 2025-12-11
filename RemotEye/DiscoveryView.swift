//
//  DiscoveryView.swift
//  RemotEye
//
//  Created by AFP PAR 29 on 09/12/25.
//

import SwiftUI

struct DiscoveryView: View {
    let landmark: Landmark
    let onClose: () -> Void

    var body: some View {
        ZStack {
            // Background image + blur
            if let uiImage = UIImage(named: landmark.mainImageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                    .blur(radius: 20)
            } else {
                Color.black.ignoresSafeArea()
            }

            LinearGradient(
                colors: [.black.opacity(0.5), .black.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("New place discovered")
                    .font(.subheadline)
                    .foregroundColor(.yellow)

                Text(landmark.name)
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal)

                if let year = landmark.historicalYear {
                    Text(year)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }

                // Foreground card with main image
                if let uiImage = UIImage(named: landmark.mainImageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(radius: 10, y: 6)
                        .padding(.horizontal, 32)
                }

                Text(landmark.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer()

                Button(action: onClose) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
        }
    }
}
