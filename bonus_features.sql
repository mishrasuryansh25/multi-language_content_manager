-- Get pending translation suggestions
SELECT 
    ts.suggestion_id,
    ci.content_id,
    cv.title AS original_title,
    l_original.lang_code AS original_language,
    ts.suggested_title,
    l_suggested.lang_name AS suggested_language,
    u.username AS suggested_by,
    ts.created_at
FROM 
    translations_suggestions ts
JOIN 
    content_items ci ON ts.content_id = ci.content_id
JOIN 
    content_versions cv ON ts.version_id = cv.version_id
JOIN 
    languages l_original ON cv.lang_id = l_original.lang_id
JOIN 
    languages l_suggested ON ts.suggested_lang_id = l_suggested.lang_id
JOIN 
    users u ON ts.suggested_by = u.user_id
WHERE 
    ts.suggestion_status = 'pending'
ORDER BY 
    ts.created_at DESC;

-- Approve a translation suggestion and create a new version
START TRANSACTION;

-- First, mark existing version in this language as not current (if exists)
UPDATE content_versions
SET is_current = FALSE
WHERE content_id = (SELECT content_id FROM translations_suggestions WHERE suggestion_id = 1)
AND lang_id = (SELECT suggested_lang_id FROM translations_suggestions WHERE suggestion_id = 1);

-- Then create new version from approved suggestion
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
SELECT 
    ts.content_id,
    COALESCE(
        (SELECT MAX(version_number) 
        FROM content_versions 
        WHERE content_id = ts.content_id 
        AND lang_id = ts.suggested_lang_id
    ), 0) + 1,
    ts.suggested_title,
    ts.suggested_content,
    ts.suggested_lang_id,
    ts.suggested_by,
    TRUE,
    'Approved translation suggestion'
FROM 
    translations_suggestions ts
WHERE 
    ts.suggestion_id = 1;

-- Update suggestion status
UPDATE translations_suggestions
SET 
    suggestion_status = 'approved',
    reviewed_at = CURRENT_TIMESTAMP,
    reviewed_by = 1  -- Assuming admin is approving
WHERE 
    suggestion_id = 1;

COMMIT;



-- Recursive query to get category hierarchy
WITH RECURSIVE category_hierarchy AS (
    -- Base case: select root categories
    SELECT 
        c.category_id,
        ct.translated_name AS category_name,
        c.parent_category_id,
        1 AS level
    FROM 
        categories c
    JOIN 
        category_translations ct ON c.category_id = ct.category_id AND ct.lang_id = 1
    WHERE 
        c.parent_category_id IS NULL
    
    UNION ALL
    
    -- Recursive case: select child categories
    SELECT 
        c.category_id,
        ct.translated_name AS category_name,
        c.parent_category_id,
        ch.level + 1
    FROM 
        categories c
    JOIN 
        category_translations ct ON c.category_id = ct.category_id AND ct.lang_id = 1
    JOIN 
        category_hierarchy ch ON c.parent_category_id = ch.category_id
)
SELECT 
    CONCAT(REPEAT('    ', level - 1), category_name) AS hierarchical_name,
    category_id,
    parent_category_id,
    level
FROM 
    category_hierarchy
ORDER BY 
    COALESCE(parent_category_id, 0), category_id;

    
    
-- Soft delete a content item
UPDATE content_items
SET is_deleted = TRUE,
    updated_at = CURRENT_TIMESTAMP
WHERE content_id = 5;

-- Query to exclude soft-deleted items (should be used in most queries)
SELECT 
    ci.content_id,
    cv.title,
    l.lang_code,
    cs.status_name
FROM 
    content_items ci
JOIN 
    content_versions cv ON ci.content_id = cv.content_id AND cv.is_current = TRUE
JOIN 
    languages l ON cv.lang_id = l.lang_id
JOIN 
    content_statuses cs ON ci.status_id = cs.status_id
WHERE 
    ci.is_deleted = FALSE
ORDER BY 
    ci.updated_at DESC;

-- Procedure to restore soft-deleted items
DELIMITER //
CREATE PROCEDURE restore_content(IN p_content_id INT)
BEGIN
    UPDATE content_items
    SET is_deleted = FALSE,
        updated_at = CURRENT_TIMESTAMP
    WHERE content_id = p_content_id;
    
    SELECT CONCAT('Content item ', p_content_id, ' has been restored.') AS message;
END//
DELIMITER ;

-- Usage
CALL restore_content(5);