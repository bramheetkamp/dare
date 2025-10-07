//
//  LocationSearchView.swift
//  Dare
//
//  Created by Bram Heetkamp on 18/06/2025.
//

import SwiftUI
import MapKit

struct LocationSearchView: View {
    @Binding var location: String
    @State private var showSearchSheet = false

    var body: some View {
        Button {
            showSearchSheet = true
        } label: {
            HStack {
                Text(location.isEmpty ? "Search for a location" : location)
                    .foregroundColor(location.isEmpty ? .gray : .primary)
                Spacer()
                Image(systemName: "magnifyingglass")
            }
            .padding()
            .background(Color.cell)
            .cornerRadius(Style.CornerRadius.small)
        }
        .sheet(isPresented: $showSearchSheet) {
            LocationSearchSheet(location: $location, isPresented: $showSearchSheet)
        }
    }
}

struct LocationSearchSheet: View {
    @Binding var location: String
    @Binding var isPresented: Bool

    @State private var searchText = ""
    @StateObject private var completerDelegate = LocationSearchCompleterDelegate()
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationView {
            VStack {
                TextField("Type a location...", text: $searchText)
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(Style.CornerRadius.small)
                    .padding(.horizontal)
                    .focused($isTextFieldFocused)
                    .onChange(of: searchText) { newValue in
                        completerDelegate.completer.queryFragment = newValue
                    }
                    .disableAutocorrection(true)
                    
                List {
                    if !searchText.isEmpty {
                        Button {
                            location = searchText
                            isPresented = false
                        } label: {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(.green)
                                VStack(alignment: .leading) {
                                    Text("Use custom location")
                                        .bold()
                                    Text("\"\(searchText)\"")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    ForEach(completerDelegate.completions, id: \.self) { completion in
                        Button {
                            location = "\(completion.title), \(completion.subtitle)"
                            isPresented = false
                        } label: {
                            VStack(alignment: .leading) {
                                Text(completion.title).bold()
                                Text(completion.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Search Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            completerDelegate.completer.resultTypes = .address
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTextFieldFocused = true
            }
        }
    }
}

// Completer Delegate remains the same:
class LocationSearchCompleterDelegate: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    let completer = MKLocalSearchCompleter()
    @Published var completions: [MKLocalSearchCompletion] = []

    override init() {
        super.init()
        completer.delegate = self
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Location search failed: \(error)")
    }
}
