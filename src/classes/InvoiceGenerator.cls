public class InvoiceGenerator{
    String sowNumber;
    SOW__c sow,sowNew;
    
    InvoiceDates__c[] invDates;
    Resource__c[] resources;
    Set<String> auNumbers;
    
    public InvoiceGenerator(SOW__c trgSOW)
    {
        sowNew=trgSOW;
    }
    
    public InvoiceGenerator(string SOWNumber)
    {
        sowNumber = SOWNumber;
        System.debug(sowNumber);
    }
    
    public void GenerateInvoice()
    {
        decimal allocation;
        Invoice__c[] invoices =new List<Invoice__c>();
        
        LoadSOW();
        
        DeleteInvoices();
        
        LoadInvoiceDates();

        for(InvoiceDates__c invDate:invDates)
        {
            for(String au:auNumbers)
            {
                String employees='';
                decimal amount=0;
                Invoice__c invoice=new Invoice__c();
                invoice.SOWNo__c=sow.Id;
                invoice.AU__c=au;
                invoice.Invoice_Date__c=invDate.End_Date__c;
                for(Resource__c resource:resources)
                {
                    allocation=resource.Allocation__c;
                    if(au.Equals(resource.AUNo__c))
                    {
                        decimal amt=GetInvoiceAmount(invDate,resource);
                        if(amt>0)
                        {
                            employees+= ' ' + resource.Name__c + ';';
                            amount+=(amt*(allocation/100));
                        }   
                    }
                }
                invoice.Resources__c=employees;
                invoice.Amount__c=amount;
                if(amount>0)
                    invoices.add(invoice);
            }
        }
        insert invoices;
    }
    
    private void DeleteInvoices()
    {
        Invoice__c[] invoices = [Select id from Invoice__c where SOWNo__c=:sow.id];
        delete invoices;
    }
    
    public void LoadSOW()
    {
        auNumbers=new Set<String>();
        //sow=[Select Start_Date__c,End_Date__c,Client__c From SOW__c ];
        sow=[Select Start_Date__c,End_Date__c,Client__c,(Select Name,Name__c,Start_Date__c,End_Date__c,rate__c,AUNo__c,Allocation__c from Resources__r)
              From SOW__c where Id=: sowNew.Id];
        resources = sow.Resources__r;
        for(Resource__c resource:resources)
            auNumbers.add(resource.AUNo__c);
    }
    
     private void LoadInvoiceDates()
    {
        invDates = [Select Start_Date__c,End_Date__c,No_Of_Hours__c From InvoiceDates__c];
    }
    
    private decimal GetInvoiceAmount(InvoiceDates__c invDate,Resource__c resource)
    {
        decimal rate,invAmount;
        Date iSDate,iEDate,rStartDate,rEndDate;
        Integer iHours=0;
        invAmount=0;
        rate = resource.Rate__c;
        iSDate=invDate.Start_Date__c;
        iEDate=invDate.End_Date__c;
        rStartDate=resource.Start_Date__c;
        rEndDate=resource.End_Date__c;
        
        if(rStartDate<=iSDate && rEndDate>=iSDate)
        {
            if((rStartDate>iSDate) && (rStartDate<iEDate))
            {
                iHours=getDiffBusinessDays(rStartDate,iEDate)*8;
            }
            else if((rEndDate<iEDate) && (rEndDate>iSDate))
            {
                iHours=getDiffBusinessDays(iSDate,rEndDate)*8;
            }
            else
            {
                iHours=invDate.No_Of_Hours__c.intValue();
            }
        }
        else
        {
            return 0;
        }    
        invAmount=iHours * rate;
        return invAmount;
    }
    
    private Integer getDiffBusinessDays(Date startdt, Date enddt) 
    {

        Date tempdate = null;

        if (startdt > enddt)
        {
            tempdate = enddt;
            enddt = startdt;
            startdt = tempdate;
        }

        Integer i = Math.mod((date.newinstance(1985, 6, 24)).daysBetween(startdt),7); // 24/6/85 was a monday   

        Map<Integer, Map<Integer, Integer>> m = new Map<Integer, Map<Integer, Integer>>
        {

        0 => new Map<Integer, Integer> { 1 => 2 , 2 => 3 , 3 => 4 , 4 => 5 , 5 => 5 , 6 => 5 },

        1 => new Map<Integer, Integer> { 1 => 2 , 2 => 3 , 3 => 4 , 4 => 4 , 5 => 4 , 6 => 5 },

        2 => new Map<Integer, Integer> { 1 => 2 , 2 => 3 , 3 => 3 , 4 => 3 , 5 => 4 , 6 => 5 },

        3 => new Map<Integer, Integer> { 1 => 2 , 2 => 2 , 3 => 2 , 4 => 3 , 5 => 4 , 6 => 5 },

        4 => new Map<Integer, Integer> { 1 => 1 , 2 => 1 , 3 => 2 , 4 => 3 , 5 => 4 , 6 => 5 },

        5 => new Map<Integer, Integer> { 1 => 0 , 2 => 1 , 3 => 2 , 4 => 3 , 5 => 4 , 6 => 5 },

        6 => new Map<Integer, Integer> { 1 => 1 , 2 => 2 , 3 => 3 , 4 => 4 , 5 => 5 , 6 => 5 }

        };

        Integer i2 = Math.mod((startdt.daysBetween(enddt)),7);

        Integer i3 = (m.get(i)).get(i2);

        if (i2 == null || i2 < 1 || i2 > 6)
        {

            if (i >= 0 && i <= 4) { i3 = 1; } 

            else  { i3 = 0; }

        }

        i3 = i3 + 5 * (Math.floor( ((Decimal) startdt.daysBetween(enddt)).divide(7,4))).intValue(); 

        if (tempdate != null) i3 *= -1; // negative number of days

        return i3;

    }
}