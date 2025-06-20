package com.sunhao.courseschedulebackend.mapper;

import com.sunhao.courseschedulebackend.entity.po.ScheduleWeeks;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;

/**
 * <p>
 * 课程安排生效周数表 Mapper 接口
 * </p>
 *
 * @author sunhao
 * @since 2025-06-20
 */
@Mapper
public interface ScheduleWeeksMapper extends BaseMapper<ScheduleWeeks> {

}
