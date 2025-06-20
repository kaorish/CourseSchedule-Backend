package com.sunhao.courseschedulebackend.entity.po;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableField;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import java.io.Serializable;
import java.time.LocalDate;
import java.time.LocalDateTime;
import lombok.Getter;
import lombok.Setter;

/**
 * <p>
 * 学期信息表
 * </p>
 *
 * @author sunhao
 * @since 2025-06-20
 */
@Getter
@Setter
@TableName("semesters")
public class Semesters implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 学期唯一自增ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 学期显示名称, 如: 2024-2025-1
     */
    @TableField("name")
    private String name;

    /**
     * 学期第一周的周一的日期
     */
    @TableField("start_date")
    private LocalDate startDate;

    /**
     * 学期总周数
     */
    @TableField("total_weeks")
    private Integer totalWeeks;

    @TableField("created_at")
    private LocalDateTime createdAt;

    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
