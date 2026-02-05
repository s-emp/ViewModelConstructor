#if canImport(UIKit)
import SwiftUI
import ViewModelConstructorCore

struct StringInputView: View {
    let label: String
    @Binding var value: any Sendable

    var body: some View {
        let binding = Binding<String>(
            get: { value as? String ?? "" },
            set: { value = $0 }
        )
        TextField(label, text: binding)
            .textFieldStyle(.roundedBorder)
    }
}
#endif
