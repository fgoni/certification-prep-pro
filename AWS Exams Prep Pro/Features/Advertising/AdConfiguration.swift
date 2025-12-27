import Foundation

/// Configuration for ad provider
/// Separates configuration from implementation
/// Allows ad unit IDs to be changed without modifying AdManager code
public struct AdConfiguration {
    let testAdUnitID: String
    let productionAdUnitID: String

    /// Returns the appropriate ad unit ID based on build configuration
    var currentAdUnitID: String {
        #if DEBUG
        return testAdUnitID
        #else
        return productionAdUnitID
        #endif
    }

    /// Default configuration using Google Mobile Ads test and production IDs
    static let `default` = AdConfiguration(
        testAdUnitID: "ca-app-pub-3940256099942544/6978759866",
        productionAdUnitID: "ca-app-pub-2770959732100621/2655308252"
    )
}
