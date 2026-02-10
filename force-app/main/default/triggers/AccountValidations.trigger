trigger AccountValidations on Account (before insert,before update) {

    //Scenario 1: If the Account Insudtry in blank, default it to 'Technology'

    //Step 1: FInd the accounts being inserted
    /**
     * in Triggers, trigger.new holds the records which are being inserted or updated. 
     * It is a list of sObjects. In this case, it will be a list of Account records.
     */
   // Account accRec = trigger.new[0]; //processes only first record from the list of accounts being inserted. This is just for demonstration purposes. In a real scenario, you would typically loop through all records in trigger.new.

    //Iterate over the list of accounts being inserted
    //tradiitonal for loop
    /*for(Integer i=0; i<trigger.new.size(); i++){
        Account accRec = trigger.new[i];
        if(String.isBlank(accRec.Industry)){
            accRec.Industry = 'Technology';
        }
    }*/

    system.debug('Accounts being inserted: ' + trigger.new.size());

    //this code will execute only for beforeInsert context
    if(trigger.isInsert && trigger.isBefore)
    {
        //Enhanced for loop
        for(Account accRec : trigger.new)
        {
            //check if the industry field is blank
            if(accRec.Industry == null)
            {
                accRec.Industry = 'Technology';
            }
        }
    }

    //Scenario 2: If the industry is blank and the account is being updated, 
    //throw an error message to the user
   if(trigger.isUpdate && trigger.isBefore)
    {
        for(Account accRec : trigger.new)
        {
            if(accRec.Industry == null)
            {
            //top of the page error message
                accRec.addError('Industry field cannot be blank during update.');
                //on field level
                accRec.Industry.addError('Industry field cannot be blank during update.'); //This will add an error message to the industry field itself, highlighting it for the user.
               // acc.Industry = 'Banking';
               system.debug('AFter the error message is added, the record will not be saved to the database. The user will see the error message and can correct the industry field before trying to save again.');
            }
        }
    }

    List<Account> lstAccToUpdate = new List<Account>();
    lstAccToUpdate = [SELECT id,Name from Account];

    List<Contact> lstContacts = [SELECT Id, Name, AccountId, Account.Name 
                                FROM Contact 
                                WHERE AccountId IN :lstAccToUpdate];
    system.debug('Contacts with Account Name: ' + lstContacts);

    //parent to child relationship - standard relationship between Account and Contact
     List<Account> lstAccounts = [SELECT Id, Name, (SELECT Id, Name FROM Contacts) 
                                  FROM Account];
     system.debug('Accounts with their related contacts: ' + lstAccounts);

}