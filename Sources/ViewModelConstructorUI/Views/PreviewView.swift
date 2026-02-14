#if canImport(UIKit)
import SwiftUI
import UIKit
import ViewModelConstructorCore

struct PreviewView<Category: ConstructorCategory>: View {
    @Bindable var store: ConstructorStore<Category>
    @State private var updateTrigger = UUID()
    @State private var selectedDevice: DeviceSize = .iPhone15

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            previewToolbar
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(.bar)

            Divider()

            // Content
            if let registration = store.selectedRegistration {
                ScrollView([.horizontal, .vertical]) {
                    DeviceFrameView(
                        deviceSize: selectedDevice,
                        backgroundColor: store.previewBackgroundColor
                    ) {
                        ComponentPreviewRepresentable(
                            registration: registration,
                            values: store.currentValues,
                            showBorder: store.showBorder,
                            updateTrigger: updateTrigger
                        )
                    }
                    .padding(24)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ContentUnavailableView(
                    "No Component Selected",
                    systemImage: "rectangle.dashed",
                    description: Text("Select a component from the sidebar to preview it.")
                )
            }
        }
        .navigationTitle("Preview")
    }

    @ViewBuilder
    private var previewToolbar: some View {
        HStack(spacing: 16) {
            ColorPicker("Background", selection: $store.previewBackgroundColor)
                .fixedSize()

            Divider()
                .frame(height: 20)

            Toggle("Border", isOn: $store.showBorder)
                .fixedSize()

            Divider()
                .frame(height: 20)

            Button {
                updateTrigger = UUID()
            } label: {
                Label("Recreate", systemImage: "arrow.clockwise")
            }

            Divider()
                .frame(height: 20)

            Picker("Device", selection: $selectedDevice) {
                ForEach(DeviceSize.allCases) { device in
                    Text(device.rawValue).tag(device)
                }
            }
            .fixedSize()

            Spacer()
        }
    }
}

#if DEBUG
private enum PreviewCategory: String, ConstructorCategory {
    case controls = "Controls"
}

@MainActor
private func makePreviewStore() -> ConstructorStore<PreviewCategory> {
    let store = ConstructorStore<PreviewCategory>()
    let reg = ComponentRegistration(
        name: "SampleButton",
        categoryRawValue: PreviewCategory.controls.rawValue,
        propertyDescriptors: [
            PropertyDescriptor(name: "title", typeInfo: .string, isOptional: false),
        ],
        createView: {
            let label = UILabel()
            label.text = "Preview Component"
            label.textAlignment = .center
            return label
        },
        createDefaultViewModel: { ["title": "Tap Me"] as [String: any Sendable] },
        allPropertyValues: { vm in vm as? [String: any Sendable] ?? [:] },
        constructFromValues: { $0 },
        configureView: { _, _ in }
    )
    store.registrations.append(reg)
    store.select(reg)
    return store
}
#endif

#Preview {
    PreviewView(store: makePreviewStore())
}
#endif
