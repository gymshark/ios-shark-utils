import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(SharkUtilsTests.allTests),
        testCase(WeakContainerTests.allTests),
        testCase(WeakNonOptionalTests.allTests),
        testCase(WriteSafeTests.allTests),
    ]
}
#endif
