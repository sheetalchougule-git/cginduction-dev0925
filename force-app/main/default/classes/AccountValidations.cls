/***
 * @Description: This will is being used in trigger to perform actions on Account records.
 */
public with sharing class AccountValidations 
{
    public static void validateAccountIndustry()
    {
        //Enhanced for loop
        for(Account accRec : (List<Account>)trigger.new)
        {
            //check if the industry field is blank
            if(accRec.Industry == null)
            {
                accRec.Industry = 'Technology';
            }
        }
    }

    public static void validateAccountUpdation(List<Account> newAccountsList)
    {
        for(Account accRec : newAccountsList)
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

    public static void accountDeactivation(List<Account> newAccountsList)
    {
        //iterate over the list of accounts being updated
       /* for(Account accRec : newAccountsList)
        {
            //Check if the Active__c = false
            if(accRec.Active__c == 'No')
            {
                //Check if there are any related opportunities with stage not closed and stage is negotation/review
                List<Opportunity> oppList = [SELECT Id, StageName 
                                             FROM Opportunity 
                                             WHERE AccountId = :accRec.Id 
                                             AND IsClosed = false 
                                             AND StageName = 'Negotiation/Review'];
                if(!oppList.isEmpty())
                {
                    accRec.addError('Account cannot be deactivated because it has open opportunities in "Negotiation" or "Review" stage.');
                }
            }
        }*/

        //Aprroach 2: Query the related opportunities with stage not closed 
        //and stage is negotation/review for all accounts being updated in one go 
        // store the results in a map
       /* Map<Id, List<Opportunity>> accountToOppsMap = new Map<Id, List<Opportunity>>();
        List<Opportunity> lstOpps;

        for(Opportunity opp : [SELECT Id, StageName, AccountId 
                               FROM Opportunity 
                               WHERE AccountId IN :newAccountsList 
                               AND IsClosed = false 
                               AND StageName = 'Negotiation/Review'])
        {
            if(!accountToOppsMap.containsKey(opp.AccountId))
            {
                //map is currently empty for this account, so we need to initialize the list
                lstOpps = new List<Opportunity>();
                lstOpps.add(opp);
                accountToOppsMap.put(opp.AccountId, lstOpps);
            }
            else {
                lstOpps = accountToOppsMap.get(opp.AccountId);
                lstOpps.add(opp);
                accountToOppsMap.put(opp.AccountId, lstOpps);
            }
        }

        //If the account is being deactivated, check if there are any related opportunities in the map
        for(Account accRec : newAccountsList)
        {
            if(accRec.Active__c == 'No')
            {
                if(accountToOppsMap.containsKey(accRec.Id))
                {
                    accRec.addError('Account cannot be deactivated because it has open opportunities in "Negotiation" or "Review" stage.');
                }
            }
        }*/

        //Approach 3: Create rollup summary on Opportunity object 
        //to calculate the total amount of all the closed won opportunities 
        //and if the total amount is greater than 0, then throw an error message to the user.
        /*for(Account accRec : newAccountsList)
        {
            if(accRec.Active__c == 'No' && accRec.No_of_Negotiation_Opps__c > 0)
            {
                accRec.addError('Account cannot be deactivated because it has open opportunities in "Negotiation/Review" stage.');
            }
        }*/

        //Approach 4: use the join to retrieve the accounts that are being deactivated 
        //and have related opportunities in "Negotiation/Review" stage in one go and then add error message to those accounts.
        List<Account> lstAccs = [SELECT Id, Name, Active__c, 
                                (SELECT Id FROM Opportunities 
                                WHERE IsClosed = false 
                                AND StageName = 'Negotiation/Review') 
                                 FROM Account 
                                 WHERE Id IN :newAccountsList AND Active__c = 'No'];
        for(Account accRec : lstAccs)
        {
            if(!accRec.Opportunities.isEmpty())
            {
                accRec.addError('Account cannot be deactivated because it has open opportunities in "Negotiation" or "Review" stage.');
            }
        } 
    }
}