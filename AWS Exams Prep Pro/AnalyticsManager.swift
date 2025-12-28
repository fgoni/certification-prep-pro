import Foundation
#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

/// Manages Firebase Analytics events throughout the app
class AnalyticsManager {
    static let shared = AnalyticsManager()

    private init() {}

    // MARK: - Quiz Events

    /// Track when user starts a quiz
    func trackQuizStarted(examSet: String, quizType: String) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent("quiz_started", parameters: [
            "exam_set": examSet,
            "quiz_type": quizType,
            AnalyticsParameterTimestamp: Int(Date().timeIntervalSince1970)
        ])
        #endif
    }

    /// Track when user completes a quiz
    func trackQuizCompleted(
        examSet: String,
        score: Int,
        totalQuestions: Int,
        timeSpent: Int,
        passed: Bool
    ) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent("quiz_completed", parameters: [
            "exam_set": examSet,
            "score": score,
            "total_questions": totalQuestions,
            "time_spent_seconds": timeSpent,
            "passed": passed,
            AnalyticsParameterTimestamp: Int(Date().timeIntervalSince1970)
        ])
        #endif
    }

    /// Track when user abandons a quiz
    func trackQuizAbandoned(examSet: String, questionsAttempted: Int) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent("quiz_abandoned", parameters: [
            "exam_set": examSet,
            "questions_attempted": questionsAttempted,
            AnalyticsParameterTimestamp: Int(Date().timeIntervalSince1970)
        ])
        #endif
    }

    // MARK: - Navigation Events

    /// Track exam selection
    func trackExamSelected(examSet: String) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent("exam_selected", parameters: [
            "exam_set": examSet
        ])
        #endif
    }

    /// Track when user views historical results
    func trackHistoricalResultsViewed() {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent("historical_results_viewed", parameters: [:])
        #endif
    }

    // MARK: - Ad Events

    /// Track when user watches a rewarded ad
    func trackRewardedAdWatched(outcome: String) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent("rewarded_ad_watched", parameters: [
            "outcome": outcome // "completed" or "skipped"
        ])
        #endif
    }

    /// Track when user attempts to watch ad but limit is reached
    func trackAdLimitReached() {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent("ad_limit_reached", parameters: [:])
        #endif
    }

    // MARK: - Feature Usage

    /// Track when feedback is submitted
    func trackFeedbackSubmitted(category: String) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent("feedback_submitted", parameters: [
            "category": category
        ])
        #endif
    }

    /// Track custom event
    func trackCustomEvent(_ name: String, parameters: [String: Any]? = nil) {
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(name, parameters: parameters)
        #endif
    }
}
