//
//  DraggableStepper.swift
//  DraggableStepper
//
//  Created by Hector Ghinaglia on 9/6/17.
//  Copyright © 2017 Hector Ghinaglia. All rights reserved.
//

import UIKit

public protocol DraggableStepperProtocol: class {
    var isDraggingEnabled: Bool { get }
    func didChange(total: Int)
}

public extension DraggableStepperProtocol {
    var isDraggingEnabled: Bool { return true }
}

open class DraggableStepper: UIView {
    
    public weak var delegate: DraggableStepperProtocol?
    public var step: Int
    public var range: ClosedRange<Int>
    
    private var totalBeforeInteraction: Int = 0
    private(set) var total: Int {
        didSet {
            setupResultLabel()
            delegate?.didChange(total: self.total)
        }
    }
    
    private weak var stepUpButton: UIButton!
    private weak var stepDownButton: UIButton!
    
    public weak var stepUpLabel: UILabel!
    public weak var stepDownLabel: UILabel!
    public weak var resultLabel: UILabel!
    
    public init() {
        self.range = 0...10
        self.step = 1
        self.total = range.lowerBound
        super.init(frame: .zero)
        setup()
    }
    
    public init(range: ClosedRange<Int>, step: Int = 1) {
        self.range = range
        self.step = step
        self.total = range.lowerBound
        super.init(frame: .zero)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.range = 0...10
        self.step = 1
        self.total = range.lowerBound
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - UI elements setup
    
    private func setup() {
        setupPanGesture()
        setupResultLabel()
        setupLabels()
        setupButtons()
        setupConstraints()
    }
    
    private func setupPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandling(sender:)))
        addGestureRecognizer(pan)
    }
    
    private func setupResultLabel() {
        if resultLabel == nil {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = tintColor
            label.textAlignment = .right
            label.minimumScaleFactor = 0.8
            label.font = .systemFont(ofSize: 38.0)
            addSubview(label)
            self.resultLabel = label
        }
        resultLabel.text = "\(total)"
    }
    
    private func setupLabels() {
        let upLabel = UILabel()
        upLabel.translatesAutoresizingMaskIntoConstraints = false
        upLabel.text = "▲"
        upLabel.textColor = tintColor
        addSubview(upLabel)
        self.stepUpLabel = upLabel
        
        let downLabel = UILabel()
        downLabel.translatesAutoresizingMaskIntoConstraints = false
        downLabel.text = "▼"
        downLabel.textColor = tintColor
        addSubview(downLabel)
        self.stepDownLabel = downLabel
    }
    
    private func setupButtons() {
        let stepUpButton = UIButton(type: .system)
        stepUpButton.translatesAutoresizingMaskIntoConstraints = false
        stepUpButton.setTitle("", for: .normal)
        stepUpButton.addTarget(self, action: #selector(stepUp(sender:)), for: .touchUpInside)
        addSubview(stepUpButton)
        self.stepUpButton = stepUpButton
        
        let stepDownButton = UIButton(type: .system)
        stepDownButton.translatesAutoresizingMaskIntoConstraints = false
        stepDownButton.setTitle("", for: .normal)
        stepDownButton.addTarget(self, action: #selector(stepDown(sender:)), for: .touchUpInside)
        addSubview(stepDownButton)
        self.stepDownButton = stepDownButton
    }
    
    // MARK: - Actions
    
    @objc private func panGestureHandling(sender: UIPanGestureRecognizer) {
        guard delegate?.isDraggingEnabled ?? true else { return }        
        
        let translation = sender.translation(in: self)
        
        switch sender.state {
        case .began:
            totalBeforeInteraction = total
        case .changed:
            let requiredDistanceForUpdate: CGFloat = 100.0 / CGFloat(range.upperBound - range.lowerBound)
            let deltaSteps = Int(round(-translation.y / requiredDistanceForUpdate))
            updateTotal(newTotal: totalBeforeInteraction + deltaSteps)
        default: break
        }
    }
    
    public func updateTotal(newTotal: Int) {
        total = max(min(newTotal, range.upperBound), range.lowerBound)
    }
    
    @objc private func stepUp(sender: UIButton) {
        updateTotal(newTotal: total + step)
    }
    
    @objc private func stepDown(sender: UIButton) {
        updateTotal(newTotal: total - step)
    }
    
    // MARK: - Layouts
    
    private func setupConstraints() {
        
        let views: [String: Any] = [
            "upButton": stepUpButton,
            "downButton": stepDownButton,
            "upLabel": stepUpLabel,
            "downLabel": stepDownLabel,
            "resultLabel": resultLabel
        ]
        
        let resultLabelHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(margin)-[resultLabel]", options: [], metrics: ["margin": 16.0], views: views)
        let resultLabelVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(margin)-[resultLabel]-(margin)-|", options: [], metrics: ["margin": 16.0], views: views)
        addConstraints(resultLabelHorizontalConstraints + resultLabelVerticalConstraints)
        
        let upLabelHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[resultLabel]-(margin)-[upLabel]-(margin)-|", options: [], metrics: ["margin": 16.0], views: views)
        let upLabelVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[upLabel]", options: [], metrics: nil, views: views)
        let upLabelHeightConstraint = NSLayoutConstraint(
            item: stepUpLabel,
            attribute: .height,
            relatedBy: .equal,
            toItem: self,
            attribute: .height,
            multiplier: 0.5,
            constant: 0.0
        )
        addConstraints(upLabelHorizontalConstraints + upLabelVerticalConstraints + [upLabelHeightConstraint])
        
        let downLabelHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:[resultLabel]-(margin)-[downLabel]-(margin)-|", options: [], metrics: ["margin": 16.0], views: views)
        let downLabelVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[upLabel][downLabel]|", options: [], metrics: nil, views: views)
        let downLabelHeightConstraint = NSLayoutConstraint(
            item: stepDownLabel,
            attribute: .height,
            relatedBy: .equal,
            toItem: self,
            attribute: .height,
            multiplier: 0.5,
            constant: 0.0
        )
        addConstraints(downLabelHorizontalConstraints + downLabelVerticalConstraints + [downLabelHeightConstraint])
        
        let upButtonHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[upButton]|", options: [], metrics: nil, views: views)
        let upButtonVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:|[upButton]", options: [], metrics: nil, views: views)
        let upButtonHeightConstraint = NSLayoutConstraint(
            item: stepUpButton,
            attribute: .height,
            relatedBy: .equal,
            toItem: self,
            attribute: .height,
            multiplier: 0.5,
            constant: 0.0
        )
        addConstraints(upButtonHorizontalConstraints + upButtonVerticalConstraints + [upButtonHeightConstraint])
        
        let downButtonHorizontalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "H:|[downButton]|", options: [], metrics: nil, views: views)
        let downButtonVerticalConstraints = NSLayoutConstraint.constraints(
            withVisualFormat: "V:[upButton][downButton]|", options: [], metrics: nil, views: views)
        let downButtonHeightConstraint = NSLayoutConstraint(
            item: stepDownButton,
            attribute: .height,
            relatedBy: .equal,
            toItem: self,
            attribute: .height,
            multiplier: 0.5,
            constant: 0.0
        )
        addConstraints(downButtonHorizontalConstraints + downButtonVerticalConstraints + [downButtonHeightConstraint])
    }
    
}
