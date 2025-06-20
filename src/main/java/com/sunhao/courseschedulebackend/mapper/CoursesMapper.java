package com.sunhao.courseschedulebackend.mapper;

import com.sunhao.courseschedulebackend.entity.po.Courses;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.sunhao.courseschedulebackend.entity.vo.WeeklyCourseVO;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

/**
 * <p>
 * 课程静态信息表 Mapper 接口
 * </p>
 *
 * @author sunhao
 * @since 2025-06-20
 */
@Mapper
public interface CoursesMapper extends BaseMapper<Courses> {

    /**
     * 根据学期ID和周数查询课程信息
     * @param semesterId 学期ID
     * @param weekNumber 周数
     * @return 课程信息列表
     */
    List<WeeklyCourseVO.CourseInfo> findCoursesByWeek(@Param("semesterId") Long semesterId, @Param("weekNumber") Integer weekNumber);

    /**
     * 根据学期ID、周数和星期几查询课程信息
     * @param semesterId 学期ID
     * @param weekNumber 周数
     * @param dayOfWeek  星期几 (1-7)
     * @return 课程信息列表
     */
    List<WeeklyCourseVO.CourseInfo> findCoursesByDetails(
            @Param("semesterId") Long semesterId,
            @Param("weekNumber") Integer weekNumber,
            @Param("dayOfWeek") Integer dayOfWeek
    );
}
