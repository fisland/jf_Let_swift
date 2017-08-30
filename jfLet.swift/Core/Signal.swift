//
//  Signal.swift
//  jfLet.swift
//
//  Created by 张炯枫 on 2017/5/24.
//  Copyright © 2017年 fisland. All rights reserved.
//
import Foundation
import UIKit

public class Signal<a>: NSObject {
    
    //1.定义Subscriber的类型 (a)->void, a为泛型参数，代表Signal可以容乃任何类型
    public typealias SignalToken = Int
    fileprivate typealias Subscriber = (a) -> Void
    fileprivate var subscribers = [SignalToken:Subscriber]()
    public private(set) var value : a
    
    let queue = DispatchQueue(label: "com.swift.let.token")
    fileprivate var bindedObject : [(NSObject, String)] = []

    init(value:a) {
        self.value = value
    }
    
    //2.Signal核心方法，subscribleNext,通过参数来订阅该signal的下一次更新
    public func subscribeNext(hasInitiaValue:Bool = false, subscriber: @escaping (a) -> Void) -> SignalToken {
        //调用subscribeNext时，我们生成token,并保存闭包。如果设置了hasInitiaValue，则会立刻用当前值调用一次
        var token : SignalToken = 0
        queue.sync{
            token = (subscribers.keys.max() ?? 0) + 1
            subscribers[token] = subscriber
            if hasInitiaValue{
                subscriber(value)
            }
        }
        return token
    }
    
    public func unscrible(token : SignalToken)
    {
        queue.sync{
            subscribers[token] = nil
        }
    }
    //3. bind, 可以吧signal绑定到某个control的property上，signal更新会自动更新control的property
    public func bind(signal : Signal<a>) -> SignalToken {
        let token = self.subscribeNext { (newValue : a) in
            signal.update(newValue)
        }
        
        return token
    }
    public func unbind(token : SignalToken)
    {
        unscrible(token: token)
    }
    //4.signal的核心方法，通过update来修改signal的值，并通知所有的订阅之
    public func update(_ value : a) {
        //当值更新的时候，逐个调用subscribe
        queue.sync {
            self.value = value
            for sub in subscribers.values{
                sub(value)
            }
        }
    }
    //5.返回signal当前的瞬值
    public func peek() -> a {
        return value
    }
    
    deinit
    {
        for object in bindedObject{
            object.0.removeObserver(self, forKeyPath: object.1)
        }
    }

}
extension Signal
{
    public func map<b>(f : @escaping (a) -> b) -> Signal<b>
    {
        let mappedValue = f(self.value)
        return Signal<b>(value: mappedValue)
    }
    
    public func filter(f : @escaping (a) -> Bool) -> Signal<a>?
    {
        if f(self.value){
            return self
        }else{
            return nil
        }
    }
}
extension Signal
{
    public func bind(to control:NSObject, keyPath:String) {
        //bind也是使用subscribeNext来实现，属性的同步写使用nsobject的setvalue来实现

        _ = self.subscribeNext(hasInitiaValue: true, subscriber: { (v:a) in
            control.setValue(v, forKey: keyPath)
        })
    }
}
