//
//  HomeViewModel.swift
//  jfLet.swift
//
//  Created by 张炯枫 on 2017/5/28.
//  Copyright © 2017年 fisland. All rights reserved.
//

import Foundation

class HomeViewModel {
    var todos : Signal<[TodoModelItem]> = Signal(value: [])
    var finishedTodos : Signal<[TodoModelItem]> = Signal(value: [])
    var showIndicator : Signal<Bool> = Signal(value: false)
    var timeValue : Signal<String>
    var todoModel : TodoModel = TodoModel()

    //addTodo 是viewModel的提供的command，用于添加一个todo
    func addTodo(content:String,complete:@escaping (Bool)->Void) -> Void {
        //请求开始
        showIndicator.update(true)
        
        //请求结束
    }
    
    //请求到list后，取出完成和未完成，赋值到对应的属性中
    func update() {
        
    }
}
