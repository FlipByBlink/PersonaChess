import SwiftUI

struct FloorModeDividers: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        if self.model.floorMode {
            ZStack {
                HStack(spacing: 0) {
                    Spacer()
                    ForEach(1..<8, id: \.self) { _ in
                        Rectangle()
                            .foregroundStyle(.white)
                            .frame(width: 1.5)
                        Spacer()
                    }
                }
                VStack(spacing: 0) {
                    Spacer()
                    ForEach(1..<8, id: \.self) { _ in
                        Rectangle()
                            .foregroundStyle(.white)
                            .frame(height: 1.5)
                        Spacer()
                    }
                }
            }
        }
    }
}
