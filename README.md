# 유튜브 시청기록 기반 도서 추천 시스템 <br/> (Youtube-based_Book_Recommendation_System)

## 📌 개요

### 배경

대한민국 전체 인구 중 80% 이상이 유튜브를 이용하고, 인당 월평균 32.9시간 유튜브를 시청하는 것으로 나타남. 이는 다른 어플리케이션과 비교하였을 때 매우 높음.
또한 스마트폰 과의존에 대한 증가로 나타나는 집중력 감소라는 사회적 문제에, 독서가 하나의 해답이 될 수 있을 것임
→ **유튜브의 알고리즘의 원리에 착안하여 도서를 추천**해보자!
→ `유튜브 시청기록 기반 도서 추천 시스템`

또한 **Cold Start** 문제를 교차 도메인으로 해결 가능한데, 도서 추천을 진행할 때 알지 못하는 유저의 도서 선호를 유튜브 시청 기록을 통해 예측할 수 있을 것임

### 분석과정

1. 데이터 수집
2. 클러스터링을 통해 분야 선호 클러스터 형성
3. 사회 이슈 추출
4. 영상 키워드 추출 및 유사도 계산
5. (2),(3),(4)를 활용한 최종 분포 형성
6. 도서 추천


## 💻 프로젝트 소개

**활용 데이터**: YES24 및 유튜브 크롤링, 문화빅데이터 플랫폼 인기 대출 데이터, 빅카인즈 분야 별 뉴스 기사    
**도서 추천 대상** : 서울도서관 인기 대출 정보, 성균관대학교 핫북, 이달의 신간  ※ 확장 가능

**데이터 출처**: 문화빅데이터플랫폼, 빅카인즈, Yes24, Youtube API, 성균관대학교 도서관, 서울 열린데이터 광장, 대한출판문화협회

