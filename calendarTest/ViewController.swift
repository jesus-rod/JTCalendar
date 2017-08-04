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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCalendarView()
        
        
        monthFormatter.dateFormat = "MMMM yyyy"
        
        calendarView.visibleDates { (visibleDates) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setupCalendarView() {
        calendarView.scrollToHeaderForDate( Date() )
        calendarView.allowsMultipleSelection  = true
        calendarView.isRangeSelectionUsed = true
        calendarView.scrollDirection = .vertical
        calendarView.scrollingMode = .none
        calendarView.minimumInteritemSpacing = 0
        calendarView.minimumLineSpacing = 0
        let someSmallerDateCellValue : CGFloat = 40.0
        calendarView.cellSize = someSmallerDateCellValue
        
        calendarView.register(UINib(nibName: "MonthHeader", bundle: Bundle.main),
                              forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                              withReuseIdentifier: "MonthHeader")
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        
        let date = visibleDates.monthDates.first!.date
        monthYearStickyLabel.text = monthFormatter.string(from: date)
        
        
    }

    func compareSelectedDates() {
        
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
    
    
    func handleCellConfiguration(cell: JTAppleCell?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
//        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    // Function to handle the text color of the calendar
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        
        guard let myCustomCell = view as? JTCollectionViewCell  else { return }
        
        if myCustomCell.isSelected {
            myCustomCell.dateLabel.textColor = .white
        } else {
            myCustomCell.dateLabel.textColor = .black
        }
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
        
//        if cellState.isSelected {
//            myCustomCell.selectedView.isHidden = false
//        } else {
//            myCustomCell.selectedView.isHidden = true
//        }
    }

    
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date), at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let date = range.start
        
        let header: MonthHeader
        
        header = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "MonthHeader", for: indexPath) as! MonthHeader
        header.title.text = monthFormatter.string(from: date)
        
        
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
        
        if cellState.dateBelongsTo == .thisMonth {
            cell.isHidden = false
        } else {
            //hide it
            cell.isHidden = true
        }
        
        print(cellState.text)
        
        handleCellConfiguration(cell: cell, cellState: cellState)
        return cell
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
//        handleCellConfiguration(cell: cell, cellState: cellState)
        
        
        //first date was selected before, so lets pick a second date
        if firstDate != nil && secondDate == nil {
            secondDate = date
            calendarView.selectDates(from: firstDate!, to: date,  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
        } else if firstDate != nil {
            //there is a date range selected, lets start a new range
            calendarView.deselectAllDates()
            firstDate = date
            calendarView.selectDates([date], triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: false)
            secondDate = nil
        } else {
            //nothing has been chosen, let's pick the first date
            firstDate = date
        }
        
        print("--->", firstDate)
        print("--->", secondDate)
        
        handleCellSelection(view: cell, cellState: cellState)
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
//        handleCellConfiguration(cell: cell, cellState: cellState)
        handleCellSelection(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
    
    
    
}
