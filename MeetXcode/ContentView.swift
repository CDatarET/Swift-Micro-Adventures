//
//  ContentView.swift
//  MeetXcode
//
//  Created by CDatarET on 01/09/26.
//

import SwiftUI
import MapKit

// MARK: - Adventure Model
struct Adventure: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let category: String
    let effortLevel: String
    let locationName: String
    let coordinate: CLLocationCoordinate2D
    var isCompleted: Bool = false
}

struct ContentView: View {
    // Filter options
    private let allCategories: [String] = ["Nature", "Urban", "Water", "Hike", "Food", "Culture"]
    private let allEffortLevels: [String] = ["Easy", "Moderate", "Challenging"]

    // Sample adventures in San Francisco
    @State private var adventures: [Adventure] = [
        Adventure(
            title: "Golden Gate Sunrise Walk",
            description: "Catch the sunrise from Battery Spencer and look over the bridge.",
            category: "Nature",
            effortLevel: "Easy",
            locationName: "Battery Spencer",
            coordinate: CLLocationCoordinate2D(latitude: 37.8291, longitude: -122.4800)
        ),
        Adventure(
            title: "Twin Peaks Urban Hike",
            description: "Climb to the city's geographic center for panoramic 360-degree views.",
            category: "Hike",
            effortLevel: "Moderate",
            locationName: "Twin Peaks",
            coordinate: CLLocationCoordinate2D(latitude: 37.7544, longitude: -122.4477)
        ),
        Adventure(
            title: "Ferry Building Food Crawl",
            description: "Sample artisan cheeses, fresh pastries, and local coffee stalls.",
            category: "Food",
            effortLevel: "Easy",
            locationName: "San Francisco Ferry Building",
            coordinate: CLLocationCoordinate2D(latitude: 37.7955, longitude: -122.3937)
        ),
        Adventure(
            title: "Mission District Mural Tour",
            description: "Explore vibrant alleyways filled with rich Latino history and culture.",
            category: "Culture",
            effortLevel: "Easy",
            locationName: "Balmy Alley",
            coordinate: CLLocationCoordinate2D(latitude: 37.7538, longitude: -122.4137)
        ),
        Adventure(
            title: "Embarcadero Waterfront Stroll",
            description: "Walk along the breezy piers from Oracle Park to Fisherman's Wharf.",
            category: "Water",
            effortLevel: "Easy",
            locationName: "The Embarcadero",
            coordinate: CLLocationCoordinate2D(latitude: 37.8080, longitude: -122.4101)
        ),
        Adventure(
            title: "Mount Davidson Trail Trek",
            description: "Hike through a dense eucalyptus forest up to the highest point in SF.",
            category: "Hike",
            effortLevel: "Challenging",
            locationName: "Mount Davidson",
            coordinate: CLLocationCoordinate2D(latitude: 37.7391, longitude: -122.4542)
        )
    ]

