# SwiftUI Previews Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add `#Preview` blocks to all View and Input components in ViewModelConstructorUI so they render in Xcode's preview canvas.

**Architecture:** Each file gets a `#Preview` block appended before the closing `#endif`. Input previews use `@Previewable @State` with mock values. View previews define mock types inside `#if DEBUG` and create populated `ConstructorStore` instances with stub closures.

**Tech Stack:** SwiftUI `#Preview` macro, `@Previewable @State`, `#if DEBUG`

---

### Task 1: Add previews to simple Input components

**Files:**
- Modify: `Sources/ViewModelConstructorUI/Inputs/StringInputView.swift`
- Modify: `Sources/ViewModelConstructorUI/Inputs/BoolInputView.swift`
- Modify: `Sources/ViewModelConstructorUI/Inputs/DateInputView.swift`
- Modify: `Sources/ViewModelConstructorUI/Inputs/ColorInputView.swift`
- Modify: `Sources/ViewModelConstructorUI/Inputs/UnsupportedTypeInputView.swift`

**Step 1: Add preview to StringInputView.swift**

Insert before the closing `#endif` (line 18):

```swift

#Preview {
    @Previewable @State var value: any Sendable = "Hello, World!"
    StringInputView(label: "Title", value: $value)
        .padding()
}
```

**Step 2: Add preview to BoolInputView.swift**

Insert before the closing `#endif` (line 17):

```swift

#Preview {
    @Previewable @State var value: any Sendable = true
    BoolInputView(label: "Is Enabled", value: $value)
        .padding()
}
```

**Step 3: Add preview to DateInputView.swift**

Insert before the closing `#endif` (line 17):

```swift

#Preview {
    @Previewable @State var value: any Sendable = Date()
    DateInputView(label: "Created At", value: $value)
        .padding()
}
```

**Step 4: Add preview to ColorInputView.swift**

Insert before the closing `#endif` (line 23):

```swift

#Preview {
    @Previewable @State var value: any Sendable = UIColor.systemBlue
    ColorInputView(label: "Background Color", value: $value)
        .padding()
}
```

**Step 5: Add preview to UnsupportedTypeInputView.swift**

Insert before the closing `#endif` (line 19):

```swift

#Preview {
    UnsupportedTypeInputView(label: "metadata", typeName: "CustomComplexType")
        .padding()
}
```

**Step 6: Build to verify**

Run: `swift build`
Expected: BUILD SUCCEEDED

**Step 7: Commit**

```bash
git add Sources/ViewModelConstructorUI/Inputs/StringInputView.swift \
       Sources/ViewModelConstructorUI/Inputs/BoolInputView.swift \
       Sources/ViewModelConstructorUI/Inputs/DateInputView.swift \
       Sources/ViewModelConstructorUI/Inputs/ColorInputView.swift \
       Sources/ViewModelConstructorUI/Inputs/UnsupportedTypeInputView.swift
git commit -m "feat: add SwiftUI previews to simple input components"
```

---

### Task 2: Add previews to NumberInputView

**Files:**
- Modify: `Sources/ViewModelConstructorUI/Inputs/NumberInputView.swift`

This file contains three views: `IntInputView`, `DoubleInputView`, `FloatInputView`.

**Step 1: Add three previews to NumberInputView.swift**

Insert before the closing `#endif` (line 65):

```swift

#Preview("Int Input") {
    @Previewable @State var value: any Sendable = 42
    IntInputView(label: "Count", value: $value)
        .padding()
}

#Preview("Double Input") {
    @Previewable @State var value: any Sendable = 3.14
    DoubleInputView(label: "Opacity", value: $value)
        .padding()
}

#Preview("Float Input") {
    @Previewable @State var value: any Sendable = Float(1.5)
    FloatInputView(label: "Scale", value: $value)
        .padding()
}
```

**Step 2: Build to verify**

Run: `swift build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add Sources/ViewModelConstructorUI/Inputs/NumberInputView.swift
git commit -m "feat: add SwiftUI previews to number input components"
```

---

### Task 3: Add previews to complex Input components

**Files:**
- Modify: `Sources/ViewModelConstructorUI/Inputs/EnumInputView.swift`
- Modify: `Sources/ViewModelConstructorUI/Inputs/ArrayInputView.swift`
- Modify: `Sources/ViewModelConstructorUI/Inputs/OptionalInputView.swift`

**Step 1: Add preview to EnumInputView.swift**

Insert before the closing `#endif` (line 22):

