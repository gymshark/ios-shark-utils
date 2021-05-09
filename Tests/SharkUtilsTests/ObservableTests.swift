import XCTest
import SharkUtils

private struct Root: Equatable {
    var valA = 0
    var child = Child()
}

private struct Child: Equatable {
    var valB = 0
    var grandChild = GrandChild()
}

private struct GrandChild: Equatable {
    var valC = 0
}

public func ignoreNeverUsed(_ x: Any) {}

class ObservableTests: XCTestCase {

    func testOnSet_valueSet_called() {
        let observable = Observable.onSet(Root())
        var valC = observable.value.child.grandChild.valC
        var calls = 0
        let binding = observable.observeFromNextValue {
            calls.increment()
            valC = $0.child.grandChild.valC
        }
        ignoreNeverUsed(binding)

        observable.value.valA = 0
        XCTAssertEqual(calls, 1)

        observable.value.child.grandChild.valC = 3
        XCTAssertEqual(calls, 2)
        XCTAssertEqual(valC, 3)

        observable.value.valA = 4
        XCTAssertEqual(calls, 3)
        XCTAssertEqual(valC, 3)
    }

    func testOnChange_valueSetButNotChanged_notCalled() {
        let observable = Observable.onChange(Root())
        var calls = 0
        let binding = observable.observeFromNextValue { _ in
            calls.increment()
        }
        ignoreNeverUsed(binding)

        observable.value.child.grandChild.valC = 0
        XCTAssertEqual(calls, 0)

        observable.value.valA = 0
        XCTAssertEqual(calls, 0)
    }

    func testOnChange_valueSetChanged_called() {
        let observable = Observable.onChange(Root())
        var calls = 0
        let binding = observable.observeFromNextValue { _ in
            calls.increment()
        }
        ignoreNeverUsed(binding)

        observable.value.child.grandChild.valC = 3
        XCTAssertEqual(calls, 1)

        observable.value.valA = 5
        XCTAssertEqual(calls, 2)
    }
    
    func testOnChange_valueSet_noSetChildrenNotCalled() {
        let rootObservable = Observable.onChange(Root())
        let childObservable = rootObservable.synced(\.child)
        let grandChildObservable = childObservable.synced(\.grandChild)
        var rootCalls = 0
        var childCalls = 0
        var grandChildCalls = 0
        let bindings = [
            rootObservable.observeFromNextValue { _ in
                rootCalls.increment()
            },
            childObservable.observeFromNextValue { _ in
                childCalls.increment()
            },
            grandChildObservable.observeFromNextValue { _ in
                grandChildCalls.increment()
            }
        ]
        ignoreNeverUsed(bindings)

        func assertNoCalls(line: UInt = #line) {
            XCTAssertEqual(rootCalls, 0, line: line)
            XCTAssertEqual(childCalls, 0, line: line)
            XCTAssertEqual(grandChildCalls, 0, line: line)
        }

        rootObservable.value.valA = 0
        assertNoCalls()

        rootObservable.value.child.grandChild.valC = 0
        assertNoCalls()

        grandChildObservable.value.valC = 0
        assertNoCalls()

        rootObservable.value.child.grandChild.valC = 0
        assertNoCalls()

        grandChildObservable.value.valC = 0
        assertNoCalls()
    }
    
    func testOnChange_parentRefNotRetained_called() {
        var rootObservable: Observable? = Observable.onChange(Root())
        let childObservable = rootObservable?.synced(\.child)

        var rootCalls = 0
        var childCalls = 0

        let bindings = [
            rootObservable?.observeFromNextValue { _ in
                rootCalls.increment()
            },
            childObservable?.observeFromNextValue { _ in
                childCalls.increment()
            }
        ]
        ignoreNeverUsed(bindings)

        rootObservable = nil
        childObservable?.value.valB = 5

        XCTAssertEqual(rootCalls, 0)
        XCTAssertEqual(childCalls, 1)
    }

