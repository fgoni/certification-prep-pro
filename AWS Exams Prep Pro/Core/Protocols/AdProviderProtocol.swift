import Foundation
import Combine

/// Protocol defining advertising capabilities
/// Can be implemented by any ad provider (AdMob, Unity Ads, etc.)
/// This protocol enables decoupling of ad functionality from the rest of the app
public protocol AdProviderProtocol: ObservableObject {
    /// Indicates whether an ad is currently loaded and ready to show
    var isAdLoaded: Bool { get }

    /// Loads an ad asynchronously
    /// This method should load the ad and update isAdLoaded when ready
    func loadAd()

    /// Shows a loaded ad and calls completion with success/failure
    /// - Parameter completion: Called with true if user earned reward, false otherwise
    func showAd(completion: @escaping (Bool) -> Void)
}
