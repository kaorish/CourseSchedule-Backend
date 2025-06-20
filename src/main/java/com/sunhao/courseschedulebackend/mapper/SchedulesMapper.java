package com.sunhao.courseschedulebackend.mapper;

import com.sunhao.courseschedulebackend.entity.po.Schedules;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunhao.courseschedulebackend.entity.vo.ScheduleManageVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * <p>
 * 课程具体时间地点安排表 Mapper 接口
 * </p>
 *
 * @author sunhao
 * @since 2025-06-20
 */
@Mapper
public interface SchedulesMapper extends BaseMapper<Schedules> {

    List<ScheduleManageVO> findScheduleManageVOBySemesterId(@Param("semesterId") Long semesterId);
}
