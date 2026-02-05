#if canImport(UIKit)
import SwiftUI
import ViewModelConstructorCore

struct DateInputView: View {
    let label: String
    @Binding var value: any Sendable

    var body: some View {
        let binding = Binding<Date>(
            get: { value as? Date ?? Date() },
            set: { value = $0 }
        )
        DatePicker(label, selection: binding)
    }
}
#endif
