import Foundation

/// Available AWS certification question sets
enum QuestionSet: CaseIterable {
    case cloudPractitioner
    case softwareArchitectAssociate
    case developerAssociate
    case sysOpsAssociate

    var title: String {
        switch self {
        case .cloudPractitioner:
            return "AWS Cloud Practitioner"
        case .softwareArchitectAssociate:
            return "AWS Solutions Architect Associate"
        case .developerAssociate:
            return "AWS Developer Associate"
        case .sysOpsAssociate:
            return "AWS SysOps Administrator Associate"
        }
    }
}
