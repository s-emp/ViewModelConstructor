#if canImport(UIKit)
import SwiftUI
import UIKit
import ViewModelConstructorCore

/// The main three-column constructor interface.
///
/// Usage:
/// ```swift
/// let store = ConstructorStore<MyCategory>()
/// store.register(component: MyButton.self, viewModel: MyButtonViewModel.self, category: .controls)
///
/// ConstructorView(store: store)
/// ```
public struct ConstructorView<Category: ConstructorCategory>: View {
    @Bindable private var store: ConstructorStore<Category>

    public init(store: ConstructorStore<Category>) {
        self.store = store
    }

    public var body: some View {
        NavigationSplitView {
            SidebarView(store: store)
        } content: {
            PreviewView(store: store)
        } detail: {
            InspectorView(store: store)
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
        createView: {
            let label = UILabel()
            label.text = "Button"
            label.textAlignment = .center
            return label
        },
        createDefaultViewModel: { ["title": "Tap Me", "isEnabled": true] as [String: any Sendable] },
        allPropertyValues: { vm in vm as? [String: any Sendable] ?? [:] },
        constructFromValues: { $0 },
        configureView: { _, _ in }
    ))
    store.registrations.append(ComponentRegistration(
        name: "StackView",
        categoryRawValue: PreviewCategory.layout.rawValue,
        propertyDescriptors: [
            PropertyDescriptor(name: "spacing", typeInfo: .double, isOptional: false),
        ],
        createView: { UIView() },
        createDefaultViewModel: { ["spacing": 8.0] as [String: any Sendable] },
        allPropertyValues: { vm in vm as? [String: any Sendable] ?? [:] },
        constructFromValues: { $0 },
        configureView: { _, _ in }
    ))
    return store
}
#endif

#Preview {
    ConstructorView(store: makePreviewStore())
}
#endif
