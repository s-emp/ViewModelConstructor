#if canImport(UIKit)
import SwiftUI
import UIKit
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

#if DEBUG
private enum PreviewCategory: String, ConstructorCategory {
    case controls = "Controls"
    case layout = "Layout"
}

@MainActor
private func makePreviewStore() -> ConstructorStore<PreviewCategory> {
    let store = ConstructorStore<PreviewCategory>()
    store.registrations.append(ComponentRegistration(
        name: "PrimaryButton",
        categoryRawValue: PreviewCategory.controls.rawValue,
        propertyDescriptors: [
            PropertyDescriptor(name: "title", typeInfo: .string, isOptional: false),
            PropertyDescriptor(name: "isEnabled", typeInfo: .bool, isOptional: false),
        ],
        createView: { UIView() },
        createDefaultViewModel: { ["title": "Tap", "isEnabled": true] as [String: any Sendable] },
        allPropertyValues: { vm in vm as? [String: any Sendable] ?? [:] },
        constructFromValues: { $0 },
        configureView: { _, _ in }
    ))
    store.registrations.append(ComponentRegistration(
        name: "IconButton",
        categoryRawValue: PreviewCategory.controls.rawValue,
        propertyDescriptors: [
            PropertyDescriptor(name: "iconName", typeInfo: .string, isOptional: false),
        ],
        createView: { UIView() },
        createDefaultViewModel: { ["iconName": "star"] as [String: any Sendable] },
        allPropertyValues: { vm in vm as? [String: any Sendable] ?? [:] },
        constructFromValues: { $0 },
        configureView: { _, _ in }
    ))
    store.registrations.append(ComponentRegistration(
        name: "CardView",
        categoryRawValue: PreviewCategory.layout.rawValue,
        propertyDescriptors: [
            PropertyDescriptor(name: "padding", typeInfo: .double, isOptional: false),
        ],
        createView: { UIView() },
        createDefaultViewModel: { ["padding": 16.0] as [String: any Sendable] },
        allPropertyValues: { vm in vm as? [String: any Sendable] ?? [:] },
        constructFromValues: { $0 },
        configureView: { _, _ in }
    ))
    return store
}
#endif

#Preview {
    NavigationSplitView {
        SidebarView(store: makePreviewStore())
    } detail: {
        Text("Detail")
    }
}
#endif
