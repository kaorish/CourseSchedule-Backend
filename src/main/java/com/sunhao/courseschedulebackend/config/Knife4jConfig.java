package com.sunhao.courseschedulebackend.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.service.Contact;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2WebMvc;

@Configuration
@EnableSwagger2WebMvc // 开启Swagger2功能
public class Knife4jConfig {

    @Bean
    public Docket createRestApi() {
        // 文档类型
        return new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(apiInfo())
                .select()
                // 指定Controller扫描包路径
                .apis(RequestHandlerSelectors.basePackage("com.sunhao.courseschedulebackend.controller"))
                .paths(PathSelectors.any())
                .build();
    }

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("课程表App后端接口文档")
                .description("为课程表鸿蒙App提供数据支持")
                .contact(new Contact("sunhao", "http://example.com", "your-email@example.com"))
                .version("1.0")
                .build();
    }
}