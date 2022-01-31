public abstract class EEC_Question {
    public String question { get; set; }
    protected List<String> hideOnLicensingType { get; set; }
    public Boolean isRequired = true; 
    public String label { get; set; }
    public String className { get; set; }
    public List<ConditionPair> conditions = new List<ConditionPair>();
    public List<ConditionPair> lessThenConditions = new List<ConditionPair>();
    public String rerender { get; set; }   
    
    public List<ConditionPair> getConditions() {
        return conditions;
    }
    
    public class ConditionPair {
        public String fieldName { get; set; }
        public Object value { get; set; }
        
        public ConditionPair(String field, Object v) {
            this.fieldName = field;
            this.value = v;
        }
    }
    
    public virtual String getQuestionType() {
        return 'unknown';
    } 

    public Boolean getIsRequired() {
        return isRequired;
    } 

    public String getHideOnLicensingType() {
        if (hideOnLicensingType != NULL) {
            return String.join(hideOnLicensingType, ',');
        }

        return '';
    }

    public ConditionPair getFirstCondition() {
        if(conditions.size() > 0) {
            return conditions[0];
        }
        
        return null;
    }

    public ConditionPair getSecondCondition() {
        if(conditions.size() > 1) {
            return conditions[1];
        }
        
        return null;
    }

    public EEC_Question isRequired(Boolean isRequired){
        this.isRequired = isRequired;
        return this;
    }  

    public EEC_Question setClassName(String className) {
      this.className = className;
      return this;
    }

    public EEC_Question setRerender(String rerender) {
        this.rerender = rerender;
        return this;
    }

    public EEC_Question addCondition(String field, String value) { 
        conditions.add(new ConditionPair(field, value));

        return this;
    }
    
    public EEC_Question addLessThenCondition(String field, Object value) {
        lessThenConditions.add(new ConditionPair(field, value));
        return this;
    }
}