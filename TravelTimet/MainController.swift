import UIKit

class MainController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let discoverVC = DiscoverViewController()
        let nearbyVC = NearbyViewController()
        let bookmarksVC = BookmarksViewController()
        let profileVC = ProfileViewController()

        discoverVC.tabBarItem = UITabBarItem(title: "Discover", image: UIImage(systemName: "magnifyingglass"), tag: 0)
        nearbyVC.tabBarItem = UITabBarItem(title: "Nearby", image: UIImage(systemName: "location.circle"), tag: 1)
        bookmarksVC.tabBarItem = UITabBarItem(title: "Bookmarks", image: UIImage(systemName: "bookmark"), tag: 2)
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), tag: 3)

        let tabBarList = [discoverVC, nearbyVC, bookmarksVC, profileVC]

        viewControllers = tabBarList.map { UINavigationController(rootViewController: $0) }
    }
    
    
}
