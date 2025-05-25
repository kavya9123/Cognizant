
-- 1. User Upcoming Events
SELECT 
    u.full_name AS user_name,
    u.city AS user_city,
    e.title AS event_title,
    e.start_date,
    e.end_date
FROM Users1 u
JOIN Registrations1 r ON u.user_id = r.user_id
JOIN Events1 e ON r.event_id = e.event_id
WHERE e.status = 'upcoming' 
    AND e.city = u.city
ORDER BY e.start_date;

-- 2. Top Rated Events

SELECT 
    e.title,
    e.city,
    ROUND(AVG(f.rating), 2) AS avg_rating,
    COUNT(f.feedback_id) AS feedback_count
FROM Events1 e
JOIN Feedback1 f ON e.event_id = f.event_id
GROUP BY e.event_id, e.title, e.city
HAVING COUNT(f.feedback_id) >= 10
ORDER BY avg_rating DESC, feedback_count DESC;

-- 3. Inactive Users

SELECT 
    u.user_id,
    u.full_name,
    u.email,
    u.city,
    u.registration_date
FROM Users1 u
WHERE u.user_id NOT IN (
    SELECT DISTINCT r.user_id
    FROM Registrations1 r
    WHERE r.registration_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY)
);

-- 4. Peak Session Hours

SELECT 
    e.title AS event_title,
    e.city,
    COUNT(s.session_id) AS sessions_10am_to_12pm
FROM Events1 e
LEFT JOIN Sessions1 s ON e.event_id = s.event_id
    AND TIME(s.start_time) >= '10:00:00' 
    AND TIME(s.start_time) < '12:00:00'
GROUP BY e.event_id, e.title, e.city
ORDER BY sessions_10am_to_12pm DESC;

-- 5. Most Active Cities

SELECT 
    e.city,
    COUNT(DISTINCT r.user_id) AS distinct_user_registrations
FROM Events1 e
JOIN Registrations1 r ON e.event_id = r.event_id
GROUP BY e.city
ORDER BY distinct_user_registrations DESC
LIMIT 5;

-- 6. Event Resource Summary

SELECT 
    e.title AS event_title,
    e.city,
    SUM(CASE WHEN res.resource_type = 'pdf' THEN 1 ELSE 0 END) AS pdf_count,
    SUM(CASE WHEN res.resource_type = 'image' THEN 1 ELSE 0 END) AS image_count,
    SUM(CASE WHEN res.resource_type = 'link' THEN 1 ELSE 0 END) AS link_count,
    COUNT(res.resource_id) AS total_resources
FROM Events1 e
LEFT JOIN Resources1 res ON e.event_id = res.event_id
GROUP BY e.event_id, e.title, e.city
ORDER BY total_resources DESC;

-- 7. Low Feedback Alerts
SELECT 
    u.full_name,
    u.email,
    e.title AS event_title,
    f.rating,
    f.comments,
    f.feedback_date
FROM Users1 u
JOIN Feedback1 f ON u.user_id = f.user_id
JOIN Events1 e ON f.event_id = e.event_id
WHERE f.rating < 3
ORDER BY f.feedback_date DESC, f.rating ASC;

-- 8. Sessions per Upcoming Event
SELECT 
    e.title AS event_title,
    e.city,
    e.start_date,
    e.end_date,
    COUNT(s.session_id) AS session_count
FROM Events1 e
LEFT JOIN Sessions1 s ON e.event_id = s.event_id
WHERE e.status = 'upcoming'
GROUP BY e.event_id, e.title, e.city, e.start_date, e.end_date
ORDER BY session_count DESC, e.start_date;

-- 9. Organizer Event Summary

