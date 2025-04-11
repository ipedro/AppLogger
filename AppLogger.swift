// MIT License
// 
// Copyright (c) 2022 Pedro Almeida
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// auto-generated file, do not edit directly

import AppLogger
import Combine
import Data
import Foundation
import Models
import SwiftUI
import UI
import UIKit
import XCGLogger
import class Data.AppLoggerViewModel
import class Data.DataObserver
import class UIKit.UIActivity

public actor AppLogger {
    private let dataStore = DataStore()
    
    private var coordinator: Coordinator?

    public static let current = AppLogger()
    
    /// Adds a log entry to the DataStore.
    ///
    /// - Parameter logEntry: The log entry to add.
    /// - Returns: A Boolean indicating whether the log entry was successfully added. Returns false if the log entry's ID already exists.
    @discardableResult
    public func addLogEntry(_ log: LogEntry) async -> Bool {
        await dataStore.addLogEntry(log)
    }
    
    public func present(
        animated: Bool = true,
        configuration: AppLoggerConfiguration = .init(),
        completion: (@Sendable () -> Void)? = nil
    ) async {
        guard coordinator == nil else {
            return
        }
        
        let observer = await dataStore.makeObserver()
        
        let coordinator = await Coordinator(
            dataObserver: observer,
            configuration: configuration,
            dismiss: dismiss(viewController:)
        )
        
        self.coordinator = coordinator
        
        await coordinator.present(
            animated: animated,
            completion: completion
        )
    }
    
    private func dismiss(viewController: UIViewController?) {
        coordinator = nil
        if let viewController {
            Task { @MainActor in
                viewController.dismiss(animated: true)
            }
        }
    }
}

@MainActor
final class Coordinator: NSObject {
    private let dataObserver: DataObserver
    
    private let configuration: AppLoggerConfiguration
    
    private let dismiss: (UIViewController?) -> Void
    
    private weak var viewController: UIViewController?
    
    init(
        dataObserver: DataObserver,
        configuration: AppLoggerConfiguration,
        dismiss: @escaping (_ viewController: UIViewController?) -> Void
    ) {
        self.dataObserver = dataObserver
        self.configuration = configuration
        self.dismiss = dismiss
    }
    
    private var keyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .filter(\.isKeyWindow)
            .first
    }
    
    private lazy var viewModel = AppLoggerViewModel(
        dataObserver: dataObserver,
        dismissAction: dismissAction
    )
    
    func present(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard
            viewController == nil,
            let presentingController = keyWindow?.rootViewController?.topPresentedViewController
        else {
            return
        }
        
        let viewController = makeViewController()
        print(type(of: viewController))
        self.viewController = viewController
        
        if let sheetPresentation = viewController.sheetPresentationController {
            sheetPresentation.detents = [.large(), .medium()]
            sheetPresentation.selectedDetentIdentifier = .medium
            sheetPresentation.prefersGrabberVisible = true
            sheetPresentation.prefersScrollingExpandsWhenScrolledToEdge = false
            sheetPresentation.largestUndimmedDetentIdentifier = .large
            sheetPresentation.delegate = self
        }
        
        presentingController.present(
            viewController,
            animated: animated,
            completion: completion
        )
    }
    
    private func dismissAction() {
        dismiss(viewController)
    }
    
    func makeViewController() -> UIViewController {
        if #available(iOS 16.0, *) {
            UIHostingController(rootView: makeNavigationStack())
        } else {
            // Fallback on earlier versions
            UIHostingController(rootView: makeNavigationView())
        }
    }
    
    func makeNavigationView() -> some View {
        injectDependencies(LogEntriesNavigation.makeView())
    }
    
    @available(iOS 16.0, *)
    func makeNavigationStack() -> some View {
        injectDependencies(LogEntriesNavigation.makeStack())
    }
    
    func injectDependencies(_ view: some View) -> some View {
        view
            .configuration(configuration)
            .environmentObject(viewModel)
    }
}

extension Coordinator: UISheetPresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // presentation has already ended, no need to send VC reference.
        dismiss(nil)
    }
}

private extension UIViewController {
    var topPresentedViewController: UIViewController {
        presentedViewController?.topPresentedViewController ?? self
    }
}
@_exported import Models

package final class AppLoggerViewModel: ObservableObject {
    @Published
    package var searchQuery: String = ""
    
    @Published
    package var showFilters: Bool {
        willSet {
            UserDefaults.standard.showFilters = newValue
        }
    }
    
    @Published
    package var sorting: LogEntry.Sorting
    
    @Published
    package var activityItem: ActivityItem?
    
    @Published
    package var activeFilters: Set<Filter> = []
    
    package var activeScope: [String] {
        var scope = activeFilters.sorted()
        if !searchQuery.trimmed.isEmpty {
            scope.append(searchQuery.trimmed.filter)
        }
        return scope.map(\.displayName)
    }
    
    @Published
    package var sources: [Filter] = []
    
    @Published
    package var categories: [Filter] = []
    
    @Published
    package var entries: [LogEntry.ID] = []
    
    package let dismissAction: @MainActor () -> Void
    
    private let dataObserver: DataObserver
    
    private var cancellables = Set<AnyCancellable>()
    
    package init(
        dataObserver: DataObserver,
        dismissAction: @escaping @MainActor () -> Void
    ) {
        self.dataObserver = dataObserver
        self.dismissAction = dismissAction
        self.sorting = UserDefaults.standard.sorting
        self.showFilters = UserDefaults.standard.showFilters
        
        setupListeners()
    }
    
    package func sourceColor(_ source: LogEntry.Source, for colorScheme: ColorScheme) -> Color {
        dataObserver.sourceColors[source.id]?[colorScheme]?.color() ?? .secondary
    }
    
    package func entrySource(_ id: LogEntry.ID) -> LogEntry.Source {
        dataObserver.entrySources[id]!
    }
    
    package func entryCategory(_ id: LogEntry.ID) -> LogEntry.Category {
        dataObserver.entryCategories[id]!
    }
    
    package func entryContent(_ id: LogEntry.ID) -> LogEntry.Content {
        dataObserver.entryContents[id]!
    }
    
    package func entryUserInfoKeys(_ id: LogEntry.ID) -> [LogEntry.UserInfoKey]? {
        dataObserver.entryUserInfoKeys[id]
    }
    
    package func entryUserInfoValue(_ id: LogEntry.UserInfoKey) -> String {
        dataObserver.entryUserInfoValues[id]!
    }
    
    package func entryCreatedAt(_ id: LogEntry.ID) -> Date {
        id.createdAt
    }
    
}

private extension AppLoggerViewModel {
    func setupListeners() {
        Publishers.CombineLatest(
            dataObserver.allCategories.debounceOnMain(for: 0.1).map { Set($0.map(\.filter)) },
            $activeFilters
        )
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] sources, filters in
            self.categories = sortFilters(sources, by: filters)
        }
        .store(in: &cancellables)
        
        Publishers.CombineLatest(
            dataObserver.allSources.debounceOnMain(for: 0.1).map { Set($0.map(\.filter)) },
            $activeFilters
        )
        .receive(on: DispatchQueue.main)
        .sink { [unowned self] sources, filters in
            self.sources = sortFilters(sources, by: filters)
        }
        .store(in: &cancellables)
        
        
        Publishers.CombineLatest4(
            dataObserver.allEntries.debounceOnMain(for: 0.2),
            $searchQuery.debounceOnMain(for: 0.3).map(\.trimmed),
            $activeFilters,
            $sorting
        )
        .receive(on: DispatchQueue.main)
        .map { [unowned self] allEntries, query, filters, sort in
            UserDefaults.standard.sorting = sort

            var result = filterEntries(allEntries, with: filters)
            if !query.isEmpty {
                result = filterEntries(result, with: [query.filter])
            }
            result = sortEntries(result, by: sort)
            return result
        }
        .sink { [unowned self] newValue in
            entries = newValue
        }
        .store(in: &cancellables)
    }
    
    func sortEntries(_ entries: [LogEntry.ID], by sorting: LogEntry.Sorting) -> [LogEntry.ID] {
        switch sorting {
        case .ascending: entries
        case .descending: entries.reversed()
        }
    }
    
    func sortFilters(_ filters: Set<Filter>, by selection: Set<Filter>) -> [Filter] {
        return filters.sorted { lhs, rhs in
            let lhsActive = selection.contains(lhs)
            let rhsActive = selection.contains(rhs)
            if lhsActive != rhsActive {
                return lhsActive && !rhsActive
            }
            return lhs < rhs
        }
    }
    
    func filterEntries(_ entries: [LogEntry.ID], with filters: Set<Filter>) -> [LogEntry.ID] {
        var result = entries
        
        if !filters.isEmpty {
            result = result.filter { id in
                return filterEntry(id, with: filters)
            }
        }
        
        return result
    }
    
    func filterEntry(_ id: LogEntry.ID, with filters: Set<Filter>) -> Bool {
        var source: LogEntry.Source {
            dataObserver.entrySources[id]!
        }
        
        var category: LogEntry.Category {
            dataObserver.entryCategories[id]!
        }
        
        var content: LogEntry.Content {
            dataObserver.entryContents[id]!
        }
        
        var userInfo: Set<String> {
            let keys = dataObserver.entryUserInfoKeys[id, default: []]
            var userInfo = Set(keys.map(\.key))
            for key in keys {
                if let value = dataObserver.entryUserInfoValues[key] {
                    userInfo.insert(value)
                }
            }
            return userInfo
        }
        
        for filter in filters {
            if filter.kind.contains(.source) {
                if source.matches(filter) { return true }
            }
            if filter.kind.contains(.category) {
                if category.matches(filter) { return true }
            }
            if filter.kind.contains(.content) {
                if content.matches(filter) { return true }
            }
            if filter.kind.contains(.userInfo) {
                if userInfo.contains(where: { $0.matches(filter) }) { return true }
            }
        }
        
        return false
    }
}

