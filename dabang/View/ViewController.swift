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
    private let filterAction = PublishRelay<Filter>()
    private let viewModel = ViewModel()
    private var bag = DisposeBag()
    
    // MARK: LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindView()
        bindViewModel()
        
        // 초기 세팅으로 로드
        filterAction.accept(viewModel.filter)
    }
    
    // MARK: Setup View
    private func setupView() {
        roomTypeFilterButtons.forEach{$0.on = true}
        sellingTypeFilterButtons.forEach{$0.on = true}
        orderFilterButton.on = true
    }
    
    // MARK: Bind View
    private func bindView() {
        tableView.rx
            .setDelegate(self)
            .disposed(by: bag)
        
        // 새로고침 버튼
        refreshButton.rx.tap
            .map{[weak self] _ in
                FeedbackGenerator().impact()
                self?.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                self?.viewModel.filter.startIndex = 0
                return (self?.viewModel.filter)!
            }
            .bind(to: filterAction)
            .disposed(by: bag)
        
        // RoomType 필터 버튼
        var roomTypeFilterObs: [Observable<ControlEvent<Void>.Element>] = []
        roomTypeFilterButtons.forEach { button in
            let roomTypeFilterOb = button.rx.tap
                .do(onNext: { _ in
                    if button.on {
                        if self.roomTypeFilterButtons.filter({$0.on}).count == 1 { // 현재 한개만 선택된 경우
                            return
                        }
                        self.viewModel.filter.removeRoomType(type: button.tag)
                    } else {
                        self.viewModel.filter.addRoomType(type: button.tag)
                    }
                    button.on.toggle()
                }).asObservable().share()
            
            roomTypeFilterObs.append(roomTypeFilterOb)
        }
        
        // SellingType 필터 버튼
        var sellingTypeFilterObs: [Observable<ControlEvent<Void>.Element>] = []
        sellingTypeFilterButtons.forEach { button in
            let sellingTypeFilterOb = button.rx.tap
                .do(onNext: { _ in
                    if button.on {
                        if self.sellingTypeFilterButtons.filter({$0.on}).count == 1 { // 현재 한개만 선택된 경우
                            return
                        }
                        self.viewModel.filter.removeSellingType(type: button.tag)
                    } else {
                        self.viewModel.filter.addSellingType(type: button.tag)
                    }
                    button.on.toggle()
                }).asObservable().share()
            
            sellingTypeFilterObs.append(sellingTypeFilterOb)
        }
        
        // 정렬순서 필터 버튼
        let orderFilterOb = orderFilterButton.rx.tap
            .do(onNext: {_ in
                self.orderFilterButton.on.toggle()
                self.viewModel.filter.orderAsc = self.orderFilterButton.on
            }).asObservable().share()
        
        
        // 필터버튼 바인딩
        Observable.merge(roomTypeFilterObs + sellingTypeFilterObs + [orderFilterOb])
            .do(onNext: {_ in
                self.viewModel.filter.startIndex = 0
                FeedbackGenerator().impact()
            })
            .map{ _ in self.viewModel.filter }
            .bind(to: filterAction)
            .disposed(by: bag)
    }
    
    // MARK: Bind View Model
    private func bindViewModel() {
        let inputOb = ViewModel.Input(
            filterAction: filterAction.asObservable()
        )
        
        let output = viewModel.transform(inputOb: inputOb)
        let dataSource = RxTableViewSectionedReloadDataSource<RoomSection>(
            configureCell: {[weak self] dataSource, tableView, indexPath, item in
                if item.desc == "average" {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "AverageCell", for: indexPath) as! AverageCell
                    if let avg = self?.viewModel.avgModel {
                        // avg UI
                    }
                    return cell
                } else {
                    let cell: RoomCell
                    if item.roomType < 2 { // 원룸 쓰리룸
                        cell = tableView.dequeueReusableCell(withIdentifier: "RoomCell", for: indexPath) as! RoomCell
                    } else {
                        cell = tableView.dequeueReusableCell(withIdentifier: "RoomCellReverse", for: indexPath) as! RoomCell
                    }
                    
                    cell.titleLabel.text = item.priceTitle
                    item.desc
                    item.imgUrl
//                self.setTableViewUI(row: indexPath.row, model: item, cell: cell)
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
            })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)
    }
    
    
    // MARK: - Scroll Delegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - 100 - scrollView.frame.size.height), !viewModel.isLoading {
            viewModel.isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5, execute: {
                self.viewModel.filter.startIndex += self.viewModel.LIMIT_CNT
                self.filterAction.accept(self.viewModel.filter)
            })
        }
    }

}

