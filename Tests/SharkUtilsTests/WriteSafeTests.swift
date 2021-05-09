
import XCTest
@testable import SharkUtils

class WriteSafeTests: XCTestCase {

    func testPerform_all_performActionsAreFirstInFirstOutQueuedSyncActions() throws {
        let sut = WriteSafe()
        var value = 0
        DispatchQueue.global(qos: .userInteractive).async {
            sut.perform {
                usleep(100)
                value = 2
            }
        }
        DispatchQueue.global(qos: .userInteractive).async {
            sut.perform {
                value *= 3
            }
        }
        let expectation = self.expectation(description: "first in first out not adhered too")
        DispatchQueue.global(qos: .userInteractive).async {
            let read = sut.perform {
                value
            }
            XCTAssertEqual(read, 6)
            expectation.fulfill()
            
        }
        wait(for: [expectation], timeout: 0.2)
    }
    
    static var allTests = [
        ("testPerform_all_performActionsAreFirstInFirstOutQueuedSyncActions", testPerform_all_performActionsAreFirstInFirstOutQueuedSyncActions),
    ]

}
