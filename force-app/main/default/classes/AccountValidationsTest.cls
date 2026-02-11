/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AccountValidationsTest {

   static testMethod void validateDefaultIndustryNull() 
   {
        // Create test data
        Account acc = new Account(Name = 'Test Account', AnnualRevenue = 5000000);
        acc.Industry = null; // Set industry to null to test the validation logic
       
        //this will invoke the trigger
        insert acc;

        // After the insert, the trigger should have set the industry to 'Technology'
        Account insertedAcc = [SELECT Id, Name, Industry FROM Account WHERE Id = :acc.Id];
        System.assertEquals('Technology', insertedAcc.Industry);
    }

    static testMethod void validateDefaultIndustryAsEnrollmentRepProfile() 
    {
        //Retrive the profile id of the user with profile name as 'Enrollment Rep'
        Id enrollmentRepProfileId = [SELECT Id FROM Profile WHERE Name = 'Enrollment Rep' LIMIT 1].Id;

        //Create a user with the profile id of 'Enrollment Rep'
        User enrollmentRepUser = new User();
        enrollmentRepUser.ProfileId = enrollmentRepProfileId;
        enrollmentRepUser.Username = 'enrollmentrep@example.com';
        enrollmentRepUser.Email = 'test@example.com';
        enrollmentRepUser.Alias = 'test';
        enrollmentRepUser.FirstName = 'Test';
        enrollmentRepUser.LastName = 'User';
        enrollmentRepUser.TimeZoneSidKey = 'America/Los_Angeles';
        enrollmentRepUser.LocaleSidKey = 'en_US';
        enrollmentRepUser.LanguageLocaleKey = 'en_US';
        enrollmentRepUser.EmailEncodingKey = 'UTF-8';
        insert enrollmentRepUser;

        //login as the user with profile 'Enrollment Rep'
        System.runAs(enrollmentRepUser) {
            // Create test data
            Account acc = new Account(Name = 'Test Account', AnnualRevenue = 5000000);
            acc.Industry = null; // Set industry to null to test the validation logic
            insert acc;
            // After the insert, the trigger should have set the industry to 'Technology'
            Account insertedAcc = [SELECT Id, Name, Industry FROM Account WHERE Id = :acc.Id];
            System.assertEquals('Technology', insertedAcc.Industry);
        }
    }
        
    static testMethod void validateDefaultIndustryNotNull() 
   {
        // Create test data
        Account acc = new Account(Name = 'Test Account', AnnualRevenue = 5000000);
        acc.Industry = 'Banking'; // Set industry to null to test the validation logic
       
        //this will invoke the trigger
        insert acc;

        // After the insert, the trigger should have set the industry to 'Technology'
        Account insertedAcc = [SELECT Id, Name, Industry FROM Account WHERE Id = :acc.Id];
        System.assertNotEquals('Technology', insertedAcc.Industry);
    }

   
    static testMethod void validateBulkInsertAccounts() 
    {
        system.debug('No of DMLS Performed before the test: ' + Limits.getDmlStatements());

        Test.startTest();
        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < 200; i++) {
            Account acc = new Account(Name = 'Test Account ' + i, AnnualRevenue = 5000000);
            acc.Industry = null; // Set industry to null to test the validation logic
            accList.add(acc);
        }
         //this will invoke the trigger
        insert accList;
        system.debug('No of DMLS Performed inside start  test: ' + Limits.getDmlStatements());

        Test.stopTest();
        system.debug('No of DMLS Performed after the stop test: ' + Limits.getDmlStatements());
       
        // After the insert, the trigger should have set the industry to 'Technology' for all accounts
        List<Account> insertedAccList = [SELECT Id, Name, Industry FROM Account WHERE Id IN :accList];
        for(Account acc : insertedAccList) {
            System.assertEquals('Technology', acc.Industry);
        }
    }

    static testMethod void validateDefaultIndustryUpdateNull() 
   {
        // Create test data
        Account acc = new Account(Name = 'Test Account', AnnualRevenue = 5000000);
        acc.Industry = null; // Set industry to null to test the validation logic
       
        //this will invoke the trigger
        insert acc;
        try {
           // Update the account
            acc.Industry = null;
            update acc;
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Industry field cannot be blank during update.'), e.getMessage());
        }
    }

 /*   static testMethod void validateDefaultIndustryValue() 
   {
        // Create test data
        Account acc = new Account(Name = 'Test Account', AnnualRevenue = 5000000);
        acc.Industry = null; // Set industry to null to test the validation logic
       
        //this will invoke the trigger
        insert acc;
       
        try {
           //call the method that contains the validation logic
            AccountValidations.validateAccountUpdation(new List<Account>{acc});
            //System.assert(false, 'Expected a validation exception to be thrown');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('Industry field cannot be blank during update.'), e.getMessage());
        }
    }*/
}