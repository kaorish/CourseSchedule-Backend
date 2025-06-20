package com.sunhao.courseschedulebackend.controller;

import com.sunhao.courseschedulebackend.entity.dto.SemesterUpdateDTO;
import com.sunhao.courseschedulebackend.entity.po.Semesters;
import com.sunhao.courseschedulebackend.service.SemestersService;
import com.sunhao.courseschedulebackend.util.ResultUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.annotation.Resource;
import java.util.List;

/**
 * <p>
 * 学期信息表 前端控制器
 * </p>
 *
 * @author sunhao
 * @since 2025-06-20
 */
@RestController
@RequestMapping("/api/semesters") // 为整个Controller设置统一的前缀
public class SemestersController {

    @Resource
    private SemestersService semestersService;

    /**
     * 获取所有学期列表
     * @return 包含所有学期信息的列表
     */
    @GetMapping
    public ResultUtil getAllSemesters() {
        // 直接调用MyBatis-Plus提供的list()方法，查询semesters表的所有数据
        List<Semesters> semesterList = semestersService.list();

        // 使用你的ResultUtil来包装返回结果
        return ResultUtil.isSuccess(semesterList);
    }

    /**
     * 更新指定ID的学期信息
     * @param id 学期ID
     * @param semesterUpdateDTO 包含要更新的数据的DTO
     * @return 操作结果
     */
    @PutMapping("/{id}")
    public ResultUtil updateSemester(
            @PathVariable("id") Long id,
            @RequestBody SemesterUpdateDTO semesterUpdateDTO) {

        boolean success = semestersService.updateSemester(id, semesterUpdateDTO);

        if (success) {
            return ResultUtil.isSuccess("学期信息更新成功", null);
        } else {
            return ResultUtil.isFail(404, "未找到指定学期或更新失败");
        }
    }
}
