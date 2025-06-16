import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/services/location_service.dart';
import '../../../farm/presentation/providers/farm_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/states/auth_state.dart';
import '../providers/weather_provider.dart';
import '../../domain/entities/weather.dart';

/// Detailed weather screen with farm location selection
class DetailedWeatherScreen extends ConsumerStatefulWidget {
  const DetailedWeatherScreen({super.key});

  @override
  ConsumerState<DetailedWeatherScreen> createState() =>
      _DetailedWeatherScreenState();
}

class _DetailedWeatherScreenState extends ConsumerState<DetailedWeatherScreen> {
  String _selectedLocationId = 'current'; // 'current' or farm ID
  String _selectedLocationName = 'Current Location';
  double? _selectedLat;
  double? _selectedLng;

  @override
  void initState() {
    super.initState();
    _initializeCurrentLocation();

    // Safety timeout - if location isn't set after 10 seconds, use default
    Timer(const Duration(seconds: 10), () {
      if (mounted && (_selectedLat == null || _selectedLng == null)) {
        setState(() {
          _selectedLat = -6.7924; // Dar es Salaam coordinates
          _selectedLng = 39.2083;
          _selectedLocationName = 'Dar es Salaam (Default)';
        });
      }
    });
  }

  Future<void> _initializeCurrentLocation() async {
    try {
      // Check if permission is permanently denied
      final isPermanentlyDenied =
          await LocationService.isPermissionPermanentlyDenied();

      if (isPermanentlyDenied) {
        // Permission permanently denied, use default location
        _setDefaultLocation();
        return;
      }

      // Try to get current position (this will request permission if needed)
      final position = await LocationService.getCurrentPositionSafe(
        timeout: const Duration(
          seconds: 8,
        ), // Slightly longer timeout for permission dialog
      );

      if (position != null && mounted) {
        setState(() {
          _selectedLat = position.latitude;
          _selectedLng = position.longitude;
          _selectedLocationName = 'Current Location';
        });
        return;
      }
    } catch (e) {
      // GPS failed, continue to fallback
    }

    // Fallback to default location if GPS fails
    _setDefaultLocation();
  }

