-- ====================================================================
--  数据库创建语句
-- ====================================================================

-- 如果存在名为 CourseSchedule 的数据库，则先删除，防止冲突
DROP DATABASE IF EXISTS `CourseSchedule`;

-- 创建名为 CourseSchedule 的数据库，并设置默认字符集为 utf8mb4
-- 创建数据库时，不仅指定字符集，还明确指定默认的排序规则
CREATE DATABASE `CourseSchedule`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

-- 切换到新创建的数据库上下文
USE `CourseSchedule`;

-- ====================================================================
--  1. 学期表 (semesters)
-- ====================================================================
CREATE TABLE `semesters` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '学期唯一自增ID',
  `name` VARCHAR(255) NOT NULL COMMENT '学期显示名称, 如: 2024-2025-1',
  `start_date` DATE NOT NULL COMMENT '学期第一周的周一的日期',
  `total_weeks` TINYINT UNSIGNED NOT NULL COMMENT '学期总周数',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_name` (`name`) -- 保证学期名称唯一，防止重复添加
) ENGINE=InnoDB COMMENT='学期信息表';

-- ====================================================================
--  2. 课程信息表 (courses)
-- ====================================================================
CREATE TABLE `courses` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '课程唯一自增ID',
  `semester_id` BIGINT NOT NULL COMMENT '所属学期的自增ID',
  `name` VARCHAR(255) NOT NULL COMMENT '课程名称',
  `teacher` VARCHAR(255) DEFAULT NULL COMMENT '教师姓名',
  `color` VARCHAR(10) DEFAULT '#81D4FA' COMMENT '课程卡片颜色',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_courses_semester_id` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='课程静态信息表';

-- ====================================================================
--  3. 课程安排表 (schedules)
-- ====================================================================
CREATE TABLE `schedules` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '课程安排的唯一自增ID',
  `course_id` BIGINT NOT NULL COMMENT '关联的课程自增ID',
  `location` VARCHAR(255) DEFAULT NULL COMMENT '上课地点',
  `day_of_week` TINYINT NOT NULL COMMENT '周几 (1-7)',
  `start_period` TINYINT NOT NULL COMMENT '开始节次',
  `end_period` TINYINT NOT NULL COMMENT '结束节次',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_schedules_course_id` FOREIGN KEY (`course_id`) REFERENCES `courses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='课程具体时间地点安排表';

