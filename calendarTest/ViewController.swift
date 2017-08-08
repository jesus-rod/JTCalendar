//
//  ViewController.swift
//  calendarTest
//
//  Created by Jesus Adolfo on 03.08.17.
//  Copyright © 2017 jesusadolfo. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController {

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    @IBOutlet weak var monthYearStickyLabel: UILabel!
    
    let formatter = DateFormatter()
    let monthFormatter = DateFormatter()
    var testCalendar = Calendar.current
    var rangeSelectedDates: [Date] = []
    var firstDate: Date?
    var secondDate: Date?

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    var currentMonthIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
        
        
        monthFormatter.dateFormat = "MMMM yyyy"
        
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
        bottomView.isHidden = true
        bottomViewHeight.constant = 0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupCalendarView() {
        calendarView.scrollToDate( Date() )
        calendarView.allowsMultipleSelection  = true
        calendarView.isRangeSelectionUsed = true
        calendarView.scrollDirection = .vertical
        calendarView.scrollingMode = .none
        calendarView.minimumInteritemSpacing = 0
        calendarView.minimumLineSpacing = 0
        
        let someSmallerDateCellValue : CGFloat = 40.0
        calendarView.cellSize = someSmallerDateCellValue
        
        
        calendarView.sectionInset.left = 15
        calendarView.sectionInset.right = 15
        
        calendarView.register(UINib(nibName: "MonthHeader", bundle: Bundle.main),
                              forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                              withReuseIdentifier: "MonthHeader")
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        
        let date = visibleDates.monthDates.first!.date
        monthYearStickyLabel.text = monthFormatter.string(from: date)
        
        
    }

    func orderSelectedDates(withDates dates: [Date]) -> [Date]{
        let sortedDates = dates.sorted { $0 < $1 }
        return sortedDates
    }
    
    @IBAction func resetDatepickerButtonPressed(_ sender: UIButton) {
        resetDatepicker()
    }
    
    func resetDatepicker() {
        hideBottomView()
        calendarView.deselectAllDates()
        firstDate = nil
        secondDate = nil
    }
    
    func hideBottomView() {
        //call animation for the bottom view
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.bottomView.isHidden = true
            self.bottomViewHeight.constant = 0
            self.view.layoutIfNeeded()
            
        }, completion: { (completed) in
            
        })
    }
    
    func showBottomView() {
        //call animation for the bottom view
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.bottomView.isHidden = false
            self.bottomViewHeight.constant = 160
            self.view.layoutIfNeeded()
            
        }, completion: { (completed) in
            
            
            
        })
    }
    
}

extension ViewController: JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2018 12 15")!
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6,
                                                 calendar: testCalendar,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfRow,
                                                 firstDayOfWeek: .monday)
        return parameters
    }

    
    func handleCellSelection(view: JTAppleCell?, cellState: CellState) {
        
        guard let myCustomCell = view as? JTCollectionViewCell else {return }
        switch cellState.selectedPosition() {
        case .full, .left, .right:
            myCustomCell.dateLabel.textColor = .white
            myCustomCell.selectedView.isHidden = false
            myCustomCell.selectedView.backgroundColor = UIColor.orange // Or you can put what ever you like for your rounded corners, and your stand-alone selected cell
        case .middle:
            myCustomCell.dateLabel.textColor = .white
            myCustomCell.selectedView.isHidden = false
            myCustomCell.selectedView.backgroundColor = UIColor.black // Or what ever you want for your dates that land in the middle
        default:
            myCustomCell.dateLabel.textColor = .black
            myCustomCell.selectedView.isHidden = true
            myCustomCell.selectedView.backgroundColor = nil // Have no selection when a cell is not selected
        }
        
    }

    
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let date = range.start
        
        let header: MonthHeader
        
        header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "MonthHeader", for: indexPath) as! MonthHeader
        header.title.text = monthFormatter.string(from: date).uppercased()
        
        
        return header
    }
    
    func sizeOfDecorationView(indexPath: IndexPath) -> CGRect {
        let stride = calendarView.frame.width * CGFloat(indexPath.section)
        return CGRect(x: stride + 5, y: 5, width: calendarView.frame.width - 10, height: calendarView.frame.height - 10)
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        return MonthSize (defaultSize: 40)
    }
    

    
}

extension ViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "JTCalendarCell", for: indexPath) as! JTCollectionViewCell
        cell.dateLabel.text = cellState.text
        
        let dataSection = cellState.dateSection()
        if dataSection.month != currentMonthIndex {
            currentMonthIndex = dataSection.month
            let visibleDates = calendarView.visibleDates()
            setupViewsOfCalendar(from: visibleDates)
        }
        
        if cellState.dateBelongsTo == .thisMonth {
            cell.isHidden = false
        } else {
            //hide it
            cell.isHidden = true
        }
        
        handleCellSelection(view: cell, cellState: cellState)
        return cell
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        
        //first date was selected before, so lets pick a second date
        if firstDate != nil && secondDate == nil {
            
            secondDate = date
            guard let firstDate = firstDate, let secondDate = secondDate else { return }
            
            let orderedLimits = orderSelectedDates(withDates: [firstDate, secondDate])
            calendarView.selectDates(from: orderedLimits[0], to: orderedLimits[1],  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)

            showBottomView()
        } else if firstDate != nil {
            //there is a date range selected, lets start a new range
            calendarView.deselectAllDates()
            firstDate = date
            calendarView.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: false)
            secondDate = nil
            hideBottomView()
        } else {
            //nothing has been chosen, let's pick the first date
            firstDate = date
        }
        
        handleCellSelection(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) -> Bool {
        
        
        //if the selected date
        if date == firstDate {
            secondDate = firstDate
            showBottomView()
            return false
        }
        
        
        if firstDate != nil && secondDate != nil {
            resetDatepicker()
            firstDate = date
            calendarView.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: false)
            hideBottomView()
            return false
        } else {
            return true
        }
        
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
    }
    
 
    
    
    
    
}
