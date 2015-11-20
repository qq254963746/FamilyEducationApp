//
//  ViewController.swift
//  家教
//
//  Created by goofygao on 15/10/19.
//  Copyright © 2015年 goofyy. All rights reserved.
//

import UIKit
import Alamofire


class ViewController: UIViewController,HttpProtocol{
    
    @IBOutlet weak var searchStudent: UIButton!
    @IBOutlet weak var searchTeacher: UIButton!
    @IBOutlet weak var addButton: UIButton!
    var studentStatus:NSMutableArray?
    let requestHttp = HttpRequest()
    
    let reuseIdentifier = "ContentCell"
    //cell行高缓存
    var cellHeightCache = NSCache()
    var dataCount = 5
    var transformValuesDictionary:NSMutableDictionary = NSMutableDictionary()
    //展示家教信息的TableView
    @IBOutlet weak var tableViewFraulein: UITableView!
    @IBOutlet var barButton: UIButton!
    let defaultValue = NSUserDefaults.standardUserDefaults()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
       self.initView()
        requestHttp.delegate = self
        requestHttp.loadNewData(0)
        requestHttp.loadNewData(1)
        requestHttp.loadNewData(2)
        requestHttp.loadNewData(3)
        self.tableViewFraulein.reloadData()
        
}

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Your Menu View Controller vew must know the following data for the proper animatio
        let destinationVC = segue.destinationViewController as? GuillotineMenuViewController
        destinationVC?.hostNavigationBarHeight = self.navigationController!.navigationBar.frame.size.height
        destinationVC?.hostTitleText = self.navigationItem.title
        destinationVC?.view.backgroundColor = self.navigationController!.navigationBar.barTintColor
        destinationVC?.setMenuButtonWithImage(barButton.imageView!.image!)
        
    }
    
    
    //MARK: - 初始化视图控制器
    
    func initView() {
        //navigation设置
        let navBar = self.navigationController?.navigationBar
        navBar?.barTintColor = UIColor(red: 65.0 / 255.0, green: 62.0 / 255.0, blue: 79.0 / 255.0, alpha: 1)
        navBar?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        //tableview 注册添加代理
        tableViewFraulein.delegate = self
        tableViewFraulein.dataSource = self
        let nib = UINib(nibName: "CustomFrauleinViewCell", bundle: nil)
        self.tableViewFraulein.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
        //  self.tableViewFraulein.sp=
        self.tableViewFraulein.backgroundColor = UIColor(red: 65.0 / 255.0, green: 62.0 / 255.0, blue: 79.0 / 255.0, alpha: 1)
        //tableView设置刷新
        //进入之后自动刷新
      // MJRefreshHeader
        let header = MJRefreshGifHeader(refreshingTarget: self, refreshingAction: "headerRefreshGetNewInfo")
        var refreshImage = [UIImage]()
        for var i = 1; i <= 60; i++ {
            let string = NSString(format: "dropdown_anim__000%zd.png", i) as String
           
            refreshImage.append(UIImage(named: string)!)
        }
        header.setImages(refreshImage, forState: MJRefreshStateIdle)
        header.setImages(refreshImage, forState: MJRefreshStatePulling)
        header.setTitle("松开刷新", forState: MJRefreshStatePulling)
        header.setTitle("正在努力加载...", forState: MJRefreshStateRefreshing)
        header.stateLabel?.textColor = UIColor(white: 1, alpha: 0.9)
        header.lastUpdatedTimeLabel?.textColor = UIColor(white: 1, alpha: 0.9)
        
        self.tableViewFraulein.header = header
         self.tableViewFraulein.header.beginRefreshing()
        self.initTabBar()
    }
    
    //初始化底部tabBar
    func initTabBar() {
        let tabBarView = UIView(frame: CGRectMake(0, DeviceData.height - 49, DeviceData.width, 49))
        tabBarView.backgroundColor = UIColor.redColor()
        self.view.addSubview(tabBarView)
        
        searchTeacher.setImage(UIImage(named: "16.png"), forState: UIControlState.Normal)
        searchTeacher.titleLabel?.textAlignment = NSTextAlignment.Center
        searchTeacher.setTitle("找老师", forState: UIControlState.Normal)
        searchTeacher.imageEdgeInsets = UIEdgeInsetsMake(10,40, 20,40)
        searchTeacher.titleLabel?.font = UIFont.systemFontOfSize(10)
        
        
        searchTeacher.titleLabel?.tintColor = UIColor.cyanColor()
        searchTeacher.titleEdgeInsets = UIEdgeInsetsMake(30, -50, 0, 10)
        searchTeacher.addTarget(self, action: "searchTeachAction", forControlEvents: UIControlEvents.TouchDown)
        
        searchStudent.setImage(UIImage(named: "18.png"), forState: UIControlState.Normal)
        searchStudent.titleLabel?.textAlignment = NSTextAlignment.Center
        searchStudent.setTitle("找学生", forState: UIControlState.Normal)
        searchStudent.imageEdgeInsets = UIEdgeInsetsMake(10,45, 20,45)
        searchStudent.titleLabel?.font = UIFont.systemFontOfSize(10)
        
        
        searchStudent.titleLabel?.tintColor = UIColor.cyanColor()
        searchStudent.titleEdgeInsets = UIEdgeInsetsMake(30, -20, 0, 10)
        searchStudent.addTarget(self, action: "searchStudentAction", forControlEvents: UIControlEvents.TouchDown)

    }
   
    

    func headerRefreshGetNewInfo() {
//        self.tableViewFraulein.header.endRefreshing()
        requestHttp.loadNewData(2)
//        self.tableViewFraulein.reloadData()
    }
    //MARK: - 用来加载找教师数据 - tabbar
    func searchTeachAction() {
        
        self.tableViewFraulein.header.beginRefreshing()
    }
    //MARK: - 用来加载找学生数据 - tabbar
    func searchStudentAction() {

        self.dataCount += 5
        self.tableViewFraulein.header.beginRefreshing()
        self.tableViewFraulein.reloadData()
    }

}
//MARK: - tableview添加代理方法

