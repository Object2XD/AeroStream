package com.example.aero_stream_for_android.data.smb

data class SmbScanEta(
    val progressPercent: Int?,
    val estimatedRemainingSec: Long?
)

object SmbScanEtaEstimator {
    fun estimate(
        stage: SmbScanStage,
        processedCount: Int,
        totalCount: Int,
        elapsedMillis: Long
    ): SmbScanEta {
        if (
            (stage != SmbScanStage.EXTRACTING && stage != SmbScanStage.STAGING && stage != SmbScanStage.COMMITTING) ||
            processedCount <= 0 ||
            totalCount <= 0 ||
            elapsedMillis <= 0L
        ) {
            return SmbScanEta(progressPercent = null, estimatedRemainingSec = null)
        }
        val boundedProcessed = processedCount.coerceAtMost(totalCount)
        val elapsedSec = elapsedMillis / 1000.0
        if (elapsedSec <= 0.0) {
            return SmbScanEta(progressPercent = null, estimatedRemainingSec = null)
        }
        val speed = boundedProcessed / elapsedSec
        if (speed <= 0.0) {
            return SmbScanEta(progressPercent = null, estimatedRemainingSec = null)
        }
        val remaining = (totalCount - boundedProcessed).coerceAtLeast(0)
        val etaSec = kotlin.math.ceil(remaining / speed).toLong().coerceAtLeast(0L)
        val progress = ((boundedProcessed * 100.0) / totalCount).toInt().coerceIn(0, 100)
        return SmbScanEta(progressPercent = progress, estimatedRemainingSec = etaSec)
    }

    fun formatRemaining(remainingSec: Long): String {
        return formatElapsed(remainingSec)
    }

    fun formatElapsed(elapsedSec: Long): String {
        val sec = elapsedSec.coerceAtLeast(0L)
        val hours = sec / 3600
        val minutes = (sec % 3600) / 60
        val seconds = sec % 60
        return "%02d:%02d:%02d".format(hours, minutes, seconds)
    }
}
