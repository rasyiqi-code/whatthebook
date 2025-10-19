import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../bloc/user_stats_bloc.dart';
import '../bloc/leaderboard_bloc.dart';
import '../../domain/usecases/get_author_leaderboard.dart';
import '../widgets/leaderboard_list.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/user_stats.dart';
import '../../../../core/injection/injection_container.dart' as di;

class AchievementsPage extends StatelessWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return const Center(child: Text('User belum login'));
    }
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserStatsBloc>(
          create: (_) => di.sl<UserStatsBloc>()..add(LoadUserStatsEvent(user.id)),
        ),
        BlocProvider<LeaderboardBloc>(
          create: (_) => di.sl<LeaderboardBloc>()..add(LoadLeaderboardEvent(LeaderboardTimeFilter.weekly)),
        ),
      ],
      child: _AchievementsView(
        userId: user.id,
        userName: user.userMetadata?['full_name'] ?? '',
        avatarUrl: user.userMetadata?['avatar_url'],
      ),
    );
  }
}

class _AchievementsView extends StatefulWidget {
  final String userId;
  final String userName;
  final String? avatarUrl;
  const _AchievementsView({
    required this.userId,
    required this.userName,
    this.avatarUrl,
  });

  @override
  State<_AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<_AchievementsView> {
  LeaderboardTimeFilter _filter = LeaderboardTimeFilter.weekly;
  int _selectedIndicator =
      0; // 0: totalWords, 1: booksPublished, 2: chaptersPublished, 3: reviewsWritten, 4: likesReceived
  final List<String> _indicatorLabels = [
    'Total Kata',
    'Buku Diterbitkan',
    'Chapter Diterbitkan',
    'Review Ditulis',
    'Likes Diterima',
  ];

  @override
  void initState() {
    super.initState();
    // Langsung load time series produktivitas
    context.read<UserStatsBloc>().add(
      LoadUserProductivityTimeSeriesEvent(widget.userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildProductivityLineChart(context),
            const SizedBox(height: 24),
            _buildLeaderboardSection(context),
            const SizedBox(height: 24),
            // _buildHighlightSection(context), // Dihapus sesuai permintaan
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Colors.grey[300],
          child: widget.avatarUrl != null
              ? ClipOval(
                  child: Image.network(
                    widget.avatarUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.person, size: 32, color: Colors.white),
                  ),
                )
              : Icon(Icons.person, size: 32, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.userName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('Penulis & Pembaca'),
          ],
        ),
      ],
    );
  }

  Widget _buildProductivityLineChart(BuildContext context) {
    return BlocBuilder<UserStatsBloc, UserStatsState>(
      builder: (context, state) {
        if (state is UserStatsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UserProductivityTimeSeriesLoaded) {
          final userSeries = state.userSeries;
          final communitySeries = state.communitySeries;
          if (userSeries.isEmpty || communitySeries.isEmpty) {
            return const Text('Belum ada data produktivitas bulanan.');
          }
          return DefaultTabController(
            length: _indicatorLabels.length,
            initialIndex: _selectedIndicator,
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.show_chart, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Grafik Produktivitas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TabBar(
                      isScrollable: true,
                      labelColor: Colors.green,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.green,
                      tabs: _indicatorLabels.map((e) => Tab(text: e)).toList(),
                      onTap: (idx) => setState(() => _selectedIndicator = idx),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (idx < 0 || idx >= userSeries.length) {
                                    return Container();
                                  }
                                  return Text(
                                    userSeries[idx].yearMonth.substring(2),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: List.generate(
                                userSeries.length,
                                (i) => FlSpot(
                                  i.toDouble(),
                                  _getIndicatorValue(
                                    userSeries[i],
                                    _selectedIndicator,
                                  ).toDouble(),
                                ),
                              ),
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                            ),
                            LineChartBarData(
                              spots: List.generate(
                                communitySeries.length,
                                (i) => FlSpot(
                                  i.toDouble(),
                                  _getIndicatorValue(
                                    communitySeries[i],
                                    _selectedIndicator,
                                  ).toDouble(),
                                ),
                              ),
                              isCurved: true,
                              color: Colors.orange,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.circle, color: Colors.blue, size: 12),
                        SizedBox(width: 4),
                        Text('User'),
                        SizedBox(width: 16),
                        Icon(Icons.circle, color: Colors.orange, size: 12),
                        SizedBox(width: 4),
                        Text('Rata-rata Komunitas'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildProductiveMonthHighlight(
                      userSeries,
                      _selectedIndicator,
                    ),
                    const SizedBox(height: 8),
                    _buildGrowthPercentage(userSeries, _selectedIndicator),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  int _getIndicatorValue(UserProductivityPoint point, int indicatorIdx) {
    switch (indicatorIdx) {
      case 0:
        return point.totalWords;
      case 1:
        return point.booksPublished;
      case 2:
        return point.chaptersPublished;
      case 3:
        return point.reviewsWritten;
      case 4:
        return point.likesReceived;
      default:
        return 0;
    }
  }

  Widget _buildProductiveMonthHighlight(
    List<UserProductivityPoint> userSeries,
    int indicatorIdx,
  ) {
    if (userSeries.isEmpty) return const SizedBox();
    int maxIdx = 0;
    int maxValue = _getIndicatorValue(userSeries[0], indicatorIdx);
    for (int i = 1; i < userSeries.length; i++) {
      final v = _getIndicatorValue(userSeries[i], indicatorIdx);
      if (v > maxValue) {
        maxValue = v;
        maxIdx = i;
      }
    }
    final month = userSeries[maxIdx].yearMonth;
    final label = _indicatorLabels[indicatorIdx];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events, color: Colors.green, size: 20),
          const SizedBox(width: 8),
          Text(
            'Bulan terproduktif: $month ($maxValue $label)',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthPercentage(
    List<UserProductivityPoint> userSeries,
    int indicatorIdx,
  ) {
    if (userSeries.length < 2) {
      return const Text(
        'Pertumbuhan bulan terakhir: -',
        style: TextStyle(color: Colors.grey),
      );
    }
    final last = _getIndicatorValue(
      userSeries[userSeries.length - 1],
      indicatorIdx,
    );
    final prev = _getIndicatorValue(
      userSeries[userSeries.length - 2],
      indicatorIdx,
    );
    if (prev == 0) {
      return const Text(
        'Pertumbuhan bulan terakhir: -',
        style: TextStyle(color: Colors.grey),
      );
    }
    final growth = ((last - prev) / prev * 100).toDouble();
    final isUp = growth >= 0;
    final color = isUp ? Colors.green : Colors.red;
    final sign = isUp ? '+' : '';
    return Text(
      'Pertumbuhan bulan terakhir: $sign${growth.toStringAsFixed(1)}%',
      style: TextStyle(fontWeight: FontWeight.bold, color: color),
    );
  }

  Widget _buildLeaderboardSection(BuildContext context) {
    return BlocBuilder<LeaderboardBloc, LeaderboardState>(
      builder: (context, state) {
        if (state is LeaderboardLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is LeaderboardLoaded) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: DefaultTabController(
                length: 3,
                initialIndex: _filter.index,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.leaderboard, color: Colors.deepPurple),
                          SizedBox(width: 8),
                          Text(
                            'Leaderboard Penulis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TabBar(
                        labelColor: Colors.deepPurple,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.deepPurple,
                        tabs: const [
                          Tab(text: 'Mingguan'),
                          Tab(text: 'Bulanan'),
                          Tab(text: 'All Time'),
                        ],
                        onTap: (index) {
                          final filter = [
                            LeaderboardTimeFilter.weekly,
                            LeaderboardTimeFilter.monthly,
                            LeaderboardTimeFilter.allTime,
                          ][index];
                          setState(() => _filter = filter);
                          context.read<LeaderboardBloc>().add(
                            LoadLeaderboardEvent(filter),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      LeaderboardList(
                        entries: state.entries,
                        currentUserId: widget.userId,
                        onRetry: () => context.read<LeaderboardBloc>().add(
                          LoadLeaderboardEvent(_filter),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (state is LeaderboardError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