extension ViewController: UITableViewDelegate,UITableViewDataSource {
    
     func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
      func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if self.studentStatus?.count == nil {
            return 1
        }
        return (self.studentStatus?.count)!
    }
    
      func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CustomFrauleinViewCell
      
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true
       
        cell.StudentFrauleinTittle.text = self.studentStatus?[indexPath.row].stu_name
        cell.FrauleinPlace.text = self.studentStatus?[indexPath.row].stu_addr
         cell.FrauleinDetailContent.text = self.studentStatus?[indexPath.row].stu_intro!
        if let _ = self.studentStatus?[indexPath.row].stu_star {
             cell.FrauleinLevel.getLevelStar(Int((self.studentStatus?[indexPath.row].stu_star)!))
        } else {
            cell.FrauleinLevel.getLevelStar(Int(arc4random_uniform(6)))
        }
//        cell.FrauleinLevel.getLevelStar(Int((self.studentStatus?[indexPath.row].stu_star)!))
        
        //把行高放进缓存
        cellHeightCache.setObject(cell.heightForCell("\(self.studentStatus?[indexPath.row].stu_intro)") + 2, forKey: indexPath.row)
        
        return cell
            
        
    }
    
    
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
       
        let storyBoadrd = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let familyStoryBoard:FamilyInfoViewController = storyBoadrd.instantiateViewControllerWithIdentifier("familyInfo") as! FamilyInfoViewController
        self.navigationController?.pushViewController(familyStoryBoard, animated: true)
