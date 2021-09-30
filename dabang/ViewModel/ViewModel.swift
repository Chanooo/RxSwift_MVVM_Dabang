//
//  ViewModel.swift
//  dabang
//
//  Created by CNOO on 2021/09/30.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel {
    let bag = DisposeBag()
    let LIMIT_CNT = 12
    
    // 필터 기본 값
    var filter: Filter = Filter(
        roomTypes: [.원룸, .투쓰리룸, .오피스텔, .아파트],
        sellingTypes: [.월세, .전세, .매매],
        orderAsc: true,
        startIndex: 0
    )
    
    var avgModel: AverageModel?
    var isLoading: Bool = true
    
    struct Input {
        let filterAction: Observable<Bool>
        let roomTypeFilterButtons: [FilterButton]!
        let sellingTypeFilterButtons: [FilterButton]!
        let orderFilterButton: FilterButton!
    }
    
    private var models: [RoomModel] = []
    private var sections: [RoomSection] = []
    private let modelsSectionRelay = PublishRelay<[RoomSection]?>()
    struct Output {
        let modelsDriver: Driver<[RoomSection]?> // Main Thread에서 작업되는 것을 보장하기 위해 Driver로 설정
    }
    
    
    func transform(inputOb: Input) -> Output {
        
        // fetch
        inputOb.filterAction
            .map{[unowned self] isRefresh in
                self.filter.startIndex = isRefresh ? 0
                    : self.filter.startIndex + self.LIMIT_CNT
                
                return self.filter
            }
            .bind(onNext: filterRooms)
            .disposed(by: bag)
        
        
        // RoomType 필터 버튼
        var roomTypeFilterObs: [Observable<ControlEvent<Void>.Element>] = []
        inputOb.roomTypeFilterButtons.forEach { button in
            let roomTypeFilterOb = button.rx.tap
                .do(onNext: { _ in
                    if button.on {
                        if inputOb.roomTypeFilterButtons.filter({$0.on}).count == 1 { // 현재 한개만 선택된 경우
                            return
                        }
                        self.filter.removeRoomType(type: button.tag)
                    } else {
                        self.filter.addRoomType(type: button.tag)
                    }
                    button.on.toggle()
                }).asObservable().share()
            
            roomTypeFilterObs.append(roomTypeFilterOb)
        }
        
        // SellingType 필터 버튼
        var sellingTypeFilterObs: [Observable<ControlEvent<Void>.Element>] = []
        inputOb.sellingTypeFilterButtons.forEach { button in
            let sellingTypeFilterOb = button.rx.tap
                .do(onNext: { _ in
                    if button.on {
                        if inputOb.sellingTypeFilterButtons.filter({$0.on}).count == 1 { // 현재 한개만 선택된 경우
                            return
                        }
                        self.filter.removeSellingType(type: button.tag)
                    } else {
                        self.filter.addSellingType(type: button.tag)
                    }
                    button.on.toggle()
                }).asObservable().share()
            
            sellingTypeFilterObs.append(sellingTypeFilterOb)
        }
        
        // 정렬순서 필터 버튼
        let orderFilterOb = inputOb.orderFilterButton.rx.tap
            .do(onNext: {_ in
                inputOb.orderFilterButton.on.toggle()
                self.filter.orderAsc = inputOb.orderFilterButton.on
            }).asObservable().share()
        
        
        // 필터버튼 바인딩
        Observable.merge(roomTypeFilterObs + sellingTypeFilterObs + [orderFilterOb])
            .do(onNext: {_ in
                FeedbackGenerator().impact()
                self.filter.startIndex = 0
            })
            .map{ _ in self.filter }
            .bind(onNext: filterRooms)
            .disposed(by: bag)
        
        
        let outputOb = Output(
            modelsDriver: modelsSectionRelay.asDriver(onErrorJustReturn: nil)
        )
        
        return outputOb
    }
    
    
    // MARK: Busniss Logic
    private func filterRooms(filter: Filter) {
        
        if let model = loadData(filter: filter) {
            
            // 마지막 로드인 경우
            var endIndex = filter.startIndex+LIMIT_CNT
            if model.count < endIndex {
                endIndex = model.count
                isLoading = true
            }
            
            // 이미 전체 다 로드했을 때
            if model.count <= filter.startIndex {
                isLoading = true
                return
            }
            
            let rooms = model[filter.startIndex..<endIndex]
            if filter.startIndex == 0 {
                models.removeAll()
            }
            models += Array(rooms)
            models.append(RoomModel()) // 페이지 끝단에는 평균가 셀 추가
            if sections.count == 0 {
                sections.append(RoomSection(items: models))
            } else {
                sections[0].items = models
            }
            modelsSectionRelay.accept(sections)
        }
    }
    
    private func loadData(filter: Filter) -> [RoomModel]? {
        if let path = Bundle.main.path(forResource: "RoomListData", ofType: "txt"),
           let json = try? String(contentsOfFile: path, encoding: .utf8),
           let data = json.data(using: .utf8),
           let model = try? JSONDecoder().decode(Model.self, from: data)
        {
            avgModel = model.average.first!
            return model.rooms.filter({
                filter.roomTypes.contains(RoomType(rawValue: $0.roomType)!) &&
                filter.sellingTypes.contains(SellingType(rawValue: $0.sellingType)!)
            }).sorted(by: {
                if filter.orderAsc {
                    return $0.priceTitle.priceToInt() < $1.priceTitle.priceToInt()
                } else {
                    return $0.priceTitle.priceToInt() > $1.priceTitle.priceToInt()
                }
            })
            
        } else {
            print("‼️ 데이터를 불러오지 못했습니다.")
            return nil
        }
    }
}
