@attached(member, names: arbitrary)
@attached(extension, conformances: ViewModelConstructable)
public macro ViewModelConstructor() = #externalMacro(
    module: "ViewModelConstructorMacros",
    type: "ViewModelConstructorMacro"
)
