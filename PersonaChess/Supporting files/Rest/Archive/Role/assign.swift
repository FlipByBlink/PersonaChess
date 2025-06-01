//
//  asign.swift
//  2025/06/01
//

extension AppModel {
#if os(visionOS)
    func set(role: CustomSpatialTemplate.Role?) {
        Task {
            if let systemCoordinator = await self.groupSession?.systemCoordinator {
                if let role {
                    systemCoordinator.assignRole(role)
                } else {
                    systemCoordinator.resignRole()
                }
                self.myRole = role
            }
        }
    }
#endif
}