SELECT 
    u.full_name AS organizer_name,
    u.email AS organizer_email,
    SUM(CASE WHEN e.status = 'upcoming' THEN 1 ELSE 0 END) AS upcoming_events,
    SUM(CASE WHEN e.status = 'completed' THEN 1 ELSE 0 END) AS completed_events,
    SUM(CASE WHEN e.status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_events,
    COUNT(e.event_id) AS total_events
FROM Users1 u
JOIN Events1 e ON u.user_id = e.organizer_id
GROUP BY u.user_id, u.full_name, u.email
ORDER BY total_events DESC;

-- 10. Feedback Gap
SELECT 
    e.title AS event_title,
    e.city,
    e.status,
    e.start_date,
    COUNT(r.registration_id) AS registration_count
FROM Events1 e
JOIN Registrations1 r ON e.event_id = r.event_id
LEFT JOIN Feedback1 f ON e.event_id = f.event_id
WHERE f.feedback_id IS NULL
GROUP BY e.event_id, e.title, e.city, e.status, e.start_date
ORDER BY registration_count DESC;

-- 11. Daily New User Count

SELECT 
    registration_date,
    COUNT(user_id) AS new_users_count
FROM Users1
WHERE registration_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
GROUP BY registration_date
ORDER BY registration_date DESC;

-- 12. Event with Maximum Sessions

SELECT
    E.title AS event_title,
    COUNT(S.session_id) AS number_of_sessions
FROM Events AS E
JOIN Sessions1 AS S ON E.event_id = S.event_id
GROUP BY E.title
ORDER BY number_of_sessions DESC
LIMIT 1;
-- 13. Average Rating per City
SELECT 
    e.city,
    ROUND(AVG(f.rating), 2) AS avg_rating,
    COUNT(f.feedback_id) AS total_feedback_entries
FROM Events1 e
JOIN Feedback1 f ON e.event_id = f.event_id
GROUP BY e.city
ORDER BY avg_rating DESC;

-- 14. Most Registered Events

SELECT 
    e.title AS event_title,
    e.city,
    e.status,
    e.start_date,
    COUNT(r.registration_id) AS registration_count
FROM Events1 e
JOIN Registrations1 r ON e.event_id = r.event_id
GROUP BY e.event_id, e.title, e.city, e.status, e.start_date
ORDER BY registration_count DESC
LIMIT 3;

-- 15. Event Session Time Conflict

SELECT 
    e.title AS event_title,
    s1.title AS session1_title,
    s1.speaker_name AS session1_speaker,
    s1.start_time AS session1_start,
    s1.end_time AS session1_end,
    s2.title AS session2_title,
    s2.speaker_name AS session2_speaker,
    s2.start_time AS session2_start,
    s2.end_time AS session2_end
FROM Events1 e
JOIN Sessions1 s1 ON e.event_id = s1.event_id
JOIN Sessions1 s2 ON e.event_id = s2.event_id
WHERE s1.session_id < s2.session_id
    AND s1.start_time < s2.end_time
    AND s2.start_time < s1.end_time
ORDER BY e.title, s1.start_time;

-- 16. Unregistered Active Users

SELECT 
    u.user_id,
    u.full_name,
    u.email,
    u.city,
    u.registration_date,
    DATEDIFF(CURDATE(), u.registration_date) AS days_since_registration
FROM Users1 u
LEFT JOIN Registrations1 r ON u.user_id = r.user_id
WHERE u.registration_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY)
    AND r.user_id IS NULL
ORDER BY u.registration_date DESC;

-- 17. Multi-Session Speakers

SELECT 
    s.speaker_name,
    COUNT(s.session_id) AS total_sessions,
    COUNT(DISTINCT s.event_id) AS events_spoken_at,
    GROUP_CONCAT(DISTINCT e.title ORDER BY e.title SEPARATOR ', ') AS events_list
FROM Sessions1 s
JOIN Events1 e ON s.event_id = e.event_id
GROUP BY s.speaker_name
HAVING COUNT(s.session_id) > 1
ORDER BY total_sessions DESC, events_spoken_at DESC;

-- 18. Resource Availability Check

SELECT 
    e.title AS event_title,
    e.city,
    e.status,
    e.start_date,
    e.end_date
FROM Events1 e
LEFT JOIN Resources1 res ON e.event_id = res.event_id
WHERE res.resource_id IS NULL
ORDER BY e.start_date;

-- 19. Completed Events with Feedback Summary

SELECT 
    e.title AS event_title,
    e.city,
    e.start_date,
    COUNT(DISTINCT r.registration_id) AS total_registrations,
    ROUND(AVG(f.rating), 2) AS avg_rating,
    COUNT(f.feedback_id) AS feedback_count,
    ROUND((COUNT(f.feedback_id) * 100.0 / COUNT(DISTINCT r.registration_id)), 2) AS feedback_response_rate_percent
FROM Events1 e
LEFT JOIN Registrations1 r ON e.event_id = r.event_id
LEFT JOIN Feedback1 f ON e.event_id = f.event_id
WHERE e.status = 'completed'
GROUP BY e.event_id, e.title, e.city, e.start_date
HAVING COUNT(DISTINCT r.registration_id) > 0
ORDER BY avg_rating DESC;

-- 20. User Engagement Index

SELECT 
    u.full_name,
    u.email,
    u.city,
    COUNT(DISTINCT r.event_id) AS events_registered,
    COUNT(DISTINCT f.event_id) AS events_feedback_given,
    CASE 
        WHEN COUNT(DISTINCT r.event_id) > 0 
        THEN ROUND((COUNT(DISTINCT f.event_id) * 100.0 / COUNT(DISTINCT r.event_id)), 2)
        ELSE 0 
    END AS engagement_percentage
FROM Users1 u
LEFT JOIN Registrations1 r ON u.user_id = r.user_id
LEFT JOIN Feedback1 f ON u.user_id = f.user_id
GROUP BY u.user_id, u.full_name, u.email, u.city
ORDER BY engagement_percentage DESC, events_registered DESC;

-- 21. Top Feedback Providers

SELECT 
    u.full_name,
    u.email,
    u.city,
    COUNT(f.feedback_id) AS feedback_entries_count,
    ROUND(AVG(f.rating), 2) AS avg_rating_given
FROM Users1 u
JOIN Feedback1 f ON u.user_id = f.user_id
GROUP BY u.user_id, u.full_name, u.email, u.city
ORDER BY feedback_entries_count DESC, avg_rating_given DESC
LIMIT 5;

