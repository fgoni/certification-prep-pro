# AWS Exams Prep Pro - CLAUDE.md

iOS app for AWS certification exam preparation with interactive quizzes and progress tracking.

## 🚀 Automatic Testing Workflow

**Important:** After completing iOS changes, Claude automatically tests the app in the simulator:

```bash
~/.claude/scripts/run-ios-simulator.sh -p . -d "iPhone 16"
```

This means:
- ✅ Code is built and compiled
- ✅ App launches in iOS Simulator
- ✅ Changes are immediately visible and testable
- ✅ No need to click Run in Xcode

**You can test on different devices:**
```bash
# iPhone 15
~/.claude/scripts/run-ios-simulator.sh -p . -d "iPhone 15"

# iPhone 16 Pro
~/.claude/scripts/run-ios-simulator.sh -p . -d "iPhone 16 Pro"

# iPad Pro
~/.claude/scripts/run-ios-simulator.sh -p . -d "iPad Pro"
```

## 📱 Project Overview

**Type**: iOS Native App (Swift + SwiftUI)
**Target iOS**: 14.0+
**Main Framework**: SwiftUI + SwiftData
**Ad Integration**: Google Mobile Ads SDK

## 🎓 Supported Certifications

1. **AWS Cloud Practitioner** - 900+ questions
2. **AWS Developer Associate** - 800+ questions
3. **AWS SysOps Administrator Associate** - 1000+ questions
4. **AWS Solutions Architect Associate** - 1200+ questions

## 🏗️ Architecture

**Pattern**: MVVM with SwiftUI + Protocol-Oriented Design

**Key Layers:**
- **Views**: SwiftUI components for UI
- **ViewModels**: Business logic and state management
- **Services**: Quiz loading, result management, ad handling
- **Models**: Quiz question, results, configuration
- **Managers**: Ad management, quiz limits

**State Management:**
- SwiftUI `@State`, `@StateObject` for local state
- SwiftData for persistent storage
- Published properties for observable state

## 📁 Project Structure

```
certification-prep-pro/
├── CLAUDE.md (this file)
├── Podfile (CocoaPods dependencies)
├── AWS Exams Prep Pro.xcodeproj/
│
├── AWS Exams Prep Pro/           # Main app source
│   ├── App/
│   │   └── AWS_Exams_Prep_ProApp.swift
│   │
│   ├── Core/
│   │   ├── Models/
│   │   │   ├── QuizQuestion.swift
│   │   │   └── QuizResult.swift
│   │   └── Protocols/
│   │       ├── AdProviderProtocol.swift
│   │       ├── QuizLimitProviderProtocol.swift
│   │       └── PersistenceProtocol.swift
│   │
│   ├── Features/
│   │   ├── Advertising/
│   │   │   ├── AdManager.swift
│   │   │   └── AdConfiguration.swift
│   │   │
│   │   ├── QuizLimit/
│   │   │   ├── QuizLimitManager.swift
│   │   │   └── QuizLimitConfiguration.swift
│   │   │
│   │   ├── Landing/
│   │   │   ├── Views/
│   │   │   │   ├── LandingScreenView.swift
│   │   │   │   ├── QuizLimitBar.swift
│   │   │   │   └── ExamSelectorView.swift
│   │   │   ├── ViewModels/
│   │   │   │   └── LandingViewModel.swift
│   │   │   └── Models/
│   │   │       └── QuestionSet.swift
│   │   │
│   │   ├── Quiz/
│   │   │   ├── Views/
│   │   │   │   ├── QuizView.swift
│   │   │   │   └── CelebrationTrophy.swift
│   │   │   ├── Services/
│   │   │   │   ├── QuestionLoader.swift
│   │   │   │   └── QuizQuestions.swift
│   │   │   └── ViewModels/
│   │   │
│   │   ├── Results/
│   │   │   ├── Views/
│   │   │   │   └── HistoricalResultsView.swift
│   │   │   ├── ViewModels/
│   │   │   └── Services/
│   │   │       └── QuizResultManager.swift
│   │   │
│   │   └── Celebration/
│   │       ├── Models/
│   │       │   └── Confetti.swift
│   │       └── Views/
│   │           ├── ConfettiView.swift
│   │
│   └── Resources/
│       ├── QuestionSets/
│       │   ├── cloud-practitioner-questions.json
│       │   ├── developer-associate-questions.json
│       │   ├── software-architect-associate-questions.json
│       │   └── sysops-associate-questions.json
│       └── Assets.xcassets
│
├── Tests/
│   └── AWS Exams Prep ProTests/
│
└── UITests/
    └── AWS Exams Prep ProUITests/
```

## 🔧 Development Guidelines

### Code Style

- **Swift Conventions**: Use Swift naming conventions (lowerCamelCase for vars/functions, UpperCamelCase for types)
- **File Organization**: One primary type per file; extensions in separate files if complex
- **Comments**: Document complex logic only; self-documenting code is preferred
- **Formatting**: Use Xcode's built-in formatting (Editor → Structure → Re-Indent)

### Features Overview

#### 1. Quiz System
- Multiple quiz modes: Quick Quiz (20 questions), Full Quiz (65 questions)
- Timer-based quizzes with pause/resume
- Multiple correct answers support
- Detailed explanations after each question

#### 2. Quiz Limiting
- 3 quiz attempts per day (configured in QuizLimitConfiguration)
- Daily reset at midnight
- Rewarded ads unlock additional attempts
- Visual display of remaining attempts and time until reset

