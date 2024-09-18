// ContentView.swift

import SwiftUI

struct ContentView: View {
    @AppStorage("userAppleID") var storedAppleID: String = ""
    @EnvironmentObject var appModel: AppModel

    var body: some View {
        VStack {
            if appModel.isMatched, let matchedAppleID = appModel.matchedAppleID {
                VStack(spacing: 20) {
                    Text("Connected with")
                        .font(.headline)
                    Text(matchedAppleID)
                        .font(.title)
                        .bold()

                    Button(action: {
                        initiateFaceTimeCall(to: matchedAppleID)
                    }) {
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundColor(.white)
                            Text("Start FaceTime Call")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
                .padding()
            } else {
                VStack {
                    Text("Waiting for a match...")
                        .font(.headline)
                        .padding()
                    ProgressView("Searching for a match...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                }
            }
        }
        .padding()
        .onAppear {
            // If user is already registered, request a match
            if !storedAppleID.isEmpty && !appModel.isMatched {
                requestMatch()
            }
        }
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

    func initiateFaceTimeCall(to appleID: String) {
        SharePlayProvider.initiateFaceTimeCall(to: appleID)
    }
}
