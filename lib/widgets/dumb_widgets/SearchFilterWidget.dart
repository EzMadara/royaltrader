import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:royaltrader/cubit/tile_cubit.dart';

class SearchFilterWidget extends StatelessWidget {
  final TextEditingController searchController;

  const SearchFilterWidget({Key? key, required this.searchController})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          labelText: 'Search by Company',
          hintText: 'Enter company name',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          suffixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
        ),
        onChanged: (value) {
          context.read<TileCubit>().filterByCompany(value);
        },
      ),
    );
  }
}