private extension Publisher {
    func debounceOnMain(
        for dueTime: DispatchQueue.SchedulerTimeType.Stride,
        options: DispatchQueue.SchedulerOptions? = nil
    ) -> Publishers.Debounce<Self, DispatchQueue> {
        debounce(for: dueTime, scheduler: DispatchQueue.main, options: options)
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private extension UserDefaults {
    var sorting: LogEntry.Sorting {
        get {
            let rawValue = integer(forKey: "AppLogger.sorting")
            return LogEntry.Sorting(rawValue: rawValue) ?? .descending
        }
        set {
            set(newValue.rawValue, forKey: "AppLogger.sorting")
        }
    }
    
    var showFilters: Bool {
        get {
            bool(forKey: "AppLogger.showFilters")
        }
        set {
            set(newValue, forKey: "AppLogger.showFilters")
        }
    }
}

package final class DataObserver: @unchecked Sendable {
    package init(
        allCategories: [LogEntry.Category] = [],
        allEntries: [LogEntry.ID] = [],
        allSources: [LogEntry.Source] = [],
        entryCategories: [LogEntry.ID : LogEntry.Category] = [:],
        entryContents: [LogEntry.ID : LogEntry.Content] = [:],
        entrySources: [LogEntry.ID : LogEntry.Source] = [:],
        entryUserInfos: [LogEntry.ID: LogEntry.UserInfo?] = [:],
        sourceColors: [LogEntry.Source.ID: DynamicColor] = [:]
    ) {
        self.allCategories = CurrentValueSubject(allCategories)
        self.allEntries = CurrentValueSubject(allEntries)
        self.allSources = CurrentValueSubject(allSources)
        self.entryCategories = entryCategories
        self.entryContents = entryContents
        self.entrySources = entrySources
        self.sourceColors = sourceColors
        
        for (id, userInfo) in entryUserInfos {
            guard let (keys, values) = userInfo?.denormalize(id: id) else {
                continue
            }
            entryUserInfoKeys[id] = keys
            for (key, value) in values {
                entryUserInfoValues[key] = value
            }
        }
    }
    
    /// A published array of log entry IDs from the data store.
    package let allEntries: CurrentValueSubject<[LogEntry.ID], Never>
    
    /// An array holding all log entry categories present in the store.
    package internal(set) var allCategories: CurrentValueSubject<[LogEntry.Category], Never>
    
    /// An array holding all log entry sources present in the store.
    package internal(set) var allSources: CurrentValueSubject<[LogEntry.Source], Never>
    
    /// A dictionary mapping log entry IDs to their corresponding category.
    package internal(set) var entryCategories: [LogEntry.ID: LogEntry.Category]
    
    /// A dictionary mapping log entry IDs to their corresponding content.
    package internal(set) var entryContents: [LogEntry.ID: LogEntry.Content]
    
    /// A dictionary mapping log entry IDs to their corresponding source.
    package internal(set) var entrySources: [LogEntry.ID: LogEntry.Source]
    
    /// A dictionary mapping log entry IDs to their corresponding userInfo keys.
    package internal(set) var entryUserInfoKeys = [LogEntry.ID: [LogEntry.UserInfoKey]]()
    
    /// A dictionary mapping log entry IDs to their corresponding userInfo values.
    package internal(set) var entryUserInfoValues = [LogEntry.UserInfoKey: String]()
    
    /// A dictionary mapping log source IDs to their corresponding color.
    package internal(set) var sourceColors = [LogEntry.Source.ID: DynamicColor]()
}

/// An actor that handles asynchronous storage and management of log entries.
/// It indexes log entries by their unique IDs and tracks associated metadata such as categories, sources, and content.
package actor DataStore {
    package init() {}
    
    weak private var observer: DataObserver?
    
    private var sourceColorGenerator = DynamicColorGenerator<LogEntry.Source>()
    
    /// A reactive subject that holds an array of log entry IDs.
    private var allEntries = Set<LogEntry.ID>()
    
    /// An array holding all log entry categories present in the store.
    private var allCategories = Set<LogEntry.Category>()
    
    /// An array holding all log entry sources present in the store.
    private var allSources = Set<LogEntry.Source>()
    
    /// A dictionary mapping log entry IDs to their corresponding category.
    private var entryCategories = [LogEntry.ID: LogEntry.Category]()
    
    /// A dictionary mapping log entry IDs to their corresponding content.
    private var entryContents = [LogEntry.ID: LogEntry.Content]()
    
    /// A dictionary mapping log entry IDs to their corresponding source.
    private var entrySources = [LogEntry.ID: LogEntry.Source]()
    
    /// A dictionary mapping log entry IDs to their corresponding userInfo keys.
    private var entryUserInfoKeys = [LogEntry.ID: [LogEntry.UserInfoKey]]()
    
    /// A dictionary mapping log entry IDs to their corresponding userInfo values.
    private var entryUserInfoValues = [LogEntry.UserInfoKey: String]()
    
    package func makeObserver() -> DataObserver {
        let observer = DataObserver()
        self.observer = observer
        defer {
            updateObserver()
        }
        return observer
    }
    
    /// Adds a log entry to the DataStore.
    ///
    /// - Parameter logEntry: The log entry to add.
    /// - Returns: A Boolean indicating whether the log entry was successfully
    /// added. Returns false if the log entry's ID already exists.
    @discardableResult
    package func addLogEntry(_ logEntry: LogEntry) -> Bool {
        let id = logEntry.id
        
        // O(1) lookup for duplicates.
        guard allEntries.insert(id).inserted else {
            return false
        }
        
        defer {
            updateObserver()
        }
        
        allCategories.insert(logEntry.category)
        allSources.insert(logEntry.source)
        
        sourceColorGenerator.generateColorIfNeeded(for: logEntry.source)
        
        entryCategories[id] = logEntry.category
        entryContents[id] = logEntry.content
        entrySources[id] = logEntry.source
        
        if let userInfo = logEntry.userInfo {
            let (keys, values) = userInfo.denormalize(id: id)
            entryUserInfoKeys[id] = keys
            for (key, value) in values {
                entryUserInfoValues[key] = value
            }
        }
        
        return true
    }
    
    private func updateObserver() {
        guard let observer else {
            return
        }
        
        defer {
            // push update to subscribers as last step
            observer.allEntries.send(allEntries.sorted())
            observer.allSources.send(allSources.sorted())
            observer.allCategories.send(allCategories.sorted())
        }
        
        observer.entryCategories = entryCategories
        observer.entryContents = entryContents
        observer.entrySources = entrySources
        observer.entryUserInfoKeys = entryUserInfoKeys
        observer.entryUserInfoValues = entryUserInfoValues
        observer.sourceColors = sourceColorGenerator.assignedColors
    }
}

extension LogEntry.UserInfo {
    func denormalize(id logID: LogEntry.ID) -> (keys: [LogEntry.UserInfoKey], values: [LogEntry.UserInfoKey: String]) {
        var keys = [LogEntry.UserInfoKey]()
        var values = [LogEntry.UserInfoKey: String]()
        
        for (key, value) in storage {
            let infoID = LogEntry.UserInfoKey(id: logID, key: key)
            keys.append(infoID)
            values[infoID] = value
        }
        
        return (keys, values)
    }
}

package struct DynamicColorGenerator<Element> where Element: Identifiable {
    private var unassignedColors = [DynamicColor]()
    
    private(set) var assignedColors: [Element.ID: DynamicColor] = [:]
    
    package init() {}
    
    package mutating func color(for element: Element) -> DynamicColor {
        generateColorIfNeeded(for: element)
    }
    
    @discardableResult
    mutating func generateColorIfNeeded(for element: Element) -> DynamicColor {
        if let color = assignedColors[element.id] {
            return color
        }
        if unassignedColors.isEmpty {
            unassignedColors = DynamicColor.makeColors(count: .random(in: 4...8)).shuffled()
        }
        
        let newColor = unassignedColors.removeFirst()
        assignedColors[element.id] = newColor
        return newColor
    }
}

private struct PreviewItem: Identifiable {
    let id: Int
}

@available(iOS 17, *)
#Preview {
    @Previewable @State
    var generator = DynamicColorGenerator<PreviewItem>()
    
    let items = (0..<1000).map(PreviewItem.init(id:))
    
    ScrollView {
        LazyVStack(spacing: 10) {
            ForEach(items) { item in
                HStack(spacing: .zero) {
                    ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                        (generator.color(for: item)[colorScheme]?.color() ?? .secondary)
                            .frame(height: 80)
                            .overlay {
                                Text(generator.color(for: item).description(with: colorScheme))
                                    .font(.caption2.monospaced().bold())
                                    .foregroundStyle(colorScheme == .dark ? .black : .white)
                            }
                    }
                }
            }
        }
        .padding(15)
    }
    .background(content: {
        HStack(spacing: .zero) {
            Rectangle().fill(Color.white.gradient)
            Rectangle().fill(Color.black.gradient)
        }
        .ignoresSafeArea(edges: .all)
    })
}

