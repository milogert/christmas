package com.milogert.christmas.filters

import org.springframework.context.annotation.Configuration
import javax.servlet.*
import javax.servlet.annotation.WebFilter
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse

@WebFilter(urlPatterns = arrayOf("/*"))
@Configuration
class CorsFilter : Filter {
    override fun init(filterConfig: FilterConfig?) {
        println("Starting CorsFilter")
    }

    override fun destroy() {
        println("Destroying CorsFilter")
    }

    override fun doFilter(request: ServletRequest, response: ServletResponse, chain: FilterChain) {
        println("Filtering headers")
        var hReq = request as HttpServletRequest
        var hRes = response as HttpServletResponse

        response.setHeader("Access-Control-Allow-Origin", "*")
        response.setHeader("Access-Control-Allow-Methods", "GET, PUT, POST, DELETE, OPTIONS")
        response.setHeader("Access-Control-Allow-Headers", "DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range")
        response.setHeader("Access-Control-Expose-Headers", "DNT,X-CustomHeader,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Content-Range,Range")

        chain.doFilter(request, response)
    }
}
