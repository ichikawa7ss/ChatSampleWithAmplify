//
//  ViewController.swift
//  ChatSampleWithAmplify
//
//  Created by ichikawa on 2020/11/17.
//  Copyright © 2020 ichikawa. All rights reserved.
//

import UIKit
import Amplify

class ViewController: UIViewController {

    private var subscription: GraphQLSubscriptionOperation<Todo>?
    
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var completedLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.createTodo(name: UUID().uuidString, description: "test")
        createSubscription()
    }

    @IBAction func tapCancelButton() {
        subscription?.cancel()
    }
    
    private func createTodo(name: String, description: String) {
        let todo = Todo(name: name, description: description)
        Amplify.API.mutate(request: .create(todo)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let todo):
                    print("Successfully created the todo: \(todo)")
                case .failure(let graphQLError):
                    print("Failed to create graphql \(graphQLError)")
                }
            case .failure(let apiError):
                print("Failed to create a todo", apiError)
            }
        }
    }
    
    
    private func getTodo() {
        Amplify.API.query(request: .get(Todo.self, byId: "0BBA66B7-1A0A-4F40-95A3-CBF9A5140CAF")) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let todo):
                    guard let todo = todo else {
                        print("Could not find todo")
                        return
                    }
                    print("Successfully retrieved todo: \(todo)")
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
            }
        }
    }
    
    private func listTodos() {
        let todo = Todo.keys
        let predicate = todo.name == "my first todo" && todo.description == "todo description"
        Amplify.API.query(request: .list(Todo.self, where: predicate)) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let todo):
                    print("Successfully retrieved list of todos: \(todo)")
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
            }
        }
    }
    
    private func createSubscription() {
        subscription = Amplify.API.subscribe(request: .subscription(of: Todo.self, type: .onCreate), valueListener: { (subscriptionEvent) in
            switch subscriptionEvent {
            case .connection(let subscriptionConnectionState):
                print("Subscription connect state is \(subscriptionConnectionState)")
            case .data(let result):
                switch result {
                case .success(let createdTodo):
                    DispatchQueue.main.async {
                        self.label.text = createdTodo.name
                    }
                    print("Successfully got todo from subscription: \(createdTodo)")
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                }
            }
        }) { result in
            switch result {
            case .success:
                self.completedLabel.isHidden = false
                print("Subscription has been closed successfully")
            case .failure(let apiError):
                print("Subscription has terminated with \(apiError)")
            }
        }
    }
}

