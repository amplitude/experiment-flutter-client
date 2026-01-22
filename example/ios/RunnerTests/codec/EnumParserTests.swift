import XCTest
@testable import experiment_flutter
import AmplitudeExperiment

class EnumParserTests: XCTestCase {
    func testParseSource_localStorage_returnsLocalStorage() {
        do {
            let result = try EnumParser.parseSource("localStorage")
            XCTAssertEqual(result, .LocalStorage)
        } catch {
            XCTFail("Should not throw error for valid source")
        }
    }

    func testParseSource_initialVariants_returnsInitialVariants() {
        do {
            let result = try EnumParser.parseSource("initialVariants")
            XCTAssertEqual(result, .InitialVariants)
        } catch {
            XCTFail("Should not throw error for valid source")
        }
    }

    func testParseSource_invalidValue_throwsError() {
        XCTAssertThrowsError(try EnumParser.parseSource("invalid")) { error in
            XCTAssertTrue(error is NSError)
        }
    }

    func testParseSource_emptyString_throwsError() {
        XCTAssertThrowsError(try EnumParser.parseSource("")) { error in
            XCTAssertTrue(error is NSError)
        }
    }

    func testParseServerZone_us_returnsUS() {
        do {
            let result = try EnumParser.parseServerZone("us")
            XCTAssertEqual(result, .US)
        } catch {
            XCTFail("Should not throw error for valid server zone")
        }
    }

    func testParseServerZone_eu_returnsEU() {
        do {
            let result = try EnumParser.parseServerZone("eu")
            XCTAssertEqual(result, .EU)
        } catch {
            XCTFail("Should not throw error for valid server zone")
        }
    }

    func testParseServerZone_invalidValue_throwsError() {
        XCTAssertThrowsError(try EnumParser.parseServerZone("invalid")) { error in
            XCTAssertTrue(error is NSError)
        }
    }

    func testParseServerZone_emptyString_throwsError() {
        XCTAssertThrowsError(try EnumParser.parseServerZone("")) { error in
            XCTAssertTrue(error is NSError)
        }
    }
}
