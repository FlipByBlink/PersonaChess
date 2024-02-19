import SwiftUI
import RealityKit

struct EntranceView: View {
    @EnvironmentObject var model: AppModel
    var body: some View {
        VStack(spacing: 0) {
            Group {
                if self.showHallView {
                    HallView()
                } else {
                    SharePlayMenu()
                }
            }
            .frame(width: EntranceWindow.size,
                   height: EntranceWindow.size - EntrancePiecesView.height)
            .frame(depth: EntranceWindow.size)
            EntrancePiecesView()
        }
    }
}

private extension EntranceView {
    private var showHallView: Bool {
#if targetEnvironment(simulator)
        true
#else
        self.model.groupSession != nil
#endif
    }
}
