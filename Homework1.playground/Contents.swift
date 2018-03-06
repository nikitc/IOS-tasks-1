import UIKit

struct Note {
    let title: String
    let content: String
    let importance: Importance
    let uuid: String
    let color: UIColor
    
    init(title: String,
         content: String,
         importance: Importance,
         uuid: String = UUID().uuidString,
         color: UIColor = UIColor.white) {
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
                    "color": UIColorToHex(color: self.color)
            ]
        }
    }
    
    static func parse(json: [String: Any]) -> Note? {
        return Note(title: json["title"] as! String,
                    content: json["content"] as! String,
                    importance: Importance(rawValue: json["importance"] as! String)!,
                    uuid: json["uuid"] as! String,
                    color: HexToUIColor(hex: json["color"] as! String))
    }
    
    func UIColorToHex(color: UIColor) -> String {
        return color.htmlRGB
    }
    
    static func HexToUIColor(hex: String) -> UIColor {
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
    
    func deleteNote(uuid: String) {
        notes = notes.filter { $0.uuid != uuid }
    }
    
    func saveAllNotes() {
        var data = "["
        for (index, note) in notes.enumerated() {
            var currentJson = "{"
            currentJson += "\"title\": \"\(String(describing: (note.json["title"] as! String)))\","
            currentJson += "\"content\": \"\(String(describing: (note.json["title"] as! String)))\","
            currentJson += "\"importance\": \"\(String(describing: (note.json["importance"] as! String)))\","
            currentJson += "\"uuid\": \"\(String(describing: (note.json["uuid"] as! String)))\","
            currentJson += "\"color\": \"\(String(describing: (note.json["color"] as! String)))\""
            currentJson += "}"
            data += currentJson
            if index != notes.count - 1 {
                data += ","
            }
        }
        data += "]"
        
        do {
            try data.write(toFile: FileNotebook.filepath!, atomically: false, encoding: String.Encoding.utf8);
        }
        catch {/* error handling here */}

        print(data)
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
        catch {}
        
    }
}

var a = FileNotebook()
var e = Note(title: "test", content: "data", importance: Importance.Normal, uuid: "22", color: UIColor.black)
a.addNote(note: e)
a.deleteNote(uuid: "22")
a.addNote(note: e)
a.saveAllNotes()
a.loadNotes()
print(a.notes)


