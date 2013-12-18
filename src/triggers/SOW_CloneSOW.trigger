trigger SOW_CloneSOW on SOW__c (after insert)
{
	SOW__c[] sowNew=trigger.new;
    SOW__c sow=sowNew[0];       
    if(!String.isEmpty(sow.Parent_Sow__c))
    {
        SOWCloner.clone(sow);
    }
    
}