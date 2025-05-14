import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nicotinaai_flutter/blocs/connectivity/connectivity_bloc.dart';

class ConnectivityOverlay extends StatelessWidget {
  final Widget child;
  
  const ConnectivityOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityBloc, ConnectivityState>(
      builder: (context, state) {
        return Stack(
          fit: StackFit.expand,
          children: [
            child,
            if (state is ConnectivityDisconnected)
              _buildNoConnectionOverlay(context),
          ],
        );
      },
    );
  }
  
  Widget _buildNoConnectionOverlay(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'Sem conexão com a internet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Este aplicativo requer conexão com a internet para funcionar corretamente.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Disparar evento para verificar conexão novamente
                BlocProvider.of<ConnectivityBloc>(context).add(ConnectivityStarted());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}