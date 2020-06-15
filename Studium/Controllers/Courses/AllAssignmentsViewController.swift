//
//  AllAssignmentsViewController.swift
//  Studium
//
//  Created by Vikram Singh on 5/24/20.
//  Copyright © 2020 Vikram Singh. All rights reserved.
//

import Foundation
import RealmSwift
import ChameleonFramework

class AllAssignmentsViewController: SwipeTableViewController, AssignmentRefreshProtocol{
    
    let realm = try! Realm() //Link to the realm where we are storing information
    
    var assignments: Results<Assignment>? //Auto updating array linked to the realm
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "AssignmentCell", bundle: nil), forCellReuseIdentifier: "Cell")

        //loadAssignments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadAssignments()
    }
    
    func loadAssignments(){
        assignments = realm.objects(Assignment.self) //fetching all objects of type Course and updating array with it.
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let assignment = assignments?[indexPath.row]{
            let assignmentCell = cell as! AssignmentCell
            assignmentCell.loadData(assignment: assignment)
            return assignmentCell
        }else{
            cell.textLabel?.text = ""
        }
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignments?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let assignment = assignments?[indexPath.row]{
            do{
                try realm.write{
                    assignment.complete = !assignment.complete
                }
            }catch{
                print(error)
            }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func updateModelDelete(at indexPath: IndexPath) {
        if let assignmentForDeletion = assignments?[indexPath.row]{
            do{
                try realm.write{
                    realm.delete(assignmentForDeletion)
                }
            }catch{
                print(error)
            }
        }
    }
}
