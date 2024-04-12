import SwiftUI

struct FloorModeDividers: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        if self.model.floorMode {
            ZStack {
                HStack(spacing: 0) {
                    Spacer()
                    ForEach(1..<8, id: \.self) { _ in
                        Rectangle().frame(width: 1)
                        Spacer()
                    }
                }
                VStack(spacing: 0) {
                    Spacer()
                    ForEach(1..<8, id: \.self) { _ in
                        Rectangle().frame(height: 1)
                        Spacer()
                    }
                }
            }
        }
    }
}
