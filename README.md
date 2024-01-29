# 유튜브 시청기록 기반 도서 추천 시스템 <br/> (Youtube-based_Book_Recommendation_System)
## 📌 개요

### 배경

대한민국 전체 인구 중 80% 이상이 유튜브를 이용하고, 인당 월평균 32.9시간 유튜브를 시청하는 것으로 나타남. 이는 다른 어플리케이션과 비교하였을 때 매우 높음. <br/>
또한 스마트폰 과의존에 대한 증가로 나타나는 집중력 감소라는 사회적 문제에, 독서가 하나의 해답이 될 수 있을 것임 

→ **유튜브의 알고리즘의 원리에 착안하여 도서를 추천**해보자! 

→ `유튜브 시청기록 기반 도서 추천 시스템` 

또한 **Cold Start** 문제를 교차 도메인으로 해결 가능한데, 도서 추천을 진행할 때 알지 못하는 유저의 도서 선호를 유튜브 시청 기록을 통해 예측할 수 있을 것임
<br/>
<br/>

### 💡 분석과정

1. 데이터 수집
2. 클러스터링을 통해 분야 선호 클러스터 형성
3. 사회 이슈 추출
4. 영상 키워드 추출 및 유사도 계산
5. (2),(3),(4)를 활용한 최종 분포 형성
6. 도서 추천
<br/>

## 📌 데이터 수집 및 전처리

- **활용 데이터**: YES24 및 유튜브 크롤링, 문화빅데이터 플랫폼 인기 대출 데이터, 빅카인즈 분야 별 뉴스 기사
- **도서 추천 대상** : 서울도서관 인기 대출 정보, 성균관대학교 핫북, 이달의 신간 ※ 확장 가능
- **데이터 출처**: 문화빅데이터플랫폼, 빅카인즈, Yes24, Youtube API, 성균관대학교 도서관, 서울 열린데이터 광장, 대한출판문화협회

- **크롤링**
1. 책의 고유값인 ISBN을 이용하여 YES24 책의 저자, 제목, 소개 등 정보 수집
2. 유튜브 링크를 이용하여 개별 영상에 접근 후 제목, 해시태그, 자막 정보 수집
<br/>

## 📌 클러스터링

** 국립중앙도서관 성별-연령대별 인기 대출 도서 정보 데이터 이용
<br/>

`분야 선호 클러스터` 형성 결정! <br/>
→ 단순하게 데이터를 그대로 사용하여 연령, 성별로 사용자를 구분한다면 선호 분야 예측에 있어서 오류 발생 가능성이 존재함 <br/>
→ 분야 선호 클러스터를 통해 사용자를 분류한다면, **사용자와 비슷한 성향을 가진 사람들의 선호를 반영**할 수 있을 것!<br/>
<br/>

**💫 클러스터링 과정**

- 데이터 전처리
    - KDC명을 총류, 철학, .. , 역사로 값 변경
    - 분석 기간 열에서 중복 집계를 제외하기 위해 90일인 경우만 사용
    - KDC명 열에서 **총류**(너무 기타분류)와 **언어**(토익 등 언어시험 위주)는 특성 확인 후 유의미한 추천이 힘들 것이라 생각해 **제외**
    - 연령대 열에 있는 ‘**영유아’, ‘유아’**는 유튜브를 잘 시청하지 않는 연령대이고 대출 도서 특성 확인 후 추천 모델의 대상과 적합하지 않다고 판단해 **제외**
- EDA 과정
    - 문학 대출 비율이 대부분의 연령대에서 높음<br/>
    → 문학 장서 수 자체가 많기 때문<br/>
    → 두드러지는 대출 도서를 찾기 위해 : (연령, 성별 기준 분야별 대출 비율)/(전체 이용자의 분야별 대출 비율)로 클러스터링 진행<br/>
    → 문학의 비율이 줄어들어서 전체 분류가 고르게 됨<br/>
    - 유아의 경우 종교 분류의 비율이 높음<br/>
    → 그리스로마신화 이슈임을 파악
- 클러스터링
    
    ✅ 최종 군집 개수 **K=3**으로 클러스터링 진행 ! (K-means) <br/>
    ✅ K-medoids와 계층적은 k-means와 결과가 동일하고, DBSCAN, GMM은 데이터의 특성상 적절하지 않아서 클러스터링 결과가 타당하다고 판단함<br/>
    <br/>

**☑️ 클러스터링 결과** <br/>
→ 각 클러스터에 속하는 고객군의 대출 비율의 평균을 구해서 시각화

- 클러스터 1 : 종교, 역사 분야 선호 <석가모니형>
- 클러스터 2 : 철학, 사회과학, 예술 분야 선호 <소크라테스형>
- 클러스터 3 : 기술과학, 자연과학 분야 선호 <맥가이버형>
<br/><br/>

## 📌 사회 이슈 추출

** 이슈 추출 배경 : 필터 버블<br/>
→ **확증 편향**(관심있는 정보만을 받게되어 편향성이 강화됨)<br/>
→ **유튜브 또한 필터 버블 현상이 존재**하기 때문에 **우리의 유튜브 기반 도서 추천 또한 필터 버블이 발생**할 수 있음<br/>
→ 도서 추천 시 **`사회 이슈`** 를 활용하여 **필터 버블 현상 완화**<br/>
<br/>

**💫 이슈 추출 과정**

1️⃣ 정치, 경제, 사회, 국제, 스포츠, IT_과학 분야의 전체 기사 본문 키워드 바탕으로 추출한 상위 50개의 단순 빈도로 워드 클라우드 생성<br/>
→ ⚠️ 유의미한 사회적 이슈 혹은 특징보다는 보편적으로 많이 나오는 단어들이 단순 나열되는 문제 발생<br/>
→ 이슈를 담은 키워드는 하나의 분야에 밀집하여 나오지 않을까!라는 생각으로 **기사의 분야(섹션)를 하나의 문서로 보고 `TF-IDF` 아이디어** 적용<br/>

- ❓ **TF-IDF**
    
    단어의 빈도와 문서의 빈도를 사용하여 단어마다 중요한 정도에 따라 가중치를 부여하는 방법으로, 모든 문서에 등장하는 단어는 중요도가 낮고, 특정 문서에만 등장하는 단어는 중요도가 높다는 것
  
  <p align="center"><img src="https://github.com/Youjin-Seo/Youtube-based_Book_Recommendation_System/assets/89994770/15b1b06b-5f7a-4e55-bfe1-68f89f0f83c0"  width="80%" height="80%"/></p>
  <p align="center">
    수식 ▲
<br/>

2️⃣ 이미 특성 추출 및 WordCount, 필터링이 진행된 데이터였기 때문에 식을 그대로 적용하기는 부적절하다고 판단하여 Score식을 custom 함

![image](https://github.com/Youjin-Seo/Youtube-based_Book_Recommendation_System/assets/89994770/edfeac5b-1adc-40c4-a96f-d7e6302abe32) |![image](https://github.com/Youjin-Seo/Youtube-based_Book_Recommendation_System/assets/89994770/2f0f54b5-32f2-4358-a75e-33282af9e1b2)
--- | --- |

**score가 높을수록 해당 분야의 이슈를 대표**한다고 판단 → 워드클라우드 생성

![image](https://github.com/Youjin-Seo/Youtube-based_Book_Recommendation_System/assets/89994770/8e97d094-0efd-40c5-a99b-c26fe737863f)

