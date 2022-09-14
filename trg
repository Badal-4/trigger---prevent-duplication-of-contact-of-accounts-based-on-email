//trigger to prevent duplication of contact based on email
trigger trg2 on Contact(before Update,before Insert)
{
    Map<Id,String> conMap = new Map<Id,String>();
    
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate))
    {
        if(!trigger.new.isEmpty())
        {
            for(Contact c : trigger.new)
            {
                if(c.Email != null && c.AccountId != null)
                {
                    conMap.put(c.AccountId,c.Email);
                }
            }
        }
    }
    
    List<Contact> conList = [Select Id,Email,AccountId from Contact where AccountId IN : conMap.keySet() and email IN : conMap.values()];
    Set<Id> accId = new Set<Id>();
    Set<String> existingEmail = new Set<String>();
    
    if(!conList.isEmpty())
    {
        for(Contact co : conList)
        {
            accId.add(co.AccountId);
            existingEmail.add(co.Email);
        }
    }
    
    for(Contact con : trigger.new)
    {
        if(con.AccountId != null && con.Email != null && accId.contains(con.AccountId) && existingEmail.contains(con.Email) )
        {
            con.addError('Duplication Error');
        }
    }
}
