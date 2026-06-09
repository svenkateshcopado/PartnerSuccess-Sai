trigger OpportunityDiscountTrigger on Opportunity (before insert, before update) {
    OpportunityDiscountValidator.validateDiscounts(Trigger.new);
}