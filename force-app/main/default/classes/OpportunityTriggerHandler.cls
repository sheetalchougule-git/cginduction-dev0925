public with sharing class OpportunityTriggerHandler extends TriggerHandler
 {
    public OpportunityTriggerHandler() {
        this.setMaxLoopCount(10);
    }

    //this method is declared as virtual in the TriggerHandler class,
    // so we can override it here to implement our custom logic 
    //for the before update event of the Opportunity object
    public override void beforeUpdate()
    {
        //typecast the Trigger.new and Trigger.oldMap to List<Opportunity> and Map<Id, Opportunity> respectively
       Map<Id,Opportunity> oldOpportunityMap = (Map<Id, Opportunity>) Trigger.oldMap;
       List<Opportunity> newOpportunityList = (List<Opportunity>) Trigger.new;
       
       OpportunityHandler.validateOpportunityData(newOpportunityList, oldOpportunityMap);
       
    }
}