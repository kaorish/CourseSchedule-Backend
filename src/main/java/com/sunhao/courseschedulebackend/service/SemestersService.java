package com.sunhao.courseschedulebackend.service;

import com.sunhao.courseschedulebackend.entity.dto.SemesterUpdateDTO;
import com.sunhao.courseschedulebackend.entity.po.Semesters;
import com.baomidou.mybatisplus.extension.service.IService;

/**
 * <p>
 * 学期信息表 服务类
 * </p>
 *
 * @author sunhao
 * @since 2025-06-20
 */
public interface SemestersService extends IService<Semesters> {

    boolean updateSemester(Long id, SemesterUpdateDTO semesterUpdateDTO);
}
