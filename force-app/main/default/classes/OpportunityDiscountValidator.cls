public class OpportunityDiscountValidator {
    
    private static Boolean processing = false;
    
    public static void validateDiscounts(List<Opportunity> opportunities) {
        if (processing) {
            return;
        }
        
        processing = true;
        
        try {
            for (Opportunity opp : opportunities) {
                if (opp.Amount == null || opp.Discount_Percent__c == null) {
                    continue;
                }
                
                Decimal maxDiscount;
                String approverLevel;
                
                if (opp.Amount >= 100000) {
                    maxDiscount = 10;
                    approverLevel = 'VP Sales';
                } else if (opp.Amount >= 50000) {
                    maxDiscount = 15;
                    approverLevel = 'Sales Manager';
                } else if (opp.Amount >= 10000) {
                    maxDiscount = 20;
                    approverLevel = 'Team Lead';
                } else {
                    maxDiscount = 25;
                    approverLevel = 'Auto-Approved';
                }
                
                if (opp.Discount_Percent__c > maxDiscount) {
                    opp.Requires_Approval__c = true;
                    opp.Approval_Level__c = approverLevel;
                    opp.Discount_Status__c = 'Pending Approval';
                } else {
                    opp.Requires_Approval__c = false;
                    opp.Approval_Level__c = approverLevel;
                    opp.Discount_Status__c = 'Approved';
                }
                
                opp.Max_Allowed_Discount__c = maxDiscount;
            }
        } finally {
            processing = false;
        }
    }
}