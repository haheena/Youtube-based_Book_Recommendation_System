# 유튜브 시청기록 기반 도서 추천 시스템 <br/> (Youtube-based_Book_Recommendation_System)

## 📌 개요

**분석 배경**

스마트폰 과의존으로 인한 전 연령대의 집중력 감소와 문해력 부족이라는 사회적 문제가 존재하며, <br/>
대한민국 전체 인구 중 80% 이상이 월 평균 32.9시간 유튜브를 시청 <br/>
KOSIS 국민도서 실태조사에 따르면 모든 연령층 및 성별에 무관하게 독서량 추이가 지속적으로 감소하고 있음

**분석 목표**

유튜브의 알고리즘 원리에 착안하여 도서를 추천하여 전 연령대에서 저조한 독서율을 높이기 위함

<br/>

**💡 전체적인 분석과정**

1. 데이터 수집
2. 클러스터링을 통해 '분야 선호 클러스터' 형성
3. 사회 이슈 추출
4. 유튜브 영상 키워드 추출
5. L-LDA를 이용하여 유튜브 키워드와 KDC의 유사도 계산
6. (2),(3),(4) 과정을 종합하여 분포 업데이트 및 최종 분포 형성
7. 도서 추천
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

**💫 ‘분야 선호 클러스터’ 형성 배경**

성별 및 연령대별로 나눠진 데이터를 그대로 사용하지 않고 사용자와 비슷한 성향을 가진 사람들의 선호를 반영하기 위함
<br/>

**💫 클러스터링 과정**
1. 국립중앙도서관 인기 대출 데이터를 이용하여 데이터 전처리 진행
2. EDA를 통해 문학 대출 비율이 대부분의 연령대에서 높다는 것을 파악한 후 두드러지는 선호 분야를 찾을 수 있도록 ‘총 대출수’ 열의 데이터 단위를 비율로 변형
3. K-means 기법을 이용하여 최종 군집 개수 **K=3**으로 클러스터링 진행
<br/>

**☑️ 클러스터링 결과** <br/>
- 클러스터 1 : 종교, 역사 분야 선호 <석가모니형>
- 클러스터 2 : 철학, 사회과학, 예술 분야 선호 <소크라테스형>
- 클러스터 3 : 기술과학, 자연과학 분야 선호 <맥가이버형>
<br/><br/>

## 📌 사회 이슈 추출

**💫 사회 이슈 추출 배경**

유튜브 기반 도서 추천 시스템은 필터 버블로 인한 확증 편향이 발생할 수 있기 때문에 사회 이슈를 활용하여 **필터 버블 현상 완화**
<br/>

**💫 이슈 추출 과정**

1. 정치, 경제, 사회, 국제, 스포츠, IT_과학 분야 전체 기사의 본문 키워드를 바탕으로, 상위 50개의 키워드를 추출하여 단순 빈도로 워드 클라우드 생성
    
    → 유의미한 사회적 이슈보다는 **보편적**으로 많이 나오는 **단어들이 단순 나열되는 문제**가 발생하여 기사의 분야를 하나의 문서로 보고 **TF-IDF 아이디어 적용**
    
2. 스케일링을 통해 페널티를 완화하여 Score식을 수정 <br/>
3. score가 높은 단어들을 이용해 워드클라우드 생성

  <p align="center"><img src="https://github.com/Youjin-Seo/Youtube-based_Book_Recommendation_System/assets/89994770/8e97d094-0efd-40c5-a99b-c26fe737863f"  width="50%" height="50%"/></p>

그 결과 **사회 이슈를 반영한 단어의 등장 빈도 증가**
<br/>
<br/>

## 📌 유튜브 영상 키워드 추출

요약하고자 하는 스크립트(유튜브 자막)가 어떤 도메인인지 알 수 없는 상황으로 비지도 학습인 **TextRank 알고리즘** 사용

**💫 TextRank 알고리즘을 적용한 키워드 추출 과정**

1. 유튜브 자막 스크립트 크롤링 및 전처리<br/>
2. TextRank 알고리즘 적용
<br/>

✅ **유튜브 키워드 추출 결과**

전반적으로 핵심 소재가 잘 추출됨. <br/>
하지만 영상의 핵심 내용과는 크게 관련이 없지만 Rank가 높거나, 중요한 소재임에도 Rank가 낮은 경우가 생겨 추가적으로 키워드 추출 개선 진행

**💫 유튜브 키워드 추출 개선**

1. 유튜브 영상을 **정보성 영상과 오락성 영상으로 분류**
2. 영상의 종류에 따라 영상 제목을 활용하여 추출 개선
3. 이후 **`상위 8개 키워드 추출`**<br/>
<br/>

## 📌 토픽 모델링 L-LDA

유튜브 키워드가 입력되었을 경우 그 키워드가 어느 KDC분류에 대한 정보를 갖고 있는지 분류하는 모델을 생성하여 유튜브와 책을 이어주는 작업 진행
→ 사용자의 유튜브 키워드 집합을 하나의 문서로 보고, L-LDA 적용 <br/>

**💫 L-LDA 과정**

1. 각 KDC분류에서 3000개씩 총 24,000개의 데이터로 지도학습 진행
2. L-LDA 적용 후 KDC별 단어 분포 확인
![image](https://github.com/Youjin-Seo/Youtube-based_Book_Recommendation_System/assets/89994770/b0f610f4-33ca-4323-85d8-b4b8663f81e8)
3. 유튜브 영상 키워드를 이용하여 1차 선호도 분포 형성
![image](https://github.com/Youjin-Seo/Youtube-based_Book_Recommendation_System/assets/89994770/bd22b624-c5d4-491d-bb75-93c12546fe90)

<br/>

## 📌 분포 업데이트 및 최종 분포 형성

**💫 분포 업데이트**

실제 사용자의 선호도 정보를 반영하기 위해 경험적 베이즈 분석(Empirical Bayes)을 적용하여 사전 분포를 결정한 후 분포 업데이트
<br/>

### 🔆 **최종 분포 형성 과정** 🔆

case) 영상이 2개 입력된 경우<br/>

1. 각 영상에서 키워드 추출
2. L-LDA를 통해 1차 선호도 분포 형성
3. 1차 선호도 분포들의 Likelihood를 계산하여 사전 분포 지정 (’분야 선호 클러스터’ 中 1개)
4. 사전 분포와 관측을 통한 분포 업데이트 후 선호도 분포 생성
5. 사회 이슈 키워드로부터 L-LDA 분포 생성
6. 선호도 0.7, 사회 이슈 0.3의 비율로 분포 가중합
7. 최종 분포 형성


