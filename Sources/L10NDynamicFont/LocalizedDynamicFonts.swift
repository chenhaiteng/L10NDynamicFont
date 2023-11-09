// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

extension CaseIterable {
    static func from(string: String) -> Self? {
        return Self.allCases.first { string == "\($0)" }
    }
    var string: String { "\(self)" }
}

struct LocalizedDynamicFonts: Decodable {
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case largeTitle
        case title
        case title2
        case title3
        case body
        case callout
        case caption
        case caption2
        case headline
        case subheadline
        case footnote
        case extraLargeTitle
        case extraLargetTitle2
    }
    
    private var dictionay: [String: Any]
    
    init?(dictionay: Any?) {
        guard let dictionay = dictionay as? [String : Any] else { return nil }
        self.dictionay = dictionay
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        dictionay = [:]
        for key in CodingKeys.allCases {
            if let localized = try? values.decode([String:String].self, forKey: key) {
                dictionay[key.rawValue] = localized
            }
        }
    }
    
    init(with data: Data) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(LocalizedDynamicFonts.self, from: data)
    }
    
    subscript(style: Font.TextStyle, language: String) -> String? {
        return (dictionay[style.string] as? [String: String])?[language]
    }
}

extension Font.TextStyle {
#if canImport(UIKit)
    typealias TextStyle = UIFont.TextStyle
#endif
#if canImport(AppKit)
    typealias TextStyle = NSFont.TextStyle
#endif
    var mappedStyle: TextStyle {
        switch self {
        case .title:
            return .title1
        case .title2:
            return .title2
        case .title3:
            return .title3
        case .largeTitle:
            #if os(tvOS)
            if #available(tvOS 17.0, *) {
                return .extraLargeTitle
            } else {
                return .title1
            }
            #else
            return .largeTitle
            #endif
        case .body:
            return .body
        case .callout:
            return .callout
        case .caption:
            return .caption1
        case .caption2:
            return .caption2
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .footnote:
            return .footnote
#if os(visionOS)
        case .extraLargeTitle:
            if #available(iOSApplicationExtension 17.0, *) {
                return .extraLargeTitle
            } else {
                return .largeTitle
            }
        case .extraLargeTitle2:
            if #available(iOSApplicationExtension 17.0, *) {
                return .extraLargeTitle2
            } else {
                return .largeTitle
            }
#endif
        @unknown default:
            return .body
        }
    }
    
    var font: Font {
        switch self {
        case .title:
            return .title
        case .title2:
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                return .title2
            } else {
                return .title
            }
        case .title3:
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                return .title3
            } else {
                return .title
            }
        case .largeTitle:
            return .largeTitle
        case .body:
            return .body
        case .callout:
            return .callout
        case .caption:
            return .caption
        case .caption2:
            if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                return .caption2
            } else {
                return .caption
            }
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .footnote:
            return .footnote
#if os(visionOS)
        case .extraLargeTitle:
            if #available(iOSApplicationExtension 17.0, *) {
                return .extraLargeTitle
            } else {
                return UIFont.TextStyle.largeTitle
            }
        case .extraLargeTitle2:
            if #available(iOSApplicationExtension 17.0, *) {
                return .extraLargeTitle2
            } else {
                return UIFont.TextStyle.largeTitle
            }
#endif
        @unknown default:
            return .body
        }
    }
}

extension Font {
    static func textStyleSize(_ style: Font.TextStyle) -> CGFloat {
        #if canImport(UIKit)
        UIFont.preferredFont(forTextStyle: style.mappedStyle).pointSize
        #elseif canImport(AppKit)
        NSFont.preferredFont(forTextStyle: style.mappedStyle).pointSize
        #endif
    }
}

extension Locale {
    var compatiableLanguageCode: String? {
        if #available(macOS 13, iOS 16, tvOS 16, watchOS 9, *) {
            return Locale.current.language.languageCode?.identifier
        } else {
            return Locale.current.languageCode
        }
    }
}

extension Font {
    public static func localizedFont(size: CGFloat) -> Font {
        switch Locale.current.compatiableLanguageCode {
        case .none:
            return .system(size: size)
        case let languageCode?:
            if let fonts = Bundle.main.infoDictionary?["LocalizedFonts"] as? [String:String], let localizedFont = fonts[languageCode] {
                return .custom(localizedFont, size: size)
            } else {
                debugPrint("language code: \(languageCode)")
                return .system(size: size)
            }
        }
    }
    
    static func loadFonts() -> LocalizedDynamicFonts? {
        if let url = Bundle.main.url(forResource: "DynamicLocalizedFonts", withExtension: "json"), let data = try? Data(contentsOf: url), let dynamicFonts = try? LocalizedDynamicFonts(with: data) {
            return dynamicFonts
        }
        return LocalizedDynamicFonts(dictionay: Bundle.main.infoDictionary?["DynamicLocalizedFonts"])
    }
    
    static func dynamicLocalizedFont(_ style: Font.TextStyle) -> Font {
        switch Locale.current.compatiableLanguageCode {
        case .none:
            debugPrint("no locale information")
            return style.font // Cannot get language code
        case let languageCode?:
            if let fonts = loadFonts(), let fontName = fonts[style, languageCode] {
                if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                    return .custom(fontName, size: textStyleSize(style), relativeTo: style)
                } else {
                    return .custom(fontName, size: textStyleSize(style))
                }
            } else {
                debugPrint("language \(languageCode) has not support yet")
                return style.font
            }
        }
    }
    
    public static var localizedTitle: Font {
        dynamicLocalizedFont(.title)
    }
    
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    public static var localizedTitle2: Font {
        dynamicLocalizedFont(.title2)
    }
    
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    public static var localizedTitle3: Font {
        dynamicLocalizedFont(.title3)
    }
    
    public static var localizedCaption: Font {
        dynamicLocalizedFont(.caption)
    }
    
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    public static var localizedCaption2: Font {
        dynamicLocalizedFont(.caption2)
    }
    
    public static var localizedLargeTitle: Font {
        dynamicLocalizedFont(.largeTitle)
    }
    
    public static var localizedBody: Font {
        dynamicLocalizedFont(.body)
    }
    
    public static var localizedCallout: Font {
        dynamicLocalizedFont(.callout)
    }
    
    public static var localizedHeadline: Font {
        dynamicLocalizedFont(.headline)
    }
    
    public static var localizedSubheadline: Font {
        dynamicLocalizedFont(.subheadline)
    }
    
    public static var localizedFootnote: Font {
        dynamicLocalizedFont(.footnote)
    }
    
    @available(visionOS 1.0, *)
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public static var localizedExtraLargeTitle: Font {
        localizedFont(size: Font.textStyleSize(.extraLargeTitle))
    }
    
    @available(visionOS 1.0, *)
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    public static var localizedExtraLargeTitle2: Font {
        localizedFont(size: Font.textStyleSize(.extraLargeTitle2))
    }
}