    func testOnChange_setSameValueOnRoot_noCalls() {
        let rootObservable = Observable.onChange(Root())
        let childObservable = rootObservable.synced(\.child)
        let grandChildObservable = childObservable.synced(\.grandChild)

        var rootCalls = 0
        var childCalls = 0
        var grandChildCalls = 0

        let bindings = [
            rootObservable.observeFromNextValue { _ in
                rootCalls.increment()
            },
            childObservable.observeFromNextValue { _ in
                childCalls.increment()
            },
            grandChildObservable.observeFromNextValue { _ in
                grandChildCalls.increment()
            }
        ]
        ignoreNeverUsed(bindings)

        func assertNoCalls(line: UInt = #line) {
            XCTAssertEqual(rootCalls, 0, line: line)
            XCTAssertEqual(childCalls, 0, line: line)
            XCTAssertEqual(grandChildCalls, 0, line: line)
        }

        rootObservable.value.valA = 0
        assertNoCalls()

        rootObservable.value.child.grandChild.valC = 0
        assertNoCalls()
    }

    func testOnChang_setSameValueOnGrandChild_noCalls() {
        let rootObservable = Observable.onChange(Root())
        let childObservable = rootObservable.synced(\.child)
        let grandChildObservable = childObservable.synced(\.grandChild)

        var rootCalls = 0
        var childCalls = 0
        var grandChildCalls = 0

        let bindings = [
            rootObservable.observeFromNextValue { _ in
                rootCalls.increment()
            },
            childObservable.observeFromNextValue { _ in
                childCalls.increment()
            },
            grandChildObservable.observeFromNextValue { _ in
                grandChildCalls.increment()
            }
        ]
        ignoreNeverUsed(bindings)

        func assertNoCalls(line: UInt = #line) {
            XCTAssertEqual(rootCalls, 0, line: line)
            XCTAssertEqual(childCalls, 0, line: line)
            XCTAssertEqual(grandChildCalls, 0, line: line)
        }

        grandChildObservable.value.valC = 0
        assertNoCalls()

        rootObservable.value.child.grandChild.valC = 0
        assertNoCalls()
    }

    func testOnChangeWritable_changeRootValue_onlyRootCalled() {
        let rootObservable = Observable.onChange(Root())
        let childObservable = rootObservable.synced(\.child)
        let grandChildObservable = childObservable.synced(\.grandChild)

        var valA = 0
        var valB = 0
        var valC  = 0

        var rootCalls = 0
        var childCalls = 0
        var grandChildCalls = 0

        let bindings = [
            rootObservable.observeFromNextValue {
                valA = $0.valA
                rootCalls.increment()
            },
            childObservable.observeFromNextValue {
                valB = $0.valB
                childCalls.increment()
            },
            grandChildObservable.observeFromNextValue {
                valC = $0.valC
                grandChildCalls.increment()
            }
        ]

        ignoreNeverUsed(bindings)

        func assertCalls(expectedRootCalls: Int, expectedChildCalls: Int, expectedGrandChildCalls: Int, line: UInt = #line) {
            XCTAssertEqual(rootCalls, expectedRootCalls, line: line)
            XCTAssertEqual(childCalls, expectedChildCalls, line: line)
            XCTAssertEqual(grandChildCalls, expectedGrandChildCalls, line: line)
        }
        func assertValues(expectedValA: Int, expectedValB: Int, expectedValC: Int, line: UInt = #line) {
            XCTAssertEqual(valA, expectedValA, line: line)
            XCTAssertEqual(valB, expectedValB, line: line)
            XCTAssertEqual(valC, expectedValC, line: line)
        }

        rootObservable.value.valA = 10
        assertCalls(expectedRootCalls: 1, expectedChildCalls: 0, expectedGrandChildCalls: 0)
        assertValues(expectedValA: 10, expectedValB: 0, expectedValC: 0)
    }

