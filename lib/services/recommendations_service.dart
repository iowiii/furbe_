class RecommendationsService {
  String getRecommendation(String mood) {
    switch (mood) {
      case 'happy':
        return 'Keep up the good care and continue daily play!';
      case 'sad':
        return 'Spend more bonding time and check for possible health issues.';
      case 'angry':
        return 'Avoid stressful situations and give them space.';
      case 'scared':
        return 'Provide comfort and a safe environment.';
      default:
        return 'No recommendation available.';
    }
  }
}