let log = XCGLogger.default

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    override init() {
        super.init()
        log.formatters = [AppLoggerFormatter()]
        log.setup(
            level: .verbose,
            showLogIdentifier: false,
            showFunctionName: true,
            showThreadName: false,
            showLevel: true,
            showFileNames: true,
            showLineNumbers: true,
            showDate: true,
            writeToFile: .none,
            fileLevel: nil
        )
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        log.verbose(
            userInfo: [
                "state": application.applicationState.debugDescription,
                "badge number": String(application.applicationIconBadgeNumber)
            ]
        )
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        log.verbose(connectingSceneSession)
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
        log.verbose(sceneSessions)
    }
}


extension UIApplication.State: @retroactive CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .active:
            return "Active"
        case .inactive:
            return "Inactive"
        case .background:
            return "Background"
        default:
            return "Default"
        }
    }
}

struct AppLoggerFormatter: LogFormatterProtocol {
    func format(logDetails: inout LogDetails, message: inout String) -> String {
        let logDetails = logDetails
        Task {
            await AppLogger.current.addLogEntry(
                LogEntry(
                    date: logDetails.date,
                    category: LogEntry.Category(logDetails.level.description),
                    source: {
                        if logDetails.fileName.isEmpty {
                            "XCGLogger"
                        } else {
                            LogEntry.Source(
                                (logDetails.fileName as NSString).lastPathComponent,
                                .file(line: logDetails.lineNumber)
                            )
                        }
                    }(),
                    content: LogEntry.Content(
                        function: logDetails.functionName,
                        message: logDetails.message,
                    ),
                    userInfo: logDetails.userInfo
                )
            )
        }
        return message
    }

    var debugDescription: String {
        "AppLoggerFormatter"
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    // Helper function to consolidate scene details for logging.
    private func sceneDetails(for scene: UIScene) -> [String: Any] {
        // Break down session and configuration details into smaller parts.
        var details: [String: Any] = [
            "persistentIdentifier": scene.session.persistentIdentifier,
            "name": scene.session.configuration.name!,
            "sessionRole": scene.session.configuration.role.rawValue,
            "activationState": {
                switch scene.activationState {
                case .background:
                    return "Background"
                case .foregroundActive:
                    return "Foreground Active"
                case .foregroundInactive:
                    return "Foreground Inactive"
                case .unattached:
                    return "Unattached"
                default:
                    return "Unknown"
                }
            }()
        ]
        
        if let windowScene = scene as? UIWindowScene {
            let trait = windowScene.traitCollection
            details["interfaceOrientation"] = windowScene.interfaceOrientation.rawValue
            details["screenBounds"] = windowScene.screen.bounds
            details["userInterfaceStyle"] = trait.userInterfaceStyle == .dark ? "dark" : "light"
            details["horizontalSizeClass"] = trait.horizontalSizeClass == .compact ? "compact" : "regular"
            details["verticalSizeClass"] = trait.verticalSizeClass == .compact ? "compact" : "regular"
            details["displayScale"] = trait.displayScale
            details["preferredContentSizeCategory"] = trait.preferredContentSizeCategory.rawValue
            details["windowsCount"] = windowScene.windows.count
            details["isFullScreen"] = windowScene.isFullScreen
        }
        
        return details
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Ensure the scene is a UIWindowScene
        guard let windowScene = (scene as? UIWindowScene) else {
            log.error("No window scene")
            return
        }
        
        // Log enriched scene details with smaller, extracted properties.
        log.info(userInfo: sceneDetails(for: scene))
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        log.info(userInfo: sceneDetails(for: scene))
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        log.info(userInfo: sceneDetails(for: scene))
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        log.info(userInfo: sceneDetails(for: scene))
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        log.info(userInfo: sceneDetails(for: scene))
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        log.info(userInfo: sceneDetails(for: scene))
    }
}

class ViewController: UIViewController {
    
    private lazy var presentButton = UIButton(
        configuration: .bordered(),
        primaryAction: UIAction(title: "Present Logger", handler: { action in
            Task { await AppLogger.current.present() }
            // Log only the action title instead of the entire action object.
            log.info(action.title, userInfo: [
                "discoverabilityTitle": action.discoverabilityTitle,
                "identifier": action.identifier.rawValue,
                "attributes": action.attributes.rawValue,
                "state": action.state.rawValue
            ])
        })
    )
    
    private lazy var presentLightButton = UIButton(
        configuration: .bordered(),
        primaryAction: UIAction(title: "Present Light Logger", handler: { action in
            Task { await AppLogger.current.present(configuration: .init(colorScheme: .light)) }
            // Log only the action title instead of the entire action object.
            log.info(action.title, userInfo: [
                "discoverabilityTitle": action.discoverabilityTitle,
                "identifier": action.identifier.rawValue,
                "attributes": action.attributes.rawValue,
                "state": action.state.rawValue
            ])
        })
    )
    
    private lazy var presentDarkButton = UIButton(
        configuration: .bordered(),
        primaryAction: UIAction(title: "Present Dark Logger", handler: { action in
            Task { await AppLogger.current.present(configuration: .init(colorScheme: .dark)) }
            log.info(action.title, userInfo: [
                "discoverabilityTitle": action.discoverabilityTitle,
                "identifier": action.identifier.rawValue,
                "attributes": action.attributes.rawValue,
                "state": action.state.rawValue
            ])
        })
    )
    
    private lazy var logErrorButton = UIButton(
        configuration: .bordered(),
        primaryAction: UIAction(title: "Log Error", handler: { action in
            // Log a small string message along with the action title.
            log.error("Error occurred", userInfo: [
                "code": 123,
                "domain": "example.com",
                "reason": "Something went wrong"
            ])
        })
    )
    
