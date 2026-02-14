import SwiftUI
import ViewModelConstructorCore
import ViewModelConstructorUI

enum DemoCategory: String, ConstructorCategory, CaseIterable {
    case text = "Text"
    case button = "Button"
}

@main
struct DemoAppApp: App {
    @State private var store: ConstructorStore<DemoCategory> = {
        let store = ConstructorStore<DemoCategory>()
        store.register(
            component: MyTextView.self,
            viewModel: MyTextViewModel.self,
            category: .text
        )
        store.register(
            component: MyButtonView.self,
            viewModel: MyButtonViewModel.self,
            category: .button
        )
        return store
    }()

    var body: some Scene {
        WindowGroup {
            ConstructorView(store: store)
        }
    }
}
