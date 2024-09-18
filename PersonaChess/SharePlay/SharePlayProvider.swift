// SharePlayProvider.swift

import LinkPresentation
import UIKit
import GroupActivities

enum SharePlayProvider {
    static func startGroupActivity(matchedAppleID: String) {
        let activity = AppGroupActivity(matchedAppleID: matchedAppleID)

        Task {
            do {
                let activated = try await activity.activate()
                if activated {
                    // Optionally handle further SharePlay activities here
                } else {
                    print("Activation not preferred.")
                }
            } catch {
                print("Failed to activate activity: \(error.localizedDescription)")
            }
        }
    }

    static func initiateFaceTimeCall(to appleID: String) {
        guard let url = URL(string: "facetime://\(appleID)") else {
            print("Invalid FaceTime URL.")
            return
        }
        DispatchQueue.main.async {
            UIApplication.shared.open(url) { success in
                if success {
                    print("FaceTime call initiated successfully.")
                } else {
                    print("Failed to initiate FaceTime call.")
                }
            }
        }
    }
}
