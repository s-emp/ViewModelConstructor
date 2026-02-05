import Testing
import ViewModelConstructorCore

@ViewModelConstructor
struct SampleViewModel {
    let title: String
    let count: Int
    let isEnabled: Bool
    let subtitle: String?

    init() {
        self.title = "Hello"
        self.count = 42
        self.isEnabled = true
        self.subtitle = nil
    }
}

@Test func macroGeneratesViewModelConstructableConformance() {
    let vm = SampleViewModel.makeDefault()
    #expect(vm.title == "Hello")
    #expect(vm.count == 42)
    #expect(vm.isEnabled == true)
    #expect(vm.subtitle == nil)
}

@Test func propertyDescriptorsAreCorrect() {
    let descriptors = SampleViewModel.propertyDescriptors
    #expect(descriptors.count == 4)
    #expect(descriptors[0].name == "title")
    #expect(descriptors[1].name == "count")
    #expect(descriptors[2].name == "isEnabled")
    #expect(descriptors[3].name == "subtitle")
    #expect(descriptors[3].isOptional == true)
}

@Test func allPropertyValuesExtractsCorrectly() {
    let vm = SampleViewModel.makeDefault()
    let values = vm.allPropertyValues
    #expect(values["title"] as? String == "Hello")
    #expect(values["count"] as? Int == 42)
    #expect(values["isEnabled"] as? Bool == true)
}

@Test func constructFromValuesCreatesNewInstance() {
    let vm = SampleViewModel.makeDefault()
    var values = vm.allPropertyValues
    values["title"] = "World"
    values["count"] = 99

    let newVM = SampleViewModel.construct(from: values)
    #expect(newVM.title == "World")
    #expect(newVM.count == 99)
    #expect(newVM.isEnabled == true) // unchanged
}

@Test func roundTripPreservesValues() {
    let original = SampleViewModel.makeDefault()
    let values = original.allPropertyValues
    let reconstructed = SampleViewModel.construct(from: values)
    #expect(reconstructed.title == original.title)
    #expect(reconstructed.count == original.count)
    #expect(reconstructed.isEnabled == original.isEnabled)
    #expect(reconstructed.subtitle == original.subtitle)
}
