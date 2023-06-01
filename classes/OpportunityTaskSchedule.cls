global class OpportunityTaskSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
         OpportunityHandler.createTask();
    }
}
/*
String jobName = 'Create Task';
String cronExpr = '0 0 0 * * ?'; // Runs at midnight every day
OpportunityTaskSchedule job = new OpportunityTaskSchedule();
System.schedule(jobName, cronExpr, job);*/