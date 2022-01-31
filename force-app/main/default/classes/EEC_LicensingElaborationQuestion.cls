public class EEC_LicensingElaborationQuestion extends EEC_Question {
    public String statusField { get; set; }
    public String elaborationDescription { get; set; }
    public String elaborationField { get; set; }
    public String shouldElaborateOn { get; set; }

    public override String getQuestionType() {
        return 'elaboration';
    }

    public EEC_LicensingElaborationQuestion(String question, String statusField, String elaborationDescription, String elaborationField, List<String> hideOnLicensingType) {
        this.question = question;
        this.statusField = statusField;
        this.elaborationDescription = elaborationDescription;
        this.elaborationField = elaborationField;
        this.hideOnLicensingType = hideOnLicensingType; 
        this.shouldElaborateOn = 'Yes'; // force yes for the time being
    }

    public EEC_LicensingElaborationQuestion(String question, String statusField, String elaborationDescription, String elaborationField) {
        this(question, statusField, elaborationDescription, elaborationField, new List<String>());
    }
}