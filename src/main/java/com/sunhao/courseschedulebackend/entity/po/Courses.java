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
 * 课程静态信息表
 * </p>
 *
 * @author sunhao
 * @since 2025-06-20
 */
@Getter
@Setter
@TableName("courses")
public class Courses implements Serializable {

    private static final long serialVersionUID = 1L;

    /**
     * 课程唯一自增ID
     */
    @TableId(value = "id", type = IdType.AUTO)
    private Long id;

    /**
     * 所属学期的自增ID
     */
    @TableField("semester_id")
    private Long semesterId;

    /**
     * 课程名称
     */
    @TableField("name")
    private String name;

    /**
     * 教师姓名
     */
    @TableField("teacher")
    private String teacher;

    /**
     * 课程卡片颜色
     */
    @TableField("color")
    private String color;

    @TableField("created_at")
    private LocalDateTime createdAt;

    @TableField("updated_at")
    private LocalDateTime updatedAt;
}
