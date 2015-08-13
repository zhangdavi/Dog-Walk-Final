//
//  ViewController.swift
//  Dog Walk
//
//  Created by Pietro Rea on 7/10/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource {
  
  @IBOutlet var tableView: UITableView!
  
    // 定义一个属性to hold 即将要操控的数据或记录
    var managedContext: NSManagedObjectContext!
  
    //定义一个dog 对象
    var currentDog: Dog!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    //Insert Dog entity
    //定义dog 数据，在数据库中查询，如果查询不到，则吧这个数据插入数据库，如果查询到，则继续
    let dogEntity = NSEntityDescription.entityForName("Dog",
      inManagedObjectContext: managedContext)
    
    let dogName = "Fido"
//    配置查询条件
    let dogFetch = NSFetchRequest(entityName: "Dog")
    
    dogFetch.predicate = NSPredicate(format: "name == %@", dogName)
    
    var error: NSError?
//   执行查询返回结果，返回一个Dog数组，对当前这个程序而言，只有一只狗，以后可以升级到多只狗
    let result =
    managedContext.executeFetchRequest(dogFetch,
      error: &error) as! [Dog]?
    
    if let dogs = result {
      
      if dogs.count == 0 {
//        当查询结果为0，说明没有狗，这是在数据库中插入一条狗并保存，狗的名字叫“Fido”，并把这只狗给当前狗
//        初始化一条狗纪录，把这条记录给当前狗，当前狗名字赋值，然后保存到数据库，这种用法真是很奇怪，先记住再说
        currentDog = Dog(entity: dogEntity!,
          insertIntoManagedObjectContext: managedContext)
        
        currentDog.name = dogName
        
//        保存插入的狗
        if !managedContext.save(&error) {
          println("Could not save: \(error)")
        }
      } else {
//        如果数据库中已经有狗，把第一只狗赋给当前的狗
        currentDog = dogs[0]
      }
      
    } else {
      println("Could not fetch: \(error)")
    }
//    这是什么鬼？comments后程序不能正常运行，而且这还在viewDidLoad中，是自动产生的code 吗？
//    这是用 code进行UI的增加，这里在tableview 中增加cell
    tableView.registerClass(UITableViewCell.self,
      forCellReuseIdentifier: "Cell")
  }
//把walk放在cell里，返回cell数量
  func tableView(tableView: UITableView,
    numberOfRowsInSection section: Int) -> Int {
      return currentDog.walks.count;
  }
//  设置section title，这里只有一个section，如何增加一个新的section？
  func tableView(tableView: UITableView,
    titleForHeaderInSection section: Int) -> String? {
      return "List of Walks";
  }

  func tableView(tableView: UITableView,
    cellForRowAtIndexPath
    indexPath: NSIndexPath) -> UITableViewCell {
//      这里的“Cell”就是tableview中注册的cell
      let cell =
      tableView.dequeueReusableCellWithIdentifier("Cell",
        forIndexPath: indexPath) as! UITableViewCell
//      定义日期时间格式
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateStyle = .ShortStyle
      dateFormatter.timeStyle = .MediumStyle
      
      //the next two statements have changed
//        一对多之间的引用关系，currentDog.walks[]数组对用Walk表中的纪录
      let walk = currentDog.walks[indexPath.row] as! Walk

        //      把日期转换格式后显示在cell上
      cell.textLabel!.text =
        dateFormatter.stringFromDate(walk.date)
      
      return cell
  }
  
//    定义table每一行可编辑
  func tableView(tableView: UITableView,
    canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
//  定义每一行可编辑的类型
  func tableView(tableView: UITableView,
    commitEditingStyle
    editingStyle: UITableViewCellEditingStyle,
    forRowAtIndexPath indexPath: NSIndexPath) {
    
    if editingStyle == UITableViewCellEditingStyle.Delete {
    
    //1
    let walkToRemove =
    currentDog.walks[indexPath.row] as! Walk
    
    //2
    managedContext.deleteObject(walkToRemove)
    
    //3
    var error: NSError?
    if !managedContext.save(&error) {
    println("Could not save: \(error)")
    }
    
    //4
    tableView.deleteRowsAtIndexPaths([indexPath],
    withRowAnimation: UITableViewRowAnimation.Automatic)
    }
  }
  
  @IBAction func add(sender: AnyObject) {
    
    //Insert new Walk entity into Core Data
    let walkEntity = NSEntityDescription.entityForName("Walk",
      inManagedObjectContext: managedContext)
    
    let walk = Walk(entity: walkEntity!,
      insertIntoManagedObjectContext: managedContext)
//    当前系统日期
    walk.date = NSDate()
    
    //Insert the new Walk into the Dog's walks set
    var walks =
    currentDog.walks.mutableCopy() as! NSMutableOrderedSet
    
    walks.addObject(walk)
    
    currentDog.walks = walks.copy() as! NSOrderedSet
    
    //Save the managed object context
    var error: NSError?
    if !managedContext!.save(&error) {
      println("Could not save: \(error)")
    }
    
    //Reload table view
    tableView.reloadData()

  }
  
}

