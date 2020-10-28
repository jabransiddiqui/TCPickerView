//
//  TCPickerView.swift
//  TCPickerView
//
//  Created by Jibran SiddiQui on 28/10/2020.
//  Copyright © 2020 Jibran SiddiQui. All rights reserved.
//


import UIKit

public protocol TCPickerViewDelegate: class {
    func pickerView(_ pickerView: TCPickerView, didSelectRowAtIndex index: Int)
}

open class TCPickerView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    public enum Mode {
        case none
        case single
        case multiply
    }
    
    public struct Value {
        public let title: String
        public var isChecked: Bool
        
        public init(title: String, isChecked: Bool = false) {
            self.title = title
            self.isChecked = isChecked
        }
    }
    
    public typealias Completion = ([Int]) -> Void
    fileprivate let tableViewCellIdentifier = "TableViewCell"
    fileprivate var titleLabel: UILabel?
    fileprivate var numberOfRowsss: Int = 0
    fileprivate var doneButton: UIButton?
    fileprivate var closeButton: UIButton?
    fileprivate var containerView: UIView?
    fileprivate var centerXConstraint: NSLayoutConstraint?
    fileprivate var centerYConstraint: NSLayoutConstraint?
    fileprivate var tableView: UITableView?
    
    
    open var allowTouchOutsideToDismiss: Bool = true {
        didSet {
            weak var weakSelf = self
            if weakSelf != nil {
                if allowTouchOutsideToDismiss == false {
                    weakSelf!.tapOutsideTouchGestureRecognizer.removeTarget(weakSelf!, action: #selector(TCPickerView.close))
                }
                else {
                    weakSelf!.tapOutsideTouchGestureRecognizer.addTarget(weakSelf!, action: #selector(TCPickerView.close))
                }
            }
        }
    }
    fileprivate var tapOutsideTouchGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    open var title: String = "Select" {
        didSet {
            self.titleLabel?.text = self.title
        }
    }
    open var numberOfRows: Int = 3 {
        didSet {
            self.numberOfRowsss = self.numberOfRows
        }
    }
    open var doneText: String = "OK" {
        didSet {
            self.doneButton?.setTitle(self.doneText, for: .normal)
        }
    }
    open var closeText: String = "CANCEL" {
        didSet {
            self.closeButton?.setTitle(self.closeText, for: .normal)
        }
    }
    open var textColor: UIColor = UIColor.black {
        didSet {
            self.titleLabel?.textColor = UIColor.black
            self.doneButton?.titleLabel?.textColor = UIColor.white
            self.closeButton?.titleLabel?.textColor = UIColor.black
        }
    }
    open var mainColor: UIColor = UIColor(red:1.00, green:0.76, blue:0.14, alpha:1.0) {
        didSet {
            self.titleLabel?.backgroundColor = self.mainColor
        }
    }
    
    open var okButtonColor: UIColor = UIColor(red:0.24, green:0.59, blue:0.09, alpha:1.0) {
        
        didSet {
            
            self.doneButton?.backgroundColor = self.okButtonColor
            
        }
    }
    open var closeButtonColor: UIColor = UIColor(red: 198/255,
        green: 198/255, blue: 198/255, alpha: 1) {
        didSet {
            self.closeButton?.backgroundColor = self.closeButtonColor
        }
    }
    open var buttonFont: UIFont? = UIFont(name: "Helvetica", size: 15.0) {
        didSet {
            self.doneButton?.titleLabel?.font = self.buttonFont
            self.closeButton?.titleLabel?.font = self.buttonFont
        }
    }
    open var titleFont: UIFont? = UIFont(name: "Helvetica-Bold", size: 15.0) {
        didSet {
            self.titleLabel?.font = self.titleFont
        }
    }
    open var titleColor: UIColor? = UIColor(red:1.00, green:0.78, blue:0.05, alpha:1.0) {
        didSet {
            self.titleLabel?.textColor = self.titleColor
        }
    }
    
    open var values: [Value] = [] {
        didSet {
            self.tableView?.reloadData()
        }
    }
    open weak var delegate: TCPickerViewDelegate?
    open var completion: Completion?
    open var selection: Mode = .multiply
    
    public init(numberOfRowsss : Int) {
        self.numberOfRowsss = numberOfRowsss
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        let frame: CGRect = CGRect(x: 0, y: 0, width: screenWidth,
            height: screenHeight)
        super.init(frame: frame)
        self.initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initialize()
    }

    fileprivate func initialize() {
        // Gesture for background
        if allowTouchOutsideToDismiss == true {
            self.tapOutsideTouchGestureRecognizer.addTarget(self, action: #selector(TCPickerView.close))
        }
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        let width: CGFloat = screenWidth - 84
        //let height: CGFloat = 400
        var height: CGFloat = 300
        if(numberOfRowsss < 3){
    
            height = CGFloat(100 + (50 * numberOfRowsss))
            
        }
        if(numberOfRowsss > 3){
            height = 300
        }
        let x: CGFloat = 32
        let y: CGFloat = (screenHeight - height) / 2
        let frame: CGRect = CGRect(x: x, y: y, width: width, height: height)
        
        self.containerView = UIView(frame: frame)
        self.doneButton = UIButton(frame: CGRect.zero)
        self.closeButton = UIButton(frame: CGRect.zero)
        self.titleLabel = UILabel(frame: CGRect.zero)
        self.tableView = UITableView(frame: CGRect.zero)
        self.tableView?.register(TCPickerTableViewCell.self,
            forCellReuseIdentifier: self.tableViewCellIdentifier)
        self.tableView?.tableFooterView = UIView()
        self.tableView?.dataSource = self
        self.tableView?.delegate = self
        
        self.doneButton?.addTarget(self, action: #selector(TCPickerView.done),
            for: .touchUpInside)
        self.closeButton?.addTarget(self, action: #selector(TCPickerView.close),
            for: .touchUpInside)
        self.setupUI()
        self.updateUI()
        self.closeButton?.setTitleColor(.black, for: .normal)

    }
    
    fileprivate func setupUI() {
        guard let containerView = self.containerView,
            let doneButton = self.doneButton,
            let closeButton = self.closeButton,
            let titleLabel = self.titleLabel,
            let tableView = self.tableView else {
                return
        }
        
        self.addSubview(containerView)
        containerView.addSubview(doneButton)
        containerView.addSubview(closeButton)
        containerView.addSubview(titleLabel)
        containerView.addSubview(tableView)
        
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.containerView?.center = CGPoint(x: self.center.x,
            y: self.center.y + self.frame.size.height)
        
        //titles
        containerView.addConstraint(NSLayoutConstraint(item: titleLabel,
            attribute: .top, relatedBy: .equal, toItem: containerView,
            attribute: .top, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: titleLabel,
           attribute: .leading, relatedBy: .equal, toItem: containerView,
           attribute: .leading, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: titleLabel,
           attribute: .trailing, relatedBy: .equal, toItem: containerView,
           attribute: .trailing, multiplier: 1.0, constant: 0))
        titleLabel.addConstraint(NSLayoutConstraint(item: titleLabel,
            attribute: .height, relatedBy: .equal, toItem: nil,
            attribute: .height, multiplier: 1.0, constant: 50))
        
        //buttons
        containerView.addConstraint(NSLayoutConstraint(item: containerView,
                                                       attribute: .leading, relatedBy: .equal, toItem: doneButton,
                                                       attribute: .leading, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: containerView,
                                                       attribute: .bottom, relatedBy: .equal, toItem: doneButton,
                                                       attribute: .bottom, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: doneButton,
                                                       attribute: .width, relatedBy: .equal, toItem: containerView,
                                                       attribute: .width, multiplier: 0.5, constant: 0))
        doneButton.addConstraint(NSLayoutConstraint(item: doneButton,
                                                    attribute: .height, relatedBy: .equal, toItem: nil,
                                                    attribute: .height, multiplier: 1.0, constant: 50))
        
        containerView.addConstraint(NSLayoutConstraint(item: containerView,
                                                       attribute: .trailing, relatedBy: .equal, toItem: closeButton,
                                                       attribute: .trailing, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: containerView,
                                                       attribute: .bottom, relatedBy: .equal, toItem: closeButton,
                                                       attribute: .bottom, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: closeButton,
                                                       attribute: .width, relatedBy: .equal, toItem: containerView,
                                                       attribute: .width, multiplier: 0.5, constant: 0))
        closeButton.addConstraint(NSLayoutConstraint(item: closeButton,
                                                     attribute: .height, relatedBy: .equal, toItem: nil,
                                                     attribute: .height, multiplier: 1.0, constant: 50))
        
        //tableView
        containerView.addConstraint(NSLayoutConstraint(item: containerView,
            attribute: .trailing, relatedBy: .equal, toItem: tableView,
            attribute: .trailing, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: containerView,
            attribute: .leading, relatedBy: .equal, toItem: tableView,
            attribute: .leading, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: titleLabel,
            attribute: .bottom, relatedBy: .equal, toItem: tableView,
            attribute: .top, multiplier: 1.0, constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: closeButton,
            attribute: .top, relatedBy: .equal, toItem: tableView,
            attribute: .bottom, multiplier: 1.0, constant: 0))
    }

    fileprivate func updateUI() {
        let grayColor = UIColor(red: 198/255,
            green: 198/255, blue: 198/255, alpha: 1)
        self.containerView?.backgroundColor = UIColor.white
        self.containerView?.layer.borderColor = grayColor.cgColor
        //self.containerView?.layer.borderWidth = 0.5
       // self.containerView?.layer.cornerRadius = 15.0
        self.containerView?.layer.borderWidth = 0.0
        self.containerView?.layer.cornerRadius = 2.0
        self.containerView?.clipsToBounds = true
        self.titleLabel?.text = title
        self.titleLabel?.backgroundColor = UIColor(red:1.00, green:0.76, blue:0.14, alpha:1.0)
        self.doneButton?.setTitle(doneText, for: .normal)
        self.closeButton?.setTitle(closeText, for: .normal)
        
        self.doneButton?.titleLabel?.textAlignment = .center
        self.closeButton?.titleLabel?.textAlignment = .center
        self.titleLabel?.textAlignment = .center
        
        self.textColor = UIColor.white
        self.closeButtonColor = grayColor
        self.closeButton?.setTitleColor(.black, for: .normal)
        self.mainColor = UIColor(red:1.00, green:0.76, blue:0.14, alpha:1.0)
        self.okButtonColor =  UIColor(red:0.24, green:0.59, blue:0.09, alpha:1.0)
        self.titleFont = UIFont(name: "Helvetica-Bold", size: 15.0)
        self.buttonFont = UIFont(name: "Helvetica", size: 15.0)
        self.tableView?.separatorInset = UIEdgeInsets(
            top: 0, left: 0, bottom: 0, right: 0)
        self.tableView?.rowHeight = 50
        self.tableView?.separatorStyle = .none
    }
    
    open func show() {
        guard let appDelegate = UIApplication.shared.delegate else {
            assertionFailure()
            return
        }
        guard let window = appDelegate.window else {
            assertionFailure()
            return
        }
        
        window?.addSubview(self)
        window?.bringSubview(toFront: self)
        window?.endEditing(true)
        UIView.animate(withDuration: 0.3, delay: 0.0,
            usingSpringWithDamping: 0.7, initialSpringVelocity: 3.0,
            options: .allowAnimatedContent, animations: {
            self.containerView?.center = self.center
        }) { (isFinished) in
            self.layoutIfNeeded()
        }
    }
    
    @objc private func done() {
        var indexes: [Int] = []
        for i in 0..<self.values.count {
            if self.values[i].isChecked {
                indexes.append(i)
            }
        }
        self.completion?(indexes)
        self.close()
    }
    
    @objc private func close() {
        UIView.animate(withDuration: 0.7, delay: 0.0,
            usingSpringWithDamping: 1, initialSpringVelocity: 1.0,
            options: .allowAnimatedContent, animations: {
            self.containerView?.center = CGPoint(x: self.center.x,
            y: self.center.y + self.frame.size.height)
        }) { (isFinished) in
            self.removeFromSuperview()
        }
    }
    
    //MARK: UITableViewDataSource methods
    
    public func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return self.values.count
    }
    
    public func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:
            self.tableViewCellIdentifier,
            for: indexPath) as? TCPickerTableViewCell else {
            assertionFailure("cell doesn't init")
            return UITableViewCell()
        }
        let value = self.values[indexPath.row]
        cell.viewModel = TCPickerTableViewCell.ViewModel(
            title: value.title,
            isChecked: value.isChecked
        )
        return cell
    }
    
    //MARK: UITableViewDelegate methods
    
    public func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        var values = self.values
        switch self.selection {
            case .none: return
            case .single:
                for i in 0..<values.count {
                    values[i].isChecked = false
                }
                values[indexPath.row].isChecked = true
            case .multiply:
                values[indexPath.row].isChecked = !values[indexPath.row].isChecked
        }
        self.values = values
        self.delegate?.pickerView(self, didSelectRowAtIndex: indexPath.row)
    }
}

