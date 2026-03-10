import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/routes.dart';
import '../../../../core/services/tutorial_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();

    // Verificar se deve mostrar tutorial e navegar
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        // Verificar se é a primeira vez que o usuário abre o app
        if (TutorialService.shouldShowTutorial()) {
          context.go(AppRoutes.tutorial);
        } else {
          context.go(AppRoutes.dashboard);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colors = Theme.of(context).colorScheme;
    
    // Tamanho adaptativo do logo baseado no tamanho da tela
    final logoSize = size.shortestSide * 0.45; // 45% da menor dimensão

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primary,
              colors.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: size.height,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Logo com tamanho adaptativo
                            Container(
                              width: logoSize,
                              height: logoSize,
                              padding: EdgeInsets.all(logoSize * 0.15),
                              decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/icons/icon-512.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback para ícone material se a imagem não carregar
                                return Icon(
                                  Icons.receipt_long_rounded,
                                  size: logoSize * 0.6,
                                  color: colors.primary,
                                );
                              },
                            ),
                          ),
                        ),
                        
                        SizedBox(height: size.height * 0.05),
                        
                        // Nome da app
                        Text(
                          'Facturio',
                          style: TextStyle(
                            fontSize: size.width * 0.12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        
                        SizedBox(height: size.height * 0.01),
                        
                        // Subtítulo
                        Text(
                          'Sistema de Faturação',
                          style: TextStyle(
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.5,
                          ),
                        ),
                        
                        SizedBox(height: size.height * 0.08),
                        
                        // Loading indicator
                        SizedBox(
                          width: logoSize * 0.35,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            minHeight: 3,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ],
                    ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
