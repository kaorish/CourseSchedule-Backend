package com.sunhao.courseschedulebackend.service;

import com.sunhao.courseschedulebackend.entity.dto.ScheduleAddDTO;
import com.sunhao.courseschedulebackend.entity.dto.ScheduleUpdateDTO;
import com.sunhao.courseschedulebackend.entity.po.Schedules;
import com.baomidou.mybatisplus.extension.service.IService;
import com.sunhao.courseschedulebackend.entity.vo.ScheduleDetailVO;
import com.sunhao.courseschedulebackend.entity.vo.ScheduleManageVO;

import java.util.List;

/**
 * <p>
 * 课程具体时间地点安排表 服务类
 * </p>
 *
 * @author sunhao
 * @since 2025-06-20
 */
public interface SchedulesService extends IService<Schedules> {

    List<ScheduleManageVO> getScheduleManageList(Long semesterId);

    boolean addSchedule(ScheduleAddDTO scheduleAddDTO);

    boolean deleteSchedule(Long scheduleId);

    boolean updateSchedule(Long scheduleId, ScheduleUpdateDTO scheduleUpdateDTO);

    ScheduleDetailVO getScheduleDetailById(Long scheduleId);
}
