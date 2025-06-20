package com.sunhao.courseschedulebackend;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

@SpringBootApplication
@MapperScan("com.sunhao.courseschedulebackend.mapper")
@EnableWebMvc // ★★★ 添加这个注解 ★★★
public class CourseScheduleBackendApplication {

    public static void main(String[] args) {
        SpringApplication.run(CourseScheduleBackendApplication.class, args);
    }

}
