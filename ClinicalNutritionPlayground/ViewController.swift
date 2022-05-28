//
//  ViewController.swift
//  ClinicalNutritionPlayground
//
//  Created by 山田　天星 on 2022/05/07.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let color3 = UIColor(named: "Color")?.cgColor
        let color2 = UIColor(named: "Color-1")?.cgColor
        let color1 = UIColor(named: "Color-2")?.cgColor
        
        navigationController?
            .navigationBar
            .backItem?
            .backBarButtonItem?
            .tintColor
        = .white
        
        navigationController?
            .navigationBar
            .tintColor
        = .white

        let gradLayer = CAGradientLayer()
        gradLayer.frame = view.frame
        gradLayer.colors = [color3, color2, color1]
        gradLayer.startPoint = .init(x: 0, y: 00)
        gradLayer.endPoint = .init(x: 0, y: 1.0)
        view.layer.insertSublayer(gradLayer, at: 0)
        
    }

    @IBAction func showButton(_ sender: Any) {
        show()
    }
 
    func show() {
        // ここでPresenterとViewControllerを繋げている
        let view = storyboard?.instantiateViewController(withIdentifier: "RatioConverterViewController")  as! RatioConverterViewController
        let model = RatioConverterUseCase()
        let presenter = RatioConverterPresenter(view: view,
                                                model: model)
        view.inject(presenter: presenter)
        navigationController?.pushViewController(view, animated: true)
    }
}