    private lazy var stackView = UIStackView(
        arrangedSubviews: [
            logErrorButton,
            presentButton,
            presentLightButton,
            presentDarkButton,
            UIView() // Extra view for layout purposes.
        ]
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = .init(
            top: 20,
            leading: 20,
            bottom: 20,
            trailing: 20
        )
        view.addSubview(stackView)
        view.layoutIfNeeded()
        
        // Log key details from the view controller without logging entire objects.
        log.info(userInfo: viewControllerDetails())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        stackView.frame = view.bounds
        log.verbose(userInfo: [
            "viewFrame": view.frame,
            "stackViewFrame": stackView.frame,
            "subviewsCount": view.allSuviews.count
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        log.verbose(userInfo: [
            "event": "viewWillAppear",
            "animated": animated,
            "currentViewFrame": view.frame
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        log.verbose(userInfo: [
            "event": "viewDidAppear",
            "animated": animated,
            "currentViewFrame": view.frame
        ])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        log.verbose(userInfo: [
            "event": "viewWillDisappear",
            "animated": animated,
            "currentViewFrame": view.frame
        ])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        log.verbose(userInfo: [
            "event": "viewDidDisappear",
            "animated": animated,
            "currentViewFrame": view.frame
        ])
    }
    
    /// Extracts key information about the view controller and its view.
    private func viewControllerDetails() -> [String: Any] {
        return [
            "className": String(describing: type(of: self)),
            "viewFrame": view.frame,
            "backgroundColor": view.backgroundColor?.description ?? "none",
            "subviewsCount": view.allSuviews.count,
            "stackViewAxis": stackView.axis == .horizontal ? "horizontal" : "vertical",
            "stackViewDistribution": stackView.distribution.rawValue,
            "stackViewArrangedSubviewsCount": stackView.arrangedSubviews.count
        ]
    }
}

private extension UIView {
    var allSuviews: [UIView] {
        subviews.flatMap { [$0] + $0.allSuviews }
    }
}

/// Represents an activity for presenting an ActivityView (Share sheet) via the `activitySheet` modifier
package struct ActivityItem {
    package var items: [Any]
    package var activities: [UIActivity]

    /// The
    /// - Parameters:
    ///   - items: The items to share via a `UIActivityViewController`
    ///   - activities: Custom activities you want to include in the sheet
    package init(items: Any..., activities: [UIActivity] = []) {
        self.items = items
        self.activities = activities
    }
}

public struct AppLoggerConfiguration: Sendable {
    public var accentColor: Color
    public var colorScheme: ColorScheme?
    public var emptyReasons: EmptyReasons = .init()
    public var icons: Icons = .init()
    public var navigationTitle: String

    public init(
        accentColor: Color = .secondary,
        colorScheme: ColorScheme? = nil,
        emptyReasons: EmptyReasons = .init(),
        icons: Icons = .init(),
        navigationTitle: String = "Logs"
    ) {
        self.accentColor = accentColor
        self.colorScheme = colorScheme
        self.emptyReasons = emptyReasons
        self.icons = icons
        self.navigationTitle = navigationTitle
    }
}

public extension AppLoggerConfiguration {
    struct EmptyReasons: Sendable {
        public var empty: String
        public var searchResults: String
        
        public init(
            empty: String = "No Entries Yet",
            searchResults: String = "No results matching"
        ) {
            self.empty = empty
            self.searchResults = searchResults
        }
    }

    struct Icons: Sendable {
        public var dismiss: String
        public var export: String
        public var filtersOff: String
        public var filtersOn: String
        public var sortAscending: String
        public var sortDescending: String
        
        public init(
            dismiss: String = "xmark.circle.fill",
            export: String = "square.and.arrow.up",
            filtersOff: String = "line.3.horizontal.decrease.circle",
            filtersOn: String = "line.3.horizontal.decrease.circle.fill",
            sortAscending: String = "text.line.last.and.arrowtriangle.forward", //"arrowtriangle.up",
            sortDescending: String = "text.line.first.and.arrowtriangle.forward" // "arrowtriangle.down"
        ) {
            self.dismiss = dismiss
            self.export = export
            self.filtersOff = filtersOff
            self.filtersOn = filtersOn
            self.sortAscending = sortAscending
            self.sortDescending = sortDescending
        }
    }
}

struct ConfigurationKey: EnvironmentKey {
    static let defaultValue: AppLoggerConfiguration = .init()
}

package extension EnvironmentValues {
    var configuration: AppLoggerConfiguration {
        get {
            self[ConfigurationKey.self]
        } set {
            self[ConfigurationKey.self] = newValue
        }
    }
}

package extension View {
    func configuration(_ configuration: AppLoggerConfiguration) -> some View {
        environment(\.configuration, configuration)
    }
}

package struct DynamicColor: Sendable {
    private let data: [ColorScheme: Components]
    
    private init(_ value: [ColorScheme: Components]) {
        data = value
    }
    
    package subscript(colorScheme: ColorScheme) -> Components? {
        data[colorScheme]
    }
    
    package func description(with colorScheme: ColorScheme) -> String {
        data[colorScheme]!.description
    }
    
    package struct Components: Sendable, CustomStringConvertible {
        let hue: CGFloat
        let saturation: CGFloat
        let brightness: CGFloat
        
        package var description: String {
            "H: \(hue)\nS: \(saturation)\nB: \(brightness)"
        }
        
        package func color() -> Color {
            Color(
                uiColor: UIColor(
                    hue: hue,
                    saturation: saturation,
                    brightness: brightness,
                    alpha: 1
                )
            )
        }
    }
    
    package static func makeColors(count: Int = 10) -> [DynamicColor] {
        let start: CGFloat = .random(in: 0...0.3)
        let end: CGFloat = .random(in: 0.8...1.2)
        let strideLength = (end - start) / CGFloat(count)
        
        return stride(from: start, to: end + strideLength, by: strideLength)
            .suffix(count)
            .map { hue in
                let saturation = CGFloat.random(in: 0.2...0.8)
                let brightness = CGFloat.random(in: 0.4...0.8)
                
                return DynamicColor(
                    ColorScheme.allCases.reduce(into: [:]) { dict, colorScheme in
                        let components = switch colorScheme {
                        case .dark:
                            Components(
                                hue: hue,
                                saturation: max(0.4, saturation * 1.1),
                                brightness: max(0.6, brightness * 1.5)
                            )
                        default:
                            Components(
                                hue: hue,
                                saturation: saturation / brightness,
                                brightness: brightness
                            )
                        }
                        
                        dict[colorScheme] = components
                    }
                )
            }
    }
}

@available(iOS 17, *)
#Preview {
    @Previewable @State
    var colors = DynamicColor.makeColors()
    
    VStack(spacing: 10) {
        ForEach(Array(colors.enumerated()), id: \.offset) { offset, color in
            HStack(spacing: .zero) {
                ForEach(ColorScheme.allCases, id: \.self) { colorScheme in
                    color[colorScheme]!.color().overlay {
                        Text(color.description(with: colorScheme))
                            .font(.caption2.monospaced().bold())
                            .foregroundStyle(colorScheme == .dark ? .black : .white)
                    }
                }
            }
        }
    }
    .safeAreaInset(edge: .bottom, spacing: 30, content: {
        Button("Generate Colors") {
            colors = DynamicColor.makeColors()
        }
        .buttonStyle(.borderedProminent)
    })
    .padding(15)
    .background(content: {
        HStack(spacing: .zero) {
            Rectangle().fill(Color.white.gradient)
            Rectangle().fill(Color.black.gradient)
        }
        .ignoresSafeArea(edges: .all)
    })
}

extension Filter {
    package struct Kind: CustomStringConvertible, Hashable, OptionSet {
        package let rawValue: Int8
        
        package var description: String {
            var components = [String]()
            if self.contains(.source) { components.append("source") }
            if self.contains(.category) { components.append("category") }
            if self.contains(.content) { components.append("content") }
            if self.contains(.userInfo) { components.append("userInfo") }
            return components.joined(separator: ", ")
        }
        
        package init(rawValue: Int8) {
            self.rawValue = rawValue
        }
        
        package static let source = Kind(rawValue: 1 << 0)
        package static let category = Kind(rawValue: 1 << 1)
        package static let content = Kind(rawValue: 1 << 2)
        package static let userInfo = Kind(rawValue: 1 << 3)
        
        package static let all: Kind = [
            .source,
            .category,
            .content,
            .userInfo,
        ]
    }
}

package struct Filter: Hashable {
    package let kind: Kind
    package let query: String
    package let displayName: String
    
    init(_ kind: Kind, query: String, displayName: String) {
        self.query = query
        self.kind = kind
        self.displayName = displayName
    }
}

extension Filter: Comparable {
    package static func < (lhs: Filter, rhs: Filter) -> Bool {
        lhs.query.localizedStandardCompare(rhs.query) == .orderedAscending
    }
}

extension Filter: ExpressibleByStringLiteral {
    package init(stringLiteral value: String) {
        self.query = value
        self.displayName = value
        self.kind = .all
    }
}
// MARK: - Filterable

package protocol Filterable {
    static var filterQuery: KeyPath<Self, String> { get }
    static var filterCriteriaOptional: KeyPath<Self, String?>? { get }
}

// MARK: - Filter Convertible

package protocol FilterConvertible: Filterable {
    static var filterDisplayName: KeyPath<Self, String> { get }
    static var filterKind: Filter.Kind { get }
}

package extension FilterConvertible {
    var filter: Filter {
        Filter(
            Self.filterKind,
            query: self[keyPath: Self.filterQuery],
            displayName: self[keyPath: Self.filterDisplayName]
        )
    }
}

// MARK: - Helpers

extension String: FilterConvertible {
    package static var filterKind: Filter.Kind { .all }
    package static var filterDisplayName: KeyPath<String, String> { \.self }
    package static var filterQuery: KeyPath<String, String> { \.self }
}


package extension Filterable {
    static var filterCriteriaOptional: KeyPath<Self, String?>? { nil }
    
    func matches(_ filter: Filter) -> Bool {
        let value = self[keyPath: Self.filterQuery]
        if value.localizedCaseInsensitiveContains(filter.query) {
            //print("Filter \(filter.kind):", filter.query, "–", "Match:", value)
            return true
        }
        
        if let keyPath = Self.filterCriteriaOptional, let optionalValue = self[keyPath: keyPath] {
            if optionalValue.localizedCaseInsensitiveContains(filter.query) {
                //print("Filter \(filter.kind):", filter.query, "–", "Match:", optionalValue)
                return true
            }
        }
        return false
    }
}

/// This file defines the LogEntry struct, which represents a log entry in the application.
///
/// A log entry that encapsulates the details for a single log event, including its source, category, and content.
public struct LogEntry: Identifiable, Sendable {
    
    /// A unique identifier for the log entry.
    public let id: ID
    
    /// The source from which the log entry originates.
    public let source: Source
    
    /// The category that describes the type or nature of the log entry.
    public let category: Category
    
    /// The actual content or message of the log entry.
    public let content: Content
    
    /// Additional information like a dictionary.
    public let userInfo: UserInfo?
    
    /// The date the log was created.
    public var createdAt: Date {
        id.createdAt
    }
}

public extension LogEntry {
    
    /// Creates a new instance of LogEntry with the given source, category, and content.
    ///
    /// - Parameters:
    ///   - date: The date the log was sent.
    ///   - category: The category or classification of the log entry.
    ///   - source: The source from which the log entry originates.
    ///   - content: The detailed content of the log entry.
    ///   - userInfo: An optional user info.
    init(
        date: Date = Date(),
        category: Category,
        source: Source,
        content: Content,
        userInfo: [String: Any]? = nil
    ) {
        self.id = ID(date: date)
        self.source = source
        self.category = category
        self.content = content
        self.userInfo = UserInfo(userInfo)
    }
    
    /// Creates a new instance of LogEntry with the given source, category, and content.
    ///
    /// - Parameters:
    ///   - date: The date the log was sent.
    ///   - category: The category or classification of the log entry.
    ///   - source: A custom source from which the log entry originates.
    ///   - content: The detailed content of the log entry.
    ///   - userInfo: An optional user info.
    init(
        date: Date = Date(),
        category: Category,
        source: some LogEntrySource,
        content: Content,
        userInfo: [String: Any]? = nil
    ) {
        self.id = ID(date: date)
        self.source = Source(source)
        self.category = category
        self.content = content
        self.userInfo = UserInfo(userInfo)
    }
}

package extension [LogEntry] {
    func valuesByID<V>(_ keyPath: KeyPath<LogEntry, V>) -> [LogEntry.ID: V] {
        reduce(into: [:]) { dict, entry in
            dict[entry.id] = entry[keyPath: keyPath]
        }
    }
}

public extension LogEntry.Category {
    static let verbose = Self("🗯", "Verbose")
    static let debug = Self("🔹", "Debug")
    static let info = Self("ℹ️", "Info")
    static let notice = Self("✳️", "Notice")
    static let warning = Self("⚠️", "Warning")
    static let error = Self("💥", "Error")
    static let severe = Self("💣", "Severe")
    static let alert = Self("‼️", "Alert")
    static let emergency = Self("🚨", "Emergency")
}

public extension LogEntry {
    /// A structure that represents a log entry category with an optional emoji and a debug name.
    ///
    /// It provides computed properties for representing the emoji as a string and for creating a display name by combining the emoji (if available) with the debug name.
    struct Category: Hashable, Sendable {
        /// An optional emoji associated with this log entry category.
        public let emoji: Character?
        /// A string identifier used for debugging and identifying the log entry category.
        public let name: String
        
        /// Initializes a new log entry category with the given debug name.
        ///
        /// - Parameter name: A string identifier for the category.
        public init(_ name: String) {
            self.emoji = nil
            self.name = name
        }
        
        /// Initializes a new log entry category with the given emoji and debug name.
        ///
        /// - Parameters:
        ///   - emoji: An emoji representing the category.
        ///   - name: A string identifier for the category.
        public init(_ emoji: Character, _ name: String) {
            self.emoji = emoji
            self.name = name
        }
    }
}

extension LogEntry.Category: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension LogEntry.Category: Comparable {
    public static func < (lhs: LogEntry.Category, rhs: LogEntry.Category) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}

extension LogEntry.Category: CustomStringConvertible {
    public var description: String {
        if let emoji {
            "\(emoji) \(name)"
        } else {
            name
        }
    }
}

extension LogEntry.Category: FilterConvertible {
    package static var filterKind: Filter.Kind { .category }
    package static var filterDisplayName: KeyPath<LogEntry.Category, String> { \.description }
    package static var filterQuery: KeyPath<LogEntry.Category, String> { \.name }
}
public extension LogEntry {
    struct Content: Sendable {
        public let function: String
        public let message: String?
        
        public init(
            function: String,
            message: String? = .none
        ) {
            self.function = function
            self.message = message
        }
    }
}

extension LogEntry.Content: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(function: value)
    }
}

extension LogEntry.Content: Filterable {
    package static var filterQuery: KeyPath<LogEntry.Content, String> {
        \.function
    }
    
