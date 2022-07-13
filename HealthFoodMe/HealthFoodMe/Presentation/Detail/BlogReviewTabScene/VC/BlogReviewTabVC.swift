//
//  BlogReviewTabVC.swift
//  HealthFoodMe
//
//  Created by 강윤서 on 2022/07/13.
//

import UIKit

class BlogReviewTabVC: UIViewController {
    
    private var reviewHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainGreen
        
        return view
    }()

    private lazy var blogReviewCV: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        layout.sectionInset = .zero
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsVerticalScrollIndicator = false
        
        cv.backgroundColor = .mainRed
        
        return cv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setLayout()
    }
}

extension BlogReviewTabVC {
    private func setDelegate() {
        
    }
    
    private func setLayout() {
        view.addSubviews(reviewHeaderView, blogReviewCV)
        
        reviewHeaderView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).inset(18)
            make.centerX.equalToSuperview()
            make.width.equalTo(226)
            make.height.equalTo(40)
        }
        
        blogReviewCV.snp.makeConstraints { make in
            make.top.equalTo(reviewHeaderView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
}
