//
//  MMPageControlView.swift
//  UU898
//
//  Created by 马扬 on 2018/9/21.
//  Copyright © 2018年 Mayang. All rights reserved.
//

import UIKit


/// page control 的标题视图会不会滚动
///
/// - scroll: 会滚动
/// - noscroll: 不会滚动
enum MMPageControlViewTitleStyle {
    case scroll
    case noscroll
}

/// pageview 协议
@objc protocol MMPageControlViewDelegate : NSObjectProtocol {


    /// 必须实现协议 标题的个数
    ///
    /// - Returns: 数量
    func numberForPageControlView() -> Int


    /// 必须实现协议 标题的文本返回
    ///
    /// - Parameter index: 标题的索引
    /// - Returns: 返回标题的文本
    func titleForTitleViewIndex(index:Int) -> String


    /// 必须实现
    ///
    /// - Parameter index: 索引
    /// - Returns: 返回view 展示在列表
    func viewForCollectionViewIndex(index:Int) -> UIView



    /// 标题的按钮被选中
    ///
    /// - Parameters:
    ///   - selected: 被选中的按钮
    ///   - last: 上次被选中的按钮
    ///   - index: 被选中的索引
    /// - Returns:
    @objc optional func titleSelected(at selected:MMPageControlStackTitleButton,last:MMPageControlStackTitleButton,index:Int) -> Void


    /// 按钮被选中的颜色
    ///
    /// - Returns: 颜色
    @objc optional func titleSelectColor() -> UIColor

    /// 按钮未被选中的颜色
    ///
    /// - Returns: 颜色
    @objc optional func titleNormalColor() -> UIColor

    /// 标题和内容f分割线的颜色
    ///
    /// - Returns: color
    @objc optional func titleLineNormalColor() -> UIColor


    /// 是否允许标题按钮被点击
    /// *只有点击按钮才会被执行*
    /// - Parameters:
    ///   - selected: 被选中的按钮
    ///   - last: 上次被选中的按钮
    ///   - index: 被选中的索引
    /// - Returns: 是否允许被选中
    @objc optional func titleShouldWillSelected(at selected:MMPageControlStackTitleButton,last:MMPageControlStackTitleButton,index:Int) -> Bool;


}

class MMPageControlView: UIView {


    open weak var delegate : MMPageControlViewDelegate?{
        didSet{
            self.titleView?.delegate = self.delegate
            self.contentView?.cdelegate = self.delegate
        }
    }
    open var defaultIndex = 0
    open var isScrollEnabled : Bool = true{
        didSet{
            self.contentView?.isScrollEnabled = self.isScrollEnabled
        }
    }
    /// 标题view 布局回调
    open var titleViewLayoutCallBack : ((MMPageControlStackTitleView) -> Void)?

    /// 标题button 布局回调
    ///
    /// - Parameter
    ///        -index: 标题的索引
    ///        -button: 标题的索引
    open var titleButtonLayoutCallBack : ((_ button : MMPageControlStackTitleButton,_ index : Int) -> Void)?




    /// 不可滚动标题视图
    fileprivate var titleView : MMPageControlStackTitleView?
    /// 内容视图
    fileprivate var contentView : MMPageControlContentView?
    fileprivate var style : MMPageControlViewTitleStyle?



    convenience init(frame: CGRect,style:MMPageControlViewTitleStyle) {
        self.init(frame: frame)
        self.style = style
        if style == .noscroll{
            self.createStackTitleView()
        }
        self.createContentView()
        self.createAction()
    }


    /// 更新数据
    open func reloadData() -> Void{
        if self.delegate == nil{
            return;
        }
        self.titleView?.reloadData()
        self.titleView?.buttonStatus(index: self.titleView?.lastIndex ?? 0)
        self.contentView?.reloadData()
    }


    /// 滚到到item
    ///
    /// - Parameter index: 位置
    open func scrollToItem(index:Int) -> Void{
        if self.titleView?.buttons.count ?? Int.max > index{
            self.defaultUpdate(index: index)
        }
    }


    /// 获取选中位置的button
    ///
    /// - Parameter index: 位置
    open func getTitleButtonByIndex(index:Int) -> MMPageControlStackTitleButton?{
        #if DEBUG
        assert(index < self.titleView!.buttons.count, "位置参数必须小于标题数量")
        #endif
        return self.titleView?.buttons[index]
    }

    /// 默认展示的索引发生变化
    fileprivate func defaultUpdate(index:Int) -> Void{
        if self.delegate != nil{
            if self.titleView?.buttons.count == 0{
                self.defaultIndex = index
                return
            }
            self.titleView?.buttonStatus(index: index)
            self.contentView?.scrollToItem(index: index)
        }
    }

