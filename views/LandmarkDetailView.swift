import SwiftUI
import MapKit

struct LandmarkDetailView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss

    let landmark: Landmark

    @State private var showCamera = false
    @State private var lastPhoto: UIImage? = nil
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showDiscovery = false

    var isVisited: Bool {
        appState.isVisited(landmark.id)
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .clipped()
                    contentCard
                        .offset(y: -40)
                        .padding(.bottom, -40)
                }
            }
        }
        .navigationTitle(landmark.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraCaptureView { image in
                self.lastPhoto = image
                appState.markVisited(landmark.id)
                showDiscovery = true
            }
        }
        .fullScreenCover(isPresented: $showDiscovery) {
            DiscoveryView(landmark: landmark) {
                showDiscovery = false
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Unlock Info"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - HEADER

    private var headerSection: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomLeading) {
                headerImage
                    .frame(width: geometry.size.width, height: 320)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.black.opacity(0.0), .black.opacity(0.55)],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    )

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: isVisited ? "checkmark.seal.fill" : "lock.fill")
                        Text(isVisited ? "Unlocked" : "Locked")
                            .font(.subheadline.weight(.semibold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        (isVisited ? Color.green.opacity(0.9) : Color.red.opacity(0.9))
                            .clipShape(Capsule())
                    )
                    .foregroundColor(.white)

                    Text(landmark.name)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)

                    if let year = landmark.historicalYear {
                        Text(year)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 22)
            }
            .frame(width: geometry.size.width, height: 320)
        }
        .frame(height: 320)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var headerImage: some View {
        if let uiImage = UIImage(named: landmark.mainImageName) {
            return Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .eraseToAnyView()
        } else {
            return Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .padding(40)
                .foregroundColor(.secondary)
                .background(Color.gray.opacity(0.15))
                .eraseToAnyView()
        }
    }

    // MARK: - CONTENT CARD

    private var contentCard: some View {
        VStack(alignment: .leading, spacing: 18) {

            Text("Overview")
                .font(.headline)

            Text(landmark.description)
                .font(.body)
                .foregroundColor(.primary)

            if !isVisited {
                Button(action: attemptUnlock) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("capture the monument to Unlock it")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(radius: 4, y: 2)
                }
                .padding(.top, 4)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("You’ve already unlocked this place.")
                }
                .font(.subheadline)
                .foregroundColor(.green)
            }

            if let photo = lastPhoto {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Photo")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.top, 4)
            }

            // Historical Gallery: fully blurred/dimmed when locked
            if !landmark.gallery.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Historical Gallery")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(landmark.gallery, id: \.self) { name in
                                ZStack {
                                    galleryImage(named: name)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 240, height: 150)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 14))

                                    if !isVisited {
                                        // Stronger lock overlay: more dim + more blur
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.black.opacity(0.35))
                                            .blur(radius: 4)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                            )

                                        VStack(spacing: 6) {
                                            Image(systemName: "lock.fill")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text("Unlock to view")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.95))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }

        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal)
        .padding(.top, 16)
    }

    private func galleryImage(named: String) -> Image {
        if let uiImage = UIImage(named: named) {
            return Image(uiImage: uiImage)
        } else {
            return Image(systemName: "photo")
        }
    }

    // MARK: - Unlock Logic

    private func attemptUnlock() {
        guard let userLocation = appState.userLocation else {
            alertMessage = "Location unavailable."
            showAlert = true
            return
        }

        let targetLocation = CLLocation(latitude: landmark.latitude,
                                         longitude: landmark.longitude)
        let distance = userLocation.distance(from: targetLocation)

        print("Distance to \(landmark.name): \(distance) m")

        if distance > 30000 {
            alertMessage = "You must be within 30 meters of this monument to unlock it."
            showAlert = true
        } else {
            showCamera = true
        }
    }
}

// MARK: - Helper

private extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}