//        let archivedObject = NSKeyedArchiver.archivedDataWithRootObject([Student]())
//        let defaults = NSUserDefaults.standardUserDefaults()
        
        defaultValue.setObject("\(self.studentStatus![indexPath.row].stu_id)", forKey: "stu_id")
        defaultValue.setObject(self.studentStatus![indexPath.row].username, forKey: "username")
        defaultValue.setObject(self.studentStatus![indexPath.row].stu_name, forKey: "stu_name")
        defaultValue.setObject(self.studentStatus![indexPath.row].stu_sign, forKey: "stu_sign")
        defaultValue.setObject("\(self.studentStatus![indexPath.row].stu_sex)", forKey: "stu_sex")
        defaultValue.setObject("\(self.studentStatus![indexPath.row].stu_age)", forKey: "stu_age")
        defaultValue.setObject(self.studentStatus![indexPath.row].stu_num, forKey: "stu_num")
        defaultValue.setObject(self.studentStatus![indexPath.row].stu_addr, forKey: "stu_addr")
//        defaultValue.setObject(self.studentStatus![indexPath.row].stu_edu, forKey: "stu_edu")
//        defaultValue.setObject(self.studentStatus![indexPath.row].stu_major, forKey: "stu_major")
        defaultValue.setObject(self.studentStatus![indexPath.row].stu_course, forKey: "stu_course")
        defaultValue.setObject(self.studentStatus![indexPath.row].stu_intro, forKey: "stu_intro")
        defaultValue.setObject(self.studentStatus![indexPath.row].stu_pic, forKey: "stu_pic")
        defaultValue.setObject("\(self.studentStatus![indexPath.row].stu_collect)", forKey: "stu_collect")
        defaultValue.setObject("\(self.studentStatus![indexPath.row].stu_bcost)", forKey: "stu_bcost")
        defaultValue.setObject("\(self.studentStatus![indexPath.row].stu_lcost)", forKey: "stu_lcost")
        defaultValue.setObject(self.studentStatus![indexPath.row].volTime, forKey: "volTime")
        defaultValue.setObject(self.studentStatus![indexPath.row].free_time, forKey: "free_time")
////        defaultValue.setObject(self.studentStatus![indexPath.row].lfree_time, forKey: "lfree_time")
        defaultValue.setObject("\(self.studentStatus![indexPath.row].stu_collect)", forKey: "stu_collect")
        defaultValue.setObject("\(self.studentStatus![indexPath.row].stu_star)", forKey: "stu_star")
        defaultValue.setObject("\(self.studentStatus![indexPath.row].real_sign)", forKey: "real_sign")
//        defaultValue.setObject(self.studentStatus![indexPath.row].volTime, forKey: "volTime")
        defaultValue.synchronize()
    }
    
//    kind
    
        func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let rowHeight = cellHeightCache.objectForKey(indexPath.row) as? CGFloat {
            
            return rowHeight
        }
        
        let rowHeight = cellHeightCache.objectForKey(indexPath.row) as? CGFloat
        
        return 100
    }
    
    //MARK: -button action
    
    @IBAction func rightNavigationItemAction(sender: UIButton) {
        self.presentViewController(ChatListViewController(), animated: true, completion: nil)
        
    }
 
    
    func didReceiveResults(result: NSMutableArray) {
        if studentStatus?.count == nil {
            var array = [Student]()
            self.studentStatus = NSMutableArray(array: array)
        }
      
        for i in 0...result.count - 1{
            self.studentStatus?.addObject(result[i])
        }
        let cell = tableViewFraulein.dequeueReusableCellWithIdentifier(reuseIdentifier) as! CustomFrauleinViewCell
        cellHeightCache.setObject(cell.heightForCell("\(self.studentStatus?[((self.studentStatus?.count)! - 1)].stu_intro)"), forKey: (self.studentStatus?.count)! - 1)
        if self.studentStatus?.count > 3 {
            print("++++++++++++++++++++")
            self.tableViewFraulein.header.endRefreshing()
            self.tableViewFraulein.reloadData()
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1)
        UIView.animateWithDuration(0.7) { () -> Void in
            cell.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
    }
    
    
}








