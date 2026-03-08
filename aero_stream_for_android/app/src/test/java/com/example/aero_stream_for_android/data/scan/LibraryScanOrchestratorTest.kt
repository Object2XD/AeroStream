package com.example.aero_stream_for_android.data.scan

import androidx.room.withTransaction
import com.example.aero_stream_for_android.data.local.db.AeroDatabase
import com.example.aero_stream_for_android.data.local.db.dao.LibraryScanStagingDao
import com.example.aero_stream_for_android.data.local.db.dao.LibraryScanStatusDao
import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import com.example.aero_stream_for_android.data.local.db.entity.LibraryScanStagingSongEntity
import com.example.aero_stream_for_android.data.local.db.entity.LibraryScanStatusEntity
import com.example.aero_stream_for_android.data.local.db.entity.SongEntity
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.domain.model.SongMetadataState
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkStatic
import io.mockk.unmockkStatic
import org.junit.After
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

class LibraryScanOrchestratorTest {

    private val database: AeroDatabase = mockk()
    private val songDao: SongDao = mockk(relaxed = true)
    private val stagingDao: LibraryScanStagingDao = mockk(relaxed = true)
    private val statusDao: LibraryScanStatusDao = mockk(relaxed = true)

    private val stagedRows = mutableListOf<LibraryScanStagingSongEntity>()

    @Before
    fun setUp() {
        mockkStatic("androidx.room.RoomDatabaseKt")
        coEvery { database.withTransaction(any<suspend () -> Unit>()) } coAnswers {
            secondArg<suspend () -> Unit>().invoke()
        }
        coEvery { stagingDao.insertSongs(any()) } coAnswers {
            stagedRows += firstArg<List<LibraryScanStagingSongEntity>>()
        }
        coEvery { stagingDao.getSongsBySession(any()) } coAnswers {
            val sessionId = firstArg<String>()
            stagedRows.filter { it.scanSessionId == sessionId }
        }
        coEvery { stagingDao.deleteBySession(any()) } coAnswers {
            val sessionId = firstArg<String>()
            stagedRows.removeAll { it.scanSessionId == sessionId }
        }
        coEvery { stagingDao.deleteBySourceConfig(any(), any()) } coAnswers {
            val source = firstArg<String>()
            val sourceConfigId = secondArg<String>()
            stagedRows.removeAll { it.scanSource == source && it.scanSourceConfigId == sourceConfigId }
        }
        coEvery { statusDao.getStatus(any(), any()) } returns null
    }

    @After
    fun tearDown() {
        unmockkStatic("androidx.room.RoomDatabaseKt")
    }

    @Test
    fun refresh_publishesOn100Rows_andKeepsPartialResultOnCancellation() = kotlinx.coroutines.test.runTest {
        val items = (1..101).map { ScanItem("k$it") }
        val existingRows = items.mapIndexed { index, item ->
            songEntity(
                id = (index + 1).toLong(),
                localPath = item.key
            )
        }
        coEvery { songDao.getSongsBySourceList(MusicSource.LOCAL.name) } returns existingRows

        var cancel = false
        val adapter = FakeLocalAdapter(
            items = items,
            onAfterEmit = { index ->
                if (index == 100) cancel = true
            }
        )

        val orchestrator = LibraryScanOrchestrator(database, songDao, stagingDao, statusDao)
        val result = orchestrator.refresh(
            config = Unit,
            adapter = adapter,
            quickScan = true,
            isCancelled = { cancel }
        )

        assertFalse(result.success)
        coVerify(exactly = 1) {
            stagingDao.deleteBySourceConfig(MusicSource.LOCAL.name, LocalScanSourceAdapter.STATUS_CONFIG_ID)
        }
        coVerify(atLeast = 1) { songDao.deleteAllBySource(MusicSource.LOCAL.name) }
        coVerify(atLeast = 1) { songDao.insertSongs(any()) }
    }

    @Test
    fun refresh_publishesOnFinalize_evenWhenLessThan100Rows() = kotlinx.coroutines.test.runTest {
        val items = (1..10).map { ScanItem("k$it") }
        val existingRows = items.mapIndexed { index, item ->
            songEntity(
                id = (index + 1).toLong(),
                localPath = item.key
            )
        }
        coEvery { songDao.getSongsBySourceList(MusicSource.LOCAL.name) } returns existingRows

        val adapter = FakeLocalAdapter(items = items)
        val orchestrator = LibraryScanOrchestrator(database, songDao, stagingDao, statusDao)

        val result = orchestrator.refresh(
            config = Unit,
            adapter = adapter,
            quickScan = true
        )

        assertTrue(result.success)
        coVerify(atLeast = 1) { songDao.deleteAllBySource(MusicSource.LOCAL.name) }
        coVerify(atLeast = 1) { songDao.insertSongs(any()) }
        coVerify(exactly = 1) { stagingDao.deleteBySession(any()) }
    }

