import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/mosque.dart';
import '../services/mosque_service.dart';
import '../services/local_storage_service.dart';

class MosqueFinderScreen extends StatefulWidget {
  const MosqueFinderScreen({super.key});

  @override
  State<MosqueFinderScreen> createState() => _MosqueFinderScreenState();
}

class _MosqueFinderScreenState extends State<MosqueFinderScreen> {
  final MosqueService _mosqueService = MosqueService();
  final LocalStorageService _localStorage = LocalStorageService();
  final MapController _mapController = MapController();
  
  List<Mosque> _mosques = [];
  Position? _currentPosition;
  bool _isLoading = true;
  String? _error;
  bool _showMap = false;
  
  @override
  void initState() {
    super.initState();
    _checkApiKeyAndLoadMosques();
  }
  
  Future<void> _checkApiKeyAndLoadMosques() async {
    final apiKey = await _localStorage.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      setState(() {
        _error = 'API key not set. Please add your Geoapify API key in settings.';
        _isLoading = false;
      });
      _showApiKeyDialog();
    } else {
      _loadNearbyMosques();
    }
  }
  
  Future<void> _loadNearbyMosques() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      _currentPosition = await _mosqueService.getCurrentLocation();
      
      _mosques = await _mosqueService.getNearbyMosques(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
      );
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.nearbyMosques),
        actions: [
          if (!_isLoading && _mosques.isNotEmpty)
            IconButton(
              icon: Icon(_showMap ? Icons.list : Icons.map),
              onPressed: () {
                setState(() {
                  _showMap = !_showMap;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNearbyMosques,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        if (_error!.contains('API key'))
                          ElevatedButton.icon(
                            onPressed: _showApiKeyDialog,
                            icon: const Icon(Icons.key),
                            label: Text(l10n.enterApiKey),
                          )
                        else
                          ElevatedButton(
                            onPressed: _loadNearbyMosques,
                            child: Text(l10n.retry),
                          ),
                      ],
                    ),
                  ),
                )
              : _mosques.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.mosque, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(l10n.noResults),
                        ],
                      ),
                    )
                  : _showMap
                      ? _buildMapView()
                      : _buildListView(),
    );
  }
  
  Widget _buildListView() {
    final l10n = AppLocalizations.of(context)!;
    
    return RefreshIndicator(
      onRefresh: _loadNearbyMosques,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mosques.length,
        itemBuilder: (context, index) {
          final mosque = _mosques[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.mosque),
              ),
              title: Text(
                mosque.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mosque.address != null)
                    Text(
                      mosque.address!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        mosque.formattedDistance,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.directions),
                onPressed: () {
                  // Open in maps app or show directions
                  _showDirectionsDialog(mosque);
                },
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildMapView() {
    if (_currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final userLocation = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );
    
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: userLocation,
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.qurancompanion.app',
        ),
        MarkerLayer(
          markers: [
            // User location marker
            Marker(
              point: userLocation,
              width: 80,
              height: 80,
              child: Icon(
                Icons.my_location,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
            ),
            // Mosque markers
            ..._mosques.map((mosque) => Marker(
              point: mosque.location,
              width: 80,
              height: 80,
              child: GestureDetector(
                onTap: () {
                  _showMosqueDetails(mosque);
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mosque,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      child: Text(
                        mosque.formattedDistance,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ],
    );
  }
  
  void _showMosqueDetails(Mosque mosque) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mosque.name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (mosque.address != null) ...[
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(mosque.address!),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                const Icon(Icons.straighten, size: 16),
                const SizedBox(width: 8),
                Text(mosque.formattedDistance),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDirectionsDialog(mosque);
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('Directions'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  void _showDirectionsDialog(Mosque mosque) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Get Directions'),
        content: Text('Open directions to ${mosque.name} in your maps app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Here you would typically open the maps app
              // For now, just show a snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening directions to ${mosque.name}...'),
                ),
              );
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
  
  void _showApiKeyDialog() {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.enterApiKey),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'To find nearby mosques, you need a free Geoapify API key.\n\n'
              'Get yours at:\nhttps://myprojects.geoapify.com/',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter your API key',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _localStorage.setApiKey(controller.text);
                Navigator.pop(context);
                _loadNearbyMosques();
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}