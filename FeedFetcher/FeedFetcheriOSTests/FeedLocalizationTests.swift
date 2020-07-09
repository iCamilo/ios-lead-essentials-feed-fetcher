import XCTest
@testable import FeedFetcheriOS

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
         forEachLocalizedString(assert: { localizedComponents in
            if localizedComponents.value == localizedComponents.key {
                XCTFail("Missing \(localizedComponents.language) (\(localizedComponents.languageCode)) localized string for key: '\(localizedComponents.key)' in table: '\(localizedComponents.table)'")
            }
         })
        
    }
    
    func test_localizedStrings_noBlankOrEmptyValuesForAllSupportedLocalizations() {
        forEachLocalizedString(assert: { localizedComponents in
            if localizedComponents.value.isBlankOrEmpty {
                XCTFail("Empty \(localizedComponents.language) (\(localizedComponents.languageCode)) localized string for key: '\(localizedComponents.key)' in table: '\(localizedComponents.table)'")
            }
        })
    }
        
    // MARK: - Helpers
    
    private typealias LocalizedBundle = (bundle: Bundle, localization: String)
    private typealias LocalizedComponents = (table: String, language: String, languageCode: String, key: String, value: String)
    
    private func allLocalizationBundles(in bundle: Bundle, file: StaticString = #file, line: UInt = #line) -> [LocalizedBundle] {
        return bundle.localizations.compactMap { localization in
            guard
                let path = bundle.path(forResource: localization, ofType: "lproj"),
                let localizedBundle = Bundle(path: path)
                else {
                    XCTFail("Couldn't find bundle for localization: \(localization)", file: file, line: line)
                    return nil
            }
            
            return (localizedBundle, localization)
        }
    }
    
    private func allLocalizedStringKeys(in bundles: [LocalizedBundle], table: String, file: StaticString = #file, line: UInt = #line) -> Set<String> {
        return bundles.reduce([]) { (acc, current) in
            guard
                let path = current.bundle.path(forResource: table, ofType: "strings"),
                let strings = NSDictionary(contentsOfFile: path),
                let keys = strings.allKeys as? [String]
                else {
                    XCTFail("Couldn't load localized strings for localization: \(current.localization)", file: file, line: line)
                    return acc
            }
            
            return acc.union(Set(keys))
        }
    }
    
    private func forEachLocalizedString(assert action: (LocalizedComponents) -> Void) {
        let table = "Feed"
        let presentationBundle = Bundle(for: FeedPresenter.self)
        let localizationBundles = allLocalizationBundles(in: presentationBundle)
        let localizedStringKeys = allLocalizedStringKeys(in: localizationBundles, table: table)
        
        localizationBundles.forEach { (bundle, localization) in
        localizedStringKeys.forEach { key in
            let value = bundle.localizedString(forKey: key, value: nil, table: table)
            let language = Locale.current.localizedString(forLanguageCode: localization) ?? ""
            
            action((table: table, language: language, languageCode: localization, key: key, value: value))
                                                         
            }
        }
    }
}

private extension String {
    var isBlankOrEmpty: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
