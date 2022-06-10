-- --------------------------------------------------------
-- Host:                         jomaso.ddns.net
-- Versión del servidor:         10.3.34-MariaDB-0ubuntu0.20.04.1 - Ubuntu 20.04
-- SO del servidor:              debian-linux-gnu
-- HeidiSQL Versión:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Volcando estructura de base de datos para joma_jomabb
CREATE DATABASE IF NOT EXISTS `joma_jomabb` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `joma_jomabb`;

-- Volcando estructura para procedimiento joma_jomabb.addDeporte
DELIMITER //
CREATE PROCEDURE `addDeporte`(
	IN `Nname` VARCHAR(20),
	IN `Ndescrip` VARCHAR(200)
)
BEGIN		
		INSERT INTO deportes(nombre,descripcion)
		VALUES(Nname,Ndescrip);
END//
DELIMITER ;

-- Volcando estructura para función joma_jomabb.addEquipo
DELIMITER //
CREATE FUNCTION `addEquipo`(
	`idAd` INT,
	`Nname` VARCHAR(50),
	`desc` VARCHAR(200),
	`deport` VARCHAR(50)
) RETURNS tinyint(1)
    NO SQL
    SQL SECURITY INVOKER
BEGIN
		DECLARE idEq1 INT;
		DECLARE resultado BOOLEAN;
		DECLARE idD INT;
		DECLARE cont INT;
		
		SELECT COUNT(*) INTO cont FROM equipos e WHERE e.nombre=Nname;
		
		if cont<1 then
			SET resultado=TRUE;
			INSERT INTO equipos(nombre,admin,descripcion)
			VALUES(Nname,idAd,`desc`);
	
			SELECT e.id into idEq1 FROM equipos e WHERE e.nombre=Nname;
			
			INSERT INTO participa(id_usuario,id_equipo)
			VALUES(idAd,idEq1);
			
			SELECT d.id into idD from deportes d WHERE d.nombre=deport;
			
			INSERT INTO practica (id_equipo,id_deporte)
			VALUES(idEq1,idD);			
		ELSE 
			set resultado=FALSE;
		END if;
		
		RETURN resultado;		
END//
DELIMITER ;

-- Volcando estructura para función joma_jomabb.addJugador
DELIMITER //
CREATE FUNCTION `addJugador`(
	`idU` INT,
	`idE` INT
) RETURNS tinyint(1)
BEGIN
	DECLARE result BOOLEAN;

	DECLARE compUsr INT;

	SELECT COUNT(p.id_usuario) INTO compUsr FROM participa p WHERE p.id_equipo=idE AND p.id_usuario=idU;
	
	if compUsr>0 then
		set result=FALSE;
	ELSE
		INSERT INTO participa (id_usuario,id_equipo) VALUES(idU,idE);
		SET result=TRUE;
	END if;
	
	RETURN result;

END//
DELIMITER ;

-- Volcando estructura para procedimiento joma_jomabb.addTorneo
DELIMITER //
CREATE PROCEDURE `addTorneo`(
	IN `Nname` VARCHAR(50),
	IN `Ndescrip` VARCHAR(200),
	IN `NfechaInicio` DATE,
	IN `NfechaInscrip` DATE,
	IN `depName` VARCHAR(50)
)
BEGIN

	DECLARE idT INT;
	DECLARE idD INT;
	
	INSERT INTO torneos(nombre,descripcion,fecha_inicio,fecha_inscripcion)
	VALUES(Nname,Ndescrip,NfechaInicio,NfechaInscrip);
	
	SELECT t.id INTO idT FROM torneos t WHERE t.nombre=Nname AND t.descripcion=Ndescrip and t.fecha_inicio=NfechaInicio AND t.fecha_inscripcion=NfechaInscrip;
	
	SELECT d.id INTO idD FROM deportes d WHERE d.nombre=depName;
	
	INSERT INTO trata (id_torneo,id_deporte)
	VALUES(idT,idD);
	
	
