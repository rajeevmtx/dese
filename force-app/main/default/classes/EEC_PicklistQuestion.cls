public class EEC_PicklistQuestion extends EEC_Question {
 
    public List<SelectOption> options { get; set; } 
    public String fieldName { get; set; } 

    public override String getQuestionType() {
        return 'picklist';
    }

    public EEC_PicklistQuestion(String fieldName, String label) {
        this.fieldName = fieldName;
        this.label = label; 
    } 

    public EEC_PicklistQuestion setOptions(List<SelectOption> options) {
        this.options = options;
        return this;
    }

}