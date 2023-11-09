import XCTest
import SwiftUI
@testable import L10NDynamicFont

final class LocalizedDynamicFontsTests: XCTestCase {
    let mockData = "{\"title\":{\"en\":\"enFont\", \"zh\":\"zhFont\"}}".data(using: .utf8)
    func testDecode() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
        
        if let data = mockData {
            let decoder = JSONDecoder()
            let fonts = try decoder.decode(LocalizedDynamicFonts.self, from: data)
            XCTAssertEqual(fonts[.title, "en"], "enFont")
            XCTAssertEqual(fonts[.title, "zh"], "zhFont")
            XCTAssertNil(fonts[.title, "jp"])
            XCTAssertNil(fonts[.caption, "zh"])
            XCTAssertNil(fonts[.caption, "en"])
        }
    }
    
    func testInit() throws {
        if let data = mockData {
            let fonts = try LocalizedDynamicFonts(with: data)
            XCTAssertEqual(fonts[.title, "en"], "enFont")
            XCTAssertEqual(fonts[.title, "zh"], "zhFont")
            XCTAssertNil(fonts[.title, "jp"])            
            XCTAssertNil(fonts[.caption, "zh"])
            XCTAssertNil(fonts[.caption, "en"])
        }
    }
}
