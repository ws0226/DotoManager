//
//  NotificationListViewController.swift
//  My Manager
//
//  Created by Woosol Hwang on 09/06/24.
//
import UIKit
import UserNotifications
import CoreData

struct NotificationItem {
    var name: String
    var body: String
    var triggerDate: Date
    var courseName: String
    var type: String
}

class NotificationListController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var noNotificationsLabel: UILabel!
    
    @objc func UpdateNotificationView(){
        loadNotifications()
    }
    
    var notificationItems: [NotificationItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NotificationCell.self, forCellReuseIdentifier: "NotificationCell")
        
        setupNoNotificationsLabel()
        loadNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(UpdateNotificationView), name: NSNotification.Name("UpdateNotification"), object: nil)
    }
    
    func setupNoNotificationsLabel() {
        noNotificationsLabel = UILabel()
        noNotificationsLabel.text = "예정된 알림이 없습니다! 과제/온강을 다 보셨거나 전부 삭제하셨군요!"
        noNotificationsLabel.textAlignment = .center
        noNotificationsLabel.font = UIFont.systemFont(ofSize: 16)
        noNotificationsLabel.textColor = .gray
        noNotificationsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noNotificationsLabel)
        
        NSLayoutConstraint.activate([
            noNotificationsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noNotificationsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        noNotificationsLabel.isHidden = true
    }
    
    func loadNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
            guard let self = self else { return }
            self.notificationItems = requests.compactMap { request in
                guard let trigger = request.trigger as? UNCalendarNotificationTrigger, let triggerDate = trigger.nextTriggerDate() else {
                    return nil
                }
                
                let titleComponents = request.content.title.split(separator: "]")
                guard titleComponents.count > 1 else {
                    return nil
                }
                
                let type = titleComponents[0].trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
                let name = titleComponents[1].trimmingCharacters(in: .whitespaces)
                let courseName = request.content.body
                
                return NotificationItem(name: name, body: request.content.body, triggerDate: triggerDate, courseName: courseName, type: type)
            }
            self.notificationItems.sort { $0.triggerDate < $1.triggerDate }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.noNotificationsLabel.isHidden = !self.notificationItems.isEmpty
            }
        }
    }
}

extension NotificationListController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificationItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell", for: indexPath) as! NotificationCell
        let item = notificationItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}
extension NotificationListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteNotification(at: indexPath)
        }
    }
    
    func deleteNotification(at indexPath: IndexPath) {
        let item = notificationItems[indexPath.row]
        
        let alert = UIAlertController(title: "Delete Notification", message: "Are you sure you want to delete this notification?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.name])
            self.UpdateNotification(named: item.name)
            self.notificationItems.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.noNotificationsLabel.isHidden = !self.notificationItems.isEmpty
        }))
        present(alert, animated: true, completion: nil)
    }

    private func UpdateNotification(named name: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Notification> = Notification.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let notifications = try context.fetch(fetchRequest)
            if let notification = notifications.first {
                notification.notification = false
            } else {
                let newNotification = Notification(context: context)
                newNotification.name = name
                newNotification.notification = false
            }
            try context.save()
        } catch {
            print("Failed to update notification entity: \(error)")
        }
    }
}
