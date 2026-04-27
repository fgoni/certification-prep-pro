//
//  NotificationManager.swift
//  AWS Exams Prep Pro
//
//  Schedules nightly reminders to keep the user's quiz streak alive. The
//  schedule is refreshed at app launch, on toggle changes, and after every
//  quiz completion — so we can skip "today" once the user has already
//  practiced.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    enum Identifier {
        static let prefix = "daily-reminder-"
    }

    /// Reminder fires at this hour, local time. Hard-coded to 19:00 to match
    /// the onboarding copy ("~7pm, customizable later").
    private let reminderHour = 19
    private let reminderMinute = 0

    /// Number of upcoming nights to schedule. iOS caps pending local
    /// notifications at 64 per app, so 14 leaves plenty of headroom.
    private let scheduleHorizonDays = 14

    private let center = UNUserNotificationCenter.current()
    private let resultsManager: QuizResultsManager

    init(resultsManager: QuizResultsManager = .shared) {
        self.resultsManager = resultsManager
    }

    // MARK: - Authorization

    /// Requests permission. Returns true if granted (or already granted).
    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    /// Current system-level authorization status.
    func authorizationStatus() async -> UNAuthorizationStatus {
        await center.notificationSettings().authorizationStatus
    }

    // MARK: - Schedule lifecycle

    /// Refreshes the reminder schedule for the next `scheduleHorizonDays`
    /// nights. Cancels any existing pending reminders first. Skips today if
    /// the user has already completed a quiz.
    ///
    /// Safe to call repeatedly — it's idempotent.
    func refreshSchedule(now: Date = Date(), calendar: Calendar = .current) async {
        let enabled = UserDefaults.standard.bool(forKey: OnboardingKey.notificationsEnabled)
        guard enabled else {
            await cancelAll()
            return
        }

        let status = await authorizationStatus()
        guard status == .authorized || status == .provisional else {
            await cancelAll()
            return
        }

        await cancelAll()

        let activeDays = activeDaySet(calendar: calendar)
        let today = calendar.startOfDay(for: now)
        let streak = resultsManager.currentStreak(now: now, calendar: calendar)

        for offset in 0..<scheduleHorizonDays {
            guard let day = calendar.date(byAdding: .day, value: offset, to: today) else { continue }
            // Skip today if a quiz was already completed.
            if offset == 0 && activeDays.contains(today) { continue }

            var components = calendar.dateComponents([.year, .month, .day], from: day)
            components.hour = reminderHour
            components.minute = reminderMinute
            guard let fireDate = calendar.date(from: components), fireDate > now else { continue }

            let projectedStreak = projectedStreak(currentStreak: streak, hasQuizToday: activeDays.contains(today), offset: offset)
            let request = makeRequest(for: fireDate, offset: offset, projectedStreak: projectedStreak, calendar: calendar)
            try? await center.add(request)
        }
    }

    func cancelAll() async {
        let pending = await center.pendingNotificationRequests()
        let ids = pending
            .map(\.identifier)
            .filter { $0.hasPrefix(Identifier.prefix) }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Public hooks

    /// Called by `QuizResultsManager` after a result is saved.
    func quizCompleted() {
        Task { await refreshSchedule() }
    }

    // MARK: - Helpers

    private func activeDaySet(calendar: Calendar) -> Set<Date> {
        Set(resultsManager.fetchResults().map { calendar.startOfDay(for: $0.date) })
    }

    /// Best-effort projection of what the streak will be on the day this
    /// notification fires, assuming the user practices each day in between.
    /// We use it to write a richer notification body — it's never load-bearing.
    private func projectedStreak(currentStreak: Int, hasQuizToday: Bool, offset: Int) -> Int {
        // If today already has activity, the streak already includes today.
        // Otherwise, today's reminder is for *starting* day N+1.
        let base = hasQuizToday ? currentStreak : currentStreak
        return max(0, base + offset)
    }

    private func makeRequest(
        for fireDate: Date,
        offset: Int,
        projectedStreak: Int,
        calendar: Calendar
    ) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        let (title, body) = copy(projectedStreak: projectedStreak, isToday: offset == 0)
        content.title = title
        content.body = body
        content.sound = .default

        let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        let dayKey = calendar.startOfDay(for: fireDate).timeIntervalSince1970
        let id = "\(Identifier.prefix)\(Int(dayKey))"
        return UNNotificationRequest(identifier: id, content: content, trigger: trigger)
    }

    private func copy(projectedStreak: Int, isToday: Bool) -> (title: String, body: String) {
        let userName = UserDefaults.standard.string(forKey: OnboardingKey.userName)?
            .trimmingCharacters(in: .whitespaces) ?? ""
        let firstName = userName.split(separator: " ").first.map(String.init) ?? ""

        if projectedStreak >= 2 {
            let title = firstName.isEmpty
                ? "Day \(projectedStreak) streak ready 🔥"
                : "\(firstName), day \(projectedStreak) streak ready 🔥"
            let body = isToday
                ? "5 minutes is all it takes to keep it alive."
                : "Don't break the chain — squeeze in a Quick Quiz."
            return (title, body)
        }

        if projectedStreak == 1 {
            let title = "Keep your streak going 🔥"
            let body = "One more quiz tonight locks in day 2."
            return (title, body)
        }

        let title = firstName.isEmpty ? "Ready for tonight's quiz?" : "Ready, \(firstName)?"
        let body = "5 minutes is enough to start a streak."
        return (title, body)
    }
}
