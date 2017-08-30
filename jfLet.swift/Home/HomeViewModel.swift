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

    var todoCount : Int{
        get{
            return todos.peek().count
        }
    }
    
    var finishedCount : Int{
        get{
            return finishedTodos.peek().count
        }
    }
    
    init() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM yyyy"
        
        let stringDate = dateFormatter.string(from: NSDate() as Date)
        //init中设置，所以开头不设置
        timeValue = Signal(value : stringDate)
        
        updateTodo()
        
    }
    
    //addTodo 是viewModel的提供的command，用于添加一个todo
    func addTodo(content:String,complete:@escaping (Bool)->Void) -> Void {
        //请求开始
        showIndicator.update(true)
        let item = TodoModelItem(timeStamp: Signal<Double>(value: 0), title: Signal<String>(value: content), status: Signal<TodoStatus>(value: .Normal), objectId: Signal<String>(value: ""))
        todoModel.sendTodoAsync(todo: item) { (status : ReqStatus)  in
            self.showIndicator.update(false)
            complete(status == .Success)
            
            if (status == .Success){
                self.updateTodo()
            }
        }
        //请求结束
    }

    func checkedTodo(index:Int, newStatus:TodoStatus) {
        var sourceArr:[TodoModelItem]
        if newStatus == .Normal {
            sourceArr = finishedTodos.peek()
        } else {
            sourceArr = todos.peek()
        }
        
        guard index < sourceArr.count else{
            return
        }
        
        let item = sourceArr[index]
        item.status.update(newStatus)
        
    }
    //请求到list后，取出完成和未完成，赋值到对应的属性中
    func updateTodo() {
        todoModel.getAllModelsAsync { (x:[TodoModelItem]) in
            self.todos.update(x.filter({ (item) -> Bool in
                item.status.peek() == .Normal
            }))
            self.finishedTodos.update(x.filter({ (item) -> Bool in
                item.status.peek() == .Finished
            }))
        }
    }
}
