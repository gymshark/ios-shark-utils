//
//  ScrollStacks.swift
//  
//
//  Created by Russell Warwick on 02/05/2021.
//

import UIKit

public extension UIView {

    @discardableResult
    func VScroll(safeArea: Bool = false, @GenericArrayBuilder<UIView> views: () -> [UIView]) -> UIStackView {
        return VStack(safeArea: safeArea) {
            SharkUtils.VScroll(views: views)
        }
    }

    @discardableResult
    func HScroll(safeArea: Bool = false, fill: Bool = true, @GenericArrayBuilder<UIView> views: () -> [UIView]) -> UIStackView {
        return VStack(safeArea: safeArea) {
            SharkUtils.HScroll(views: views)
            
            if !fill {
                Space()
            }
        }
    }
}

public final class VScroll: UIStackView {
    
    // MARK: - UI
    
    let scrollView = UIScrollView().with {
        $0.alwaysBounceVertical = true
    }
    
    private var stackView = UIStackView().with {
        $0.axis = .vertical
        $0.distribution = .equalSpacing
        $0.alignment = .fill
    }
    
    // MARK: - Init
    
    init(@GenericArrayBuilder<UIView> views: () -> [UIView]) {
        super.init(frame: .zero)
        
        addArrangedSubview(scrollView)
        
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo:scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo:scrollView.bottomAnchor),
            stackView.topAnchor.constraint(equalTo:scrollView.topAnchor),
            stackView.widthAnchor.constraint(equalTo:scrollView.widthAnchor)
        ])

        stackView.addArrangedSubViews(views())
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

public final class HScroll: UIStackView {
    
    // MARK: - UI
    
    let scrollView = UIScrollView().with {
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = true
    }
    
    private var stackView = UIStackView().with {
        $0.axis = .horizontal
        $0.distribution = .equalSpacing
        $0.alignment = .fill
    }
    
    // MARK: - Init
    
    init(@GenericArrayBuilder<UIView> views: () -> [UIView]) {
        super.init(frame: .zero)
        backgroundColor = .cyan
        addArrangedSubview(scrollView)
        
        scrollView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo:scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo:scrollView.bottomAnchor),
            stackView.topAnchor.constraint(equalTo:scrollView.topAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        stackView.addArrangedSubViews(views())
    }

    required init(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