-- 22. Duplicate Registrations Check

SELECT 
    u.full_name,
    u.email,
    e.title AS event_title,
    e.city,
    COUNT(r.registration_id) AS duplicate_registrations,
    GROUP_CONCAT(r.registration_date ORDER BY r.registration_date SEPARATOR ', ') AS registration_dates
FROM Users1 u
JOIN Registrations1 r ON u.user_id = r.user_id
JOIN Events1 e ON r.event_id = e.event_id
GROUP BY u.user_id, e.event_id, u.full_name, u.email, e.title, e.city
HAVING COUNT(r.registration_id) > 1
ORDER BY duplicate_registrations DESC;

-- 23. Registration Trends
SELECT 
    DATE_FORMAT(r.registration_date, '%Y-%m') AS month_year,
    MONTHNAME(r.registration_date) AS month_name,
    YEAR(r.registration_date) AS year,
    COUNT(r.registration_id) AS registration_count
FROM Registrations1 r
WHERE r.registration_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY DATE_FORMAT(r.registration_date, '%Y-%m'), MONTHNAME(r.registration_date), YEAR(r.registration_date)
ORDER BY month_year DESC;

-- 24. Average Session Duration per Event

SELECT 
    e.title AS event_title,
    e.city,
    COUNT(s.session_id) AS total_sessions,
    ROUND(AVG(TIMESTAMPDIFF(MINUTE, s.start_time, s.end_time)), 2) AS avg_session_duration_minutes,
    MIN(TIMESTAMPDIFF(MINUTE, s.start_time, s.end_time)) AS shortest_session_minutes,
    MAX(TIMESTAMPDIFF(MINUTE, s.start_time, s.end_time)) AS longest_session_minutes
FROM Events1 e
JOIN Sessions1 s ON e.event_id = s.event_id
GROUP BY e.event_id, e.title, e.city
ORDER BY avg_session_duration_minutes DESC;

-- 25. Events Without Sessions

SELECT 
    e.title AS event_title,
    e.city,
    e.status,
    e.start_date,
    e.end_date,
    u.full_name AS organizer_name
FROM Events1 e
JOIN Users1 u ON e.organizer_id = u.user_id
LEFT JOIN Sessions1 s ON e.event_id = s.event_id
WHERE s.session_id IS NULL
ORDER BY e.start_date, e.title;


-- 26. Event Popularity Score

SELECT 
    e.title AS event_title,
    e.city,
    e.status,
    COUNT(DISTINCT r.user_id) AS unique_registrations,
    COUNT(f.feedback_id) AS feedback_count,
    COALESCE(ROUND(AVG(f.rating), 2), 0) AS avg_rating,
    (COUNT(DISTINCT r.user_id) * 0.4 + 
     COUNT(f.feedback_id) * 0.3 + 
     COALESCE(AVG(f.rating), 0) * 0.3) AS popularity_score
FROM Events1 e
LEFT JOIN Registrations1 r ON e.event_id = r.event_id
LEFT JOIN Feedback1 f ON e.event_id = f.event_id
GROUP BY e.event_id, e.title, e.city, e.status
ORDER BY popularity_score DESC;

-- 27. User Activity Timeline

SELECT 
    u.full_name,
    'Registration' AS activity_type,
    e.title AS event_title,
    r.registration_date AS activity_date,
    NULL AS rating
FROM Users1 u
JOIN Registrations1 r ON u.user_id = r.user_id
JOIN Events1 e ON r.event_id = e.event_id
UNION ALL
SELECT 
    u.full_name,
    'Feedback' AS activity_type,
    e.title AS event_title,
    f.feedback_date AS activity_date,
    f.rating
FROM Users1 u
JOIN Feedback1 f ON u.user_id = f.user_id
JOIN Events1 e ON f.event_id = e.event_id
ORDER BY full_name, activity_date DESC;

-- 28. Event Performance Dashboard

SELECT 
    e.title AS event_title,
    e.city,
    e.status,
    e.start_date,
    COUNT(DISTINCT r.user_id) AS total_registrations,
    COUNT(DISTINCT s.session_id) AS total_sessions,
    COUNT(DISTINCT res.resource_id) AS total_resources,
    COUNT(f.feedback_id) AS feedback_received,
    COALESCE(ROUND(AVG(f.rating), 2), 0) AS avg_rating,
    CASE 
        WHEN COUNT(DISTINCT r.user_id) > 0 
        THEN ROUND((COUNT(f.feedback_id) * 100.0 / COUNT(DISTINCT r.user_id)), 2)
        ELSE 0 
    END AS feedback_response_rate
FROM Events1 e
LEFT JOIN Registrations1 r ON e.event_id = r.event_id
LEFT JOIN Sessions1 s ON e.event_id = s.event_id
LEFT JOIN Resources1 res ON e.event_id = res.event_id
LEFT JOIN Feedback1 f ON e.event_id = f.event_id
GROUP BY e.event_id, e.title, e.city, e.status, e.start_date
ORDER BY e.start_date DESC;