  void _setDefaultLocation() {
    if (mounted) {
      setState(() {
        _selectedLat = -6.7924; // Dar es Salaam coordinates
        _selectedLng = 39.2083;
        _selectedLocationName = 'Dar es Salaam (Default)';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);

    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view weather')),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Weather Details',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showLocationSelector(context),
            icon: const Icon(Icons.location_on),
            tooltip: 'Change Location',
          ),
        ],
      ),
      body: Column(
        children: [
          // Location selector header
          _buildLocationHeader(theme),

          // Weather content
          Expanded(child: _buildWeatherContent(theme)),
        ],
      ),
    );
  }

  Widget _buildLocationHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
            theme.colorScheme.secondary.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.spacing20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with icon and change button
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius8,
                    ),
                  ),
                  child: Icon(
                    _selectedLocationId == 'current'
                        ? Icons.my_location_rounded
                        : Icons.agriculture_rounded,
                    color: Colors.white,
                    size: ResponsiveUtils.iconSize20,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.spacing12),
                Expanded(
                  child: Text(
                    'Weather Location',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius20,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showLocationSelector(context),
                      borderRadius: BorderRadius.circular(
                        ResponsiveUtils.radius20,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.spacing16,
                          vertical: ResponsiveUtils.spacing8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swap_horiz_rounded,
                              color: Colors.white,
                              size: ResponsiveUtils.iconSize16,
                            ),
                            SizedBox(width: ResponsiveUtils.spacing6),
                            Text(
                              'Change',
                              style: GoogleFonts.inter(
                                fontSize: ResponsiveUtils.fontSize13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: ResponsiveUtils.height16),

            // Location name and details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedLocationName,
                        style: GoogleFonts.poppins(
                          fontSize: ResponsiveUtils.fontSize20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.height4),
                      if (_selectedLat != null && _selectedLng != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.spacing8,
                            vertical: ResponsiveUtils.spacing4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(
                              ResponsiveUtils.radius6,
                            ),
                          ),
                          child: Text(
                            '${_selectedLat!.toStringAsFixed(4)}, ${_selectedLng!.toStringAsFixed(4)}',
                            style: GoogleFonts.robotoMono(
                              fontSize: ResponsiveUtils.fontSize11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Status indicator
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.spacing12,
                    vertical: ResponsiveUtils.spacing6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _selectedLocationId == 'current'
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      ResponsiveUtils.radius12,
                    ),
                    border: Border.all(
                      color:
                          _selectedLocationId == 'current'
                              ? Colors.green.withValues(alpha: 0.4)
                              : Colors.blue.withValues(alpha: 0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color:
                              _selectedLocationId == 'current'
                                  ? Colors.green
                                  : Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: ResponsiveUtils.spacing6),
                      Text(
                        _selectedLocationId == 'current'
                            ? 'Live GPS'
                            : 'Farm Location',
                        style: GoogleFonts.inter(
                          fontSize: ResponsiveUtils.fontSize11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherContent(ThemeData theme) {
    if (_selectedLat == null || _selectedLng == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            SizedBox(height: ResponsiveUtils.height16),
            Text(
              'Getting your location...',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: ResponsiveUtils.height8),
            Text(
              'This may take a few seconds',
              style: GoogleFonts.inter(
                fontSize: ResponsiveUtils.fontSize14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            SizedBox(height: ResponsiveUtils.height24),
            ElevatedButton(
              onPressed: () {
                // Force fallback to default location
                setState(() {
                  _selectedLat = -6.7924; // Dar es Salaam coordinates
                  _selectedLng = 39.2083;
                  _selectedLocationName = 'Dar es Salaam (Default)';
                });
              },
              child: const Text('Use Default Location'),
            ),
          ],
        ),
      );
    }

    final weatherAsync = ref.watch(
      weatherByCoordinatesProvider((lat: _selectedLat!, lon: _selectedLng!)),
    );

    return weatherAsync.when(
      data: (weatherData) => _buildDetailedWeatherView(theme, weatherData),
      loading: () => _buildWeatherLoading(theme),
      error: (error, stack) => _buildWeatherError(theme, error),
    );
  }

  Widget _buildDetailedWeatherView(ThemeData theme, WeatherData weatherData) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(
          weatherByCoordinatesProvider((
            lat: _selectedLat!,
            lon: _selectedLng!,
          )),
        );
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current weather overview
            _buildCurrentWeatherCard(theme, weatherData.current),

            SizedBox(height: ResponsiveUtils.height20),

            // Detailed metrics
            _buildDetailedMetrics(theme, weatherData.current),

            SizedBox(height: ResponsiveUtils.height20),

            // Hourly forecast
            _buildHourlyForecast(theme, weatherData),

            SizedBox(height: ResponsiveUtils.height20),

            // Daily forecast
            _buildDailyForecast(theme, weatherData),

            SizedBox(height: ResponsiveUtils.height20),

            // Farming insights
            _buildFarmingInsights(theme, weatherData.current),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeatherCard(ThemeData theme, CurrentWeather current) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: ResponsiveUtils.spacing8,
            offset: Offset(0, ResponsiveUtils.spacing4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${current.temperature.round()}°C',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.fontSize48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    current.condition.description,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  Text(
                    'Feels like ${current.feelsLike.round()}°C',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              Icon(
                _getWeatherIcon(current.condition.main),
                size: ResponsiveUtils.iconSize64,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMetrics(ThemeData theme, CurrentWeather current) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Conditions',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height12),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: ResponsiveUtils.spacing12,
          mainAxisSpacing: ResponsiveUtils.spacing12,
          children: [
            _buildMetricCard(
              theme,
              'Humidity',
              '${current.humidity}%',
              Icons.water_drop,
            ),
            _buildMetricCard(
              theme,
              'Wind Speed',
              '${current.windSpeed.toStringAsFixed(1)} km/h',
              Icons.air,
            ),
            _buildMetricCard(
              theme,
              'Pressure',
              '${current.pressure} hPa',
              Icons.compress,
            ),
            _buildMetricCard(
              theme,
              'UV Index',
              current.uvIndex.toStringAsFixed(1),
              Icons.wb_sunny,
            ),
            _buildMetricCard(
              theme,
              'Visibility',
              '${(current.visibility / 1000).toStringAsFixed(1)} km',
              Icons.visibility,
            ),
            _buildMetricCard(
              theme,
              'Wind Direction',
              '${current.windDirection}°',
              Icons.navigation,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.spacing12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: ResponsiveUtils.iconSize20,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: ResponsiveUtils.spacing8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize12,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(ThemeData theme, WeatherData weatherData) {
    // For now, we'll create mock hourly data since the API might not provide it
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hourly Forecast',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height12),

        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 24,
            itemBuilder: (context, index) {
              final hour = DateTime.now().add(Duration(hours: index));
              final temp =
                  weatherData.current.temperature +
                  (index % 3 - 1) * 2; // Mock variation

              return Container(
                width: 80,
                margin: EdgeInsets.only(right: ResponsiveUtils.spacing12),
                padding: EdgeInsets.all(ResponsiveUtils.spacing12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${hour.hour}:00',
                      style: GoogleFonts.inter(
                        fontSize: ResponsiveUtils.fontSize12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    Icon(
                      _getWeatherIcon(weatherData.current.condition.main),
                      size: ResponsiveUtils.iconSize24,
                      color: theme.colorScheme.primary,
                    ),
                    Text(
                      '${temp.round()}°',
                      style: GoogleFonts.poppins(
                        fontSize: ResponsiveUtils.fontSize14,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDailyForecast(ThemeData theme, WeatherData weatherData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '5-Day Forecast',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height12),

        ...weatherData.fiveDayForecast.map((forecast) {
          return Container(
            margin: EdgeInsets.only(bottom: ResponsiveUtils.spacing8),
            padding: EdgeInsets.all(ResponsiveUtils.spacing16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    forecast.dayName,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  _getWeatherIcon(forecast.condition.main),
                  size: ResponsiveUtils.iconSize24,
                  color: theme.colorScheme.primary,
                ),
                SizedBox(width: ResponsiveUtils.spacing12),
                Expanded(
                  child: Text(
                    forecast.condition.description,
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                Text(
                  forecast.temperatureRange,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFarmingInsights(ThemeData theme, CurrentWeather current) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Farming Insights',
          style: GoogleFonts.poppins(
            fontSize: ResponsiveUtils.fontSize18,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: ResponsiveUtils.height12),

        // UV Index insight
        _buildInsightCard(
          theme,
          'UV Protection',
          _getUVInsight(current.uvIndex),
          Icons.wb_sunny,
          _getUVColor(current.uvIndex),
        ),

        SizedBox(height: ResponsiveUtils.height8),

        // Humidity insight
        _buildInsightCard(
          theme,
          'Irrigation',
          _getHumidityInsight(current.humidity),
          Icons.water_drop,
          _getHumidityColor(current.humidity),
        ),

        SizedBox(height: ResponsiveUtils.height8),

        // Wind insight
        _buildInsightCard(
          theme,
          'Wind Conditions',
          _getWindInsight(current.windSpeed),
          Icons.air,
          _getWindColor(current.windSpeed),
        ),

        SizedBox(height: ResponsiveUtils.height8),

        // Temperature insight
        _buildInsightCard(
          theme,
          'Crop Care',
          _getTemperatureInsight(current.temperature),
          Icons.thermostat,
          _getTemperatureColor(current.temperature),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
    ThemeData theme,
    String title,
    String insight,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.spacing16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.radius12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.spacing8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(ResponsiveUtils.radius8),
            ),
            child: Icon(icon, size: ResponsiveUtils.iconSize20, color: color),
          ),
          SizedBox(width: ResponsiveUtils.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.height4),
                Text(
                  insight,
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherLoading(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          SizedBox(height: ResponsiveUtils.height16),
          Text(
            'Loading weather data...',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherError(ThemeData theme, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ResponsiveUtils.iconSize48,
            color: theme.colorScheme.error,
          ),
          SizedBox(height: ResponsiveUtils.height16),
          Text(
            'Unable to load weather data',
            style: GoogleFonts.poppins(
              fontSize: ResponsiveUtils.fontSize18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: ResponsiveUtils.height8),
          Text(
            'Please check your internet connection and try again',
            style: GoogleFonts.inter(
              fontSize: ResponsiveUtils.fontSize14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.height24),
          ElevatedButton(
            onPressed: () {
              if (_selectedLat != null && _selectedLng != null) {
                ref.invalidate(
                  weatherByCoordinatesProvider((
                    lat: _selectedLat!,
                    lon: _selectedLng!,
                  )),
                );
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showLocationSelector(BuildContext context) {
    final authState = ref.read(authProvider);
    if (authState is! AuthAuthenticated) return;

    final farmsAsync = ref.watch(farmsListProvider(authState.user.id));
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(ResponsiveUtils.radius20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: ResponsiveUtils.spacing8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Padding(
                  padding: EdgeInsets.all(ResponsiveUtils.spacing16),
                  child: Text(
                    'Select Location',
                    style: GoogleFonts.poppins(
                      fontSize: ResponsiveUtils.fontSize18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),

                // Current location option
                ListTile(
                  leading: Icon(
                    Icons.my_location,
                    color:
                        _selectedLocationId == 'current'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                  title: Text(
                    'Current Location',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize16,
                      fontWeight:
                          _selectedLocationId == 'current'
                              ? FontWeight.w600
                              : FontWeight.w500,
                      color:
                          _selectedLocationId == 'current'
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Use device GPS location',
                    style: GoogleFonts.inter(
                      fontSize: ResponsiveUtils.fontSize14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  trailing:
                      _selectedLocationId == 'current'
                          ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                          )
                          : null,
                  onTap: () async {
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);

                    try {
                      // Check if permission is permanently denied
                      final isPermanentlyDenied =
                          await LocationService.isPermissionPermanentlyDenied();

                      if (isPermanentlyDenied) {
                        // Show dialog to open settings
                        if (mounted) {
                          _showPermissionSettingsDialog(scaffoldMessenger);
                        }
                        return;
                      }

                      final position =
                          await LocationService.getCurrentPositionSafe(
                            timeout: const Duration(seconds: 8),
                          );

                      if (position != null && mounted) {
                        setState(() {
                          _selectedLocationId = 'current';
                          _selectedLocationName = 'Current Location';
                          _selectedLat = position.latitude;
                          _selectedLng = position.longitude;
                        });
                      } else {
                        // GPS failed, show error and keep current location
                        if (mounted) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Unable to get current location. Please check GPS settings and permissions.',
                              ),
                              duration: Duration(seconds: 4),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      // GPS error, show error message
                      if (mounted) {
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Location access failed. Please enable GPS and grant location permission.',
                            ),
                            duration: Duration(seconds: 4),
                          ),
                        );
                      }
                    }
                  },
                ),

                // Farm locations
                farmsAsync.when(
                  data:
                      (farms) => Column(
                        children:
                            farms.map((farm) {
                              final isSelected = _selectedLocationId == farm.id;
                              final hasCoordinates =
                                  farm.coordinates != null &&
                                  farm.coordinates!['lat'] != null &&
                                  farm.coordinates!['lng'] != null;

                              return ListTile(
                                leading: Icon(
                                  Icons.agriculture,
                                  color:
                                      isSelected
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.primary
                                          : hasCoordinates
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.onSurface
                                          : Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.4),
                                ),
                                title: Text(
                                  farm.name,
                                  style: GoogleFonts.inter(
                                    fontSize: ResponsiveUtils.fontSize16,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                    color:
                                        isSelected
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                            : hasCoordinates
                                            ? Theme.of(
                                              context,
                                            ).colorScheme.onSurface
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.4),
                                  ),
                                ),
                                subtitle: Text(
                                  hasCoordinates
                                      ? farm.location
                                      : 'No GPS coordinates available',
                                  style: GoogleFonts.inter(
                                    fontSize: ResponsiveUtils.fontSize14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                trailing:
                                    isSelected
                                        ? Icon(
                                          Icons.check_circle,
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                        )
                                        : null,
                                enabled: hasCoordinates,
                                onTap:
                                    hasCoordinates
                                        ? () {
                                          Navigator.pop(context);
                                          setState(() {
                                            _selectedLocationId = farm.id;
                                            _selectedLocationName = farm.name;
                                            _selectedLat =
                                                (farm.coordinates!['lat']
                                                        as num)
                                                    .toDouble();
                                            _selectedLng =
                                                (farm.coordinates!['lng']
                                                        as num)
                                                    .toDouble();
                                          });
                                        }
                                        : null,
                              );
                            }).toList(),
                      ),
                  loading:
                      () => const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                  error:
                      (error, stack) => Padding(
                        padding: EdgeInsets.all(ResponsiveUtils.spacing16),
                        child: Text(
                          'Unable to load farms',
                          style: GoogleFonts.inter(
                            fontSize: ResponsiveUtils.fontSize14,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                ),

                SizedBox(height: ResponsiveUtils.height16),
              ],
            ),
          ),
    );
  }

  // Helper methods for weather icons and farming insights
  IconData _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.grain;
      case 'drizzle':
        return Icons.grain;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      case 'mist':
      case 'fog':
        return Icons.cloud;
      default:
        return Icons.wb_sunny;
    }
  }

  String _getUVInsight(double uvIndex) {
    if (uvIndex <= 2) {
      return 'Low UV levels. Safe for extended outdoor work without protection.';
    } else if (uvIndex <= 5) {
      return 'Moderate UV levels. Use sun protection during midday hours.';
    } else if (uvIndex <= 7) {
      return 'High UV levels. Seek shade during midday. Use sun protection.';
    } else if (uvIndex <= 10) {
      return 'Very high UV levels. Minimize outdoor exposure 10am-4pm.';
    } else {
      return 'Extreme UV levels. Avoid outdoor work during peak hours.';
    }
  }

  Color _getUVColor(double uvIndex) {
    if (uvIndex <= 2) {
      return Colors.green;
    } else if (uvIndex <= 5) {
      return Colors.yellow;
    } else if (uvIndex <= 7) {
      return Colors.orange;
    } else if (uvIndex <= 10) {
      return Colors.red;
    } else {
      return Colors.purple;
    }
  }

  String _getHumidityInsight(int humidity) {
    if (humidity < 30) {
      return 'Low humidity. Increase irrigation frequency. Monitor plant stress.';
    } else if (humidity < 60) {
      return 'Optimal humidity levels. Maintain current irrigation schedule.';
    } else if (humidity < 80) {
      return 'High humidity. Reduce irrigation. Monitor for fungal diseases.';
    } else {
      return 'Very high humidity. Risk of fungal diseases. Improve ventilation.';
    }
  }

  Color _getHumidityColor(int humidity) {
    if (humidity < 30) {
      return Colors.orange;
    } else if (humidity < 60) {
      return Colors.green;
    } else if (humidity < 80) {
      return Colors.blue;
    } else {
      return Colors.red;
    }
  }

  String _getWindInsight(double windSpeed) {
    if (windSpeed < 5) {
      return 'Calm conditions. Good for spraying pesticides and fertilizers.';
    } else if (windSpeed < 15) {
      return 'Light breeze. Suitable for most farming activities.';
    } else if (windSpeed < 25) {
      return 'Moderate wind. Avoid spraying. Secure loose materials.';
    } else if (windSpeed < 35) {
      return 'Strong wind. Postpone spraying. Risk of crop damage.';
    } else {
      return 'Very strong wind. Avoid outdoor work. Secure equipment.';
    }
  }

  Color _getWindColor(double windSpeed) {
    if (windSpeed < 5) {
      return Colors.green;
    } else if (windSpeed < 15) {
      return Colors.blue;
    } else if (windSpeed < 25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _getTemperatureInsight(double temperature) {
    if (temperature < 10) {
      return 'Cold conditions. Protect sensitive crops from frost damage.';
    } else if (temperature < 20) {
      return 'Cool weather. Good for cool-season crops. Monitor growth.';
    } else if (temperature < 30) {
      return 'Optimal temperature. Ideal conditions for most crops.';
    } else if (temperature < 35) {
      return 'Hot weather. Increase irrigation. Provide shade if needed.';
    } else {
      return 'Very hot. Risk of heat stress. Increase watering frequency.';
    }
  }

  Color _getTemperatureColor(double temperature) {
    if (temperature < 10) {
      return Colors.blue;
    } else if (temperature < 20) {
      return Colors.lightBlue;
    } else if (temperature < 30) {
      return Colors.green;
    } else if (temperature < 35) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  /// Show dialog for permission settings
  void _showPermissionSettingsDialog(ScaffoldMessengerState scaffoldMessenger) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Location Permission Required',
              style: GoogleFonts.poppins(
                fontSize: ResponsiveUtils.fontSize18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Text(
              'Location permission has been permanently denied. To use your current location for weather, please enable location permission in app settings.',
              style: GoogleFonts.inter(fontSize: ResponsiveUtils.fontSize14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final opened = await LocationService.openAppSettings();
                  if (!opened && mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Unable to open app settings. Please open settings manually.',
                        ),
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
                child: Text(
                  'Open Settings',
                  style: GoogleFonts.inter(
                    fontSize: ResponsiveUtils.fontSize14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
