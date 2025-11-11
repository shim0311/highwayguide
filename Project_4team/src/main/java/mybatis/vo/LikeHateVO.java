package mybatis.vo;

public class LikeHateVO {
    private int Idx, UserKey, PostNum, ThumbsUp, ThumbsDown;

    public int getIdx() {
        return Idx;
    }

    public void setIdx(int idx) {
        Idx = idx;
    }

    public int getUserKey() {
        return UserKey;
    }

    public void setUserKey(int userKey) {
        UserKey = userKey;
    }

    public int getPostNum() {
        return PostNum;
    }

    public void setPostNum(int postNum) {
        PostNum = postNum;
    }

    public int getThumbsUp() {
        return ThumbsUp;
    }

    public void setThumbsUp(int thumbsUp) {
        ThumbsUp = thumbsUp;
    }

    public int getThumbsDown() {
        return ThumbsDown;
    }

    public void setThumbsDown(int thumbsDown) {
        ThumbsDown = thumbsDown;
    }
}