#### 3. Ad Integration
- Google Mobile Ads SDK integration
- Rewarded interstitial ads for unlocking quiz attempts
- Test ad unit IDs (Debug) and production IDs (Release)
- Fully decoupled via AdProviderProtocol

#### 4. Results Tracking
- Persistent storage with SwiftData
- Score tracking (percentage and correct count)
- Time tracking (time spent vs. time limit)
- Historical view of all past attempts

#### 5. UI/UX
- Celebration trophy and confetti on passing
- Exam selector with visual feedback
- Progress indicators
- Error handling with user-friendly messages

## 🔑 Key Technologies

| Technology | Purpose |
|-----------|---------|
| SwiftUI | Modern UI framework |
| SwiftData | Local data persistence |
| Google Mobile Ads SDK | Rewarded ad integration |
| CocoaPods | Dependency management |
| Xcode 15+ | Development IDE |

## 📝 Code Guidelines

### Protocol Usage

All feature modules should depend on protocols, not concrete implementations:

```swift
// ✅ Good - depends on protocol
class LandingViewModel {
    let adProvider: AdProviderProtocol
    init(adProvider: AdProviderProviderProtocol = AdManager.shared) {
        self.adProvider = adProvider
    }
}

// ❌ Bad - tight coupling
class LandingViewModel {
    func watchAd() {
        AdManager.shared.showRewardedInterstitialAd { ... }
    }
}
```

### SwiftData Usage

Use SwiftData for persistent app state:
- Quiz attempt tracking
- Historical results
- User preferences

### Views & ViewModels

- Views should be dumb (display only)
- ViewModels contain business logic
- Dependency injection in init methods
- Use `@StateObject` for ViewModel lifecycle

## 🧪 Testing Workflow

### Automatic Simulator Testing

After Claude completes work:
```bash
~/.claude/scripts/run-ios-simulator.sh -p . -d "iPhone 16"
```

The app will:
1. Build successfully with xcodebuild
2. Launch in the iOS Simulator
3. Be ready for manual testing

### Manual Testing Checklist

After changes, verify:
- [ ] App compiles without warnings
- [ ] App launches without crashes
- [ ] Feature works as expected
- [ ] No console errors or warnings
- [ ] UI responsive on different devices
- [ ] Ads load and display correctly
- [ ] Quiz limit system works
- [ ] Results persist properly

## 🐛 Debugging Tips

### Build Issues
```bash
# Clean build if stuck
rm -rf .derivedData
~/.claude/scripts/run-ios-simulator.sh -p .

# Check Xcode errors
xcodebuild clean build -scheme "AWS Exams Prep Pro"
```

### Runtime Issues
- Check Xcode console for errors/warnings
- Use Xcode debugger for step-through debugging
- Add print statements for logging
- Test on actual devices if simulator behaves differently

### Ad Issues
- Use test ad unit IDs in Debug configuration
- Check GoogleMobileAds pod is updated
- Verify Info.plist has required ad settings

## 📦 Dependencies

### CocoaPods
- **Google-Mobile-Ads-SDK**: Rewarded interstitial ads

### Swift Standard Library
- SwiftUI
- SwiftData
- Foundation

## 🚨 Important Notes

1. **AdManager** is fully decoupled - changes to ad provider won't affect views
2. **Quiz Questions** are loaded from JSON - easy to update without code changes
3. **SwiftData** handles persistence - no manual UserDefaults management needed
4. **Protocols** enable testing with mock objects
5. **Color scheme** should be tested on both light and dark modes

## 📊 Build Configurations

### Debug
- Test ad unit IDs
- Verbose logging enabled
- Full debug symbols

### Release
- Production ad unit IDs
- Optimized for performance
- No debug output

Build Release:
```bash
~/.claude/scripts/run-ios-simulator.sh -p . -c Release
```

## 🔄 Common Tasks

### Add New Exam Set
1. Add JSON file to `Resources/QuestionSets/`
2. Add case to `QuestionSet` enum in `Features/Landing/Models/QuestionSet.swift`
3. Add switch case in `LandingViewModel` to load the new set
4. Rebuild and test

### Modify Quiz Rules
- Quiz duration: Change `timeLimit` parameter in `QuizView` init
- Questions per quiz: Change count in `QuizView` filtering logic
- Attempt limits: Update `QuizLimitConfiguration.maxAttempts`

### Update Ad Unit IDs
Edit `Features/Advertising/AdConfiguration.swift`:
```swift
static let `default` = AdConfiguration(
    testAdUnitID: "...",
    productionAdUnitID: "..."
)
```

## 🎯 Development Workflow

```
1. Task: "Add feature X"
   ↓
2. Make code changes
   ↓
3. Claude runs simulator:
   ~/.claude/scripts/run-ios-simulator.sh -p . -d "iPhone 16"
   ↓
4. App launches automatically
   ↓
5. You test feature X
   ↓
6. ✅ Done!
```

## 📞 Support & Documentation

For iOS simulator script help:
- Quick reference: `~/.claude/scripts/QUICK-REFERENCE.txt`
- Full docs: `~/.claude/scripts/RUN-IOS-SIMULATOR-README.md`
- Integration guide: `~/.claude/scripts/INTEGRATION-GUIDE.md`

---

**Last Updated**: December 27, 2024
**Status**: Active Development
**Maintainer**: Facundo
