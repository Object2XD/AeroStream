package com.example.aero_stream_for_android.data.scan

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import androidx.core.app.NotificationCompat
import androidx.work.ForegroundInfo
import com.example.aero_stream_for_android.R
import javax.inject.Inject
import javax.inject.Singleton

data class ActiveLibraryScanState(
    val source: com.example.aero_stream_for_android.domain.model.MusicSource,
    val sourceConfigId: String,
    val displayName: String,
    val progress: LibraryScanProgress,
    val updatedAt: Long = System.currentTimeMillis()
)

internal data class AggregatedLibraryScanNotificationState(
    val activeCount: Int,
    val scannedCountTotal: Int,
    val processedCountTotal: Int,
    val failedCountTotal: Int,
    val skippedDirectoriesTotal: Int,
    val totalCountKnownSum: Int,
    val hasUnknownTotal: Boolean,
    val elapsedSecMax: Long,
    val estimatedRemainingSecMax: Long?
)

@Singleton
class LibraryScanNotificationCoordinator @Inject constructor() {
    companion object {
        const val CHANNEL_ID = "library_scan_progress"
        const val NOTIFICATION_ID = 2002
        private const val CHANNEL_NAME = "ライブラリスキャン進行"
    }

    fun buildPreparingNotification(context: Context) =
        NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("ライブラリを更新中")
            .setContentText("スキャンを開始しています")
            .setOnlyAlertOnce(true)
            .setOngoing(true)
            .build()

    fun buildProgressNotification(
        context: Context,
        activeStates: List<ActiveLibraryScanState>,
        cancelIntent: PendingIntent?
    ) = buildNotification(context, activeStates, cancelIntent)

    fun buildForegroundInfo(
        context: Context,
        activeState: ActiveLibraryScanState,
        cancelIntent: PendingIntent?
    ): ForegroundInfo = ForegroundInfo(
        NOTIFICATION_ID,
        buildNotification(context, listOf(activeState), cancelIntent)
    )

    fun ensureChannel(context: Context) {
        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_LOW
        )
        notificationManager(context).createNotificationChannel(channel)
    }

    fun notificationManager(context: Context): NotificationManager =
        context.getSystemService(Service.NOTIFICATION_SERVICE) as NotificationManager

    private fun buildNotification(
        context: Context,
        activeStates: List<ActiveLibraryScanState>,
        cancelIntent: PendingIntent?
    ): android.app.Notification {
        ensureChannel(context)
        val aggregated = aggregate(activeStates) ?: return buildPreparingNotification(context)
        val line1 = buildLine1(aggregated)
        val line2 = buildLine2(aggregated)
        val detailText = buildDetailText(aggregated)
        return NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("ライブラリを更新中")
            .setContentText(line1)
            .setOnlyAlertOnce(true)
            .setOngoing(true)
            .setStyle(NotificationCompat.BigTextStyle().bigText(detailText))
            .setProgress(
                if (!aggregated.hasUnknownTotal && aggregated.totalCountKnownSum > 0) {
                    aggregated.totalCountKnownSum
                } else {
                    0
                },
                if (!aggregated.hasUnknownTotal && aggregated.totalCountKnownSum > 0) {
                    aggregated.processedCountTotal.coerceAtMost(aggregated.totalCountKnownSum)
                } else {
                    0
                },
                aggregated.hasUnknownTotal || aggregated.totalCountKnownSum <= 0
            )
            .apply {
                if (cancelIntent != null) {
                    addAction(0, "キャンセル", cancelIntent)
                }
            }
            .build()
    }

    internal fun aggregate(
        activeStates: List<ActiveLibraryScanState>
    ): AggregatedLibraryScanNotificationState? {
        if (activeStates.isEmpty()) return null
        val hasUnknownTotal = activeStates.any { !it.progress.discoveryCompleted || it.progress.totalCount <= 0 }
        val etaCandidates = activeStates.mapNotNull { it.progress.estimatedRemainingSec }
        return AggregatedLibraryScanNotificationState(
            activeCount = activeStates.size,
            scannedCountTotal = activeStates.sumOf { it.progress.scannedCount.coerceAtLeast(0) },
            processedCountTotal = activeStates.sumOf { it.progress.processedCount.coerceAtLeast(0) },
            failedCountTotal = activeStates.sumOf { it.progress.failedCount.coerceAtLeast(0) },
            skippedDirectoriesTotal = activeStates.sumOf { it.progress.skippedDirectories.coerceAtLeast(0) },
            totalCountKnownSum = activeStates.sumOf { it.progress.totalCount.coerceAtLeast(0) },
            hasUnknownTotal = hasUnknownTotal,
            elapsedSecMax = activeStates.maxOf { it.progress.elapsedSec.coerceAtLeast(0L) },
            estimatedRemainingSecMax = if (hasUnknownTotal || etaCandidates.isEmpty()) {
                null
            } else {
                etaCandidates.maxOrNull()
            }
        )
    }

    private fun buildLine1(
        aggregated: AggregatedLibraryScanNotificationState
    ): String = "実行中 ${aggregated.activeCount}件"

    private fun buildLine2(
        aggregated: AggregatedLibraryScanNotificationState
    ): String {
        return buildString {
            if (!aggregated.hasUnknownTotal && aggregated.totalCountKnownSum > 0) {
                append(
                    "処理 ${aggregated.processedCountTotal.coerceAtMost(aggregated.totalCountKnownSum)}/${aggregated.totalCountKnownSum}件"
                )
                val progressPercent = ((aggregated.processedCountTotal.coerceAtMost(aggregated.totalCountKnownSum) * 100.0) /
                    aggregated.totalCountKnownSum)
                    .toInt()
                    .coerceIn(0, 100)
                append(" (${progressPercent}%)")
            } else {
                append("処理 ${aggregated.processedCountTotal}件")
            }
            append(" / 発見 ${aggregated.scannedCountTotal}件")
            if (aggregated.failedCountTotal > 0) {
                append(" / 失敗 ${aggregated.failedCountTotal}件")
            }
        }
    }

    private fun buildDetailText(
        aggregated: AggregatedLibraryScanNotificationState
    ): String = buildString {
        append(buildLine1(aggregated))
        append('\n')
        append(buildLine2(aggregated))
        append('\n')
        append("経過 ${LibraryScanEtaEstimator.formatElapsed(aggregated.elapsedSecMax)}")
        append(" ・ ")
        if (aggregated.estimatedRemainingSecMax != null) {
            append("残り約 ${LibraryScanEtaEstimator.formatRemaining(aggregated.estimatedRemainingSecMax)}")
        } else {
            append("残り時間を計算中")
        }
    }
}
