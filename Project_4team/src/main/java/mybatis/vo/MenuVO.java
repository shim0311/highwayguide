package mybatis.vo;

import java.util.Objects;

public class MenuVO {
    private int Idx, SAKey;
    private String FoodName, Price, Season, //계절메뉴 - "4" : 비계절, "S" : 여름, "W" : 겨울
            Recommend, Best, Premium; //음식구분("N", "Y" 플래그로 구분함)

    public int getIdx() {
        return Idx;
    }

    public void setIdx(int idx) {
        Idx = idx;
    }

    public int getSAKey() {
        return SAKey;
    }

    public void setSAKey(int SAKey) {
        this.SAKey = SAKey;
    }

    public String getFoodName() {
        return FoodName;
    }

    public void setFoodName(String foodName) {
        FoodName = foodName;
    }

    public String getPrice() {
        return Price;
    }

    public void setPrice(String price) {
        Price = price;
    }

    public String getSeason() {
        return Season;
    }

    public void setSeason(String season) {
        Season = season;
    }

    public String getRecommend() {
        return Recommend;
    }

    public void setRecommend(String recommend) {
        Recommend = recommend;
    }

    public String getBest() {
        return Best;
    }

    public void setBest(String best) {
        Best = best;
    }

    public String getPremium() {
        return Premium;
    }

    public void setPremium(String premium) {
        Premium = premium;
    }

    @Override
    public boolean equals(Object obj) {
        if(this == obj) return true;
        if (obj == null || getClass() != obj.getClass())
            return false;
        MenuVO menuVO = (MenuVO) obj;
        return Objects.equals(this.Price, menuVO.Price) &&
                Objects.equals(this.Recommend, menuVO.Recommend) &&
                Objects.equals(this.Best, menuVO.Best) &&
                Objects.equals(this.Premium, menuVO.Premium) &&
                Objects.equals(this.Season, menuVO.Season);
    }
    @Override
    public int hashCode() {
        return Objects.hash(this.Season, this.Price, this.Recommend, this.Best, this.Premium);
    }
}