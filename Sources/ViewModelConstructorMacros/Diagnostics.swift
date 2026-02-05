import SwiftDiagnostics

enum ViewModelConstructorDiagnostic: String, DiagnosticMessage {
    case notAStruct
    case missingParameterlessInit

    var severity: DiagnosticSeverity {
        .error
    }

    var message: String {
        switch self {
        case .notAStruct:
            return "@ViewModelConstructor can only be applied to structs"
        case .missingParameterlessInit:
            return "@ViewModelConstructor requires a parameterless init()"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "ViewModelConstructorMacros", id: rawValue)
    }
}
