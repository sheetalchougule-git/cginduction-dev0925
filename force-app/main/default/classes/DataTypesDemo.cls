public with sharing class DataTypesDemo 
{
    //constants
    private FINAL String RECORDTYPE_NAME = 'Training Institute';

    public DataTypesDemo() {
        this.RECORDTYPE_NAME = 'Vendor'; // This will cause a compile-time error because RECORDTYPE_NAME is declared as final
        primitiveDataTypes();
        sobjectDataTypes();

    }

    public void primitiveDataTypes() 
    {
        //primitive data types
        Integer myInt = 10;  //initialize an integer variable
        Double myDouble = 3.14;
        Boolean myBoolean = true;
        String myString = 'Hello, World!'; 
        Date myDate = Date.today();
        Time myTime = Time.newInstance(12, 0, 0, 0);

        String strFirstName;  //declaration of a string variable without initialization
    }

    public void sobjectDataTypes()
    {
        //sObject data types
        Account myAccount = new Account(Name = 'Acme Corporation');
        Contact myContact = new Contact(FirstName = 'John', LastName = 'Doe');
        Opportunity myOpportunity = new Opportunity(Name = 'New Business Deal', StageName = 'Prospecting', CloseDate = Date.today().addDays(30));
    
        //Create an Account
        Account newAccount = new Account();
        newAccount.Name = 'Global Tech Solutions';
        newAccount.Active__c = 'Yes'; // Assuming Active__c is a custom checkbox field
        insert newAccount; //dml operation to save the account record to the database

        system.debug('New Account ID: ' + newAccount.Id); //debug statement to log the new account ID

        Contact newContact = new Contact();
        newContact.FirstName = 'Jane';
        newContact.LastName = 'Smith';
        newContact.Email = 'test@test.com';
        newContact.AccountId = newAccount.Id; // Assuming AccountId is a lookup field to the Account object
        insert newContact;

        Certification__c newCertification = new Certification__c();
        newCertification.Name = 'Salesforce Certified Developer';
        newCertification.Expiration_Date__c = Date.today().addYears(1);
        insert newCertification;

        SObject newSObject = new Account();
        newSObject.put('Name', 'New Account');
        newSObject.put('Active__c', 'Yes');
        insert newSObject;
    }
}