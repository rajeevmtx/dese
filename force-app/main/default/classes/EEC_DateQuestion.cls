public class EEC_DateQuestion extends EEC_Question {
    public String dateField { get; set; }
    
    public override String getQuestionType() {
        return 'date';
    }
    
    public EEC_DateQuestion(String dateField, String label) {
        this.label = label;
        this.dateField = dateField;
    }
}