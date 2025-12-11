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
                    contentCard
                        .offset(y: -40)
                        .padding(.bottom, -40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
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
        ZStack(alignment: .bottomLeading) {
            headerImage
                .frame(height: 320)
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
                        Text("Take Photo to Unlock")
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
                    Text("Last photo taken")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 180)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.top, 4)
            }

            if !landmark.gallery.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Historical Gallery")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(landmark.gallery, id: \.self) { name in
                                galleryImage(named: name)
                                    .frame(width: 240, height: 150)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
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

    private func galleryImage(named: String) -> some View {
        if let uiImage = UIImage(named: named) {
            return Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .eraseToAnyView()
        } else {
            return Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .padding(24)
                .foregroundColor(.secondary)
                .background(Color.gray.opacity(0.15))
                .eraseToAnyView()
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

        if distance > 3000 {
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
