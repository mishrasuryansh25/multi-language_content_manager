use multi_lang_content_db

CREATE TABLE languages (
lang_id INT auto_increment primary key,
lang_code varchar(10) not null unique,
lang_name varchar(20) not null,
is_active boolean default true,
created_at timestamp default current_timestamp,
updated_at timestamp default current_timestamp on update current_timestamp);



CREATE TABLE users (
user_id int auto_increment primary key,
username varchar(50) not null unique,
email varchar(100) not null unique,
first_name varchar(20) not null,
l_name varchar(20) not null,
is_active boolean default true,
created_at timestamp default current_timestamp,
updated_at timestamp default current_timestamp on update current_timestamp); 



CREATE TABLE content_statuses (
status_id int auto_increment primary key,
status_name varchar(50) not null unique,
description text,
created_at timestamp default current_timestamp);



CREATE TABLE categories (
category_id int auto_increment primary key,
parent_category_id int null,
created_by int not null,
created_at timestamp default current_timestamp,
updated_at timestamp default current_timestamp on update current_timestamp,
is_active boolean default true,
foreign key (parent_category_id) references categories(category_id) on delete set null,
foreign key (created_by) references users(user_id),
index idx_parent_category (parent_category_id) );



CREATE TABLE category_translations (
translation_id int auto_increment primary key,
category_id int not null,
lang_id int not null,
translated_name varchar(50) not null,
translated_description text,
created_at timestamp default current_timestamp,
updated_at timestamp default current_timestamp on update current_timestamp,
foreign key (category_id) references categories(category_id) on delete cascade,
foreign key (lang_id) references languages(lang_id),
unique key uk_category_language (category_id, lang_id) );



CREATE TABLE content_items (
content_id int auto_increment primary key,
original_lang_id int not null,
created_by int not null,
status_id int not null,
created_at timestamp default current_timestamp,
updated_at timestamp default current_timestamp on update current_timestamp,
is_deleted boolean default false comment 'Soft Delete Flag',
foreign key (original_lang_id) references languages(lang_id),
foreign key (created_by) references content_statuses(status_id),
index idx_content_status(status_id),
index idx_content_creator(created_by) );


CREATE TABLE content_versions (
    version_id INT AUTO_INCREMENT PRIMARY KEY,
    content_id INT NOT NULL,
    version_number INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    lang_id INT NOT NULL,
    updated_by INT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    change_description TEXT,
    is_current BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (content_id) REFERENCES content_items(content_id) ON DELETE CASCADE,
    FOREIGN KEY (lang_id) REFERENCES languages(lang_id),
    FOREIGN KEY (updated_by) REFERENCES users(user_id),
    UNIQUE KEY uk_content_version (content_id, version_number, lang_id),
    INDEX idx_content_language (content_id, lang_id),
    INDEX idx_current_versions (content_id, lang_id, is_current)
);


CREATE TABLE content_categories (
content_id int not null,
category_id int not null,
assigned_at timestamp default current_timestamp,
assigned_by int not null,
primary key (content_id, category_id),
foreign key (content_id) references content_items(content_id) on delete cascade,
foreign key (category_id) references categories(category_id) on delete cascade,
foreign key (assigned_by) references users(user_id) );



CREATE table audit_logs (
log_id int auto_increment primary key,
action_type varchar(50) not null,
table_name varchar(50) not null,
record_id int not null,
user_id int not null,
action_timestamp timestamp default current_timestamp,
old_values JSON,
new_values JSON,
foreign key(user_id) references users(user_id),
index idx_audit_table_record (table_name, record_id),
index idx_audit_timestamp(action_timestamp) );



CREATE TABLE translations_suggestions (
suggestion_id int auto_increment primary key,
content_id int not null,
version_id int not null,
suggested_lang_id int not null,
suggested_by int not null,
suggested_title varchar(300) not null,
suggested_content text not null,
suggestion_status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
created_at timestamp default current_timestamp,
reviewed_at timestamp null,
reviewed_by int null,
review_notes text,
foreign key (content_id) references content_items(content_id) on delete cascade,
foreign key (version_id) references content_versions(version_id) on delete cascade,
foreign key (suggested_lang_id) references languages(lang_id),
foreign key (suggested_by) references users(user_id),
foreign key (reviewed_by) references users(user_id),
index idx_suggestion_status (suggestion_status) );
