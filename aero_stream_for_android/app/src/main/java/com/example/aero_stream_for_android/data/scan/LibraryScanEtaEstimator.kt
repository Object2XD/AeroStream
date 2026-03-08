package com.example.aero_stream_for_android.data.scan

data class LibraryScanEta(
    val progressPercent: Int?,
    val estimatedRemainingSec: Long?
)

object LibraryScanEtaEstimator {
    fun estimate(
        stage: LibraryScanStage,
        processedCount: Int,
        totalCount: Int,
        elapsedMillis: Long
    ): LibraryScanEta {
        if (
            (stage != LibraryScanStage.EXTRACTING &&
                stage != LibraryScanStage.STAGING &&
                stage != LibraryScanStage.COMMITTING) ||
            processedCount <= 0 ||
            totalCount <= 0 ||
            elapsedMillis <= 0L
        ) {
            return LibraryScanEta(progressPercent = null, estimatedRemainingSec = null)
        }
        val boundedProcessed = processedCount.coerceAtMost(totalCount)
        val elapsedSec = elapsedMillis / 1000.0
        if (elapsedSec <= 0.0) {
            return LibraryScanEta(progressPercent = null, estimatedRemainingSec = null)
        }
        val speed = boundedProcessed / elapsedSec
        if (speed <= 0.0) {
            return LibraryScanEta(progressPercent = null, estimatedRemainingSec = null)
        }
        val remaining = (totalCount - boundedProcessed).coerceAtLeast(0)
        val etaSec = kotlin.math.ceil(remaining / speed).toLong().coerceAtLeast(0L)
        val progress = ((boundedProcessed * 100.0) / totalCount).toInt().coerceIn(0, 100)
        return LibraryScanEta(progressPercent = progress, estimatedRemainingSec = etaSec)
    }

    fun formatRemaining(remainingSec: Long): String = formatElapsed(remainingSec)

    fun formatElapsed(elapsedSec: Long): String {
        val sec = elapsedSec.coerceAtLeast(0L)
        val hours = sec / 3600
        val minutes = (sec % 3600) / 60
        val seconds = sec % 60
        return "%02d:%02d:%02d".format(hours, minutes, seconds)
    }
}