    // Initial camera position centered on SF
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
        )
    )

    // Selected filters
    @State private var selectedCategories: Set<String> = []
    @State private var selectedEfforts: Set<String> = []
    @State private var showingFilters = false

    // Index tracking for the currently highlighted adventure
    @State private var currentAdventureIndex: Int = 0

    init() {
        _selectedCategories = State(initialValue: Set(allCategories))
        _selectedEfforts = State(initialValue: Set(allEffortLevels))
    }

    // Filtered list based on user selections
    var filteredAdventures: [Adventure] {
        adventures.filter { adventure in
            selectedCategories.contains(adventure.category) &&
            selectedEfforts.contains(adventure.effortLevel)
        }
    }

    // Safely get the current adventure being displayed in the card
    var currentAdventure: Adventure? {
        guard !filteredAdventures.isEmpty else { return nil }
        let safeIndex = currentAdventureIndex % filteredAdventures.count
        return filteredAdventures[safeIndex]
    }

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                // Loop through all filtered adventures and show markers
                ForEach(filteredAdventures) { adventure in
                    Marker(adventure.title, coordinate: adventure.coordinate)
                        .tint(adventure.isCompleted ? .green : .blue)
                }
            }
            .mapStyle(.standard)
            .ignoresSafeArea()
            .navigationTitle("Micro Adventures")
            .navigationBarTitleDisplayMode(.large)
            // Compact floating info card overlay near the top
            .overlay(alignment: .top) {
                if let adventure = currentAdventure {
                    VStack {
                        Spacer().frame(height: 110)
                        HStack(alignment: .center, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                // Pills row
                                HStack(spacing: 6) {
                                    Text(adventure.category)
                                        .font(.system(size: 10, weight: .semibold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Color.blue.opacity(0.15)))
                                        .foregroundColor(.blue)

                                    Text(adventure.effortLevel)
                                        .font(.system(size: 10, weight: .semibold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Color.orange.opacity(0.15)))
                                        .foregroundColor(.orange)
                                }

                                // Title
                                Text(adventure.title)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)

                                // Description
                                Text(adventure.description)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }

                            Spacer()

                            // Status button
                            Button {
                                if let index = adventures.firstIndex(where: { $0.id == adventure.id }) {
                                    adventures[index].isCompleted.toggle()
                                }
                            } label: {
                                Label(adventure.isCompleted ? "Done" : "Start", systemImage: adventure.isCompleted ? "checkmark.circle.fill" : "play.circle.fill")
                                    .font(.caption)
                                    .labelStyle(.iconOnly)
                                    .font(.title2)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(adventure.isCompleted ? .green : .accentColor)
                        }
                        .padding(12)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                        .padding(.horizontal)
                    }
                } else {
                    // Empty state when filters match nothing
                    VStack {
                        Spacer().frame(height: 110)
                        Text("No adventures match your filters.")
                            .font(.subheadline)
                            .padding()
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                            .padding(.horizontal)
                    }
                }
            }
            // Wide "Next Adventure" button floating above the lower map area
            .overlay(alignment: .bottom) {
                Button {
                    if !filteredAdventures.isEmpty {
                        currentAdventureIndex = (currentAdventureIndex + 1) % filteredAdventures.count
                        if let nextLoc = currentAdventure?.coordinate {
                            withAnimation {
                                cameraPosition = .region(MKCoordinateRegion(center: nextLoc, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.right.circle")
                        Text("Next Adventure")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .foregroundColor(.primary)
                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                }
                .disabled(filteredAdventures.isEmpty)
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingFilters = true
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingFilters) {
                NavigationStack {
                    Form {
                        Section("Categories") {
                            HStack {
                                Button("Select All") { selectedCategories = Set(allCategories) }
                                Spacer()
                                Button("Clear All") { selectedCategories.removeAll() }
                            }
                            ForEach(allCategories, id: \.self) { category in
                                Toggle(isOn: Binding(
                                    get: { selectedCategories.contains(category) },
                                    set: { isOn in
                                        if isOn { selectedCategories.insert(category) } else { selectedCategories.remove(category) }
                                        currentAdventureIndex = 0
                                    }
                                )) {
                                    Text(category)
                                }
                            }
                        }

                        Section("Effort Levels") {
                            HStack {
                                Button("Select All") { selectedEfforts = Set(allEffortLevels) }
                                Spacer()
                                Button("Clear All") { selectedEfforts.removeAll() }
                            }
                            ForEach(allEffortLevels, id: \.self) { effort in
                                Toggle(isOn: Binding(
                                    get: { selectedEfforts.contains(effort) },
                                    set: { isOn in
                                        if isOn { selectedEfforts.insert(effort) } else { selectedEfforts.remove(effort) }
                                        currentAdventureIndex = 0
                                    }
                                )) {
                                    Text(effort)
                                }
                            }
                        }
                    }
                    .navigationTitle("Filters")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showingFilters = false }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
