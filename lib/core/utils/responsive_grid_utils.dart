class ResponsiveGridUtils {
  /// Calculates the appropriate cross axis count based on screen width
  static GridConfig getGridConfig(double screenWidth, {bool isProductGrid = false}) {
    int crossAxisCount;
    double childAspectRatio;
    
    if (screenWidth >= 1200) {
      // Large screens (desktop)
      crossAxisCount = 4;
      childAspectRatio = isProductGrid ? 0.85 : 1.3;
    } else if (screenWidth >= 800) {
      // Medium screens (tablet/small desktop)
      crossAxisCount = 3;
      childAspectRatio = isProductGrid ? 0.8 : 1.2;
    } else {
      // Small screens (mobile)
      crossAxisCount = 2;
      childAspectRatio = isProductGrid ? 0.8 : 1.2;
    }
    
    return GridConfig(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
    );
  }
}

class GridConfig {
  final int crossAxisCount;
  final double childAspectRatio;
  
  const GridConfig({
    required this.crossAxisCount,
    required this.childAspectRatio,
  });
} 