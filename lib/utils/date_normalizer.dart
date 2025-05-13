import 'package:flutter/foundation.dart';

/// Classe utilitária para normalização de datas entre UTC e local
/// Garante consistência nos cálculos baseados em datas em todo o aplicativo
class DateNormalizer {
  /// Converte qualquer DateTime para UTC
  /// Se já é UTC, retorna a data original
  static DateTime toUtc(DateTime date) {
    return date.isUtc ? date : date.toUtc();
  }
  
  /// Converte qualquer DateTime para local
  /// Se já é local, retorna a data original
  static DateTime toLocal(DateTime date) {
    return date.isUtc ? date.toLocal() : date;
  }
  
  /// Normaliza uma data para meia-noite UTC
  /// Isso é útil para comparações consistentes de dias
  static DateTime normalizeToMidnightUtc(DateTime date) {
    // Converter para UTC se necessário
    final dateUtc = toUtc(date);
    
    // Retornar nova data UTC com apenas ano, mês e dia (zera horas, minutos, segundos)
    return DateTime.utc(dateUtc.year, dateUtc.month, dateUtc.day);
  }
  
  /// Calcula a diferença em dias entre duas datas, usando normalização para meia-noite UTC
  /// Isso garante que a diferença seja baseada apenas na data, não na hora
  static int daysBetween(DateTime start, [DateTime? end]) {
    // Se end não for fornecido, usar agora UTC
    final endDate = end ?? DateTime.now().toUtc();
    
    // Normalizar ambas as datas para meia-noite UTC
    final startNormalized = normalizeToMidnightUtc(start);
    final endNormalized = normalizeToMidnightUtc(endDate);
    
    // Calcular diferença em dias
    return endNormalized.difference(startNormalized).inDays;
  }
  
  /// Verifica se duas datas correspondem ao mesmo dia (ignorando hora)
  /// Usa normalização UTC para garantir que a comparação seja consistente
  static bool isSameDay(DateTime date1, DateTime date2) {
    final date1Normalized = normalizeToMidnightUtc(date1);
    final date2Normalized = normalizeToMidnightUtc(date2);
    
    return date1Normalized.isAtSameMomentAs(date2Normalized);
  }
  
  /// Verifica se uma data corresponde ao dia atual
  /// Usa normalização UTC para garantir que a comparação seja consistente
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
  
  /// Retorna a meia-noite local do dia atual
  /// Útil para comparações de "hoje" baseadas no fuso horário do usuário
  static DateTime todayMidnightLocal() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
  
  /// Depura informações de datas para identificar problemas de fuso horário
  static void debugDate(String label, DateTime date) {
    if (!kDebugMode) return;
    
    print('🕰️ $label:');
    print('  - Original: ${date.toString()} (UTC: ${date.isUtc})');
    
    final dateUtc = toUtc(date);
    print('  - UTC: ${dateUtc.toString()} (UTC: ${dateUtc.isUtc})');
    
    final dateLocal = toLocal(date);
    print('  - Local: ${dateLocal.toString()} (UTC: ${dateLocal.isUtc})');
    
    final dateMidnightUtc = normalizeToMidnightUtc(date);
    print('  - Meia-noite UTC: ${dateMidnightUtc.toString()} (UTC: ${dateMidnightUtc.isUtc})');
  }
}