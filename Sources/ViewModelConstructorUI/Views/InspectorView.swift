#if canImport(UIKit)
import SwiftUI
import ViewModelConstructorCore

struct InspectorView<Category: ConstructorCategory>: View {
    @Bindable var store: ConstructorStore<Category>

    var body: some View {
        NavigationStack {
            Group {
                if let registration = store.selectedRegistration {
                    PropertyListView(
                        registration: registration,
                        values: $store.currentValues
                    )
                } else {
                    ContentUnavailableView(
                        "No Component Selected",
                        systemImage: "sidebar.right",
                        description: Text("Select a component from the sidebar to inspect its properties.")
                    )
                }
            }
            .navigationTitle("Inspector")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        store.resetToDefaults()
                    } label: {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                    }
                    .disabled(store.selectedRegistration == nil)
                }
            }
        }
    }
}

private struct PropertyListView: View {
    let registration: ComponentRegistration
    @Binding var values: [String: any Sendable]

    var body: some View {
        Form {
            ForEach(registration.propertyDescriptors, id: \.name) { descriptor in
                PropertyRow(
                    descriptor: descriptor,
                    values: $values
                )
            }
        }
    }
}

private struct PropertyRow: View {
    let descriptor: PropertyDescriptor
    @Binding var values: [String: any Sendable]

    var body: some View {
        let valueBinding = Binding<any Sendable>(
            get: { values[descriptor.name] ?? defaultValue(for: descriptor.typeInfo) },
            set: { values[descriptor.name] = $0 }
        )

        switch descriptor.typeInfo {
        case .nested(let nestedType):
            NestedNavigationRow(
                descriptor: descriptor,
                nestedType: nestedType,
                values: $values
            )
        default:
            Section(descriptor.name) {
                PropertyInputFactory.makeInput(
                    label: descriptor.name,
                    typeInfo: descriptor.typeInfo,
                    value: valueBinding
                )
            }
        }
    }

    private func defaultValue(for typeInfo: TypeInfo) -> any Sendable {
        switch typeInfo {
        case .string: return ""
        case .int: return 0
        case .double: return 0.0
        case .float: return Float(0.0)
        case .bool: return false
        case .date: return Date()
        case .color: return UIColor.black
        case .enumType(_, let cases): return cases.first ?? ""
        case .optional: return Optional<Any>.none as any Sendable
        case .array: return [any Sendable]()
        default: return ""
        }
    }
}

private struct NestedNavigationRow: View {
    let descriptor: PropertyDescriptor
    let nestedType: any ViewModelConstructable.Type
    @Binding var values: [String: any Sendable]

    var body: some View {
        Section(descriptor.name) {
            NavigationLink {
                NestedPropertyView(
                    name: descriptor.name,
                    nestedType: nestedType,
                    parentValues: $values
                )
            } label: {
                Label(descriptor.name, systemImage: "chevron.right.square")
            }
        }
    }
}

private struct NestedPropertyView: View {
    let name: String
    let nestedType: any ViewModelConstructable.Type
    @Binding var parentValues: [String: any Sendable]
    @State private var nestedValues: [String: any Sendable] = [:]

    var body: some View {
        Form {
            ForEach(nestedType.propertyDescriptors, id: \.name) { descriptor in
                let valueBinding = Binding<any Sendable>(
                    get: { nestedValues[descriptor.name] ?? "" },
                    set: { newVal in
                        nestedValues[descriptor.name] = newVal
                        // Reconstruct the nested ViewModel and store it in parent
                        let reconstructed = nestedType.construct(from: nestedValues)
                        parentValues[name] = reconstructed
                    }
                )

                Section(descriptor.name) {
                    PropertyInputFactory.makeInput(
                        label: descriptor.name,
                        typeInfo: descriptor.typeInfo,
                        value: valueBinding
                    )
                }
            }
        }
        .navigationTitle(name)
        .onAppear {
            // Extract current nested values
            if let nestedVM = parentValues[name] {
                // Try to get allPropertyValues from the nested ViewModel
                if let constructable = nestedVM as? any ViewModelConstructable {
                    nestedValues = constructable.allPropertyValues
                } else {
                    // Initialize from defaults
                    let defaultVM = nestedType.makeDefault()
                    nestedValues = defaultVM.allPropertyValues
                }
            } else {
                let defaultVM = nestedType.makeDefault()
                nestedValues = defaultVM.allPropertyValues
            }
        }
    }
}
#endif
