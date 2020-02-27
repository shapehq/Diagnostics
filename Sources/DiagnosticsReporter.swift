//
//  DiagnosticsReporter.swift
//  Diagnostics
//
//  Created by Antoine van der Lee on 02/12/2019.
//  Copyright © 2019 WeTransfer. All rights reserved.
//

import Foundation

public protocol DiagnosticsReporting {
    /// Creates the report chapter.
    static func report() -> DiagnosticsChapter
}

public enum DiagnosticsReporter {

    public enum DefaultReporter: CaseIterable {
        case generalInfo
        case appSystemMetadata
        case logs
        case userDefaults

        var reporter: DiagnosticsReporting.Type {
            switch self {
            case .generalInfo:
                return GeneralInfoReporter.self
            case .appSystemMetadata:
                return AppSystemMetadataReporter.self
            case .logs:
                return LogsReporter.self
            case .userDefaults:
                return UserDefaultsReporter.self
            }
        }

        public static var allReporters: [DiagnosticsReporting.Type] {
            allCases.map { $0.reporter }
        }
    }

    /// The title that is used in the header of the web page of the report.
    static var reportTitle: String = "\(Bundle.appName) - Diagnostics Report"

    /// Creates the report by making use of the given reporters.
    /// - Parameters:
    ///   - reporters: The reporters to use. Defaults to `DefaultReporter.allReporters`. Use this parameter if you'd like to exclude certain reports.
    ///   - filters: The filters to use for the generated diagnostics. Should conform to the `DiagnosticsReportFilter` protocol.
    public static func create(using reporters: [DiagnosticsReporting.Type] = DefaultReporter.allReporters, filters: [DiagnosticsReportFilter.Type]? = nil) -> DiagnosticsReport {
        let reportChapters = reporters.map { reporter -> DiagnosticsChapter in
            var chapter = reporter.report()
            if let filters = filters, !filters.isEmpty {
                chapter.applyingFilters(filters)
            }
            return chapter
        }
        
        let html = generateHTML(using: reportChapters)
        let data = html.data(using: .utf8)!
        return DiagnosticsReport(filename: "Diagnostics-Report.html", html: html, data: data)
    }
}

// MARK: - HTML Report Generation
extension DiagnosticsReporter {
    private static func generateHTML(using reportChapters: [DiagnosticsChapter]) -> HTML {
        var html = "<html>"
        html += header()
        html += "<body>"
        html += "<main class=\"container\">"

        html += menu(using: reportChapters)
        html += mainContent(using: reportChapters)

        html += "</main>"
        html += footer()
        html += "</body>"
        return html
    }

    private static func header() -> HTML {
        var html = "<head>"
        html += "<title>\(Bundle.appName) - Diagnostics Report</title>"
        html += style()
        html += "<meta charset=\"utf-8\">"
        html += "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">"
        html += "</head>"
        return html
    }

    private static func footer() -> HTML {
        return """
        <footer>
        </footer>
        """
    }

    static func style() -> HTML {
        /// To add Swift Package Manager support we're adding the CSS directly here. This is because we can't add resources to packages in SPM.
        return """
        <style>body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif,"Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol";-webkit-font-smoothing:antialiased;-moz-osx-font-smoothing:grayscale;font-size:1em;line-height:1.3em;margin:50px 50px 20px;color:#17181a}h1{margin:10px 0 20px;font-weight:400}h3{display:block;font-weight:400;font-size:20px;margin:0 0 10px}p{font-size:14px;margin:0 0 10px;display:block}p:last-child,ul:last-child{margin-bottom:0}pre{overflow:scroll}.container{display:flex;justify-content:space-between;flex-direction:row-reverse;max-width:960px;margin:0 auto}.main-content{width:calc(100% - 190px)}.nav-container{width:180px}.nav-container nav{position:fixed;border-radius:4px}.nav-container nav ul{margin:0}.nav-container nav ul li{margin-bottom:5px;display:block}.nav-container nav ul li:last-child{margin-bottom:0}.nav-container nav ul li a{font-size:14px;color:#444;text-decoration:none}.nav-container nav ul li a:hover{color:#000;text-decoration:underline}.chapter{position:relative;margin-bottom:20px;padding-bottom:20px;border-bottom:1px solid #ccc}.chapter:last-child{border-bottom:0}.chapter .anchor{position:absolute;top:-20px}table th{text-align:left;padding:0 5px 0 0;font-weight:500}table td,table th{font-size:14px}footer{text-align:center;font-size:14px}footer a{color:#111}.footer-logo{width:20px;display:inline-block;vertical-align:middle}@media(max-width:768px){body{margin:20px}.container{margin:0}header h1{font-size:24px}.main-content{width:100%}.nav-container{display:none}table td,table th{display:block}table td{margin-bottom:5px}}@media (prefers-color-scheme:dark){body{background:#111;color:#f7f7f7}.chapter{border-bottom-color:rgba(255,255,255,.3)}.nav-container nav ul li a{color:rgba(255,255,255,.6)}.nav-container nav ul li a:hover{color:#fff}footer a{color:rgba(255,255,255,.85)}footer a:hover{color:#fff}.footer-logo path{fill:#f7f7f7}}</style>
        """
    }

    static func menu(using chapters: [DiagnosticsChapter]) -> HTML {
        var html = "<aside class=\"nav-container\"><nav><ul>"
        chapters.forEach { chapter in
            html += "<li><a href=\"#\(chapter.title.anchor)\">\(chapter.title)</a></li>"
        }
        html += "</ul></nav></aside>"
        return html
    }

    static func mainContent(using chapters: [DiagnosticsChapter]) -> HTML {
        var html = "<div class=\"main-content\">"
        html += "<header><h1>\(reportTitle)</h1></header>"
        chapters.forEach { chapter in
            html += chapter.html()
        }
        html += "</div>"
        return html
    }
}

extension String {
    var anchor: String {
        return lowercased().replacingOccurrences(of: " ", with: "-")
    }
}
