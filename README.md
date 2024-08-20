# 유튜브 시청기록 기반 도서 추천 시스템 <br/> (Youtube-based_Book_Recommendation_System)

## 📌 개요

### 배경
**분석 배경**

스마트폰 과의존으로 인한 전 연령대의 집중력 감소와 문해력 부족이라는 사회적 문제가 존재하며, 대한민국 전체 인구 중 80% 이상이 월 평균 32.9시간 유튜브를 시청 <br/>
KOSIS 국민도서 실태조사에 따르면 모든 연령층 및 성별에 무관하게 독서량 추이가 지속적으로 감소하고 있음

**분석 목표**

유튜브의 알고리즘 원리에 착안하여 도서를 추천하여 전 연령대에서 저조한 독서율을 높이기 위함

<br/>
<br/>

### 💡 전체적인 분석과정

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
    ▲ 수식
<br/>

2️⃣ 이미 특성 추출 및 WordCount, 필터링이 진행된 데이터였기 때문에 식을 그대로 적용하기는 부적절하다고 판단하여 Score식을 custom 함


<img src="https://github.com/Youjin-Seo/Youtube-based_Book_Recommendation_System/assets/89994770/b2c29d0e-94f1-450a-97cb-9e7a13cd4c6a" width="50%" height="50%"><img src="https://github.com/Youjin-Seo/Youtube-based_Book_Recommendation_System/assets/89994770/1fb59e93-47cc-4549-9c23-e29e1934fb42" width="50%" height="50%">

**score가 높을수록 해당 분야의 이슈를 대표**한다고 판단 → 워드클라우드 생성

  <p align="center"><img src="https://github.com/Youjin-Seo/Youtube-based_Book_Recommendation_System/assets/89994770/8e97d094-0efd-40c5-a99b-c26fe737863f"  width="80%" height="80%"/></p>
<br/>
<br/>

## 📌 유튜브 영상 키워드 추출

유튜브 **자막이 우리의 스크립트**가 되는데, 요약하고자 하는 스크립트가 어떤 도메인인지 알 수 없는 상황! (즉, 학습 데이터의 부재)<br/>
→ 비지도 학습인 `TextRank 알고리즘` 사용<br/>
<br/>

- ❓ **TextRank**
    
    먼저, `PageRank`란 특정 페이지를 인용하는 다른 페이지가 얼마나 있는지를 정규화하여 세는 방법<br/>
    영향력 있는(PageRank가 높은) 페이지에게서 인용될수록 중요도가 올라감,<br/>
    다른 많은 페이지를 인용한 페이지에게서 인용되었다면 인용된 페이지가 차지하는 비중이 낮아짐
    
    `TextRank`란, PageRank 알고리즘을 응용하여, 문서 내 문장 또는 단어의 Ranking을 계산하는 알고리즘<br/>
<br/>    

**💫 TextRank 알고리즘을 적용한 키워드 추출 과정**

1️⃣ 텍스트 스크립트 크롤링 및 전처리<br/>

유튜브 제공 api를 이용해서 자막 크롤링.<br/>
문서를 문장 단위로 분리 후, 형태소 토큰화. 이후 품사 태깅을 통해 어근과 명사만 추출

2️⃣ 단어 간 가중치 그래프 생성

3️⃣ TextRank 알고리즘 적용

4️⃣ 결과 확인

<p align="center"><img src = "https://github.com/Youjin-Seo/Youtube-based_Book_Recommendation_System/assets/89994770/40bd6d4d-2618-4546-8399-c66f1acfdf41" width="80%" height="80%"/></p>

전반적으로 핵심 소재가 잘 추출되었지만, 영상의 핵심 내용과는 크게 관련이 없지만 Rank가 높거나, 중요한 소재임에도 Rank가 낮은 경우가 생김<br/>
→ 키워드 추출 개선 필요<br/>
<br/>

### 🔆 **키워드 추출 개선** 🔆

** 유튜브 영상 **제목 활용**

- 브이로그, 먹방, 플레이리스트, 겟레디윗미 등 책 추천과 연결되지 못하는 주제에서는 유의미한 정보가 추출될 수 없다고 판단하여 분석 대상에서 제외
- 정보성 영상의 경우, 제목에 주제를 포함한 정보들이 존재 <br/>
→ text 유사도 계산시 제목과 자막을 모두 활용하고, 제목에 정보를 많이 담고 있기 때문에 가중치 부여<br/>
→ 즉, **KR-SBERT** 모델을 이용하여 **제목과 키워드 간 유사도를 계산**!
- 오락성 영상(게임, 영화, 드라마, 스포츠 등)의 경우 제목이 주제를 반영하지 못함 <br/>
→ 자막에서 추출된 키워드만을 이용해 주제 파악

- ❓ **정보성 영상 vs 오락성 영상**
    
    **특정 단어**가 제목, 해시태그에 존재할 경우 오락성 영상으로 분류
<br/>

1. **정보성 영상**
    
    **KR-SBERT**를 이용하여 제목과 키워드의 유사도 계산<br/>
    🔜 그 결과, 영상의 핵심 내용과는 관련이 없지만 Rank가 높았던 단어들의 유사도는 상대적으로 낮았고, 영상의 핵심 내용과 관련있지만 Rank가 낮았던 단어들의 유사도가 상대적으로 높았음

