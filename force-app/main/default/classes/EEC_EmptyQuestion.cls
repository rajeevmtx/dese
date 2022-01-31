public class EEC_EmptyQuestion extends EEC_Question {
    public override String getQuestionType() {
        return 'empty';
    }
    
    public EEC_EmptyQuestion() {
        this.isRequired = false;
    }
}