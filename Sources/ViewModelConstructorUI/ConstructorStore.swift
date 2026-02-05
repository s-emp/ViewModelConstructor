#if canImport(UIKit)
import SwiftUI
import ViewModelConstructorCore

@MainActor
@Observable
public final class ConstructorStore<Category: ConstructorCategory> {
    public var registrations: [ComponentRegistration] = []
    public var selectedRegistration: ComponentRegistration?
    public var currentValues: [String: any Sendable] = [:]
    public var previewBackgroundColor: Color = Color(uiColor: .systemBackground)
    public var showBorder: Bool = false

    public init() {}

    public func register<V: UIView & ViewModelConfigurable, VM: ViewModelConstructable>(
        component: V.Type,
        viewModel: VM.Type,
        category: Category
    ) where V.ViewModel == VM {
        let registration = ComponentRegistration(
            name: String(describing: V.self),
            categoryRawValue: category.rawValue,
            propertyDescriptors: VM.propertyDescriptors,
            createView: { V() },
            createDefaultViewModel: { VM.makeDefault() },
            allPropertyValues: { vm in (vm as! VM).allPropertyValues },
            constructFromValues: { values in VM.construct(from: values) },
            configureView: { view, vm in (view as! V).configure(with: vm as! VM) }
        )
        registrations.append(registration)
    }

    public func select(_ registration: ComponentRegistration?) {
        selectedRegistration = registration
        if let registration {
            let defaultVM = registration.createDefaultViewModel()
            currentValues = registration.allPropertyValues(defaultVM)
        } else {
            currentValues = [:]
        }
    }

    public func resetToDefaults() {
        guard let registration = selectedRegistration else { return }
        let defaultVM = registration.createDefaultViewModel()
        currentValues = registration.allPropertyValues(defaultVM)
    }

    public func buildCurrentViewModel() -> (any Sendable)? {
        guard let registration = selectedRegistration else { return nil }
        return registration.constructFromValues(currentValues)
    }

    public var categorizedRegistrations: [(category: String, registrations: [ComponentRegistration])] {
        let grouped = Dictionary(grouping: registrations) { $0.categoryRawValue }
        return Category.allCases.compactMap { category in
            guard let items = grouped[category.rawValue], !items.isEmpty else { return nil }
            return (category: category.rawValue, registrations: items)
        }
    }
}
#endif
