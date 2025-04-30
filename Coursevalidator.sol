 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CourseValidator {
    struct Module {
        uint progress; // progress in percentage (0–100)
    }

    struct Course {
        uint id;
        address learner;
        bool completed;
        Module[] modules;
    }

    mapping(uint => Course) public courses;
    mapping(uint => bool) public certificateIssued;

    event CourseCompleted(uint courseId, address learner);

    /// @notice Add a new course with a number of modules
    function addCourse(uint courseId, address learner, uint moduleCount) public {
        require(courses[courseId].id == 0, "Course already exists");
        Course storage course = courses[courseId];
        course.id = courseId;
        course.learner = learner;

        for (uint i = 0; i < moduleCount; i++) {
            course.modules.push(Module(0));
        }
    }

    /// @notice Update a module's progress
    function updateProgress(uint courseId, uint moduleIndex, uint newProgress) public {
        Course storage course = courses[courseId];
        require(course.id != 0, "Course not found");
        require(moduleIndex < course.modules.length, "Invalid module index");
        require(newProgress <= 100, "Progress can't exceed 100");
        course.modules[moduleIndex].progress = newProgress;

        validateCourseCompletion(courseId);
    }

    /// @notice Check if all modules are complete and issue certificate
    function validateCourseCompletion(uint courseId) internal {
        Course storage course = courses[courseId];
        if (course.completed) return;

        for (uint i = 0; i < course.modules.length; i++) {
            if (course.modules[i].progress < 100) {
                return;
            }
        }

        // All modules are 100% → mark course complete
        course.completed = true;

        // ✅ Certificate issuance logic
        certificateIssued[courseId] = true;

        // 🔔 Emit event
        emit CourseCompleted(courseId, course.learner);
    }
}
