package com.sunhao.courseschedulebackend.service.serviceimpl;

import com.sunhao.courseschedulebackend.entity.po.Courses;
import com.sunhao.courseschedulebackend.entity.po.Semesters;
import com.sunhao.courseschedulebackend.entity.vo.WeeklyCourseVO;
import com.sunhao.courseschedulebackend.mapper.CoursesMapper;
import com.sunhao.courseschedulebackend.mapper.SemestersMapper;
import com.sunhao.courseschedulebackend.service.CoursesService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import org.springframework.stereotype.Service;

import javax.annotation.Resource;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

/**
 * <p>
 * 课程静态信息表 服务实现类
 * </p>
 *
 * @author sunhao
 * @since 2025-06-20
 */
@Service
public class CoursesServiceImpl extends ServiceImpl<CoursesMapper, Courses> implements CoursesService {

    @Resource
    private SemestersMapper semestersMapper;

    @Override
    public WeeklyCourseVO getWeeklyCourses(Long semesterId, Integer weekNumber) {
        // 1. 查询课程信息
        List<WeeklyCourseVO.CourseInfo> courses = baseMapper.findCoursesByWeek(semesterId, weekNumber);

        // 2. 查询学期信息以计算日期
        Semesters semester = semestersMapper.selectById(semesterId);
        if (semester == null) {
            // 可以抛出自定义异常，或返回null
            return null;
        }

        // 3. 计算并生成周信息 (weekInfo)
        List<WeeklyCourseVO.WeekInfo> weekInfoList = generateWeekInfo(semester.getStartDate(), weekNumber);

        // 4. 组装最终的DTO
        WeeklyCourseVO result = new WeeklyCourseVO();
        result.setWeekNumber(weekNumber);
        result.setCourses(courses);
        result.setWeekInfo(weekInfoList);

        return result;
    }

    /**
     * 根据学期开始日期和周数，生成该周的日期信息
     * @param semesterStartDate 学期第一周的周一的日期
     * @param weekNumber 当前周数
     * @return 一周的日期信息列表
     */
    private List<WeeklyCourseVO.WeekInfo> generateWeekInfo(LocalDate semesterStartDate, Integer weekNumber) {
        List<WeeklyCourseVO.WeekInfo> weekInfoList = new ArrayList<>();
        // 计算当前周的周一的日期
        LocalDate mondayOfWeek = semesterStartDate.plusWeeks(weekNumber - 1);

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM/dd");
        String[] dayNames = {"周一", "周二", "周三", "周四", "周五", "周六", "周日"};

        for (int i = 0; i < 7; i++) {
            LocalDate currentDate = mondayOfWeek.plusDays(i);
            WeeklyCourseVO.WeekInfo info = new WeeklyCourseVO.WeekInfo();
            info.setDayOfWeek(i + 1);
            info.setDate(currentDate.format(formatter));
            info.setDayName(dayNames[i]);
            weekInfoList.add(info);
        }
        return weekInfoList;
    }

    @Override
    public List<WeeklyCourseVO.CourseInfo> getTodayCourses(Long semesterId) {
        // 1. 查询学期信息以获取开学日期
        Semesters semester = semestersMapper.selectById(semesterId);
        if (semester == null) {
            // 如果学期不存在，返回空列表
            return new ArrayList<>();
        }

        LocalDate semesterStartDate = semester.getStartDate();
        LocalDate today = LocalDate.now();

        // 2. 如果今天还没开学，或者已经过了学期总周数，直接返回空
        if (today.isBefore(semesterStartDate) || today.isAfter(semesterStartDate.plusWeeks(semester.getTotalWeeks()))) {
            return new ArrayList<>();
        }

        // 3. 计算今天是第几周
        long daysBetween = ChronoUnit.DAYS.between(semesterStartDate, today);
        int currentWeekNumber = (int) (daysBetween / 7) + 1;

        // 4. 计算今天是星期几 (1=周一, 7=周日)
        int currentDayOfWeek = today.getDayOfWeek().getValue();

        // 5. 调用Mapper查询今天的课程
        return baseMapper.findCoursesByDetails(semesterId, currentWeekNumber, currentDayOfWeek);
    }

}
