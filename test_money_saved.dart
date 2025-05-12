void main() {
  // Test 1: Calculate money saved for 5 days without smoking
  testMoneySaved(
    daysWithoutSmoking: 5,
    cigarettesPerDay: 20,
    packPrice: 1200, // R$12,00 in cents
    cigarettesPerPack: 20
  );
  
  // Test 2: Calculate money saved for 10 days with different parameters
  testMoneySaved(
    daysWithoutSmoking: 10,
    cigarettesPerDay: 15,
    packPrice: 1500, // R$15,00 in cents
    cigarettesPerPack: 20
  );
  
  // Test 3: More expensive cigarettes
  testMoneySaved(
    daysWithoutSmoking: 7,
    cigarettesPerDay: 20,
    packPrice: 2000, // R$20,00 in cents
    cigarettesPerPack: 20
  );
  
  // Test 4: Edge case - 0 days
  testMoneySaved(
    daysWithoutSmoking: 0,
    cigarettesPerDay: 20,
    packPrice: 1200,
    cigarettesPerPack: 20
  );
}

void testMoneySaved({
  required int daysWithoutSmoking,
  required int cigarettesPerDay,
  required int packPrice,
  required int cigarettesPerPack,
}) {
  // Calculate cigarettes avoided based on days without smoking
  final cigarettesAvoided = daysWithoutSmoking * cigarettesPerDay;
  
  // Calculate price per cigarette
  final pricePerCigarette = packPrice / cigarettesPerPack;
  
  // Calculate money saved in cents
  final moneySaved = (cigarettesAvoided * pricePerCigarette).round();
  
  // Money saved per day
  final dailySavings = daysWithoutSmoking > 0 
      ? moneySaved / daysWithoutSmoking 
      : 0;
  
  // Monthly projected savings (30 days)
  final monthlySavings = dailySavings * 30;
  
  // Format money values
  final formattedMoneySaved = (moneySaved / 100).toStringAsFixed(2);
  final formattedDailySavings = (dailySavings / 100).toStringAsFixed(2);
  final formattedMonthlySavings = (monthlySavings / 100).toStringAsFixed(2);
  
  // Print results
  print('==== TEST: $daysWithoutSmoking days without smoking ====');
  print('Input parameters:');
  print('- Days without smoking: $daysWithoutSmoking');
  print('- Cigarettes per day: $cigarettesPerDay');
  print('- Pack price: R\$$packPrice/100');
  print('- Cigarettes per pack: $cigarettesPerPack');
  print('Calculation results:');
  print('- Price per cigarette: R\$${(pricePerCigarette/100).toStringAsFixed(2)}');
  print('- Cigarettes avoided: $cigarettesAvoided');
  print('- Money saved: R\$$formattedMoneySaved');
  print('- Daily savings average: R\$$formattedDailySavings');
  print('- Projected monthly savings: R\$$formattedMonthlySavings');
  print('');
}