    package static var filterableOptional: KeyPath<LogEntry.Content, String?> {
        \.message
    }
}

public extension LogEntry {
    struct ID: Hashable, Comparable, Sendable {
        private let rawValue = UUID()
        package let timestamp: TimeInterval
        
        package init(date: Date) {
            self.timestamp = date.timeIntervalSince1970
        }
        
        public static func < (lhs: ID, rhs: ID) -> Bool {
            lhs.timestamp < rhs.timestamp
        }
        
        /// The date the log was created.
        package var createdAt: Date {
            Date(timeIntervalSince1970: timestamp)
        }
    }
}
package extension LogEntry {
    enum Mock: Hashable, CaseIterable {
        case analytics
        case error
        case googleAnalytics
        case debug
        case notice
        case socialLogin
        case warning
        
        package func entry() -> LogEntry {
            switch self {
            case .analytics: analytics
            case .error: error
            case .googleAnalytics: googleAnalytics
            case .debug: debug
            case .notice: notice
            case .socialLogin: socialLogin
            case .warning: warning
            }
        }
        
        private var debug: LogEntry {
            LogEntry(
                category: .debug,
                source: Source("MyWebView", .file(line: 20)),
                content: Content(
                    function: "func didNavigate()",
                    message: "Navigation cancelled."
                ),
                userInfo: [
                    "url": "https://github.com",
                    "line": 20,
                    "file": "MyWebView",
                    "function": "didNavigate",
                    "reason": "Navigation cancelled."
                ]
            )
        }
        
        private var notice: LogEntry {
            LogEntry(
                category: .notice,
                source: Source("MyWebView", .file(line: 450)),
                content: Content(
                    function: "func didRefresh()",
                    message: "Page refreshed."
                ),
                userInfo: [
                    "line": 450,
                    "file": "MyWebView",
                    "function": "didRefresh"
                ]
            )
        }
        
        private var googleAnalytics: LogEntry {
            LogEntry(
                category: Category("📈", "Analytics"),
                source: "Google Analytics",
                content: "tracked event",
                userInfo: [
                    "customerID": "1234567890",
                    "screen": "Home"
                ]
            )
        }
        
        private var socialLogin: LogEntry {
            LogEntry(
                category: Category("👔", "Social Media"),
                source: Source("Facebook", .sdk(version: "12.2.1")),
                content: Content(
                    function: "Any Social Login",
                    message: "User logged in"
                ),
                userInfo: [
                    "custom_event": "1",
                    "environment": "dev",
                    "screenName": "Home",
                    "user_id": "3864579",
                    "userName": "John Doe",
                    "user_type": "premium",
                    "user_email": "johndoe@example.com",
                    "user_age": 25,
                    "user_location": "New York",
                    "user_gender": "male",
                    "user_country": "US",
                    "user_city": "New York",
                    "user_occupation": "Software Engineer",
                    "user_language": "en-US",
                    "user_timezone": "America/New_York",
                    "user_ip": "192.168.1.1",
                    "user_device": "iPhone 12 mini",
                    "user_browser": "Chrome",
                    "user_browser_version": "92.0.4515.159",
                    "user_os": "iOS",
                    "user_os_version": "14.5",
                    "user_referrer": "https://facebook.com",
                    "event": "login",
                    "event_category": "user",
                    "event_action": "login",
                    "event_label": "facebook login",
                    "event_value": 100,
                    "event_non_interaction": true,
                    "event_callback_id": "12345",
                    "event_custom_params": ["key": "value"],
                    "event_custom_dimensions": ["key": "value"],
                    "event_custom_metrics": ["key": 100],
                    "event_description": "A string is a series of characters, such as \"Swift\", that forms a collection. Strings in Swift are Unicode correct and locale insensitive, and are designed to be efficient. The String type bridges with the Objective-C class NSString and offers interoperability with C functions that works with strings."
                ]
            )
        }
        
        private var analytics: LogEntry {
            LogEntry(
                category: Category("📈", "Analytics"),
                source: Source("Firebase", .sdk(version: "8.9.0")),
                content: "Open Screen: Home",
                userInfo: [
                    "environment": "dev",
                    "event": "open home"
                ]
            )
        }
        
        private var error: LogEntry {
            LogEntry(
                category: .error,
                source: Source(
                    "Alamofire.AFError",
                    .error(code: 19)
                ),
                content: "Couldn't load url"
            )
        }
        
        private var warning: LogEntry {
            LogEntry(
                category: .warning,
                source: Source("MyWebView", .file(line: 150)),
                content: "Couldn't find user_id"
            )
        }
    }
}
public extension LogEntry {
    enum Sorting: Int, CustomStringConvertible, CaseIterable, Identifiable {
        case ascending, descending
        
        public var description: String {
            switch self {
            case .ascending:
                "New Logs Last"
            case .descending:
                "New Logs First"
            }
        }
        
        public var id: RawValue {
            rawValue
        }
        
        /// Toggle between sorting orders.
        mutating func toggle() {
            self = self == .ascending ? .descending : .ascending
        }
    }
}

public extension LogEntry {
    struct Source: Hashable, Identifiable, Sendable {
        public var id: String { name }
        public let emoji: Character?
        public let name: String
        public let info: SourceInfo?
        
        public init(
            _ name: String,
            _ info: SourceInfo? = .none
        ) {
            self.emoji = nil
            self.info = info
            self.name = Self.cleanName(name)
        }
        
        public init(
            _ emoji: Character,
            _ name: String,
            _ info: SourceInfo? = .none
        ) {
            self.emoji = emoji
            self.info = info
            self.name = Self.cleanName(name)
        }
        
        package init(_ source: some LogEntrySource) {
            emoji = source.logEntryEmoji
            info = source.logEntryInfo
            name = Self.cleanName(source.logEntryName)
        }
        
        private static func cleanName(_ name: String) -> String {
            if name.hasSuffix(".swift") {
                name.replacingOccurrences(of: ".swift", with: "")
            } else {
                name
            }
        }
    }
}

extension LogEntry.Source: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension LogEntry.Source: Comparable {
    public static func < (lhs: LogEntry.Source, rhs: LogEntry.Source) -> Bool {
        lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}

extension LogEntry.Source: CustomStringConvertible {
    public var description: String {
        if let emoji {
            "\(emoji) \(name)"
        } else {
            name
        }
    }
}

extension LogEntry.Source: FilterConvertible {
    package static var filterKind: Filter.Kind { .source }
    package static var filterDisplayName: KeyPath<LogEntry.Source, String> { \.description }
    package static var filterQuery: KeyPath<LogEntry.Source, String> { \.name }
}

public extension LogEntry {
    enum SourceInfo: Hashable, Sendable {
        case file(line: Int)
        case sdk(version: String)
        case error(code: Int)
    }
}

public protocol LogEntrySource {
    var logEntryEmoji: Character? { get }
    var logEntryName: String { get }
    var logEntryInfo: LogEntry.SourceInfo? { get }
}

public extension LogEntrySource {
    var logEntryEmoji: Character? { nil }
    
