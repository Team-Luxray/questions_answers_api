-- create database
CREATE DATABASE questions_answers;

-- create raw data and processed data tables
CREATE TABLE products_csv (
  id integer GENERATED BY DEFAULT AS IDENTITY UNIQUE PRIMARY KEY,
  name text,
  slogan text,
  description text,
  category text,
  default_price money
);

CREATE TABLE products (
product_id integer GENERATED BY DEFAULT AS IDENTITY UNIQUE PRIMARY KEY,
product_name text
);

CREATE TABLE questions_csv (
  id integer GENERATED BY DEFAULT AS IDENTITY UNIQUE PRIMARY KEY,
  product_id int references products_csv(id),
  body text,
  date_written bigint,
  asker_name text,
  asker_email text,
  reported smallint,
  helpful int
);

CREATE TABLE questions (
  question_id integer GENERATED BY DEFAULT AS IDENTITY UNIQUE PRIMARY KEY,
  product_id int references products(product_id),
  question_body varchar(1000),
  question_date_written timestamp,
  asker_name varchar(50),
  asker_email varchar(62),
  question_reported smallint,
  question_helpful int
);

CREATE TABLE answers_csv (
  id integer GENERATED BY DEFAULT AS IDENTITY UNIQUE PRIMARY KEY,
  question_id int references questions_csv(id),
  body text,
  date_written bigint,
  answerer_name text,
  answerer_email text,
  reported smallint,
  helpful int
);

CREATE TABLE answers (
  answer_id integer GENERATED BY DEFAULT AS IDENTITY UNIQUE PRIMARY KEY,
  question_id int references questions(question_id),
  answer_body varchar(1000),
  answer_date_written timestamp,
  answerer_name varchar(50),
  answerer_email varchar(62),
  answer_reported smallint,
  answer_helpful int
);

CREATE TABLE photos_csv (
  id integer GENERATED BY DEFAULT AS IDENTITY UNIQUE PRIMARY KEY,
  answer_id int references answers_csv(id),
  url text
);

CREATE TABLE photos (
  photo_id integer GENERATED BY DEFAULT AS IDENTITY UNIQUE PRIMARY KEY,
  answer_id int references answers(answer_id),
  photo_url varchar(2083)
);

-- add CSV data to raw data tables
COPY products_csv(id, name, slogan, description, category, default_price)
FROM '/Users/samanthapham/Documents/hack_reactor/sdc-samantha/product.csv'
DELIMITER ','
CSV HEADER;

COPY questions_csv(id, product_id, body, date_written, asker_name, asker_email, reported, helpful)
FROM '/Users/samanthapham/Documents/hack_reactor/sdc-samantha/questions.csv'
DELIMITER ','
CSV HEADER;

COPY answers_csv(id, question_id, body, date_written, answerer_name, answerer_email, reported, helpful)
FROM '/Users/samanthapham/Documents/hack_reactor/sdc-samantha/answers.csv'
DELIMITER ','
CSV HEADER;

COPY photos_csv(id, answer_id, url)
FROM '/Users/samanthapham/Documents/hack_reactor/sdc-samantha/answers_photos.csv'
DELIMITER ','
CSV HEADER;

-- insert transformed raw data into processed data tables
INSERT INTO products (product_id, product_name)
SELECT id, name
FROM products_csv;


INSERT INTO questions (question_id, product_id, question_body, question_date_written, asker_name, asker_email, question_reported, question_helpful)
SELECT id, product_id, body, to_timestamp(date_written / 1000), asker_name, asker_email, reported, helpful
FROM questions_csv;

ALTER TABLE questions
ALTER COLUMN question_reported TYPE boolean
USING CASE WHEN question_reported = 0 THEN FALSE
WHEN question_reported = 1 THEN TRUE
ELSE NULL
END;

INSERT INTO answers (answer_id, question_id, answer_body, answer_date_written, answerer_name, answerer_email, answer_reported, answer_helpful)
SELECT id, question_id, body, to_timestamp(date_written / 1000), answerer_name, answerer_email, reported, helpful
FROM answers_csv;

ALTER TABLE answers
ALTER COLUMN answer_reported TYPE boolean
USING CASE WHEN answer_reported = 0 THEN FALSE
WHEN answer_reported = 1 THEN TRUE
ELSE NULL
END;

INSERT INTO photos (photo_id, answer_id, photo_url)
SELECT id, answer_id, url
FROM photos_csv;