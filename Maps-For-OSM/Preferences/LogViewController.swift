/*
 Maps For OSM
 App for display and use of OSM maps without MapKit
 Copyright: Michael Rönnau mr@elbe5.de
 */

import UIKit
import E5Data
import E5IOSUI

class LogViewController: NavTableViewController{
    
    var logLevelControl = UISegmentedControl()
    
    var logs: Array<String> = Array()
    
    override func loadView() {
        title = "log".localize()
        createSubheaderView()
        super.loadView()
        view.backgroundColor = .systemBackground
        tableView.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LogCell.self, forCellReuseIdentifier: LogCell.CELL_IDENT)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        logs.append(contentsOf: Log.cache.reversed())
        tableView.reloadData()
        Log.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        Log.delegate = nil
        logs.removeAll()
    }
    
    override func setupSubheaderView(subheaderView: UIView){
        subheaderView.backgroundColor = .subheaderBackground
        super.setupSubheaderView(subheaderView: subheaderView)
        let header = UILabel(header: "logLevel".localize())
        subheaderView.addSubviewWithAnchors(header, top: subheaderView.topAnchor, leading: subheaderView.leadingAnchor, trailing: subheaderView.trailingAnchor, insets: defaultInsets)
        
        logLevelControl.insertSegment(action: UIAction(){ action in
            Log.logLevel = .none
        }, at: 0, animated: false)
        logLevelControl.setTitle("none", forSegmentAt: 0)
        logLevelControl.insertSegment(action: UIAction(){ action in
            Log.logLevel = .error
        }, at: 1, animated: false)
        logLevelControl.setTitle("error", forSegmentAt: 1)
        logLevelControl.insertSegment(action: UIAction(){ action in
            Log.logLevel = .warn
        }, at: 2, animated: false)
        logLevelControl.setTitle("warn", forSegmentAt: 2)
        logLevelControl.insertSegment(action: UIAction(){ action in
            Log.logLevel = .info
        }, at: 3, animated: false)
        logLevelControl.setTitle("info", forSegmentAt: 3)
        logLevelControl.insertSegment(action: UIAction(){ action in
            Log.logLevel = .debug
        }, at: 4, animated: false)
        logLevelControl.setTitle("debug", forSegmentAt: 4)
        logLevelControl.selectedSegmentIndex = Log.logLevel.rawValue
        
        subheaderView.addSubviewWithAnchors(logLevelControl, top: header.bottomAnchor, leading: subheaderView.leadingAnchor, trailing: subheaderView.trailingAnchor, insets: defaultInsets)
        
        let clearButton = UIButton()
        clearButton.setTitle("clearLog".localize(), for: .normal)
        clearButton.setTitleColor(.systemBlue, for: .normal)
        clearButton.addAction(UIAction(){ action in
            Log.cache.removeAll()
            self.logs.removeAll()
            self.tableView.reloadData()
        }, for: .touchDown)
        subheaderView.addSubviewWithAnchors(clearButton, top: logLevelControl.bottomAnchor, leading: subheaderView.leadingAnchor, trailing: subheaderView.trailingAnchor, bottom: subheaderView.bottomAnchor, insets: defaultInsets)
    }
    
}

extension LogViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LogCell.CELL_IDENT, for: indexPath) as! LogCell
        cell.updateCell(log: logs[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}

extension LogViewController: LogDelegate{
    
    func newLog(log: String) {
        logs.insert(log, at: 0)
        tableView.reloadData()
    }
    
}
    

