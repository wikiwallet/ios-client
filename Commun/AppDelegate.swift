//
//  AppDelegate.swift
//  Commun
//
//  Created by Maxim Prigozhenkov on 14/03/2019.
//  Copyright © 2019 Commun Limited. All rights reserved.
//
//  https://console.firebase.google.com/project/golos-5b0d5/notification/compose?campaignId=9093831260433778480&dupe=true
//

import UIKit
import Fabric
import Crashlytics
import CoreData
import Firebase
import FirebaseMessaging
import UserNotifications
import CyberSwift
@_exported import CyberSwift
import RxSwift
import RxCocoa
import SDURLCache
import SDWebImageWebPCoder
import ListPlaceholder
import AppsFlyerLib
import SwifterSwift

let isDebugMode: Bool = true
let smsCodeDebug: UInt64 = isDebugMode ? 9999 : 0
let gcmMessageIDKey = "gcm.message_id"
let firstInstallAppKey = "com.commun.ios.firstInstallAppKey"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // MARK: - Properties
    var window: UIWindow?
    let notificationCenter = UNUserNotificationCenter.current()
    let notificationTappedRelay = BehaviorRelay<ResponseAPIGetNotificationItem>(value: ResponseAPIGetNotificationItem.empty)
    let shareExtensionDataRelay = BehaviorRelay<ShareExtensionData?>(value: nil)
    let deepLinkPath = BehaviorRelay<[String]>(value: [])
    let disposeBag = DisposeBag()

    // MARK: - RootVCs
    var splashVC: SplashVC { SplashVC() }
    var welcomeNC: UINavigationController {
        let welcomeVC = WelcomeVC()
        let welcomeNav = UINavigationController(rootViewController: welcomeVC)
        return welcomeNav
    }
    var boardingSetPasscodeVC: BoardingSetPasscodeVC { BoardingSetPasscodeVC() }
    lazy var tabBarVC = TabBarVC()

    // MARK: - Class Functions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Prepare for localization
        Bundle.swizzleLocalization()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = splashVC
        window!.makeKeyAndVisible()
        
        #if !APPSTORE
        if !UserDefaults.standard.bool(forKey: UIApplication.versionBuild) {
            try? KeychainManager.deleteUser()
            UserDefaults.standard.set(true, forKey: UIApplication.versionBuild)
        }
        #endif
        
        // first fun app
        if !UserDefaults.standard.bool(forKey: firstInstallAppKey) {
            // Analytics
            AnalyticsManger.shared.launchFirstTime()

            UserDefaults.standard.set(true, forKey: firstInstallAppKey)
        }

        configureAppsFlyer()
        AnalyticsManger.shared.sessionStart()
        // Use Firebase library to configure APIs
        configureFirebase()

        // ask for permission for sending notifications
        configureNotifications()

        // Config Fabric
        Fabric.with([Crashlytics.self])

        // global tintColor
        window?.tintColor = .appMainColor

        // Logger
