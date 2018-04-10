package com.milogert.christmas.controllers

import com.milogert.christmas.daos.GeneralDao
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

const val ep_pair = "/pair"

@RestController
class GeneralController {
    val generalDao = GeneralDao()

    @GetMapping(ep_pair)
    fun pair(): String {
        generalDao.pair()
        return "OK"
    }
}