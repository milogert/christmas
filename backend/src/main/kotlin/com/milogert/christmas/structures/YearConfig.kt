package com.milogert.christmas.structures

data class YearConfig (
        val year: Int,
        val isSecret: Boolean,
        val participants: ArrayList<Int> = ArrayList<Int>()
)