//        Logger.showEvents = [.event, .request, .error, .info]
//        Logger.shownApiMethods = ["content.getPosts", "auth.authorize"]

        // support webp image
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)

        // Sync iCloud key-value store
        NSUbiquitousKeyValueStore.default.synchronize()

        // Hide constraint warning
        UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")

        // handle connected
        AuthManager.shared.status
            .distinctUntilChanged()
            .subscribe(onNext: { (status) in
                self.navigateWithAuthorizationStatus(status)
            })
            .disposed(by: disposeBag)

        // cache
        if let urlCache = SDURLCache(memoryCapacity: 0, diskCapacity: 2*1024*1024*1024, diskPath: SDURLCache.defaultCachePath(), enableForIOS5AndUp: true) {
            URLCache.shared = urlCache
        }

        // badge
        NotificationsManager.shared.unseenNotificationsRelay
            .subscribe(onNext: { (count) in
                UIApplication.shared.applicationIconBadgeNumber = Int(count)
            })
            .disposed(by: disposeBag)
        
        return true
    }
    
    func navigateWithAuthorizationStatus(_ status: AuthManager.Status) {
        switch status {
        case .initializing:
            // Closing animation
            self.window?.rootViewController = splashVC
        case .registering:
            if UserDefaults.standard.bool(forKey: Config.currentUserDidShowWelcomeScreen)
            {
                self.changeRootVC(NonAuthTabBarVC())
            } else {
                self.changeRootVC(welcomeNC)
            }
        case .boarding:
            let boardingNC = UINavigationController(rootViewController: boardingSetPasscodeVC)
            self.changeRootVC(boardingNC)
        case .authorizing:
            break
        case .authorized:
            // create new TabBarVC when user logged out
            if AuthManager.shared.isLoggedOut {
                SubscribersViewModel.ofCurrentUser = SubscribersViewModel(userId: Config.currentUser?.id)
                SubscriptionsViewModel.ofCurrentUserTypeUser = SubscriptionsViewModel(type: .user)
                SubscriptionsViewModel.ofCurrentUserTypeCommunity = SubscriptionsViewModel(type: .community)
                BalancesViewModel.ofCurrentUser = BalancesViewModel()
                tabBarVC = TabBarVC()
            }
            
            changeRootVC(self.tabBarVC)
            
        case .error(let error):
            switch error {
            case .userNotFound:
                AuthManager.shared.logout()
                return
            default:
                break
            }
        }
    }

    func changeRootVC<VC: UIViewController>(_ rootVC: VC) {
        if let vc = window?.rootViewController,
            vc is VC
        {
            return
        }

        // window?.rootViewController
        ChangingRootVCAnimator.shared.changeRootVC(to: rootVC, from: window?.rootViewController)

        getConfig { (error) in
            if let error = error {
                if error.cmError.message == ErrorMessage.needUpdateApplicationVersion.rawValue {
                    rootVC.view.showForceUpdate()
                    return
                }
                print("getConfig = \(error)")
            }
        }
    }

    func getConfig(completion: @escaping ((Error?) -> Void)) {
        RestAPIManager.instance.getConfig()
            .subscribe(onSuccess: { _ in
                completion(nil)
            }) { (error) in
                completion(error)
            }
            .disposed(by: disposeBag)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        AnalyticsManger.shared.backgroundApp()
        AuthManager.shared.disconnect()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        AnalyticsManger.shared.foregroundApp()
        AuthManager.shared.connect()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.appGroups.removeObject(forKey: appShareExtensionKey)
        AuthManager.shared.disconnect()
        self.saveContext()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerTracker.shared().trackAppLaunch()
    }

    // MARK: - Custom Functions
    private func configureFirebase() {
        #if APPSTORE
            let fileName = "GoogleService-Info-Prod"
        #else
            let fileName = "GoogleService-Info-Dev"
        #endif
        let filePath = Bundle.main.path(forResource: fileName, ofType: "plist")
        guard let fileopts = FirebaseOptions(contentsOfFile: filePath!)
            else { assert(false, "Couldn't load config file"); return }
        FirebaseApp.configure(options: fileopts)
    }
    
    private func configureNotifications() {
        // Set delegate for Messaging
        Messaging.messaging().delegate = self

        // Configure notificationCenter
        self.notificationCenter.delegate = self

        self.notificationCenter.requestAuthorization(options: [.alert, .sound, .badge],
                                                     completionHandler: { (granted, _) in
                                                        Logger.log(message: "Permission granted: \(granted)", event: .debug)
                                                        guard granted else { return }
                                                        self.getNotificationSettings()
        })

        // Register for remote notification
        UIApplication.shared.registerForRemoteNotifications()
    }

    private func getNotificationSettings() {
        self.notificationCenter.getNotificationSettings(completionHandler: { (settings) in
            Logger.log(message: "Notification settings: \(settings)", event: .debug)
        })
    }

    private func scheduleLocalNotification(userInfo: [AnyHashable: Any]) {
        let notificationContent                 =   UNMutableNotificationContent()
        let categoryIdentifier                  =   userInfo["category"] as? String ?? "Commun"

        notificationContent.title               =   userInfo["title"] as? String ?? "Commun"
        notificationContent.body                =   userInfo["body"] as? String ?? "Commun"
        notificationContent.sound               =   userInfo["sound"] as? UNNotificationSound ?? UNNotificationSound.default
        notificationContent.badge               =   userInfo["badge"] as? NSNumber ?? 1
        notificationContent.categoryIdentifier  =   categoryIdentifier

        let trigger         =   UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier      =   "Commun Local Notification"
        let request         =   UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)

        self.notificationCenter.add(request) { (error) in
            if let error = error {
                Logger.log(message: "Error \(error.localizedDescription)", event: .error)
            }
        }

        let snoozeAction    =   UNNotificationAction(identifier: "ActionSnooze", title: "snooze".localized().uppercaseFirst, options: [])
        let deleteAction    =   UNNotificationAction(identifier: "ActionDelete", title: "delete".localized().uppercaseFirst, options: [.destructive])

        let category        =   UNNotificationCategory(identifier: categoryIdentifier,
                                                       actions: [snoozeAction, deleteAction],
                                                       intentIdentifiers: [],
                                                       options: [])

        self.notificationCenter.setNotificationCategories([category])
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Commun")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

