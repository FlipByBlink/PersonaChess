import SwiftUI

//TODO: 要動作確認

struct HandleGroupImmersion: ViewModifier {
    @EnvironmentObject var model: AppModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    var kind: Self .Kind
    
    func body(content: Content) -> some View {
        content
            .onChange(of: self.model.isImmersiveSpaceModePreferred) { _, newValue in
                switch self.kind {
                    case .window:
                        if newValue == true {
                            Task {
                                await self.openImmersiveSpace(id: "immersiveSpace")
                            }
                        }
                    case .immersiveSpace:
                        if newValue != true {
                            Task {
                                await self.dismissImmersiveSpace()
                            }
                        }
                }
            }
    }
    
    init(_ kind: Self.Kind) {
        self.kind = kind
    }
    
    enum Kind {
        case window,
             immersiveSpace
    }
}
