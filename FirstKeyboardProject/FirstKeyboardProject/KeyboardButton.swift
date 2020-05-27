//
//  KeyboardButton.swift
//  FirstKeyboardProject
//
//  Created by 위대연 on 2020/05/21.
//  Copyright © 2020 위대연. All rights reserved.
//

import UIKit
class DKey:UIButton {
    private var optionText:String = ""
    func setOptionText(_ text:String?) {
        self.optionText = text ?? ""
    }
    
    func getOptionText() -> String {
        return self.optionText
    }
}

class KeyboardButton: UIView {
    //var defaultBackgroundColor: UIColor = .white
    //var highlightBackgroundColor: UIColor = .lightGray
    
    var buttonTextColor = UIColor(named: "ButtonText")
    var buttonBackgroundColor = UIColor(named: "ButtonBackground")
    var buttonHighlightColor = UIColor(named: "ButtonHighlight")
    
    lazy var button: DKey = {
        let btn = DKey(type: .custom)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .clear
        return btn
    }()
    
    lazy var optionLabel: UILabel = {
        let optionLabel = UILabel()
        optionLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        optionLabel.text = ""
        optionLabel.textAlignment = .right
        optionLabel.translatesAutoresizingMaskIntoConstraints = false
        return optionLabel
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    //custom views should override this to return true if
    //they cannot layout correctly using autoresizing.
    //from apple docs https://developer.apple.com/documentation/uikit/uiview/1622549-requiresconstraintbasedlayout
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        buttonTextColor = UIColor(named: "ButtonText")
        buttonBackgroundColor = UIColor(named: "ButtonBackground")
        buttonHighlightColor = UIColor(named: "ButtonHighlight")
        //self.backgroundColor = self.button.isHighlighted ? highlightBackgroundColor : defaultBackgroundColor
        self.backgroundColor = buttonBackgroundColor
        self.button.setTitleColor(buttonTextColor, for: .normal)
        self.button.tintColor = buttonTextColor
    }
    
    private func setupView() {
        layer.cornerRadius = 5.0
        layer.masksToBounds = false
        layer.shadowOffset = CGSize(width: 0, height: 1.0)
        layer.shadowRadius = 0.0
        layer.shadowOpacity = 0.35

        addSubview(optionLabel)
        addSubview(button)
        button.setTitleColor(buttonTextColor, for: .normal)
        button.tintColor = buttonTextColor
        setupLayout()
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            optionLabel.topAnchor.constraint(equalTo: topAnchor),
            optionLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            optionLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            optionLabel.heightAnchor.constraint(equalToConstant: 20),
            
            button.topAnchor.constraint(equalTo: topAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setOptionTitle(_ text:String) {
        self.optionLabel.text = text
        self.button.setOptionText(text)
    }
    
    func setTitle(text:String?,option:String?, for state: UIControl.State) {
        DispatchQueue.main.async {
            self.button.setTitle(text, for: state)
            self.optionLabel.text = option
            self.button.setOptionText(option)
        }
    }
    
    func getTitle() -> String {
        return self.button.titleLabel?.text ?? ""
    }
    
    func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        self.button.setTitleColor(color, for: .normal)
    }
}
extension UIInputView: UIInputViewAudioFeedback {
    public var enableInputClicksWhenVisible: Bool {
        return true
    }
}