// MARK: - Firebase Cloud Messaging (FCM)
extension AppDelegate {
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            Logger.log(message: "Message ID: \(messageID)", event: .severe)
        }

        // Print full message.
        Logger.log(message: "userInfo: \(userInfo)", event: .severe)
    }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler:  @escaping (UIBackgroundFetchResult) -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            Logger.log(message: "Message ID: \(messageID)", event: .severe)
        }

        // Print full message.
        Logger.log(message: "userInfo: \(userInfo)", event: .severe)

        completionHandler(UIBackgroundFetchResult.newData)
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger.log(message: "Unable to register for remote notifications: \(error.localizedDescription)", event: .error)
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Logger.log(message: "APNs token retrieved: \(deviceToken)", event: .severe)

        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }

    private func showConnectingHud() {
        let message = "connecting".uppercaseFirst.localized() + "..."
        self.window?.rootViewController?.showIndetermineHudWithMessage(message)
    }
}

// MARK: - UNUserNotificationCenterDelegate
@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Tap on push message
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler:    @escaping () -> Void) {
        let notificationContent = response.notification.request.content

        if response.notification.request.identifier == "Local Notification" {
            Logger.log(message: "Handling notifications with the Local Notification Identifier", event: .debug)
        }

        // Print full message.
        Logger.log(message: "UINotificationContent: \(notificationContent)", event: .debug)

        // decode notification
        if let string = notificationContent.userInfo["notification"] as? String,
            let data = string.data(using: .utf8)
        {
            do {
                let notification = try JSONDecoder().decode(ResponseAPIGetNotificationItem.self, from: data)
                notificationTappedRelay.accept(notification)
            } catch {
                Logger.log(message: "Receiving notification error: \(error)", event: .error)
            }
        }

        completionHandler()
    }
}

// MARK: - MessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String) {
        Logger.log(message: "FCM registration token: \(fcmToken)", event: .severe)

        let dataDict: [String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)

        UserDefaults.standard.set(fcmToken, forKey: Config.currentDeviceFcmTokenKey)

        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        Logger.log(message: "Received data message: \(remoteMessage.appData)", event: .severe)
    }

    func configureAppsFlyer() {
        #if APPSTORE
            AppsFlyerTracker.shared().appsFlyerDevKey = "roSnaCmLo7RUhprGGbQBc3"
            AppsFlyerTracker.shared().appleAppID = Config.appStoreId
            AppsFlyerTracker.shared().delegate = self
        #endif
    }
}

extension AppDelegate: AppsFlyerTrackerDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {

    }

    func onConversionDataFail(_ error: Error) {

    }
}

// MARK: - Deeplink
extension AppDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if let url = userActivity.webpageURL {
            let path = Array(url.path.components(separatedBy: "/").dropFirst())
            if path.count == 1 || path.count == 3 {
                deepLinkPath.accept(path)
                return true
            }
        }

        return false
    }
}

// MARK: - Share Extension pass data
extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        switch url.description {
        case "commun://createPost":
            self.shareExtensionDataRelay.accept(UserDefaults.appGroups.loadShareExtensionData())
        default:
            break
        }

        return OpenSocialLink.application(app, open: url, options: options)
    }
}
