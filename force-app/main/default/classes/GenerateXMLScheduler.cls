global class GenerateXMLScheduler implements Schedulable{
    
    global void execute(SchedulableContext sc) {
        GenerateXMLBatch genXML = new GenerateXMLBatch(); 
        Database.executeBatch(genXML);
    }
}