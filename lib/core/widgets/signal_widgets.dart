import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// A builder widget that reactively rebuilds when a signal changes.
/// 
/// This is a convenience wrapper around SignalBuilder for simpler usage.
class SignalValueBuilder<T> extends StatelessWidget {
  final Signal<T> signal;
  final Widget Function(BuildContext context, T value) builder;
  
  const SignalValueBuilder({
    Key? key,
    required this.signal,
    required this.builder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      signal: signal,
      builder: (context, value) => builder(context, value),
    );
  }
}

/// A builder widget that reactively rebuilds when a computed signal changes.
class ComputedBuilder<T> extends StatelessWidget {
  final Computed<T> computed;
  final Widget Function(BuildContext context, T value) builder;
  
  const ComputedBuilder({
    Key? key,
    required this.computed,
    required this.builder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      signal: computed,
      builder: (context, value) => builder(context, value),
    );
  }
}

/// A builder widget that shows different content based on a boolean signal.
class SignalConditionalBuilder extends StatelessWidget {
  final Signal<bool> condition;
  final Widget Function(BuildContext context) trueBuilder;
  final Widget Function(BuildContext context) falseBuilder;
  
  const SignalConditionalBuilder({
    Key? key,
    required this.condition,
    required this.trueBuilder,
    required this.falseBuilder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      signal: condition,
      builder: (context, isTrue) {
        return isTrue ? trueBuilder(context) : falseBuilder(context);
      },
    );
  }
}

/// A builder widget that handles loading and error states reactively.
class SignalStateBuilder<T> extends StatelessWidget {
  final Signal<bool> isLoading;
  final Signal<String?> error;
  final Signal<T?> data;
  final Widget Function(BuildContext context) loadingBuilder;
  final Widget Function(BuildContext context, String error) errorBuilder;
  final Widget Function(BuildContext context, T data) contentBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;
  
  const SignalStateBuilder({
    Key? key,
    required this.isLoading,
    required this.error,
    required this.data,
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.contentBuilder,
    this.emptyBuilder,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      signal: isLoading,
      builder: (context, loading) {
        if (loading) {
          return loadingBuilder(context);
        }
        
        return SignalBuilder(
          signal: error,
          builder: (context, errorMsg) {
            if (errorMsg != null && errorMsg.isNotEmpty) {
              return errorBuilder(context, errorMsg);
            }
            
            return SignalBuilder(
              signal: data,
              builder: (context, value) {
                if (value == null) {
                  return emptyBuilder?.call(context) ?? 
                      const Center(child: Text('No data available'));
                }
                
                return contentBuilder(context, value);
              },
            );
          },
        );
      },
    );
  }
}

/// A widget that rebuilds when any of the provided signals change.
class MultiSignalBuilder extends StatelessWidget {
  final List<Signal> signals;
  final Widget Function(BuildContext context) builder;
  
  const MultiSignalBuilder({
    Key? key, 
    required this.signals,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SignalListener(
      signals: signals,
      child: builder(context),
    );
  }
}

/// A widget that listens to signal errors and shows snackbars.
class SignalErrorListener extends StatelessWidget {
  final Signal<String?> errorSignal;
  final Widget child;
  final Duration duration;
  
  const SignalErrorListener({
    Key? key,
    required this.errorSignal,
    required this.child,
    this.duration = const Duration(seconds: 4),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      signal: errorSignal,
      builder: (context, error) {
        if (error != null && error.isNotEmpty) {
          // Use post-frame callback to avoid build-time snackbar
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                duration: duration,
                action: SnackBarAction(
                  label: 'Dismiss',
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
            
            // Clear the error after showing it
            errorSignal.value = null;
          });
        }
        
        return child;
      },
    );
  }
}