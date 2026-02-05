public struct PropertyDescriptor: Sendable {
    public let name: String
    public let typeInfo: TypeInfo
    public let isOptional: Bool

    public init(name: String, typeInfo: TypeInfo, isOptional: Bool) {
        self.name = name
        self.typeInfo = typeInfo
        self.isOptional = isOptional
    }
}
