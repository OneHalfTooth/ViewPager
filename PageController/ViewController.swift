//
//  ViewController.swift
//  PageController
//
//  Created by 马扬 on 2018/10/11.
//  Copyright © 2018 mayang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {



    var pageControl : MMPageControlView?
    var cs : [UIViewController]?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = [.left,.right]
        self.initData()
        self.createView()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(5)) {
            self.pageControl?.scrollToItem(index: 4);
        }
    }

    /** 创建viiew */
    fileprivate func createView(){

        self.pageControl = MMPageControlView.init(frame: .zero, style: .noscroll)
        self.pageControl?.translatesAutoresizingMaskIntoConstraints = false
        self.pageControl?.defaultIndex = 1
        self.view.addSubview(self.pageControl!)
        self.pageControl?.delegate = self

        let top = NSLayoutConstraint.init(item: self.pageControl!, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint.init(item: self.pageControl!, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint.init(item: self.pageControl!, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint.init(item: self.pageControl!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        self.view.addConstraints([top,left,right,bottom])
    }


    /** 初始化数据 */
    fileprivate func initData(){
        var cs = [UIViewController]()

        for i in 0 ..< 6 {
            let v = SecondViewController()
            self.addChild(v)
            v.title = "\(i)"
            v.view.backgroundColor = UIColor.init(red: CGFloat(Int.random(in: 0 ..< 255)) / 255.0, green: CGFloat(Int.random(in: 0 ..< 255)) / 255.0, blue: CGFloat(Int.random(in: 0 ..< 255)) / 255.0, alpha: 1)
            cs.append(v)
        }
        self.cs = cs
    }

}


extension ViewController: MMPageControlViewDelegate{

    func numberForPageControlView() -> Int {
        return 6
    }

    func titleForTitleViewIndex(index: Int) -> String {
        return ["收银","发钱","赚钱","花钱","洒银","不要钱"][index]
    }
    func titleSelectColor() -> UIColor {
        return UIColor.blue
    }
    func titleNormalColor() -> UIColor {
        return UIColor.init(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1)
    }
    func titleLineNormalColor() -> UIColor {
        return  UIColor.init(red: 221.0 / 255.0, green: 221.0 / 255.0, blue: 221.0 / 255.0, alpha: 1)
    }

    func viewForCollectionViewIndex(index: Int) -> UIView {

        return self.cs![index].view
    }

}
