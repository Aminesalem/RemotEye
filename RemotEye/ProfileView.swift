import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @AppStorage("profileImageData") private var profileImageData: Data?
    @State private var showImagePicker = false
    @State private var selectedItem: PhotosPickerItem?
    @State private var showRemoveConfirm = false

    private var profileImage: Image {
        if
            let data = profileImageData,
            let ui = UIImage(data: data)
        {
            return Image(uiImage: ui)
        } else {
            return Image(systemName: "person.crop.circle.fill")
        }
    }

    // Only count visited IDs that exist in the current landmarks set
    private var validVisitedCount: Int {
        let validIDs = Set(appState.landmarks.map { $0.id })
        return appState.visitedIDs.intersection(validIDs).count
    }

    private var progressText: String {
        let visited = validVisitedCount
        let total = appState.landmarks.count
        return "\(visited) of \(total) places unlocked"
    }

    private var progressFraction: Double {
        let visited = Double(validVisitedCount)
        let total = Double(max(appState.landmarks.count, 1))
        return visited / total
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile image
                    VStack(spacing: 12) {
                        profileImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(radius: 4, y: 2)

                        HStack(spacing: 12) {
                            PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                Text("Change Photo")
                                    .font(.subheadline.bold())
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.15))
                                    .foregroundColor(.blue)
                                    .clipShape(Capsule())
                            }

                            if profileImageData != nil {
                                Button(role: .destructive) {
                                    showRemoveConfirm = true
                                } label: {
                                    Text("Remove")
                                        .font(.subheadline.bold())
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.red.opacity(0.12))
                                        .foregroundColor(.red)
                                        .clipShape(Capsule())
                                }
                                .confirmationDialog("Remove profile photo?",
                                                    isPresented: $showRemoveConfirm,
                                                    titleVisibility: .visible) {
                                    Button("Remove Photo", role: .destructive) {
                                        profileImageData = nil
                                    }
                                    Button("Cancel", role: .cancel) { }
                                }
                            }
                        }
                    }
                    .padding(.top, 24)

                    // Progress
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Progress")
                            .font(.headline)

                        ProgressView(value: progressFraction)
                            .tint(.yellow)
                            .frame(maxWidth: .infinity)

                        Text(progressText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Stats
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "map")
                            Text("Total places: \(appState.landmarks.count)")
                            Spacer()
                        }
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                            Text("Unlocked: \(validVisitedCount)")
                            Spacer()
                        }
                        HStack {
                            Image(systemName: "lock.fill")
                            let locked = max(appState.landmarks.count - validVisitedCount, 0)
                            Text("Locked: \(locked)")
                            Spacer()
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Actions
                    VStack(spacing: 12) {
                        Button(role: .destructive) {
                            appState.resetVisited()
                        } label: {
                            Text("Reset Progress")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)

                        Text("No account required. Your data stays on this device.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                    .padding(.top, 8)

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: selectedItem) { _, newValue in
            guard let newValue else { return }
            Task {
                if let data = try? await newValue.loadTransferable(type: Data.self) {
                    profileImageData = data
                }
            }
        }
    }
}
