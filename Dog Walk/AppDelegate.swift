//
//  AppDelegate.swift
//  Dog Walk
//
//  Created by Pietro Rea on 7/10/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
  var window: UIWindow?
  //定义一个coreDataStack实例，
    //You initialize the Core Data stack object as a lazy variable on the application delegate. This means the stack won’t be set up until the first time you access the property
    lazy var coreDataStack = CoreDataStack()

    
    //propagates the managed context from your CoreDataStack object (initializing the whole stack in the process) to ViewController.以下的定义似乎都是静态的
//Tells the delegate that the launch process is almost done and the app is almost ready to run.
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Override point for customization after application launch. 针对不同的应用，界面，配置等，以下代码要重写
    
    let navigationController =
    self.window!.rootViewController as! UINavigationController
    
    let viewController =
    navigationController.topViewController as! ViewController
    
    viewController.managedContext = coreDataStack.context

    return true
  }
//  Tells the delegate that the app is now in the background.
  func applicationDidEnterBackground(application: UIApplication) {
    coreDataStack.saveContext()
  }
//  Tells the delegate when the app is about to terminate.
  func applicationWillTerminate(application: UIApplication) {
    coreDataStack.saveContext()
  }
}

