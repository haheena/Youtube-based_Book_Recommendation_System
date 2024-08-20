

setwd("경로 입력")

library(dplyr)
library(rvest)
library(tidyr)
library(stringr)
library(writexl)
library(readxl)

crawldf <- read_excel("전처리된도서자료.xlsx")
crawldf$Descript <- ""
Stack <- NULL

##########
# 크롤링 #
##########

df <- crawldf[230001:235170, ]

for(i in 1:5170){
  ISBN <- df$국제표준도서번호[i]
  check <- "Init"
  URL <- str_c("https://www.yes24.com/Product/Search?domain=ALL&query=" , ISBN)
  
  res <- read_html(URL)
  
  # 링크 추출, html정보 얻기
  pattern <- "#yesSchList .gd_name"
  link <- res %>% 
    html_nodes(pattern) %>% 
    html_attr("href") %>% 
    head(1) %>%
    str_c("https://www.yes24.com", .)
  
  
  link
  if (length(link) == 0) {
    description <- "No Description"
    check <- "No Book"
  }
  
  # 책 소개
  if(check != "No Book"){
    res2 <- read_html(link)
    pattern <- "#infoset_introduce .infoWrap_txtInner"
    description <- res2 %>% 
      html_nodes(pattern) %>% 
      html_text() %>% 
      tail(1) %>%
      gsub("\r\n", " ", .) %>% 
      gsub("\\s+", " ", .)
    
    description
    
    if (length(description) == 0) {
      description <- "No Description"
    }
  }
  print(i)
  
  # 결과값 df에 넣기
  df[i, 'Descript'] <- description
}

#기존 Stack에 df rbind
Stack <- rbind(Stack, df)

#엑셀 생성
writexl::write_xlsx(Stack, "예스24크롤링_14.xlsx")


#생성한 엑셀 파일 하나로 합치기
for (i in 1:3){
  #모으기
  stacked <- read_excel("크롤링모으기.xlsx")
  file_str <- paste0("크롤링_",i,".xlsx")
  forstack <- read_excel(file_str)
  
  
  # 데이터프레임으로 저장
  moamoa <- as.data.frame(stacked)
  df2 <- as.data.frame(forstack)
  dim(moamoa)
  
  # 크롤링 안된부분 제거
  df2 <- df2[!(df2$Descript) == "No Description",]
  dim(df2)
  
  
  moamoa <- rbind(stacked, df2)
  writexl::write_xlsx(moamoa, "크롤링모으기.xlsx")
}

