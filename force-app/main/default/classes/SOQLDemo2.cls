/***
 * @Description:  Class to demonstrate the SOQL in Apex
 * @Test CLass:
 * @Author:  Sheetal Chougule
 * Audit history:
 * 
 */

public with sharing class SOQLDemo2 
{
    public SOQLDemo2() {

    }

    /****
     * SELECT - Keyword used to retrieve data from the database
     * fields - The fields that we want to retrieve from the database
     * FROM - Keyword used to specify the object from which we want to retrieve data
     * WHERE - Keyword used to filter the data based on certain conditions
     * ORDER BY - Keyword used to sort the data based on certain fields
     * LIMIT - Keyword used to limit the number of records returned by the query
     */
    public static void simpleSOQLQueries()
    {
        //Retrieve all the accounts from the database
        List<Account> accounts = [SELECT Id, Name FROM Account];

        //Retrieve all the accounts with the name 'Test'
        //Exact Match
        List<Account> testAccounts = [SELECT Id, Name, Active__c 
                                      FROM Account 
                                      WHERE Name = 'Test'];

        //Retrieve all accounts with the name 'Test' and active status as true
        List<Account> activeTestAccounts = [SELECT Id, Name, Active__c 
                                            FROM Account 
                                            WHERE Name = 'Test' AND Active__c = 'Yes'];
        
        //Retrive all accounts where name starts with 'Test'
        List<Account> testAccountsStartsWith = [SELECT Id, Name, Active__c 
                                              FROM Account 
                                              WHERE Name LIKE 'Test%']; 
        //Retrive all accounts where name ends with 'Test'
        List<Account> testAccountsEndsWith = [SELECT Id, Name, Active__c 
                                              FROM Account 
                                              WHERE Name LIKE '%Test'];
        //Retrive all accounts where name contains 'Test'
        List<Account> testAccountsContains = [SELECT Id, Name, Active__c 
                                              FROM Account 
                                              WHERE Name LIKE '%Test%'];

        //Retrieve all opportuntites ordered by amount in descending order
        List<Opportunity> opportunities = [SELECT Id, Name, Amount 
                                           FROM Opportunity 
                                           ORDER BY Amount DESC];

        //Retrieve top 5 accounts ordered by created date in descending order
        List<Account> top5Accounts = [SELECT Id, Name, CreatedDate 
                                      FROM Account 
                                      ORDER BY CreatedDate DESC 
                                      LIMIT 5];
    }

    public static void relationshipSOQLQueries()
    {
        //Retrieve all contacts along with their account name
        //Child to Parent Relationship - standard relationship between Contact and Account
        List<Contact> contacts = [SELECT Id, Name,AccountId,Account.Name 
                                  FROM Contact];

        //Retrive the course detials along with the related Institute Name
        //Child to Parent Relationship - custom relationship between Course__c and Training_Institute__c
        List<Course__c> lstCourses = [SELECT Id, Name, Training_Institute__c, 
                                      Training_Institute__r.Name
                                      FROM Course__c];
    
         system.debug('Contacts with Account Name: ' + contacts);
         system.debug('Course details with Institute Name: ' + lstCourses);

         //Retrieve all accounts along with their related contacts
         //Parent to Child Relationship - standard relationship between Account and Contact
         List<Account> accountsWithContacts = [SELECT Id, Name, (SELECT Id, Name FROM Contacts) ,
                                              (SELECT Id, Name FROM Opportunities)
                                              FROM Account];                             

         system.debug('Account with Contacts and Opportunities: ' + accountsWithContacts);

         //Retrieve all the training institutes along with their related courses
         //Parent to Child Relationship - custom relationship between Training_Institute__c and Course__c
         List<Account> institutesWithCourses = [SELECT Id, Name, (SELECT Id, Name FROM Courses__r) 
                                                FROM 
                                                Account];
        system.debug('Institutes with Courses: ' + institutesWithCourses);
        
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
    }

    public static void soqlWithBindVariables()
    {
        //binding single variable
        String accountName = 'Test';
        List<Account> testAccounts = [SELECT Id, Name, Active__c 
                                      FROM Account 
                                      WHERE Name = :accountName];
        System.debug('Test Accounts: ' + testAccounts);

        //Binding list variable
        List<Account> lstAccToUpdate = new List<Account>();
        lstAccToUpdate = [SELECT id,Name from Account];

        List<Contact> lstContacts = [SELECT Id, Name, AccountId, Account.Name 
                                    FROM Contact 
                                    WHERE AccountId IN :lstAccToUpdate];
        system.debug('Contacts with Account Name: ' + lstContacts);
    }

    public static void dynamicQueries()
    {
        String accountName = 'Test';
        String query = 'SELECT Id, Name, Active__c FROM Account WHERE Name = :accountName';
        List<Account> testAccounts = Database.query(query);
        System.debug('Test Accounts: ' + testAccounts);

        //Dynamic query with bind variable and limit
        Integer limitSize = 5;
        String dynamicQuery = 'SELECT Id, Name FROM Account WHERE Name = :accountName LIMIT :limitSize';
        List<Account> limitedTestAccounts = Database.query(dynamicQuery);
        System.debug('Limited Test Accounts: ' + limitedTestAccounts);

       //Dynamic query with escape single quotes
       String accountNameWithQuote = 'Test\'s Account';
       String escapedQuery = 'SELECT Id, Name FROM Account WHERE Name = \'' + String.escapeSingleQuotes(accountNameWithQuote) + '\'';
       List<Account> accountsWithQuote = Database.query(escapedQuery);
       System.debug('Accounts with Quote: ' + accountsWithQuote);
    }

    public static void aggregateQueries()
    {
        //Aggregate query to count the number of accounts
        Integer accountCount = [SELECT COUNT() FROM Account];
        System.debug('Total Accounts: ' + accountCount);

        //Aggregate query to calculate the average amount of opportunities
        List<AggregateResult>  averageAmount = [SELECT AVG(Amount) FROM Opportunity];
        System.debug('Average Opportunity Amount: ' + averageAmount);

        //Aggregate query to group accounts by active status and count them
        List<AggregateResult> groupedAccounts = [SELECT Active__c, COUNT(Id) 
                                                 FROM Account 
                                                 GROUP BY Active__c];
        for (AggregateResult ar : groupedAccounts) {
            System.debug('Active Status: ' + ar.get('Active__c') + ', Count: ' + ar.get('expr0'));
        }

        //Get the Opportunities amount total by stage
        List<AggregateResult> opportunityAmountByStage = [SELECT StageName, SUM(Amount) 
                                                          FROM Opportunity 
                                                          GROUP BY StageName];
        for (AggregateResult ar : opportunityAmountByStage) {
            System.debug('Stage: ' + ar.get('StageName') + ', Total Amount: ' + ar.get('expr0'));
        }

        //aliasing the aggregate result
        List<AggregateResult> opportunityAmountByStageWithAlias = [SELECT StageName, SUM(Amount) totalAmount 
                                                          FROM Opportunity 
                                                          GROUP BY StageName];
        for (AggregateResult ar : opportunityAmountByStageWithAlias) {
            System.debug('Stage: ' + ar.get('StageName') + ', Total Amount: ' + ar.get('totalAmount'));
        }
    }

    public static void queriesWithAllFields()
    {
      /*  //Query to retrieve all fields from Account object
        List<Account> allFieldsAccounts = [SELECT FIELDS(ALL) FROM Account];
        System.debug('Accounts with All Fields: ' + allFieldsAccounts);

        //Query to retrieve all fields from Contact object
        List<Contact> allFieldsContacts = [SELECT FIELDS(ALL) FROM Contact];
        System.debug('Contacts with All Fields: ' + allFieldsContacts);

        //Query all custom fields from Course__c object
        List<Course__c> allFieldsCourses = [SELECT FIELDS(ALL) FROM Course__c];
        System.debug('Courses with All Fields: ' + allFieldsCourses);

        //Query only system fields from Contact object
        List<Contact> systemFieldsContacts = [SELECT FIELDS(SYSTEM) FROM Contact];
        System.debug('Contacts with System Fields: ' + systemFieldsContacts);

        //retive only custom fields from Course__c object
        List<Course__c> customFieldsCourses = [SELECT Name, FIELDS(CUSTOM) FROM Course__c];
        System.debug('Courses with Custom Fields: ' + customFieldsCourses);*/
    }

    public static void soqlFORLOOP()
    {
        //Using SOQL FOR loop to process large number of records
        for (Account acc : [SELECT Id, Name FROM Account]) {
            System.debug('Account Name: ' + acc.Name);
        }

        //Using SOQL FOR loop with relationship query
        for (Contact con : [SELECT Id, Name, Account.Name FROM Contact]) {
            System.debug('Contact Name: ' + con.Name + ', Account Name: ' + con.Account.Name);
        }
    }
}