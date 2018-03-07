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
            var dict = [String: Any]()
            dict["title"] = self.title
            dict["content"] = self.content
            dict["uuid"] = self.uuid
            if (self.importance != .normal) {
                dict["importance"] = self.importance.rawValue
            }
            
            if (self.color != UIColor.white) {
                dict["color"] = self.color.htmlRGB
            }
            
            return dict
        }
    }
    
    static func parse(json: [String: Any]) -> Note? {
        guard let title = json["title"] as? String,
              let content = json["content"] as? String,
              let uuid = json["content"] as? String
        else {
              return nil
        }
        
        let color = (json["content"] as? String).flatMap{ UIColor(hex: $0) } ?? UIColor(hex: "FFFFF")
        let importance = (json["importance"] as? String).flatMap(Importance.init) ?? .normal
        
        return Note(title: title,
                    content: content,
                    importance: importance,
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

enum Importance: String {
    case important
    case normal
    case unimportant
}

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
        guard let path = FileNotebook.filepath
            else {
                return
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: notes.map {$0.json}, options: [])
            guard let strData = String.init(data: data, encoding: .utf8) as String?
                else {
                    return
            }
            try strData.write(toFile: path, atomically: false, encoding: String.Encoding.utf8)
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func loadNotes() {
        guard let path = FileNotebook.filepath
            else {
                return
        }
        
        do {
            let strData = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
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
var testNote = Note(title: "test", content: "data", importance: Importance.normal, uuid: "22", color: UIColor.black)
fileNotebook.add(note: testNote)
fileNotebook.deleteNote(uuid: "22")
fileNotebook.add(note: testNote)
fileNotebook.saveAllNotes()
fileNotebook.loadNotes()
print(fileNotebook.notes)


