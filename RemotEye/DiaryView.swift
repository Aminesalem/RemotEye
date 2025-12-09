//
//  DiaryView.swift
//  RemotEye
//
//  Created by AFP PAR 29 on 09/12/25.
//

import SwiftUI

struct DiaryView: View {
    @EnvironmentObject var appState: AppState

    var visitedLandmarks: [Landmark] {
        appState.landmarks.filter { appState.isVisited($0.id) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if visitedLandmarks.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "book.closed.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)

                            Text("No places visited yet")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.secondary)

                            Text("Visit locations on the map to unlock their stories.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 120)
                    } else {
                        ForEach(visitedLandmarks) { lm in
                            NavigationLink {
                                LandmarkDetailView(landmark: lm)
                            } label: {
                                diaryCard(for: lm)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            .navigationTitle("Diary")
        }
    }

    // MARK: - Card UI
    private func diaryCard(for landmark: Landmark) -> some View {
        HStack(spacing: 16) {
            Image(landmark.mainImageName)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 80)
                .clipped()
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 6) {
                Text(landmark.name)
                    .font(.headline)

                Text("Visited")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if let year = landmark.historicalYear {
                    Text(year)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 3)
    }
}
