import XCTest
import SharkUtils

class WeakContainerTests: XCTestCase {

    func testWeak() {
        var obj: AnyObject? = NSObject()
        let container = obj.flatMap { WeakContainer($0) }
        XCTAssertNotNil(container?.value)
        obj = nil
        XCTAssertNil(container?.value)
    }

    func testEquales_sameInstance_true() {
        let obj = NSObject()
        XCTAssertEqual(WeakContainer(obj), WeakContainer(obj))
        XCTAssertNotEqual(WeakContainer(obj), WeakContainer(NSObject()))
    }

    func testRemoveReleased_objectNotRetained_arrayEntryRemoved() {
        var releasing = [NSObject(), NSObject()]
        let retained = [NSObject(), NSObject(), NSObject()]
        var weakArray = (retained + releasing).map { WeakContainer($0) }

        XCTAssertEqual(weakArray.count, 5)
        weakArray.removeReleased()
        XCTAssertEqual(weakArray.count, 5)

        releasing.removeAll()
        XCTAssertEqual(weakArray.count, 5)
        weakArray.removeReleased()
        XCTAssertEqual(weakArray.count, 3)
    }
    
    static var allTests = [
        ("testWeak", testWeak),
        ("testEquales_sameInstance_true", testEquales_sameInstance_true),
        ("testRemoveReleased_objectNotRetained_arrayEntryRemoved", testRemoveReleased_objectNotRetained_arrayEntryRemoved),
    ]
}
