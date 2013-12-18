public class SOWCloner
{

    public static void clone(SOW__c curSOW)
    {
        Resource__c[] curResources = new List<Resource__c>();
        SOW__c[] sows = [Select Start_Date__c,End_Date__c,Client__c,CreatedDate,
                        (Select Name,Name__c,Start_Date__c,End_Date__c,rate__c,AUNo__c,Internal_Rate__c,Allocation__c from Resources__r) 
                        From SOW__c where (Parent_SOW__c=: curSOW.Parent_SOW__c AND id!=:curSOW.id) OR
                        (id=:curSOW.Parent_SOW__c)
                        ORDER BY CreatedDate DESC LIMIT 1];
        System.debug('parent sow found'+sows.size());
        if(sows.size()==0)
        {
            return;
        }
        SOW__c parentSOW = sows[0];
        Resource__c[] resources = parentSOW.Resources__r;
        System.debug('resources found'+resources.size());
        for(Resource__c resource:resources)
        {
            Resource__c curResource = resource.clone();
            curResource.SOWNo__c=curSOW.id;
            curResource.SOWNo__c=curSOW.id;
            curResources.add(curResource);
        }
        insert curResources;
    }
}