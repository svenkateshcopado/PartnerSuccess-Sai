@isTest
private class OpportunityDiscountValidatorTest {
    
    @isTest
    static void testHighValueOpportunity() {
        Opportunity opp = new Opportunity(
            Name = 'Test High Value Deal',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 150000,
            Discount_Percent__c = 15
        );
        
        Test.startTest();
        insert opp;
        Test.stopTest();
        
        opp = [SELECT Requires_Approval__c, Approval_Level__c, Discount_Status__c, Max_Allowed_Discount__c 
               FROM Opportunity WHERE Id = :opp.Id];
        
        System.assertEquals(true, opp.Requires_Approval__c, 'Should require approval');
        System.assertEquals('VP Sales', opp.Approval_Level__c, 'Should route to VP Sales');
        System.assertEquals('Pending Approval', opp.Discount_Status__c, 'Should be pending');
        System.assertEquals(10, opp.Max_Allowed_Discount__c, 'Max discount should be 10%');
    }
    
    @isTest
    static void testMediumValueOpportunity() {
        Opportunity opp = new Opportunity(
            Name = 'Test Medium Value Deal',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 75000,
            Discount_Percent__c = 12
        );
        
        Test.startTest();
        insert opp;
        Test.stopTest();
        
        opp = [SELECT Requires_Approval__c, Approval_Level__c, Discount_Status__c, Max_Allowed_Discount__c 
               FROM Opportunity WHERE Id = :opp.Id];
        
        System.assertEquals(false, opp.Requires_Approval__c, 'Should not require approval');
        System.assertEquals('Sales Manager', opp.Approval_Level__c, 'Should be Sales Manager level');
        System.assertEquals('Approved', opp.Discount_Status__c, 'Should be auto-approved');
        System.assertEquals(15, opp.Max_Allowed_Discount__c, 'Max discount should be 15%');
    }
    
    @isTest
    static void testLowValueOpportunity() {
        Opportunity opp = new Opportunity(
            Name = 'Test Low Value Deal',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 25000,
            Discount_Percent__c = 18
        );
        
        Test.startTest();
        insert opp;
        Test.stopTest();
        
        opp = [SELECT Requires_Approval__c, Approval_Level__c, Discount_Status__c, Max_Allowed_Discount__c 
               FROM Opportunity WHERE Id = :opp.Id];
        
        System.assertEquals(false, opp.Requires_Approval__c, 'Should not require approval');
        System.assertEquals('Team Lead', opp.Approval_Level__c, 'Should be Team Lead level');
        System.assertEquals('Approved', opp.Discount_Status__c, 'Should be auto-approved');
        System.assertEquals(20, opp.Max_Allowed_Discount__c, 'Max discount should be 20%');
    }
    
    @isTest
    static void testSmallOpportunity() {
        Opportunity opp = new Opportunity(
            Name = 'Test Small Deal',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 5000,
            Discount_Percent__c = 22
        );
        
        Test.startTest();
        insert opp;
        Test.stopTest();
        
        opp = [SELECT Requires_Approval__c, Approval_Level__c, Discount_Status__c, Max_Allowed_Discount__c 
               FROM Opportunity WHERE Id = :opp.Id];
        
        System.assertEquals(false, opp.Requires_Approval__c, 'Should not require approval');
        System.assertEquals('Auto-Approved', opp.Approval_Level__c, 'Should be auto-approved');
        System.assertEquals('Approved', opp.Discount_Status__c, 'Should be approved');
        System.assertEquals(25, opp.Max_Allowed_Discount__c, 'Max discount should be 25%');
    }
    
    @isTest
    static void testBulkProcessing() {
        List<Opportunity> opps = new List<Opportunity>();
        
        for (Integer i = 0; i < 200; i++) {
            opps.add(new Opportunity(
                Name = 'Bulk Test ' + i,
                StageName = 'Prospecting',
                CloseDate = Date.today().addDays(30),
                Amount = 100000 + (i * 1000),
                Discount_Percent__c = 12
            ));
        }
        
        Test.startTest();
        insert opps;
        Test.stopTest();
        
        List<Opportunity> results = [SELECT Requires_Approval__c FROM Opportunity WHERE Id IN :opps];
        System.assertEquals(200, results.size(), 'Should process all records');
    }
    
