#if canImport(UIKit)
import SwiftUI
import ViewModelConstructorCore

struct SidebarView<Category: ConstructorCategory>: View {
    @Bindable var store: ConstructorStore<Category>
    @State private var searchText = ""

    var body: some View {
        List(selection: selectionBinding) {
            ForEach(filteredCategories, id: \.category) { group in
                Section(group.category) {
                    ForEach(group.registrations) { registration in
                        NavigationLink(value: registration.id) {
                            Text(registration.name)
                        }
                    }
                }
            }
        }
        .navigationTitle("Components")
        .searchable(text: $searchText, prompt: "Search components")
    }

    private var selectionBinding: Binding<UUID?> {
        Binding<UUID?>(
            get: { store.selectedRegistration?.id },
            set: { newID in
                if let newID,
                   let registration = store.registrations.first(where: { $0.id == newID }) {
                    store.select(registration)
                } else {
                    store.select(nil)
                }
            }
        )
    }

    private var filteredCategories: [(category: String, registrations: [ComponentRegistration])] {
        let categorized = store.categorizedRegistrations
        if searchText.isEmpty {
            return categorized
        }
        return categorized.compactMap { group in
            let filtered = group.registrations.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
            guard !filtered.isEmpty else { return nil }
            return (category: group.category, registrations: filtered)
        }
    }
}
#endif
