import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/skeleton/skeleton_bloc.dart';
import 'package:nicotinaai_flutter/blocs/skeleton/skeleton_event.dart';
import 'package:nicotinaai_flutter/blocs/skeleton/skeleton_state.dart' as skeleton_state;
import 'package:nicotinaai_flutter/core/theme/app_theme.dart';
import 'package:nicotinaai_flutter/widgets/skeleton_loading.dart';

/// Um wrapper para exibir skeleton loading para números
/// enquanto estão sendo carregados
class NumberSkeletonWrapper<T> extends StatelessWidget {
  /// Valor a ser exibido quando carregado
  final T value;
  
  /// Função para formatar o valor como string
  final String Function(T) formatter;
  
  /// Estilo do texto para o valor
  final TextStyle? style;
  
  /// Verificador para saber se deve mostrar skeleton
  final bool isLoading;
  
  /// Largura do skeleton (opcional, adapta ao conteúdo se não fornecido)
  final double? skeletonWidth;
  
  /// Altura do skeleton
  final double skeletonHeight;
  
  /// Raio da borda do skeleton
  final double skeletonBorderRadius;

  const NumberSkeletonWrapper({
    Key? key,
    required this.value,
    required this.formatter,
    required this.isLoading,
    this.style,
    this.skeletonWidth,
    this.skeletonHeight = 24.0,
    this.skeletonBorderRadius = 4.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SkeletonLoading(
        width: skeletonWidth ?? _estimateWidth(context),
        height: skeletonHeight,
        borderRadius: skeletonBorderRadius,
      );
    } else {
      return Text(
        formatter(value),
        style: style ?? context.textTheme.headlineMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: context.contentColor,
          fontSize: 24,
        ),
      );
    }
  }
  
  /// Estima a largura com base no valor formatado e no estilo
  double _estimateWidth(BuildContext context) {
    // Largura base que funciona bem para a maioria dos números na UI
    final String formattedValue = formatter(value);
    
    // Ajustar largura com base no número de caracteres (aproximado)
    double baseWidth = 60.0; // largura mínima
    
    // Estimativa melhorada com base no comprimento do texto
    if (formattedValue.length > 3) {
      return baseWidth + (formattedValue.length - 3) * 10;
    }
    
    return baseWidth;
  }
}

/// Uma versão especializada para exibir skeleton loading para valores monetários
class MoneySkeletonWrapper extends StatelessWidget {
  /// Valor em centavos
  final int valueInCents;
  
  /// Função de formatação de moeda
  final String Function(int) formatter;
  
  /// Verificador para saber se deve mostrar skeleton
  final bool isLoading;
  
  /// Estilo do texto para o valor
  final TextStyle? style;

  const MoneySkeletonWrapper({
    Key? key,
    required this.valueInCents,
    required this.formatter,
    required this.isLoading,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SkeletonLoading(
        width: 120, // Valores monetários geralmente precisam de mais espaço
        height: 28,
        borderRadius: 4,
      );
    } else {
      return Text(
        formatter(valueInCents),
        style: style ?? context.textTheme.headlineMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: context.contentColor,
          fontSize: 28,
        ),
      );
    }
  }
}