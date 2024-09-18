// ChessMenuView.swift

import SwiftUI

// Assuming you have these imports
import GroupActivities

struct ChessMenuView: View {
    @EnvironmentObject var appModel: AppModel
    @State private var selectedRole: CustomSpatialTemplate.Role? = nil

    var body: some View {
        VStack {
            Text("Select Your Role")
                .font(.headline)
                .padding()

            HStack {
                // White Role Button
                Button(action: {
                    selectedRole = .white
                    appModel.set(role: .white)
                }) {
                    Text("Play as White")
                        .foregroundColor(.white)
                        .padding()
                        .background(selectedRole == .white ? Color.blue : Color.gray)
                        .cornerRadius(8)
                }

                // Black Role Button
                Button(action: {
                    selectedRole = .black
                    appModel.set(role: .black)
                }) {
                    Text("Play as Black")
                        .foregroundColor(.white)
                        .padding()
                        .background(selectedRole == .black ? Color.blue : Color.gray)
                        .cornerRadius(8)
                }
            }
            .padding()

            // Additional UI components...

            // Example of using the role color in your UI
            if let role = selectedRole {
                Text("You have selected \(role.rawValue.capitalized) role")
                    .foregroundColor(role.color)
                    .padding()
            }
        }
    }
}

// Extension to map CustomSpatialTemplate.Role to Color
extension CustomSpatialTemplate.Role {
    var color: Color {
        switch self {
        case .white:
            return .white
        case .black:
            return .black
        case .participant:
            return .gray // Or any color you prefer
        }
    }
}
