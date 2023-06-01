global class ContactSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        ContactHandler.deleteContact();
    }
}

/*String jobName = 'DeleteContactsJob';
String cronExpr = '0 0 0 * * ?'; // Runs at midnight every day
ContactSchedule job = new ContactSchedule();
System.schedule(jobName, cronExpr, job);*/