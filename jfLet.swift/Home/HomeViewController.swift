//
//  HomeViewController.swift
//  jfLet.swift
//
//  Created by 张炯枫 on 2017/5/29.
//  Copyright © 2017年 fisland. All rights reserved.
//

import UIKit
import Networking
import NVActivityIndicatorView

class HomeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var todoTextView: UITextField!
    @IBOutlet weak var todoTableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var textValue: Signal<String> = Signal(value: "")
    let activity = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40), type : .ballClipRotateMultiple, color : UIColor.blue)

    let viewModel = HomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        textValue.bind(to: todoTextView, keyPath: "text")
        // Do any additional setup after loading the view.
        todoTableView.delegate = self
        todoTableView.dataSource = self
    }

    func setupViews(){
        self.todoTableView.tableFooterView = UIView()
        view.addSubview(activity)
        
        viewModel.timeValue.bind(to: self.dateLabel, keyPath: "text")
        
        _ = viewModel.finishedTodos.subscribeNext(subscriber: { (v) in
            self.todoTableView.reloadSections(IndexSet(integer: 1), with: .none)
        })
        
        _ = viewModel.todos.subscribeNext(subscriber: { (v) in
            self.todoTableView.reloadSections(IndexSet(integer: 0), with: .none)
        })
        
        _ = viewModel.showIndicator.subscribeNext(subscriber: { (x) in
            if x{
                self.activity.startAnimating()
            }
            else{
                self.activity.stopAnimating()
            }
        })
        
        todoTextView.delegate = self
    }

    override func viewDidLayoutSubviews() {
        var frame = activity.frame
        frame.origin.x = view.bounds.width / 2 - frame.size.width / 2
        frame.origin.y = view.bounds.height / 2 - frame.size.height / 2
        
        activity.frame = frame
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text != "" {
            viewModel.addTodo(content: textField.text!, complete: { (x) in
                if x{
                    textField.text = ""
                }
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource, HomeTodoCellDelegate{

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ["To Do", "Finished"][section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return [viewModel.todoCount, viewModel.finishedCount][section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HomeTodoCell") as! HomeTodoCell
        
        var item : TodoModelItem
        if indexPath.section == 1{
            cell.checkBox.on = true
            item = viewModel.finishedTodos.peek()[indexPath.row]
        } else {
            cell.checkBox.on = false
            item = viewModel.todos.peek()[indexPath.row]
        }
        
        cell.delegate = self
        item.title.bind(to: cell.mainTitle, keyPath: "text")
        return cell
    }
    
    func didFinishedCheck(cell: HomeTodoCell) {
        let indexPath = self.todoTableView.indexPath(for: cell)
        var status : TodoStatus
        
        if  cell.checkBox.on {
            status = .Finished
        }
        else{
            status = .Normal
        }
        
        if let i = indexPath{
            viewModel.checkedTodo(index: i.row, newStatus: status)
        }
    }
}











