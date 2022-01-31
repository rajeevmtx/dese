public class EEC_SimpleQuestion extends EEC_Question { 

    public String fieldName { get; set; } 
    public Boolean isTextArea { get; set; }
    public Integer maxLength { get; set; }
    public override String getQuestionType() {
        return isTextArea ? 'simple-textarea' : 'simple';
    }

    public EEC_SimpleQuestion(String fieldName, String label) {
        this.fieldName = fieldName;
        this.label = label;
        this.isTextArea = false;
        this.maxLength = 32768;
    }
      
     
    public EEC_SimpleQuestion isTextArea(Boolean isTextArea) {
        this.isTextArea = isTextArea;

        return this;
    } 
    
    public EEC_SimpleQuestion maxLength(Integer maxLength) {
        this.maxLength = maxLength;
        return this;
    }
}