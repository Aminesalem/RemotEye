import SwiftUI
import CoreLocation

enum MainTab {
    case map
    case camera
    case diary
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    @State private var selectedLandmark: Landmark? = nil
    @State private var isShowingDetail: Bool = false

    @State private var selectedTab: MainTab = .map
    @State private var searchText: String = ""
    @State private var showStandaloneCamera = false
    @State private var showingDiary = false
    @State private var showingProfile = false

    // MARK: - Filtered landmarks for search
    private var filteredLandmarks: [Landmark] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return appState.landmarks
        }
        let q = trimmed.lowercased()
        return appState.landmarks.filter { $0.name.lowercased().contains(q) }
    }

    // MARK: - Nearest landmark info (prefer locked first)
    private var nearestInfo: (landmark: Landmark, distance: CLLocationDistance, bearing: Double)? {
        guard
            let userLoc = appState.userLocation,
            !appState.landmarks.isEmpty
        else { return nil }

        // Split into locked and all
        let locked = appState.landmarks.filter { !appState.isVisited($0.id) }
        let pool = locked.isEmpty ? appState.landmarks : locked

        var best: (Landmark, CLLocationDistance, Double)? = nil

        for lm in pool {
            let targetLocation = CLLocation(latitude: lm.latitude, longitude: lm.longitude)
            let dist = userLoc.distance(from: targetLocation)
            let bearing = bearingBetween(user: userLoc, target: targetLocation)

            if best == nil || dist < best!.1 {
                best = (lm, dist, bearing)
            }
        }

        return best
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // MAP BACKGROUND (now accepts filtered landmarks)
                MapView(landmarksToShow: filteredLandmarks)
                    .ignoresSafeArea()

                // UI OVERLAYS
                VStack(spacing: 12) {
                    topBar
                        .padding(.horizontal)
                        .padding(.top, 16)

                    if let info = nearestInfo {
                        nearestBanner(info: info)
                            .onTapGesture {
                                NotificationCenter.default.post(
                                    name: .centerOnLandmark,
                                    object: info.landmark.id
                                )
                            }
                            .padding(.horizontal)
                    }

                    Spacer()

                    bottomTabBar
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                }
                .ignoresSafeArea(edges: [.bottom])
            }
            .navigationBarHidden(true)
            .onAppear {
                appState.loadLandmarks()
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: Notification.Name("LandmarkSelected")
                )
            ) { notif in
                if let name = notif.object as? String,
                   let lm = appState.landmarks.first(where: { $0.name == name }) {
                    selectedLandmark = lm
                    isShowingDetail = true
                }
            }
            .sheet(isPresented: $showingDiary, onDismiss: {
                selectedTab = .map
            }) {
                DiaryView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
                    .environmentObject(appState)
            }
            .navigationDestination(isPresented: $isShowingDetail) {
                if let lm = selectedLandmark {
                    LandmarkDetailView(landmark: lm)
                } else {
                    EmptyView()
                }
            }
        }
    }

    // MARK: - TOP SEARCH + PROFILE
    private var topBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Cerca luoghi storici...", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(radius: 4, y: 2)

            Button {
                showingProfile = true
            } label: {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.primary)
            }
            .padding(6)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .shadow(radius: 4, y: 2)
        }
    }

    // MARK: - NEAREST BANNER (distance + compass)

    private func nearestBanner(info: (landmark: Landmark, distance: CLLocationDistance, bearing: Double)) -> some View {
        let landmark = info.landmark
        let dist = info.distance
        let bearing = info.bearing

        let distanceText: String
        if dist < 100 {
            distanceText = String(format: "%.0f m", dist)
        } else if dist < 1000 {
            distanceText = String(format: "%.0f m", dist)
        } else {
            distanceText = String(format: "%.1f km", dist / 1000.0)
        }

        return HStack(spacing: 12) {
            // compass-like arrow
            Image(systemName: "location.north.fill")
                .font(.system(size: 20, weight: .bold))
                .rotationEffect(Angle(degrees: bearing))
                .frame(width: 32, height: 32)
                .foregroundColor(.yellow)
                .padding(6)
                .background(.ultraThinMaterial)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Nearest place")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(landmark.name)
                    .font(.headline)

                Text(distanceText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(radius: 4, y: 2)
    }

    // MARK: - BOTTOM TAB BAR

    private var bottomTabBar: some View {
        HStack(spacing: 24) {
            tabButton(
                tab: .map,
                systemImage: "map.fill",
                title: "Map"
            )
            tabButton(
                tab: .diary,
                systemImage: "book.closed.fill",
                title: "Diary"
            )
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 18)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(radius: 8, y: 4)
    }

    private func tabButton(tab: MainTab,
                           systemImage: String,
                           title: String) -> some View {
        let isSelected = (tab == selectedTab)

        return Button {
            selectedTab = tab
            if tab == .diary {
                showingDiary = true
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .primary : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .padding(.horizontal, 4)
            .background(
                isSelected
                ? Color.white.opacity(0.2)
                : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Bearing helper

    private func bearingBetween(user: CLLocation, target: CLLocation) -> Double {
        let lat1 = user.coordinate.latitude * .pi / 180
        let lon1 = user.coordinate.longitude * .pi / 180
        let lat2 = target.coordinate.latitude * .pi / 180
        let lon2 = target.coordinate.longitude * .pi / 180

        let dLon = lon2 - lon1
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        var bearing = atan2(y, x) * 180 / .pi
        bearing = fmod((bearing + 360), 360)
        return bearing
    }
}
