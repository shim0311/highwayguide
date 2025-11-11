package bbs.util;

public class Paging {
    int nowPage = 1; //현재페이지 == cPage
    int numPerPage = 10; // 한 페이지당 표현할 게시물 수

    //페이징을 위한 변수
    int totalCount; // 총 게시물의 수

    int pagePerBlock = 5; // 한 블럭당 표현할 페이지 수
    int totalPage; // 총 페이지 수

    int begin; // 현재 페이지 값에 따라 bbs_t 테이블에서 가져올 게시물의 시작 행번호(rnum)
    int end; // 현재 페이지 값에 따라 bbs_t 테이블에서 가져올 게시물의 마지막 행번호(rnum)

    int startPage; // 한 블럭의 시작페이지 값
    int endPage; // 한 블럭의 마지막페이지 값

    //생성시 한페이지에 표현할 게시물의 수와 한 블럭당 표현할 페이지 수를 받아서 생성함
    public Paging(int numPerPage, int pagePerBlock){
        this.numPerPage = numPerPage;
        this.pagePerBlock = pagePerBlock;
    }

    public int getNowPage() {
        return nowPage;
    }

    public void setNowPage(int nowPage) {
        this.nowPage = nowPage;

        // 현재 페이지 값이 총 페이지 수를 넘지 못하도록 하자!
        if(nowPage > totalPage)
            nowPage = totalPage;

        //각 페이지의 시작 행번호(begin)과 마지막 행번호(end)를 구한다.
        // 예) 현재페이지: 1, being:1, end: 10
        // 예) 현재페이지: 2, being:11, end: 20
        // 예) 현재페이지: 3, being:21, end: 30
        begin = (nowPage - 1) * numPerPage+1;
        end = nowPage * numPerPage;

        //현재페이지 값에 따라 블럭의 시작페이지(startPage)구하자
        startPage = (int)((nowPage - 1)/pagePerBlock)*pagePerBlock+1; //소수점 표현안됨

        //한 블럭의 마지막 페이지 값
        endPage = startPage + pagePerBlock - 1;

        // 위에서 구한 마지막 페이지가 총 페이지 값을 넘어갈때가 빈번하게 생긴다.
        if(endPage > totalPage) //마지막 페이지값은 총 페이지 수를 넘을 수 없다.
            endPage = totalPage;
    }

    public int getNumPerPage() {
        return numPerPage;
    }

    public void setNumPerPage(int numPerPage) {
        this.numPerPage = numPerPage;
    }

    public int getTotalCount() {
        return totalCount;
    }

    public void setTotalCount(int totalCount) {
        this.totalCount = totalCount;
        this.totalPage = (int)Math.ceil((double)totalCount/numPerPage);/*pagePerBlock*/
    }

    public int getPagePerBlock() {
        return pagePerBlock;
    }

    public void setPagePerBlock(int pagePerBlock) {
        this.pagePerBlock = pagePerBlock;
    }

    public int getTotalPage() {
        return totalPage;
    }

    public void setTotalPage(int totalPage) {
        this.totalPage = totalPage;
    }

    public int getBegin() {
        return begin;
    }

    public void setBegin(int begin) {
        this.begin = begin;
    }

    public int getEnd() {
        return end;
    }

    public void setEnd(int end) {
        this.end = end;
    }

    public int getStartPage() {
        return startPage;
    }

    public void setStartPage(int startPage) {
        this.startPage = startPage;
    }

    public int getEndPage() {
        return endPage;
    }

    public void setEndPage(int endPage) {
        this.endPage = endPage;
    }
}
