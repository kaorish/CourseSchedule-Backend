package com.sunhao.courseschedulebackend.controller;

import com.sunhao.courseschedulebackend.entity.vo.WeeklyCourseVO;
import com.sunhao.courseschedulebackend.service.CoursesService;
import com.sunhao.courseschedulebackend.util.ResultUtil;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;
import java.util.List;

/**
 * <p>
 * 课程静态信息表 前端控制器
 * </p>
 *
 * @author sunhao
 * @since 2025-06-20
 */
@RestController
@RequestMapping("/api/courses")
public class CoursesController {

    @Resource
    private CoursesService coursesService;

    /**
     * 根据学期ID和周数查询一周的课程
     * @param semesterId 学期ID
     * @param week 周数
     * @return 包含该周课程和日期信息的VO
     */
    @GetMapping
    public ResultUtil getCoursesByWeek(
            @RequestParam("semesterId") Long semesterId,
            @RequestParam("week") Integer week) {

        if (semesterId == null || week == null || week < 1) {
            return ResultUtil.isFail(400, "参数错误：semesterId和week不能为空，且week必须大于0");
        }

        WeeklyCourseVO weeklyCourses = coursesService.getWeeklyCourses(semesterId, week);

        if (weeklyCourses == null) {
            return ResultUtil.isFail(404, "未找到对应的学期信息");
        }

        return ResultUtil.isSuccess(weeklyCourses);
    }

    /**
     * 查询今天的课程
     * @param semesterId 当前学期ID
     * @return 今天的课程列表
     */
    @GetMapping("/today")
    public ResultUtil getTodayCourses(@RequestParam("semesterId") Long semesterId) {
        if (semesterId == null) {
            return ResultUtil.isFail(400, "参数错误：semesterId不能为空");
        }

        List<WeeklyCourseVO.CourseInfo> todayCourses = coursesService.getTodayCourses(semesterId);

        return ResultUtil.isSuccess(todayCourses);
    }
}
