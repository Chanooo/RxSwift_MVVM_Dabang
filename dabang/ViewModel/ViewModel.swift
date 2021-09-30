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
        let filterAction: Observable<Filter>
    }
    
    private var models: [RoomModel] = []
    private var sections: [RoomSection] = []
    private let modelsSectionRelay = PublishRelay<[RoomSection]?>()
    struct Output {
        let modelsDriver: Driver<[RoomSection]?> // Main Thread에서 작업되는 것을 보장하기 위해 Driver로 설정
    }
    
    
    func transform(inputOb: Input) -> Output {
        
        inputOb.filterAction
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
            print(filter)
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
