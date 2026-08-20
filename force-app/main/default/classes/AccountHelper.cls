public with sharing class AccountHelper {

    /**
     * @description Retrieves a single Account record by its Id.
     * @param       accountId The Id of the Account to retrieve.
     * @return      Account record, or null if not found. Testing123
     */
    public static Account getAccountById(Id accountId) {
        if (accountId == null) {
            return null;
        }
        List<Account> accounts = [
            SELECT Id, Name, Phone, Industry, Active__c
            FROM Account
            WHERE Id = :accountId
            LIMIT 1
        ];
        return accounts.isEmpty() ? null : accounts[0];
    }

    /**
     * @description Updates the Name of an Account identified by its Id.
     * @param       accountId The Id of the Account to update.
     * @param       newName   The new name to assign to the Account.
     * @return      Boolean true if update was successful, false otherwise.
     */
    public static Boolean updateAccountName(Id accountId, String newName) {
        if (accountId == null || String.isBlank(newName)) {
            return false;
        }
        try {
            Account acc = new Account(Id = accountId, Name = newName);
            update acc;
            return true;
        } catch (DmlException e) {
            System.debug('Error updating Account: ' + e.getMessage());
            return false;
        }
    }

    /**
     * @description Retrieves all active Account records.
     * @return      List of active Account records.
     */
    public static List<Account> getActiveAccounts() {
        return [
            SELECT Id, Name, Phone, Industry
            FROM Account
            WHERE Active__c = 'Yes'
            ORDER BY Name ASC
        ];
    }
}