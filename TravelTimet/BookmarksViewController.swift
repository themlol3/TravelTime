import UIKit
import Firebase
import SDWebImage

class BookmarksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var bookmarks: [(name: String, latitude: Double, longitude: Double, imageURL: String?)] = []
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Bookmarks"

        tableView = UITableView(frame: view.bounds)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "BookmarkCell")
        view.addSubview(tableView)

        fetchBookmarks()
    }

    func fetchBookmarks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let databaseRef = Database.database(url: "https://traveltime-628dc-default-rtdb.europe-west1.firebasedatabase.app").reference()
        let bookmarksRef = databaseRef.child("users").child(userId).child("bookmarks")

        bookmarksRef.observe(.value) { snapshot in
            self.bookmarks.removeAll()

            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let dict = childSnapshot.value as? [String: Any],
                   let name = dict["name"] as? String,
                   let latitude = dict["latitude"] as? Double,
                   let longitude = dict["longitude"] as? Double,
                   let imageURL = dict["imageURL"] as? String {
                    
                    self.bookmarks.append((name: name, latitude: latitude, longitude: longitude, imageURL: imageURL))
                }
            }

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookmarks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath)
        let bookmark = bookmarks[indexPath.row]
        
        cell.textLabel?.text = bookmark.name
        if let url = URL(string: bookmark.imageURL ?? "") {
            cell.imageView?.sd_setImage(with: url, completed: nil)
        }
        
        return cell
    }

}
