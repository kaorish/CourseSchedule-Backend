package com.sunhao.courseschedulebackend.entity.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import java.io.Serializable;
import lombok.Getter;
import lombok.Setter;

/**
 * <p>
 * 课程安排生效周数表
 * </p>
 *
 * @author sunhao
 * @since 2025-06-20
 */
@Getter
@Setter
@TableName("schedule_weeks")
public class ScheduleWeeks implements Serializable {

    private static final long serialVersionUID = 1L;

    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 关联的课程安排自增ID
     */
    @TableField("schedule_id")
    private Long scheduleId;

    /**
     * 具体的周数
     */
    @TableField("week_number")
    private Integer weekNumber;
}
