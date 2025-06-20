package com.sunhao.courseschedulebackend.entity.vo;

import com.sunhao.courseschedulebackend.entity.po.Courses;
import lombok.Data;
import java.util.List;
import java.util.Map;

@Data
public class WeeklyCourseVO {

    private Integer weekNumber;
    private List<WeekInfo> weekInfo;
    private List<CourseInfo> courses;

    @Data
    public static class WeekInfo {
        private Integer dayOfWeek;
        private String date; // e.g., "09/02"
        private String dayName; // e.g., "周一"
    }

    @Data
    public static class CourseInfo {
        private Long scheduleId;
        private String name;
        private String teacher;
        private String location;
        private String color;
        private Integer dayOfWeek;
        private Integer startPeriod;
        private Integer endPeriod;
    }
}
