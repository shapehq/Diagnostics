//
//  AppDelegate.swift
//  Diagnostics-Example
//
//  Created by Antoine van der Lee on 02/12/2019.
//  Copyright © 2019 WeTransfer. All rights reserved.
//

import UIKit
import Diagnostics

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    enum ExampleError: Error {
        case missingData
    }

    enum ExampleLocalizedError: LocalizedError {
        case missingLocalizedData

        var localizedDescription: String {
            return "Missing localized data"
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        do {
            let url = FileManager.default.documentsDirectory.appendingPathComponent("diagnostics_log.txt")
            try DiagnosticsLogger.setup(fileLocation: url)
        } catch {
            print("Failed to setup the Diagnostics Logger")
        }
        
        DiagnosticsLogger.log(message: "Application started")
        DiagnosticsLogger.log(error: ExampleError.missingData)
        DiagnosticsLogger.log(error: ExampleLocalizedError.missingLocalizedData)
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

private extension FileManager {
    var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
