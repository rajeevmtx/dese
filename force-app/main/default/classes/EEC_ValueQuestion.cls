public class EEC_ValueQuestion extends EEC_Question { 
    
    public String value { get ; set; } 

    public override String getQuestionType() {
        return 'value';
    }

    public EEC_ValueQuestion(String value, String label) {
        this.value = value;
        this.label = label; 
    }
}