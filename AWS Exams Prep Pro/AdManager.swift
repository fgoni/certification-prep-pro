import SwiftUI
import GoogleMobileAds

class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()
    
    // Ad Unit IDs
    private let testAdUnitID = "ca-app-pub-3940256099942544/6978759866"
    private let productionAdUnitID = "ca-app-pub-2770959732100621/2655308252"
    
    // Current ad unit ID based on environment
    private var currentAdUnitID: String {
        #if DEBUG
        return testAdUnitID
        #else
        return productionAdUnitID
        #endif
    }
    
    @Published var isAdLoaded = false
    private var rewardedInterstitialAd: RewardedInterstitialAd?
    private var completionHandler: ((Bool) -> Void)?
    
    private override init() {
        super.init()
        loadRewardedInterstitialAd()
    }
    
    func loadRewardedInterstitialAd() {
        let request = Request()
        RewardedInterstitialAd.load(with: currentAdUnitID, request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Failed to load rewarded interstitial ad with error: \(error.localizedDescription)")
                self.completionHandler?(false)
                return
            }
            
            self.rewardedInterstitialAd = ad
            self.isAdLoaded = true
            self.rewardedInterstitialAd?.fullScreenContentDelegate = self
        }
    }
    
    func showRewardedInterstitialAd(completion: @escaping (Bool) -> Void) {
        completionHandler = completion
        
        if let ad = rewardedInterstitialAd {
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                ad.present(from: rootViewController) {
                    // Reward the user here
                    self.completionHandler?(true)
                }
            } else {
                completionHandler?(false)
            }
        } else {
            loadRewardedInterstitialAd()
            completionHandler?(false)
        }
    }
}

// MARK: - FullScreenContentDelegate
extension AdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        rewardedInterstitialAd = nil
        loadRewardedInterstitialAd()
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present with error: \(error.localizedDescription)")
        rewardedInterstitialAd = nil
        completionHandler?(false)
        loadRewardedInterstitialAd()
    }
} 
