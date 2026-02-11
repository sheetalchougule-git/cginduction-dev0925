public inherited sharing class InheritedSharingDemo {

    public static string updateAccountAccessibleCount()
    {
        return  'Access to No of Accounts' + [Select Count() From Account];
    }
}