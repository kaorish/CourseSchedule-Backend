package com.sunhao.courseschedulebackend.entity.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import java.time.LocalDate;

@Data
public class SemesterUpdateDTO {

    // 使用@JsonFormat来告诉Jackson如何将前端传来的"yyyy-MM-dd"字符串转为LocalDate对象
    @JsonFormat(pattern = "yyyy-MM-dd", timezone = "GMT+8")
    private LocalDate startDate;

    private Integer totalWeeks;
}
