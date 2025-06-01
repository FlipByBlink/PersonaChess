//
//  RolePicker.swift
//  2025/06/01
//

extension MenuViewDuring3DMode {
    private func rolePicker() -> some View {
        Self.RowView(title: "Role") {
            if self.model.myRole != nil {
                Button {
                    self.model.set(role: nil)
                } label: {
                    Label("Audience", systemImage: "xmark")
                        .labelStyle(.iconOnly)
                }
                .scaleEffect(0.8, anchor: .trailing)
                .buttonBorderShape(.circle)
            }
            Button("White") { self.model.set(role: .white) }
                .disabled(self.model.myRole == .white)
            Button("Black") { self.model.set(role: .black) }
                .disabled(self.model.myRole == .black)
        }
    }
}