    fileprivate override init(frame: CGRect) {
        super.init(frame: frame)
    }

    fileprivate func createAction() -> Void{
        /** collectionView 滚动的回调 */
        self.contentView?.scrollEndCallBack = {[weak self] (index) in
            self?.titleView?.reloadSelected(selectedIndex: index)
        }
        self.titleView?.clickCallBack = {[weak self] (index) in
            self?.contentView?.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .centeredHorizontally, animated: true)
        }
    }

    fileprivate var isLayout = false
    override func layoutSubviews() {
        super.layoutSubviews()
        guard self.isLayout == false else {
            return
        }
        self.isLayout = true
        let layout = self.contentView?.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.itemSize = self.contentView?.bounds.size ?? CGSize.zero
        self.reloadData()
        self.defaultUpdate(index: self.defaultIndex)
    }
    fileprivate func createContentView() -> Void{
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize.init(width: 1, height: 1)

        self.contentView = MMPageControlContentView.init(frame: .zero, collectionViewLayout: layout)
        self.addSubview(self.contentView!)
        self.contentView?.translatesAutoresizingMaskIntoConstraints = false
        let left = NSLayoutConstraint.init(item: self.contentView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0);
        let bottom = NSLayoutConstraint.init(item: self.contentView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0);
        let right = NSLayoutConstraint.init(item: self.contentView!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0);
        self.addConstraints([left,right,bottom])
        var top : NSLayoutConstraint?
        if self.titleView == nil{
            top = NSLayoutConstraint.init(item: self.contentView!, attribute: .top, relatedBy: .equal, toItem: self.titleView, attribute: .bottom, multiplier: 1, constant: 0)
        }
        top = NSLayoutConstraint.init(item: self.contentView!, attribute: .top, relatedBy: .equal, toItem: self.titleView, attribute: .bottom, multiplier: 1, constant: 0)
        self.addConstraint(top!)
    }

    /// 创建不带滚动的标题视图
    fileprivate func createStackTitleView() -> Void{
        self.titleView = MMPageControlStackTitleView.init(frame: .zero)
        self.addSubview(self.titleView!)
        self.titleView?.translatesAutoresizingMaskIntoConstraints = false
        let left = NSLayoutConstraint.init(item: self.titleView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0);
        let top = NSLayoutConstraint.init(item: self.titleView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0);
        let right = NSLayoutConstraint.init(item: self.titleView!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0);
        let height = NSLayoutConstraint.init(item: self.titleView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 44.0)
        self.titleView?.addConstraint(height)
        self.addConstraints([left,right,top])
        self.titleViewLayoutCallBack?(self.titleView!)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//MARK:内容视图
/// 内容视图
final class MMPageControlContentView : UICollectionView,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{

    weak var cdelegate : MMPageControlViewDelegate?
    /** 滚动回调 */
    var scrollEndCallBack : ((Int) -> Void)?

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.dataSource = self
        self.delegate = self
        self.isPagingEnabled = true
        self.bounces = false
        self.backgroundColor = UIColor.white

        self.register(MMPageControlContentViewCell.classForCoder(), forCellWithReuseIdentifier: "MMPageControlContentViewCell")
    }
    fileprivate func scrollToItem(index:Int)  -> Void{
        self.performBatchUpdates(nil) { (stop) in
            self.scrollToItem(at: IndexPath.init(row: index, section: 0), at: .centeredHorizontally, animated: true)
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.cdelegate?.numberForPageControlView() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MMPageControlContentViewCell", for: indexPath) as! MMPageControlContentViewCell
        cell.view = self.cdelegate?.viewForCollectionViewIndex(index: indexPath.row)
        return cell
    }


    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index : NSInteger = (NSInteger)(scrollView.contentOffset.x / self.bounds.size.width)
        self.scrollEndCallBack?(index)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class MMPageControlContentViewCell: UICollectionViewCell {
    weak var controller : UIViewController?{
        didSet{
            if self.controller?.view != nil {
                self.contentView.addSubview(self.controller!.view)
                self.updateConstraints(v: self.controller!.view)
            }
        }
    }

    weak var view : UIView?{
        didSet{
            if self.view != nil {
                self.contentView.addSubview(self.view!)
                self.updateConstraints(v: self.view!)
            }
        }
    }

    fileprivate func updateConstraints(v : UIView){
        v.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint.init(item: v, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint.init(item: v, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint.init(item: v, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint.init(item: v, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        self.addConstraints([left,top,right,bottom])
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.controller?.view.removeFromSuperview()
        self.view?.removeFromSuperview()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK:不带滚动的标题视图
/// 不带滚动的标题视图
final class MMPageControlStackTitleView: UIView {

    fileprivate var contentView : UIStackView?
    public weak var delegate : MMPageControlViewDelegate?
    fileprivate var clickCallBack : ((Int) -> Void)?
    fileprivate var titleButtonLayoutCallBack : ((_ button : MMPageControlStackTitleButton,_ index : Int) -> Void)?

    fileprivate var buttons = [MMPageControlStackTitleButton]()
    fileprivate var lastIndex = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.createView()
    }

    fileprivate func reloadSelected(selectedIndex:Int) -> Void{
        if self.lastIndex == selectedIndex{
            return
        }
        self.buttonStatus(index: selectedIndex)
    }

    fileprivate func reloadData() -> Void{
        self.buttons.removeAll()
        for x in self.contentView?.arrangedSubviews ?? [] {
            self.contentView?.removeArrangedSubview(x)
            x.removeFromSuperview()
        }
        self.createTitles()
    }

    fileprivate func createView() -> Void{
        self.createContentView()
    }

    @objc func buttonClick(button : MMPageControlStackTitleButton) -> Void{
        guard let index = self.buttons.index(of: button) else{
            return
        }
        if (self.delegate?.titleShouldWillSelected?(at: button, last: self.buttons[index], index: index) ?? true) == false {
            return
        }

        self.clickCallBack?(index)
        self.buttonStatus(index: index)
        self.delegate?.titleSelected?(at: button, last: self.buttons[index], index: index)
    }

    /** button 状态变化 */
    fileprivate func buttonStatus(index:Int) -> Void{
        #if DEBUG
        assert(index < self.buttons.count, "默认位置不能大于总个数")
        #else
        if index >= self.buttons.count {
            return
        }
        #endif

        self.buttons[self.lastIndex].isEnabled = true
        self.buttons[self.lastIndex].line.backgroundColor = self.delegate?.titleLineNormalColor?() ?? UIColor.init(red: 221 / 255.0, green: 221 / 255.0, blue: 221 / 255.0, alpha: 1)
        self.lastIndex = index
        self.buttons[self.lastIndex].isEnabled = false
        self.buttons[self.lastIndex].line.backgroundColor = self.delegate?.titleSelectColor?() ?? UIColor.init(red: 0.25, green: 0.25, blue: 0.25, alpha: 1)
    }

    /// 创建按钮
    fileprivate func createTitles() -> Void{

        for i in 0 ..< (self.delegate?.numberForPageControlView() ?? 0) {
            let title = self.delegate?.titleForTitleViewIndex(index: i)
            assert(title != nil, "标题不能为空")
            let button = self.createButton(title: title!)
            button.tag = 1219 + i
            self.titleButtonLayoutCallBack?(button,i)
            self.contentView?.addArrangedSubview(button)
            self.buttons.append(button)
        }
    }

    fileprivate func createContentView() -> Void{
        self.contentView = UIStackView.init(frame: .zero)
        self.contentView?.alignment = .fill
        self.contentView?.distribution = .fillEqually
        self.addSubview(self.contentView!)
        self.contentView?.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint.init(item: self.contentView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let left = NSLayoutConstraint.init(item: self.contentView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint.init(item: self.contentView!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint.init(item: self.contentView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        self.addConstraints([left,top,right,bottom])
    }

    fileprivate func createButton(title:String) -> MMPageControlStackTitleButton{
        let button = MMPageControlStackTitleButton.init(type: UIButton.ButtonType.custom)
        button.setTitle(title, for: .normal)
        button.setTitleColor(self.delegate?.titleNormalColor?() ?? UIColor.init(red: 51 / 255.0, green: 51 / 255.0, blue: 51 / 255.0, alpha: 51 / 255.0), for: .normal)
        button.setTitleColor(self.delegate?.titleSelectColor?() ?? UIColor.init(red: 0.25, green: 0.25, blue: 0.25, alpha: 1), for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.backgroundColor = UIColor.white
        button.line.backgroundColor = self.delegate?.titleLineNormalColor?() ?? UIColor.init(red: 221 / 255.0, green: 221 / 255.0, blue: 221 / 255.0, alpha: 1)
        button.addTarget(self, action: #selector(self.buttonClick(button:)), for: .touchUpInside)
        return button
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK:标题button
final class MMPageControlStackTitleButton: UIButton{

    var line = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.line)
        self.line.translatesAutoresizingMaskIntoConstraints = false

        let height = NSLayoutConstraint.init(item: self.line, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 1)
        let left = NSLayoutConstraint.init(item: self.line, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint.init(item: self.line, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint.init(item: self.line, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        self.addConstraints([left,right,bottom])
        self.line.addConstraint(height)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
