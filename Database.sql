ALTER TABLE `data` DROP FOREIGN KEY `fk_data_message_1`;
ALTER TABLE `message` DROP FOREIGN KEY `fk_message_userInfo_1`;
ALTER TABLE `message` DROP FOREIGN KEY `fk_message_topic_1`;
ALTER TABLE `topic` DROP FOREIGN KEY `fk_topic_subTopic_1`;
ALTER TABLE `subTopic` DROP FOREIGN KEY `fk_subTopic_subGroup_1`;
ALTER TABLE `subGroup` DROP FOREIGN KEY `fk_subGroup_Group_1`;
ALTER TABLE `userInfo` DROP FOREIGN KEY `fk_userInfo_Role_1`;
ALTER TABLE `userInfo` DROP FOREIGN KEY `fk_userInfo_Group_1`;

DROP TABLE `userInfo`;
DROP TABLE `Group`;
DROP TABLE `Role`;
DROP TABLE `subGroup`;
DROP TABLE `message`;
DROP TABLE `data`;
DROP TABLE `subTopic`;
DROP TABLE `topic`;

CREATE TABLE `userInfo` (
`userid` int(11) NOT NULL AUTO_INCREMENT,
`username` varchar(255) NOT NULL,
`password` varchar(255) NOT NULL,
`telephone` varchar(255) NULL,
`email` varchar(255) NOT NULL,
`roleid` int(11) NULL,
`groupid` int(11) NULL,
`usertype` int(255) NULL,
`status` int(255) NULL,
`secure` int(255) NULL,
PRIMARY KEY (`userid`) 
);
CREATE TABLE `Group` (
`groupid` int(11) NOT NULL AUTO_INCREMENT,
`groupname` varchar(255) NULL,
PRIMARY KEY (`groupid`) 
);
CREATE TABLE `Role` (
`roleid` int(11) NOT NULL AUTO_INCREMENT,
`rolename` varchar(255) NULL,
`groupid` int(11) NULL,
PRIMARY KEY (`roleid`) 
);
CREATE TABLE `subGroup` (
`subgroupid` int(11) NOT NULL AUTO_INCREMENT,
`subgroupname` varchar(255) NULL,
`groupid` int(11) NULL,
PRIMARY KEY (`subgroupid`) 
);
CREATE TABLE `message` (
`messageid` int(11) NOT NULL AUTO_INCREMENT,
`messagename` varchar(255) NULL,
`userid` int(11) NULL,
`otheruserid` int(11) NULL,
`uploadtime` datetime NULL,
`topicid` int(11) NULL,
PRIMARY KEY (`messageid`) 
);
CREATE TABLE `data` (
`dataid` int(11) NOT NULL AUTO_INCREMENT,
`datatype` varchar(255) NULL,
`dataname` varchar(255) NULL,
`dataurl` varchar(255) NULL,
`messageid` int(11) NULL,
`uploadtime` datetime NULL,
PRIMARY KEY (`dataid`) 
);
CREATE TABLE `subTopic` (
`subtopicid` int(11) NOT NULL,
`subtopicname` varchar(255) NULL,
`subgroupid` int(11) NULL,
PRIMARY KEY (`subtopicid`) 
);
CREATE TABLE `topic` (
`topicid` int(11) NOT NULL,
`topicname` varchar(255) NULL,
`subtopicid` int(11) NULL,
PRIMARY KEY (`topicid`) 
);

ALTER TABLE `data` ADD CONSTRAINT `fk_data_message_1` FOREIGN KEY (`messageid`) REFERENCES `message` (`messageid`);
ALTER TABLE `message` ADD CONSTRAINT `fk_message_userInfo_1` FOREIGN KEY (`userid`) REFERENCES `userInfo` (`userid`);
ALTER TABLE `message` ADD CONSTRAINT `fk_message_topic_1` FOREIGN KEY (`topicid`) REFERENCES `topic` (`topicid`);
ALTER TABLE `topic` ADD CONSTRAINT `fk_topic_subTopic_1` FOREIGN KEY (`subtopicid`) REFERENCES `subTopic` (`subtopicid`);
ALTER TABLE `subTopic` ADD CONSTRAINT `fk_subTopic_subGroup_1` FOREIGN KEY (`subgroupid`) REFERENCES `subGroup` (`subgroupid`);
ALTER TABLE `subGroup` ADD CONSTRAINT `fk_subGroup_Group_1` FOREIGN KEY (`groupid`) REFERENCES `Group` (`groupid`);
ALTER TABLE `userInfo` ADD CONSTRAINT `fk_userInfo_Role_1` FOREIGN KEY (`roleid`) REFERENCES `Role` (`roleid`);
ALTER TABLE `userInfo` ADD CONSTRAINT `fk_userInfo_Group_1` FOREIGN KEY (`groupid`) REFERENCES `Group` (`groupid`);

