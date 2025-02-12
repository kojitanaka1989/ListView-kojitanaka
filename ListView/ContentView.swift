//
//  ContentView.swift
//  ListView
//
//  Created by 田中康志 on 2025/02/09.
//

import SwiftUI

struct Task: Identifiable, Codable {
    var id = UUID()  // タスクを区別するための番号
    var taskItem: String  // タスクの内容
}

struct ContentView: View {
    var body: some View {
        FirstView()//FirstViewを表示
        //SecondView()
    }
}
//リストのビュー
struct FirstView: View {
    //"TasksData"というキーで保存されたものを監視
    @AppStorage("TasksData") private var tasksData = Data()
    @State var tasksArray: [Task] = []
    // FirstView生成時に呼ばれる。
    init() {
        // tasksDataをデコードできたら、その値をtasksArrayにわたす
        if let decodedTasks = try? JSONDecoder().decode([Task].self, from: tasksData){
            _tasksArray = State(initialValue: decodedTasks)
            print(tasksArray)
        }
    }
    
    
    
    var body: some View {
        
 
        NavigationStack{
            NavigationLink(destination: SecondView(tasksArray: $tasksArray).navigationTitle("Add Task")) {
                Text("Add New Task")
                    .font(.system(size: 20, weight: .bold))
                    .padding()
                
            }
            List {
                //ExampleTask の中の　taskList を List の内側に　ForEachを使う
                ForEach(tasksArray){ task in
                    Text(task.taskItem)
                }
               
                // スワイプで削除
                .onDelete(perform: deleteTask)
                
                // 削除する関数を作る
                func deleteTask(at offsets: IndexSet) {
                    tasksArray.remove(atOffsets: offsets) // 指定されたタスクを削除
                    saveTasks() //削除後にデータを保存
                }
                
                
                //並び替えが起きた時に実行される
                
                .onMove{ from, to in
                    replaceRow(from, to)
                    
                    
                    
                }
                
               
                
                
            }
                .navigationTitle("Task List")//画面上のタイトル
            
            
            // 編集ボタンをつける
            toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            
            //ナビゲーションバーに編集ボタンを追加
            .toolbar(content: {
                           EditButton()
                       })
        }
    }
    //並び替え処理　と　並び替え後の保存
    func replaceRow(_ from: IndexSet, _ to: Int) {
           tasksArray.move(fromOffsets: from, toOffset: to) // 配列内での並び替え
           if let encodedArray = try? JSONEncoder().encode(tasksArray) {
               tasksData = encodedArray // エンコードできたらAppStorageに渡す(保存・更新)
           }
       }
}

//タスク入力用のビュー
struct SecondView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    //テキストフィールドに入力された文字を格納する変数
    @State private var task: String = ""
    @Binding var tasksArray:[Task] //タスクをいれる配列
    
    var body: some View {
        TextField("タスクを入力してください", text: $task)
            .textFieldStyle(.roundedBorder)
            .padding()
        
        Button{
            //ボタンを押した時に実行される
            addTask(newTask: task)//入力されたタスクの保存
            task = ""//テキストフィールドを空に
            print(tasksArray)
            
            
        } label: {
            Text("add")
            
        }
        .buttonStyle(.borderedProminent)
        .tint(.orange)
        .padding()
        
        Spacer()//下側の余白を埋めた
        
        
        
        
        
    }
    //タスクの追加と保存　引数は入力されたタスクの文字
    func addTask(newTask:String){
    //テキストフィールドに入力された値が空白者に時だけ処理(何か入力されている)時だけ処理
        if !newTask.isEmpty {
            
            let task = Task(taskItem: newTask)//Taskをインスタンス化(実体化)
            var array = tasksArray
            
            array.append(task)//一時的な配列ArrayにTaskを追加
            
            //エンコードがうまくいったらUserDefaultsに保存する
            if let encodedData = try? JSONEncoder().encode(array){
                UserDefaults.standard.setValue(encodedData, forKey: "TasksData")
                tasksArray = array//保存ができた時だけ　新しいTaskが追加された配列を反映
                dismiss()//前の画面に戻る
            }
        }
        }
    }



#Preview {
    ContentView()
}


//#Preview("SecondView", body: {
//    SecondView()
//})