-- ====================================================================
--  4. 安排周数表 (schedule_weeks)
-- ====================================================================
CREATE TABLE `schedule_weeks` (
  `id` BIGINT NOT NULL AUTO_INCREMENT,
  `schedule_id` BIGINT NOT NULL COMMENT '关联的课程安排自增ID',
  `week_number` TINYINT UNSIGNED NOT NULL COMMENT '具体的周数',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_schedule_week` (`schedule_id`, `week_number`),
  CONSTRAINT `fk_schedule_weeks_schedule_id` FOREIGN KEY (`schedule_id`) REFERENCES `schedules` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB COMMENT='课程安排生效周数表';


-- ====================================================================
--  插入 2024-2025-2 学期数据 (V4 - 硬编码ID、极简版)
-- ====================================================================

USE `CourseSchedule`;
SET NAMES 'utf8mb4' COLLATE 'utf8mb4_unicode_ci';

-- --- 步骤 1: 插入学期信息 (我们知道它将生成 ID=1) ---
INSERT INTO `semesters` (`name`, `start_date`, `total_weeks`) VALUES
('2024-2025-2', '2025-02-17', 19);

-- --- 步骤 2: 插入课程静态信息 (直接指定 semester_id = 1) ---
INSERT INTO `courses` (`semester_id`, `name`, `teacher`, `color`) VALUES
(1, '编译原理', '欧阳城添', '#FFAB91'),
(1, '大数据技术', '陈益杉', '#81D4FA'),
(1, '信息安全', '黄伟东', '#C5E1A5'),
(1, '机器学习', '谢润山', '#FFF59D'),
(1, '大学生就业指导', '刘勇', '#B39DDB'),
(1, '鸿蒙应用开发', '曾鹏程', '#F48FB1'),
(1, '人工智能', '黄光健', '#80CBC4');

-- --- 步骤 3: 插入课程安排 (Schedules) (同样用子查询关联，但更直接) ---
-- 注意：这里我将所有schedules的INSERT合并成一条，更高效。
-- 我们知道course表的ID是从1开始自增的，但为了脚本的健壮性，这里仍然使用子查询关联。
INSERT INTO `schedules` (`course_id`, `location`, `day_of_week`, `start_period`, `end_period`) VALUES
((SELECT id FROM courses WHERE name='编译原理' AND semester_id=1), '阅道109', 1, 1, 2), -- 编译原理(周一)
((SELECT id FROM courses WHERE name='编译原理' AND semester_id=1), '阅道107', 3, 1, 2), -- 编译原理(周三)
((SELECT id FROM courses WHERE name='大数据技术' AND semester_id=1), '阅道109', 5, 1, 2), -- 大数据技术(周五)
((SELECT id FROM courses WHERE name='信息安全' AND semester_id=1), '阅道121', 2, 3, 4), -- 信息安全(周二)
((SELECT id FROM courses WHERE name='机器学习' AND semester_id=1), '阅道316', 2, 3, 4), -- 机器学习(周二)
((SELECT id FROM courses WHERE name='大学生就业指导' AND semester_id=1), '文山106', 4, 3, 4), -- 大学生就业指导(周四)
((SELECT id FROM courses WHERE name='信息安全' AND semester_id=1), '阅道214', 5, 3, 4), -- 信息安全(周五)
((SELECT id FROM courses WHERE name='大数据技术' AND semester_id=1), '阅道109', 1, 5, 6), -- 大数据技术(周一)
((SELECT id FROM courses WHERE name='鸿蒙应用开发' AND semester_id=1), '九章209', 3, 5, 6), -- 鸿蒙应用开发(周三)
((SELECT id FROM courses WHERE name='人工智能' AND semester_id=1), '阅道209', 5, 5, 6), -- 人工智能(周五)
((SELECT id FROM courses WHERE name='鸿蒙应用开发' AND semester_id=1), '九章209', 2, 7, 8), -- 鸿蒙应用开发(周二)
((SELECT id FROM courses WHERE name='人工智能' AND semester_id=1), '阅道209', 4, 7, 8), -- 人工智能(周四)
((SELECT id FROM courses WHERE name='机器学习' AND semester_id=1), '阅道316', 4, 7, 8); -- 机器学习(周四)


-- --- 步骤 4: 插入周数 (Schedule_Weeks) ---
-- 我们知道schedules表的ID是从1开始自增的，所以可以直接硬编码ID。
INSERT INTO `schedule_weeks` (`schedule_id`, `week_number`) VALUES
-- 编译原理(周一, schedule_id=1)
(1, 1),(1, 2),(1, 3),(1, 4),(1, 5),(1, 6),(1, 7),(1, 8),(1, 9),(1, 10),(1, 11),(1, 12),
-- 编译原理(周三, schedule_id=2)
(2, 1),(2, 2),(2, 3),(2, 4),(2, 5),(2, 6),(2, 7),(2, 8),(2, 9),(2, 10),(2, 11),(2, 12),
-- 大数据技术(周五, schedule_id=3)
(3, 9),(3, 10),(3, 11),(3, 12),(3, 13),(3, 14),(3, 15),(3, 16),
-- 信息安全(周二, schedule_id=4)
(4, 1),(4, 2),(4, 3),(4, 4),(4, 5),(4, 6),(4, 7),(4, 8),
-- 机器学习(周二, schedule_id=5)
(5, 9),(5, 10),(5, 11),(5, 12),(5, 13),(5, 14),(5, 15),(5, 16),
-- 大学生就业指导(周四, schedule_id=6)
(6, 5),(6, 6),(6, 7),(6, 8),
-- 信息安全(周五, schedule_id=7)
(7, 1),(7, 2),(7, 3),(7, 4),(7, 5),(7, 6),(7, 7),(7, 8),
-- 大数据技术(周一, schedule_id=8)
(8, 9),(8, 10),(8, 11),(8, 12),(8, 13),(8, 14),(8, 15),(8, 16),
-- 鸿蒙应用开发(周三, schedule_id=9)
(9, 7),(9, 8),(9, 9),(9, 10),(9, 11),(9, 12),(9, 13),(9, 14),(9, 15),(9, 16),
-- 人工智能(周五, schedule_id=10)
(10, 1),(10, 2),(10, 3),(10, 4),(10, 5),(10, 6),(10, 7),(10, 8),
-- 鸿蒙应用开发(周二, schedule_id=11)
(11, 7),(11, 8),(11, 9),(11, 10),(11, 11),(11, 12),(11, 13),(11, 14),(11, 15),(11, 16),
-- 人工智能(周四, schedule_id=12)
(12, 1),(12, 2),(12, 3),(12, 4),(12, 5),(12, 6),(12, 7),(12, 8),
-- 机器学习(周四, schedule_id=13)
(13, 9),(13, 10),(13, 11),(13, 12),(13, 13),(13, 14),(13, 15),(13, 16);

SELECT 'Data for semester 2024-2025-2 (ID=1) has been inserted successfully.' AS status;


-- ====================================================================
--  插入 2024-2025-1 学期数据 (ID=2)
-- ====================================================================

USE `CourseSchedule`;
SET NAMES 'utf8mb4' COLLATE 'utf8mb4_unicode_ci';

-- --- 步骤 1: 插入学期信息 (我们知道它将生成 ID=2) ---
INSERT INTO `semesters` (`name`, `start_date`, `total_weeks`) VALUES
('2024-2025-1', '2024-09-02', 19);

-- --- 步骤 2: 插入课程静态信息 (直接指定 semester_id = 2) ---
INSERT INTO `courses` (`semester_id`, `name`, `teacher`, `color`) VALUES
(2, '汇编语言与微机原理', '欧阳城添', '#FFAB91'),
(2, 'Linux系统编程', '蔡华帅', '#A5D6A7'),
(2, '算法分析与设计', '黄光健', '#80CBC4'),
(2, '数字图像处理', '黄伟东', '#C5E1A5'),
(2, '软件工程', '陈益杉', '#81D4FA'),
(2, '计算机网络', '李伟', '#9FA8DA'),
(2, 'Web技术及应用', '吴剑青', '#F48FB1'),
(2, '形势与政策(三)', '李金德', '#B39DDB');

-- --- 步骤 3: 插入课程安排 (Schedules) ---
INSERT INTO `schedules` (`course_id`, `location`, `day_of_week`, `start_period`, `end_period`) VALUES
-- 汇编语言与微机原理
((SELECT id FROM courses WHERE name='汇编语言与微机原理' AND semester_id=2), '阅道409', 1, 1, 2), -- ID: 14
((SELECT id FROM courses WHERE name='Linux系统编程' AND semester_id=2), '阅道311', 2, 1, 2),     -- ID: 15
((SELECT id FROM courses WHERE name='算法分析与设计' AND semester_id=2), '文山219', 3, 1, 2),     -- ID: 16
((SELECT id FROM courses WHERE name='汇编语言与微机原理' AND semester_id=2), '阅道409', 4, 1, 2), -- ID: 17
((SELECT id FROM courses WHERE name='数字图像处理' AND semester_id=2), '阅道121', 5, 1, 2),     -- ID: 18
-- 3-4节
((SELECT id FROM courses WHERE name='软件工程' AND semester_id=2), '阅道407', 1, 3, 4),        -- ID: 19
((SELECT id FROM courses WHERE name='计算机网络' AND semester_id=2), '阅道409', 2, 3, 4),        -- ID: 20
((SELECT id FROM courses WHERE name='计算机网络' AND semester_id=2), '阅道408', 3, 3, 4),        -- ID: 21
((SELECT id FROM courses WHERE name='Web技术及应用' AND semester_id=2), '阅道409', 3, 3, 4),     -- ID: 22
((SELECT id FROM courses WHERE name='计算机网络' AND semester_id=2), '阅道408', 4, 3, 4),        -- ID: 23
((SELECT id FROM courses WHERE name='形势与政策(三)' AND semester_id=2), '文山316', 5, 3, 4),      -- ID: 24
-- 5-6节
((SELECT id FROM courses WHERE name='Web技术及应用' AND semester_id=2), '阅道309', 1, 5, 6),     -- ID: 25
((SELECT id FROM courses WHERE name='软件工程' AND semester_id=2), '阅道407', 3, 5, 6),        -- ID: 26
((SELECT id FROM courses WHERE name='数字图像处理' AND semester_id=2), '阅道129', 4, 5, 6),     -- ID: 27
((SELECT id FROM courses WHERE name='Linux系统编程' AND semester_id=2), '阅道311', 4, 5, 6),     -- ID: 28
((SELECT id FROM courses WHERE name='算法分析与设计' AND semester_id=2), '文山219', 5, 5, 6),     -- ID: 29
-- 7-8节
((SELECT id FROM courses WHERE name='数字图像处理' AND semester_id=2), '阅道124', 2, 7, 8);      -- ID: 30

-- --- 步骤 4: 插入周数 (Schedule_Weeks) ---
INSERT INTO `schedule_weeks` (`schedule_id`, `week_number`) VALUES
-- 汇编 (周一, ID: 14), 6-17周
(14, 6),(14, 7),(14, 8),(14, 9),(14, 10),(14, 11),(14, 12),(14, 13),(14, 14),(14, 15),(14, 16),(14, 17),
-- Linux (周二, ID: 15), 9-16周
(15, 9),(15, 10),(15, 11),(15, 12),(15, 13),(15, 14),(15, 15),(15, 16),
-- 算法 (周三, ID: 16), 1-4,6-11周
(16, 1),(16, 2),(16, 3),(16, 4),(16, 6),(16, 7),(16, 8),(16, 9),(16, 10),(16, 11),
-- 汇编 (周四, ID: 17), 6-17周
(17, 6),(17, 7),(17, 8),(17, 9),(17, 10),(17, 11),(17, 12),(17, 13),(17, 14),(17, 15),(17, 16),(17, 17),
-- 图像 (周五, ID: 18), 1-4,6-9周
(18, 1),(18, 2),(18, 3),(18, 4),(18, 6),(18, 7),(18, 8),(18, 9),
-- 软工 (周一, ID: 19), 4,6-16周
(19, 4),(19, 6),(19, 7),(19, 8),(19, 9),(19, 10),(19, 11),(19, 12),(19, 13),(19, 14),(19, 15),(19, 16),
-- 网路 (周二, ID: 20), 2-4,6-13周
(20, 2),(20, 3),(20, 4),(20, 6),(20, 7),(20, 8),(20, 9),(20, 10),(20, 11),(20, 12),(20, 13),
-- 网路 (周三, ID: 21), 1周
(21, 1),
-- Web (周三, ID: 22), 7-16周
(22, 7),(22, 8),(22, 9),(22, 10),(22, 11),(22, 12),(22, 13),(22, 14),(22, 15),(22, 16),
-- 网路 (周四, ID: 23), 1-4,6-13周
(23, 1),(23, 2),(23, 3),(23, 4),(23, 6),(23, 7),(23, 8),(23, 9),(23, 10),(23, 11),(23, 12),(23, 13),
-- 形策 (周五, ID: 24), 11-14周
(24, 11),(24, 12),(24, 13),(24, 14),
-- Web (周一, ID: 25), 7-16周
(25, 7),(25, 8),(25, 9),(25, 10),(25, 11),(25, 12),(25, 13),(25, 14),(25, 15),(25, 16),
-- 软工 (周三, ID: 26), 4,6-16周
(26, 4),(26, 6),(26, 7),(26, 8),(26, 9),(26, 10),(26, 11),(26, 12),(26, 13),(26, 14),(26, 15),(26, 16),
-- 图像 (周四, ID: 27), 1周
(27, 1),
-- Linux (周四, ID: 28), 9-16周
(28, 9),(28, 10),(28, 11),(28, 12),(28, 13),(28, 14),(28, 15),(28, 16),
-- 算法 (周五, ID: 29), 1-4,6-11周
(29, 1),(29, 2),(29, 3),(29, 4),(29, 6),(29, 7),(29, 8),(29, 9),(29, 10),(29, 11),
-- 图像 (周二, ID: 30), 2-4,6-9周
(30, 2),(30, 3),(30, 4),(30, 6),(30, 7),(30, 8),(30, 9);


SELECT 'Data for semester 2024-2025-1 (ID=2) has been inserted successfully.' AS status;



-- ====================================================================
--  插入 2023-2024-2 学期数据 (ID=3)
-- ====================================================================

USE `CourseSchedule`;
SET NAMES 'utf8mb4' COLLATE 'utf8mb4_unicode_ci';

-- --- 步骤 1: 插入学期信息 (我们知道它将生成 ID=3) ---
INSERT INTO `semesters` (`name`, `start_date`, `total_weeks`) VALUES
('2023-2024-2', '2024-02-19', 19); -- 假设2024年春季学期开始日期

-- --- 步骤 2: 插入课程静态信息 (直接指定 semester_id = 3) ---
INSERT INTO `courses` (`semester_id`, `name`, `teacher`, `color`) VALUES
(3, '概率统计', '钟金', '#FFCDD2'),
(3, 'Python程序设计', '管希东', '#E1BEE7'),
(3, '毛泽东思想和中国特色社会主义理论体系概论', '武立敬', '#D1C4E9'),
(3, '大学英语(四)', '万莉', '#C5CAE9'),
(3, '计算机组成原理', '王茜娴', '#BBDEFB'),
(3, '形势与政策(二)', '刘晓军', '#B3E5FC'),
(3, '体育(四)', '李宗祥', '#B2EBF2'),
(3, '操作系统', '曾珽', '#B2DFDB'),
(3, '习近平新时代中国特色社会主义思想概论', '李丹', '#DCE775');

-- --- 步骤 3: 插入课程安排 (Schedules) ---
-- ID将从31开始自增
INSERT INTO `schedules` (`course_id`, `location`, `day_of_week`, `start_period`, `end_period`) VALUES
-- 1-2节
((SELECT id FROM courses WHERE name='概率统计' AND semester_id=3), '阅道306', 1, 1, 2), -- ID: 31
((SELECT id FROM courses WHERE name='Python程序设计' AND semester_id=3), '阅道220', 1, 1, 2), -- ID: 32
((SELECT id FROM courses WHERE name='概率统计' AND semester_id=3), '阅道306', 2, 1, 2), -- ID: 33
((SELECT id FROM courses WHERE name='毛泽东思想和中国特色社会主义理论体系概论' AND semester_id=3), '文山126', 3, 1, 2), -- ID: 34
((SELECT id FROM courses WHERE name='概率统计' AND semester_id=3), '阅道306', 4, 1, 2), -- ID: 35
((SELECT id FROM courses WHERE name='大学英语(四)' AND semester_id=3), '文山125', 4, 1, 2), -- ID: 36
((SELECT id FROM courses WHERE name='计算机组成原理' AND semester_id=3), '阅道209', 5, 1, 2), -- ID: 37
((SELECT id FROM courses WHERE name='大学英语(四)' AND semester_id=3), '文山124', 6, 1, 2), -- ID: 38
-- 3-4节
((SELECT id FROM courses WHERE name='计算机组成原理' AND semester_id=3), '阅道209', 1, 3, 4), -- ID: 39
((SELECT id FROM courses WHERE name='形势与政策(二)' AND semester_id=3), '文山115', 2, 3, 4), -- ID: 40
((SELECT id FROM courses WHERE name='Python程序设计' AND semester_id=3), '阅道220', 3, 3, 4), -- ID: 41
((SELECT id FROM courses WHERE name='体育(四)' AND semester_id=3), '健身房(三江东园)', 5, 3, 4), -- ID: 42
-- 5-6节
((SELECT id FROM courses WHERE name='大学英语(四)' AND semester_id=3), '阅道110', 1, 5, 6), -- ID: 43
((SELECT id FROM courses WHERE name='大学英语(四)' AND semester_id=3), '文山126', 1, 5, 6), -- ID: 44
((SELECT id FROM courses WHERE name='操作系统' AND semester_id=3), '阅道220', 3, 5, 6), -- ID: 45
((SELECT id FROM courses WHERE name='操作系统' AND semester_id=3), '阅道220', 4, 5, 6), -- ID: 46
((SELECT id FROM courses WHERE name='大学英语(四)' AND semester_id=3), '阅道110', 5, 5, 6), -- ID: 47
-- 7-8节
((SELECT id FROM courses WHERE name='操作系统' AND semester_id=3), '阅道220', 2, 7, 8), -- ID: 48
((SELECT id FROM courses WHERE name='习近平新时代中国特色社会主义思想概论' AND semester_id=3), '文山127', 3, 7, 8); -- ID: 49

-- --- 步骤 4: 插入周数 (Schedule_Weeks) ---
INSERT INTO `schedule_weeks` (`schedule_id`, `week_number`) VALUES
-- ID: 31, 概率(周一), 1-8周
(31,1),(31,2),(31,3),(31,4),(31,5),(31,6),(31,7),(31,8),
-- ID: 32, Python(周一), 9-16周
(32,9),(32,10),(32,11),(32,12),(32,13),(32,14),(32,15),(32,16),
-- ID: 33, 概率(周二), 1-8周
(33,1),(33,2),(33,3),(33,4),(33,5),(33,6),(33,7),(33,8),
-- ID: 34, 毛概(周三), 1-16周
(34,1),(34,2),(34,3),(34,4),(34,5),(34,6),(34,7),(34,8),(34,9),(34,10),(34,11),(34,12),(34,13),(34,14),(34,15),(34,16),
-- ID: 35, 概率(周四), 1-8周
(35,1),(35,2),(35,3),(35,4),(35,5),(35,6),(35,7),(35,8),
-- ID: 36, 英语(周四), 13周
(36,13),
-- ID: 37, 计组(周五), 1-12周
(37,1),(37,2),(37,3),(37,4),(37,5),(37,6),(37,7),(37,8),(37,9),(37,10),(37,11),(37,12),
-- ID: 38, 英语(周六), 4周
(38,4),
-- ID: 39, 计组(周一), 1-12周
(39,1),(39,2),(39,3),(39,4),(39,5),(39,6),(39,7),(39,8),(39,9),(39,10),(39,11),(39,12),
-- ID: 40, 形策(周二), 5-8周
(40,5),(40,6),(40,7),(40,8),
-- ID: 41, Python(周三), 9-16周
(41,9),(41,10),(41,11),(41,12),(41,13),(41,14),(41,15),(41,16),
-- ID: 42, 体育(周五), 1-16周
(42,1),(42,2),(42,3),(42,4),(42,5),(42,6),(42,7),(42,8),(42,9),(42,10),(42,11),(42,12),(42,13),(42,14),(42,15),(42,16),
-- ID: 43, 英语(周一), 1-7,9-12,14-16周
(43,1),(43,2),(43,3),(43,4),(43,5),(43,6),(43,7),(43,9),(43,10),(43,11),(43,12),(43,14),(43,15),(43,16),
-- ID: 44, 英语(周一), 17周
(44,17),
-- ID: 45, OS(周三), 1-5,7-12周
(45,1),(45,2),(45,3),(45,4),(45,5),(45,7),(45,8),(45,9),(45,10),(45,11),(45,12),
-- ID: 46, OS(周四), 7周
(46,7),
-- ID: 47, 英语(周五), 1,5,7,9,11,13,15周
(47,1),(47,5),(47,7),(47,9),(47,11),(47,13),(47,15),
-- ID: 48, OS(周二), 1-12周
(48,1),(48,2),(48,3),(48,4),(48,5),(48,6),(48,7),(48,8),(48,9),(48,10),(48,11),(48,12),
-- ID: 49, 习概(周三), 1-16周
(49,1),(49,2),(49,3),(49,4),(49,5),(49,6),(49,7),(49,8),(49,9),(49,10),(49,11),(49,12),(49,13),(49,14),(49,15),(49,16);

SELECT 'Data for semester 2023-2024-2 (ID=3) has been inserted successfully.' AS status;


-- ====================================================================
--  插入 2023-2024-1 学期数据 (ID=4)
-- ====================================================================

USE `CourseSchedule`;
SET NAMES 'utf8mb4' COLLATE 'utf8mb4_unicode_ci';

-- --- 步骤 1: 插入学期信息 (我们知道它将生成 ID=4) ---
INSERT INTO `semesters` (`name`, `start_date`, `total_weeks`) VALUES
('2023-2024-1', '2023-09-04', 19); -- 假设2023年秋季学期开始日期

-- --- 步骤 2: 插入课程静态信息 (直接指定 semester_id = 4) ---
INSERT INTO `courses` (`semester_id`, `name`, `teacher`, `color`) VALUES
(4, '数字逻辑与数字电路', '李大海', '#FFCC80'),
(4, '线性代数', '谷芳芳', '#90CAF9'),
(4, '大学物理(二)', '李晟', '#A5D6A7'),
(4, '数据结构', '涂燕琼', '#F48FB1'),
(4, '大学英语(三)', '张蒙', '#CE93D8'),
(4, '体育(三)', '李宗祥', '#80DEEA'),
(4, '数据库原理', '陈勋俊', '#FFE082'),
(4, '马克思主义基本原理', '朱晓珣', '#BCAAA4'),
(4, '大学物理实验', '刘云', '#B0BEC5');

-- --- 步骤 3: 插入课程安排 (Schedules) ---
-- ID将从50开始自增
INSERT INTO `schedules` (`course_id`, `location`, `day_of_week`, `start_period`, `end_period`) VALUES
-- 1-2节
((SELECT id FROM courses WHERE name='数字逻辑与数字电路' AND semester_id=4), '阅道217', 1, 1, 2), -- ID: 50
((SELECT id FROM courses WHERE name='线性代数' AND semester_id=4), '阅道104', 2, 1, 2), -- ID: 51
((SELECT id FROM courses WHERE name='数字逻辑与数字电路' AND semester_id=4), '阅道217', 3, 1, 2), -- ID: 52
((SELECT id FROM courses WHERE name='大学物理(二)' AND semester_id=4), '文山128', 4, 1, 2), -- ID: 53
-- 3-4节
((SELECT id FROM courses WHERE name='数据结构' AND semester_id=4), '阅道217', 1, 3, 4), -- ID: 54
((SELECT id FROM courses WHERE name='大学英语(三)' AND semester_id=4), '阅道208', 2, 3, 4), -- ID: 55
((SELECT id FROM courses WHERE name='数据结构' AND semester_id=4), '阅道217', 3, 3, 4), -- ID: 56
((SELECT id FROM courses WHERE name='线性代数' AND semester_id=4), '阅道104', 4, 3, 4), -- ID: 57
((SELECT id FROM courses WHERE name='体育(三)' AND semester_id=4), '健身房(三江东园)', 5, 3, 4), -- ID: 58
((SELECT id FROM courses WHERE name='数字逻辑与数字电路' AND semester_id=4), '阅道217', 6, 3, 4), -- ID: 59
-- 5-6节
((SELECT id FROM courses WHERE name='大学物理(二)' AND semester_id=4), '文山128', 1, 5, 6), -- ID: 60
((SELECT id FROM courses WHERE name='数据库原理' AND semester_id=4), '阅道124', 3, 5, 6), -- ID: 61
((SELECT id FROM courses WHERE name='数据库原理' AND semester_id=4), '阅道124', 3, 5, 6), -- ID: 62 (注意：这是调课，但时间地点一样，所以新建一个schedule)
((SELECT id FROM courses WHERE name='数据库原理' AND semester_id=4), '阅道123', 4, 5, 6), -- ID: 63
((SELECT id FROM courses WHERE name='数据库原理' AND semester_id=4), '阅道124', 5, 5, 6), -- ID: 64
-- 7-8节
((SELECT id FROM courses WHERE name='大学物理实验' AND semester_id=4), NULL, 2, 7, 8), -- ID: 65
((SELECT id FROM courses WHERE name='马克思主义基本原理' AND semester_id=4), '文山217', 3, 7, 8); -- ID: 66

-- --- 步骤 4: 插入周数 (Schedule_Weeks) ---
INSERT INTO `schedule_weeks` (`schedule_id`, `week_number`) VALUES
-- ID: 50, 数电(周一), 1-4,6-15,17周
(50,1),(50,2),(50,3),(50,4),(50,6),(50,7),(50,8),(50,9),(50,10),(50,11),(50,12),(50,13),(50,14),(50,15),(50,17),
-- ID: 51, 线代(周二), 1-4,6-9周
(51,1),(51,2),(51,3),(51,4),(51,6),(51,7),(51,8),(51,9),
-- ID: 52, 数电(周三), 1-4,6-17周
(52,1),(52,2),(52,3),(52,4),(52,6),(52,7),(52,8),(52,9),(52,10),(52,11),(52,12),(52,13),(52,14),(52,15),(52,16),(52,17),
-- ID: 53, 大物(周四), 1-4,6-11周
(53,1),(53,2),(53,3),(53,4),(53,6),(53,7),(53,8),(53,9),(53,10),(53,11),
-- ID: 54, 数据结构(周一), 1-4,6-13周
(54,1),(54,2),(54,3),(54,4),(54,6),(54,7),(54,8),(54,9),(54,10),(54,11),(54,12),(54,13),
-- ID: 55, 英语(周二), 1-4,6-17周
(55,1),(55,2),(55,3),(55,4),(55,6),(55,7),(55,8),(55,9),(55,10),(55,11),(55,12),(55,13),(55,14),(55,15),(55,16),(55,17),
-- ID: 56, 数据结构(周三), 1-4,6-13周
(56,1),(56,2),(56,3),(56,4),(56,6),(56,7),(56,8),(56,9),(56,10),(56,11),(56,12),(56,13),
-- ID: 57, 线代(周四), 1-4,6-9周
(57,1),(57,2),(57,3),(57,4),(57,6),(57,7),(57,8),(57,9),
-- ID: 58, 体育(周五), 1-4,6-17周
(58,1),(58,2),(58,3),(58,4),(58,6),(58,7),(58,8),(58,9),(58,10),(58,11),(58,12),(58,13),(58,14),(58,15),(58,16),(58,17),
-- ID: 59, 数电(周六), 16周
(59,16),
-- ID: 60, 大物(周一), 1-4,6-11周
(60,1),(60,2),(60,3),(60,4),(60,6),(60,7),(60,8),(60,9),(60,10),(60,11),
-- ID: 61, 数据库(周三), 8-15周
(61,8),(61,9),(61,10),(61,11),(61,12),(61,13),(61,14),(61,15),
-- ID: 62, 数据库(周三调课), 18周
(62,18),
-- ID: 63, 数据库(周四调课), 15,18周
(63,15),(63,18),
-- ID: 64, 数据库(周五), 8-15,17周
(64,8),(64,9),(64,10),(64,11),(64,12),(64,13),(64,14),(64,15),(64,17),
-- ID: 65, 大物实验(周二), 1-4,6-17周
(65,1),(65,2),(65,3),(65,4),(65,6),(65,7),(65,8),(65,9),(65,10),(65,11),(65,12),(65,13),(65,14),(65,15),(65,16),(65,17),
-- ID: 66, 马原(周三), 1-4,6-17周
(66,1),(66,2),(66,3),(66,4),(66,6),(66,7),(66,8),(66,9),(66,10),(66,11),(66,12),(66,13),(66,14),(66,15),(66,16),(66,17);

SELECT 'Data for semester 2023-2024-1 (ID=4) has been inserted successfully.' AS status;


-- ====================================================================
--  插入 2022-2023-2 学期数据 (ID=5)
-- ====================================================================

USE `CourseSchedule`;
SET NAMES 'utf8mb4' COLLATE 'utf8mb4_unicode_ci';

-- --- 步骤 1: 插入学期信息 (我们知道它将生成 ID=5) ---
INSERT INTO `semesters` (`name`, `start_date`, `total_weeks`) VALUES
('2022-2023-2', '2023-02-20', 19); -- 假设2023年春季学期开始日期

-- --- 步骤 2: 插入课程静态信息 (直接指定 semester_id = 5) ---
INSERT INTO `courses` (`semester_id`, `name`, `teacher`, `color`) VALUES
(5, '高等数学(二)', '郭挺', '#FFAB91'),
(5, 'JAVA语言程序设计', '李伟, 郑剑', '#A5D6A7'),
(5, '大学英语(二)', '卢欣欣', '#80CBC4'),
(5, '大学生创新创业基础', '邱鑫', '#C5E1A5'),
(5, '大学物理(一)', '朱云', '#81D4FA'),
(5, '体育(二)', '时圣稳', '#9FA8DA'),
(5, '形势与政策(一)', '刘晓军', '#F48FB1'),
(5, '离散数学', '涂燕琼', '#B39DDB'),
(5, '中国近现代史纲要', '吴光辉', '#FFE082');

-- --- 步骤 3: 插入课程安排 (Schedules) ---
-- ID将从67开始自增
INSERT INTO `schedules` (`course_id`, `location`, `day_of_week`, `start_period`, `end_period`) VALUES
-- 1-2节
((SELECT id FROM courses WHERE name='高等数学(二)' AND semester_id=5), '阅道207', 1, 1, 2), -- ID: 67
((SELECT id FROM courses WHERE name='JAVA语言程序设计' AND semester_id=5), '阅道112', 2, 1, 2), -- ID: 68
((SELECT id FROM courses WHERE name='高等数学(二)' AND semester_id=5), '阅道207', 2, 1, 2), -- ID: 69
((SELECT id FROM courses WHERE name='大学英语(二)' AND semester_id=5), '阅道207', 3, 1, 2), -- ID: 70
((SELECT id FROM courses WHERE name='高等数学(二)' AND semester_id=5), '阅道207', 4, 1, 2), -- ID: 71
((SELECT id FROM courses WHERE name='大学生创新创业基础' AND semester_id=5), '阅道122', 5, 1, 2), -- ID: 72
((SELECT id FROM courses WHERE name='大学英语(二)' AND semester_id=5), '阅道207', 5, 1, 2), -- ID: 73
-- 3-4节
((SELECT id FROM courses WHERE name='大学物理(一)' AND semester_id=5), '文山219', 1, 3, 4), -- ID: 74
((SELECT id FROM courses WHERE name='大学物理(一)' AND semester_id=5), '文山219', 1, 3, 4), -- ID: 75
((SELECT id FROM courses WHERE name='体育(二)' AND semester_id=5), '健身房(三江东园)', 2, 3, 4), -- ID: 76
((SELECT id FROM courses WHERE name='大学生创新创业基础' AND semester_id=5), '阅道122', 3, 3, 4), -- ID: 77
((SELECT id FROM courses WHERE name='形势与政策(一)' AND semester_id=5), '阅道310', 3, 3, 4), -- ID: 78
((SELECT id FROM courses WHERE name='大学物理(一)' AND semester_id=5), '文山219', 4, 3, 4), -- ID: 79
((SELECT id FROM courses WHERE name='离散数学' AND semester_id=5), '阅道320', 5, 3, 4), -- ID: 80
-- 5-6节
((SELECT id FROM courses WHERE name='大学生创新创业基础' AND semester_id=5), '阅道122', 1, 5, 6), -- ID: 81
((SELECT id FROM courses WHERE name='离散数学' AND semester_id=5), '阅道124', 3, 5, 6), -- ID: 82
-- 7-8节
((SELECT id FROM courses WHERE name='JAVA语言程序设计' AND semester_id=5), '阅道216', 3, 7, 8), -- ID: 83
((SELECT id FROM courses WHERE name='离散数学' AND semester_id=5), '阅道123', 3, 7, 8), -- ID: 84
((SELECT id FROM courses WHERE name='中国近现代史纲要' AND semester_id=5), '文山127', 5, 7, 8); -- ID: 85

-- --- 步骤 4: 插入周数 (Schedule_Weeks) ---
INSERT INTO `schedule_weeks` (`schedule_id`, `week_number`) VALUES
(67, 1),(67, 2),(67, 3),(67, 4),(67, 5),(67, 6),(67, 7),(67, 8),(67, 9),(67, 10),(67, 11),(67, 12),(67, 13),(67, 14),(67, 15),
(68, 1),(68, 2),(68, 3),(68, 4),(68, 5),(68, 6),(68, 7),(68, 8),(68, 9),(68, 10),(68, 11),(68, 12),
(69, 1),(69, 2),(69, 3),(69, 4),(69, 5),(69, 6),(69, 7),(69, 8),(69, 9),(69, 10),(69, 11),(69, 12),(69, 13),(69, 14),(69, 15),
(70, 1),(70, 2),(70, 3),(70, 4),(70, 5),(70, 6),(70, 7),(70, 8),(70, 9),(70, 10),(70, 11),(70, 12),(70, 13),(70, 14),(70, 15),(70, 16),
(71, 1),(71, 2),(71, 3),(71, 4),(71, 5),(71, 6),(71, 7),(71, 8),(71, 9),(71, 10),(71, 11),(71, 12),(71, 13),(71, 14),
(72, 9),
(73, 2),(73, 4),(73, 6),(73, 8),(73, 10),(73, 12),(73, 14),(73, 16),
(74, 1),(74, 2),(74, 3),(74, 4),(74, 5),(74, 6),(74, 7),(74, 8),(74, 10),(74, 11),(74, 12),(74, 13),(74, 14),
(75, 15),
(76, 1),(76, 2),(76, 3),(76, 4),(76, 5),(76, 6),(76, 7),(76, 8),(76, 9),(76, 10),(76, 11),(76, 12),(76, 13),(76, 14),(76, 15),(76, 16),
(77, 1),(77, 2),(77, 3),(77, 5),(77, 6),(77, 7),(77, 8),
(78, 11),(78, 12),(78, 13),(78, 14),
(79, 1),(79, 2),(79, 3),(79, 4),(79, 5),(79, 6),(79, 7),(79, 8),(79, 9),(79, 10),(79, 11),(79, 12),(79, 13),(79, 14),
(80, 1),(80, 2),(80, 3),(80, 4),(80, 5),(80, 6),(80, 7),(80, 8),(80, 9),(80, 10),(80, 11),(80, 12),(80, 13),(80, 14),(80, 15),(80, 16),
(81, 1),(81, 2),(81, 3),(81, 4),(81, 5),(81, 6),(81, 7),(81, 8),
(82, 9),(82, 10),(82, 11),(82, 12),(82, 13),(82, 14),(82, 15),(82, 16),
(83, 1),(83, 2),(83, 3),(83, 4),(83, 5),(83, 6),(83, 7),(83, 8),(83, 9),(83, 10),(83, 11),(83, 12),
(84, 1),(84, 2),(84, 3),(84, 4),(84, 5),(84, 6),(84, 7),(84, 8),
(85, 1),(85, 2),(85, 3),(85, 4),(85, 5),(85, 6),(85, 7),(85, 8),(85, 9),(85, 10),(85, 11),(85, 12),(85, 13),(85, 14),(85, 15),(85, 16);

SELECT 'Data for semester 2022-2023-2 (ID=5) has been inserted successfully.' AS status;


-- ====================================================================
--  插入 2022-2023-1 学期数据 (ID=6)
-- ====================================================================

USE `CourseSchedule`;
SET NAMES 'utf8mb4' COLLATE 'utf8mb4_unicode_ci';

-- --- 步骤 1: 插入学期信息 (我们知道它将生成 ID=6) ---
INSERT INTO `semesters` (`name`, `start_date`, `total_weeks`) VALUES
('2022-2023-1', '2022-08-29', 19); -- 假设2022年秋季学期开始日期

-- --- 步骤 2: 插入课程静态信息 (直接指定 semester_id = 6) ---
INSERT INTO `courses` (`semester_id`, `name`, `teacher`, `color`) VALUES
(6, '高等数学(一)', '郭挺', '#FFCDD2'),
(6, '大学英语(一)', '卢欣欣', '#C5CAE9'),
(6, 'C/C++程序设计', '陈勋俊', '#BBDEFB'),
(6, '思想道德与法治', '蒋越', '#D1C4E9'),
(6, '体育(一)', '曾文', '#B2EBF2'),
(6, '大学生心理健康教育', '申黎', '#B3E5FC'),
(6, '红色文化', '申黎', '#B2DFDB'),
(6, '军事理论', '朱元峰', '#DCE775'),
(6, '计算机科学导论', '吴剑青', '#FFE082'),
(6, '新生导论与职业规划', '张小红,郑剑,李伟,王俊岭,巫光福,王振东,于祥春,吴剑青', '#FFCC80'),
(6, '安全教育', '王吉源', '#FFAB91');

-- --- 步骤 3: 插入课程安排 (Schedules) ---
-- ID将从86开始自增
INSERT INTO `schedules` (`course_id`, `location`, `day_of_week`, `start_period`, `end_period`) VALUES
-- 1-2节
((SELECT id FROM courses WHERE name='高等数学(一)' AND semester_id=6), '阅道207', 1, 1, 2), -- ID: 86
((SELECT id FROM courses WHERE name='高等数学(一)' AND semester_id=6), '阅道207', 2, 1, 2), -- ID: 87
((SELECT id FROM courses WHERE name='大学英语(一)' AND semester_id=6), '阅道207', 3, 1, 2), -- ID: 88
((SELECT id FROM courses WHERE name='高等数学(一)' AND semester_id=6), '阅道207', 4, 1, 2), -- ID: 89
((SELECT id FROM courses WHERE name='C/C++程序设计' AND semester_id=6), '阅道129', 5, 1, 2), -- ID: 90
-- 3-4节
((SELECT id FROM courses WHERE name='思想道德与法治' AND semester_id=6), '文山221', 1, 3, 4), -- ID: 91
((SELECT id FROM courses WHERE name='体育(一)' AND semester_id=6), '羽毛球馆(三江东园)', 2, 3, 4), -- ID: 92
((SELECT id FROM courses WHERE name='思想道德与法治' AND semester_id=6), '文山221', 3, 3, 4), -- ID: 93
((SELECT id FROM courses WHERE name='大学生心理健康教育' AND semester_id=6), '阅道208', 4, 3, 4), -- ID: 94
-- 5-6节
((SELECT id FROM courses WHERE name='红色文化' AND semester_id=6), '文山316', 1, 5, 6), -- ID: 95
((SELECT id FROM courses WHERE name='C/C++程序设计' AND semester_id=6), '阅道128', 1, 5, 6), -- ID: 96
((SELECT id FROM courses WHERE name='C/C++程序设计' AND semester_id=6), '阅道309', 3, 5, 6), -- ID: 97
((SELECT id FROM courses WHERE name='军事理论' AND semester_id=6), '文山512', 4, 5, 6), -- ID: 98
((SELECT id FROM courses WHERE name='计算机科学导论' AND semester_id=6), '阅道129', 5, 5, 6), -- ID: 99
-- 7-8节
((SELECT id FROM courses WHERE name='新生导论与职业规划' AND semester_id=6), '阅道104', 1, 7, 8), -- ID: 100
((SELECT id FROM courses WHERE name='思想道德与法治' AND semester_id=6), '文山221', 5, 7, 8), -- ID: 101
-- 9-10节
((SELECT id FROM courses WHERE name='安全教育' AND semester_id=6), '文山115', 1, 9, 10); -- ID: 102

-- --- 步骤 4: 插入周数 (Schedule_Weeks) ---
INSERT INTO `schedule_weeks` (`schedule_id`, `week_number`) VALUES
(86, 2),(86, 3),(86, 4),(86, 5),(86, 9),(86, 10),(86, 11),(86, 12),(86, 13),(86, 14),(86, 15),(86, 16),
(87, 2),(87, 3),(87, 4),(87, 5),(87, 9),(87, 10),(87, 11),(87, 12),(87, 13),(87, 14),(87, 15),(87, 16),
(88, 2),(88, 3),(88, 4),(88, 5),(88, 9),(88, 10),(88, 11),(88, 12),(88, 13),(88, 14),(88, 15),(88, 16),(88, 17),
(89, 2),(89, 3),(89, 4),(89, 5),(89, 9),(89, 10),(89, 11),(89, 12),(89, 13),(89, 14),(89, 15),(89, 16),
(90, 2),(90, 3),(90, 4),(90, 5),(90, 9),(90, 10),(90, 11),(90, 12),(90, 13),(90, 14),(90, 15),(90, 16),(90, 17),
(91, 11),(91, 12),(91, 13),(91, 14),(91, 15),(91, 16),(91, 17),
(92, 2),(92, 3),(92, 4),(92, 5),(92, 9),(92, 10),(92, 11),(92, 12),(92, 13),(92, 14),(92, 15),(92, 16),(92, 17),
(93, 10),(93, 11),(93, 12),(93, 13),(93, 14),(93, 15),(93, 16),(93, 17),
(94, 10),(94, 11),(94, 12),(94, 13),(94, 14),(94, 15),(94, 16),(94, 17),
(95, 2),(95, 3),(95, 4),(95, 5),(95, 9),
(96, 14),(96, 15),
(97, 2),(97, 3),(97, 4),(97, 5),(97, 9),(97, 10),(97, 11),(97, 12),(97, 13),(97, 14),(97, 15),(97, 16),(97, 17),
(98, 2),(98, 3),(98, 4),(98, 5),(98, 9),(98, 10),(98, 11),(98, 12),(98, 13),(98, 14),(98, 15),(98, 16),
(99, 2),(99, 3),(99, 4),(99, 5),(99, 9),(99, 10),(99, 11),(99, 12),
(100, 2),(100, 3),(100, 4),(100, 5),(100, 9),(100, 10),(100, 11),(100, 12),(100, 13),(100, 14),(100, 15),(100, 16),
(101, 9),
(102, 11),(102, 12),(102, 13),(102, 14);

SELECT 'Data for semester 2022-2023-1 (ID=6) has been inserted successfully. All data initialization is complete!' AS status;