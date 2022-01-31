public class EEC_DateTimeQuestion extends EEC_Question { 

    public String dateField { get; set; }
    public String timeField { get; set; } 
    public List<SelectOption> times { get; set; }

    public override String getQuestionType() {
        return 'datetime';
    }

    public Type thing(Type t) {
        return t;
    }

    public EEC_DateTimeQuestion(String dateField, String timeField, String label) {
        this.dateField = dateField;
        this.timeField = timeField;
        this.label = label;
    }

    public EEC_DateTimeQuestion setTimes(List<SelectOption> options) {
        this.times = options;
        return this;
    }
}