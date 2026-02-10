trigger AccountValidations on Account (before insert,before update)
 {
    //this code will execute only for beforeInsert context
    if(trigger.isInsert && trigger.isBefore)
    {
        AccountValidations.validateAccountIndustry();
    }

    //Scenario 2: If the industry is blank and the account is being updated, 
    //throw an error message to the user
   if(trigger.isUpdate && trigger.isBefore)
    {
        AccountValidations.validateAccountUpdation(Trigger.New);
        AccountValidations.accountDeactivation(Trigger.New);
    }

    

}