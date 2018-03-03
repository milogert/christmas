package com.milogert.christmas.controllers

import com.milogert.christmas.structures.Greeting
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController
import java.util.concurrent.atomic.AtomicLong

@RestController
class YearController {

    @GetMapping("/newYear")
    fun newYear(@RequestParam(value = "year") year: Int) {
        // Add to database.
    }
}