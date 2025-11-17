//
//  ViewController.swift
//  FirstKeyboardProject
//
//  Created by 위대연 on 2020/05/23.
//  Copyright © 2020 위대연. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var testTF: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.borderStyle = .roundedRect
        textField.placeholder = "테스트용 텍스트필드"
        return textField
    }()
    
    var testTF2: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.borderStyle = .roundedRect
        textField.placeholder = "테스트용 텍스트필드"
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(testTF)
        view.addSubview(testTF2)
        
        testTF.translatesAutoresizingMaskIntoConstraints = false
        testTF2.translatesAutoresizingMaskIntoConstraints = false
        
        let layoutGuide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            testTF.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor),
            testTF.heightAnchor.constraint(equalToConstant: 60),
            testTF.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 36),
            testTF.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -36),
            
            testTF2.topAnchor.constraint(equalTo: testTF.bottomAnchor, constant: 8),
            testTF2.heightAnchor.constraint(equalToConstant: 60),
            testTF2.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 36),
            testTF2.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -36)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         testTF.becomeFirstResponder() 
    }
}

