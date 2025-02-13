//
//  ContentView.swift
//  ListView
//
//  Created by 田中康志 on 2025/02/09.
//

import SwiftUI

// Task 構造体（タスクのデータモデル）


struct ContentView: View {
    var body: some View {
        FirstView() // FirstView を表示
    }
    }
        
        // FirstView（タスクリストの画面）
        struct FirstView: View {
            @AppStorage("TasksData") private var tasksData = Data()
            @State private var tasksArray: [Task] = []
            
            var body: some View {
                NavigationStack {
                    VStack {
                        NavigationLink(destination: SecondView(tasksArray: $tasksArray, saveTasks: saveTasks)) { //  修正: saveTasks を渡す
                            Text("Add New Task")
                                .font(.system(size: 20, weight: .bold))
                                .padding()
                            
                            
                            List {
                                ForEach(tasksArray) { task in
                                    Text(task.taskItem)
                                }
                                .onDelete(perform: deleteTask) // スワイプで削除
                                .onMove(perform: replaceRow)  // 並び替え
                                
                                .navigationTitle("Task List")
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarLeading) {
                                        EditButton() // 編集モードボタン
                                    }
                                    
                                }
                            }
                            .onAppear(perform: loadTasks) // アプリ起動時にデータをロード
                        }
                        
                    }//VStack
                }//NavigationStack
            }//var body
            // タスク削除処理（スワイプ or 編集モードで削除）
            func deleteTask(at offsets: IndexSet) {
                var array = tasksArray
                tasksArray.remove(atOffsets: offsets)
                saveTasks() // 削除後にデータを保存
            }
            
            
            // 並び替え処理（並び替えた後にデータを保存）
            func replaceRow(_ from: IndexSet, _ to: Int) {
                tasksArray.move(fromOffsets: from, toOffset: to)
                saveTasks() // 並び替え後にデータを保存
                
                
                // エンコードが成功した場合のみ保存＆更新
        
               if let encodedData = try? JSONEncoder(array).encode() {
                   tasksData = encodedData
           tasksArray = array // 成功した場合のみ `tasksArray` を更新
               
                }
            }
            
            
            
            // データを UserDefaults に保存（SecondView でも使えるように func saveTasks() を渡す）
            func saveTasks() {
                if let encodedArray = try? JSONEncoder().encode(tasksArray) {
                    tasksData = encodedArray
                }
            }
            
            // データを UserDefaults から読み込む
            func loadTasks() {
                if let decodedTasks = try? JSONDecoder().decode([Task].self, from: tasksData) {
                    tasksArray = decodedTasks
                }
            }
        }
        
        // SecondView（タスクを追加する画面）
struct SecondView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var task: String = ""
    @Binding var tasksArray: [Task] // タスクを受け取る
    var saveTasks: () -> Void // 修正: saveTasks を FirstView から受け取る
    
    var body: some View {
        VStack {
            TextField("タスクを入力してください", text: $task)
                .textFieldStyle(.roundedBorder)
                .padding()
        }
        
        Button {
            addTask(newTask: task) // タスクを追加
            task = "" // 入力欄をクリア
        } label: {
            Text("Add")
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
        .padding()
        
        Spacer()
        
    }
    
    func addTask(newTask: String) {
        if newTask.isEmpty { return }
        
        let task = Task(taskItem: newTask)
        
        // ここでtasksArrayを変更してしまうと、エラーが起きたときに
        // 保存した内容と画面が合わなくなってしまうので、
        // tasksArrayを直接書き換えないように
        // 一時的な作業用の変数にtasksArrayをコピーする
        var array = tasksArray
        // 作業用の変数を操作。ここではタスクを追加する
        array.append(task)
        
        // 操作した内容をData型に変換し、変換が成功したかチェックする
        if let encodeData = try? JSONEncoder().encode(array) {
            
            // 変換が成功した時だけUserDefautsにタスクのデータを保存する
            UserDefaults.standard.setValue(encodeData, forKey: "TaskData")
            
            // 変換が成功した時だけ画面内容を保持する変数tasksArrayを変更する
            tasksArray = array
            
            dismiss()
        }
    }
    
}
            // タスク追加処理
//            func addTask(newTask: String) {
//                if !newTask.isEmpty {
//                    let task = Task(taskItem: newTask)
//                    tasksArray.append(task) // tasksArray に追加
                    
                    
//                    func deleteTask(at offsets: IndexSet) {
//                        var array = tasksArray
//                        array.remove(atOffsets: offsets) // 削除処理を実行
//                    }
//                  if let encodedData = try? JSONEncoder().encode(array) { //  エンコードが成功した場合のみ更新
//                        tasksData = encodedData
//                        tasksArray = array
//                    }
//                }
                
                
//                saveTasks() // UserDefaults にデータを保存
//                dismiss() // 画面を閉じる
                
//            }
//        }
        
        
        
        // プレビュー用
        #Preview {
            ContentView()
        }


