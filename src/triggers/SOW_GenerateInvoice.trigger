trigger SOW_GenerateInvoice on SOW__c (after update)
{
    if(trigger.isUpdate)
    {
        SOW__c[] sowNew=trigger.new;
        SOW__c[] sowOld=trigger.old;
        
        if(sowNew[0].Generate_Invoice__c==true && sowOld[0].Generate_Invoice__c==false)
        {
            InvoiceGenerator gen = new InvoiceGenerator(sowNew[0]);
            gen.GenerateInvoice();
        }
    }
}