```swift

#Preview {
    @Previewable @State var value: any Sendable = "primary"
    EnumInputView(
        label: "Style",
        cases: ["primary", "secondary", "destructive"],
        value: $value
    )
    .padding()
}
```

**Step 2: Add preview to ArrayInputView.swift**

Insert before the closing `#endif` (line 77):

```swift

#Preview {
    @Previewable @State var value: any Sendable = ["Item 1", "Item 2"] as [any Sendable]
    ArrayInputView(
        label: "Tags",
        elementTypeInfo: .string,
        value: $value
    )
    .padding()
}
```

**Step 3: Add preview to OptionalInputView.swift**

Insert before the closing `#endif` (line 59):

```swift

#Preview {
    @Previewable @State var value: any Sendable = Optional("Optional value") as any Sendable
    OptionalInputView(
        label: "Subtitle",
        wrappedTypeInfo: .string,
        value: $value
    )
    .padding()
}
```

**Step 4: Build to verify**

Run: `swift build`
Expected: BUILD SUCCEEDED

**Step 5: Commit**

```bash
git add Sources/ViewModelConstructorUI/Inputs/EnumInputView.swift \
       Sources/ViewModelConstructorUI/Inputs/ArrayInputView.swift \
       Sources/ViewModelConstructorUI/Inputs/OptionalInputView.swift
git commit -m "feat: add SwiftUI previews to complex input components"
```

---

### Task 4: Add preview to DeviceFrameView

**Files:**
- Modify: `Sources/ViewModelConstructorUI/Views/DeviceFrameView.swift`

**Step 1: Add preview to DeviceFrameView.swift**

Insert before the closing `#endif` (line 48):

```swift

#Preview {
    DeviceFrameView(deviceSize: .iPhone15, backgroundColor: .white) {
        VStack(spacing: 12) {
            Text("Sample Component")
                .font(.headline)
            Text("This is how content looks inside the device frame")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
```

**Step 2: Build to verify**

Run: `swift build`
Expected: BUILD SUCCEEDED

**Step 3: Commit**

```bash
git add Sources/ViewModelConstructorUI/Views/DeviceFrameView.swift
git commit -m "feat: add SwiftUI preview to DeviceFrameView"
```

---

### Task 5: Add previews to store-dependent Views

**Files:**
- Modify: `Sources/ViewModelConstructorUI/Views/SidebarView.swift`
- Modify: `Sources/ViewModelConstructorUI/Views/InspectorView.swift`
- Modify: `Sources/ViewModelConstructorUI/Views/PreviewView.swift`
- Modify: `Sources/ViewModelConstructorUI/ConstructorView.swift`

Each file needs a `#if DEBUG` block with a mock `PreviewCategory` enum and a helper to create a populated store. Since each file is self-contained, the mock types are duplicated per file (by design — no shared preview helpers).

The mock `ComponentRegistration` uses dictionary-based "view models" — `createDefaultViewModel` returns a `[String: any Sendable]`, and `allPropertyValues`/`constructFromValues` pass dictionaries through. This avoids needing real UIView/ViewModel types.

**Step 1: Add preview to SidebarView.swift**

Insert before the closing `#endif` (line 53):

```swift

#if DEBUG
private enum PreviewCategory: String, ConstructorCategory {
    case controls = "Controls"
    case layout = "Layout"
}

@MainActor
private func makePreviewStore() -> ConstructorStore<PreviewCategory> {
    let store = ConstructorStore<PreviewCategory>()
    store.registrations.append(ComponentRegistration(
        name: "PrimaryButton",
        categoryRawValue: PreviewCategory.controls.rawValue,
        propertyDescriptors: [
            PropertyDescriptor(name: "title", typeInfo: .string, isOptional: false),
            PropertyDescriptor(name: "isEnabled", typeInfo: .bool, isOptional: false),
        ],
        createView: { UIView() },
        createDefaultViewModel: { ["title": "Tap", "isEnabled": true] as [String: any Sendable] },
        allPropertyValues: { vm in vm as? [String: any Sendable] ?? [:] },
        constructFromValues: { $0 },
        configureView: { _, _ in }
    ))
    store.registrations.append(ComponentRegistration(
        name: "IconButton",
        categoryRawValue: PreviewCategory.controls.rawValue,
        propertyDescriptors: [
            PropertyDescriptor(name: "iconName", typeInfo: .string, isOptional: false),
        ],
        createView: { UIView() },
        createDefaultViewModel: { ["iconName": "star"] as [String: any Sendable] },
        allPropertyValues: { vm in vm as? [String: any Sendable] ?? [:] },
        constructFromValues: { $0 },
        configureView: { _, _ in }
    ))
    store.registrations.append(ComponentRegistration(
        name: "CardView",
        categoryRawValue: PreviewCategory.layout.rawValue,
        propertyDescriptors: [
            PropertyDescriptor(name: "padding", typeInfo: .double, isOptional: false),
        ],
        createView: { UIView() },
        createDefaultViewModel: { ["padding": 16.0] as [String: any Sendable] },
        allPropertyValues: { vm in vm as? [String: any Sendable] ?? [:] },
        constructFromValues: { $0 },
        configureView: { _, _ in }
    ))
    return store
}
#endif

#Preview {
    NavigationSplitView {
        SidebarView(store: makePreviewStore())
    } detail: {
        Text("Detail")
    }
}
```

