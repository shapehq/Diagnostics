//
//  UserDefaultsReporter.swift
//  Diagnostics
//
//  Created by Antoine van der Lee on 02/12/2019.
//  Copyright © 2019 WeTransfer. All rights reserved.
//

import Foundation

/// Generates a report from all the registered UserDefault keys.
public final class UserDefaultsReporter: DiagnosticsReporting {

    /// Defaults to `standard`. Can be used to override and return a different user defaults.
    public static var userDefaults: UserDefaults = .standard

    public static func report() -> DiagnosticsChapter {
        let userDefaults = self.userDefaults.dictionaryRepresentation()
        return DiagnosticsChapter(title: "UserDefaults", diagnostics: userDefaults, formatter: self)
    }
}

extension UserDefaultsReporter: HTMLFormatting {
    public static func format(_ diagnostics: Diagnostics) -> HTML {
        guard let userDefaultsDict = diagnostics as? [String: Any] else { return diagnostics.html() }
        return "<pre>\(userDefaultsDict.jsonRepresentation ?? "Could not parse User Defaults")</pre>"
    }
}

private extension Dictionary where Key == String, Value == Any {
    var jsonRepresentation: String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: jsonCompatible, options: [.prettyPrinted, .sortedKeys, .fragmentsAllowed]) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }

    var jsonCompatible: [String: Any] {
        return mapValues { value -> Any in
            if let dict = value as? [String: Any] {
                return dict.jsonCompatible
            } else if let array = value as? [Any] {
                return array.map { "\($0)" }
            }

            return "\(value)"
        }
    }
}
