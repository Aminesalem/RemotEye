import SwiftUI

struct DiscoveryView: View {
    let landmark: Landmark
    let onClose: () -> Void

    // Screenshot-locked metrics
    private let horizontalInset: CGFloat = 32
    private let titleTopSpacing: CGFloat = 100
    private let spaceBelowDiscovered: CGFloat = 16
    private let spaceBelowTitle: CGFloat = 8
    private let spaceBelowYear: CGFloat = 24
    private let spaceBelowCard: CGFloat = 32
    private let spaceAboveButton: CGFloat = 60
    private let buttonBottomInset: CGFloat = 30

    // Card metrics derived from screen width
    private var cardWidth: CGFloat {
        UIScreen.main.bounds.width - (horizontalInset * 2)
    }
    // Adjust 0.62 slightly (0.60–0.65) if you want a taller/shorter card
    private var cardHeight: CGFloat {
        cardWidth * 0.62
    }
    private let cardCornerRadius: CGFloat = 22

    var body: some View {
        ZStack {
            // Background fills screen
            backgroundImage
                .ignoresSafeArea()

            // Bottom gradient for description readability
            VStack { Spacer() }
                .background(
                    LinearGradient(
                        colors: [.black.opacity(0.0), .black.opacity(0.8)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )

            // All spacing is controlled explicitly to match the screenshot
            VStack(spacing: 0) {
                Spacer().frame(height: titleTopSpacing)

                Text("New place discovered")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.yellow)
                    .padding(.bottom, spaceBelowDiscovered)

                Text(landmark.name)
                    .font(.system(size: 34, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal, horizontalInset)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .padding(.bottom, spaceBelowTitle)

                if let year = landmark.historicalYear {
                    Text(year)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.bottom, spaceBelowYear)
                }

                // Foreground card: fixed size, image fills container (cropped as needed)
                foregroundCard
                    .frame(width: cardWidth, height: cardHeight)
                    .padding(.horizontal, horizontalInset)
                    .padding(.bottom, spaceBelowCard)

                // Description constrained to the same width as the card
                Text(landmark.description)
                    .font(.body)
                    .foregroundColor(.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .frame(width: cardWidth) // match card width exactly
                    .padding(.horizontal, horizontalInset) // keeps alignment with edges
                    .padding(.top, 120) // guaranteed gap under the card
                    .padding(.bottom, spaceAboveButton)

                Spacer()

                // Button constrained to the same width as the card
                Button(action: onClose) {
                    Text("Continue")
                        .font(.headline.weight(.semibold))
                        .frame(width: cardWidth) // match card width exactly
                        .padding(.vertical, 16)
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal, horizontalInset)
                .padding(.bottom, buttonBottomInset)
            }
        }
    }

    // MARK: - Background

    private var backgroundImage: some View {
        Group {
            if let uiImage = UIImage(named: landmark.mainImageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .overlay(
                        LinearGradient(
                            colors: [.black.opacity(0.20), .black.opacity(0.60)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            } else {
                LinearGradient(
                    colors: [Color.black.opacity(0.6), Color.black],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
    }

    // MARK: - Foreground Card

    private var foregroundCard: some View {
        Group {
            if let uiImage = UIImage(named: landmark.mainImageName) {
                // Image fills the fixed container; corners are clipped by the card shape
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill() // fill the container; crop as needed
                    .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: cardCornerRadius)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 10, y: 6)
            } else {
                RoundedRectangle(cornerRadius: cardCornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [Color.gray.opacity(0.35), Color.gray.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cardCornerRadius)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.5), radius: 10, y: 6)
            }
        }
    }
}
