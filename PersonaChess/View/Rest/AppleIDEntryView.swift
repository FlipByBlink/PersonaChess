// AppleIDEntryView.swift

import SwiftUI

struct AppleIDEntryView: View {
    @State private var appleID: String = ""
    @State private var isSubmitting: Bool = false
    @AppStorage("userAppleID") var storedAppleID: String = ""
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        VStack {
            Text("Enter Your Apple ID")
                .font(.title)
                .padding()

            TextField("example@icloud.com", text: $appleID)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .autocapitalization(.none)
                .disableAutocorrection(true)

            Button(action: {
                isSubmitting = true
                submitAppleID(appleID: appleID)
            }) {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else {
                    Text("Submit")
                        .font(.headline)
                        .padding()
                }
            }
            .disabled(appleID.isEmpty || isSubmitting)
        }
        .padding()
    }

    func submitAppleID(appleID: String) {
        // Save locally
        storedAppleID = appleID

        // Send to backend
        guard let url = URL(string: "https://entermirage.com/register") else {
            print("Invalid URL.")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyData = ["appleID": appleID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyData)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
            }
            if let error = error {
                print("Error submitting Apple ID: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                print("No data received from server.")
                return
            }
            if let responseString = String(data: data, encoding: .utf8) {
                print("Server Response: \(responseString)")
            }

            // Automatically request a match
            requestMatch()
        }.resume()
    }

    func requestMatch() {
        guard let url = URL(string: "https://entermirage.com/match") else {
            print("Invalid URL.")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyData = ["appleID": storedAppleID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyData)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error requesting match: \(error.localizedDescription)")
                return
            }
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("Invalid response from server.")
                return
            }

            if let matchedAppleID = json["matchedAppleID"] as? String {
                DispatchQueue.main.async {
                    appModel.isMatched = true
                    appModel.matchedAppleID = matchedAppleID
                    // Optionally, initiate SharePlay or other activities here
                }
            } else if let message = json["message"] as? String {
                print(message)
                // Retry after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    requestMatch()
                }
            } else {
                print("Unexpected response from server.")
            }
        }.resume()
    }
}
