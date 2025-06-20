package com.sunhao.courseschedulebackend.entity.vo;

import lombok.Data;

@Data
public class ScheduleManageVO {
    private Long scheduleId;
    private String courseName;
    private String teacher;
    private String location;
    private String dayOfWeekText; // e.g., "周一"
    private String timeText;      // e.g., "第1-2节"
    private String weeksText;     // ★★★ e.g., "1-8, 10周" ★★★
    private String color;
}