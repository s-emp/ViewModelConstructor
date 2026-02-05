#if canImport(UIKit)
import UIKit
import ViewModelConstructorCore

public struct ComponentRegistration: Identifiable, @unchecked Sendable {
    public let id = UUID()
    public let name: String
    public let categoryRawValue: String
    public let propertyDescriptors: [PropertyDescriptor]
    let createView: @MainActor () -> UIView
    let createDefaultViewModel: @Sendable () -> any Sendable
    let allPropertyValues: @Sendable (any Sendable) -> [String: any Sendable]
    let constructFromValues: @Sendable ([String: any Sendable]) -> any Sendable
    let configureView: @MainActor (UIView, any Sendable) -> Void
}

extension ComponentRegistration: Hashable {
    public static func == (lhs: ComponentRegistration, rhs: ComponentRegistration) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
#endif
