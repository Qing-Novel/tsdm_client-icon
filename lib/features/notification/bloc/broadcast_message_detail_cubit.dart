import 'package:bloc/bloc.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:tsdm_client/constants/url.dart';
import 'package:tsdm_client/extensions/string.dart';
import 'package:tsdm_client/features/notification/repository/notification_repository.dart';
import 'package:tsdm_client/utils/logger.dart';
import 'package:universal_html/html.dart' as uh;

part 'broadcast_message_detail_cubit.mapper.dart';
part 'broadcast_message_detail_state.dart';

/// Cubit of broadcast message detail page.
final class BroadcastMessageDetailCubit extends Cubit<BroadcastMessageDetailState> with LoggerMixin {
  /// Constructor.
  BroadcastMessageDetailCubit(this._notificationRepository) : super(const BroadcastMessageDetailState());

  final NotificationRepository _notificationRepository;

  /// Fetch detail status from [pmid].
  Future<void> fetchDetail(String pmid) async {
    emit(state.copyWith(status: BroadcastMessageDetailStatus.loading));
    await _notificationRepository
        .fetchDocument('$broadcastMessageDetailUrl$pmid')
        .match(
          (e) {
            handle(e);
            error('failed to fetch broadcast message detail: $e');
            emit(state.copyWith(status: BroadcastMessageDetailStatus.failed));
          },
          (v) {
            final (document, _) = v;
            final infoNode = document.querySelector('div#pm_ul');
            final datetime =
                infoNode?.querySelector('dl > dd.ptm > span.xg1')?.innerText.parseToDateTimeUtc8() ??
                // Recent messages.
                infoNode?.querySelector('dl > dd.ptm > span.xg1 > span')?.title?.parseToDateTimeUtc8();
            final messageNode = infoNode?.querySelector('dl > dd > p.pm_smry');
            if (datetime == null || messageNode == null) {
              error(
                'failed to build broadcast detail message page: '
                'datetime=$datetime, messageNode=${messageNode?.innerHtml}',
              );
              emit(state.copyWith(status: BroadcastMessageDetailStatus.failed));
              return;
            }
            emit(
              state.copyWith(
                status: BroadcastMessageDetailStatus.success,
                dateTime: datetime,
                messageNode: messageNode,
              ),
            );
          },
        )
        .run();
  }
}
