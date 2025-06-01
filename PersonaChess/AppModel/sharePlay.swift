import GroupActivities

extension AppModel {
    func configureGroupSessions() {
        Task {
            for await groupSession in AppGroupActivity.sessions() {
                self.sharedState.clear()
                self.sharedState.pieces.setPreset()
                self.entities.update(self.sharedState.pieces)
                
                self.groupSession = groupSession
                let messenger = GroupSessionMessenger(session: groupSession)
                self.messenger = messenger
                
                groupSession.$state
                    .sink {
                        if case .invalidated = $0 {
                            self.messenger = nil
                            self.tasks.forEach { $0.cancel() }
                            self.tasks = []
                            self.subscriptions = []
                            self.groupSession = nil
                            self.spatialSharePlaying = nil
                            self.sharedState.clearAllLog()
                            self.sharedState.pieces.setPreset()
                            self.sharedState.mode = .localOnly
                            self.entities.update(self.sharedState.pieces)
                        }
                    }
                    .store(in: &self.subscriptions)
                
                groupSession.$activeParticipants
                    .sink {
                        if $0.count == 1 { self.sharedState.mode = .sharePlay }
                        let newParticipants = $0.subtracting(groupSession.activeParticipants)
                        Task {
                            try? await messenger.send(self.sharedState,
                                                      to: .only(newParticipants))
                        }
                    }
                    .store(in: &self.subscriptions)
                
                self.tasks.insert(
                    Task {
                        for await (message, _) in messenger.messages(of: SharedState.self) {
                            self.receive(message)
                        }
                    }
                )
                
#if os(visionOS)
                self.tasks.insert(
                    Task {
                        if let systemCoordinator = await groupSession.systemCoordinator {
                            for await localParticipantState in systemCoordinator.localParticipantStates {
                                self.spatialSharePlaying = localParticipantState.isSpatial
                            }
                        }
                    }
                )
                
                self.tasks.insert(
                    Task {
                        if let systemCoordinator = await groupSession.systemCoordinator {
                            for await immersionStyle in systemCoordinator.groupImmersionStyle {
                                if immersionStyle != nil {
                                    //TODO: 実装
                                } else {
                                    //TODO: 実装
                                }
                            }
                        }
                    }
                )
                
                self.tasks.insert(
                    Task {
                        if let systemCoordinator = await groupSession.systemCoordinator {
                            var configuration = SystemCoordinator.Configuration()
                            configuration.supportsGroupImmersiveSpace = true
                            systemCoordinator.configuration = configuration
                            groupSession.join()
                        }
                    }
                )
#else
                groupSession.join()
#endif
            }
        }
    }
    func sendMessage() {
        Task {
            try? await self.messenger?.send(self.sharedState)
        }
    }
    func activateGroupActivity() {
        Task {
            do {
                let result = try await AppGroupActivity().activate()
                switch result {
                    case true: self.sharedState.mode = .sharePlay
                    default: break
                }
            } catch {
                print("Failed to activate activity: \(error)")
            }
        }
    }
}

private extension AppModel {
    private func receive(_ message: SharedState) {
        guard message.mode == .sharePlay else { return }
        Task { @MainActor in
            self.sharedState = message
            self.entities.update(self.sharedState.pieces)
        }
    }
}




//======== Reference ========
//Drawing content in a group session | Apple Developer Documentation
//https://developer.apple.com/documentation/groupactivities/drawing_content_in_a_group_session
//
//Design spatial SharePlay experiences - WWDC23 - Videos - Apple Developer
//https://developer.apple.com/videos/play/wwdc2023/10075
//
//Build spatial SharePlay experiences - WWDC23 - Videos - Apple Developer
//https://developer.apple.com/videos/play/wwdc2023/10087
//
//Customizing spatial Persona templates | Apple Developer Documentation
//https://developer.apple.com/documentation/groupactivities/customizing-spatial-persona-templates
