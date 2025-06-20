package com.sunhao.courseschedulebackend.service.serviceimpl;

import com.sunhao.courseschedulebackend.entity.dto.SemesterUpdateDTO;
import com.sunhao.courseschedulebackend.entity.po.Semesters;
import com.sunhao.courseschedulebackend.mapper.SemestersMapper;
import com.sunhao.courseschedulebackend.service.SemestersService;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.sunhao.courseschedulebackend.util.ResultUtil;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;

import javax.annotation.Resource;

/**
 * <p>
 * 学期信息表 服务实现类
 * </p>
 *
 * @author sunhao
 * @since 2025-06-20
 */
@Service
public class SemestersServiceImpl extends ServiceImpl<SemestersMapper, Semesters> implements SemestersService {

    @Override
    public boolean updateSemester(Long id, SemesterUpdateDTO semesterUpdateDTO) {
        // 1. 先根据ID查询出已有的学期实体
        Semesters semester = this.getById(id);
        if (semester == null) {
            // 如果学期不存在，返回false表示更新失败
            return false;
        }

        // 2. 将DTO中的数据更新到POJO实体中
        if (semesterUpdateDTO.getStartDate() != null) {
            semester.setStartDate(semesterUpdateDTO.getStartDate());
        }
        if (semesterUpdateDTO.getTotalWeeks() != null) {
            semester.setTotalWeeks(semesterUpdateDTO.getTotalWeeks());
        }

        // 3. 调用MyBatis-Plus的updateById方法，它会自动更新有变化的字段
        return this.updateById(semester);
    }
}
