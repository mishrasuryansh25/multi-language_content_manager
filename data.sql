-- Insert supported languages
INSERT INTO languages (lang_code, lang_name) VALUES
('en', 'English'),
('es', 'Spanish'),
('fr', 'French'),
('de', 'German'),
('ja', 'Japanese');

-- Insert content statuses
INSERT INTO content_statuses (status_name, description) VALUES
('draft', 'Content is being worked on and not visible to public'),
('review', 'Content is ready for editorial review'),
('published', 'Content is live and visible to audience'),
('archived', 'Content is no longer active but preserved');

-- Insert users
INSERT INTO users (username, email, first_name, l_name) VALUES
('admin', 'admin@example.com', 'System', 'Administrator'),
('jdoe', 'john.doe@example.com', 'John', 'Doe'),
('msmith', 'mary.smith@example.com', 'Mary', 'Smith'),
('ljohnson', 'luke.johnson@example.com', 'Luke', 'Johnson');

-- Insert categories (hierarchical)
INSERT INTO categories (parent_category_id, created_by) VALUES
(NULL, 1), -- No parent (root category)
(NULL, 1),
(1, 2),    -- Child of category 1
(1, 2),    -- Child of category 1
(2, 3);    -- Child of category 2

-- Insert category translations
INSERT INTO category_translations (category_id, lang_id, translated_name, translated_description) VALUES
-- English translations
(1, 1, 'Technology', 'All about technology and innovation'),
(2, 1, 'Science', 'Scientific discoveries and research'),
(3, 1, 'Programming', 'Software development topics'),
(4, 1, 'Hardware', 'Computer hardware discussions'),
(5, 1, 'Biology', 'Life sciences and organisms'),
-- Spanish translations
(1, 2, 'Tecnología', 'Todo sobre tecnología e innovación'),
(2, 2, 'Ciencia', 'Descubrimientos e investigaciones científicas'),
(3, 2, 'Programación', 'Temas de desarrollo de software'),
(4, 2, 'Hardware', 'Discusiones sobre hardware de computadora'),
(5, 2, 'Biología', 'Ciencias de la vida y organismos');

-- Insert content items
INSERT INTO content_items (original_language_id, created_by, status_id) VALUES
(1, 2, 3),  -- Published English article
(1, 3, 1),  -- Draft English article
(2, 4, 3),  -- Published Spanish article
(3, 2, 2),  -- In-review French article
(1, 3, 4);  -- Archived English article

-- Insert content versions
INSERT INTO content_versions (content_id, version_number, title, content, lang_id, updated_by, is_current, change_description) VALUES
-- Content 1 (English original)
(1, 1, 'Introduction to AI', 'Artificial Intelligence is transforming industries...', 1, 2, TRUE, 'Initial version'),
(1, 2, 'Introduction to Artificial Intelligence', 'AI is transforming industries across the globe...', 1, 2, FALSE, 'Updated title and content'),
-- Content 1 (Spanish translation)
(1, 1, 'Introducción a la IA', 'La inteligencia artificial está transformando industrias...', 2, 3, TRUE, 'Initial Spanish translation'),
-- Content 2 (English draft)
(2, 1, 'Machine Learning Basics', 'Machine learning algorithms can...', 1, 3, TRUE, 'First draft'),
-- Content 3 (Spanish original)
(3, 1, 'Avances en Energía Solar', 'Los últimos avances en tecnología solar...', 2, 4, TRUE, 'Published article'),
-- Content 4 (French in-review)
(4, 1, 'Les Bases du Blockchain', 'La technologie blockchain offre...', 3, 2, TRUE, 'Initial French version'),
-- Content 5 (English archived)
(5, 1, 'Old Programming Techniques', 'In the 1990s, programming was...', 1, 3, TRUE, 'Archived content');

-- Map content to categories
INSERT INTO content_categories (content_id, category_id, assigned_by) VALUES
(1, 1, 2),  -- AI article in Technology
(1, 3, 2),  -- AI article also in Programming
(2, 3, 3),  -- ML Basics in Programming
(3, 2, 4),  -- Solar Energy in Science
(3, 5, 4),  -- Solar Energy also in Biology
(4, 1, 2),  -- Blockchain in Technology
(5, 3, 3);  -- Old Programming in Programming

-- Insert some audit logs
INSERT INTO audit_logs (action_type, table_name, record_id, user_id, old_values, new_values) VALUES
('CREATE', 'content_items', 1, 2, NULL, '{"title": "Introduction to AI", "status": "published"}'),
('UPDATE', 'content_versions', 1, 2, '{"title": "Introduction to AI"}', '{"title": "Introduction to Artificial Intelligence"}'),
('CREATE', 'content_categories', 1, 2, NULL, '{"content_id": 1, "category_id": 1}');

-- Insert translation suggestions (bonus feature)
INSERT INTO translations_suggestions (content_id, version_id, suggested_language_id, suggested_by, suggested_title, suggested_content, suggestion_status) VALUES
(1, 2, 3, 4, 'Introduction à l\'IA', 'L\'intelligence artificielle transforme les industries...', 'pending'),
(2, 1, 2, 3, 'Fundamentos de Aprendizaje Automático', 'Los algoritmos de aprendizaje automático pueden...', 'approved');