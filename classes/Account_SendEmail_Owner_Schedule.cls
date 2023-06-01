global class Account_SendEmail_Owner_Schedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        AccountHandler.sendEmailRegPhoneNoUpdate();
    }
}
/* String jobName = 'Send Email';
 * String cronExpr = '0 0 0 * * ?'; // Runs at midnight every day
  Account_SendEmail_Owner_Schedule job = new Account_SendEmail_Owner_Schedule();
   System.schedule(jobName, cronExpr, job);*/