trigger OpportunityTrigger on Opportunity (before update,after update) 
{
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
    handler.run();
}