#for the services in the test dealing with one services
DROP SCHEMA IF EXISTS `type0NewsDb`;
CREATE SCHEMA `type0NewsDb` ;

#for the services in the test dealing with two services
DROP SCHEMA IF EXISTS `type1NewsDb`;
CREATE SCHEMA `type1NewsDb` ;

DROP SCHEMA IF EXISTS `type1SportsNewsDb`;
CREATE SCHEMA `type1SportsNewsDb` ;

#for the services in the test dealing with three services
DROP SCHEMA IF EXISTS `type2PoliticalNewsDb`;
CREATE SCHEMA `type2PoliticalNewsDb` ;

DROP SCHEMA IF EXISTS `type2SportsNewsDb`;
CREATE SCHEMA `type2SportsNewsDb` ;

DROP SCHEMA IF EXISTS `type2FamousNewsDb`;
CREATE SCHEMA `type2FamousNewsDb` ;

# create tables for the services in the test dealing with two services
CREATE TABLE IF NOT EXISTS `type0NewsDb`.`news` (
  `id_news` INT NOT NULL AUTO_INCREMENT,
  `news_name` VARCHAR(100) NULL,
  `description` LONGTEXT NULL,
  `type` VARCHAR(45) NULL,
  PRIMARY KEY (`id_news`));

# create tables for the services in the test dealing with two services
CREATE TABLE IF NOT EXISTS `type1NewsDb`.`news` (
  `id_news` INT NOT NULL AUTO_INCREMENT,
  `news_name` VARCHAR(100) NULL,
  `description` LONGTEXT NULL,
  `type` VARCHAR(45) NULL,
  PRIMARY KEY (`id_news`));
  
CREATE TABLE IF NOT EXISTS `type1SportsNewsDb`.`news` (
  `id_news` INT NOT NULL AUTO_INCREMENT,
  `news_name` VARCHAR(100) NULL,
  `description` LONGTEXT NULL,
  `type` VARCHAR(45) NULL,
  PRIMARY KEY (`id_news`));

# create tables for the services in the test dealing with three services
CREATE TABLE IF NOT EXISTS `type2PoliticalNewsDb`.`news` (
  `id_news` INT NOT NULL AUTO_INCREMENT,
  `news_name` VARCHAR(100) NULL,
  `description` LONGTEXT NULL,
  `type` VARCHAR(45) NULL,
  PRIMARY KEY (`id_news`));
  
CREATE TABLE IF NOT EXISTS `type2SportsNewsDb`.`news` (
  `id_news` INT NOT NULL AUTO_INCREMENT,
  `news_name` VARCHAR(100) NULL,
  `description` LONGTEXT NULL,
  `type` VARCHAR(45) NULL,
  PRIMARY KEY (`id_news`));
  
CREATE TABLE IF NOT EXISTS `type2FamousNewsDb`.`news` (
  `id_news` INT NOT NULL AUTO_INCREMENT,
  `news_name` VARCHAR(100) NULL,
  `description` LONGTEXT NULL,
  `type` VARCHAR(45) NULL,
  PRIMARY KEY (`id_news`));

# Add values to tables - for the service in the test dealing with one service
INSERT INTO `type0NewsDb`.`news` (`id_news`, `news_name`, `description`, `type`)
VALUES ('1', 'news1', 'description of news1', 'political'),
('2', 'news2', 'description of news2', 'political'),
('3', 'news3', 'description of news3', 'political'),
('4', 'news4', 'description of news4', 'political'),
('5', 'news5', 'description of news5', 'political'),
('6', 'news1', 'description of news1', 'famous'),
('7', 'news2', 'description of news2', 'famous'),
('8', 'news3', 'description of news3', 'famous'),
('9', 'news4', 'description of news4', 'famous'),
('10', 'news5', 'description of news5', 'famous'),
('11', 'news1', 'description of news1', 'sports'),
('12', 'news2', 'description of news2', 'sports'),
('13', 'news3', 'description of news3', 'sports'),
('14', 'news4', 'description of news4', 'sports'),
('15', 'news5', 'description of news5', 'sports');


# Add values to tables - for the services in the test dealing with two services
INSERT INTO `type1NewsDb`.`news` (`id_news`, `news_name`, `description`, `type`)
VALUES ('1', 'news1', 'description of news1', 'political'),
('2', 'news2', 'description of news2', 'political'),
('3', 'news3', 'description of news3', 'political'),
('4', 'news4', 'description of news4', 'political'),
('5', 'news5', 'description of news5', 'political'),
('6', 'news1', 'description of news1', 'famous'),
('7', 'news2', 'description of news2', 'famous'),
('8', 'news3', 'description of news3', 'famous'),
('9', 'news4', 'description of news4', 'famous'),
('10', 'news5', 'description of news5', 'famous');

INSERT INTO `type1SportsNewsDb`.`news` (`id_news`, `news_name`, `description`, `type`)
VALUES ('1', 'news1', 'description of news1', 'sports'),
('2', 'news2', 'description of news2', 'sports'),
('3', 'news3', 'description of news3', 'sports'),
('4', 'news4', 'description of news4', 'sports'),
('5', 'news5', 'description of news5', 'sports');

# Add values to tables - for the services in the test dealing with three services
INSERT INTO `type2PoliticalNewsDb`.`news` (`id_news`, `news_name`, `description`, `type`)
VALUES ('1', 'news1', 'description of news1', 'political'),
('2', 'news2', 'description of news2', 'political'),
('3', 'news3', 'description of news3', 'political'),
('4', 'news4', 'description of news4', 'political'),
('5', 'news5', 'description of news5', 'political');

INSERT INTO `type2SportsNewsDb`.`news` (`id_news`, `news_name`, `description`, `type`)
VALUES ('1', 'news1', 'description of news1', 'sports'),
('2', 'news2', 'description of news2', 'sports'),
('3', 'news3', 'description of news3', 'sports'),
('4', 'news4', 'description of news4', 'sports'),
('5', 'news5', 'description of news5', 'sports');

INSERT INTO `type2FamousNewsDb`.`news` (`id_news`, `news_name`, `description`, `type`)
VALUES ('1', 'news1', 'description of news1', 'famous'),
('2', 'news2', 'description of news2', 'famous'),
('3', 'news3', 'description of news3', 'famous'),
('4', 'news4', 'description of news4', 'famous'),
('5', 'news5', 'description of news5', 'famous');