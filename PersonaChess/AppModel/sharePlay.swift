import GroupActivities

extension AppModel {
    func configureGroupSessions() {
        Task {
            for await groupSession in AppGroupActivity.sessions() {
                self.sharedState.clear()
                self.sharedState.pieces.setPreset()
                self.entities.update(self.sharedState.pieces)
                
                self.groupSession = groupSession
                let reliableMessenger = GroupSessionMessenger(session: groupSession,
                                                              deliveryMode: .reliable)
                self.reliableMessenger = reliableMessenger
                
                let unreliableMessenger = GroupSessionMessenger(session: groupSession,
                                                                deliveryMode: .unreliable)
                self.unreliableMessenger = unreliableMessenger
                
                groupSession.$state
                    .sink {
                        if case .invalidated = $0 {
                            self.reliableMessenger = nil
                            self.unreliableMessenger = nil
                            self.tasks.forEach { $0.cancel() }
                            self.tasks = []
                            self.subscriptions = []
                            self.groupSession = nil
                            self.isImmersiveSpaceModePreferred = nil
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
                            try? await reliableMessenger.send(self.sharedState,
                                                              to: .only(newParticipants))
                        }
                    }
                    .store(in: &self.subscriptions)
                
                self.tasks.insert(
                    Task {
                        for await (message, _) in reliableMessenger.messages(of: SharedState.self) {
                            self.receive(message)
                        }
                    }
                )
                
                self.tasks.insert(
                    Task {
                        for await (message, _) in unreliableMessenger.messages(of: DragState.self) {
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
                                self.isImmersiveSpaceModePreferred = (immersionStyle != nil)
                                //TODO: 要動作確認
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
            try? await self.reliableMessenger?.send(self.sharedState)
        }
    }
    func sendMessage(_ dragState: DragState) {
        Task {
            try? await self.unreliableMessenger?.send(dragState)
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
    private func receive(_ message: DragState) {
        guard case .beginDrag(let initialDragState) = self.sharedState.pieces.currentAction else {
            print("Received dragState even though the action is not beginDrag. \(message)")
            return
        }
        guard initialDragState.id == message.id else {
            assertionFailure("ERROR: DragState IDs are different. \(message)")
            return
        }
        Task { @MainActor in
            self.entities.dragUpdate(self.sharedState.pieces,
                                     message)
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
