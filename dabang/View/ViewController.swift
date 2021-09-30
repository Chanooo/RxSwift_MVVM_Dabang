//
//  ViewController.swift
//  dabang
//
//  Created by CNOO on 2021/09/30.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController, UIScrollViewDelegate {

    // MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet var roomTypeFilterButtons: [FilterButton]!
    @IBOutlet var sellingTypeFilterButtons: [FilterButton]!
    @IBOutlet weak var orderFilterButton: FilterButton!
    
    // MARK: ASSERT PARAM
    private let filterAction = PublishRelay<Bool>() // true 이면, 리프레싱 또는 초기로드
    private let viewModel = ViewModel()
    private var bag = DisposeBag()
    
    // MARK: LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindView()
        bindViewModel()
        
        // 초기 세팅으로 로드
        filterAction.accept(true)
    }
    
    // MARK: Setup View
    private func setupView() {
        roomTypeFilterButtons.forEach{$0.on = true}
        sellingTypeFilterButtons.forEach{$0.on = true}
        orderFilterButton.on = true
        
        roomTypeFilterButtons.forEach{$0.setWidth()}
        sellingTypeFilterButtons.forEach{$0.setWidth()}
        orderFilterButton.setWidth()
        
    }
    
    // MARK: Bind View
    private func bindView() {
        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)
        
        // 새로고침 버튼
        refreshButton.rx.tap
            .map{ FeedbackGenerator().impact()
                return true
            }
            .bind(to: filterAction)
            .disposed(by: bag)
    }
    
    // MARK: Bind View Model
    private func bindViewModel() {
        
        let inputOb = ViewModel.Input(
            filterAction: filterAction.asObservable(),
            roomTypeFilterButtons: roomTypeFilterButtons,
            sellingTypeFilterButtons: sellingTypeFilterButtons,
            orderFilterButton: orderFilterButton
        )
        
        let output = viewModel.transform(inputOb: inputOb)
        let dataSource = RxTableViewSectionedReloadDataSource<RoomSection>(
            configureCell: {[weak self] dataSource, tableView, indexPath, item in
                if item.desc == "average" {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AverageCell", for: indexPath) as! AverageCell
                    if let avg = self?.viewModel.avgModel {
                        // avg UI
                        cell.setUI(data: avg)
                    }
                    return cell
                } else {
                    let cell: RoomCell
                    if item.roomType < 2 { // 원룸 쓰리룸
                        cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath) as! RoomCell
                    } else {
                        cell = tableView.dequeueReusableCell(withIdentifier: "RoomCellReverse", for: indexPath) as! RoomCell
                    }
                    cell.setUI(data: item)
                    return cell
                }
            }
        )
        
        output.modelsDriver
            .compactMap{$0}
            .do(onNext: { [weak self] in
                self?.viewModel.isLoading = false
                if let loadCnt = $0.first?.items.filter({$0.desc != "average"}).count {
                    self?.title = "방 \(loadCnt)개 로드 됨"
                }
                if self?.viewModel.filter.startIndex == 0 {
                    self?.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                }
            })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
    
    
    // MARK: - Scroll Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - 100 - scrollView.frame.size.height), !viewModel.isLoading {
            viewModel.isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now()+0.25, execute: {
                self.filterAction.accept(false)
            })
        }
    }

}

