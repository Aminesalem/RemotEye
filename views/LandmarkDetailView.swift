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

    // MARK: - Dynamic titles and content

    private var overviewTitle: String {
        isVisited ? "Overview (Unlocked)" : "Overview (Locked)"
    }

    private var overviewBody: String {
        if isVisited, let pieces = unlockedPieces {
            return pieces.overview
        } else {
            return landmark.description
        }
    }

    private var funFactsText: String? {
        guard isVisited, let pieces = unlockedPieces else { return nil }
        let trimmed = pieces.funFacts?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? nil : trimmed
    }

    // Split unlocked text into overview + fun facts using known delimiters.
    private var unlockedPieces: (overview: String, funFacts: String?)? {
        guard let raw = Landmark.unlockedOverviewByID[landmark.id] else { return nil }
        return splitUnlockedText(raw)
    }

    private func splitUnlockedText(_ raw: String) -> (overview: String, funFacts: String?) {
        // Support several possible headings, case-insensitive.
        let tokens = ["Additions:", "Fun fact:", "Fun Fact:"]
        var bestRange: Range<String.Index>? = nil

        for token in tokens {
            if let r = raw.range(of: token, options: [.caseInsensitive]) {
                if bestRange == nil || r.lowerBound < bestRange!.lowerBound {
                    bestRange = r
                }
            }
        }

        if let r = bestRange {
            let overview = String(raw[..<r.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            let fun = String(raw[r.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            return (overview, fun.isEmpty ? nil : fun)
        } else {
            // No delimiter found → everything is overview.
            return (raw.trimmingCharacters(in: .whitespacesAndNewlines), nil)
        }
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
        .onAppear {
            // Load persisted photo if any
            if lastPhoto == nil, let saved = appState.loadLastPhoto(for: landmark.id) {
                lastPhoto = saved
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraCaptureView { image in
                self.lastPhoto = image
                appState.saveLastPhoto(image, for: landmark.id) // persist compressed photo
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

            Text(overviewTitle)
                .font(.headline)

            Text(overviewBody)
                .font(.body)
                .foregroundColor(.primary)

            if let ff = funFactsText {
                Text("Fun Fact")
                    .font(.headline)
                    .padding(.top, 8)

                Text(ff)
                    .font(.body)
                    .foregroundColor(.primary)
            }

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
                    Text("You have unlocked this place. great job!")
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

            // Historical Gallery (unchanged from your last working version)
            if !landmark.gallery.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Historical Gallery")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(Array(landmark.gallery.enumerated()), id: \.1) { index, name in
                                if isVisited {
                                    Button {
                                        selectedIndex = index
                                        isShowingGallery = true
                                    } label: {
                                        galleryImage(named: name)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 240, height: 150)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 14))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    .contentShape(Rectangle())
                                } else {
                                    ZStack {
                                        galleryImage(named: name)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 240, height: 150)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 14))

                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.black.opacity(0.9))
                                            .blur(radius: 38)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14)
                                                    .stroke(Color.white.opacity(0.30), lineWidth: 1)
                                            )
                                            .clipShape(RoundedRectangle(cornerRadius: 14))

                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.black.opacity(0.08))
                                            .blur(radius: 10)

                                        VStack(spacing: 6) {
                                            Image(systemName: "lock.fill")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text("Unlock to view")
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.95))
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .allowsHitTesting(false)
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

        if distance > 30 {
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
