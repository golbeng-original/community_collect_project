웃긴 대학
========
URL : [http://web.humoruniv.com/](http://web.humoruniv.com)

**특이사항**
- 게시글 형식 리스트
- 웃긴 제목 형식 리스트
- 대기 제목 형식 리스트
- 그림낙서 형식 리스트 
- 탭 형식 리스트 
- 게시판 별로 '오늘의 베스트', '주간 베스트', '월간 베스트' 가 존재 한다.

메뉴 목록
--------
>http://web.humoruniv.com/board/humor/list.html
- 페이지 이동 (&)
  - pg=0~

- 메뉴 종류
1. 게시글 형식 리스트
    - 인기 자료 : table=pick
    - 웃긴 자료 : table=pds
        - 오늘의 베스트 : table=pds&st=day
        - 주간 베스트 : table=pds&st=week
        - 월간 베스트 : table=pds&st=month
        - 추천수 많은 글 : table=pds&st=better
    - 대기 자료 : table=pdswait
        - 오늘의 베스트 : table=pdswait&st=day
        - 주간 베스트 : table=pdswait&st=week
        - 월간 베스트 : table=pdswait&st=month
    - 창작/예술
      - 공포 : table=fear
      - 사진 : table=photo (4칸 그림 테이블)
      - 그림 낙서 : table=picture (2칸 그림 테이블)
      - 웃긴 유머 : table=guest
      - 웃대 문학 : table=novel
      - 따뜻한글 : table=mild
    
    - 웃대툰 : table=art_toon
    - 신예툰 : table=nova_toon
    - 패션 : table=fashion (4칸 그림 테이블)
    - 얼굴인식 : table=face (4칸 그림 테이블 + 탭 형식)
    - 테마게시판
        - 게임 : table=game
        - 만화 : table=thema2
        - LOL : table=lol 
        - 요리 : table=cook (4칸 그림 테이블)
        - 헬스 : table=health
        - 스포츠 : table=pride
        - 음악 : table=muzik
        - 영화 : table=thema3
        - 동물대학 : table=animaluniv
        - 컴퓨터 : table=com
        - 무협판타지 : table=moofama
        - 직장 : table=workshop
        - 솔로 : table=solo
        - 직장 : table=workshop
        - 염장 : table=love
        - 초자연현상 : table=spnatural
        - 자동차 : table=car
        - SNS : table=sns
        - 고민 : table=dump
        - 추억 : table=memory
        - 프로그래밍 : table=program
        - 공감 : table=sympathy
        - 휴대폰 : table=phone
        - 군대 : table=army
        - 월드컵 : table=worldcup
        - 사랑이야기 : table=wlove
        - 솔로부대 : table=wsolo
        - 여대왁자지껄 : table=wfree

2. 웃긴 제목 형식 리스트 (1칸 그림 테이블)
    - 웃긴 제목 : table=funtitle
        - 오늘의 베스트 : table=funtitle&st=day
        - 주간 베스트 : table=funtitle&st=week
        - 월간 베스트 : table=funtitle&st=month
        - 연간 베스트 : table=funtitle&st=year
        - 추천수 많은 글 : table=funtitle&st=better

3. 대기 제목 형식 리스트 (4칸 그림 테이블)
    - 대기 제목 : table=titlewait
       - 오늘의 베스트 : table=titlewait&st=day
      - 주간 베스트 : table=titlewait&st=week
      - 월간 베스트 : table=titlewait&st=month

4. 웹소설
    > http://web.humoruniv.com/cr/cr_list.html


게시글 리스트 Html구조 정리
```html
<!-- 리스트 메뉴 시작 div-->
<div id="cnts_list_new">
    <table id="post_list">
        <tbody>
            <tr id="li_chk_pds-([0-9]+)">
                <!-- 썸네일-->
                <td class="li_num">
                    <div>
                        <a href="게시글 url">
                            <!-- 게시글 썸네일 -->
                            <img src="Thumnail 주소"/>
                        </a>
                    </div>
                </td>
                <!-- 게시글 제목-->
                <td class="li_sbj">
                    <a href="">
                        "게시글 제목"
                        <span class="list_comment_num">[댓글 수]</span>
                        <span>답글 추천 +195</span>
                    </a>
                </td>
                <!-- 유저 정보-->
                <td class="li_icn">
                    <table>
                        <tbody>
                            <tr>
                                <td>
                                    <img class="hu_icon" src="유저 아이콘">
                                </td>
                                <td>
                                    <span>
                                        <span class="hu_nick_txt">
                                            <span>닉네임</span>
                                            <img src="닉네임 아이콘"/>
                                        </span>
                                    </span>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </td>
                <!-- 등록일 -->
                <td class="li_date">
                    <span class="w_date">2021-04-09</span>
                    <span class="w_time">01:50</span>
                </td>
                <!-- 조회 수-->
                <td class="li_und">
                    2,303
                </td>
                <!-- 추천 수-->
                <td class="li_und">
                    <span class="o">
                    34
                    </span>
                </td>
                <!-- 반대 수-->
                <td clas="li_und">
                    <font>
                    0
                    </font>
                </td>
            </tr>
        </tbody>
    </table>
</div>
```

-----
게시글
-----
Url 구조
> http://web.humoruniv.com/board/humor/read.html?table=pds&pg=0&number=1053969

게시글 유저 정보Html 구조 정리
```html
<div id="wrap_cnts">
    <table>
        <tbody>
            <tr>
                <!-- 아바타 영역 -->
                <td>
                    <div id="wrap_ctgr_new">
                        <div id="wrap_winfo">
                            <table id="profile_table">
                                <tbody>
                                    <tr>
                                        <td>
                                            <div class="avt">
                                                <iframe src="http://avatar.humoruniv.com/avatar/avatar_2.php?user=%C0%AF%B5%B5%C8%F1o" width="140" height="115">
                                                    #document
                                                    <table background="아바타 주소">
                                                </iframe>
                                            </div>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </td>
                <!-- 게시글 영역-->
                <td>
                    <!-- 제목 영역-->
                    <tr>
                        <td class="info">
                        </td>
                    </tr>
                    <!-- 글쓴이 영역-->
                    <tr>
                        <td clas="info">
                            <img class="hu_icon" src="닉네임 아이콘">
                            <span>
                                <span class="hu_nick_txt">닉네임</span>
                            </span>
                        </td>
                    </tr>
                    <!-- 게시글 상태 영역-->
                    <tr>
                        <td class="info">
                            <div id="content_info">
                                <span>게시글 번호</span>
                                <span>출처 타입</span>
                                <span id="ok_div">추천 수</span>
                                <span id="not_ok_span">반대 수</span>
                                <span class="re">댓글 수</span>
                                <span>조회 수</span>
                                <div id="if_date">
                                    글 작성 시간
                                </div>
                            </div>
                        <td>
                    </tr>
                </td>
            </tr>
        </tbody>
    </table>
</div>
```


게시글 Html 구조 정리
```html
<div id="wrap_cnts">
    <div id="cnts">
        <warp_copy id="wrap_copy">
            <!-- case1. table일 경우-->
            <!--게시물 이미지, 동영상 들어갈 테이블 시작)-->
            <!-- table 갯수만큼..-->
            <table>
                <tbody>
                    <tr>
                        <td>
                            <div id="comment_file_file_([0-9]_+)">
                                <!-- case 1.1. 단순 이미지 일 경우-->
                                <a href="이미지 주소">
                                    <div class="comment_img_div">
                                        <img src="이미지 주소">
                                    </div>
                                </a>
                                <!-- case 1.2. 영상일 경우(gif)-->
                                <!-- 이미지 주소 해석-->
                                <!--
                                javascript:comment_mp4_expand('file_13990935_544604345', 'http://gimg.humoruniv.com/mp4/b6/b6bd36c46b45e23e24a1b22e376b99ebb863a98d.mp4', 'http://timg.humoruniv.com/thumb_crop_resize.php?url=http://down.humoruniv.com/hwiparambbs/data/pds/a_w49479e001_b6bd36c46b45e23e24a1b22e376b99ebb863a98d.gif?SIZE=320x432?WEBP', '320', '519', '', 'GIF', '0.4MB', 'http://down.humoruniv.com/hwiparambbs/data/pds/a_w49479e001_b6bd36c46b45e23e24a1b22e376b99ebb863a98d.gif', '13.3MB');
                                -->
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
            <!-- case2. div 일 경우-->
            <!-- div 갯수만큼..-->
            <div id="warp_img">
                <a href="이미지 주소">
                    <img id="hu_f_img" src="이미지 주소">
                </a>
            </div>
            <!-- 없을 경우도 있다.-->

            <!--게시물 본문 들어갈 테이블 시작-->
            <div id="wrap_body">
                <div class="body_editor">
                    <!-- 이미지 첨부 -->
                    <div class="simple_attach_img_div">
                        <a href="">
                            <img src="이미지 주소">
                        </a>
                    </div>
                    <!-- 텍스트 작성-->
                    <div class="simple_attach_img_div">
                        텍스트 내용
                    </div>
                    <!-- 동영상 첨부-->
                    <div class="simple_attach_img_div">
                        <table>
                            <tr>
                                <td>
                                    <div id="comment_file_editor_file_1_172159405">
                                        <div class="comment_img_div">
                                            <a href=""></a>
                                <!--
                                javascript:comment_mp4_expand('file_13990935_544604345', 'http://gimg.humoruniv.com/mp4/b6/b6bd36c46b45e23e24a1b22e376b99ebb863a98d.mp4', 'http://timg.humoruniv.com/thumb_crop_resize.php?url=http://down.humoruniv.com/hwiparambbs/data/pds/a_w49479e001_b6bd36c46b45e23e24a1b22e376b99ebb863a98d.gif?SIZE=320x432?WEBP', '320', '519', '', 'GIF', '0.4MB', 'http://down.humoruniv.com/hwiparambbs/data/pds/a_w49479e001_b6bd36c46b45e23e24a1b22e376b99ebb863a98d.gif', '13.3MB');
                                -->
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <!-- Html 형식 이미지 리스트-->
                    <p>
                        <a class="img_load_m"></a>
                        <a>
                            <img src="이미지 경로">
                        </a>
                    </p>
                </div>
            </div>
        </warp_copy>
    </div>
</div>
```

게시글 댓글 Html 구조 정리
```html
<div id="wrap_cnts">
    <div id="cnts">
        <!--  답글베스트 2015-07-01 -->
        <div id="cmt_wrap_box" class="comm_best_area">
            <table id="cmt_best_comm_table">
                <tbody>
                    <tr>
                        <td>답글 베스트X</td>
                        <td>
                            <div class="id_line">
                                <img class="hu_icon" src="아이콘 주소"/>
                            </div>
                            <div class="id_line_t">
                                <span class="best_id">
                                    <span>
                                        <span class="hu_nick_txt">
                                            아이디
                                        </span>
                                    </span>
                                </span>
                            </div>
                        </td>
                        <td>
                            <!-- 이미지 첨부 공간-->
                            <table>
                                <tbody>
                                    <tr>
                                        <td>
                                            <div id="comment_file_comment_file_([0-9+)]">
                                                <!-- 이미지 일 경우-->
                                                <a herf="이미지 주소">
                                                    <div class="comment_img_div">
                                                        <img src="이미지 주소" width="100%" height="" style="max-width:870px" />
                                                    </div>
                                                </a>
                                                <!-- 영상일 경우-->
                                                <div class="comment_img_div">
                                                    <video id="video_mp4_cmoment_file_([0-9]+)">
                                                        <source src="동영상 주소" type="video/mp4">
                                                    </video>
                                                </div>
                                            </div>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                            <!-- 텍스트 공간-->
                            <div id="list_best_box_text">
                                <span class="cmt_text">
                                    댓글 내용
                                </span>
                            </div>
                        </td>
                        <td>
                            <span class="r" id="top_comm_ok_div_([0-9]+)">추천 수</span>
                            <span class="list_no">반대 수</span>
                        </td>
                        <td>
                            <span class="list_date">
                                댓글 저장 시간
                            </span>
                        </td>
                    </tr>
                    <!-- padding line-->
                    <tr></tr>
                </tbody>
            </table>
        </div>
        <!--일반답글 시작-->
        <div id="wrap_cmt_new">
            <div id="cmt_wrap_box" class="cmt_area">
                <table>
                    <tbody>
                        <!--1단 답글-->
                        <tr id="comment_span_([0-9]+)">
                            <td>
                                <img src="아이콘"/>
                            </td>
                            <td>
                                <span>
                                    <span class="hu_nick_txt">
                                        <span>닉네임</span>
                                        <img src="닉네임 icon src" width="10" height="12" />
                                    </span>
                                </span>
                            </td>
                            <td>
                                <div id="list_best_box_text">
                                    <span>
                                        댓글
                                    </span>
                                </div>
                            </td>
                            <td>
                                <span>
                                    <span id="comm_ok_div_([0-9]+)">추천 수</span>
                                    <span class="list_no">반대 수</span>
                                </span>
                            </td>
                            <td>
                                <span class="list_date">
                                    날짜
                                    <bfri,>시간</brfi,>
                                </span>
                            </td>
                        </tr>
                        <!--2단 답글-->
                        <tr id="comment_span_([0-9]+)">
                            <td>
                                <div>
                                    <img src="-> re 이미지" width="25" height="13" />
                                </div>
                            </td>
                            <td>
                                <div>
                                    <img src="닉네임 아이콘">
                                </div>
                                <div>
                                    <span>
                                        <span class="hu_nick_txt">닉네임</span>
                                    </span>
                                </div>
                            </td>
                            <td>
                                <div id="list_best_box_text">
                                    <span>
                                        댓글
                                    </span>
                                </div>
                            </td>
                            <td>
                                <span>
                                    <span id="comm_ok_div_([0-9]+)">추천 수</span>
                                    <span class="list_no">반대 수</span>
                                </span>
                            </td>
                            <td>
                                <span class="list_date">
                                    날짜
                                    <bsat,>시간</bsaf,>
                                </span>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
```