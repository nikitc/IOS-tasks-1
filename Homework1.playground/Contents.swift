import UIKit


struct Note {
    static let defaultColor = UIColor.white
    
    let title: String
    let content: String
    let importance: Importance
    let uuid: String
    let color: UIColor
    
    init(title: String,
         content: String,
         importance: Importance,
         uuid: String = UUID().uuidString,
         color: UIColor) {
        self.title = title
        self.content = content
        self.importance = importance
        self.uuid = uuid
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
                    "uuid": self.uuid,
                    "color": self.color.htmlRGB
            ]
        }
        //если цвет белый то не сохраняем и importance
    }
    
    static func parse(json: [String: Any]) -> Note? {
        guard let title = json["title"] as? String,
              let content = json["content"] as? String,
              let uuid = json["content"] as? String
        else {
              return nil
        }
        let color = UIColor(hex: json["content"] as? String ?? "FFFFFF")
        let importance = (json["importance"] as? String).flatMap(Importance.init) ?? .Normal
        
        
        return Note(title: title,
                    content: content,
                    importance: Importance(rawValue: json["importance"] as! String)!,
                    uuid: uuid,
                    color: color)
    }
}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: String) {
        let rgb = Int(hex, radix: 16) ?? 0
        
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r,g,b,a)
        }
        return (0, 0, 0, 0)
    }
    
    var htmlRGB: String {
        return String(format: "#%02x%02x%02x", Int(rgba.red * 255), Int(rgba.green * 255), Int(rgba.blue * 255))
    }
}

//учесть решетку

enum Importance:String {
    case Important
    case Normal
    case Unimportant
}
//enum c  с мал буквы

class FileNotebook {
    
    private(set) var notes = [Note]()
    
    static var filepath: String? {
        guard let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).first
            else {
                return nil
        }
        let path = "\(dir)/notes.plist"
        
        return path
    }
    
    func add(note: Note) {
        notes.append(note)
    }
    
    func deleteNote(uuid: String) {
        notes = notes.filter { $0.uuid != uuid }
    }
    
    func saveAllNotes() {
        let data = "[" + notes.map { getJsonItem(note: $0) }.joined(separator: ",") + "]"
        
        do {
            try data.write(toFile: FileNotebook.filepath!, atomically: false, encoding: String.Encoding.utf8);
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getJsonItem(note: Note) -> String {
        var itemValues = [String]()
        itemValues.append(getJsonStr(key: "title", value: note.json["title"] as! String))
        itemValues.append(getJsonStr(key: "content", value: note.json["content"] as! String))
        itemValues.append(getJsonStr(key: "importance", value: note.json["importance"] as! String))
        itemValues.append(getJsonStr(key: "uuid", value: note.json["uuid"] as! String))
        itemValues.append(getJsonStr(key: "color", value: note.json["color"] as! String))
        
        return "{" + itemValues.joined(separator: ",") + "}"
    }
    
    func getJsonStr(key: String, value: String) -> String {
        return "\"\(key)\": \"\(String(describing: (value)))\""
    }
    
    func loadNotes() {
        do {
            let strData = try String(contentsOfFile: FileNotebook.filepath!, encoding: String.Encoding.utf8)
            let data = strData.data(using: String.Encoding.utf8, allowLossyConversion: false)!
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [[String: AnyObject]]
            for noteData in json {
                notes.append(Note.parse(json: noteData)!)
            }
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
}

var fileNotebook = FileNotebook()
var testNote = Note(title: "test", content: "data", importance: Importance.Normal, uuid: "22", color: UIColor.black)
fileNotebook.add(note: testNote)
fileNotebook.deleteNote(uuid: "22")
fileNotebook.add(note: testNote)
fileNotebook.saveAllNotes()
fileNotebook.loadNotes()
print(fileNotebook.notes)


