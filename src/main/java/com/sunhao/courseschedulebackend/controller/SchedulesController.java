package com.sunhao.courseschedulebackend.controller;

import com.sunhao.courseschedulebackend.entity.dto.ScheduleAddDTO;
import com.sunhao.courseschedulebackend.entity.dto.ScheduleUpdateDTO;
import com.sunhao.courseschedulebackend.entity.vo.ScheduleDetailVO;
import com.sunhao.courseschedulebackend.entity.vo.ScheduleManageVO;
import com.sunhao.courseschedulebackend.service.SchedulesService;
import com.sunhao.courseschedulebackend.util.ResultUtil;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

/**
 * <p>
 * 课程具体时间地点安排表 前端控制器
 * </p>
 *
 * @author sunhao
 * @since 2025-06-20
 */
@RestController
@RequestMapping("/api/schedules")
public class SchedulesController {

    @Resource
    private SchedulesService schedulesService;

    /**
     * 获取指定学期的课程管理列表
     * @param semesterId 学期ID
     * @return 格式化好的课程安排列表
     */
    @GetMapping
    public ResultUtil getScheduleList(@RequestParam("semesterId") Long semesterId) {
        if (semesterId == null) {
            return ResultUtil.isFail(400, "学期ID不能为空");
        }
        List<ScheduleManageVO> list = schedulesService.getScheduleManageList(semesterId);
        return ResultUtil.isSuccess(list);
    }

    /**
     * 添加一个新的课程安排
     * @param scheduleAddDTO 包含新课程所有信息的DTO
     * @return 操作结果
     */
    @PostMapping
    public ResultUtil addSchedule(@RequestBody ScheduleAddDTO scheduleAddDTO) {
        // 可以在这里添加一些参数校验逻辑

        try {
            boolean success = schedulesService.addSchedule(scheduleAddDTO);
            if (success) {
                // 添加成功后，我们可以让前端重新请求列表，所以这里只返回成功信息
                return ResultUtil.isSuccess("添加课程成功", null);
            } else {
                return ResultUtil.isFail(500, "添加课程失败");
            }
        } catch (Exception e) {
            // 直接打印堆栈信息到控制台，效果类似
            e.printStackTrace();
            return ResultUtil.isFail(500, "添加课程失败，服务器内部错误: " + e.getMessage());
        }
    }

    /**
     * 根据ID删除一个课程安排
     * @param id 要删除的scheduleId
     * @return 操作结果
     */
    @DeleteMapping("/{id}")
    public ResultUtil deleteSchedule(@PathVariable("id") Long id) {
        if (id == null) {
            return ResultUtil.isFail(400, "ID不能为空");
        }

        try {
            boolean success = schedulesService.deleteSchedule(id);
            if (success) {
                return ResultUtil.isSuccess("删除成功", null);
            } else {
                return ResultUtil.isFail(404, "未找到要删除的课程安排");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return ResultUtil.isFail(500, "删除失败，服务器内部错误: " + e.getMessage());
        }
    }

    /**
     * 根据ID更新一个课程安排
     * @param id 要更新的scheduleId
     * @param scheduleUpdateDTO 包含更新信息的DTO
     * @return 操作结果
     */
    @PutMapping("/{id}")
    public ResultUtil updateSchedule(
            @PathVariable("id") Long id,
            @RequestBody ScheduleUpdateDTO scheduleUpdateDTO) {

        if (id == null) {
            return ResultUtil.isFail(400, "ID不能为空");
        }

        try {
            boolean success = schedulesService.updateSchedule(id, scheduleUpdateDTO);
            if (success) {
                return ResultUtil.isSuccess("更新成功", null);
            } else {
                return ResultUtil.isFail(404, "未找到要更新的课程安排");
            }
        } catch (Exception e) {
            e.printStackTrace();
            return ResultUtil.isFail(500, "更新失败，服务器内部错误: " + e.getMessage());
        }
    }

    /**
     * 根据ID获取单个课程安排的详细信息（用于编辑回显）
     * @param id scheduleId
     * @return 未加工的课程安排详情
     */
    @GetMapping("/{id}")
    public ResultUtil getScheduleDetail(@PathVariable("id") Long id) {
        if (id == null) {
            return ResultUtil.isFail(400, "ID不能为空");
        }

        ScheduleDetailVO detailVO = schedulesService.getScheduleDetailById(id);

        if (detailVO != null) {
            return ResultUtil.isSuccess(detailVO);
        } else {
            return ResultUtil.isFail(404, "未找到指定的课程安排");
        }
    }

}