    var logEntryName: String {
        let type = "\(type(of: self))"
        guard let sanitizedType = type.split(separator: "<").first else { return type }
        return String(sanitizedType)
    }
    
    var logEntryInfo: LogEntry.SourceInfo? { nil }
}
public extension LogEntry {
    struct UserInfo: Sendable {
        package let storage: [(key: String, value: String)]
        
        /// Creates a `UserInfo` instance from a given string.
        public init(_ string: String) {
            storage = [(String(), string.trimmingCharacters(in: .whitespacesAndNewlines))]
        }
        
        /// Creates a `UserInfo` instance from a dictionary of `[String: String]`.
        public init(_ dictionary: [String: String]) {
            storage = dictionary.sorted(by: <)
        }
        
        /// Initializes a `UserInfo` instance from a generic dictionary.
        ///
        /// The keys in the given dictionary are converted to strings using `String(describing:)`,
        /// and the values are converted to strings using the `convert(toString:)` helper method.
        /// The resulting dictionary is used to instantiate the `.dictionary` case.
        ///
        /// - Parameter dictionary: A dictionary with keys conforming to `Hashable` and values of any type.
        public init<Key, Value>(_ dictionary: [Key: Value]) where Key: Hashable {
            storage = dictionary.reduce(into: [String: String]()) { partialResult, element in
                partialResult[String(describing: element.key)] = Self.convert(toString: element.value)
            }
            .sorted(by: <)
        }
        
        private static let emptyValue = "–"
        
        
        /// Attempts to initialize a `UserInfo` instance from any type of object.
        ///
        /// This initializer supports conversion from dictionaries, arrays, and strings.
        /// For dictionaries and arrays, it converts the value to a `[String: String]` representation.
        /// For strings, it trims whitespace and uses the result for the `.message` case.
        /// For other object types, reflection is used to decide between `.message` and `.dictionary`.
        ///
        /// - Parameter value: The object to convert into a `UserInfo` instance.
        public init?(_ value: Any? = nil) {
            guard let value = value else { return nil }
            
            if let dict = value as? [String: Any] {
                storage = Self.convert(toDictionary: dict).sorted(by: <)
            }
            else if let array = value as? [Any] {
                storage = Self.convert(toDictionary: array).sorted(by: <)
            }
            else if let str = value as? String {
                let trimmed = str.trimmingCharacters(in: .whitespacesAndNewlines)
                storage = [("", (trimmed.isEmpty || ["nil", "[]", "{ }", "[:]"].contains(str) ? Self.emptyValue : trimmed))]
            }
            else {
                let mirror = Mirror(reflecting: value)
                
                if mirror.children.isEmpty {
                    storage = [("", String(describing: value))]
                } else if let dict = Self.convert(toDictionary: value) {
                    storage = dict.sorted(by: <)
                } else {
                    return nil
                }
            }
        }
        
        private static func convert(toString object: Any?) -> String {
            switch object {
            case .none:
                return emptyValue
            case let string as String where ["", "nil", "[]", "{}", "[:]"].contains(string):
                return emptyValue
            case let string as String:
                return string.trimmingCharacters(in: .whitespacesAndNewlines)
            case let .some(object):
                return String(describing: object)
            }
        }
        
        private static func convert(toDictionary object: Any?) -> [String: String]? {
            switch object {
            case let dictionary as [String: Any]:
                convert(toDictionary: dictionary)
                
            case let array as [Any]:
                convert(toDictionary: array)
                
            case let object?:
                Mirror(reflecting: object).children.reduce(into: [:]) { dict, child in
                    guard let label = child.label else { return }
                    dict[String(describing: label)] = convert(toString: child.value)
                }
            case .none:
                nil
            }
        }
        
        private static func convert(toDictionary dict: [String: Any]) -> [String: String] {
            dict.reduce([String: String]()) { partialResult, element in
                var dict = partialResult
                dict[element.key] = convert(toString: element.value)
                return dict
            }
        }
        
        private static func convert(toDictionary array: [Any]) -> [String: String] {
            array.enumerated().reduce([String: String]()) { partialResult, item in
                var dict = partialResult
                dict[String(item.offset)] = convert(toString: item.element)
                return dict
            }
        }
    }
}

extension LogEntry.UserInfo: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension LogEntry.UserInfo: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        self.init(
            elements.reduce(into: [:]) { partialResult, element in
                partialResult[element.0] = element.1
            }
        )
    }
}

extension LogEntry.UserInfo: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Any...) {
        self.init(
            Self.convert(toDictionary: elements)
        )
    }
}
package extension LogEntry {
    struct UserInfoKey: Hashable, Sendable {
        package let entryID: ID
        package let key: String
        
        package init(id: ID, key: String) {
            self.entryID = id
            self.key = key
        }
    }
}

extension View {
    /// Presents an activity sheet when the associated `ActivityItem` is present
    ///
    /// The system provides several standard services, such as copying items to the pasteboard, posting content to social media sites, sending items via email or SMS, and more. Apps can also define custom services.
    /// 
    /// - Parameters:
    ///   - item: The item to use for this activity
    ///   - onComplete: When the sheet is dismissed, the this will be called with the result
    func activitySheet(
        _ item: Binding<ActivityItem?>,
        permittedArrowDirections: UIPopoverArrowDirection = .any,
        onComplete: UIActivityViewController.CompletionWithItemsHandler? = nil
    ) -> some View {
        background(ActivityView(item: item, permittedArrowDirections: permittedArrowDirections, onComplete: onComplete))
    }

}

private struct ActivityView: UIViewControllerRepresentable {
    @Binding var item: ActivityItem?
    private var permittedArrowDirections: UIPopoverArrowDirection
    private var completion: UIActivityViewController.CompletionWithItemsHandler?

    init(
        item: Binding<ActivityItem?>,
        permittedArrowDirections: UIPopoverArrowDirection,
        onComplete: UIActivityViewController.CompletionWithItemsHandler? = nil
    ) {
        _item = item
        self.permittedArrowDirections = permittedArrowDirections
        self.completion = onComplete
    }

    func makeUIViewController(context: Context) -> ActivityViewControllerWrapper {
        ActivityViewControllerWrapper(item: $item, permittedArrowDirections: permittedArrowDirections, completion: completion)
    }

    func updateUIViewController(_ controller: ActivityViewControllerWrapper, context: Context) {
        controller.item = $item
        controller.completion = completion
        controller.updateState()
    }

}

private final class ActivityViewControllerWrapper: UIViewController {
    var item: Binding<ActivityItem?>
    var permittedArrowDirections: UIPopoverArrowDirection
    var completion: UIActivityViewController.CompletionWithItemsHandler?

    init(
        item: Binding<ActivityItem?>,
        permittedArrowDirections: UIPopoverArrowDirection,
        completion: UIActivityViewController.CompletionWithItemsHandler?
    ) {
        self.item = item
        self.permittedArrowDirections = permittedArrowDirections
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        updateState()
    }

    fileprivate func updateState() {
        let isActivityPresented = presentedViewController != nil

        if item.wrappedValue != nil {
            if !isActivityPresented {
                let controller = UIActivityViewController(activityItems: item.wrappedValue?.items ?? [], applicationActivities: item.wrappedValue?.activities)
                controller.popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
                controller.popoverPresentationController?.sourceView = view
                controller.completionWithItemsHandler = { [weak self] (activityType, success, items, error) in
                    self?.item.wrappedValue = nil
                    self?.completion?(activityType, success, items, error)
                }
                present(controller, animated: true, completion: nil)
            }
        }
    }

}

struct DismissButton: View {
    var action: () -> Void
    
    @Environment(\.configuration.icons.dismiss)
    private var icon
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .symbolRenderingMode(.hierarchical)
        }
        .tint(.secondary)
    }
}

#Preview {
    DismissButton(action: {})
}

struct ExportButton: View {
    var action: () -> Void
    
    @Environment(\.configuration.icons.export)
    private var icon
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
        }
    }
}

#Preview {
    ExportButton(action: {})
}

extension Color {
    static let background = Color(uiColor: .systemBackground)
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
}

extension View {
    func badge(
        count: Int = 0,
        foregroundColor: Color = .white,
        backgroundColor: Color = .red
    ) -> some View {
        modifier(
            BadgeModifier(
                count: count,
                foregroundColor: foregroundColor,
                backgroundColor: backgroundColor
            )
        )
    }
}

struct BadgeModifier: ViewModifier {
    var count: Int
    var foregroundColor: Color
    var backgroundColor: Color
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content
            if count != 0 {
                ZStack {
                    Text(count, format: .number)
                        .font(.caption2)
                        .foregroundStyle(foregroundColor)
                        .fixedSize()
                        .padding([.leading, .trailing], 4)
                        .padding([.top, .bottom], 1)
                        .frame(minWidth: 16, minHeight: 16)
                        .background(backgroundColor, in: Capsule())
                    
                }
                .transition(.scale.combined(with: .opacity))
                .frame(width: 0, height: 0)
            }
        }
    }
}

@available(iOS 17.0, *)
#Preview(body: {
    @Previewable @State
    var count = 0
    
    Button("Test") {
        count = count == 0 ? 10 : 0
    }
    .badge(count: count)
    .animation(.interactiveSpring, value: count)
})

