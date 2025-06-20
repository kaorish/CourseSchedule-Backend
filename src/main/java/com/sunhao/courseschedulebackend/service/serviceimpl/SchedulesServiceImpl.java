package com.sunhao.courseschedulebackend.service.serviceimpl;

import com.baomidou.mybatisplus.core.conditions.query.QueryWrapper;
import com.sunhao.courseschedulebackend.entity.dto.ScheduleAddDTO;
import com.sunhao.courseschedulebackend.entity.dto.ScheduleUpdateDTO;
import com.sunhao.courseschedulebackend.entity.po.Courses;
import com.sunhao.courseschedulebackend.entity.po.ScheduleWeeks;
import com.sunhao.courseschedulebackend.entity.po.Schedules;
import com.sunhao.courseschedulebackend.entity.vo.ScheduleDetailVO;
import com.sunhao.courseschedulebackend.entity.vo.ScheduleManageVO;
import com.sunhao.courseschedulebackend.mapper.ScheduleWeeksMapper;
import com.sunhao.courseschedulebackend.mapper.SchedulesMapper;
import com.sunhao.courseschedulebackend.service.CoursesService;
import com.sunhao.courseschedulebackend.service.SchedulesService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import javax.annotation.Resource;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

/**
 * <p>
 * 课程具体时间地点安排表 服务实现类
 * </p>
 *
 * @author sunhao
 * @since 2025-06-20
 */
@Service
public class SchedulesServiceImpl extends ServiceImpl<SchedulesMapper, Schedules> implements SchedulesService {

    @Resource
    private ScheduleWeeksMapper scheduleWeeksMapper;

    @Resource
    private CoursesService coursesService; // 注入CoursesService来操作courses表

    @Override
    public List<ScheduleManageVO> getScheduleManageList(Long semesterId) {
        // 1. 获取基础的课程安排信息
        List<ScheduleManageVO> voList = baseMapper.findScheduleManageVOBySemesterId(semesterId);
        if (voList.isEmpty()) {
            return Collections.emptyList();
        }

        // 2. 遍历列表，为每一个VO填充格式化后的周数文本
        for (ScheduleManageVO vo : voList) {
            // 根据scheduleId查询所有周数
            QueryWrapper<ScheduleWeeks> queryWrapper = new QueryWrapper<>();
            queryWrapper.eq("schedule_id", vo.getScheduleId()).orderByAsc("week_number");
            List<ScheduleWeeks> weeks = scheduleWeeksMapper.selectList(queryWrapper);

            // 提取周数数字
            List<Integer> weekNumbers = weeks.stream()
                    .map(ScheduleWeeks::getWeekNumber)
                    .collect(Collectors.toList());

            // 调用算法格式化周数并设置
            vo.setWeeksText(formatWeekNumbers(weekNumbers));
        }

        return voList;
    }

    /**
     * 将周数列表格式化为人类可读的字符串
     * e.g., [1,2,3,5,7,8] -> "1-3, 5, 7-8周"
     * @param weekNumbers 已排序的周数列表
     * @return 格式化后的字符串
     */
    private String formatWeekNumbers(List<Integer> weekNumbers) {
        if (weekNumbers == null || weekNumbers.isEmpty()) {
            return "";
        }

        StringBuilder sb = new StringBuilder();
        int start = weekNumbers.get(0);
        int end = start;

        for (int i = 1; i < weekNumbers.size(); i++) {
            if (weekNumbers.get(i) == end + 1) {
                end = weekNumbers.get(i);
            } else {
                appendRange(sb, start, end);
                sb.append(", ");
                start = weekNumbers.get(i);
                end = start;
            }
        }
        appendRange(sb, start, end);
        sb.append("周");
        return sb.toString();
    }

    private void appendRange(StringBuilder sb, int start, int end) {
        if (start == end) {
            sb.append(start);
        } else {
            sb.append(start).append("-").append(end);
        }
    }

    @Override
    @Transactional // ★★★ 开启事务管理！★★★
    public boolean addSchedule(ScheduleAddDTO dto) {
        // --- 步骤 1: 处理 courses 表 ---
        // 检查这门课在这个学期是否已存在
        QueryWrapper<Courses> courseQuery = new QueryWrapper<>();
        courseQuery.eq("semester_id", dto.getSemesterId())
                .eq("name", dto.getCourseName())
                .eq("teacher", dto.getTeacher());
        Courses course = coursesService.getOne(courseQuery);

        // 如果课程不存在，则创建新课程
        if (course == null) {
            course = new Courses();
            course.setSemesterId(dto.getSemesterId());
            course.setName(dto.getCourseName());
            course.setTeacher(dto.getTeacher());
            course.setColor(dto.getColor());
            coursesService.save(course); // 保存后，course对象的id会被自动填充
        } else {
            // 如果课程已存在，但颜色不同，可以考虑更新颜色
            if (dto.getColor() != null && !dto.getColor().equals(course.getColor())) {
                course.setColor(dto.getColor());
                coursesService.updateById(course);
            }
        }

        // --- 步骤 2: 处理 schedules 表 ---
        Schedules schedule = new Schedules();
        schedule.setCourseId(course.getId()); // 使用上一步获取或创建的course的ID
        schedule.setLocation(dto.getLocation());
        schedule.setDayOfWeek(dto.getDayOfWeek());
        schedule.setStartPeriod(dto.getStartPeriod());
        schedule.setEndPeriod(dto.getEndPeriod());
        // baseMapper是SchedulesMapper，所以this.save就是保存到schedules表
        this.save(schedule); // 保存后，schedule对象的id会被自动填充

        // --- 步骤 3: 处理 schedule_weeks 表 ---
        if (dto.getWeeks() != null && !dto.getWeeks().isEmpty()) {
            Long scheduleId = schedule.getId(); // 获取上一步生成的schedule的ID
            List<ScheduleWeeks> weekEntities = dto.getWeeks().stream().map(weekNumber -> {
                ScheduleWeeks sw = new ScheduleWeeks();
                sw.setScheduleId(scheduleId);
                sw.setWeekNumber(weekNumber);
                return sw;
            }).collect(Collectors.toList());

            // 批量插入周数
            // 注意：MyBatis-Plus的批量插入需要自己实现或配置，这里用循环插入保证通用性
            for (ScheduleWeeks entity : weekEntities) {
                scheduleWeeksMapper.insert(entity);
            }
        }

        return true;
    }

