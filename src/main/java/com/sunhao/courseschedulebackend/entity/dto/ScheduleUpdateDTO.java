package com.sunhao.courseschedulebackend.entity.dto;

import lombok.Data;
import java.util.List;

@Data
public class ScheduleUpdateDTO {
    // 课程基本信息
    private String courseName;
    private String teacher;
    private String color;

    // 课程安排信息
    private String location;
    private Integer dayOfWeek;
    private Integer startPeriod;
    private Integer endPeriod;

    // 周数信息
    private List<Integer> weeks;
}