trigger ProjectScoreWeightedScoreTrigger on Project_Score_Tracker__c (before insert, before update) {
    // Call the handler method to calculate weighted scores
    ProjectScoreWeightedScoreHandler.calculateWeightedScore(Trigger.new);
}