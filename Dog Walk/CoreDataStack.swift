//
//  CoreDataStack.swift
//  Dog Walk
//
//  Created by Pietro Rea on 4/20/15.
//  Copyright (c) 2015 Razeware. All rights reserved.
//

import CoreData

//配置coreData数据库

class CoreDataStack {
  
    //四层关系
   let context:NSManagedObjectContext
  let psc:NSPersistentStoreCoordinator
  let model:NSManagedObjectModel
  let store:NSPersistentStore?
  
  init() {
    //1 把定义好的data model（这里是指 Dog Walk）从disk里调用到一个NSManagedObjectModel 对象模型里
    let bundle = NSBundle.mainBundle()
    let modelURL =
    bundle.URLForResource("Dog Walk", withExtension:"momd")
    model = NSManagedObjectModel(contentsOfURL: modelURL!)!
    
    //2 初始化NSPersistentStoreCoordinator，这个东东负责把NSManagedObjectModel  和  persistent store 连接起来，可以称之为“适配器”
    psc = NSPersistentStoreCoordinator(managedObjectModel:model)
    
    //3 context 在这里代表具体的数据（记录）
    context = NSManagedObjectContext()
    context.persistentStoreCoordinator = psc
    
    //4 得到当前的coreData存储路径，在当前路径的基础上增加新的内容
    //类函数调用方法，要加上类名？
    let documentsURL =  CoreDataStack.applicationDocumentsDirectory()
    
    let storeURL =
    documentsURL.URLByAppendingPathComponent("Dog Walk")
    
    //允许升级进化
    let options =
    [NSMigratePersistentStoresAutomaticallyOption: true]
    
   
    var error: NSError? = nil
    //定义适配器另外一端要存储的数据类型，这里是指： SQLite，Dog Walk, 允许升级
    store = psc.addPersistentStoreWithType(NSSQLiteStoreType,
      configuration: nil,
      URL: storeURL,
      options: options,
      error:&error)
    
    if store == nil {
      println("Error adding persistent store: \(error)")
      //终止函数，标准函数库
        abort()
    }
  }
  
    // This is a convenience method to save the stack’s managed object context and handle any errors that might result.
  func saveContext() {
    var error: NSError? = nil
    //如果数据没有变化则不执行后面的save，如果有变化则执行后面的save，非常简单的程序思想
    if context.hasChanges && !context.save(&error) {
    println("Could not save: \(error), \(error?.userInfo)")
    }
  }

    // 类函数，returns a URL to your application’s documents directory，SQLite database 就存放在这个路径下
  class func applicationDocumentsDirectory() -> NSURL {
    let fileManager = NSFileManager.defaultManager()
    
    let urls = fileManager.URLsForDirectory(.DocumentDirectory,
      inDomains: .UserDomainMask) as! [NSURL]
    
    return urls[0]
  }
}
