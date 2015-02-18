/* DB CREATION */
create schema test5 character set utf8;

use test5;


/* CLIENT */

CREATE TABLE `client` (
  `name` varchar(255) NOT NULL,
  `min_rating` double default NULL,
  `max_rating` double default NULL,
  `user_cf_limit` int(11) default '0',
  `R_K` int(11) default NULL,
  `R_MIN_TRUST` double default NULL,
  `P_K` int(11) default NULL,
  `P_MIN_TRUST` double default NULL,
  `I_SIM_ALG` varchar(255) default NULL,
  `TRANS_ACTION_TYPE` int(11) default '0',
  `r_alg_1` varchar(255) default NULL,
  `r_alg_2` varchar(255) default NULL,
  `p_alg_1` varchar(255) default NULL,
  `p_alg_2` varchar(255) default NULL,
  sort1 varchar(255) default NULL,
  sort2 varchar(255) default NULL,
  sort3 varchar(255) default NULL,
  PRIMARY KEY  (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/* ACTIONS */

CREATE TABLE `action_type` (
  `type_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(25) DEFAULT NULL,
  `weight` double DEFAULT NULL,
  `def_value` double DEFAULT NULL,
  `link_type` int(11) DEFAULT NULL,
  `semantic` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

 CREATE TABLE `actions` (
  `action_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `item_id` bigint(20) NOT NULL,
  `type` int(11) DEFAULT NULL,
  `times` int(11) DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `value` double DEFAULT NULL,
  `client_user_id` varchar(255) DEFAULT NULL,
  `client_item_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`action_id`),
  KEY `i_index` (`item_id`),
  KEY `idx` (`user_id`,`item_id`),
  KEY `cukey` (`client_user_id`),
  KEY `cikey` (`client_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
 PARTITION BY RANGE (action_id)
(PARTITION p1 VALUES LESS THAN (10000000) ENGINE = InnoDB,
 PARTITION p2 VALUES LESS THAN (20000000) ENGINE = InnoDB,
 PARTITION p3 VALUES LESS THAN (30000000) ENGINE = InnoDB,
 PARTITION p4 VALUES LESS THAN (40000000) ENGINE = InnoDB,
 PARTITION p5 VALUES LESS THAN (50000000) ENGINE = InnoDB,
 PARTITION p6 VALUES LESS THAN (60000000) ENGINE = InnoDB,
 PARTITION p7 VALUES LESS THAN (70000000) ENGINE = InnoDB,
 PARTITION p8 VALUES LESS THAN (80000000) ENGINE = InnoDB,
 PARTITION p9 VALUES LESS THAN (90000000) ENGINE = InnoDB,
 PARTITION p10 VALUES LESS THAN MAXVALUE ENGINE = InnoDB); 

CREATE TABLE `action_comment` (
  `action_id` bigint(20) NOT NULL,
  `comment` text,
  PRIMARY KEY  (`action_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `action_tags` (
  `action_id` bigint(20) NOT NULL default '0',
  `tag_id` smallint(6) NOT NULL default '0',
  `tag` varchar(25) default NULL,
  PRIMARY KEY  (`action_id`,`tag_id`),
  KEY `a_index` (`action_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/* OPINION */

CREATE TABLE `opinions` (
  `op_id` bigint(20) NOT NULL auto_increment,
  `user_id` bigint(20) NOT NULL,
  `item_id` bigint(20) NOT NULL,
  `value` double default '0',
  `time` datetime default NULL,
  PRIMARY KEY  (`op_id`),
  KEY `u_index` (`user_id`),
  KEY `i_index` (`item_id`),
  UNIQUE KEY `idx` (`user_id`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/* ITEM */

CREATE TABLE `items` (
  `item_id` bigint(20) NOT NULL auto_increment,
  `name` varchar(255) default NULL,
  `first_op` datetime default NULL,
  `last_op` datetime default NULL,
  `popular` tinyint(1) default '0',
  `client_item_id` varchar(255) default NULL,
  `type` int(11) default '0',
  `avgrating` double default '0',
  `stddevrating` double default '0',
  `num_op` int(11) default NULL,
  PRIMARY KEY  (`item_id`),
  UNIQUE KEY `c_index` (`client_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `item_attr` (
  `attr_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(25) DEFAULT NULL,
  `type` varchar(10) DEFAULT NULL,
  `item_type` int(11) DEFAULT NULL,
  `semantic` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `item_attr_enum` (
  `attr_id` int(11) NOT NULL,
  `value_id` int(11) NOT NULL,
  `value_name` varchar(255) default NULL,
  `amount` double default NULL,
  `name` bit(1) DEFAULT b'0',
  PRIMARY KEY  (`attr_id`,`value_id`),
  KEY `a_index` (`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `item_map_enum` (
  `item_id` bigint(20) NOT NULL,
  `attr_id` int(11) NOT NULL,
  `value_id` int(11) default NULL,
  PRIMARY KEY  (`attr_id`,`item_id`),
  KEY `i_index` (`item_id`),
  KEY `a_index` (`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `item_map_int` (
  `item_id` bigint(20) NOT NULL,
  `attr_id` int(11) NOT NULL,
  `value` int(11) default NULL,
  PRIMARY KEY  (`attr_id`,`item_id`),
  index uidx (item_id,attr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `item_map_bigint` (
  `item_id` bigint(20) NOT NULL,
  `attr_id` int(11) NOT NULL,
  `value` bigint(20) default NULL,
  PRIMARY KEY  (`attr_id`,`item_id`),
  index uidx (item_id,attr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

 CREATE TABLE `item_map_double` (
  `item_id` bigint(20) NOT NULL,
  `attr_id` int(11) NOT NULL,
  `value` double default NULL,
  PRIMARY KEY  (`attr_id`,`item_id`),
  index uidx (item_id,attr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `item_map_varchar` (
  `item_id` bigint(20) NOT NULL,
  `attr_id` int(11) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `pos` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`attr_id`,`item_id`,`pos`) USING BTREE,
  index uidx (item_id,attr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `item_map_text` (
  `item_id` bigint(20) NOT NULL,
  `attr_id` int(11) NOT NULL,
  `value` text,
  PRIMARY KEY  (`attr_id`,`item_id`),
  index uidx (item_id,attr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8; 

CREATE TABLE `item_map_datetime` (
  `item_id` bigint(20) NOT NULL,
  `attr_id` int(11) NOT NULL,
  `value` datetime default NULL,
  PRIMARY KEY  (`attr_id`,`item_id`),
  index uidx (item_id,attr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `item_map_boolean` (
  `item_id` bigint(20) NOT NULL,
  `attr_id` int(11) NOT NULL,
  `value` tinyint(1) default NULL,
  PRIMARY KEY  (`attr_id`,`item_id`),
  index uidx (item_id,attr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `item_attr_int` (
  `attr_id` int(11) NOT NULL,
  `value_id` int(11) NOT NULL,
  `min` int(11) default NULL,
  `max` int(11) default NULL,
  PRIMARY KEY  (`value_id`,`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `item_attr_bigint` (
  `attr_id` int(11) NOT NULL,
  `value_id` int(11) NOT NULL,
  `min` bigint(20) default NULL,
  `max` int(11) default NULL,
  PRIMARY KEY  (`value_id`,`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `item_attr_double` (
  `attr_id` int(11) NOT NULL,
  `value_id` int(11) NOT NULL,
  `min` double default NULL,
  `max` int(11) default NULL,
  PRIMARY KEY  (`value_id`,`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `item_attr_varchar` (
  `attr_id` int(11) NOT NULL,
  `value_id` int(11) NOT NULL,
  `min` varchar(255) default NULL,
  `max` varchar(255) default NULL,
  PRIMARY KEY  (`value_id`,`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `item_attr_datetime` (
  `attr_id` int(11) NOT NULL,
  `value_id` int(11) NOT NULL,
  `min` datetime default NULL,
  `max` datetime default NULL,
  PRIMARY KEY  (`value_id`,`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

 CREATE TABLE `item_attr_boolean` (
  `attr_id` int(11) NOT NULL,
  `value_id` int(11) NOT NULL,
  `min` tinyint(1) default NULL,
  `max` tinyint(1) default NULL,
  PRIMARY KEY  (`value_id`,`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/* DIMENSION */

CREATE TABLE `dimension` (
  `dim_id` int(11) NOT NULL auto_increment,
  `item_type` int(11) default NULL,
  `attr_id` int(11) default NULL,
  `value_id` int(11) default NULL,
  `trustnetwork` tinyint(1) default '0',
  PRIMARY KEY  (`dim_id`),
  KEY `idx` (`attr_id`,`value_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/* USERS */

 CREATE TABLE `users` (
  `user_id` bigint(20) NOT NULL auto_increment,
  `username` varchar(64) default NULL,
  `first_op` datetime default NULL,
  `last_op` datetime default NULL,
  `type` int(11) default NULL,
  `num_op` int(11) default NULL,
  `active` tinyint(1) default NULL,
  `client_user_id` varchar(255) default NULL,
  `avgrating` double default '0',
  `stddevrating` double default '0',
  PRIMARY KEY  (`user_id`),
  UNIQUE KEY `c_index` (`client_user_id`),
  KEY `u_index` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_dim` (
  `user_id` bigint(20) NOT NULL,
  `dim_id` int(11) NOT NULL,
  `relevance` double default NULL,
  PRIMARY KEY  (`user_id`,`dim_id`),
  KEY `u_index` (`user_id`),
  KEY `d_index` (`dim_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


/* ALGORITHM */

CREATE TABLE `network` (
  `u1` bigint(20) NOT NULL,
  `type` int(11) NOT NULL,
  `u2` bigint(20) NOT NULL,
  `trust` double NOT NULL,
  PRIMARY KEY  (`u1`,`u2`,`type`),
  KEY `u1` (`u1`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `network_content` (
  `c1` bigint(20) NOT NULL,
  `type` int(11) NOT NULL,
  `c2` bigint(20) NOT NULL,
  `trust` double NOT NULL,
  PRIMARY KEY  (`c1`,`c2`,`type`),
  KEY `c1` (`c1`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_user_avg` (
  `m1` bigint(20) NOT NULL,
  `m2` bigint(20) NOT NULL,
  `avgm1` double default NULL,
  `avgm2` double default NULL,
  PRIMARY KEY  (`m1`,`m2`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `content_similarity` (
  `src` bigint(20) NOT NULL,
  `dst` bigint(20) NOT NULL,
  `similarity` double NOT NULL,
  PRIMARY KEY  (`src`,`dst`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


/* Hadoop */

CREATE TABLE `trustcalc_all` (
  `user` bigint(20) NOT NULL,
  `type` int(11) NOT NULL,
  `hash` varchar(255) NOT NULL,
  PRIMARY KEY (`user`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `trustcalc_delete` (
  `user` bigint(20) NOT NULL,
  `type` int(11) NOT NULL,
  PRIMARY KEY (`user`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `trustcalc_new` (
  `u1` bigint(20) NOT NULL,
  `type` int(11) NOT NULL,
  `u2` bigint(20) NOT NULL,
  `trust` double NOT NULL,
  PRIMARY KEY (`u1`,`u2`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `trustcalc_prev` (
  `user` bigint(20) NOT NULL,
  `type` int(11) NOT NULL,
  `hash` varchar(255) NOT NULL,
  PRIMARY KEY (`user`,`type`),
  KEY `ty` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `trustcalc_item_all` (
  `user` bigint(20) NOT NULL,
  `type` int(11) NOT NULL,
  `hash` varchar(255) NOT NULL,
  PRIMARY KEY (`user`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `trustcalc_item_delete` (
  `user` bigint(20) NOT NULL,
  `type` int(11) NOT NULL,
  PRIMARY KEY (`user`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `trustcalc_item_new` (
  `u1` bigint(20) NOT NULL,
  `type` int(11) NOT NULL,
  `u2` bigint(20) NOT NULL,
  `trust` double NOT NULL,
  PRIMARY KEY (`u1`,`u2`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `trustcalc_item_prev` (
  `user` bigint(20) NOT NULL,
  `type` int(11) NOT NULL,
  `hash` varchar(255) NOT NULL,
  PRIMARY KEY (`user`,`type`),
  KEY `ty` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
CREATE TABLE `opinions_new` (
  `user_id` bigint(20) NOT NULL,
  `item_id` bigint(20) NOT NULL,
  `value` double DEFAULT NULL,
  PRIMARY KEY (`user_id`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_dim_new` (
  `user_id` bigint(20) NOT NULL,
  `dim_id` int(11) NOT NULL,
  `relevance` double DEFAULT NULL,
  PRIMARY KEY (`user_id`,`dim_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `items_popular` (
  `item_id` bigint(20) NOT NULL,
  `opsum` double DEFAULT NULL,
  PRIMARY KEY (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `items_popular_new` (
  `item_id` bigint(20) NOT NULL,
  `opsum` double DEFAULT NULL,
  PRIMARY KEY (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/* EXPLICIT LINKS */
CREATE TABLE `link_type` (
  `type_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(25) DEFAULT NULL,
  `def_value` double DEFAULT NULL,
  PRIMARY KEY (`type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `links` (
  `link_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `u1` bigint(20) NOT NULL,
  `u2` bigint(20) NOT NULL,
  `value` double DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  PRIMARY KEY (`link_id`),
  UNIQUE KEY `key2` (`u1`,`u2`,`type`),
  KEY `u_index` (`u1`),
  KEY `u2_index` (`u2`),
  KEY `idx` (`u1`,`u2`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


/* Facebook fast user similarity */

CREATE TABLE `minhashuser` (
  `hash` varchar(255) NOT NULL,
  `user` bigint(20) NOT NULL,
  KEY `h` (`hash`),
  KEY `u` (`user`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `minhashseed` (
  `position` int(11) NOT NULL,
  `seed` int(11) NOT NULL,
  KEY `p` (`position`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `facebookoauthaccount` (
  `id` bigint(20) NOT NULL,
  `oauthtoken` varchar(255) character set latin1 collate latin1_bin default NULL,
  `token_active` smallint(6) default NULL,
  `fb_id` bigint(20) default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 ROW_FORMAT=COMPACT;

CREATE TABLE `item_type` (
  `type_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(25) DEFAULT NULL,
  `link_type` int(11) DEFAULT NULL,
  `semantic` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/* DEMOGRAPHICS */

CREATE TABLE `user_attr` (
  `attr_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(25) DEFAULT NULL,
  `type` varchar(10) DEFAULT NULL,
  `link_type` int(11) DEFAULT NULL,
  `demographic` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_attr_enum` (
  `attr_id` int(11) NOT NULL,
  `value_id` int(11) NOT NULL,
  `value_name` varchar(50) default NULL,
  `amount` double default NULL,
  PRIMARY KEY  (`attr_id`,`value_id`),
  KEY `a_index` (`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_map_enum` (
  `user_id` bigint(20) NOT NULL,
  `attr_id` int(11) NOT NULL,
  `value_id` int(11) default NULL,
  PRIMARY KEY  (`attr_id`,`user_id`),
  KEY `i_index` (`user_id`),
  KEY `a_index` (`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_map_int` (
  `user_id` bigint(20) NOT NULL,
  `attr_id` int(11) NOT NULL,
  `value` int(11) default NULL,
  PRIMARY KEY  (`attr_id`,`user_id`),
  index uidx (user_id,attr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_map_bigint` (
  `user_id` bigint(20) NOT NULL,
  `attr_id` int(11) NOT NULL,
  `value` bigint(20) default NULL,
  PRIMARY KEY  (`attr_id`,`user_id`),
  index uidx (user_id,attr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

 CREATE TABLE `user_map_double` (
  `user_id` bigint(20) NOT NULL,
  `attr_id` int(11) NOT NULL,
  `value` double default NULL,
  PRIMARY KEY  (`attr_id`,`user_id`),
  index uidx (user_id,attr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_map_varchar` (
  `user_id` bigint(20) NOT NULL,
  `attr_id` int(11) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`attr_id`,`user_id`),
  index uidx (user_id,attr_id),
  index avidx (attr_id,value)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `user_map_text` (
  `user_id` bigint(20) NOT NULL,
  `attr_id` int(11) NOT NULL,
  `value` text,
  PRIMARY KEY  (`attr_id`,`user_id`),
  index uidx (user_id,attr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8; 

CREATE TABLE `user_map_datetime` (
  `user_id` bigint(20) NOT NULL,
  `attr_id` int(11) NOT NULL,
  `value` datetime default NULL,
  PRIMARY KEY  (`attr_id`,`user_id`),
  index uidx (user_id,attr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_map_boolean` (
  `user_id` bigint(20) NOT NULL,
  `attr_id` int(11) NOT NULL,
  `value` tinyint(1) default NULL,
  PRIMARY KEY  (`attr_id`,`user_id`),
  index uidx (user_id,attr_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_attr_int` (
  `attr_id` int(11) NOT NULL,
  `value_id` int(11) NOT NULL,
  `min` int(11) default NULL,
  `max` int(11) default NULL,
  PRIMARY KEY  (`value_id`,`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_attr_bigint` (
  `attr_id` int(11) NOT NULL,
  `value_id` int(11) NOT NULL,
  `min` bigint(20) default NULL,
  `max` int(11) default NULL,
  PRIMARY KEY  (`value_id`,`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_attr_double` (
  `attr_id` int(11) NOT NULL,
  `value_id` int(11) NOT NULL,
  `min` double default NULL,
  `max` int(11) default NULL,
  PRIMARY KEY  (`value_id`,`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_attr_varchar` (
  `attr_id` int(11) NOT NULL,
  `value_id` int(11) NOT NULL,
  `min` varchar(25) default NULL,
  `max` varchar(25) default NULL,
  PRIMARY KEY  (`value_id`,`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_attr_datetime` (
  `attr_id` int(11) NOT NULL,
  `value_id` int(11) NOT NULL,
  `min` datetime default NULL,
  `max` datetime default NULL,
  PRIMARY KEY  (`value_id`,`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

 CREATE TABLE `user_attr_boolean` (
  `attr_id` int(11) NOT NULL,
  `value_id` int(11) NOT NULL,
  `min` tinyint(1) default NULL,
  `max` tinyint(1) default NULL,
  PRIMARY KEY  (`value_id`,`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `demographic` (
  `demo_id` int(11) NOT NULL auto_increment,
  `attr_id` int(11) default NULL,
  `value_id` int(11) default NULL,
  PRIMARY KEY  (`demo_id`),
  KEY `idx` (`attr_id`,`value_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `item_demo` (
  `item_id` bigint(20) NOT NULL,
  `demo_id` int(11) NOT NULL,
  `relevance` double default NULL,
  PRIMARY KEY  (`item_id`,`demo_id`),
  KEY `u_index` (`item_id`),
  KEY `d_index` (`demo_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


 CREATE TABLE `taste_item_similarity` (
  `item_id_a` bigint(20) NOT NULL,
  `item_id_b` bigint(20) NOT NULL,
  `similarity` float NOT NULL,
  PRIMARY KEY (`item_id_a`,`item_id_b`),
  KEY itembkey (item_id_b,item_id_a)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `version` (
  `major` int(11) NOT NULL,
  `minor` int(11) NOT NULL,
  `bugfix` int(11) NOT NULL,
  `date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `assoc_rules` (
  `consequent` bigint(20) NOT NULL,
  `set_id` varchar(255) NOT NULL,
  `item` bigint(20) NOT NULL,
  `support` bigint(20) NOT NULL,
  `confidence` double NOT NULL,
  `lift` double NOT NULL,
  `size` int(11) NOT NULL,
  PRIMARY KEY  (`consequent`,`set_id`,`item`),
  KEY `k0` (`item`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `dbpedia_item_tokens` (
  `item_id` bigint(20) NOT NULL,
  `token_id` bigint(20) NOT NULL,
  PRIMARY KEY (`item_id`,`token_id`),
  KEY `tkey` (`token_id`)
) ENGINE=InnoDB;

CREATE TABLE `dbpedia_token_hits` (
  `token_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tokens` varchar(255) CHARACTER SET utf8 NOT NULL,
  `hits` int(11) NOT NULL,
  `internal` bit(1) DEFAULT b'0',
  `external` bit(1) DEFAULT b'0',
  PRIMARY KEY (`token_id`),
  UNIQUE KEY `tkey` (`tokens`)
) ENGINE=InnoDB;

CREATE TABLE `dbpedia_token_token` (
  `token_id1` bigint(20) NOT NULL,
  `token_id2` bigint(20) NOT NULL,
  `ngd` double NOT NULL,
  `jaccard` double NOT NULL,
  `pmi` double NOT NULL,
  `good` int(11) DEFAULT '1',
  `bad` int(11) DEFAULT '0',
  `score` float NOT NULL DEFAULT '1',
  PRIMARY KEY (`token_id1`,`token_id2`),
  UNIQUE KEY `tid` (`token_id2`,`token_id1`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `dbpedia_token_searched` (
  `token_id` bigint(20) NOT NULL,
  PRIMARY KEY  (`token_id`)
) ENGINE=InnoDB;


CREATE TABLE `dbpedia_item_user` (
  `user_id` bigint(20) NOT NULL,
  `item_id` bigint(20) NOT NULL,
  `ex_item_id` bigint(20) NOT NULL,
  `tokens` varchar(255) NOT NULL,
  `ex_client_item_id` varchar(255) NOT NULL,
  `score` float NOT NULL DEFAULT '1',
  UNIQUE KEY `user_id` (`user_id`,`item_id`,`ex_item_id`),
  KEY `item_id` (`item_id`,`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
/*!50100 PARTITION BY RANGE (item_id)
(PARTITION p1 VALUES LESS THAN (10000) ENGINE = InnoDB,
 PARTITION p2 VALUES LESS THAN (20000) ENGINE = InnoDB,
 PARTITION p3 VALUES LESS THAN (40000) ENGINE = InnoDB,
 PARTITION p4 VALUES LESS THAN (60000) ENGINE = InnoDB,
 PARTITION p5 VALUES LESS THAN (80000) ENGINE = InnoDB,
 PARTITION pNew VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;


CREATE TABLE `cluster_group` (
  `cluster_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY  (`cluster_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_clusters` (
  `user_id` bigint(20) NOT NULL,
  `cluster_id` int(11) NOT NULL,
  `weight` double NOT NULL,
  PRIMARY KEY  (`user_id`,`cluster_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_clusters_new` (
  `user_id` bigint(20) NOT NULL,
  `cluster_id` int(11) NOT NULL,
  `weight` double NOT NULL,
  PRIMARY KEY  (`user_id`,`cluster_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `cluster_counts` (
  `id` int(11) NOT NULL,
  `item_id` bigint(20) NOT NULL,
  `count` double NOT NULL,
  `t` bigint(20) NOT NULL,
  PRIMARY KEY  (`id`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `cluster_update` (
  `lastupdate` bigint(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

create table user_clusters_transient (t_id bigint(20) not null auto_increment, `user_id` bigint(20) NOT NULL,   `cluster_id` int(11) NOT NULL,   `weight` double NOT NULL,primary key (t_id));

/*EXTERNAL ACTIONS*/
CREATE TABLE `ext_actions` (
  `action_id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `item_id` bigint(20) NOT NULL,
  `type` int(11) DEFAULT NULL,
  `times` int(11) DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `value` double DEFAULT NULL,
  `client_user_id` varchar(255) DEFAULT NULL,
  `client_item_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`action_id`),
  KEY `i_index` (`item_id`),
  KEY `idx` (`user_id`,`item_id`),
  KEY `cukey` (`client_user_id`),
  KEY `cikey` (`client_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ext_action_comment` (
  `action_id` bigint(20) NOT NULL,
  `comment` text,
  PRIMARY KEY  (`action_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `ext_action_tags` (
  `action_id` bigint(20) NOT NULL default '0',
  `tag_id` smallint(6) NOT NULL default '0',
  `tag` varchar(25) default NULL,
  PRIMARY KEY  (`action_id`,`tag_id`),
  KEY `a_index` (`action_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `trustlog` (
  `user1` bigint(20) NOT NULL,
  `user2` bigint(20) NOT NULL,
  `item_id` bigint(20) NOT NULL,
  `alpha` double NOT NULL,
  `beta` double NOT NULL,
  `time` bigint(20) NOT NULL,
  KEY `ukey` (`user1`,`user2`,`time`)
) ENGINE=InnoDB;

CREATE TABLE `trust_extended` (
  `user1` bigint(20) NOT NULL,
  `user2` bigint(20) NOT NULL,
  `dim_id` int(11) NOT NULL DEFAULT '0',
  `trust` double NOT NULL,
  `time` bigint(20) NOT NULL,
  PRIMARY KEY (`user1`,`dim_id`,`user2`)
) ENGINE=InnoDB;

CREATE TABLE `beta_parameters` (
  `alpha` double NOT NULL
) ENGINE=InnoDB;

CREATE TABLE `cooc_counts` (
  `item_id1` bigint(20) NOT NULL,
  `item_id2` bigint(20) NOT NULL,
  `count` double NOT NULL,
  `time` bigint(20) NOT NULL,
  PRIMARY KEY (`item_id1`,`item_id2`)
) ENGINE=InnoDB;

CREATE TABLE `item_counts` (
  `item_id` bigint(20) NOT NULL,
  `count` int(11) NOT NULL,
  `time` bigint(20) NOT NULL,
  PRIMARY KEY (`item_id`)
) ENGINE=InnoDB;

CREATE TABLE `item_clusters` (
  `item_id` bigint(20) NOT NULL,
  `cluster_id` int(11) NOT NULL,
  `weight` double NOT NULL,
  `created` bigint(20) NOT NULL,
  PRIMARY KEY (`item_id`,`cluster_id`),
  KEY `timekey` (`created`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `item_clusters_new` (
  `item_id` bigint(20) NOT NULL,
  `cluster_id` int(11) NOT NULL,
  `weight` double NOT NULL,
  `created` bigint(20) NOT NULL,
  PRIMARY KEY (`item_id`,`cluster_id`),
  KEY `timekey` (`created`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `cluster_dim_exclude` (
  `dim_id` int(11) NOT NULL,
  PRIMARY KEY (`dim_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `cluster_attr_exclude` (
  `attr_id` int(11) NOT NULL,
  PRIMARY KEY (`attr_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `dbpedia_item_user_searched` (
  `item_id` bigint(20) NOT NULL,
  PRIMARY KEY (`item_id`)
) ENGINE=InnoDB;

CREATE TABLE `dbpedia_item_user_searched_user` (
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `item_similarity` (
  `item_id` bigint(20) NOT NULL,
  `item_id2` bigint(20) NOT NULL,
  `score` double NOT NULL,
  PRIMARY KEY (`item_id`,`item_id2`),
  UNIQUE KEY `i2` (`item_id2`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `item_similarity_new` (
  `item_id` bigint(20) NOT NULL,
  `item_id2` bigint(20) NOT NULL,
  `score` double NOT NULL,
  PRIMARY KEY (`item_id`,`item_id2`),
  UNIQUE KEY `i2` (`item_id2`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `recommendations` (
  `user_id` bigint(20) NOT NULL,
  `item_id` bigint(20) NOT NULL,
  `score` double NOT NULL,
  PRIMARY KEY (`user_id`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `recommendations_new` (
  `user_id` bigint(20) NOT NULL,
  `item_id` bigint(20) NOT NULL,
  `score` double NOT NULL,
  PRIMARY KEY (`user_id`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `cluster_counts_total` (
  `uid` int(11) NOT NULL,
  `total` double NOT NULL,
  `t` bigint(20) NOT NULL,
  PRIMARY KEY (`uid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `cluster_counts_item_total` (
  `item_id` bigint(20) NOT NULL,
  `total` double NOT NULL,
  `t` bigint(20) NOT NULL,
  PRIMARY KEY (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_tag` (
  `user_id` bigint(20) NOT NULL,
  `tag` varchar(255) NOT NULL,
  `count` int(11) NOT NULL,
  PRIMARY KEY (`user_id`,`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `cluster_referrer` (
  `referrer` varchar(255) NOT NULL,
  `cluster` int(11) NOT NULL,
  PRIMARY KEY (`referrer`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `tag_cluster_counts` (
  `tag` varchar(255) NOT NULL,
  `item_id` bigint(20) NOT NULL,
  `count` double NOT NULL,
  `t` bigint(20) NOT NULL,
  PRIMARY KEY (`tag`,`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `user_similarity` (
  `u1` bigint(20) NOT NULL,
  `u2` bigint(20) NOT NULL,
  `type` int(11) NOT NULL,
  `score` double NOT NULL,
  PRIMARY KEY (`u1`,`u2`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `mgm_interaction` (
        `u2_fbid` varchar(30) NOT NULL,
  `type` int(11) NOT NULL,
  `sub_type` int(11) NOT NULL,
  `count` int(11) NOT NULL,
  `parameter_id` int(11) NOT NULL DEFAULT '0',
  `date` datetime DEFAULT NULL,
  `u1_userid` varchar(255) NOT NULL DEFAULT '',
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`),
  KEY `userid_ix` (`u1_userid`),
  KEY `u2_fbid` (`u2_fbid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `mgm_interaction_event` (
	  `id` int(11) NOT NULL AUTO_INCREMENT,
	  `interaction_id` int(11) NOT NULL,
	  `type` int(11) NOT NULL,
	  `date` datetime DEFAULT NULL,
	  PRIMARY KEY (`id`),
	  KEY `interaction_id` (`interaction_id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

CREATE TABLE `ext_usr_attr` (
	  `id` int(11) NOT NULL AUTO_INCREMENT,
	  `uid` varchar(15) NOT NULL DEFAULT '',
	  `type` varchar(10) NOT NULL DEFAULT '',
	  `value` varchar(50) NOT NULL DEFAULT '',
	  PRIMARY KEY (`id`),
	  UNIQUE KEY `uid_ix` (`uid`,`type`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8;

CREATE TABLE `dbpedia_keyword_user` (
  `k_id` int(11) NOT NULL,
  `u1` bigint(20) NOT NULL,
  `u2` bigint(20) NOT NULL,
  `tokens` varchar(255) NOT NULL,
  `ex_client_item_id` varchar(255) NOT NULL,
  `score` float NOT NULL,
  PRIMARY KEY (`k_id`,`u1`,`u2`,`ex_client_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8
/*!50100 PARTITION BY RANGE (k_id)
(PARTITION p1 VALUES LESS THAN (100) ENGINE = InnoDB,
 PARTITION p2 VALUES LESS THAN (200) ENGINE = InnoDB,
 PARTITION p3 VALUES LESS THAN (300) ENGINE = InnoDB,
 PARTITION p4 VALUES LESS THAN (400) ENGINE = InnoDB,
 PARTITION p5 VALUES LESS THAN (500) ENGINE = InnoDB,
 PARTITION pNew VALUES LESS THAN MAXVALUE ENGINE = InnoDB) */;
 
 CREATE TABLE `dbpedia_keyword` (
  `k_id` int(11) NOT NULL AUTO_INCREMENT,
  `keyword` varchar(255) NOT NULL,
  `time` bigint(20) NOT NULL,
  PRIMARY KEY (`k_id`),
  UNIQUE KEY `keyword` (`keyword`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8;


CREATE TABLE `fb_likes_popularity` (
  `item_id` bigint(20) NOT NULL,
  `popularity` int(11) NOT NULL,
  `client` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`item_id`),
  KEY `cindex` (`client`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE `user_interaction` (
  `u1_id` bigint(20) unsigned NOT NULL,
  `u2_fbid` varchar(30) NOT NULL,
  `type` int(11) NOT NULL,
  `sub_type` int(11) NOT NULL,
  `count` int(11) NOT NULL,
  `parameter_id` int(11) NOT NULL DEFAULT '0',
  `date` datetime DEFAULT NULL,
  PRIMARY KEY (`u1_id`,`u2_fbid`,`type`,`sub_type`,`parameter_id`),
  KEY `u1idx` (`u1_id`),
  KEY `u1typeidx` (`u1_id`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `fbcat_map` (
  `category` varchar(255) NOT NULL,
  `dim_id` int(11) NOT NULL,
  PRIMARY KEY (`category`,`dim_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/* --( Inserts FB) ------------------------------------------------ */
INSERT INTO `version` VALUES (0,70,0,now());

insert into `user_attr` (`name`,`type`) values('facebook', 'BOOLEAN');
insert into `user_attr` (`name`,`type`) values('facebookId', 'VARCHAR');
insert into `user_attr` (`name`,`type`) values('facebookToken', 'VARCHAR');
insert into `user_attr` (`name`,`type`) values('facebookStartImport', 'DATETIME');
insert into `user_attr` (`name`,`type`) values('facebookFinishImport', 'DATETIME');
insert into `user_attr` (`name`,`type`) values('fb_gender','ENUM');
insert into `user_attr` (`name`,`type`) values('fb_date_of_birth','DATETIME');
insert into `user_attr` (`name`,`type`) values('fb_birthday','VARCHAR');
insert into `user_attr` (`name`,`type`) values('facebookClient', 'VARCHAR');
insert into `user_attr` (`name`,`type`) values('facebookAppId', 'VARCHAR');
/* ---------------------------------------------------------------- */

insert into user_attr_enum (attr_id, value_id, value_name, amount) values (6, 1, 'NONE', 0);

insert into cluster_update values (unix_timestamp());
insert into item_type (type_id,name,link_type,semantic) values (1,"content",null,1), (100,"fbpage",1,1);

insert into action_type (type_id,name,weight,def_value,link_type,semantic) values(1,"view",1,null,null,0);
insert into action_type (type_id,name,weight,def_value,link_type,semantic) values (2,"fblike",1,null,null,0);

INSERT INTO `item_attr` VALUES (1,'content_type','ENUM',1,1),(2,'categories','VARCHAR',1,1),(3,'description','TEXT',1,1),(4,'published_date','DATETIME',1,1),(5,'category','ENUM',1,0),(6,'title','VARCHAR',1,0),(7,'img_url','VARCHAR',1,0),(8,'link','VARCHAR',1,0),(9,'tags','VARCHAR',1,0),(10,'subcategory','ENUM',1,0);

insert into dimension (item_type,attr_id,value_id) values(0,null,null);
insert into dimension (item_type,attr_id,value_id) values(1,null,null);
insert into dimension (item_type,attr_id,value_id) values (0,100,null);

insert into item_attr_enum (attr_id,value_id,value_name, amount, name) values(1,1,'article',0,'');
insert into dimension (dim_id,item_type,attr_id,value_id,trustnetwork) values(0,1,1,1,0);

insert into item_attr_enum (attr_id,value_id,value_name, amount, name) values(5,1,'DEFAULT',0,'');
insert into dimension (dim_id,item_type,attr_id,value_id,trustnetwork) values(0,1,5,1,0);

insert into item_attr_enum (attr_id,value_id,value_name, amount, name) values(10,1,'DEFAULT',0,'');
insert into dimension (dim_id,item_type,attr_id,value_id,trustnetwork) values(0,1,10,1,0);

insert into dimension (item_type,attr_id,value_id) values(0,null,null);
insert into dimension (item_type,attr_id,value_id) values(1,null,null);



