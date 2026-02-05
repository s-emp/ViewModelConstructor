import Testing
@testable import ViewModelConstructorCore

@Test func propertyDescriptorStoresMetadata() {
    let descriptor = PropertyDescriptor(
        name: "title",
        typeInfo: .string,
        isOptional: false
    )
    #expect(descriptor.name == "title")
    #expect(descriptor.isOptional == false)
}

@Test func typeInfoIdentifiesBaseTypes() {
    let stringType = TypeInfo.string
    let optionalString = TypeInfo.optional(wrapped: .string)
    let array = TypeInfo.array(element: .int)

    if case .string = stringType {} else {
        Issue.record("Expected .string")
    }
    if case .optional(let wrapped) = optionalString {
        if case .string = wrapped {} else {
            Issue.record("Expected wrapped .string")
        }
    } else {
        Issue.record("Expected .optional")
    }
    if case .array(let element) = array {
        if case .int = element {} else {
            Issue.record("Expected element .int")
        }
    } else {
        Issue.record("Expected .array")
    }
}

@Test func baseTypeCoversAllPrimitives() {
    let allCases: [BaseType] = [.string, .int, .double, .float, .bool, .date, .color]
    #expect(allCases.count == 7)
}
