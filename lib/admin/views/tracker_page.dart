import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vender_tracker/admin/cubit/admin_cubit.dart';
import 'package:vender_tracker/admin/cubit/admin_state.dart';
import 'package:vender_tracker/common/enums/page_status.dart';
import 'package:vender_tracker/common/ui/lottie_pages.dart';
import '../../common/models/user.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/location_entry_card.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TrackerPage extends StatelessWidget {

  final AdminState state;

  const TrackerPage({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {

    if (state.locPageStatus.isLoading) {
      return LoadingPage();
    }

    final l10n = AppLocalizations.of(context)!;
    final mapValues = state.locData.values.toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.all(12.0),
          child: DropdownButtonFormField<User>(
            value: state.locSelectedUser,
            decoration: InputDecoration(
              labelText: l10n.filterByUser,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            items: state.users.map((user) => DropdownMenuItem(
              value: user,
              child: Text('${user.name} (${user.userId})'),
            )).toList(),
            onChanged: (user) {
              final cubit = context.read<AdminCubit>();

              if (user == null) {
                cubit.clearFilters();
              } else {
                cubit.changeLocSelectedUser(user);
                cubit.getLocDataForUser(
                  user.userId,
                  state.focusedDay,
                );
              }
            },
          ),
        ),
        const SizedBox(height: 4),

        if (state.locSelectedUser != null) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text("${l10n.selectedDate}: ${state.focusedDay.toLocal().toString().split(' ')[0]}"),
                ),
                const SizedBox(width: 5),

                // date picker
                GestureDetector(
                  onTap: () async {

                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now.subtract(const Duration(days: 365)),
                      lastDate: now,
                      currentDate: state.focusedDay,
                    );

                    if (picked != null && context.mounted) {
                      context.read<AdminCubit>().getLocDataForUser(
                        state.locSelectedUser!.userId,
                        picked,
                      );
                    }
                  },
                  child: Icon(Icons.date_range),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
        ],

        //  map view
        if (state.locSelectedUser != null && state.locData.isNotEmpty) ...[
          Expanded(child: LocationMapView(locations: mapValues)),
        ],

        if (state.locSelectedUser != null && state.locData.isEmpty) ...[
          Expanded(child: NoDataFoundPage()),
        ],

        if (state.locSelectedUser == null) ...[
          Expanded(child: Center(
            child: Text(
              l10n.pleaseSelectAUserFirst,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
        ],
      ],
    );
  }
}


class LocationMapView extends StatefulWidget {
  final List<Map<String, dynamic>> locations;

  const LocationMapView({super.key, required this.locations});

  @override
  State<LocationMapView> createState() => _LocationMapViewState();
}

class _LocationMapViewState extends State<LocationMapView> {

  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  LatLng _initialPosition = const LatLng(20.5937, 78.9629);
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  void fitCameraToMarkers() {
    if (_markers.isEmpty) return;

    final bounds = _createLatLngBounds(_markers.map((m) => m.position).toList());

    _controller?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  LatLngBounds _createLatLngBounds(List<LatLng> positions) {
    final southwestLat = positions.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    final southwestLng = positions.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    final northeastLat = positions.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    final northeastLng = positions.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    return LatLngBounds(
      southwest: LatLng(southwestLat, southwestLng),
      northeast: LatLng(northeastLat, northeastLng),
    );
  }

  void moveToMarker(LatLng position, int index) {

    final markerId = MarkerId("marker_$index");

    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 16, // Adjust zoom level as needed
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _controller?.showMarkerInfoWindow(markerId);
    });
  }

  void _loadMarkers() {
    final markers = <Marker>{};

    for (int i = 0; i < widget.locations.length; i++) {
      final loc = widget.locations[i];
      final lat = double.tryParse(loc['latitude'].toString()) ?? 0.0;
      final lng = double.tryParse(loc['longitude'].toString()) ?? 0.0;

      if (i == 0) _initialPosition = LatLng(lat, lng);

      final date = DateTime.fromMillisecondsSinceEpoch(int.parse(loc['timestamp']));
      final time =  DateFormat('HH:mm:ss').format(date);

      markers.add(
        Marker(
          markerId: MarkerId('marker_$i'),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: "Time Stamp: $time",
            snippet: "Battery: ${loc['batteryLevel']}%, "
                "${(loc["event"] ?? '').isEmpty ? "" : "Event: ${loc['event']}"}",
          ),
        ),
      );
    }

    setState(() {_markers = markers;});
    fitCameraToMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        children: [
          Expanded(
            flex: isExpanded ? 1 : 8,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14,
              ),
              markers: _markers,
              onMapCreated: (controller) => _controller = controller,
            ),
          ),
          const SizedBox(height: 10),

          // events list
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // list Expand field
                GestureDetector(
                  onTap: () => setState(() => isExpanded = !isExpanded),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white60,
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(child: Text(
                          AppLocalizations.of(context)!.eventsList,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        )),

                        Icon( isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        ),
                      ],
                    ),
                  ),
                ),

                // list view
                if (isExpanded) ...[
                  const SizedBox(height: 2),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.locations.length,
                      itemBuilder: (context, index) {
                        final loc = widget.locations[index];

                        return GestureDetector(
                          onTap: () {
                            final LatLng targetPosition = LatLng(
                              double.parse(loc['latitude']),
                              double.parse(loc['longitude']),
                            );
                            moveToMarker(targetPosition, index);
                          },
                          child: LocationEntryCard(
                            latitude: double.parse(loc['latitude']),
                            longitude: double.parse(loc['longitude']),
                            timestamp: int.parse(loc['timestamp']),
                            taskId: loc['taskId'],
                            event: loc['event'] ?? '',
                          ),
                        );
                      },
                    ),
                  ),
                ],

              ],
            ),

          ),
        ],
      ),
    );
  }
}
