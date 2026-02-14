#if canImport(UIKit)
import SwiftUI
import ViewModelConstructorCore

struct BoolInputView: View {
    let label: String
    @Binding var value: any Sendable

    var body: some View {
        let binding = Binding<Bool>(
            get: { value as? Bool ?? false },
            set: { value = $0 }
        )
        Toggle(label, isOn: binding)
    }
}

#Preview {
    @Previewable @State var value: any Sendable = true
    BoolInputView(label: "Is Enabled", value: $value)
        .padding()
}
#endif
