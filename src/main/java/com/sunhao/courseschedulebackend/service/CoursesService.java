package com.sunhao.courseschedulebackend.service;

import com.sunhao.courseschedulebackend.entity.po.Courses;
import com.baomidou.mybatisplus.extension.service.IService;
import com.sunhao.courseschedulebackend.entity.vo.WeeklyCourseVO;

import java.util.List;

/**
 * <p>
 * 课程静态信息表 服务类
 * </p>
 *
 * @author sunhao
 * @since 2025-06-20
 */
public interface CoursesService extends IService<Courses> {

    WeeklyCourseVO getWeeklyCourses(Long semesterId, Integer weekNumber);


    List<WeeklyCourseVO.CourseInfo> getTodayCourses(Long semesterId);
}
