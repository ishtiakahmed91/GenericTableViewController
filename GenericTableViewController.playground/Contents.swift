import UIKit
import PlaygroundSupport

// MARK: - Models
struct Newsletter {
    var title: String
    var printDate: String
}

struct Course {
    var name: String
    var publisher: String
}

struct Book {
    var title: String
    var author: String
}


//MARK: - Dummy datas
let dummyNewsletters: [Newsletter] = [
    Newsletter(title: "iOS Dev", printDate: "10.01.2020"),
    Newsletter(title: "iOSCon Munich", printDate: "12.01.2020")
]

let dummyCourses: [Course] = [
    Course(name: "Raywenderlich.com", publisher: "Ray wenderlich video team"),
    Course(name: "hackingwithswift.com", publisher: "Paul Hudson")
]

let dummyBooks: [Book] = [
    Book(title: "iOS Programming", author: "Christian Keur, Aaron Hillegass"),
    Book(title: "iOS Apprentice", author: "Joey deVilla, Eli Ganem, Matthijs Hollemans"),
    Book(title: "Native Mobile Development", author: "Shaun Lewis, Mike Dunn")
]

// MARK: - Generic Table View Controller

struct CellInfo {
    let reuseIdentifier: String
    let cellType: UITableViewCell.Type
    let cellOutletSetupCompletionBlock: (UITableViewCell) -> ()

    init<TableViewCell: UITableViewCell>(reuseIdentifier: String, cellOutletSetupCompletionBlock: @escaping (TableViewCell) -> ()) {
        self.reuseIdentifier = reuseIdentifier
        cellType = TableViewCell.self
        self.cellOutletSetupCompletionBlock = { cell in
            cellOutletSetupCompletionBlock(cell as! TableViewCell)
        }
    }
}

// MARK: - GenericTableViewController
final class GenericTableViewController<RowData>: UITableViewController {
    var rowDatas: [RowData] = []
    let cellInfo: (RowData) -> CellInfo
    var rowSeclectionCompletionBlock: (RowData) -> () = { _ in }
    var reuseIdentifiers: Set<String> = []

    init(title: String, datas: [RowData], cellInfo: @escaping (RowData) -> CellInfo) {
        self.cellInfo = cellInfo
        super.init(style: .plain)
        self.rowDatas = datas
        self.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowData = rowDatas[indexPath.row]
        rowSeclectionCompletionBlock(rowData)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowDatas.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowData = rowDatas[indexPath.row]
        let descriptor = cellInfo(rowData)

        if !reuseIdentifiers.contains(descriptor.reuseIdentifier) {
            tableView.register(descriptor.cellType, forCellReuseIdentifier: descriptor.reuseIdentifier)
            reuseIdentifiers.insert(descriptor.reuseIdentifier)
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: descriptor.reuseIdentifier, for: indexPath)
        descriptor.cellOutletSetupCompletionBlock(cell)
        return cell
    }
}


// MARK: - UITableViewCells
final class CourseCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class NewsletterCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class BookCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - Show data
enum CellData {
    case newsletter(Newsletter)
    case course(Course)
    case book(Book)

    var cellInfo: CellInfo {
        switch self {
        case .newsletter(let newsletter):
            return CellInfo(reuseIdentifier: "newsletter", cellOutletSetupCompletionBlock: {(cell: NewsletterCell) in
                cell.textLabel?.text = newsletter.title
                cell.detailTextLabel?.text = newsletter.printDate
                cell.detailTextLabel?.textColor = .orange
            })
        case .book(let book):
            return CellInfo(reuseIdentifier: "book", cellOutletSetupCompletionBlock: {(cell: BookCell) in
                cell.textLabel?.text = book.title
            })
        case .course(let course):
            return CellInfo(reuseIdentifier: "course", cellOutletSetupCompletionBlock: {(cell: CourseCell) in
                cell.textLabel?.text = course.name
                cell.textLabel?.textColor = .red
            })
        }
    }
}

let dummyCellDatas: [CellData] = [
    .newsletter(dummyNewsletters[0]),
    .newsletter(dummyNewsletters[1]),
    .course(dummyCourses[0]),
    .course(dummyCourses[1]),
    .book(dummyBooks[0]),
    .book(dummyBooks[1]),
    .book(dummyBooks[2])
]

let tableViewController = GenericTableViewController(title: "iOS learning", datas: dummyCellDatas, cellInfo: { $0.cellInfo })
let navigationController = UINavigationController(rootViewController: tableViewController)

navigationController.view.frame = CGRect(x: 0, y: 0, width: 400, height: 800)
PlaygroundPage.current.liveView = navigationController.view