    @Override
    @Transactional // ★★★ 开启事务，保证操作的原子性 ★★★
    public boolean deleteSchedule(Long scheduleId) {
        // --- 步骤 1: 删除所有关联的周数记录 ---
        // 创建一个查询条件，删除 schedule_weeks 表中所有 schedule_id 匹配的记录
        QueryWrapper<ScheduleWeeks> weekQueryWrapper = new QueryWrapper<>();
        weekQueryWrapper.eq("schedule_id", scheduleId);
        scheduleWeeksMapper.delete(weekQueryWrapper);

        // --- 步骤 2: 删除课程安排本身 ---
        // baseMapper 是 SchedulesMapper，所以直接调用 removeById
        int rowsAffected = baseMapper.deleteById(scheduleId);

        // 如果删除了至少一行，则认为操作成功
        return rowsAffected > 0;

        // 注意：我们通常不在这里删除courses表的记录，因为可能还有其他安排在使用同一个course。
        // 可以后续添加一个定时任务或脚本来清理那些没有被任何schedule引用的孤儿course记录。
    }

    @Override
    @Transactional // ★★★ 必须在事务中执行！★★★
    public boolean updateSchedule(Long scheduleId, ScheduleUpdateDTO dto) {
        // --- 步骤 1: 检查课程安排是否存在 ---
        Schedules schedule = this.getById(scheduleId);
        if (schedule == null) {
            return false; // 如果不存在，直接返回失败
        }

        // --- 步骤 2: 更新 courses 表信息 ---
        // 注意：这里我们假设课程名、老师等信息是跟着某一个schedule走的。
        // 一个更复杂的设计是，如果多个schedule共用一个course，修改一个时要如何处理。
        // 为了简化，我们直接更新这个schedule关联的course。
        Courses course = coursesService.getById(schedule.getCourseId());
        if (course != null) {
            course.setName(dto.getCourseName());
            course.setTeacher(dto.getTeacher());
            course.setColor(dto.getColor());
            coursesService.updateById(course);
        }

        // --- 步骤 3: 更新 schedules 表信息 ---
        schedule.setLocation(dto.getLocation());
        schedule.setDayOfWeek(dto.getDayOfWeek());
        schedule.setStartPeriod(dto.getStartPeriod());
        schedule.setEndPeriod(dto.getEndPeriod());
        this.updateById(schedule);

        // --- 步骤 4: 更新 schedule_weeks 表 (核心：先删后增) ---
        // 4.1 删除该scheduleId关联的所有旧周数
        QueryWrapper<ScheduleWeeks> weekQueryWrapper = new QueryWrapper<>();
        weekQueryWrapper.eq("schedule_id", scheduleId);
        scheduleWeeksMapper.delete(weekQueryWrapper);

        // 4.2 插入所有新周数
        if (dto.getWeeks() != null && !dto.getWeeks().isEmpty()) {
            List<ScheduleWeeks> weekEntities = dto.getWeeks().stream().map(weekNumber -> {
                ScheduleWeeks sw = new ScheduleWeeks();
                sw.setScheduleId(scheduleId);
                sw.setWeekNumber(weekNumber);
                return sw;
            }).collect(Collectors.toList());

            // 循环插入
            for (ScheduleWeeks entity : weekEntities) {
                scheduleWeeksMapper.insert(entity);
            }
        }

        return true;
    }

    @Override
    public ScheduleDetailVO getScheduleDetailById(Long scheduleId) {
        // --- 步骤 1: 查询 schedule 安排信息 ---
        Schedules schedule = this.getById(scheduleId);
        if (schedule == null) {
            return null; // 如果找不到，返回null
        }

        // --- 步骤 2: 查询关联的 course 课程信息 ---
        Courses course = coursesService.getById(schedule.getCourseId());
        if (course == null) {
            // 数据不一致的情况，理论上不应该发生，但最好做个保护
            return null;
        }

        // --- 步骤 3: 查询所有关联的周数 ---
        QueryWrapper<ScheduleWeeks> weekQueryWrapper = new QueryWrapper<>();
        weekQueryWrapper.eq("schedule_id", scheduleId);
        List<ScheduleWeeks> weekEntities = scheduleWeeksMapper.selectList(weekQueryWrapper);
        List<Integer> weekNumbers = weekEntities.stream()
                .map(ScheduleWeeks::getWeekNumber)
                .collect(Collectors.toList());

        // --- 步骤 4: 组装成VO返回 ---
        ScheduleDetailVO vo = new ScheduleDetailVO();
        vo.setCourseName(course.getName());
        vo.setTeacher(course.getTeacher());
        vo.setColor(course.getColor());
        vo.setLocation(schedule.getLocation());
        vo.setDayOfWeek(schedule.getDayOfWeek());
        vo.setStartPeriod(schedule.getStartPeriod());
        vo.setEndPeriod(schedule.getEndPeriod());
        vo.setWeeks(weekNumbers); // ★★★ 关键：设置原始的周数列表 ★★★

        return vo;
    }

}
