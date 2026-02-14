# SwiftUI Previews for Constructor UI Components

## Goal

Add `#Preview` to all View and Input components in ViewModelConstructorUI so developers can see how the constructor's own UI looks in Xcode's preview canvas.

## Scope

### Included (16 files)

**Inputs (11):**
- StringInputView
- IntInputView, DoubleInputView, FloatInputView (all in NumberInputView.swift)
- BoolInputView
- DateInputView
- ColorInputView
- EnumInputView
- ArrayInputView
- OptionalInputView
- UnsupportedTypeInputView

**Views (5):**
- DeviceFrameView
- SidebarView
- PreviewView
- InspectorView
- ConstructorView

### Excluded

- **ComponentPreviewRepresentable** — UIViewRepresentable bridge, not a visual component
- **PropertyInputFactory** — static factory enum, not a View

## Approach

### Input Previews

Each input file gets a `#Preview` block at the end using `@Previewable @State`:

```swift
#Preview {
    @Previewable @State var value: any Sendable = "Hello, World!"
    StringInputView(label: "Title", value: $value)
        .padding()
}
```

Mock data per input:

| Input | Mock Value |
|-------|-----------|
| StringInputView | `"Hello, World!"` |
| IntInputView | `42` |
| DoubleInputView | `3.14` |
| FloatInputView | `Float(1.5)` |
| BoolInputView | `true` |
| DateInputView | `Date()` |
| ColorInputView | `UIColor.systemBlue` |
| EnumInputView | cases: `["primary", "secondary", "destructive"]`, value: `"primary"` |
| ArrayInputView | elementTypeInfo: `.base(.string)`, value: `["Item 1", "Item 2"]` |
| OptionalInputView | wrappedTypeInfo: `.base(.string)`, value: `Optional("Optional value")` |
| UnsupportedTypeInputView | typeName: `"CustomComplexType"` |

### View Previews

Views depend on `ConstructorStore<Category>` which is generic. Each file defines mock types inside `#if DEBUG`:

```swift
#if DEBUG
private enum PreviewCategory: String, ConstructorCategory {
    case controls = "Controls"
    case layout = "Layout"
}
#endif
```

Mock store is created with fake `ComponentRegistration` entries. Closures (`createView`, `configureView`, etc.) use simple `UIView()` stubs.

| View | Store Config |
|------|-------------|
| DeviceFrameView | No store needed — uses `deviceSize`, `backgroundColor`, `@ViewBuilder content` |
| SidebarView | Store with 3-4 registrations across different categories |
| InspectorView | Store with selected registration having mixed-type `propertyDescriptors` and `currentValues` |
| PreviewView | Store with selected registration (preview UIView will be empty — acceptable for layout demo) |
| ConstructorView | Store with multiple registrations, one selected |

### Organization

- All mock types defined inside `#if DEBUG` blocks within each file
- Each file is self-contained — no shared preview helpers
- No new files created
