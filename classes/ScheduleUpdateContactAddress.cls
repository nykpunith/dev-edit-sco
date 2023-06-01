global class ScheduleUpdateContactAddress implements Schedulable {
    global void execute(SchedulableContext ctx) {
        UpdateContactAddressBatch batch = new UpdateContactAddressBatch();
        Database.executeBatch(batch,50);
    }
}

// Schedule the job to run every other day
//System.schedule('Update Contact Address Job', '0 0 0 1/2 * ? *', new ScheduleUpdateContactAddress());