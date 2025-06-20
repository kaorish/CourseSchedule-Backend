package com.sunhao.courseschedulebackend.entity.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import java.io.Serializable;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

/**
 * <p>
 * 课程具体时间地点安排表
 * </p>
 *
 * @author sunhao
 * @since 2025-06-20
 */
@Getter
@Setter
@TableName("schedules")
public class Schedules implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 课程安排的唯一自增ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 关联的课程自增ID
     */
    @TableField("course_id")
    private Long courseId;

    /**
     * 上课地点
     */
    @TableField("location")
    private String location;

    /**
     * 周几 (1-7)
     */
    @TableField("day_of_week")
    private Integer dayOfWeek;

    /**
     * 开始节次
     */
    @TableField("start_period")
    private Integer startPeriod;

    /**
     * 结束节次
     */
    @TableField("end_period")
    private Integer endPeriod;

    @TableField("created_at")
    private LocalDateTime createdAt;

    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
