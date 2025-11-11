package mybatis.vo;

public class GasVO {
    private String SAKey,Gasoline, Disel, LPG;

    public String getLPG() {
        return LPG;
    }

    public void setLPG(String LPG) {
        this.LPG = LPG;
    }

    public String getDisel() {
        return Disel;
    }

    public void setDisel(String disel) {
        Disel = disel;
    }

    public String getGasoline() {
        return Gasoline;
    }

    public void setGasoline(String gasoline) {
        Gasoline = gasoline;
    }

    public String getSAKey() {
        return SAKey;
    }

    public void setSAKey(String SAKey) {
        this.SAKey = SAKey;
    }
}
