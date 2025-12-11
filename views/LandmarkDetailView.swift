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

    // Gallery viewer state
    @State private var isShowingGallery = false
    @State private var selectedIndex = 0

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
        // Full-screen gallery viewer
        .fullScreenCover(isPresented: $isShowingGallery) {
            GalleryFullScreenView(
                images: landmark.gallery,
                selectedIndex: $selectedIndex
            )
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

            // Historical Gallery: strongly blurred/dimmed when locked; tappable when unlocked
            if !landmark.gallery.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Historical Gallery")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(Array(landmark.gallery.enumerated()), id: \.1) { index, name in
                                ZStack {
                                    galleryImage(named: name)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 240, height: 150)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 14))

                                    if !isVisited {
                                        // Much stronger lock overlay: heavy dim + heavy blur + thicker stroke
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.black.opacity(0.6))
                                            .blur(radius: 14)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Color.white.opacity(0.28), lineWidth: 1)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 14))
                                            // Second subtle blur pass to remove residual detail
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .fill(Color.black.opacity(0.05))
                                                    .blur(radius: 8)
                                            )

                                        VStack(spacing: 6) {
                                            Image(systemName: "lock.fill")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text("Unlock to view")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.95))
                                        }
                                    } else {
                                        // Unlocked: make tappable to open full-screen viewer
                                        Button {
                                            selectedIndex = index
                                            isShowingGallery = true
                                        } label: {
                                            Color.clear
                                        }
                                        .buttonStyle(.plain)
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

// MARK: - Full-screen gallery viewer

private struct GalleryFullScreenView: View {
    let images: [String]
    @Binding var selectedIndex: Int
    @Environment(\.dismiss) private var dismiss

    @State private var pageIndex: Int = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            TabView(selection: $pageIndex) {
                ForEach(Array(images.enumerated()), id: \.1) { i, name in
                    Group {
                        if let uiImage = UIImage(named: name) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .tag(i)
                                .background(Color.black)
                                .ignoresSafeArea()
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.secondary)
                                .padding(40)
                                .tag(i)
                                .background(Color.black)
                                .ignoresSafeArea()
                        }
                    }
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .automatic))
            .onAppear {
                pageIndex = min(max(0, selectedIndex), max(0, images.count - 1))
            }

            VStack {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                            .padding(12)
                    }
                }
                Spacer()
            }
        }
    }
}

// MARK: - Helper

private extension View {
    func eraseToAnyView() -> AnyView { AnyView(self) }
}
