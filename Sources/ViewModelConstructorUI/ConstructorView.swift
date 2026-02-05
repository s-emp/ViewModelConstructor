#if canImport(UIKit)
import SwiftUI
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
#endif
