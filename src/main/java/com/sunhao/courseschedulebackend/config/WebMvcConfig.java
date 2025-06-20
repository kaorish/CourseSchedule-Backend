package com.sunhao.courseschedulebackend.config;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.module.SimpleModule;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateDeserializer;
import com.fasterxml.jackson.datatype.jsr310.deser.LocalDateTimeDeserializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateSerializer;
import com.fasterxml.jackson.datatype.jsr310.ser.LocalDateTimeSerializer;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void configureMessageConverters(List<HttpMessageConverter<?>> converters) {
        // 1. 创建我们自己的、全新的Jackson消息转换器
        MappingJackson2HttpMessageConverter jackson2HttpMessageConverter = new MappingJackson2HttpMessageConverter();

        // 2. 创建一个ObjectMapper，并为它配置我们的格式化规则
        ObjectMapper objectMapper = new ObjectMapper();

        // 3. 创建一个模块，专门用于处理Java 8的日期时间类型
        SimpleModule javaTimeModule = new SimpleModule();

        // 4. 为模块添加LocalDate的序列化和反序列化规则
        javaTimeModule.addSerializer(LocalDate.class,
                new LocalDateSerializer(DateTimeFormatter.ofPattern("yyyy-MM-dd")));
        javaTimeModule.addDeserializer(LocalDate.class,
                new LocalDateDeserializer(DateTimeFormatter.ofPattern("yyyy-MM-dd")));

        // 5. 为模块添加LocalDateTime的序列化和反序列化规则
        javaTimeModule.addSerializer(LocalDateTime.class,
                new LocalDateTimeSerializer(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
        javaTimeModule.addDeserializer(LocalDateTime.class,
                new LocalDateTimeDeserializer(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));

        // 6. 将我们的模块注册到ObjectMapper中
        objectMapper.registerModule(javaTimeModule);

        // 7. 将配置好的ObjectMapper设置给我们创建的转换器
        jackson2HttpMessageConverter.setObjectMapper(objectMapper);

        // 8. ★★★ 最关键的一步：将我们自己的转换器添加到转换器列表的第一个位置 ★★★
        // 这样可以确保它被优先使用
        converters.add(0, jackson2HttpMessageConverter);
    }
}