import UIKit


struct Note {
    let title: String
    let content: String
    let importance: Importance
    let uid: String
    let color: UIColor
    
    init(title: String,
         content: String,
         importance: Importance,
         uid: String = UUID().uuidString,
         color: UIColor = UIColor.white) {
        self.title = title
        self.content = content
        self.importance = importance
        self.uid = uid
        self.color = color
    }
}

extension Note {
    var json: [String: Any] {
        get {
            return [
                    "title": self.title,
                    "content": self.title,
                    "importance": self.importance.rawValue,
                    "uid": self.uid,
                    "color": UIColorToHex(color: self.color)
                    ]
        }
    }
    
    func parse(json: [String: Any]) -> Note? {
        return Note(title: json["title"] as! String,
                    content: json["content"] as! String,
                    importance: Importance(rawValue: json["importance"] as! String)!,
                    uid: json["uid"] as! String,
                    color: HexToUIColor(hex: json["color"] as! String))
    }
    
    func UIColorToHex(color: UIColor) -> String {
        let components = color.cgColor.components
        
        let r = Double((components?[0])!)
        let g = Double((components?[1])!)
        let b = Double((components?[2])!)
        
        return String(format: "#%02lX%02lX%021lX", lround(r * 255), lround(g * 255), lround(b * 255))
    }
    
    func HexToUIColor(hex: String) -> UIColor {
        let rgb = Int(hex, radix: 16) ?? 0
        return UIColor(rgb: rgb)
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

enum Importance:String {
    case Important
    case Normal
    case Unimportant
}


class FileNotebook {
    
    private(set) var notes = [Note]()
    
    static var filepath: String? {
        guard let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first
            else {
                return nil
        }
        
        let path = "\(dir)/notes.plist"
        print(path)
        
        return path
    }
    
    func addNote(note: Note) {
        notes.append(note)
    }
    
    func deleteNote(uid: String) {
        notes = notes.filter { $0.uid != uid }
    }
    
    func saveAllNotes() {
        print(FileNotebook.filepath)
    }
    
    func loadNotes() {
        //TODO
    }
}

var a = FileNotebook()
var e = Note(title: "test", content: "data", importance: Importance.Normal, uid: "22", color: UIColor.black)
a.addNote(note: e)
a.deleteNote(uid: "22")
a.addNote(note: e)
a.saveAllNotes()


