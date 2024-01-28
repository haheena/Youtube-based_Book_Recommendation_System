# 유튜브 시청기록 기반 도서 추천 시스템 <br/> (Youtube-based_Book_Recommendation_System)
## 📌 개요

### 배경

대한민국 전체 인구 중 80% 이상이 유튜브를 이용하고, 인당 월평균 32.9시간 유튜브를 시청하는 것으로 나타남. 이는 다른 어플리케이션과 비교하였을 때 매우 높음. 
또한 스마트폰 과의존에 대한 증가로 나타나는 집중력 감소라는 사회적 문제에, 독서가 하나의 해답이 될 수 있을 것임 

→ **유튜브의 알고리즘의 원리에 착안하여 도서를 추천**해보자! 

→ `유튜브 시청기록 기반 도서 추천 시스템` 

또한 **Cold Start** 문제를 교차 도메인으로 해결 가능한데, 도서 추천을 진행할 때 알지 못하는 유저의 도서 선호를 유튜브 시청 기록을 통해 예측할 수 있을 것임

### 💡 분석과정

1. 데이터 수집
2. 클러스터링을 통해 분야 선호 클러스터 형성
3. 사회 이슈 추출
4. 영상 키워드 추출 및 유사도 계산
5. (2),(3),(4)를 활용한 최종 분포 형성
6. 도서 추천

   
## 📌 데이터 수집 및 전처리

- **활용 데이터**: YES24 및 유튜브 크롤링, 문화빅데이터 플랫폼 인기 대출 데이터, 빅카인즈 분야 별 뉴스 기사
- **도서 추천 대상** : 서울도서관 인기 대출 정보, 성균관대학교 핫북, 이달의 신간 ※ 확장 가능
- **데이터 출처**: 문화빅데이터플랫폼, 빅카인즈, Yes24, Youtube API, 성균관대학교 도서관, 서울 열린데이터 광장, 대한출판문화협회

- **크롤링**
1. 책의 고유값인 ISBN을 이용하여 YES24 책의 저자, 제목, 소개 등 정보 수집
2. 유튜브 링크를 이용하여 개별 영상에 접근 후 제목, 해시태그, 자막 정보 수집

## 📌 클러스터링

** 국립중앙도서관 성별-연령대별 인기 대출 도서 정보 데이터 이용

`분야 선호 클러스터` 형성 결정!

→ 단순하게 데이터를 그대로 사용하여 연령, 성별로 사용자를 구분한다면 선호 분야 예측에 있어서 오류 발생 가능성이 존재함

→ 분야 선호 클러스터를 통해 사용자를 분류한다면, **사용자와 비슷한 성향을 가진 사람들의 선호를 반영**할 수 있을 것!


**💫 클러스터링 과정**

- 데이터 전처리
    - KDC명을 총류, 철학, .. , 역사로 값 변경
    - 분석 기간 열에서 중복 집계를 제외하기 위해 90일인 경우만 사용
    - KDC명 열에서 **총류**(너무 기타분류)와 **언어**(토익 등 언어시험 위주)는 특성 확인 후 유의미한 추천이 힘들 것이라 생각해 **제외**
    - 연령대 열에 있는 ‘**영유아’, ‘유아’**는 유튜브를 잘 시청하지 않는 연령대이고 대출 도서 특성 확인 후 추천 모델의 대상과 적합하지 않다고 판단해 **제외**
- EDA 과정
    - 문학 대출 비율이 대부분의 연령대에서 높음
    → 문학 장서 수 자체가 많기 때문
    → 두드러지는 대출 도서를 찾기 위해 : (연령, 성별 기준 분야별 대출 비율)/(전체 이용자의 분야별 대출 비율)로 클러스터링 진행
    → 문학의 비율이 줄어들어서 전체 분류가 고르게 됨
    - 유아의 경우 종교 분류의 비율이 높음
    → 그리스로마신화 이슈임을 파악
- 클러스터링
    
    ✅ 최종 군집 개수 **K=3**으로 클러스터링 진행 ! (K-means)
  
    ✅ K-medoids와 계층적은 k-means와 결과가 동일하고, DBSCAN, GMM은 데이터의 특성상 적절하지 않아서 클러스터링 결과가 타당하다고 판단함
    

☑️ 클러스터링 결과

→ 각 클러스터에 속하는 고객군의 대출 비율의 평균을 구해서 시각화

- 클러스터 1 : 종교, 역사 분야 선호 <석가모니형>
- 클러스터 2 : 철학, 사회과학, 예술 분야 선호 <소크라테스형>
- 클러스터 3 : 기술과학, 자연과학 분야 선호 <맥가이버형>


