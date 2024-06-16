//
//  CalendarViewController.swift
//  My Manager
//
//  Created by Woosol Hwang on 09/06/24.
//
import UIKit
import FSCalendar
import CoreData

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, UITableViewDataSource, UITableViewDelegate, DataLoaderDelegate, FSCalendarDelegateAppearance, AssignmentDetailViewControllerDelegate, LectureDetailViewControllerDelegate {

    
    
    func didDismissModalViewController() {
        loadDataFromCoreData()
        calendarView.reloadData()
        
        if let selectedDate = calendarView.selectedDate {
            filteredItems = todoItems.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: selectedDate) }
        }
        tableView.reloadData()
    }

    

    @IBOutlet weak var calendarView: FSCalendar!
    @IBOutlet weak var tableView: UITableView!
    
    var portal: DataLoader!
    var todoItems: [TodoItem] = []
    var filteredItems: [TodoItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.appearance.subtitleDefaultColor = .darkGray
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CalendarTodoItemCell.self, forCellReuseIdentifier: "CalendarTodoItemCell")
        
    
        setupPortal()
        fetchData()
        NotificationCenter.default.addObserver(self, selector: #selector(updateCalendarView), name: NSNotification.Name("UpdateView"), object: nil)

    }
    
    
    /*
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        let tasksForDate = todoItems.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
        let taskNames = tasksForDate.map { $0.name }
        return taskNames.joined(separator: "\n")
    }
    */

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let tasksForDate = todoItems.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
        if tasksForDate.contains(where: { !$0.isFinished }) {
            return UIColor.red
        } else if !tasksForDate.isEmpty {
            return UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0) // Darker green for completed tasks
        }
        return nil
    }
    
        
    @objc func updateCalendarView() {
        loadDataFromCoreData()
    }

    func setupPortal() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Failed to get AppDelegate")
            return
        }
        let container = appDelegate.persistentContainer
        portal = DataLoader(container: container)
        portal.delegate = self
    }

    func fetchData(completion: (() -> Void)? = nil) {
        DispatchQueue.global().async {
            self.portal.getAssignments(courseID: "someCourseID") { success in
                self.portal.getVideoStatus(courseID: "someCourseID") { success in
                    DispatchQueue.main.async {
                        if success {
                            print("Big Success")
                        } else {
                            self.showAlert(message: "Error")
                        }
                        self.loadDataFromCoreData()
                        completion?()
                    }
                }
            }
        }
    }

    func loadDataFromCoreData() {
        let context = portal.persistentContainer.viewContext
        let assignmentFetchRequest: NSFetchRequest<Assignment> = Assignment.fetchRequest()
        let lectureFetchRequest: NSFetchRequest<Lecture> = Lecture.fetchRequest()
        
        do {
            let assignments = try context.fetch(assignmentFetchRequest)
            let lectures = try context.fetch(lectureFetchRequest)
            
            todoItems = assignments.compactMap { assignment in
                if let dueDate = assignment.due_date, let courseName = assignment.course?.name {
                    let isFinished = assignment.submitted || ManualFinishCheck(withName: assignment.name! , now: assignment.submitted, context: context)
                    
                    return TodoItem(name: assignment.name ?? "No name",
                                    detail: "Assignment",
                                    dueDate: dueDate,
                                    courseName: "\(courseName) - [과제]",
                                    isFinished: isFinished)
                }
                return nil
            }
            
            todoItems += lectures.compactMap { lecture in
                if let dueDate = lecture.due_date, let courseName = lecture.course?.name {
                    let isFinished = ManualFinishCheck(withName: lecture.title! , now: (lecture.attended || lecture.week_attendance), context: context)
                    return TodoItem(name: lecture.title ?? "No title",
                                    detail: "Lecture",
                                    dueDate: dueDate,
                                    courseName: "\(courseName) - [온강]",
                                    isFinished: isFinished)
                }
                return nil
            }
            
            calendarView.reloadData()
            tableView.reloadData()
        } catch {
            print("Failed to fetch data from CoreData: \(error)")
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Notification", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func ManualFinishCheck(withName name: String, now: Bool, context: NSManagedObjectContext) -> Bool {
        let fetchRequest: NSFetchRequest<IsFinished> = IsFinished.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.fetchLimit = 1
        do {
            let results = try context.fetch(fetchRequest)
            if let MetadatEntity = results.first {
                print("Manual save found for: \(name) as \(MetadatEntity.finish)")
                return MetadatEntity.finish
            } else {
                return now
            }
        } catch {
            print("Failed to fetch IsFinished entity: \(error)")
            return now
        }
    }
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        let eventScaleFactor: CGFloat = 1.2
        cell.eventIndicator.transform = CGAffineTransform(scaleX: eventScaleFactor, y: eventScaleFactor)
    }
        
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventOffsetFor date: Date) -> CGPoint {
        return CGPoint(x: 0, y: 5)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return todoItems.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }.count
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderRadiusFor date: Date) -> CGFloat {
        return 0.5
    }
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let tasksForDate = todoItems.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
        if tasksForDate.isEmpty {
            return nil
        }
        return tasksForDate.map { $0.isFinished ? UIColor(red: 0.0, green: 0.7, blue: 0.0, alpha: 1.0) : UIColor.red }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        filteredItems = todoItems.filter { Calendar.current.isDate($0.dueDate, inSameDayAs: date) }
        tableView.reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarTodoItemCell", for: indexPath) as! CalendarTodoItemCell
        let item = filteredItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = filteredItems[indexPath.row]
        
        if selectedItem.detail == "Lecture" {
            performSegue(withIdentifier: "LectureDetail", sender: selectedItem)
        } else if selectedItem.detail == "Assignment" {
            performSegue(withIdentifier: "AssignmentDetail", sender: selectedItem)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LectureDetail",
           let destinationVC = segue.destination as? LectureDetailViewController,
           let todoItem = sender as? TodoItem {
            destinationVC.todoItem = todoItem
            destinationVC.delegate = self  // Set the delegate
        } else if segue.identifier == "AssignmentDetail",
                  let destinationVC = segue.destination as? AssignmentDetailViewController,
                  let todoItem = sender as? TodoItem {
            destinationVC.todoItem = todoItem
            destinationVC.delegate = self  // Set the delegate
        }
    }
}

