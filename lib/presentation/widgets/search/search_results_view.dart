import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';

import '../../../../data/models/hostel_model.dart';
import '../hostel/hostel_card.dart';
import '../common/empty_state_widget.dart';
import '../common/shimmer_card.dart';
import '../../../../core/router/app_router.dart';

class SearchResultsView extends StatelessWidget {
  final AsyncValue<List<HostelModel>> hostelsAsync;

  const SearchResultsView({
    super.key,
    required this.hostelsAsync,
  });

  @override
  Widget build(BuildContext context) {
    return hostelsAsync.when(
      loading: () => SliverPadding(
        padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 100),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const ShimmerHostelCard(),
            childCount: 4,
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: Theme.of(context).textTheme.bodySmall!,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      data: (hostels) {
        if (hostels.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateWidget(
              icon: Icons.search_off_rounded,
              title: 'No Hostels Found',
              message: 'Try adjusting your filters, location, or search query to find more options.',
            ),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => FadeInUp(
                key: ValueKey('search_card_${hostels[i].hostelId}'),
                duration: const Duration(milliseconds: 300),
                delay: Duration(milliseconds: (i % 6) * 50),
                child: HostelCard(
                  hostel: hostels[i],
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRouter.hostelDetail,
                    arguments: hostels[i].hostelId,
                  ),
                ),
              ),
              childCount: hostels.length,
            ),
          ),
        );
      },
    );
  }
}