    @Test
    fun refresh_fullScanDoesNotPublishPartialResultBeforeFinalize() = kotlinx.coroutines.test.runTest {
        val items = (1..101).map { ScanItem("k$it") }
        val existingRows = items.mapIndexed { index, item ->
            songEntity(
                id = (index + 1).toLong(),
                localPath = item.key
            )
        }
        coEvery { songDao.getSongsBySourceList(MusicSource.LOCAL.name) } returns existingRows

        var cancel = false
        val adapter = FakeLocalAdapter(
            items = items,
            onAfterEmit = { index ->
                if (index == 100) cancel = true
            }
        )

        val orchestrator = LibraryScanOrchestrator(database, songDao, stagingDao, statusDao)
        val result = orchestrator.refresh(
            config = Unit,
            adapter = adapter,
            quickScan = false,
            isCancelled = { cancel }
        )

        assertFalse(result.success)
        coVerify(exactly = 0) { songDao.deleteAllBySource(MusicSource.LOCAL.name) }
        coVerify(exactly = 0) { songDao.insertSongs(any()) }
    }

    @Test
    fun refresh_doesNotStageFallbackOrErrorRows() = kotlinx.coroutines.test.runTest {
        val items = listOf(ScanItem("ok"), ScanItem("fallback"), ScanItem("error"))
        val existingRows = items.mapIndexed { index, item ->
            songEntity(
                id = (index + 1).toLong(),
                localPath = item.key
            )
        }
        coEvery { songDao.getSongsBySourceList(MusicSource.LOCAL.name) } returns existingRows
        val adapter = FakeLocalAdapter(
            items = items,
            metadataResultFor = { item ->
                when (item.key) {
                    "ok" -> ScanMetadataResult.Success(
                        Song(
                            id = 0L,
                            title = "ok",
                            artist = "a",
                            album = "b",
                            duration = 1L,
                            source = MusicSource.LOCAL,
                            localPath = item.key,
                            sourceUpdatedAt = 1L,
                            metadataState = SongMetadataState.COMPLETE
                        )
                    )
                    "fallback" -> ScanMetadataResult.Fallback(
                        Song(
                            id = 0L,
                            title = "fallback",
                            artist = "a",
                            album = "b",
                            duration = 0L,
                            source = MusicSource.LOCAL,
                            localPath = item.key
                        )
                    )
                    else -> ScanMetadataResult.Error
                }
            }
        )
        val orchestrator = LibraryScanOrchestrator(database, songDao, stagingDao, statusDao)

        val result = orchestrator.refresh(
            config = Unit,
            adapter = adapter,
            quickScan = false
        )

        assertTrue(result.success)
        assertTrue(result.failedCount >= 2)
        assertTrue(result.stagedCount <= 1)
    }

    private data class ScanItem(val key: String)

    private class FakeLocalAdapter(
        private val items: List<ScanItem>,
        private val onAfterEmit: (Int) -> Unit = {},
        private val metadataResultFor: (ScanItem) -> ScanMetadataResult = { item ->
            ScanMetadataResult.Success(
                Song(
                    id = 0L,
                    title = item.key,
                    artist = "a",
                    album = "b",
                    duration = 1L,
                    source = MusicSource.LOCAL,
                    localPath = item.key,
                    sourceUpdatedAt = 1L,
                    metadataState = SongMetadataState.COMPLETE
                )
            )
        }
    ) : LibraryScanSourceAdapter<Unit, ScanItem> {

        override fun target(config: Unit): LibraryScanTarget = LibraryScanTarget(
            source = MusicSource.LOCAL,
            publishedConfigId = null,
            statusConfigId = LocalScanSourceAdapter.STATUS_CONFIG_ID
        )

        override suspend fun enumerateItems(
            config: Unit,
            onItem: suspend (ScanItem) -> Unit,
            onDirectorySkipped: () -> Unit
        ) {
            items.forEachIndexed { index, item ->
                onItem(item)
                onAfterEmit(index + 1)
            }
        }

        override fun buildFingerprint(item: ScanItem): ScanItemFingerprint =
            ScanItemFingerprint(lookupKey = item.key, fileSize = 1L, modifiedAt = 1L)

        override fun buildFingerprint(entity: SongEntity): ScanItemFingerprint? {
            val key = entity.localPath ?: return null
            return ScanItemFingerprint(lookupKey = key, fileSize = 1L, modifiedAt = 1L)
        }

        override suspend fun extractMetadata(config: Unit, item: ScanItem): ScanMetadataResult =
            metadataResultFor(item)

        override fun toFallbackRecord(config: Unit, item: ScanItem): Song =
            Song(
                id = 0L,
                title = item.key,
                artist = "a",
                album = "b",
                duration = 1L,
                source = MusicSource.LOCAL,
                localPath = item.key
            )

        override fun mergeWithExisting(
            extractedSong: Song,
            existingEntity: SongEntity?,
            config: Unit,
            item: ScanItem
        ): SongEntity {
            return existingEntity ?: songEntity(id = 0L, localPath = item.key)
        }
    }

    private companion object {
        fun songEntity(id: Long, localPath: String): SongEntity = SongEntity(
            id = id,
            title = "t$id",
            artist = "artist",
            albumArtist = "artist",
            album = "album",
            duration = 1L,
            source = MusicSource.LOCAL.name,
            localPath = localPath,
            sourceUpdatedAt = 1L
        )
    }
}
