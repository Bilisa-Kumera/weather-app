import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/responsive.dart';
import '../../../domain/entities/city.dart';
import '../../../domain/usecases/search_cities.dart';

class CityDropdown extends StatefulWidget {
  const CityDropdown({super.key, required this.onSelected});

  final ValueChanged<City> onSelected;

  @override
  State<CityDropdown> createState() => _CityDropdownState();
}

class _CityDropdownState extends State<CityDropdown> {
  List<City> _defaultCities = [];

  @override
  void initState() {
    super.initState();
    _loadDefaultCities();
  }

  Future<void> _loadDefaultCities() async {
    final data = await rootBundle.loadString('assets/cities/cities.json');
    final decoded = jsonDecode(data) as Map<String, dynamic>;
    final list = (decoded['cities'] as List<dynamic>).cast<Map<String, dynamic>>();
    if (!mounted) return;
    setState(() {
      _defaultCities = list
          .map((e) => City(
                name: e['name'] as String,
                country: e['country'] as String,
                lat: (e['lat'] as num).toDouble(),
                lon: (e['lon'] as num).toDouble(),
              ))
          .toList(growable: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = context.responsive;
    final searchCities = context.read<SearchCities>();

    return DropdownSearch<City>(
      items: (filter, loadProps) async {
        if (filter.isEmpty) {
          return _defaultCities;
        }
        return searchCities(filter);
      },
      itemAsString: (city) => '${city.name}, ${city.country}',
      compareFn: (a, b) => a.name == b.name && a.country == b.country,
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          style: TextStyle(fontSize: r.sp(14), color: const Color(0xFF0F172A)),
          cursorColor: const Color(0xFF1D4ED8),
          decoration: InputDecoration(
            hintText: 'Magaalaa kee barbaadi',
            hintStyle: TextStyle(color: const Color(0xFF64748B), fontSize: r.sp(13)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(r.r(14)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        menuProps: MenuProps(
          backgroundColor: Colors.white,
          borderRadius: BorderRadius.circular(r.r(20)),
          elevation: 6,
        ),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return Container(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE0EAFF) : Colors.transparent,
              borderRadius: BorderRadius.circular(r.r(12)),
            ),
            margin: EdgeInsets.symmetric(horizontal: r.w(8), vertical: r.h(2)),
            child: ListTile(
              dense: true,
              leading: Icon(
                Icons.location_city_outlined,
                color: isSelected ? const Color(0xFF1D4ED8) : const Color(0xFF475569),
              ),
              title: Text(
                item.name,
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontSize: r.sp(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                item.country,
                style: TextStyle(color: const Color(0xFF64748B), fontSize: r.sp(12)),
              ),
            ),
          );
        },
      ),
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.18),
          hintText: 'Magaalaa kee barbaadi',
          hintStyle: TextStyle(color: Colors.white70, fontSize: r.sp(14)),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(r.r(18)),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      onChanged: (value) {
        if (value != null) {
          widget.onSelected(value);
        }
      },
      selectedItem: null,
      dropdownBuilder: (context, selectedItem) {
        return Text(
          selectedItem == null
              ? 'Magaalaa kee barbaadi'
              : '${selectedItem.name}, ${selectedItem.country}',
          style: TextStyle(
            color: Colors.white,
            fontSize: r.sp(14),
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }
}
