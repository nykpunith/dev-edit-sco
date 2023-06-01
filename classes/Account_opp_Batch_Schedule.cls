global class Account_opp_Batch_Schedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        AccountOpportunityBatch batch = new AccountOpportunityBatch();
        Database.executeBatch(batch, 200);
    }
}
/*String jobName = 'send email to opp Acc owner';
String cronExpr = '0 0 0 * * ?'; // Runs at midnight every day
Account_opp_Batch_Schedule job = new Account_opp_Batch_Schedule();
System.schedule(jobName, cronExpr, job);*/