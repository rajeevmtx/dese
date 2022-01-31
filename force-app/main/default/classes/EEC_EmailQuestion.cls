public class EEC_EmailQuestion extends EEC_Question {
    public String fieldName { get; set; }
    public Integer maxLength { get; set; }
    
    public override String getQuestionType() {
        return 'email';
    }
    
    public EEC_EmailQuestion(String fieldName, String label) {
        this.fieldName = fieldName;
        this.label = label;
    }
    
    public EEC_EmailQuestion maxLength(Integer maxLength) {
        this.maxLength = maxLength;
        return this;
    }
}