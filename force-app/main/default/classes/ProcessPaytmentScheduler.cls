global class ProcessPaytmentScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        ProcessPaymentBatch processPay = new ProcessPaymentBatch(); 
        Database.executeBatch(processPay);
    }
}