**Step 2: Add preview to InspectorView.swift**

Insert before the closing `#endif` (line 167):

```swift

#if DEBUG
private enum PreviewCategory: String, ConstructorCategory {
    case controls = "Controls"
    case layout = "Layout"
}

@MainActor
private func makePreviewStore() -> ConstructorStore<PreviewCategory> {
    let store = ConstructorStore<PreviewCategory>()
    let reg = ComponentRegistration(
        name: "SampleButton",
        categoryRawValue: PreviewCategory.controls.rawValue,
        propertyDescriptors: [
            PropertyDescriptor(name: "title", typeInfo: .string, isOptional: false),
            PropertyDescriptor(name: "isEnabled", typeInfo: .bool, isOptional: false),
            PropertyDescriptor(name: "cornerRadius", typeInfo: .double, isOptional: false),
            PropertyDescriptor(name: "textColor", typeInfo: .color, isOptional: false),
            PropertyDescriptor(name: "subtitle", typeInfo: .optional(wrapped: .string), isOptional: true),
        ],
        createView: { UIView() },
        createDefaultViewModel: {
            [
                "title": "Tap Me",
                "isEnabled": true,
                "cornerRadius": 8.0,
                "textColor": UIColor.label,
                "subtitle": Optional<any Sendable>.none as any Sendable,
            ] as [String: any Sendable]
        },
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
    InspectorView(store: makePreviewStore())
}
```

**Step 3: Add preview to PreviewView.swift**

Insert before the closing `#endif` (line 83):

```swift

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
```

**Step 4: Add preview to ConstructorView.swift**

Insert before the closing `#endif` (line 31):

```swift

#if DEBUG
private enum PreviewCategory: String, ConstructorCategory {
    case controls = "Controls"
    case layout = "Layout"
}

@MainActor
private func makePreviewStore() -> ConstructorStore<PreviewCategory> {
    let store = ConstructorStore<PreviewCategory>()
    store.registrations.append(ComponentRegistration(
        name: "PrimaryButton",
        categoryRawValue: PreviewCategory.controls.rawValue,
        propertyDescriptors: [
            PropertyDescriptor(name: "title", typeInfo: .string, isOptional: false),
            PropertyDescriptor(name: "isEnabled", typeInfo: .bool, isOptional: false),
        ],
        createView: {
            let label = UILabel()
            label.text = "Button"
            label.textAlignment = .center
            return label
        },
        createDefaultViewModel: { ["title": "Tap Me", "isEnabled": true] as [String: any Sendable] },
        allPropertyValues: { vm in vm as? [String: any Sendable] ?? [:] },
        constructFromValues: { $0 },
        configureView: { _, _ in }
    ))
    store.registrations.append(ComponentRegistration(
        name: "StackView",
        categoryRawValue: PreviewCategory.layout.rawValue,
        propertyDescriptors: [
            PropertyDescriptor(name: "spacing", typeInfo: .double, isOptional: false),
        ],
        createView: { UIView() },
        createDefaultViewModel: { ["spacing": 8.0] as [String: any Sendable] },
        allPropertyValues: { vm in vm as? [String: any Sendable] ?? [:] },
        constructFromValues: { $0 },
        configureView: { _, _ in }
    ))
    return store
}
#endif

#Preview {
    ConstructorView(store: makePreviewStore())
}
```

**Step 5: Build to verify**

Run: `swift build`
Expected: BUILD SUCCEEDED

**Step 6: Commit**

```bash
git add Sources/ViewModelConstructorUI/Views/SidebarView.swift \
       Sources/ViewModelConstructorUI/Views/InspectorView.swift \
       Sources/ViewModelConstructorUI/Views/PreviewView.swift \
       Sources/ViewModelConstructorUI/ConstructorView.swift
git commit -m "feat: add SwiftUI previews to store-dependent view components"
```
