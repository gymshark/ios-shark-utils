//
//  BasicUIActionHandler.swift
//  Store
//
//  Created by Dominic Campbell on 02/11/2020.
//  Copyright © 2020 Gymshark. All rights reserved.
//

import UIKit

public final class BasicUIActionHandler: NSObject {
    public var action: (() -> Void)?
    @objc public func performAction() {
        action?()
    }
}

public extension UIView {
    
    func tap(tapsRequired: Int = 1, touchesRequired: Int = 1, action: (() -> Void)?) {
        
        let handler = associatedObject {
            BasicUIActionHandler().with {
                let gesture = UITapGestureRecognizer(target: $0, action: #selector(BasicUIActionHandler.performAction))
                gesture.numberOfTapsRequired = tapsRequired
                gesture.numberOfTouchesRequired = touchesRequired
                addGestureRecognizer(gesture)
            }
        }
        
        handler.action = action
    }
    
    func longPress(minDuration: TimeInterval, action: (() -> Void)?){
        let handler = associatedObject {
            BasicUIActionHandler().with {
                let gesture = UILongPressGestureRecognizer(target: $0, action: #selector(BasicUIActionHandler.performAction))
                gesture.minimumPressDuration = minDuration
                addGestureRecognizer(gesture)
            }
        }
        
        handler.action = action
    }
}

public extension UIControl {
    
    func addTarget(forEvent event: Event, action: (() -> Void)?) {
        let handler = associatedObject {
            BasicUIActionHandler().with {
                addTarget($0, action: #selector(BasicUIActionHandler.performAction), for: event)
            }
        }
        
        handler.action = action
    }
    
    var touchUpInside: BasicUIActionHandler {
        associatedObject {
            BasicUIActionHandler().with {
                addTarget($0, action: #selector(BasicUIActionHandler.performAction), for: .touchUpInside)
            }
        }
    }
    
    var valueChanged: BasicUIActionHandler {
        associatedObject {
            BasicUIActionHandler().with {
                addTarget($0, action: #selector(BasicUIActionHandler.performAction), for: .valueChanged)
            }
        }
    }
}

public extension UIGestureRecognizer {
    var handler: BasicUIActionHandler {
        associatedObject {
            BasicUIActionHandler().with {
                self.addTarget($0, action: #selector(BasicUIActionHandler.performAction))
            }
        }
    }
}

public extension UIBarButtonItem {
    var handler: BasicUIActionHandler {
        associatedObject {
            BasicUIActionHandler().with {
                self.target = $0
                self.action = #selector(BasicUIActionHandler.performAction)
            }
        }
    }
}