END//
DELIMITER ;

-- Volcando estructura para función joma_jomabb.addUsuario
DELIMITER //
CREATE FUNCTION `addUsuario`(
	`Nnick` VARCHAR(20),
	`Nname` VARCHAR(50),
	`Ncorreo` VARCHAR(50),
	`Napellido` VARCHAR(100),
	`Ncontra` VARCHAR(100),
	`Nedad` INT
) RETURNS tinyint(1)
BEGIN

	DECLARE comprobar BOOLEAN ;
	DECLARE cant INT;
	SELECT COUNT(*) INTO cant FROM usuarios WHERE nickname=Nnick;
		
	if cant >=1 then
		return FALSE;
	ELSE	
		INSERT INTO usuarios(nickname,correo,nombre,apellidos,edad,contrasenya)
		VALUES(Nnick,Ncorreo,`Nname`,Napellido,Nedad,MD5(Ncontra));
		return TRUE;
	END if;
			
END//
DELIMITER ;

-- Volcando estructura para procedimiento joma_jomabb.borraDeporte
DELIMITER //
CREATE PROCEDURE `borraDeporte`(
	IN `id_D` INT
)
BEGIN 

	DECLARE result BOOLEAN;
	DECLARE DeporteRevisar INT;

		SELECT id INTO DeporteRevisar
		FROM deportes
		WHERE id=id_D;

		IF DeporteRevisar!=id_D THEN
			SET result=FALSE;
		
		ELSE 
			DELETE FROM deportes
			WHERE id=id_D;
			SET result=TRUE;
		END IF;
END//
DELIMITER ;

-- Volcando estructura para procedimiento joma_jomabb.borraEquipo
DELIMITER //
CREATE PROCEDURE `borraEquipo`(
	IN `idAdmin_E` INT,
	IN `Nname` VARCHAR(50)
)
BEGIN 
	DECLARE adminRevisar INT;
	DECLARE id_E INT;
	
		SELECT e.id INTO id_E from equipos e WHERE e.nombre=Nname;

		SELECT admin INTO idAdmin_E
		FROM equipos
		WHERE id_E=id;

		IF adminRevisar=idAdmin_E THEN
			DELETE FROM equipos
			WHERE id=id_E;
		END IF;
END//
DELIMITER ;

-- Volcando estructura para función joma_jomabb.borrarJugador
DELIMITER //
CREATE FUNCTION `borrarJugador`(
	`idU` INT,
	`idE` INT
) RETURNS tinyint(1)
BEGIN
	DECLARE result BOOLEAN;

	DECLARE compUsr INT;

	SELECT COUNT(p.id_usuario) INTO compUsr FROM participa p WHERE p.id_equipo=idE AND p.id_usuario=idU;
	
	if compUsr<1 then
		set result=FALSE;
	ELSE
		DELETE FROM participa
		WHERE id_equipo=idE AND id_usuario=idU;
		SET result=TRUE;
	END if;
	
	RETURN result;

END//
DELIMITER ;

-- Volcando estructura para procedimiento joma_jomabb.borraUsuario
DELIMITER //
CREATE PROCEDURE `borraUsuario`(
	IN `id_U` INT,
	IN `contrasenya_U` VARCHAR(100)
)
BEGIN 

	DECLARE result BOOLEAN;
	DECLARE contraRevisar VARCHAR(100);

		SELECT contrasenya INTO contraRevisar
		FROM usuarios
		WHERE id=id_U;

		IF contraRevisar!=contrasenya_U THEN
			SET result=FALSE;
		
		ELSE 
			DELETE FROM usuarios
			WHERE id=id_U;
			SET result=TRUE;
		END IF;
		
END//
DELIMITER ;

