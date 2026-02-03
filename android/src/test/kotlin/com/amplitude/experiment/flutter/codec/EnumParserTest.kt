package com.amplitude.experiment.flutter.codec

import com.amplitude.experiment.ServerZone
import com.amplitude.experiment.Source
import com.amplitude.experiment.flutter.codec.EnumParser
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

class EnumParserTest {
    @Test
    fun parseSource_localStorage_returnsLocalStorage() {
        val result = EnumParser.parseSource("localStorage")
        assertEquals(Source.LOCAL_STORAGE, result)
    }

    @Test
    fun parseSource_initialVariants_returnsInitialVariants() {
        val result = EnumParser.parseSource("initialVariants")
        assertEquals(Source.INITIAL_VARIANTS, result)
    }

    @Test
    fun parseSource_invalidValue_throwsIllegalArgumentException() {
        assertFailsWith<IllegalArgumentException> {
            EnumParser.parseSource("invalid")
        }
    }

    @Test
    fun parseSource_emptyString_throwsIllegalArgumentException() {
        assertFailsWith<IllegalArgumentException> {
            EnumParser.parseSource("")
        }
    }

    @Test
    fun parseServerZone_us_returnsUS() {
        val result = EnumParser.parseServerZone("us")
        assertEquals(ServerZone.US, result)
    }

    @Test
    fun parseServerZone_eu_returnsEU() {
        val result = EnumParser.parseServerZone("eu")
        assertEquals(ServerZone.EU, result)
    }

    @Test
    fun parseServerZone_invalidValue_throwsIllegalArgumentException() {
        assertFailsWith<IllegalArgumentException> {
            EnumParser.parseServerZone("invalid")
        }
    }

    @Test
    fun parseServerZone_emptyString_throwsIllegalArgumentException() {
        assertFailsWith<IllegalArgumentException> {
            EnumParser.parseServerZone("")
        }
    }
}
