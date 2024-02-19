enum ToolbarPosition {
    case foreground, 
         front,
         right,
         left
}

extension ToolbarPosition: Codable, CaseIterable, Identifiable {
    var id: Self { self }
}