    @isTest
    static void testNullValues() {
        Opportunity opp = new Opportunity(
            Name = 'Test Null Values',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = null,
            Discount_Percent__c = null
        );
        
        Test.startTest();
        insert opp;
        Test.stopTest();
        
        opp = [SELECT Requires_Approval__c, Approval_Level__c, Max_Allowed_Discount__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(false, opp.Requires_Approval__c, 'Should remain false (default value)');
        System.assertEquals(null, opp.Approval_Level__c, 'Should not set approval level');
        System.assertEquals(null, opp.Max_Allowed_Discount__c, 'Should not set max discount');
    }
    
    @isTest
    static void testRecursionPrevention() {
        Opportunity opp = new Opportunity(
            Name = 'Test Recursion',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 100000,
            Discount_Percent__c = 15
        );
        
        Test.startTest();
        insert opp;
        
        opp.Amount = 120000;
        update opp;
        Test.stopTest();
        
        System.assert(true, 'Should complete without recursion errors');
    }
    
    @isTest
    static void testDocumentedClassHighValue() {
        Opportunity opp = new Opportunity(
            Name = 'Test Documented High Value',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 200000,
            Discount_Percent__c = 12
        );
        
        Test.startTest();
        OpportunityDiscountValidator.validateDiscounts(new List<Opportunity>{opp});
        Test.stopTest();
        
        System.assertEquals(true, opp.Requires_Approval__c, 'Should require approval');
        System.assertEquals('VP Sales', opp.Approval_Level__c, 'Should route to VP Sales');
    }
    
    @isTest
    static void testDocumentedClassMediumValue() {
        Opportunity opp = new Opportunity(
            Name = 'Test Documented Medium Value',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 60000,
            Discount_Percent__c = 10
        );
        
        Test.startTest();
        OpportunityDiscountValidator.validateDiscounts(new List<Opportunity>{opp});
        Test.stopTest();
        
        System.assertEquals(false, opp.Requires_Approval__c, 'Should not require approval');
        System.assertEquals('Sales Manager', opp.Approval_Level__c, 'Should be Sales Manager level');
    }
    
    @isTest
    static void testDocumentedClassLowValue() {
        Opportunity opp = new Opportunity(
            Name = 'Test Documented Low Value',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 30000,
            Discount_Percent__c = 22
        );
        
        Test.startTest();
        OpportunityDiscountValidator.validateDiscounts(new List<Opportunity>{opp});
        Test.stopTest();
        
        System.assertEquals(true, opp.Requires_Approval__c, 'Should require approval');
        System.assertEquals('Team Lead', opp.Approval_Level__c, 'Should be Team Lead level');
    }
    
    @isTest
    static void testDocumentedClassSmallValue() {
        Opportunity opp = new Opportunity(
            Name = 'Test Documented Small Value',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = 8000,
            Discount_Percent__c = 20
        );
        
        Test.startTest();
        OpportunityDiscountValidator.validateDiscounts(new List<Opportunity>{opp});
        Test.stopTest();
        
        System.assertEquals(false, opp.Requires_Approval__c, 'Should not require approval');
        System.assertEquals('Auto-Approved', opp.Approval_Level__c, 'Should be auto-approved');
    }
    
    @isTest
    static void testDocumentedClassNullValues() {
        Opportunity opp = new Opportunity(
            Name = 'Test Documented Null',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30),
            Amount = null,
            Discount_Percent__c = null
        );
        
        Test.startTest();
        OpportunityDiscountValidator.validateDiscounts(new List<Opportunity>{opp});
        Test.stopTest();
        
        System.assertEquals(null, opp.Max_Allowed_Discount__c, 'Should not set max discount');
    }
}