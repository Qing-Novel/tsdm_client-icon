import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tsdm_client/constants/layout.dart';
import 'package:tsdm_client/features/notification/bloc/notification_bloc.dart';
import 'package:tsdm_client/features/notification/bloc/notification_state_cubit.dart';
import 'package:tsdm_client/i18n/strings.g.dart';
import 'package:tsdm_client/shared/models/notification_type.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:tsdm_client/utils/retry_button.dart';
import 'package:tsdm_client/utils/show_toast.dart';
import 'package:tsdm_client/widgets/card/notice_card_v2.dart';

enum _Actions {
  markAllNoticeAsRead,
  markAllPersonalMessageAsRead,
  markAllBroadcastMessaegAsRead,
}

/// Notice page, shows Notice and PrivateMessage of current user.
class NotificationPage extends StatefulWidget {
  /// Constructor.
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage>
    with SingleTickerProviderStateMixin, LoggerMixin {
  late final EasyRefreshController _noticeRefreshController;
  late final EasyRefreshController _personalMessageRefreshController;
  late final EasyRefreshController _broadcastMessageRefreshController;
  late final TabController _tabController;

  Widget _buildEmptyBody(BuildContext context) {
    return Align(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.sizeOf(context).width,
              minHeight: constraints.maxHeight,
            ),
            child: Center(
              child: Text(
                context.t.general.noData,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _noticeRefreshController = EasyRefreshController(
      controlFinishLoad: true,
      controlFinishRefresh: true,
    );
    _personalMessageRefreshController = EasyRefreshController(
      controlFinishLoad: true,
      controlFinishRefresh: true,
    );
    _broadcastMessageRefreshController = EasyRefreshController(
      controlFinishLoad: true,
      controlFinishRefresh: true,
    );
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _noticeRefreshController.dispose();
    _personalMessageRefreshController.dispose();
    _broadcastMessageRefreshController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.t.noticePage;
    return BlocListener<NotificationBloc, NotificationState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == NotificationStatus.failure) {
          showFailedToLoadSnackBar(context);
        } else if (state.status == NotificationStatus.success) {
          final n = state.noticeList.where((e) => !e.alreadyRead).length;
          final pm =
              state.personalMessageList.where((e) => !e.alreadyRead).length;
          final bm =
              state.broadcastMessageList.where((e) => !e.alreadyRead).length;
          context.read<NotificationStateCubit>().setAll(
                noticeCount: n,
                personalMessageCount: pm,
                broadcastMessageCount: bm,
              );
          // Update last fetch notification time.
          context
              .read<NotificationBloc>()
              .add(NotificationRecordFetchTimeRequested());
        }
      },
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          final body = switch (state.status) {
            NotificationStatus.initial ||
            NotificationStatus.loading =>
              const Center(
                child: CircularProgressIndicator(),
              ),
            NotificationStatus.success => TabBarView(
                controller: _tabController,
                children: [
                  EasyRefresh(
                    controller: _noticeRefreshController,
                    header: const MaterialHeader(),
                    onRefresh: () => context
                        .read<NotificationBloc>()
                        .add(NotificationUpdateAllRequested()),
                    child: state.noticeList.isEmpty
                        ? _buildEmptyBody(context)
                        : ListView.separated(
                            padding: edgeInsetsL12T4R12B4,
                            itemCount: state.noticeList.length,
                            itemBuilder: (_, idx) =>
                                NoticeCardV2(state.noticeList[idx]),
                            separatorBuilder: (_, __) => sizedBoxW4H4,
                          ),
                  ),
                  EasyRefresh(
                    controller: _personalMessageRefreshController,
                    header: const MaterialHeader(),
                    onRefresh: () => context
                        .read<NotificationBloc>()
                        .add(NotificationUpdateAllRequested()),
                    child: state.personalMessageList.isEmpty
                        ? _buildEmptyBody(context)
                        : ListView.separated(
                            padding: edgeInsetsL12T4R12B4,
                            itemCount: state.personalMessageList.length,
                            itemBuilder: (_, idx) => PersonalMessageCardV2(
                              state.personalMessageList[idx],
                            ),
                            separatorBuilder: (_, __) => sizedBoxW4H4,
                          ),
                  ),
                  EasyRefresh(
                    controller: _broadcastMessageRefreshController,
                    header: const MaterialHeader(),
                    onRefresh: () => context
                        .read<NotificationBloc>()
                        .add(NotificationUpdateAllRequested()),
                    child: state.broadcastMessageList.isEmpty
                        ? _buildEmptyBody(context)
                        : ListView.separated(
                            padding: edgeInsetsL12T4R12B4,
                            itemCount: state.broadcastMessageList.length,
                            itemBuilder: (_, idx) => BroadcastMessageCardV2(
                              state.broadcastMessageList[idx],
                            ),
                            separatorBuilder: (_, __) => sizedBoxW4H4,
                          ),
                  ),
                ],
              ),
            NotificationStatus.failure => buildRetryButton(
                context,
                () => context
                    .read<NotificationBloc>()
                    .add(NotificationUpdateAllRequested()),
              ),
          };
          return Scaffold(
            appBar: AppBar(
              title: Text(tr.title),
              actions: [
                PopupMenuButton<_Actions>(
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: _Actions.markAllNoticeAsRead,
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_paused_outlined),
                          sizedBoxPopupMenuItemIconSpacing,
                          Text(tr.cardMenu.markAllNoticeAsRead),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _Actions.markAllPersonalMessageAsRead,
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_active_outlined),
                          sizedBoxPopupMenuItemIconSpacing,
                          Text(tr.cardMenu.markAllPersonalMessageAsRead),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _Actions.markAllBroadcastMessaegAsRead,
                      child: Row(
                        children: [
                          const Icon(Icons.notification_important_outlined),
                          sizedBoxPopupMenuItemIconSpacing,
                          Text(tr.cardMenu.markAllBroadcastMessageAsRead),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    final noticeType = switch (value) {
                      _Actions.markAllNoticeAsRead => NotificationType.notice,
                      _Actions.markAllPersonalMessageAsRead =>
                        NotificationType.personalMessage,
                      _Actions.markAllBroadcastMessaegAsRead =>
                        NotificationType.broadcastMessage,
                    };

                    context.read<NotificationBloc>().add(
                          NotificationMarkTypeReadRequested(
                            markType: noticeType,
                            markAsRead: true,
                          ),
                        );
                  },
                ),
              ],
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(child: Text(tr.noticeTab.title)),
                  Tab(child: Text(tr.privateMessageTab.title)),
                  Tab(child: Text(tr.broadcastMessageTab.title)),
                ],
              ),
            ),
            body: body,
          );
        },
      ),
    );
  }
}
