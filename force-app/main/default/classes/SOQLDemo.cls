/*
@Description: Purpose of this class is to demo different ways to perform SOQL queries in Apex
@Author: Sheetal Chougule
@Version: 1.0
*/

/**
 * sOQL: Reading stored or saved data from salesforce database
 * Inline SOQL = Direcct SOQL query inside the Apex code
 * Dynamic SOQL = SOQL query stored in a string variable and executed at runtime
 * Ids are returned implicitly as 18-character case-insensitive strings
 */
public with sharing class SOQLDemo {
    
    public SOQLDemo() 
    {
        inlineSOQLDemo();
        soqlWithBindVariables();
        subQueryDemo();
        setMethods();
        mapMethods();
        listMethods();
    }

    public static void inlineSOQLDemo() 
    {
        /***
         * SOQL Structure:
         * SELECT - Keyword to start the query
         * Fields - Comma separated list of fields to retrieve. Use API names for fields
         * FROM - Keyword to specify the object
         * Object - API Name of the object to query
         * WHERE - Optional clause to filter records based on conditions
         * Conditions - Logical expressions to filter records (e.g., Name = 'Acme')
         * ORDER BY - Optional clause to sort the results based on specified fields
         * LIMIT - Optional clause to limit the number of records returned
         */

        //Inline soql - []
        //SOQL will rettuen and assign results to single sobject or list of sobject
        //Bad Practice - Querying for a single record without using LIMIT 1 can lead to null pointer exception if no record is found
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'Acme']; // null pointer exception if no record found
        System.debug('Account Name: ' + acc.Name);

        //Best Practice
        //SOQL return 50000 records - if we want to limit records then we need to use SOQL query
        //If we want to fetch Ids then we can use Account.Id instead of Account
        List<Account> lstAccounts = [SELECT Id, Name,Type FROM Account WHERE Name = 'Apex SOQL Demo' LIMIT 1];
        //isEmpty checks only first item in the collection and returns true or false
        if(!lstAccounts.isEmpty())
        {
            accRecord = lstAccounts[0];   // [Limitation] Only processes first record in the collection
            system.debug('Demo of inline SOQL - Direct SOQL - Best Practice '+accRecord.Type);
        }

        //Traditional array notation vs List notation
        Account[] accRecords = [SELECT Id, Name FROM Account];      //array notation
        System.debug('Total Accounts: ' + accRecords.size());
        System.debug('Account Records: ' + accRecords[0].Name  + ', ' + accRecords[1].Name); //accessing list elements

        List<Account> accList = [SELECT Id,Name
                                FROM Account]; //list notation
    }

    /**
     * Selective Querying - Querying only required fields to optimize performance
     * Querying only necessary fields reduces the amount of data transferred and improves query performance
     */
    public static void selectiveQuery()
    {
        //Selective Query - Querying only required fields to optimize performance
        List<Contact> conList = [SELECT Id, FirstName, LastName
                                 FROM Contact
                                 WHERE FirstName = 'John'
                                 AND LastName = 'Doe'];
        System.debug('Total Contacts for Acme: ' + conList.size());
    }

    /**
     * SOQL with Bind Variables - Using Apex variables in SOQL queries to make them dynamic and reusable
     * Bind variables are useful when the data is dynamic and cannot be hardcoded
     */
    public static void soqlWithBindVariables()
    {
        String accName = 'Acme';
        //Using bind variables in SOQL
        //Bind variable are useful when the data is dynaamic and cannot be hardcoded
        //SOQL is apex can reference apex variables directly using colon (:)
        List<Account> accList = [SELECT Id, Name
                                 FROM Account
                                 WHERE Name = :accName]; //bind variable with colon (:)
        System.debug('Accounts with Name ' + accName + ': ' + accList.size());
    }

    //SOQL For loop - Best practice - Use this when you want to iterate over large number of records
    //This is a different way of writing SOQL query
    //This will give the same result as given below
    //If we use SOQL query in for loop, it will create new instance of list
    //Heap size limit issues 
    public static void demoSOQLinForLoop()
    {
        for(Account accnt : [SELECT Id,Name,Type FROM Account])
        {
            system.debug('Demo of SOQL in for loop '+accnt);
        }


        //[Bad Coding Practice]- SOQL query should not be inside for loop
        //# of SOQL queries inside for loop - Heap limit issues
        //If we use SOQL inside for loop, it will create new instance of list
        //Heap size limit issues - To avoid heap size limit issues, we can use Aggregate query
        //Aggregate query doesn't create new instance of list
        for(Account acc:[SELECT Id,Name,Type FROM Account] )  //Assume you have 5000 Accounts
        {
            List<Contact> lstAssociatedContacts = [SELECT Name FROM Contact WHERE Id = :acc.Id];
            system.debug('lstAssociatedContacts '+lstAssociatedContacts);
        }
    }

    public static void subQueryDemo()
    {
        //Rereieve All Accounts with Contacts
        //Semi-Join
        List<Account> lstAllAccounts = [SELECT Name FROM Account];
        System.debug('# of Accounts >>'+lstAllAccounts.size());

        Account accntRec = [SELECT Id FROM Account LIMIT 1]; //example account id
        //relationship queries in SOQL
        //1. Child to parent relationship - Using dot notation to access parent fields from child object
        List<Contact> conList = [SELECT Id, FirstName, LastName, Account.Name,Emergency_Contact__r.Name,Vendor_Company__r.Industry__c
                                 FROM Contact
                                 WHERE AccountId = : accntRec.Id]; //example account id

        //2. Parent to child relationship - multiple related child records can be retrieved using subquery
        //Retrieve accounts with related contacts
        //in case of suq=bqueries we use the plural name of the child relationship
        List<Account> accountsWithContacts = [SELECT Id, Name,
                                                 (SELECT Id, FirstName, LastName
                                                  FROM Contacts),
                                                  (SELECT Id,Name FROM Opportunities WHERE isClosed = false) //subquery to fetch related contacts
                                                 FROM Account
                                                 WHERE Id = : accntRec.Id]; //example account id

        //retriebve all contacts where current contact is emergency contact
        //For custom relationships, use the child relationship name defined in the lookup/master-detail field
        List<Contact> emergencyContacts = [SELECT Id, FirstName, LastName,
                                                 (SELECT Id, FirstName, LastName
                                                  FROM EmergencyContactForTrainees__r) 
                                                 FROM Contact
                                                 WHERE Id = : accntRec.Id]; //example contact id

        //Subquery - Querying related records using nested SOQL
        List<Account> accList = [SELECT Id, Name,
                                 (SELECT Id, FirstName, LastName
                                  FROM Contacts) //subquery to fetch related contacts
                                 FROM Account
                                 WHERE Name = 'Acme'];
        
        //semi-join query - retrieve records from one object based on related records in another object
        List<Contact> contactsInAcme = [SELECT Id, FirstName, LastName
                                        FROM Contact
                                        WHERE AccountId IN (SELECT Id FROM Account WHERE Name = 'Acme')];
        System.debug('Contacts in Acme: ' + contactsInAcme.size());

        
        //Retrive accounts with opportunities that are not closed
        List<Account> accountsWithOpenOpportunities = [SELECT Id, Name
                                                      FROM Account
                                                      WHERE Id IN (SELECT AccountId FROM Opportunity WHERE IsClosed = false)];
        System.debug('Accounts with Open Opportunities: ' + accountsWithOpenOpportunities.size());
        
        Set<Id> emergencyContactIds = new Set<Id>{'0035g00000XXXXXXAA','0035g00000YYYYYYAA'};
        List<Contact> contactsWithEmergencyContacts = [SELECT Id, FirstName, LastName
                                                      FROM Contact
                                                      WHERE Id IN :emergencyContactIds];
        System.debug('Contacts with specified emergency contacts: ' + contactsWithEmergencyContacts.size());

        //anti-join query - retrieve records from one object that do not have related records in another object
        List<Contact> contactsWithoutOpportunities = [SELECT Id, FirstName, LastName
                                              FROM Contact
                                              WHERE AccountId NOT IN (SELECT AccountId FROM Opportunity)];
        System.debug('Contacts without Opportunities: ' + contactsWithoutOpportunities.size());
    }

   /***
     * You need to fetch all the fields from object - standard, custom, all
     * Purpose: Selecting fields from object wiithout specifying each field name
     * Note: Using SELECT * is not supported in SOQL
     * [Solution]
     * 1. Use Schema.DescribeSObjectResult to get field names dynamically
     * 2. SOQL keywords - FIELDS(ALL), FIELDS(STANDARD), FIELDS(CUSTOM)
     * 3. Dynamic SOQL - Using dynamic SOQL to fetch all fields
     * 4. FIeldsets - Using fieldsets to define a set of fields to be queried
     * 
     */
    private void selectFieldsDemo() {

        //Retrieve all fields using FIELDS(ALL)
        //Considered as unbound query - may hit governor limits if object has too many fields
        List<Account> accListAllFields = [SELECT FIELDS(ALL) FROM Account LIMIT 10];
        System.debug('Accounts with all fields: ' + accListAllFields.size());

        //Retrieve standard fields using FIELDS(STANDARD)
        List<Account> accListStandardFields = [SELECT FIELDS(STANDARD) FROM Account LIMIT 10];
        System.debug('Accounts with standard fields: ' + accListStandardFields.size());

        //Retrieve custom fields using FIELDS(CUSTOM)
        List<Account> accListCustomFields = [SELECT FIELDS(CUSTOM) FROM Account LIMIT 10];
        System.debug('Accounts with custom fields: ' + accListCustomFields.size());

        //Use few standard and custom fields along with FIELDS(CUSTOM)
        List<Account> accListMixedFields = [SELECT Name, Industry, FIELDS(CUSTOM) FROM Account LIMIT 10];
        System.debug('Accounts with mixed fields: ' + accListMixedFields.size());
    }

    private void fieldSetDemo() {
        //Retrieve all the fields from fieldset and construct dynamic SOQL query
        List<Schema.FieldSetMember> emeafieldSetMembers = 
            SObjectType.Account.FieldSets.EMEA.getFields();
            //return me list of fields - 1. Name    2.,Industry 3.,AnnualRevenue = Name,Industry,AnnualRevenue
            //form q query string to perform a query
        
        system.debug('EMEA Field Set Members: ' + emeafieldSetMembers.size());

        //cretae a sting to store field names
        String fieldNames = '';
        //ietrate over the list of fields in fieldset
        //append field names to the string to form a comma-separated list for SOQL query
        for(Schema.FieldSetMember fsm : emeafieldSetMembers) 
        {
            fieldNames += fieldNames == '' ? fsm.getFieldPath() : ',' + fsm.getFieldPath();
        }
        System.debug('Field Names from Field Set: ' + fieldNames);

        //Construct dynamic SOQL query using field names from fieldset
        String query = 'SELECT ' + fieldNames + ' FROM Account LIMIT 10';
        System.debug('Dynamic SOQL Query: ' + query);

        List<Account> accList = Database.query(query);                  //execute dynamic SOQL query. 
        System.debug('Accounts retrieved using fieldset: ' + accList.size());
    }

    /***
     * @DDescription: Dynamically retrieve all the sObjects and their fields using Schema class
     * allowing you to construct dynamic SOQL queries based on metadata.
     * @DUsage: Use Schema class to dynamically retrieve all the sObjects and their fields
     */

    private void globalDescribeDemo() {
        //Gets a map of all objects and their metadata in the org
        Map<String, Schema.SObjectType> globalDescMap = Schema.getGlobalDescribe();
        System.debug('Total SObjects in Org: ' + globalDescMap.size());

        //Iterate over the map to get sObject names
        for(String sObjName : globalDescMap.keySet()) {
            System.debug('SObject Name: ' + sObjName);
        }

        //Get describe result for a specific sObject - Account
        Schema.SObjectType accountType = globalDescMap.get('Account');
        Schema.DescribeSObjectResult accountDesc = accountType.getDescribe();

        //Get field map for Account object
        Map<String, Schema.SObjectField> accountFieldMap = accountDesc.fields.getMap();
        System.debug('Total Fields in Account: ' + accountFieldMap.size());

        //Iterate over the field map to get field names
        for(String fieldName : accountFieldMap.keySet()) {
            System.debug('Account Field Name: ' + fieldName);
        }

        String soqlQuery = 'SELECT ' + accountDesc.fields.getMap().keySet().join(',') + ' FROM Account LIMIT 10';
        System.debug('Dynamic SOQL Query for Account: ' + soqlQuery);
    }

}