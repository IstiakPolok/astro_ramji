import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/location_model.dart';
import '../providers/astrology_api_provider.dart';

class LocationAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isDark;
  final Function(LocationModel location)? onLocationSelected;
  final String? Function(String?)? validator;

  const LocationAutocompleteField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.isDark,
    this.onLocationSelected,
    this.validator,
  });

  @override
  State<LocationAutocompleteField> createState() =>
      _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _hasOpenedOverlay = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    if (!mounted) return;
    final text = widget.controller.text;
    final provider = Provider.of<AstrologyApiProvider>(context, listen: false);

    setState(() {});

    if (text.trim().length >= 2) {
      provider.searchLocations(text);
      if (!_hasOpenedOverlay) {
        _showOverlay();
      }
    } else {
      provider.clearLocationSearch();
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0.0, size.height + 6.0),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(14),
              color: widget.isDark ? AppColors.spaceDark : Colors.white,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.getGold(widget.isDark).withValues(alpha: 0.5),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: widget.isDark ? 0.4 : 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Consumer<AstrologyApiProvider>(
                  builder: (context, provider, _) {
                    if (provider.isSearchingLocations) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.goldPrimary,
                            ),
                          ),
                        ),
                      );
                    }

                    if (provider.locationResults.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shrinkWrap: true,
                      itemCount: provider.locationResults.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: widget.isDark ? Colors.white12 : Colors.black12,
                      ),
                      itemBuilder: (context, index) {
                        final item = provider.locationResults[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: AppColors.getGold(widget.isDark),
                          ),
                          title: Text(
                            item.mainText ?? item.description,
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: widget.isDark
                                  ? Colors.white
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          subtitle: item.secondaryText != null
                              ? Text(
                                  item.secondaryText!,
                                  style: GoogleFonts.roboto(
                                    fontSize: 11,
                                    color: widget.isDark
                                        ? Colors.white54
                                        : AppColors.textSecondaryLight,
                                  ),
                                )
                              : null,
                          onTap: () async {
                            widget.controller.text = item.description;
                            _removeOverlay();

                            final details =
                                await provider.getLocationDetails(item.placeId);
                            if (details != null &&
                                widget.onLocationSelected != null) {
                              widget.onLocationSelected!(details);
                            } else if (widget.onLocationSelected != null) {
                              // Fallback with placeId
                              widget.onLocationSelected!(
                                LocationModel(
                                  id: item.placeId,
                                  placeId: item.placeId,
                                  name: item.description,
                                  latitude: 28.6139,
                                  longitude: 77.2090,
                                  timezoneId: 'Asia/Kolkata',
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
    _hasOpenedOverlay = true;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _hasOpenedOverlay = false;
  }

  @override
  Widget build(BuildContext context) {
    final goldColor = AppColors.getGold(widget.isDark);

    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label.isNotEmpty) ...[
            Text(
              widget.label,
              style: GoogleFonts.cinzel(
                color: goldColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextFormField(
            controller: widget.controller,
            validator: widget.validator,
            style: GoogleFonts.roboto(
              color: widget.isDark ? Colors.white : AppColors.textPrimaryLight,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.roboto(
                color: widget.isDark ? Colors.white38 : AppColors.textMutedLight,
                fontSize: 13,
              ),
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: goldColor,
                size: 20,
              ),
              suffixIcon: Consumer<AstrologyApiProvider>(
                builder: (context, provider, _) {
                  if (provider.isSearchingLocations) {
                    return const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.goldPrimary,
                        ),
                      ),
                    );
                  }
                  if (widget.controller.text.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      color: widget.isDark ? Colors.white54 : Colors.black45,
                      onPressed: () {
                        widget.controller.clear();
                        provider.clearLocationSearch();
                        _removeOverlay();
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              filled: true,
              fillColor: widget.isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: widget.isDark
                      ? Colors.white24
                      : goldColor.withValues(alpha: 0.35),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: widget.isDark
                      ? Colors.white24
                      : goldColor.withValues(alpha: 0.35),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: goldColor,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
