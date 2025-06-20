package com.sunhao.courseschedulebackend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig {

    @Bean
    public CorsFilter corsFilter() {
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        CorsConfiguration corsConfiguration = new CorsConfiguration();
        // 允许所有来源的跨域请求，在开发阶段非常方便
        corsConfiguration.addAllowedOriginPattern("*");
        corsConfiguration.addAllowedHeader("*"); // 允许所有请求头
        corsConfiguration.addAllowedMethod("*"); // 允许所有请求方法 (GET, POST, PUT, DELETE...)
        corsConfiguration.setAllowCredentials(true); // 允许携带凭证(cookie)
        source.registerCorsConfiguration("/**", corsConfiguration); // 对所有接口生效
        return new CorsFilter(source);
    }
}
