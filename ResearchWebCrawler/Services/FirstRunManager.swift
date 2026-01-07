//
//  FirstRunManager.swift
//  Research Web Crawler
//
//  Manages first-run experience and onboarding state
//

import Foundation
import Observation

@MainActor
@Observable
class FirstRunManager {
    static let shared = FirstRunManager()

    var isFirstRun: Bool
    var hasCompletedWelcome: Bool
    var hasCompletedTutorial: Bool

    private let defaults = UserDefaults.standard
    private let firstRunKey = "hasCompletedFirstRun"
    private let welcomeKey = "hasCompletedWelcome"
    private let tutorialKey = "hasCompletedTutorial"

    private init() {
        self.isFirstRun = !defaults.bool(forKey: firstRunKey)
        self.hasCompletedWelcome = defaults.bool(forKey: welcomeKey)
        self.hasCompletedTutorial = defaults.bool(forKey: tutorialKey)
    }

    func markWelcomeComplete() {
        hasCompletedWelcome = true
        defaults.set(true, forKey: welcomeKey)
    }

    func markTutorialComplete() {
        hasCompletedTutorial = true
        defaults.set(true, forKey: tutorialKey)
        defaults.set(true, forKey: firstRunKey)
        isFirstRun = false
    }

    func reset() {
        isFirstRun = true
        hasCompletedWelcome = false
        hasCompletedTutorial = false
        defaults.removeObject(forKey: firstRunKey)
        defaults.removeObject(forKey: welcomeKey)
        defaults.removeObject(forKey: tutorialKey)
    }

    func shouldShowWelcome() -> Bool {
        return isFirstRun && !hasCompletedWelcome
    }

    func shouldShowTutorial() -> Bool {
        return isFirstRun && hasCompletedWelcome && !hasCompletedTutorial
    }
}