    func testOnChangeWritable_changeGrandChildValue_allCalled() {
        let rootObservable = Observable.onChange(Root())
        let childObservable = rootObservable.synced(\.child)
        let grandChildObservable = childObservable.synced(\.grandChild)

        var valA = 0
        var valB = 0
        var valC  = 0

        var rootCalls = 0
        var childCalls = 0
        var grandChildCalls = 0

        let bindings = [
            rootObservable.observeFromNextValue {
                valA = $0.valA
                rootCalls.increment()
            },
            childObservable.observeFromNextValue {
                valB = $0.valB
                childCalls.increment()
            },
            grandChildObservable.observeFromNextValue {
                valC = $0.valC
                grandChildCalls.increment()
            }
        ]

        ignoreNeverUsed(bindings)

        func assertCalls(expectedRootCalls: Int, expectedChildCalls: Int, expectedGrandChildCalls: Int, line: UInt = #line) {
            XCTAssertEqual(rootCalls, expectedRootCalls, line: line)
            XCTAssertEqual(childCalls, expectedChildCalls, line: line)
            XCTAssertEqual(grandChildCalls, expectedGrandChildCalls, line: line)
        }
        func assertValues(expectedValA: Int, expectedValB: Int, expectedValC: Int, line: UInt = #line) {
            XCTAssertEqual(valA, expectedValA, line: line)
            XCTAssertEqual(valB, expectedValB, line: line)
            XCTAssertEqual(valC, expectedValC, line: line)
        }

        rootObservable.value.child.grandChild.valC = 10
        assertCalls(expectedRootCalls: 1, expectedChildCalls: 1, expectedGrandChildCalls: 1)
        assertValues(expectedValA: 0, expectedValB: 0, expectedValC: 10)

        rootObservable.value.child.grandChild.valC = 20
        assertCalls(expectedRootCalls: 2, expectedChildCalls: 2, expectedGrandChildCalls: 2)
        assertValues(expectedValA: 0, expectedValB: 0, expectedValC: 20)
    }
    
    func testObserveFromNextValue_bindTokenNotRetained_notCalled() {
        let observable = Observable.onSet(Root())
        var calls = 0
        _ = observable.observeFromNextValue { _ in
            calls.increment()
        }

        observable.value.child.grandChild.valC = 3
        XCTAssertEqual(calls, 0)
    }

    func testObserve_all_called() {
        let observable = Observable.onSet(Root())
        var calls = 0
        let binding = observable.observe { _ in
            calls.increment()
        }
        ignoreNeverUsed(binding)

        XCTAssertEqual(calls, 1)

        observable.value.child.grandChild.valC = 3
        XCTAssertEqual(calls, 2)
    }
    
    
    static var allTests = [
        ("testObserve_all_called", testObserve_all_called),
        ("testObserveFromNextValue_bindTokenNotRetained_notCalled", testObserveFromNextValue_bindTokenNotRetained_notCalled),
        ("testOnChangeWritable_changeGrandChildValue_allCalled", testOnChangeWritable_changeGrandChildValue_allCalled),
        ("testOnChangeWritable_changeRootValue_onlyRootCalled", testOnChangeWritable_changeRootValue_onlyRootCalled),
        ("testOnChange_setSameValueOnRoot_noCalls", testOnChange_setSameValueOnRoot_noCalls),
        ("testOnChang_setSameValueOnGrandChild_noCalls", testOnChang_setSameValueOnGrandChild_noCalls),
        
        ("testOnChange_parentRefNotRetained_called", testOnChange_parentRefNotRetained_called),
        ("testOnChange_valueSet_noSetChildrenNotCalled", testOnChange_valueSet_noSetChildrenNotCalled),
        
        ("testOnChange_valueSetChanged_called", testOnChange_valueSetChanged_called),
        ("testOnChange_valueSetButNotChanged_notCalled", testOnChange_valueSetButNotChanged_notCalled),
        ("testOnSet_valueSet_called", testOnSet_valueSet_called),
    ]
}