struct FilterView: View {
    let data: Filter
    @Binding var isOn: Bool
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    @Environment(\.configuration.accentColor)
    private var accentColor
    
    private let shape = Capsule()
    
    var body: some View {
        Toggle(data.displayName, isOn: $isOn)
            .clipShape(shape)
            .toggleStyle(.button)
            .buttonStyle(.borderedProminent)
            .background(accentColor.opacity(0.08), in: shape)
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State
    var isOn = false
    
    VStack {
        FilterView(
            data: "Some Filter",
            isOn: $isOn
        )
    }
}

struct FiltersDrawer: View {
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    @Environment(\.spacing)
    private var spacing
    
    var body: some View {
        VStack(spacing: spacing) {
            SearchBarView(searchQuery: $viewModel.searchQuery)
                .padding(.horizontal, spacing * 2)
            
            if !viewModel.categories.isEmpty {
                FiltersRow(
                    title: "Categories",
                    selection: $viewModel.activeFilters,
                    data: viewModel.categories
                )
                .animation(.snappy, value: viewModel.categories)
            }
            if !viewModel.sources.isEmpty {
                FiltersRow(
                    title: "Sources",
                    selection: $viewModel.activeFilters,
                    data: viewModel.sources
                )
                .animation(.snappy, value: viewModel.sources)
            }
        }
        .font(.footnote)
        .padding(.vertical, spacing)
        .background(.background)
        .safeAreaInset(edge: .bottom, spacing: .zero, content: Divider.init)
    }
}

#Preview {
    FiltersDrawer()
        .environmentObject(
            AppLoggerViewModel(
                dataObserver: DataObserver(
//                    allCategories: ["test"],
//                    allSources: ["test"]
                ),
                dismissAction: {
                }
            )
        )
}

struct FiltersDrawerToggle: View {
    @Binding
    var isOn: Bool
    var activeFilters: Int = 0

    @Environment(\.configuration.icons)
    private var icons
    
    var body: some View {
        Button {
            withAnimation(.snappy) {
                isOn.toggle()
            }
        } label: {
            Image(systemName: isOn ? icons.filtersOn : icons.filtersOff)
                .badge(count: activeFilters)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State
    var isOn = false
    
    FiltersDrawerToggle(
        isOn: $isOn,
        activeFilters: isOn ? 3 : 0
    )
}

struct FiltersRow: View {
    var title: String
    
    @Binding
    var selection: Set<Filter>
    
    let data: [Filter]
    
    @Environment(\.spacing)
    private var spacing

    var body: some View {ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: spacing, pinnedViews: .sectionHeaders) {
                Section {
                    ForEach(data, id: \.self) { filter in
                        FilterView(
                            data: filter,
                            isOn: Binding {
                                selection.contains(filter)
                            } set: { active in
                                if active {
                                    selection.insert(filter)
                                } else {
                                    selection.remove(filter)
                                }
                            }
                        )
                    }
                } header: {
                    Text(title)
                        .foregroundColor(.secondary)
                        .padding(EdgeInsets(
                            top: spacing,
                            leading: spacing * 2,
                            bottom: spacing,
                            trailing: spacing
                        ))
                        .background(.background)
                }
            }
            .padding(.trailing, spacing * 2)
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State
    var activeFilters: Set<Filter> = [
        "Filter 1"
    ]
    FiltersRow(
        title: "Filters",
        selection: $activeFilters,
        data: [
            "Filter 1",
            "Filter 2",
            "Filter 3"
        ]
    )
}

struct LinkText: View {
    var data: String
    var alignment: TextAlignment = .leading

    var body: some View {
        Group {
            if let link = URL(string: data), link.scheme != .none {
                Text(data)
                    .underline()
                    .onTapGesture {
                        UIApplication.shared.open(link, options: [:], completionHandler: .none)
                    }
            } else {
                Text(data)
            }
        }
        .textSelection(.enabled)
        .multilineTextAlignment(alignment)
    }
}

#Preview {
    VStack {
        LinkText(data: "Some Link", alignment: .leading)
        LinkText(data: "https://google.com", alignment: .leading)
    }
}

package struct LogEntriesList: View {
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    @Environment(\.configuration)
    private var configuration
    
    package var body: some View {
        ScrollView {
            LazyVStack(spacing: .zero, pinnedViews: .sectionHeaders) {
                Section {
                    ForEach(viewModel.entries, id: \.self) { id in
                        LogEntryView(id: id)
                        
                        if id != viewModel.entries.last {
                            Divider()
                        }
                    }
                } header: {
                    if viewModel.showFilters {
                        FiltersDrawer().transition(
                            .move(edge: .top)
                            .combined(with: .opacity)
                        )
                    }
                }
            }
            .padding(.bottom, 50)
            .animation(.snappy, value: viewModel.entries)
        }
        .clipped()
        .ignoresSafeArea(.container, edges: .bottom)
        .background {
            if viewModel.entries.isEmpty {
                Text(emptyReason)
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.secondary)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.top, viewModel.showFilters ? 150 : 0)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(configuration.navigationTitle)
        .toolbar {
            ToolbarItem(
                placement: .topBarLeading,
                content: leadingNavigationBarItems
            )
            ToolbarItem(
                placement: .topBarTrailing,
                content: trailingNavigationBarItems
            )
        }
    }
    
    private var emptyReason: String {
        if viewModel.searchQuery.isEmpty {
            configuration.emptyReasons.empty
        } else {
            "\(configuration.emptyReasons.searchResults):\n\n\(viewModel.activeScope.joined(separator: ", "))"
        }
    }
    
    private func leadingNavigationBarItems() -> some View {
        HStack {
            FiltersDrawerToggle(
                isOn: $viewModel.showFilters,
                activeFilters: viewModel.activeScope.count
            )
            
            SortingButton(selection: $viewModel.sorting)
                .disabled(viewModel.entries.isEmpty)
        }
    }
    
    private func trailingNavigationBarItems() -> some View {
        DismissButton(action: viewModel.dismissAction)
            .font(.title2)
    }
}

#Preview {
    let allEntries = LogEntry.Mock.allCases.map { $0.entry() }
    
    var colorGenerator = DynamicColorGenerator<LogEntry.Source>()
    
    let dataObserver = DataObserver(
        allEntries: allEntries.map(\.id),
        entryCategories: allEntries.valuesByID(\.category),
        entryContents: allEntries.valuesByID(\.content),
        entrySources: allEntries.valuesByID(\.source),
        entryUserInfos: allEntries.valuesByID(\.userInfo),
        sourceColors: allEntries.map(\.source).reduce(into: [:], { partialResult, source in
            partialResult[source.id] = colorGenerator.color(for: source)
        })
    )
    
    let viewModel = AppLoggerViewModel(
        dataObserver: dataObserver,
        dismissAction: {}
    )
    
    LogEntriesList()
        .environmentObject(viewModel)
        .onAppear {
            viewModel.showFilters = true
        }
}

package struct LogEntriesNavigation<Content>: View where Content: View {

    @Environment(\.configuration.colorScheme)
    private var preferredColorScheme
    
    @Environment(\.colorScheme)
    private var colorScheme

    @Environment(\.configuration.accentColor)
    private var accentColor
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    private let content: Content
    
    @available(iOS 16.0, *)
    package static func makeStack() -> Self where Content == NavigationStack<NavigationPath, LogEntriesList> {
        Self(content: NavigationStack(root: LogEntriesList.init))
    }

    package static func makeView() -> Self where Content == NavigationView<LogEntriesList> {
        Self(content: NavigationView(content: LogEntriesList.init))
    }
    
    package var body: some View {
        content
            .tint(accentColor)
            .colorScheme(preferredColorScheme ?? colorScheme)
            .activitySheet($viewModel.activityItem)
    }
}

@available(iOS 16.0, *)
#Preview {
    let allEntries = LogEntry.Mock.allCases.map { $0.entry() }
    
    var colorGenerator = DynamicColorGenerator<LogEntry.Source>()
    
    let dataObserver = DataObserver(
        allCategories: Set(allEntries.map(\.category)).sorted(),
        allEntries: allEntries.map(\.id),
        allSources: allEntries.map(\.source),
        entryCategories: allEntries.valuesByID(\.category),
        entryContents: allEntries.valuesByID(\.content),
        entrySources: allEntries.valuesByID(\.source),
        entryUserInfos: allEntries.valuesByID(\.userInfo),
        sourceColors: allEntries.map(\.source).reduce(into: [:], { partialResult, source in
            partialResult[source.id] = colorGenerator.color(for: source)
        })
    )
    
    LogEntriesNavigation.makeStack()
        .environmentObject(
            AppLoggerViewModel(
                dataObserver: dataObserver,
                dismissAction: { print("dismiss") }
            )
        )
        .configuration(.init(accentColor: .red))
}

struct LogEntryContentView: View {
    var category: LogEntry.Category
    var content: LogEntry.Content
    
    @Environment(\.spacing)
    private var spacing
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            Text(content.function)
                .font(.callout.bold())
                .minimumScaleFactor(0.85)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            if let message = content.message, !message.isEmpty {
                HStack(alignment: .top, spacing: spacing) {
                    if let icon = category.emoji {
                        Text(String(icon))
                    }
                    
                    LinkText(data: message)
                }
                .font(.footnote)
                .foregroundStyle(.tint)
                .padding(spacing)
                .background(
                    .tint.opacity(0.1),
                    in: RoundedRectangle(cornerRadius: spacing * 1.5)
                )
            }
        }
    }
}

