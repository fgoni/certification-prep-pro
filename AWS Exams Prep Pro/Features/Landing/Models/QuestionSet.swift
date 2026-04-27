import Foundation
import SwiftUI

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

    /// Short certification name shown in cert selector card.
    var shortName: String {
        switch self {
        case .cloudPractitioner: return "Cloud Practitioner"
        case .softwareArchitectAssociate: return "Solutions Architect Associate"
        case .developerAssociate: return "Developer Associate"
        case .sysOpsAssociate: return "SysOps Administrator Associate"
        }
    }

    var vendor: String { "AWS" }

    var code: String {
        switch self {
        case .cloudPractitioner: return "CLF-C02"
        case .softwareArchitectAssociate: return "SAA-C03"
        case .developerAssociate: return "DVA-C02"
        case .sysOpsAssociate: return "SOA-C02"
        }
    }

    var brandColor: Color { Color(hex: "#FF9900") }
}