$$score = similarity^2 * textrank$$

<p align="center">
▲ 최종 score 식

정보성 영상의 경우 제목에 영상에 대한 정보가 더욱 함축적으로 들어가있기 때문에 제목과 키워드 간 유사도에 제곱을 하여 가중치를 줌
<br/>

2. **오락성 영상**
    
    고유명사(ex. 영화 주인공 이름)만 따로 제거하고 키워드 textrank를 그대로 score로 사용<br/>


이렇게 계산된 score를 바탕으로  **`상위 8개 키워드 추출`**<br/>
<br/>

## 📌 토픽 모델링 L-LDA

LLDA를 이용하여 **새로운 유튜브 키워드가 들어왔을 경우 그 키워드가 어느 KDC분류에 대한 정보를 갖고 있는지 분류**하는 모델 생성<br/>
→ 즉, 유튜브 영상과 책을 이어주기 위한 과정!<br/>

🌟 우리가 수집한 책 데이터는 KDC분류를 통해 이미 label이 된 자료이기 때문에 L-LDA를 사용하는 것이 더 효과적! 🌟<br/>
<br/>

- ❓ **L-LDA(Labeled LDA)**
    
    먼저 `LDA`란, Latent Dirichlet Allocation의 줄임말으로, 각 문서는 토픽의 혼합으로 구성되어있으며, 각 토픽에서 확률 분포에 기반하여 단어를 생성한다고 가정. 데이터가 주어지면, LDA는 문서가 생성된 과정을 역추적함.<br/>
    
    `L-LDA`는 여러 개의 주제가 labeled된 문헌들의 집합을 분석하여 주제별 단어 분포를 학습함.<br/>
    
    **LDA**는 사전에 주어진 정보가 따로 없기 때문에 **구별된 각각의 토픽들이 무엇인지 파악하는 것은 사용자의 몫**인 반면, **L-LDA**는 주제와 레이블 간 일대일 매핑을 통해 지도학습을 수행하므로 **각 토픽이 어떤 문서 집합에 대한 토픽인지 해석이 가능**함<br/>

<br/>

**💫 L-LDA 과정**

사용자의 유튜브 키워드 집합을 하나의 문서로 보고, L-LDA를 적용!

1️⃣ **지도학습** <br/>
사전에 수집한 책 소개 데이터 총 24,000개로 학습 진행 (각 KDC분류에서 3000개씩)<br/>

2️⃣ 주제별 단어 분포 확인<br/>

![image](https://github.com/Youjin-Seo/Youtube-based_Book_Recommendation_System/assets/89994770/b0f610f4-33ca-4323-85d8-b4b8663f81e8)

3️⃣ 유튜브 영상 키워드를 이용하여 **1차 선호도 분포 형성** 
![image](https://github.com/Youjin-Seo/Youtube-based_Book_Recommendation_System/assets/89994770/bd22b624-c5d4-491d-bb75-93c12546fe90)

<br/>

## 📌 분포 업데이트 및 최종 분포 형성

클러스터 분포를 반영하지 않고 영상이 하나만 입력되었을 경우, 그 한 영상에 의해서만 분포가 결정되므로 실제 사용자의 선호도 분포라고 단정할 수 없음<br/>
→ `베이지안`의 관점에서 분포를 업데이트 하자!<br/>

이때, 사전에 쌓인 도서 대출의 정보 반영

![image](https://github.com/Youjin-Seo/Youtube-based_Book_Recommendation_System/assets/89994770/a2edee6a-9133-4ff6-b56b-e7e7bc16ce11)


클러스터 분포 : 위 클러스터링 과정에서 나온 3개 클러스터 활용<br/>
유튜브 기록으로부터 얻은 분포 : 위 L-LDA 과정에서의 1차 선호도 분포<br/>
<br/>

**💫 분포 업데이트**

클러스터 분포와 선호도 분포 모두 디리클레 분포를 따르고, 디리클레 분포는 디리클레분포에 대한 Conjugate Prior이므로 효과적으로 분포를 업데이트할 수 있음! <br/>

→ **경험적 베이즈 분석(Empirical Bayes)을 적용하여 사전 분포를 결정**<br/>
<br/>

### 🔆 **최종 분포 형성 과정** 🔆

case) 영상이 2개 입력된 경우<br/>

1. 각 영상에서 키워드 추출
2. L-LDA를 통해 1차 선호도 분포 형성
3. 1차 선호도 분포들의 Likelihood를 계산하여 사전 분포 지정 (위 클러스터 3개 중에 하나로)
4. 사전 분포와 관측을 이용한 분포 업데이트 후 선호도 분포 생성
5. 사회 이슈 키워드로부터 L-LDA 분포를 생성
6. 가중합 (4번 과정 - 선호도 0.7, 5번 과정 - 사회 이슈 0.3)
7. 최종 분포 형성

이후 최종 분포에서 샘플링을 하여 책 추천을 진행~

---

✅ **개선점**

- 영어 자막에 대해서도 키워드 뽑을 수 있도록 하기
- 추천 대상이 되는 책의 범위 확대
- 오락성 영상을 더 확실하게 분류
- Sampling만 진행하는 것이 아니라 유튜브 영상에 맞는 최적의 도서를 추천할 수 있도록 ..


