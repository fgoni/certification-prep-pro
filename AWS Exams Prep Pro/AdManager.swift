import SwiftUI
import GoogleMobileAds

class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()
    
    @Published var isAdLoaded = false
    private var rewardedInterstitialAd: RewardedInterstitialAd?
    private var adLoadCompletion: ((Bool) -> Void)?
    
    private override init() {
        super.init()
        loadRewardedInterstitialAd()
    }
    
    func loadRewardedInterstitialAd() {
        let request = Request()
        RewardedInterstitialAd.load(with: "ca-app-pub-3940256099942544/6978759866", // Test ad unit ID for Rewarded Interstitials
                                     request: request,
                                     completionHandler: { [weak self] ad, error in
            if let error = error {
                print("Failed to load rewarded interstitial ad with error: \(error.localizedDescription)")
                self?.isAdLoaded = false
                return
            }
            
            self?.rewardedInterstitialAd = ad
            self?.isAdLoaded = true
            self?.rewardedInterstitialAd?.fullScreenContentDelegate = self
        })
    }
    
    func showRewardedInterstitialAd(completion: @escaping (Bool) -> Void) {
        adLoadCompletion = completion
        
        if isAdLoaded, let rewardedInterstitialAd = rewardedInterstitialAd {
            if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
                rewardedInterstitialAd.present(from: rootViewController) {
                    // Reward the user
                    completion(true)
                }
            }
        } else {
            // Ad not loaded, try to load it
            loadRewardedInterstitialAd()
            completion(false)
        }
    }
}

// MARK: - FullScreenContentDelegate
extension AdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        // Reload the ad for future use
        loadRewardedInterstitialAd()
    }
    
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present with error: \(error.localizedDescription)")
        isAdLoaded = false
        adLoadCompletion?(false)
        loadRewardedInterstitialAd()
    }
} 
