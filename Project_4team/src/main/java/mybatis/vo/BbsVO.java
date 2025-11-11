package mybatis.vo;

public class BbsVO {
    private String PostNum, SAKey, Subject, WriteDate, Writer,
            Content, ModDate, FileName, Category, ThumbsUp,
            ThumbsDown, Delete, LogIn, Pwd;

    public String getPostNum() {
        return PostNum;
    }

    public void setPostNum(String postNum) {
        PostNum = postNum;
    }

    public String getSAKey() {
        return SAKey;
    }

    public void setSAKey(String SAKey) {
        this.SAKey = SAKey;
    }

    public String getSubject() {
        return Subject;
    }

    public void setSubject(String subject) {
        Subject = subject;
    }

    public String getWriteDate() {
        return WriteDate;
    }

    public void setWriteDate(String writeDate) {
        WriteDate = writeDate;
    }

    public String getWriter() {
        return Writer;
    }

    public void setWriter(String writer) {
        Writer = writer;
    }

    public String getContent() {
        return Content;
    }

    public void setContent(String content) {
        Content = content;
    }

    public String getModDate() {
        return ModDate;
    }

    public void setModDate(String modDate) {
        ModDate = modDate;
    }

    public String getFileName() {
        return FileName;
    }

    public void setFileName(String fileName) {
        FileName = fileName;
    }

    public String getCategory() {
        return Category;
    }

    public void setCategory(String category) {
        Category = category;
    }

    public String getThumbsUp() {
        return ThumbsUp;
    }

    public void setThumbsUp(String thumbsUp) {
        ThumbsUp = thumbsUp;
    }

    public String getThumbsDown() {
        return ThumbsDown;
    }

    public void setThumbsDown(String thumbsDown) {
        ThumbsDown = thumbsDown;
    }

    public String getDelete() {
        return Delete;
    }

    public void setDelete(String delete) {
        Delete = delete;
    }

    public String getLogIn() {
        return LogIn;
    }

    public void setLogIn(String logIn) {
        LogIn = logIn;
    }

    public String getPwd() {
        return Pwd;
    }

    public void setPwd(String pwd) {
        Pwd = pwd;
    }
}
