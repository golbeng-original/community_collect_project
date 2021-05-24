오늘의 유머
==========
URL : [http://www.todayhumor.co.kr/](http://www.todayhumor.co.kr/)

**특이사항**
<br>
- 댓글 가져오는 부분이 ajax처리가 되어있어서 특별한 처리를 해야한다.<br>
- url 형식 : 'http://www.todayhumor.co.kr/board/ajax_memo_list.php?parent_table={table}&parent_id={postId}&get_all_memo=Y'


메뉴 목록
--------
> http://www.todayhumor.co.kr/board/list.php
- 페이지 이동
    - page=x

- 메뉴 종류
0. 베스트오브베스트 : table=bestofbest
1. 베스트 : table=humorbest
1. 유머자료 : table=humordata
2. 좋은글 : table=lovestory
3. 시사 : table=sisa
4. 경제 : table=economy
5. 사회면 : table=society
6. 자유게시판 : table=freeboard
7. 과학 : table=science
8. 철학 : table=phil
9. 심리학 : table=psy
10. 예술 : table=art
11. 법 : table=law
12. 의료 : table=medical
13. 역사 : table=history
14. 패션 : table=fashion
15. 뷰티 : table=beauty
16. 인테리어 : table=interior
17. DIY : table=diy
18. 애니메이션 : table=animation
19. 만화 : table=comics
20. 포니 : table=pony
21. 자랑 : table=boast
22. 멘붕 : table=menbung
23. 사이다 : table=soda
24. 꿈 : table=dream
25. 똥 : table=poop
26. 군대 : table=military
27. 밀리터리 : table=military2
28. 책 : table=readers
29. 여행 : table=travel
30. 해외직구 : table=overseabuy
31. 이민 : table=emigration
32. 영화 : table=movie
33. 국내드라마 : table=drama
34. 외국드라마 : table=mid
35. 연예 : table=star
36. 음악 : table=music
37. 음악찾기 : table=findmusic
38. 악기 : table=instrument
39. 음향기기 : table=sound
40. 공포 : table=panic
41. 미스터리 : table=mystery
42. 오유그림판 : table=oekaki
43. 사진 : table=deca
44. 카메라 : table=camera
45. 지식인 : table=jisik
46. 취업정보 : table=jobinfo
47. 컴퓨터 : table=computer
48. IT : table=it
49. 프로그래머 : table=programmer
50. 고민 : table=gomin
51. 연애 : table=love
52. 결혼생활 : table=wedlock
53. 육아 : table=baby
54. 다이어트 : table=diet
55. 동물 : table=animal
56. 식물 : table=plant
57. 요리 : table=cook
58. 커피&차 : table=coffee
59. 자동차 : table=car
60. 바이크 : table=motorcycle
61. 자전거 : table=bicycle2
62. 장난감 : table=toy
63. 낚시 : tal_fishing.php
64. 스마트폰 : table=smartphone
65. 애플 : table=iphone
66. 예능 : table=tvent
67. 스포츠 : table=sports
68. 야구 : table=baseball
69. 축구 : table=soccer
70. 농구 : table=basketball
71. 바둑 : table=baduk
72. 플래시게임방 : table=gameroom
73. 게임토론방 : table=gametalk
74. 엑스박스 : table=xbox
75. 플레이스테이션 : table=ps
76. 닌텐도 : table=nintendo
77. 모바일게임 : table=mobilegame
78. 스타크래프트 : table=starcraft
79. 스타크래프트2 : table=starcraft2
80. 와우 : table=wow
81. 디아블로2 : table=diablo2
82. 디아블로3 : table=diablo3
83. 던전앤파이터 : table=dungeon
84. 마비노기 : table=mabinogi
85. 마비노기영웅전 : table=mabi
86. 마인크래프트 : table=minecraft
87. 사이퍼즈 : table=cyphers
88. 리그오브레전드 : table=lol
89. 블레이드앤소울 : table=bns
90. 월드오브탱크 : table=wtank
91. GTA5 : table=gta5
92. 하스스톤 : table=hstone
93. 검은사막 : table=blacksand
94. 히어로즈 오브 더 스톰 : table=heroes
95. 메이플스토리1 : table=maple1
96. 오버워치 : table=overwatch
97. 포켓몬고 : table=pokemongo
98. 파이널판타지14 : table=ffantasy14
99. 배틀그라운드 : table=battlegrnd

게시글 리스트 Html구조 정리
```html
<div class="whole_box">
    <div class="vertical_container cf">
        <div class="table_container">
            <table class="table_list">
                <tbody>
                    <tr class="view list_tr_humordata" mn="([0-9]+)">
                        <td class="no">
                            <a href="게시글 링크">
                                게시글 넘버
                            </a>
                        </td>
                        <td class="icon">
                            <a>게시글 타입 아이콘</a>
                        </td>
                        <td class="subject">
                            <a href="게시글 링크">
                                게시글 제목
                                <span class="list_memo_count_span">
                                [댓글 갯수]
                                </span>
                                <span>
                                    <img src="관련 아이콘" />
                                    <img src="관련 추가 아이콘" />
                                </span>
                            </a>
                        </td>
                        <td class="name">
                            <a href="해당 유저 작성 게시글 리시트 주소">
                                닉네임
                            </a>
                        </td>
                        <td class="date">
                            작성 날짜
                        </td>
                        <td class="hits">
                            조회 수
                        </td>
                        <td class="oknok">
                            좋아요 수
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>
```

-----
게시글
-----
Url 구조
> http://www.todayhumor.co.kr/board/view.php?table=humorbest&no=1651464

게시글 유저 정보Html 구조 정리
```html
<div class="writerInfoContainer">
    <div class="writerInfoContents">
        <div>게시물ID</div>
        <div>
            <font><b>닉네임</b></font>
        </div>
        <div>
            <span class="view_ok_nook">추천수</span>
        </div>
        <div>
            조회수 : X
        </div>
        <div></div>
        <div>댓글 : 0개</div>
        <div>등록시간 : 2021/04/12 00:55:55</div>
        <div>
            <span id="short_url_span">게시글 주소</span>
        </div>
    </div>
</div>
```

게시글 Html 구조 정리
```html
<div class="contentContainer">
    <div class="viewContent">
        Html 구조로 내용이 작성 되어 있다.
        <!-- Video 태그 잘 구분 필요-->
        <!-- iframe 태그 잘 구분 필요-->
    </div>
</div>
```


게시글 댓글 Html 구조 정리
```html
<div id="memoContainerDiv">
    <!-- 1단 댓글-->
    <div class="memoWrapperDiv" id="memoWrapper([0-9]+)">
        <div class="memoDiv">
            <div class="memoInfoDiv">
                <img class="memoMemberIcon" src="닉네임 Icon 경로" />
                <span class="memoName">
                    <a>닉네임</a>
                </span>
                <span class="memoDate">(작성 시간)</span>
                <span class="memoAnonymousname">닉네임</span>
                <span class="memoOkNok">추천 ([0-9]+)</span>
            </div>
            <div class="memoContent">
                Html 구조로 내용 작성
            </div>
        </div>
        <!-- 2단 댓글 -->
        <div class="memoWrapperDiv rereMemoWrapperDiv">
            <div class="memoDiv rereMemoDiv">
                <div class="memoInfoDiv">
                    <span class="memoAnonymousname">닉네임</span>
                    <span class="memoDate">(작성 시간)</span>
                    <span class="memoAnonymousname">닉네임</span>
                    <span class="memoOkNok">추천 ([0-9]+)</span>
                </div>
                <div class="memoContent">
                    Html 구조로 작성
                </div>
            </div>
        </div>
    </div>
</div>
```