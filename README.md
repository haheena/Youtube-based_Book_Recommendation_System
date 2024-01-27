# 유튜브 시청기록 기반 도서 추천 시스템 <br/> (Youtube-based_Book_Recommendation_System) <hr/> 

## 💻 프로젝트 소개

**활용 데이터**: YES24 및 유튜브 크롤링, 문화빅데이터 플랫폼 인기 대출 데이터, 빅카인즈 분야 별 뉴스 기사    
**도서 추천 대상** : 서울도서관 인기 대출 정보, 성균관대학교 핫북, 이달의 신간  ※ 확장 가능

**데이터 출처**: 문화빅데이터플랫폼, 빅카인즈, Yes24, Youtube API, 성균관대학교 도서관, 서울 열린데이터 광장, 대한출판문화협회

<hr/> 

# 🔍 분석 흐름 및 알고리즘 개요

## 1. Preprocessing & EDA

### 고객군 클러스터링 
초기 데이터를 확인 결과, 문학의 대출 비율이 모든 연령 및 성별에서 높음을 확인함. 두드러지는 대출 도서를 찾기 위해 전체 이용자의 분야별 대출 비율로 나눈 뒤 K-means 클러스터링 적용  
![image](https://github.com/Kim-Bogeun/Youtube-based_Book_Recommendation_System/assets/127417159/0dcc671c-f139-4f78-a79f-05dd6950547d)


### 사회 이슈 추출 
TF-IDF 변형식 사용 - 분야별 공통적으로 등장하는 키워드는 우선순위가 내려가고 특정 분야에서 자주 등장하는 키워드는 우선순위가 올라가도록 함


## 2. Video Analysis & Keyword Extraction (영상 분석 & 키워드 추출)

### 유튜브 키워드 추출
1. 오락성 영상(음악 플레이리스트, 스포츠 영상 등) 에 대해서는 유의미한 정보가 추출될 수 없다고 판단, 특정 리스트에 대해 영상 분석 대상에서 제외
2. Youtube API를 통한 영상 자막 크롤링, 자막에서 **TextRank Algorithm**을 이용해 주요 키워드 추출
3. **KR-SBert** 모델을 사용한 유사도 계산을 이용해 제목과 연관성 분석 및 Score 계산, 상위 8개 Score에 대해 영상의 대표 키워드로 판단

### 유튜브 영상 KDC 할당 
1. 수집한 도서 설명 데이터를 이용해 KDC별 토픽들을 **Labeled-LDA** 모델에 학습 (아래는 학습 결과)
![image](https://github.com/Kim-Bogeun/Youtube-based_Book_Recommendation_System/assets/127417159/e8440d4c-af5e-46c9-9b14-c29d4766442a)
2. 유튜브에서 추출한 키워드를 대상으로 inference 수행, 영상의 키워드가 어느 토픽(분류)에서 나타나는 토픽인지 표현 가능


## 3. Recommendation System (추천 시스템)  
시청 기록 입력 - 유튜브로부터 키워드 추출 및 KDC 분야별 선호 분포 형성   
협업 필터링: Bayesian 관점 적용, 분포 조정 및 최종 분포 형성   
최종 분포 & 키워드 유사도 키반 도서 추천 진행   

3. 사회 이슈 추출
4. 영상 키워드 추출 및 유사도 계산
5. (2),(3),(4)를 활용한 최종 분포 형성
6. 도서 추천
