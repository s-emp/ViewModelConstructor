#if canImport(UIKit)
import SwiftUI
import ViewModelConstructorCore

struct EnumInputView: View {
    let label: String
    let cases: [String]
    @Binding var value: any Sendable

    var body: some View {
        let binding = Binding<String>(
            get: { "\(value)" },
            set: { value = $0 }
        )
        Picker(label, selection: binding) {
            ForEach(cases, id: \.self) { caseName in
                Text(caseName).tag(caseName)
            }
        }
    }
}

#Preview {
    @Previewable @State var value: any Sendable = "primary"
    EnumInputView(
        label: "Style",
        cases: ["primary", "secondary", "destructive"],
        value: $value
    )
    .padding()
}
#endif
