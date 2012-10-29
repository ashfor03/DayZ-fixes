-- --------------------------------------------------------
-- Server version:               5.5.24-0ubuntu0.12.04.1-log - (Ubuntu)
-- Server OS:                    debian-linux-gnu
-- HeidiSQL version:             7.0.0.4217
-- Date/time:                    2012-10-29 18:23:49
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping database structure for hivemind
DROP DATABASE IF EXISTS `hivemind`;
CREATE DATABASE IF NOT EXISTS `hivemind` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `hivemind`;

-- Dumping structure for table hivemind.character_data
DROP TABLE IF EXISTS `character_data`;
CREATE TABLE IF NOT EXISTS `character_data` (
  `CharacterID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `PlayerUID` varchar(16) NOT NULL DEFAULT '',
  `Alive` tinyint(1) NOT NULL DEFAULT '1',
  `InstanceID` varchar(4) NOT NULL DEFAULT '',
  `Worldspace` varchar(64) NOT NULL DEFAULT '[]',
  `Inventory` varchar(2048) NOT NULL DEFAULT '[]',
  `Backpack` varchar(2048) NOT NULL DEFAULT '[]',
  `Medical` varchar(256) NOT NULL DEFAULT '[]',
  `Generation` smallint(4) unsigned NOT NULL DEFAULT '0',
  `Datestamp` timestamp NULL DEFAULT NULL,
  `LastLogin` timestamp NULL DEFAULT NULL,
  `LastAte` timestamp NULL DEFAULT NULL,
  `LastDrank` timestamp NULL DEFAULT NULL,
  `Humanity` mediumint(6) DEFAULT NULL,
  `KillsZ` mediumint(5) unsigned NOT NULL DEFAULT '0',
  `HeadshotsZ` mediumint(5) unsigned NOT NULL DEFAULT '0',
  `distanceFoot` bigint(15) unsigned NOT NULL DEFAULT '0',
  `duration` int(10) NOT NULL DEFAULT '0',
  `currentState` varchar(128) NOT NULL DEFAULT '[]',
  `KillsH` mediumint(5) unsigned NOT NULL DEFAULT '0',
  `KillsB` mediumint(5) unsigned NOT NULL DEFAULT '0',
  `Model` varchar(32) NOT NULL DEFAULT 'Survivor1_DZ',
  PRIMARY KEY (`CharacterID`),
  KEY `PlayerUID` (`PlayerUID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Dumping structure for table hivemind.dbver
DROP TABLE IF EXISTS `dbver`;
CREATE TABLE IF NOT EXISTS `dbver` (
  `version` mediumint(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`version`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Dumping structure for function hivemind.fGetClassCount
DROP FUNCTION IF EXISTS `fGetClassCount`;
DELIMITER //
CREATE DEFINER=`root`@`` FUNCTION `fGetClassCount`(`clname` varchar(32)) RETURNS int(11)
    READS SQL DATA
BEGIN
	DECLARE iClassCount INT DEFAULT 0;
	SELECT COUNT(*) 
		INTO iClassCount 
		FROM object_data 
		WHERE Classname LIKE clname;
	RETURN iClassCount;
END//
DELIMITER ;

-- Dumping structure for function hivemind.fGetSpawnFromChance
DROP FUNCTION IF EXISTS `fGetSpawnFromChance`;
DELIMITER //
CREATE DEFINER=`root`@`` FUNCTION `fGetSpawnFromChance`(`chance` double) RETURNS tinyint(1)
    NO SQL
BEGIN
	DECLARE bspawn TINYINT(1) DEFAULT 0;
	IF (RAND() <= chance) THEN
		SET bspawn = 1;
	END IF;
	RETURN bspawn;
END//
DELIMITER ;

-- Dumping structure for function hivemind.fGetVehCount
DROP FUNCTION IF EXISTS `fGetVehCount`;
DELIMITER //
CREATE DEFINER=`root`@`` FUNCTION `fGetVehCount`() RETURNS smallint(3)
    READS SQL DATA
BEGIN
	DECLARE iVehCount	SMALLINT(3) DEFAULT 0;
	SELECT COUNT(*) 
		INTO iVehCount
		FROM object_data 
		WHERE 	AND Classname != 'TentStorage'  
			AND Classname != 'Hedgehog_DZ'	
			AND Classname != 'Wire_cat1'		
			AND Classname != 'Sandbag1_DZ'	
			AND Classname != 'TrapBear';		
	RETURN iVehCount;
END//
DELIMITER ;

-- Dumping structure for table hivemind.object_classes
DROP TABLE IF EXISTS `object_classes`;
CREATE TABLE IF NOT EXISTS `object_classes` (
  `Classname` varchar(32) NOT NULL DEFAULT '',
  `Chance` varchar(4) NOT NULL DEFAULT '0',
  `MaxNum` tinyint(1) unsigned NOT NULL DEFAULT '0',
  `Damage` varchar(20) NOT NULL DEFAULT '0',
  `Hitpoints` varchar(999) NOT NULL DEFAULT '[]',
  PRIMARY KEY (`Classname`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


-- Dumping structure for table hivemind.object_data
DROP TABLE IF EXISTS `object_data`;
CREATE TABLE IF NOT EXISTS `object_data` (
  `ObjectID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ObjectUID` varchar(20) DEFAULT NULL,
  `Instance` varchar(4) DEFAULT NULL,
  `Classname` varchar(32) DEFAULT NULL,
  `Damage` varchar(20) DEFAULT NULL,
  `CharacterID` int(10) unsigned DEFAULT NULL,
  `Worldspace` varchar(64) NOT NULL,
  `Inventory` varchar(2048) DEFAULT NULL,
  `Hitpoints` varchar(999) DEFAULT NULL,
  `Fuel` varchar(20) DEFAULT NULL,
  `Datestamp` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ObjectID`),
  UNIQUE KEY `ObjectUID` (`ObjectUID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Dumping structure for table hivemind.object_spawns
DROP TABLE IF EXISTS `object_spawns`;
CREATE TABLE IF NOT EXISTS `object_spawns` (
  `ObjectUID` varchar(20) NOT NULL DEFAULT '',
  `Classname` varchar(32) NOT NULL,
  `Worldspace` varchar(64) DEFAULT NULL,
  `Description` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ObjectUID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- Dumping structure for procedure hivemind.pCleanup
DROP PROCEDURE IF EXISTS `pCleanup`;
DELIMITER //
CREATE DEFINER=`root`@`` PROCEDURE `pCleanup`(IN `inInstance` INT)
BEGIN
	CALL pCleanupOOB(inInstance);

	DELETE
		FROM object_data 
		WHERE Instance = inInstance 
			AND Damage = '1';
	DELETE
		FROM object_data
		WHERE Instance = inInstance 
			AND DATE(Datestamp) < CURDATE() - INTERVAL 8 DAY
			AND Classname != 'TentStorage'
			AND Classname != 'Hedgehog_DZ'
			AND Classname != 'Wire_cat1'
			AND Classname != 'Sandbag1_DZ'
			AND Classname != 'TrapBear';
	DELETE
		FROM object_data
		USING object_data, character_data
		WHERE Instance = inInstance
			AND object_data.Classname = 'TentStorage'
			AND object_data.CharacterID = character_data.CharacterID
			AND character_data.Alive = 0
			AND DATE(character_data.Datestamp) < CURDATE() - INTERVAL 8 DAY;
	DELETE
		FROM object_data
		WHERE Instance = inInstance
			AND Classname = 'TentStorage'
			AND DATE(Datestamp) < CURDATE() - INTERVAL 8 DAY
			AND Inventory = '[[[],[]],[[],[]],[[],[]]]';
	DELETE
		FROM object_data
		WHERE Instance = inInstance
			AND Classname = 'Wire_cat1'
			AND DATE(Datestamp) < CURDATE() - INTERVAL 3 DAY;
	DELETE
		FROM object_data
		WHERE Instance = inInstance
			AND Classname = 'Hedgehog_DZ'
			AND DATE(Datestamp) < CURDATE() - INTERVAL 4 DAY;
	DELETE
		FROM object_data
		WHERE Instance = inInstance
			AND Classname = 'Sandbag1_DZ'
			AND DATE(Datestamp) < CURDATE() - INTERVAL 8 DAY;
	DELETE
		FROM object_data
		WHERE Instance = inInstance
			AND Classname = 'TrapBear'
			AND DATE(Datestamp) < CURDATE() - INTERVAL 5 DAY;
END//
DELIMITER ;

-- Dumping structure for procedure hivemind.pCleanupOOB
DROP PROCEDURE IF EXISTS `pCleanupOOB`;
DELIMITER //
CREATE DEFINER=`root`@`` PROCEDURE `pCleanupOOB`(IN `inInstance` INT)
BEGIN
	DECLARE intLineCount	INT DEFAULT 0;
	DECLARE intDoLine	INT DEFAULT 0;
	SELECT COUNT(*)
		INTO intLineCount
		FROM object_data
		WHERE Instance = inInstance;
	WHILE (intLineCount > 0) DO
		SET intDoLine = intLineCount - 1;
		SELECT ObjectUID, Worldspace
			INTO @rsObjectUID, @rsWorldspace
			FROM object_data
			WHERE Instance = inInstance
			LIMIT intDoLine, 1;
		select SUBSTRING_INDEX(@rsWorldspace,'[',-1 ) INTO @rsWorldspace;
		select SUBSTRING_INDEX(@rsWorldspace,']', 1 ) INTO @rsWorldspace;
		select SUBSTRING_INDEX(@rsWorldspace,',', 2 ) INTO @rsWorldspace;
		select SUBSTRING_INDEX(@rsWorldspace, ',', 1),SUBSTRING_INDEX(@rsWorldspace, ',', -1) INTO @west, @north;
		if (@west <0 OR @west >15360 OR @north <0 OR @north > 15360 ) then
			DELETE FROM object_data
				WHERE ObjectUID = @rsObjectUID;
		end if;
		SET intLineCount = intLineCount - 1;
	END WHILE;
END//
DELIMITER ;

-- Dumping structure for procedure hivemind.pFixMaxNum
DROP PROCEDURE IF EXISTS `pFixMaxNum`;
DELIMITER //
CREATE DEFINER=`root`@`` PROCEDURE `pFixMaxNum`()
BEGIN
	DECLARE iCounter INT DEFAULT 0;
	SELECT COUNT(*) INTO @iClassesCount FROM object_classes WHERE Classname<>'';
	WHILE (iCounter < @iClassesCount) DO
		SELECT Classname, MaxNum INTO @Classname, @MaxNum FROM object_classes LIMIT iCounter,1;
		SELECT COUNT(*) INTO @iMaxClassSpawn FROM object_spawns WHERE Classname LIKE @Classname;
		IF (@MaxNum > @iMaxClassSpawn) THEN
			UPDATE object_classes SET MaxNum = @iMaxClassSpawn WHERE Classname = @Classname;
		END IF;
		SET iCounter = iCounter + 1;
	END WHILE;
END//
DELIMITER ;

-- Dumping structure for table hivemind.player_data
DROP TABLE IF EXISTS `player_data`;
CREATE TABLE IF NOT EXISTS `player_data` (
  `PlayerUID` varchar(20) NOT NULL DEFAULT '',
  `PlayerName` varchar(24) NOT NULL DEFAULT '',
  `PlayerSex` int(1) DEFAULT NULL,
  PRIMARY KEY (`PlayerUID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Dumping structure for table hivemind.player_login
DROP TABLE IF EXISTS `player_login`;
CREATE TABLE IF NOT EXISTS `player_login` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `PlayerUID` varchar(20) DEFAULT '',
  `CharacterID` int(10) DEFAULT NULL,
  `Action` tinyint(3) NOT NULL DEFAULT '0',
  `Datestamp` datetime DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Dumping structure for procedure hivemind.pMain
DROP PROCEDURE IF EXISTS `pMain`;
DELIMITER //
CREATE DEFINER=`root`@`` PROCEDURE `pMain`(IN `inInstance` INT)
BEGIN
	CALL pCleanup(inInstance);
	CALL pFixMaxNum;
	CALL pSpawn(inInstance);
END//
DELIMITER ;

-- Dumping structure for procedure hivemind.pSpawn
DROP PROCEDURE IF EXISTS `pSpawn`;
DELIMITER //
CREATE DEFINER=`root`@`` PROCEDURE `pSpawn`(IN `inInstance` INT)
BEGIN
	DECLARE intOffset	INT DEFAULT 0;
	DECLARE bDoSpawn	INT DEFAULT 0;
	DECLARE intCounter	INT DEFAULT 0;

	SELECT COUNT(*)
		INTO intOffset
		FROM object_classes;

	WHILE (bDoSpawn  < intOffset) DO
		SELECT Classname, Chance, MaxNum, Damage, Hitpoints
			INTO @rsClassname, @rsChance, @rsMaxNum, @rsDamage, @rsHitpoints
			FROM object_classes
			LIMIT bDoSpawn, 1;
		SET intCounter = fGetClassCount(@rsClassname);

  		WHILE (  intCounter<@rsMaxNum ) DO
  		IF (fGetSpawnFromChance(@rschance) = 1) THEN
			INSERT INTO object_data (ObjectUID, Instance, Classname, Damage, CharacterID, Worldspace, Inventory, Hitpoints, Fuel, Datestamp)
				SELECT ObjectUID, inInstance,object_spawns.Classname,@rsDamage,'0',object_spawns.Worldspace,'[]', @rsHitpoints, '0.05', SYSDATE() 
					FROM object_spawns
					LEFT JOIN object_data using(ObjectUID) where ObjectID is NULL AND object_spawns.Classname LIKE @rsClassname
					LIMIT 0, 1;
		END IF;
		SET intCounter=intCounter+1;
 		END WHILE;
	SET bDoSpawn = bDoSpawn + 1;
	END WHILE;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
