//
//  ContentView.swift
//  UI4-WordScramble
//
//  Created by Sothesom on 17/09/1403.
//

import SwiftUI

struct ContentView: View {
    @State private var useWord = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMassage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationStack{
            List{
                Section{
                    TextField("کلمه‌ای به تعداد کلمه بالا وارد کنید", text: $newWord)
                    // جلوی وارد کردن حروف بزرگ رو میگیره
                        .textInputAutocapitalization(.never)
                }
                Section{
                    ForEach(useWord, id: \.self) { word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            // اینتر = اضافه بشه
            .onSubmit(addNewWord)
            // هر دفعه که لود میشه
            .onAppear(perform:readFile)
            .alert(errorTitle ,isPresented:$showingError){
                Button("OK"){
                    
                }
            } message: {
                Text(errorMassage)
            }
        }
    }
    
    func addNewWord (){
        // کلمه به صورت حروف کوچک باشد
        // تا ملت همون کلمه رو با حروف بزرگ ننویسن
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // حداقل یه حرف توی باکس باشه
        guard answer.count > 0 else {return}
        
        guard isOrginal(word: answer) else {
            errorWord(title: "کلمه تکراری است", message: "این کلمه قبلا انتخاب شده")
            return
        }
        
        guard isReal(word: answer) else {
            errorWord(title: "کلمه اشتباه است", message: "این کلمه غلط املایی دارد")
            return
        }
        
        guard isPossible(word: answer) else {
            errorWord(title: "کلمه غلط است", message: "کلمه نوشته شده حروف اضافی دارد")
            return
        }
        
        withAnimation {
            // کلمه رو به لیست زیرش اضافه کن
            useWord.insert(answer, at: 0)
            newWord = ""
        }
    }
    
    // خواندن فایل txt
    func readFile(){
        if let file = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let selectFile = try? String(contentsOf: file){
                let allwords = selectFile.components(separatedBy: "\n")
                rootWord = allwords.randomElement() ?? "Error"
                return
            }
        }
        fatalError("فایل رو نمیتونه بخونه")
    }
    
    // بررسی کلمه تکراری
    func isOrginal(word: String) -> Bool {
        !useWord.contains(word)
    }
    
    // بررسی حروف کلمه نوشته شده با حروف کلمه اصلی
    // برای این کار یه کپی از حروف کلمه اصلی میگیریم بعد رو کلمه نوشته شده حلقه میزنیم
    // و وقتی که اون حرف تو حرف نوشته شده بود حذفش میکنیم
    func isPossible(word: String) -> Bool{
        var copy = rootWord
        
        for letter in word {
            // اگر این حرف در اون حروف اصلی بود حذفش کن
            if let pos = copy.firstIndex(of: letter){
                copy.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    // جدا کردن فاصله ها از رشته ها
//    func stringTest(){
//        let input = "a b c"
//        let kalame = input.components(separatedBy: " ")
//        let input2 = """
//        a
//        b
//        c
//        """
//        let selectKaleme = input2.components(separatedBy: "\n")
//    }
    
    //  پیدا کردن غلط املایی در رشته ها
    func isReal(word: String) -> Bool{
        let check = UITextChecker()
        let reng = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = check.rangeOfMisspelledWord(in: word, range: reng, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    
    // تابع ارور نشون دادن
    func errorWord(title: String, message: String) {
        errorTitle = title
        errorMassage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
