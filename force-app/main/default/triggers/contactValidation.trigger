trigger contactValidation on Contact (before update) 
{
    //Step 1: Get current contacts being inserted
    Contact insertedContact = Trigger.new[0];  //retrieveing only 1 record

    system.debug('insertedContact: ' + insertedContact);
    Account acc =  [SELECT Id, Primary_Contact__c 
                    FROM Account 
                    WHERE Id = :insertedContact.AccountId];

    //Step 2: Check the is Primary field for  contact
    if(insertedContact.Is_Primary__c 
        && acc.Primary_Contact__c != null)
    {
        //Step 3: If the is Primary field is true, 
        //then check if  Primary Contact on Account is arelady populated
         system.debug('Primary_Contact__c: ' + acc.Primary_Contact__c);
       
        insertedContact.Is_Primary__c.addError('Primary Contact on Account is already populated');
        
        //Step 4: If the Primary Contact on Account is already populated,
        //then add an error to the contact record being inserted
    }
    else if(insertedContact.Is_Primary__c 
    && insertedContact.Account.Primary_Contact__c == null)
    {
        system.debug('Primary_Contact__c: ' + insertedContact.Account.Primary_Contact__c);
        acc.Primary_Contact__c = insertedContact.Id;
        update acc;
        system.debug('acc updated: ' + acc);
    }
}