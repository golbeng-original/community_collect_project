웃긴대학 사진 게시판
===============
URL : [http://web.humoruniv.com/](http://web.humoruniv.com)

**특이사항**<br>
쿠키 관리를 해야 한다.

**알아야 할 사항**<br>
페이지 Url 같은 경우는 웃긴대학 Get 기본 동작으로..
<br>
<br>

4칸 사진 메뉴 목록
--------------
- 패션 : [http://web.humoruniv.com/board/humor/list.html?table=fashion](http://web.humoruniv.com/board/humor/list.html?table=fashion)
- 얼굴 인식 : [http://web.humoruniv.com/board/humor/list.html?table=face](http://web.humoruniv.com/board/humor/list.html?table=face)
- 사진 : [http://web.humoruniv.com/board/humor/list.html?table=photo](http://web.humoruniv.com/board/humor/list.html?table=photo)
- 요리 : [http://web.humoruniv.com/board/humor/list.html?table=cook](http://web.humoruniv.com/board/humor/list.html?table=cook)
- 대기 제목 : [http://web.humoruniv.com/board/humor/list.html?table=titlewait](http://web.humoruniv.com/board/humor/list.html?table=titlewait)


게시글 리스트 Html구조 정리
```html
<div id="wrap_mdd">
    <div id="wrap_cnts">
        <div id="cnts_list_new">
            <div>
                <table>
                    <tbody>
                        <tr>
                            <!-- td 칸씩 존재-->
                            <td>
                                <div id="item">
                                    <a href="body Url">
                                        <img id="thumb_img" src="img Url" />
                                    </a>
                                    <div class="w_text">
                                        <!---->
                                        <span class="w_subject">
                                            <a href="body Url">
                                                <span id="w_subject_6981">제목</span>
                                                <span class="list_comment_num">[댓글 수]</span>
                                            </a>
                                        </span>
                                        <!---->
                                        <table>
                                            <tbody>
                                                <tr>
                                                    <td>
                                                        <img class="hu_icon" src="img Url">
                                                    </td>
                                                    <td>
                                                    </td>
                                                    <td>
                                                        <span class="w_nick">
                                                            <span>
                                                                <span class="hu_nick_txt">닉네임</span>
                                                            </span>
                                                            <span class="w_date">2021-06-01</span>
                                                            <span class="w_time">00:02</span>
                                                        </span>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                        <!---->
                                        <span class="w_extra">
                                            <span class="o">
                                                <img>
                                                좋아요 수
                                            </span>
                                            <span>
                                                <img>
                                                조회 수
                                            </span>
                                        </span>
                                    </div>
                                </div>
                            </td>
                            <!-- td 칸씩 존재-->
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
```

게시글 Html 구조 정리
```html
<div id="fashion">
    <table>
        <tbody>
            <tr>
                <td>
                    <div id="fashion_file">
                        <!-- Html 구조로.. 이부분을 쓰자-->
                    </div>
                </td>
            </tr>
        </tbody>
        Html 구조로 내용이 작성 되어 있다.
        <!-- Video 태그 잘 구분 필요-->
        <!-- iframe 태그 잘 구분 필요-->
    </table>
</div>
<form>
</form>
<div id="wrap_body">
</div>
```

2칸 사진 메뉴 목록
--------------
- 그림낙서 : [http://web.humoruniv.com/board/humor/list.html?table=picture](http://web.humoruniv.com/board/humor/list.html?table=picture)

게시글 리스트 Html구조 정리
```html
<div id="cnts_list_new">
    <div>
        <!-- 또는 gnk2-->
        <div class="gnk">
            <div class="hd">
                <p class="num">PosId</p>
                <p class="sbj">
                    <a href="bodyUrl">
                        제목
                        <span class="list_comment_num">
                            [댓글 수]
                        </span>
                    </a>
                    
                </p>
            </div>
            <div class="gnk_bd">
                <a href="body Url">
                    <img src="Thumbnail 주소">
                </a>
            </div>
            <div class="gnk_info">
                <table>
                    <tbody>
                        <tr>
                            <td>
                                <img class="hu_icon" src="닉네임 Icon Url">
                            </td>
                            <td class="al_l">
                                <span>
                                    <span class="hu_nick_txt">닉네임</span>
                                </span>
                            </td>
                            <td>
                            </td>
                            <td>
                                <span class="o">추천수</span>
                            </td>
                            <td class="al_l g6_11">
                            </td>
                            <td class="al_l g6_11">
                                반대 수
                            </td>
                        </tr>
                        <tr>
                            <td class="al_l g6_11">
                            </td>
                            <td class="al_l g6_11">
                                2021-05-31 [22:02]
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
        <!--반복-->
    </div>
    <!--반복-->
</div>
```

게시글 Html 구조 정리
```html
<warp_copy id="warp_copy">
    <table>
        <tbody>
            <tr>
                <table>
                    <tbody>
                        <tr>
                            <td>
                                <img name="hu_img1" src="낙서 Url">
                            </td>
                        </tr>
                    </tbody>
                </table>
            </tr>
        </tbody>
    </table>
</warp_copy>
```

1칸 메뉴 리스트 (내용 댓글)
--------------
- 웃긴 제목 : [http://web.humoruniv.com/board/humor/list.html?table=funtitle](http://web.humoruniv.com/board/humor/list.html?table=funtitle)

게시글 리스트 Html구조 정리
```html
<div id="cnts_list_new">
    <div>
        <div id="item">
            <table>
                <tbody>
                    <!-- tr이 5개가 한 묶음-->
                    <!--1-->
                    <tr>
                        <td class="pd10">
                            <table>
                                <tbody>
                                    <!---->
                                    <tr>
                                        
                                        <td>
                                            <span class="w_subject">
                                                <a href="Body Url">
                                                    "제목"
                                                    <span class="list_re_num">(댓글 수)</span>
                                                    <span class="list_comment_num">[답글 수]</span>
                                                </a>
                                            </span>
                                        </td>
                                        <td>
                                            <table>
                                                <tbody>
                                                    <tr>
                                                        <td>
                                                            <table>
                                                                <tbody>
                                                                    <tr>
                                                                        <td>
                                                                            <img class="hu_icon" src="닉네임 아이콘 Url">
                                                                        </td>
                                                                        <td>
                                                                            <span>
                                                                                <span class="hu_nick_txt">
                                                                                    닉네임
                                                                                </span>
                                                                            </span>
                                                                        </td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </td>
                                    </tr>
                                    <!---->
                                    <tr>
                                        <td>
                                            <span class="w_extra">
                                                <span class="o">추천 12</span>
                                                <span>반대 0</span>
                                                <span>답변 2</span>
                                                <span>답글 3</span>
                                                <span>조회 122</span>
                                            </span>
                                        </td>
                                        <td>
                                            <span class="w_date">2021-06-01</span>
                                            <span class="w_time">15:50</span>
                                        </td>
                                    </tr>
                                    <!---->
                                    <tr>
                                        <td>
                                            글 내용
                                        </td>
                                    </tr>
                                    <!---->
                                </tbody>
                            </table>
                        </td>
                    </tr>
                    <!--2-->
                    <tr>
                        <td>
                            <a href="Body Url">
                                <table>
                                    <tbody>
                                        <tr>
                                            <td>
                                                <div id="comment_file_file_[0-9]+_[0-9]+">
                                                    <a href="Body Img Url">
                                                        <div class="comment_img_div">
                                                            <img src="Body Img Url">
                                                        </div>
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </a>
                        </td>
                    </tr>
                    <!--3-->
                    <tr>
                        <!-- 우수 답변-->
                        <td>
                            <div>
                                우수 답변
                            </div>
                        </td>
                    </tr>
                    <!--4-->
                    <tr>
                        <td>
                            <table>
                                <tbody>
                                    <tr>
                                        <td>
                                            <table>
                                                <tbody>
                                                    <tr>
                                                        <td>
                                                            <img class="hu_icon" src="우수 답변 닉네임 아이콘 Url"> 
                                                        </td>
                                                        <td>
                                                            <span>
                                                                <span class="hu_nick_txt">
                                                                    우수 답변 닉네임
                                                                </span>
                                                            </span>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </td>
                                        <td>
                                            <span>
                                            </span>
                                            <span id="and_ok_div_[0-9]+">
                                                추천 수
                                            </span>
                                            <span>
                                                반대 0
                                            </span>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </td>
                    </tr>
                    <!--5-->
                    <tr>
                        <!--기타 답변들..-->
                    </tr>
                    <!---->
                    <!---->
                    <!-- 한 칸 뛰우기 용-->
                    <tr></tr>
                    <!-- -->
                </tbody>
            </table>
        </div>
    </div>
</div>
```


대기 제목 & 웃긴제목 댓글 Html 구조 정리
```html
<!-- 우수 답변 -->
<div id="wrap_answer_best">
    <div class="cnt">
        <dl class="w_info">
            <dd class="icn">
                <img class="hu_icon" src="닉네임 url">
            </dd>
            <dd class="id">
                <span>
                    <span class="hu_nick_txt">닉네임</span>
                </span>
            </dd>
            <dd class="date">
                2021-05-31 [14:21]
            </dd>
            <dd class="und">
                반대 : 0
            </dd>
            <dd class="und">
                <span class="r">
                    추천 수
                </span>
            </dd>
        </dl>
        <!-- 이 구간은 댓글 내용-->
        <p>
            내용
        </p>
        <!-- 이 구간은 댓글 내용-->
    </div>
</div>
<!-- 기타 답변 -->
<div id="warp_answer_etc">
</div>
```