-- Volcando estructura para tabla joma_jomabb.compite
CREATE TABLE IF NOT EXISTS `compite` (
  `id_equipos` int(11) NOT NULL,
  `id_torneo` int(11) NOT NULL,
  PRIMARY KEY (`id_equipos`,`id_torneo`),
  KEY `id_torneocompite` (`id_torneo`),
  CONSTRAINT `id_equiposcompite` FOREIGN KEY (`id_equipos`) REFERENCES `equipos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `id_torneocompite` FOREIGN KEY (`id_torneo`) REFERENCES `torneos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla joma_jomabb.deportes
CREATE TABLE IF NOT EXISTS `deportes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para función joma_jomabb.desinscribirEquipo
DELIMITER //
CREATE FUNCTION `desinscribirEquipo`(
	`nameEq` VARCHAR(50),
	`usrLog` INT,
	`idT` INT
) RETURNS tinyint(1)
BEGIN

	DECLARE result BOOLEAN;
	
	DECLARE contaAdmin INT;
	DECLARE idEq INT;
	
	SELECT e.id INTO idEq FROM equipos e WHERE e.nombre=nameEq;


-- mira si el usuario es admin de su equipo
	SELECT COUNT(e.id) into contaAdmin FROM equipos e WHERE e.id=idEq AND e.admin=usrLog;
		
	IF contaAdmin >0 then	
		DELETE FROM compite  WHERE id_equipos=idEq AND id_torneo=idT;
		SET result=TRUE;
	ELSE
		SET result=FALSE;
		
	END IF;

	RETURN result;

END//
DELIMITER ;

-- Volcando estructura para tabla joma_jomabb.equipos
CREATE TABLE IF NOT EXISTS `equipos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `admin` int(11) NOT NULL,
  `logo` blob DEFAULT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nombre` (`nombre`),
  KEY `fk_idadmindeusuario` (`admin`),
  CONSTRAINT `fk_idadmindeusuario` FOREIGN KEY (`admin`) REFERENCES `usuarios` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para función joma_jomabb.inscribEquipo
DELIMITER //
CREATE FUNCTION `inscribEquipo`(
	`nameEq` VARCHAR(50),
	`usuarioLog` INT,
	`idT` INT
) RETURNS tinyint(1)
BEGIN

	DECLARE result BOOLEAN;
	DECLARE acumulaInscrip INT;
	
	DECLARE contaAdmin INT;
	DECLARE idEq INT;
	
	SELECT e.id INTO idEq FROM equipos e WHERE e.nombre=nameEq;

-- mira si el equipo a inscribirse ya esta inscrito
	SELECT COUNT(c.id_equipos) INTO acumulaInscrip FROM compite c 
	WHERE c.id_equipos=idEq AND c.id_torneo=idT;

-- mira si el usuario es admin de su equipo
	SELECT COUNT(e.id) into contaAdmin FROM equipos e WHERE e.nombre=nameEq AND e.admin=usuarioLog;
	
--	DECLARE fechaC INT;
--	SELECT COUNT(t.id) INTO fechaC FROM torneos t WHERE t.id=idT AND t.fecha_inscripcion>=CURDATE();
		
	
	IF acumulaInscrip > 0 then
		SET result=false;
		
	ELSEIF contaAdmin >=1 then	
		
--		if countDate>=1 then
			INSERT INTO compite(id_equipos,id_torneo)
			VALUES(idEq,idT);
			SET result=TRUE;
--		ELSE
--			SET result=FALSE;
--		END if;	
	END IF;

	RETURN result;

END//
DELIMITER ;

-- Volcando estructura para tabla joma_jomabb.juega
CREATE TABLE IF NOT EXISTS `juega` (
  `id_usuario` int(11) NOT NULL,
  `id_deporte` int(11) NOT NULL,
  PRIMARY KEY (`id_usuario`,`id_deporte`),
  KEY `fk_laideporte` (`id_deporte`),
  CONSTRAINT `fk_laideporte` FOREIGN KEY (`id_deporte`) REFERENCES `deportes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_laidusuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para procedimiento joma_jomabb.obtenerTorneos
DELIMITER //
CREATE PROCEDURE `obtenerTorneos`()
BEGIN

	SELECT tor.id,tor.nombre, d.nombre AS "deporte", tor.fecha_inicio, tor.fecha_inscripcion FROM torneos tor, deportes d, trata t 
	WHERE fecha_inicio>=CURDATE() AND tor.id=t.id_torneo AND d.id=t.id_deporte
	ORDER BY fecha_inicio ASC;

END//
DELIMITER ;

-- Volcando estructura para procedimiento joma_jomabb.obtenerTorneosHome
DELIMITER //
CREATE PROCEDURE `obtenerTorneosHome`()
BEGIN 

	SELECT tor.id, tor.nombre, d.nombre AS "deporte", tor.fecha_inicio, tor.fecha_inscripcion FROM torneos tor, deportes d, trata t 
	WHERE fecha_inicio>=CURDATE() AND tor.id=t.id_torneo AND d.id=t.id_deporte
	ORDER BY fecha_inicio ASC;

END//
DELIMITER ;

-- Volcando estructura para procedimiento joma_jomabb.obtUsuario
DELIMITER //
CREATE PROCEDURE `obtUsuario`(
	IN `nick` VARCHAR(20)
)
BEGIN
	
	DECLARE usr INT;
	SELECT u.id INTO usr FROM usuarios u
	WHERE u.nickname=nick;
	
	SELECT u.*, p.id_equipo,j.id_deporte FROM usuarios u, participa p, juega j
	WHERE u.id=usr AND p.id_usuario=usr AND j.id_usuario=usr;

END//
DELIMITER ;

-- Volcando estructura para tabla joma_jomabb.participa
CREATE TABLE IF NOT EXISTS `participa` (
  `id_usuario` int(11) NOT NULL,
  `id_equipo` int(11) NOT NULL,
  PRIMARY KEY (`id_equipo`,`id_usuario`),
  KEY `fk_idusuario` (`id_usuario`),
  CONSTRAINT `fk_idequipo` FOREIGN KEY (`id_equipo`) REFERENCES `equipos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_idusuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla joma_jomabb.practica
CREATE TABLE IF NOT EXISTS `practica` (
  `id_equipo` int(11) NOT NULL,
  `id_deporte` int(11) NOT NULL,
  PRIMARY KEY (`id_equipo`,`id_deporte`),
  KEY `fk_iddeportepractica` (`id_deporte`),
  CONSTRAINT `fk_iddeportepractica` FOREIGN KEY (`id_deporte`) REFERENCES `deportes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_idequipopractica` FOREIGN KEY (`id_equipo`) REFERENCES `equipos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla joma_jomabb.torneos
CREATE TABLE IF NOT EXISTS `torneos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_inscripcion` date NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para tabla joma_jomabb.trata
CREATE TABLE IF NOT EXISTS `trata` (
  `id_torneo` int(11) NOT NULL,
  `id_deporte` int(11) NOT NULL,
  PRIMARY KEY (`id_torneo`,`id_deporte`),
  KEY `id_deportetrata` (`id_deporte`),
  CONSTRAINT `id_deportetrata` FOREIGN KEY (`id_deporte`) REFERENCES `deportes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `id_torneotrata` FOREIGN KEY (`id_torneo`) REFERENCES `torneos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para función joma_jomabb.userLog
DELIMITER //
CREATE FUNCTION `userLog`(
	`nick` VARCHAR(20),
	`contra` VARCHAR(100)
) RETURNS tinyint(1)
BEGIN 

	DECLARE result BOOLEAN;
	DECLARE cont INT;
	
		SELECT COUNT(*) INTO cont
		FROM usuarios
		WHERE contrasenya=MD5(contra) AND nickname=nick;

		IF cont!=1 THEN
			SET result=FALSE;
			RETURN result;
		ELSE
			SET result=TRUE;
			RETURN result;
		END IF;
		
END//
DELIMITER ;

-- Volcando estructura para tabla joma_jomabb.usuarios
CREATE TABLE IF NOT EXISTS `usuarios` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nickname` varchar(20) NOT NULL,
  `correo` varchar(50) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `apellidos` varchar(100) DEFAULT NULL,
  `edad` int(11) NOT NULL,
  `contrasenya` varchar(100) NOT NULL,
  `admin` tinyint(1) DEFAULT 0,
  `foto` blob DEFAULT NULL,
  `descripcion` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nickname` (`nickname`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4;

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para vista joma_jomabb.vistaDeportes
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vistaDeportes` (
	`nombre` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci'
) ENGINE=MyISAM;

-- Volcando estructura para vista joma_jomabb.vistaEquipos
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vistaEquipos` (
	`nombre` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`logo` BLOB NULL
) ENGINE=MyISAM;

-- Volcando estructura para vista joma_jomabb.vistaTorneos
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vistaTorneos` (
	`nombre` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`fecha_inicio` DATE NOT NULL,
	`fecha_inscripcion` DATE NOT NULL
) ENGINE=MyISAM;

-- Volcando estructura para vista joma_jomabb.vistaUsuarios
-- Creando tabla temporal para superar errores de dependencia de VIEW
CREATE TABLE `vistaUsuarios` (
	`nickname` VARCHAR(20) NOT NULL COLLATE 'utf8mb4_general_ci',
	`nombre` VARCHAR(50) NOT NULL COLLATE 'utf8mb4_general_ci',
	`edad` INT(11) NOT NULL,
	`foto` BLOB NULL
) ENGINE=MyISAM;

-- Volcando estructura para tabla joma_jomabb.z_registro
CREATE TABLE IF NOT EXISTS `z_registro` (
  `numero_registro` int(11) NOT NULL AUTO_INCREMENT,
  `id_borrado` int(11) DEFAULT NULL,
  `nick_user_creado` varchar(20) DEFAULT NULL,
  `nick_user_borrado` varchar(20) DEFAULT '',
  `fecha` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`numero_registro`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8 COMMENT='para auditoria';

-- La exportación de datos fue deseleccionada.

-- Volcando estructura para disparador joma_jomabb.auditoria_user_borrar
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `auditoria_user_borrar` AFTER DELETE ON `usuarios` FOR EACH ROW BEGIN
		
		INSERT INTO z_registro(id_borrado, nick_user_borrado, fecha) VALUES (OLD.id, OLD.nickname, CURRENT_TIMESTAMP());

	END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para disparador joma_jomabb.auditoria_user_crear
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER auditoria_user_crear AFTER INSERT ON usuarios
FOR EACH ROW
	BEGIN
		
		INSERT INTO z_registro(id_borrado, nick_user_creado, fecha) VALUES (NEW.id,  NEW.nickname, CURRENT_TIMESTAMP());
	
	END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- Volcando estructura para vista joma_jomabb.vistaDeportes
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vistaDeportes`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vistaDeportes` AS select `deportes`.`nombre` AS `nombre` from `deportes`;

-- Volcando estructura para vista joma_jomabb.vistaEquipos
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vistaEquipos`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vistaEquipos` AS select `equipos`.`nombre` AS `nombre`,`equipos`.`logo` AS `logo` from `equipos`;

-- Volcando estructura para vista joma_jomabb.vistaTorneos
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vistaTorneos`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vistaTorneos` AS select `torneos`.`nombre` AS `nombre`,`torneos`.`fecha_inicio` AS `fecha_inicio`,`torneos`.`fecha_inscripcion` AS `fecha_inscripcion` from `torneos`;

-- Volcando estructura para vista joma_jomabb.vistaUsuarios
-- Eliminando tabla temporal y crear estructura final de VIEW
DROP TABLE IF EXISTS `vistaUsuarios`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `vistaUsuarios` AS select `usuarios`.`nickname` AS `nickname`,`usuarios`.`nombre` AS `nombre`,`usuarios`.`edad` AS `edad`,`usuarios`.`foto` AS `foto` from `usuarios`;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
