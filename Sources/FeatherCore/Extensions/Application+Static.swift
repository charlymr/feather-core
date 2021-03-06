//
//  Application+Static.swift
//  FeatherCore
//
//  Created by Tibor Bodecs on 2020. 11. 20..
//

public extension Application {
    
    /// without trailing slash
    static let baseUrl: String = (Feather.https ? "https" : "http") + "://" + Feather.hostname + ":" + (Feather.port == 80 ? "" : String(Feather.port))

    // paths are always absolute, with a trailing slash
    struct Paths {
        public static let base = URL(fileURLWithPath: Feather.workDir)

        public static let resources = base.appendingPathComponent(Directories.resources)
        public static let templates = resources.appendingPathComponent(Directories.templates)
        public static let defaultTemplate = templates.appendingPathComponent(Directories.defaultTemplate)
        
        public static let `public` = base.appendingPathComponent(Directories.public)
        public static let assets = `public`.appendingPathComponent(Directories.assets)
        public static let css = `public`.appendingPathComponent(Directories.css)
        public static let images = `public`.appendingPathComponent(Directories.images)
        public static let javascript = `public`.appendingPathComponent(Directories.javascript)
        public static let svg = `public`.appendingPathComponent(Directories.svg)
        public static let fields = resources.appendingPathComponent(Directories.fields)

    }

    // locations are always relative with a trailing slash
    struct Directories {
        public static let resources: String = "Resources"
        public static let templates: String = "Templates"
        public static let defaultTemplate: String = "Default"
        public static let fields: String = "Labels/\(Config.fields)"
        public static let `public`: String = "Public"
        public static let assets: String = "assets"
        public static let css: String = "css"
        public static let images: String = "img"
        public static let javascript: String = "js"
        public static let svg: String = "svg"
    }
    
    static func dateFormatter(dateStyle: DateFormatter.Style = .short, timeStyle: DateFormatter.Style = .short) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = Application.Config.timezone
        formatter.locale =  Application.Config.locale
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        return formatter
    }
}
