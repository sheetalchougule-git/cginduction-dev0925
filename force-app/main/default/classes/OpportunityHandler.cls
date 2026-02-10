public with sharing class OpportunityHandler 
{
    public class InvalidAmountException extends Exception {}

    public static void validateOpportunityData(List<Opportunity> newOpportunityList,Map<Id,Opportunity> oldOpportunityMap)
    {
        //handle only close lost opportunities
        for(Opportunity opp : newOpportunityList)
        {
            //check if the stage is being changed to closed lost and was not closed lost before
            if(opp.StageName == 'Closed Lost' && 
                oldOpportunityMap.get(opp.Id).StageName != 'Closed Lost')
            {
                //throw an error if no reason is provided
                if(opp.Lost_Reason__c == null)
                {
                    //add error on recod level
                   // opp.addError('Please provide a reason for closing the Opportunity');

                    //add error on field level
                    opp.Lost_Reason__c.addError('Please provide a reason for closing the Opportunity');
                }
                else if(opp.Lost_Reason__c == 'Lost to Competitor' && opp.MainCompetitors__c == null)
                {
                    opp.MainCompetitors__c.addError('Please provide a Main Competitor');
                }
            }
        }
    }

    /***
     * @Descripiton: Adding execption handling to the method that updates the amount field on the Opportunity record.
     * The method will throw a custom exception if the amount is set to 0 or a negative value, and will catch any other exceptions that may occur during the update process. The method will return a boolean value indicating whether the update was successful or not.
     * @param oppId - the Id of the Opportunity record to update
     * @param amount - the new amount value to set on the Opportunity record
     */
    public static Boolean setAmount(Id oppId,Decimal amount){
        Boolean updateSuccessful = null;
        try{
            Opportunity opp = [SELECT Amount FROM Opportunity WHERE Id =: oppId];
            if(amount > 0){
                opp.Amount = amount;
                update opp;
                updateSuccessful = true;
            } else if(amount == 0)
            {
                throw new InvalidAmountException('Amount cannot be 0');
            } else if(amount < 0)
            {
                throw new InvalidAmountException('Amount cannot be less than 0');
            }
        }catch(Exception ex){
            system.debug(('Exception occurred '+ex.getMessage() + ' for record'+ oppId));
            updateSuccessful = false;
        }
        return updateSuccessful;
    }
}