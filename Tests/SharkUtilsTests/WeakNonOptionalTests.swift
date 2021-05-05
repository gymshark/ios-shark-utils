import XCTest
@testable import SharkUtils

private class Dummy {
    var someValue: Int
    init(someValue: Int = 0) {
        self.someValue = someValue
    }
}

class WeakNonOptionalTests: XCTestCase {

    func testWrappedValue_retainElsewhere_existingInstance() {
        let sut = WeakNonOptional(wrappedValue: Dummy())
        let value = sut.wrappedValue
        value.someValue = 10
        XCTAssertEqual(sut.wrappedValue.someValue, 10)
        XCTAssertTrue(value === sut.wrappedValue)
    }
    
    func testWrappedValue_notRetainElsewhere_newInstance() {
        let sut = WeakNonOptional(wrappedValue: Dummy())
        var value: Dummy? = sut.wrappedValue
        value?.someValue = 10
        value = nil
        XCTAssertEqual(sut.wrappedValue.someValue, 0)
    }
    
    func testWrappedValue_notRetainElsewhere_newBuildInstance() {
        var buildResult = Dummy(someValue: 5)
        let sut = WeakNonOptional(wrappedValue: { buildResult })
        XCTAssertEqual(sut.wrappedValue.someValue, 5)
        buildResult = Dummy(someValue: 10)
        XCTAssertEqual(sut.wrappedValue.someValue, 10)
    }
    
    static var allTests = [
        ("testWrappedValue_retainElsewhere_existingInstance", testWrappedValue_retainElsewhere_existingInstance),
        ("testWrappedValue_notRetainElsewhere_newInstance", testWrappedValue_notRetainElsewhere_newInstance),
        ("testWrappedValue_notRetainElsewhere_newBuildInstance", testWrappedValue_notRetainElsewhere_newBuildInstance),
    ]
}
