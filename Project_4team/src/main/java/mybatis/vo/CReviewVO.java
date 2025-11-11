package mybatis.vo;

public class CReviewVO {
	String Idx, SAKey, Writer, Content, ImageUrl;
	// ServiceArea 조인 정보
	String serviceAreaName, serviceAreaAddress, serviceAreaStar, serviceAreaConvenience;
	
	public String getIdx() {
		return Idx;
	}
	
	public void setIdx(String idx) {
		Idx = idx;
	}
	
	public String getSAKey() {
		return SAKey;
	}
	
	public void setSAKey(String SAKey) {
		this.SAKey = SAKey;
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
	
	public String getImageUrl() {
		return ImageUrl;
	}
	
	public void setImageUrl(String imageUrl) {
		ImageUrl = imageUrl;
	}
	
	// ServiceArea 조인 정보 getter/setter
	public String getServiceAreaName() {
		return serviceAreaName;
	}
	
	public void setServiceAreaName(String serviceAreaName) {
		this.serviceAreaName = serviceAreaName;
	}
	
	public String getServiceAreaAddress() {
		return serviceAreaAddress;
	}
	
	public void setServiceAreaAddress(String serviceAreaAddress) {
		this.serviceAreaAddress = serviceAreaAddress;
	}
	
	public String getServiceAreaStar() {
		return serviceAreaStar;
	}
	
	public void setServiceAreaStar(String serviceAreaStar) {
		this.serviceAreaStar = serviceAreaStar;
	}
	
	public String getServiceAreaConvenience() {
		return serviceAreaConvenience;
	}
	
	public void setServiceAreaConvenience(String serviceAreaConvenience) {
		this.serviceAreaConvenience = serviceAreaConvenience;
	}
}
