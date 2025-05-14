-- Create the database
CREATE DATABASE IF NOT EXISTS attendance_db;
USE attendance_db;

-- Create Students table
CREATE TABLE IF NOT EXISTS students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    enrollment_date DATE DEFAULT CURRENT_DATE
);

-- Create Classes table
CREATE TABLE IF NOT EXISTS classes (
    class_id INT PRIMARY KEY AUTO_INCREMENT,
    class_name VARCHAR(100) NOT NULL,
    instructor VARCHAR(100),
    schedule VARCHAR(100),
    room_number VARCHAR(20)
);

-- Create Attendance table
CREATE TABLE IF NOT EXISTS attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    class_id INT,
    date DATE DEFAULT CURRENT_DATE,
    status ENUM('Present', 'Absent', 'Late') NOT NULL,
    notes TEXT,
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (class_id) REFERENCES classes(class_id)
);

-- Insert sample data for Students
INSERT INTO students (first_name, last_name, email) VALUES
('John', 'Doe', 'john.doe@email.com'),
('Jane', 'Smith', 'jane.smith@email.com'),
('Mike', 'Johnson', 'mike.johnson@email.com'),
('Sarah', 'Williams', 'sarah.williams@email.com');

-- Insert sample data for Classes
INSERT INTO classes (class_name, instructor, schedule, room_number) VALUES
('Mathematics 101', 'Dr. Brown', 'Monday 9:00 AM', 'Room 101'),
('Physics 101', 'Prof. Davis', 'Tuesday 10:30 AM', 'Room 202'),
('Computer Science 101', 'Dr. Wilson', 'Wednesday 2:00 PM', 'Room 303');

-- Insert sample attendance records
INSERT INTO attendance (student_id, class_id, date, status, notes) VALUES
(1, 1, CURRENT_DATE, 'Present', 'On time'),
(2, 1, CURRENT_DATE, 'Late', 'Arrived 10 minutes late'),
(3, 1, CURRENT_DATE, 'Present', 'On time'),
(4, 1, CURRENT_DATE, 'Absent', 'No excuse provided');

-- Create a view for attendance summary
CREATE VIEW attendance_summary AS
SELECT 
    s.student_id,
    s.first_name,
    s.last_name,
    c.class_name,
    COUNT(CASE WHEN a.status = 'Present' THEN 1 END) as present_count,
    COUNT(CASE WHEN a.status = 'Absent' THEN 1 END) as absent_count,
    COUNT(CASE WHEN a.status = 'Late' THEN 1 END) as late_count
FROM students s
CROSS JOIN classes c
LEFT JOIN attendance a ON s.student_id = a.student_id AND c.class_id = a.class_id
GROUP BY s.student_id, s.first_name, s.last_name, c.class_name;

-- Create stored procedure for marking attendance
DELIMITER //
CREATE PROCEDURE mark_attendance(
    IN p_student_id INT,
    IN p_class_id INT,
    IN p_status VARCHAR(10),
    IN p_notes TEXT
)
BEGIN
    INSERT INTO attendance (student_id, class_id, status, notes)
    VALUES (p_student_id, p_class_id, p_status, p_notes);
END //
DELIMITER ;

-- Create stored procedure for getting student attendance report
DELIMITER //
CREATE PROCEDURE get_student_attendance_report(
    IN p_student_id INT,
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    SELECT 
        s.first_name,
        s.last_name,
        c.class_name,
        a.date,
        a.status,
        a.notes
    FROM students s
    JOIN attendance a ON s.student_id = a.student_id
    JOIN classes c ON a.class_id = c.class_id
    WHERE s.student_id = p_student_id
    AND a.date BETWEEN p_start_date AND p_end_date
    ORDER BY a.date, c.class_name;
END //
DELIMITER ; 