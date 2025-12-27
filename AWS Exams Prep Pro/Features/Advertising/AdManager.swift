import SwiftUI
import GoogleMobileAds
import Combine

/// AdMob implementation of AdProviderProtocol
/// Completely independent - zero dependencies on other app features
/// This module can be extracted to a separate Swift package if needed
final class AdManager: NSObject, AdProviderProtocol {
    // MARK: - Singleton
    static let shared = AdManager()

    // MARK: - Properties
    private let configuration: AdConfiguration
    @Published private(set) var isAdLoaded = false

    private var rewardedInterstitialAd: RewardedInterstitialAd?
    private var completionHandler: ((Bool) -> Void)?

    // MARK: - Initialization
    private override init() {
        self.configuration = .default
        super.init()
        loadAd()
    }

    /// Initialize with custom configuration (for testing purposes)
    /// - Parameter configuration: Custom ad configuration
    func configure(with configuration: AdConfiguration) {
        // Store configuration if needed in future
    }

    // MARK: - AdProviderProtocol Implementation
    func loadAd() {
        let request = Request()
        RewardedInterstitialAd.load(
            with: configuration.currentAdUnitID,
            request: request
        ) { [weak self] ad, error in
            guard let self = self else { return }

            if let error = error {
                print("Failed to load ad: \(error.localizedDescription)")
                self.completionHandler?(false)
                return
            }

            self.rewardedInterstitialAd = ad
            self.isAdLoaded = true
            self.rewardedInterstitialAd?.fullScreenContentDelegate = self
        }
    }

    func showAd(completion: @escaping (Bool) -> Void) {
        completionHandler = completion

        guard let ad = rewardedInterstitialAd else {
            loadAd()
            completion(false)
            return
        }

        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            completion(false)
            return
        }

        ad.present(from: rootViewController) {
            // User earned reward
            self.completionHandler?(true)
        }
    }

    // MARK: - Legacy Support
    /// Legacy method name for backward compatibility during migration
    /// Once refactoring is complete, views should use showAd() instead
    func showRewardedInterstitialAd(completion: @escaping (Bool) -> Void) {
        showAd(completion: completion)
    }
}

// MARK: - FullScreenContentDelegate
extension AdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        rewardedInterstitialAd = nil
        loadAd()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present: \(error.localizedDescription)")
        rewardedInterstitialAd = nil
        completionHandler?(false)
        loadAd()
    }
}
