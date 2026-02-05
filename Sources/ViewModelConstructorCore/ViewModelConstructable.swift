public protocol ViewModelConstructable {
    static func makeDefault() -> Self
    static var propertyDescriptors: [PropertyDescriptor] { get }
    var allPropertyValues: [String: any Sendable] { get }
    static func construct(from values: [String: any Sendable]) -> Self
}
