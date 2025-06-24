-- Get all content items with their current versions in all languages
SELECT 
    ci.content_id,
    l.lang_code,
    l.lang_name,
    cv.version_number,
    cv.title,
    cv.content,
    cs.status_name,
    u.username AS author,
    ci.created_at,
    ci.updated_at
FROM 
    content_items ci
JOIN 
    content_versions cv ON ci.content_id = cv.content_id AND cv.is_current = TRUE
JOIN 
    languages l ON cv.lang_id = l.lang_id
JOIN 
    content_statuses cs ON ci.status_id = cs.status_id
JOIN 
    users u ON ci.created_by = u.user_id
ORDER BY 
    ci.content_id, l.lang_code;
    
    
    
-- managing languages
SELECT 
    lang_id, 
    lang_code, 
    lang_name, 
    is_active,
    created_at,
    updated_at
FROM 
    languages
ORDER BY 
    lang_name;

-- Add a new language
INSERT INTO languages (lang_code, lang_name) 
VALUES ('it', 'Italian');

-- Deactivate a language
UPDATE languages 
SET is_active = FALSE 
WHERE lang_code = 'ja';



-- Get version history for a content item
SELECT 
    cv.version_id,
    cv.version_number,
    l.lang_code,
    cv.title,
    cv.updated_at,
    u.username AS updated_by,
    cv.change_description
FROM 
    content_versions cv
JOIN 
    languages l ON cv.lang_id = l.lang_id
JOIN 
    users u ON cv.updated_by = u.user_id
WHERE 
    cv.content_id = 1
ORDER BY 
    cv.version_number DESC, l.lang_code;

-- Create a new version of content
INSERT INTO content_versions (
    content_id, 
    version_number, 
    title, 
    content, 
    lang_id, 
    updated_by, 
    is_current,
    change_description
)
VALUES (
    1,
    3,
    'Comprehensive Guide to AI',
    'Artificial Intelligence, including machine learning and deep learning, is transforming...',
    1,
    2,
    TRUE,
    'Expanded content with more details'
);

-- Mark previous versions as not current
UPDATE content_versions
SET is_current = FALSE
WHERE content_id = 1 AND lang_id = 1 AND version_id != LAST_INSERT_ID();



-- Get all categories with translations in a specific language
SELECT 
    c.category_id,
    ct.translated_name AS category_name,
    ct.translated_description,
    parent_ct.translated_name AS parent_category,
    u.username AS created_by,
    c.created_at
FROM 
    categories c
JOIN 
    category_translations ct ON c.category_id = ct.category_id AND ct.lang_id = 1 -- English
LEFT JOIN 
    categories parent ON c.parent_category_id = parent.category_id
LEFT JOIN 
    category_translations parent_ct ON parent.category_id = parent_ct.category_id AND parent_ct.lang_id = 1
JOIN 
    users u ON c.created_by = u.user_id
ORDER BY 
    COALESCE(c.parent_category_id, 0), c.category_id;

-- Get content by category
SELECT 
    ci.content_id,
    cv.title,
    l.lang_code,
    GROUP_CONCAT(ct.translated_name SEPARATOR ', ') AS categories,
    cs.status_name,
    u.username AS author
FROM 
    content_items ci
JOIN 
    content_versions cv ON ci.content_id = cv.content_id AND cv.is_current = TRUE
JOIN 
    languages l ON cv.lang_id = l.lang_id
JOIN 
    content_statuses cs ON ci.status_id = cs.status_id
JOIN 
    users u ON ci.created_by = u.user_id
JOIN 
    content_categories cc ON ci.content_id = cc.content_id
JOIN 
    category_translations ct ON cc.category_id = ct.category_id AND ct.lang_id = 1 -- English
WHERE 
    cc.category_id = 3  -- Programming category
GROUP BY 
    ci.content_id, cv.title, l.lang_code, cs.status_name, u.username;
    
    

-- Get all active users
SELECT 
    user_id,
    username,
    email,
    first_name,
    l_name,
    created_at,
    updated_at
FROM 
    users
WHERE 
    is_active = TRUE
ORDER BY 
    l_name, first_name;

-- Get content created by a specific user
SELECT 
    ci.content_id,
    cv.title,
    l.lang_code,
    cs.status_name,
    ci.created_at,
    ci.updated_at
FROM 
    content_items ci
JOIN 
    content_versions cv ON ci.content_id = cv.content_id AND cv.is_current = TRUE
JOIN 
    languages l ON cv.lang_id = l.lang_id
JOIN 
    content_statuses cs ON ci.status_id = cs.status_id
WHERE 
    ci.created_by = 2  -- John Doe
ORDER BY 
    ci.updated_at DESC;
    
    
    
-- Get recent audit logs
DROP trigger if exists log_content_update;
SELECT 
    al.action_timestamp,
    al.action_type,
    al.table_name,
    al.record_id,
    u.username AS performed_by,
    al.old_values,
    al.new_values
FROM 
    audit_logs al
JOIN 
    users u ON al.user_id = u.user_id
ORDER BY 
    al.action_timestamp DESC
LIMIT 10;

-- Create a trigger for automatic audit logging (bonus feature)
DELIMITER //
CREATE TRIGGER log_content_update
AFTER UPDATE ON content_versions
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (
        action_type,
        table_name,
        record_id,
        user_id,
        old_values,
        new_values
    )
    VALUES (
        'UPDATE',
        'content_versions',
        NEW.version_id,
        NEW.updated_by,
        JSON_OBJECT(
            'title', OLD.title,
            'content', LEFT(OLD.content, 100),
            'language_id', OLD.lang_id
        ),
        JSON_OBJECT(
            'title', NEW.title,
            'content', LEFT(NEW.content, 100),
            'language_id', NEW.lang_id
        )
    );
END//
DELIMITER ;



-- Update content status
UPDATE content_items
SET status_id = (SELECT status_id FROM content_statuses WHERE status_name = 'published'),
    updated_at = CURRENT_TIMESTAMP
WHERE content_id = 2;

-- Get content by status
SELECT 
    ci.content_id,
    cv.title,
    l.lang_code,
    cs.status_name,
    u.username AS author,
    ci.created_at,
    ci.updated_at
FROM 
    content_items ci
JOIN 
    content_versions cv ON ci.content_id = cv.content_id AND cv.is_current = TRUE
JOIN 
    languages l ON cv.lang_id = l.lang_id
JOIN 
    content_statuses cs ON ci.status_id = cs.status_id
JOIN 
    users u ON ci.created_by = u.user_id
WHERE 
    cs.status_name = 'draft'
ORDER BY 
    ci.updated_at DESC;
    
    
-- get content in specific language
SELECT 
    ci.content_id,
    MAX(cv.title) AS title,  -- assuming you want the 'latest' title
    MAX(cv.content) AS content,
    cs.status_name,
    u.username AS author,
    ci.created_at,
    ci.updated_at
FROM 
    content_items ci
JOIN 
    content_versions cv ON ci.content_id = cv.content_id AND cv.is_current = TRUE
JOIN 
    content_statuses cs ON ci.status_id = cs.status_id
JOIN 
    users u ON ci.created_by = u.user_id
WHERE 
    cv.lang_id = (SELECT lang_id FROM languages WHERE lang_code = 'es')
GROUP BY 
    ci.content_id, cs.status_name, u.username, ci.created_at, ci.updated_at
ORDER BY 
    ci.updated_at DESC;
    
