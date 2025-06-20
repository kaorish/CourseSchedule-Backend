package com.sunhao.courseschedulebackend.util;


import com.baomidou.mybatisplus.generator.FastAutoGenerator;
import com.baomidou.mybatisplus.generator.config.OutputFile;
import com.baomidou.mybatisplus.generator.engine.FreemarkerTemplateEngine;

import java.util.Collections;

/**
 * MyBatis-Plus 代码生成器
 * @author sunhao
 */
public class CodeGenerator {

    public static void main(String[] args) {
        // --- 1. 修改为你自己的数据库连接信息 ---
        String url = "jdbc:mysql://localhost:3306/CourseSchedule?serverTimezone=GMT%2B8";
        String username = "root";
        String password = "@sun005222"; // <<< 修改为你的数据库密码

        // --- 2. 执行代码生成 ---
        FastAutoGenerator.create(url, username, password)
                // 全局配置
                .globalConfig(builder -> {
                    builder.author("sunhao") // 设置作者
                            .commentDate("yyyy-MM-dd") // 注释日期格式
                            .outputDir(System.getProperty("user.dir") + "/src/main/java"); // 指定输出目录
                })
                // 包配置
                .packageConfig(builder -> {
                    builder.parent("com.sunhao.courseschedulebackend") // 设置父包名
                            // .moduleName("courses") // 可以设置模块名，生成的代码会放在 com.sunhao.courseschedulebackend.courses下
                            .entity("entity.po") // POJO实体类包名
                            .mapper("mapper") // Mapper接口包名
                            .service("service") // Service接口包名
                            .serviceImpl("service.serviceimpl") // Service实现类包名
                            .controller("controller") // Controller包名
                            .pathInfo(Collections.singletonMap(OutputFile.xml, System.getProperty("user.dir") + "/src/main/resources/mapper")); // 设置mapperXml生成路径
                })
                // 策略配置
                .strategyConfig(builder -> {
                    builder.addInclude("semesters", "courses", "schedules", "schedule_weeks") // ★★★ 设置需要生成的表名 ★★★
                            .addTablePrefix() // 过滤表前缀，我们没有前缀，所以留空
                            // Entity策略配置
                            .entityBuilder()
                            .enableLombok() // 开启Lombok
                            .enableTableFieldAnnotation() // 开启字段注解
                            // Controller策略配置
                            .controllerBuilder()
                            .enableRestStyle() // 开启@RestController
                            // Service策略配置
                            .serviceBuilder()
                            .formatServiceFileName("%sService") // Service接口名格式：UserService
                            .formatServiceImplFileName("%sServiceImpl") // Service实现类名格式：UserServiceImpl
                            // Mapper策略配置
                            .mapperBuilder()
                            .enableMapperAnnotation(); // 开启@Mapper
                })
                // 模板引擎配置
                .templateEngine(new FreemarkerTemplateEngine())
                .execute();

        System.out.println("🎉 代码生成完毕！");
    }
}