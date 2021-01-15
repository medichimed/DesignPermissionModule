import UIKit

struct PermissionModule {
    static let shared = PermissionModule()

    private init() {}

    func grantPermission(to user: Caller, requiredAccess: AccessType, completion: @escaping(Result<String, GrantingPermissionError>)->()){
        //Grant permission for user considering required access type (read / write)
        //In case of success update user.hasAccess and user.accessType attributes in DB !

        //If success:
        completion(.success("Permission for user granted"))

        //Failure:
        completion(.failure(.denied("Permission for user denied")))
    }

    func grantPermission(to role: ModeratorRole, for user: Caller, requiredAccess: AccessType, completion: @escaping(Result<String, GrantingPermissionError>)->()){
        //Grant permission for role via URLSession or SDK of specific database storage (Firebase etc) considering required access type (read / write)
        //In case of success update user.hasAccess, user.accessType, user.role attributes in DB !

        //If success:
        completion(.success("Permission for role granted"))

        //Failure:
        completion(.failure(.denied("Permission for role denied")))
    }

    func hasPermission(user: Caller) -> Bool {
        //Manage request to get user.hasAccess details from DB
        return false
    }
}

class Caller {
    let id: UUID = UUID()
    let firstName: String
    let lastName: String
    var role: ModeratorRole?

    init(firstName: String, lastName: String, role: ModeratorRole? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.role = role
    }

    lazy var hasPermission: Bool = {
        return PermissionModule.shared.hasPermission(user: self)
    }()

    func updateCallerRole(with role: ModeratorRole) {
        self.role = role
    }

    func grantCallerPermision(to role: ModeratorRole, for access: AccessType) {
        PermissionModule.shared.grantPermission(to: role, for: self, requiredAccess: access) { (result) in
            switch result {
            case .success(let successMessage):
                //successMessage may be used for popUp or in logging
                print(successMessage)
                self.updateCallerRole(with: role)
            case .failure(let error):
                print(error)
                //handle error in prescribed way
            }
        }
    }

    func grantCallerPermission(to user: Caller, for access: AccessType) {
        PermissionModule.shared.grantPermission(to: user, requiredAccess: access) { (result) in
            switch result {
            case .success(let successMessage):
                print(successMessage)
                //successMessage may be used for popUp or in logging
            case .failure(let error):
                print(error)
                //handle error in prescribed way
            }
        }
    }

}

enum ModeratorRole {
    case admin, user, vendor, manager
}

enum GrantingPermissionError: Error {
    case denied(String) //there may be many types of errors
}

enum AccessType {
    case read, write
}

///Data Base model

/*
 Table Callers {
    id
    firstName
    lastName
    phoneNumber
    email
    role      //may bo none
    hasAccess //may be none
    acessType //may be none
}

 NOTE: to create more entities for DB I need more context details, at the moment I know for sure that there should be entitie with User (so called "Caller") details
 */