#Preview {
    LogEntryContentView(
        category: .alert,
        content: LogEntry.Content(
            function: "content description",
            message: "Bla"
        )
    )
}

#Preview {
    LogEntryContentView(
        category: .alert,
        content: "content description"
    )
}

struct LogEntryHeaderView: View {
    let source: LogEntry.Source
    let category: String
    let createdAt: Date
    
    @Environment(\.spacing)
    private var spacing

    var body: some View {
        HStack(spacing: spacing / 2) {
            Text(category)
                .foregroundStyle(.primary)
            
            Image(systemName: "chevron.forward")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
            
            LogEntrySourceView(data: source)
                .foregroundStyle(.tint)
            
            Spacer()
            
            Text(createdAt, style: .time)
        }
        .foregroundStyle(.secondary)
        .overlay(alignment: .leading) {
            Circle()
                .fill(.tint)
                .frame(width: spacing * 0.75)
                .offset(x: -spacing * 1.25)
        }
        .font(.footnote)
    }
}

@available(iOS 17, *)
#Preview(traits: .sizeThatFitsLayout) {
    LogEntryHeaderView(
        source: "Source",
        category: "Category",
        createdAt: Date()
    )
    .padding()
}

struct LogEntrySourceView: View {
    let data: LogEntry.Source

    private var label: String {
        switch data.info {
        case let .sdk(version):
            "\(data) (\(version))"
        case let .file(lineNumber):
            "\(data).swift:\(lineNumber)"
        case let .error(code):
            "\(data) (Code \(code))"
        case .none:
            data.description
        }
    }
    
    var body: some View {
        Text(label)
    }
}

#Preview {
    VStack {
        LogEntrySourceView(
            data: LogEntry.Source("📄", "File.swift", .file(line: 12))
        )
        
        LogEntrySourceView(
            data: LogEntry.Source("MySDK", .sdk(version: "1.2.3"))
        )
        
        LogEntrySourceView(
            data: "Some source"
        )
        
        LogEntrySourceView(data: LogEntry.Source(CustomSource()))
    }
}

private struct CustomSource: LogEntrySource {
    var logEntryEmoji: Character? { "👌" }
}

struct LogEntryUserInfoRow: View {
    let key: String
    let value: String
    
    @Environment(\.spacing)
    private var spacing

    var body: some View {
        HStack(alignment: .top, spacing: spacing) {
            keyText
            Spacer(minLength: spacing)
            valueText
        }
        .padding(spacing)
    }

    private var valueText: some View {
        LinkText(data: value, alignment: .trailing)
            .foregroundStyle(.tint)
            .font(.system(.caption, design: .monospaced))
    }

    private var keyText: some View {
        Text("\(key):")
            .font(.caption)
            .italic()
            .foregroundColor(.secondary)
            .textSelection(.enabled)
            .isHidden(key.isEmpty)
    }
}

private extension View {
    @ViewBuilder
    func isHidden(_ hidden: Bool) -> some View {
        if hidden {
            EmptyView()
        } else {
            self
        }
    }
}

#Preview {
    VStack {
        LogEntryUserInfoRow(
            key: "Key",
            value: "I'm a value"
        )
        
        Divider()
        
        LogEntryUserInfoRow(
            key: "",
            value: "String interpolations are string literals that evaluate any included expressions and convert the results to string form. String interpolations give you an easy way to build a string from multiple pieces. Wrap each expression in a string interpolation in parentheses, prefixed by a backslash."
        )
    }
}

struct LogEntryUserInfoRows: View {
    var ids: [LogEntry.UserInfoKey]

    @Environment(\.spacing)
    private var spacing
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: .zero) {
            ForEach(Array(ids.enumerated()), id: \.offset) { offset, id in
                LogEntryUserInfoRow(
                    key: id.key,
                    value: viewModel.entryUserInfoValue(id)
                )
                .background(backgroundColor(for: offset))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: spacing * 1.5))
    }
    
    private func backgroundColor(for index: Int) -> Color {
        if index.isMultiple(of: 2) {
            Color(uiColor: .systemGray5)
        } else if colorScheme == .dark {
            Color(uiColor: .systemGray4)
        } else {
            Color(uiColor: .systemGray6)
        }
    }
}

#Preview {
    let entry = LogEntry.Mock.socialLogin.entry()
    
    ScrollView {
        LogEntryUserInfoRows(
            ids: entry.userInfo?.storage.map {
                LogEntry.UserInfoKey(id: entry.id, key: $0.key)
            } ?? []
        )
        .padding()
    }
    .environmentObject(
        AppLoggerViewModel(
            dataObserver: DataObserver(
                entryUserInfos: [entry.id: entry.userInfo]
            ),
            dismissAction: {}
        )
    )
}

struct LogEntryView: View {
    let id: LogEntry.ID
    
    @Environment(\.colorScheme)
    private var colorScheme
    
    @Environment(\.spacing)
    private var spacing
    
    @EnvironmentObject
    private var viewModel: AppLoggerViewModel

    var body: some View {
        let source = viewModel.entrySource(id)
        let category = viewModel.entryCategory(id)
        let createdAt = viewModel.entryCreatedAt(id)
        let content = viewModel.entryContent(id)
        let userInfo = viewModel.entryUserInfoKeys(id)
        let tint = viewModel.sourceColor(source, for: colorScheme)
        
        VStack(alignment: .leading, spacing: spacing) {
            LogEntryHeaderView(
                source: source,
                category: category.description,
                createdAt: createdAt
            )
            
            LogEntryContentView(
                category: category,
                content: content
            )
            
            if let userInfo {
                LogEntryUserInfoRows(
                    ids: userInfo
                )
            }
        }
        .tint(tint)
        .padding(spacing * 2)
        .background(.background)
    }
}

#if DEBUG
extension LogEntryView {
    init(mock: LogEntry.Mock) {
        let entry = mock.entry()
        self.id = entry.id
    }
}
#endif

#Preview {
    let entry = LogEntry.Mock.socialLogin.entry()
    
    ScrollView {
        LogEntryView(id: entry.id)
            .environmentObject(
                AppLoggerViewModel(
                    dataObserver: DataObserver(
                        entryCategories: [entry.id: entry.category],
                        entryContents: [entry.id: entry.content],
                        entrySources: [entry.id: entry.source],
                        entryUserInfos: [entry.id: entry.userInfo],
                        sourceColors: [entry.source.id: .makeColors().randomElement()!]
                    ),
                    dismissAction: {}
                )
            )
    }
}

#Preview {
    let entry = LogEntry.Mock.googleAnalytics.entry()
    
    ScrollView {
        LogEntryView(id: entry.id)
            .environmentObject(
                AppLoggerViewModel(
                    dataObserver: DataObserver(
                        entryCategories: [entry.id: entry.category],
                        entryContents: [entry.id: entry.content],
                        entrySources: [entry.id: entry.source],
                        entryUserInfos: [entry.id: entry.userInfo],
                        sourceColors: [entry.source.id: .makeColors().randomElement()!]
                    ),
                    dismissAction: {}
                )
            )
    }
    .background(.red)
}

struct SearchBarView: View {
    @Binding
    var searchQuery: String
    
    @FocusState
    private var focus
    
    @Environment(\.spacing)
    private var spacing

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .accessibilityHidden(true)

                TextField(
                    "Search logs",
                    text: $searchQuery
                )
                .autocorrectionDisabled()
                .submitLabel(.search)
                .foregroundColor(.primary)
                .focused($focus)

                if showDismiss {
                    DismissButton(action: clearText).transition(
                        .scale.combined(with: .opacity)
                    )
                }
            }
            .padding(spacing)
            .foregroundColor(.secondary)
            .background(Color.secondaryBackground)
            .clipShape(Capsule())
        }
        .animation(.interactiveSpring, value: showDismiss)
    }
    
    private var showDismiss: Bool {
        focus || !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func clearText() {
        searchQuery = String()
        focus.toggle()
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State
    var query: String = "Query"
    SearchBarView(searchQuery: $query)
}

struct SortingButton: View {
    var options = LogEntry.Sorting.allCases
    
    @Binding
    var selection: LogEntry.Sorting
    
    @Environment(\.configuration.icons)
    private var icons
    
    var body: some View {
        Menu {
            Picker("Sorting", selection: $selection) {
                ForEach(options, id: \.rawValue) { option in
                    Label(option.description, systemImage: icon(option)).tag(option)
                }
            }
        } label: {
            Image(systemName: icon)
        }
        .symbolRenderingMode(.hierarchical)
    }
    
    private var icon: String {
        icon(selection)
    }
    
    private func icon(_ sorting: LogEntry.Sorting) -> String {
        switch sorting {
        case .ascending: icons.sortAscending
        case .descending: icons.sortDescending
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    @Previewable @State
    var selection: LogEntry.Sorting = .ascending
    
    SortingButton(selection: $selection)
}

private struct SpacingKey: EnvironmentKey {
    static let defaultValue: CGFloat = 8
}

extension EnvironmentValues {
    var spacing: CGFloat {
        get {
            self[SpacingKey.self]
        } set {
            self[SpacingKey.self] = newValue
        }
    }
}

extension View {
    func spacing(_ spacing: CGFloat) -> some View {
        environment(\.spacing, spacing)
    }
}
