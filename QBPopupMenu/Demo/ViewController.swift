//
//  ViewController.swift
//  QBPopupMenu
//
//  Created by Dusan Saiko on 24/09/2017.
//  Copyright © 2017 Dusan Saiko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var menuItems: [QBPopupMenu.Item] {
        return [
            QBPopupMenu.Item(title: "Hello",                                    action: { self.action() }),
            QBPopupMenu.Item(title: "Cut",                                      action: { self.action() }),
            QBPopupMenu.Item(title: "Copy",                                     action: { self.action() }),
            QBPopupMenu.Item(title: "Delete",                                   action: { self.action() }),
            QBPopupMenu.Item(title: "Share",                                    action: { self.action() }),
            QBPopupMenu.Item(image: UIImage(named: "clip"),                     action: { self.action() }),
            QBPopupMenu.Item(title: "Delete", image: UIImage(named: "trash"),   action: { self.action() }),
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func displayMenu(_ sender: Any) {
        let popupMenu = QBPopupMenu(items: menuItems)
        let button = sender as! UIButton
        popupMenu.showIn(parentView: view, targetRect: button.frame, animated: true)
    }
    
    @IBAction func displayPlasticMenu(_ sender: Any) {
        let popupMenu = QBPlasticPopupMenu(config: QBPopupMenu.Config(height: 40), items: menuItems)
        let button = sender as! UIButton
        popupMenu.showIn(parentView: view, targetRect: button.frame, animated: true)
    }
    
    func action() {
        print("QBPopupMenuAction!")
    }
}

