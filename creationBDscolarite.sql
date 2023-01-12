-- -----------------------------------------------------------------------------
--             Génération d'une base de données pour
--                           PostgreSQL
--                        (17/11/2013 )
-- -----------------------------------------------------------------------------
--      Nom de la base : gestion_scolarite
--      Auteur : Elyes Lamine
--      Date de dernière modification : 17/10/2013 6:35:30
-- -----------------------------------------------------------------------------
-- Ce fichier contient le script destiné à créer la base de données "commandes".
-- Ce script doit être exécuté en tant qu'utilisateur "postgres".
\c postgres
\echo [INFO] Debut du script
\echo [INFO] Suppression de la base de donnees
DROP DATABASE IF EXISTS gestion_scolarite;

\echo [INFO] Creation de la base de donnees
CREATE DATABASE gestion_scolarite ENCODING 'UTF8';

\echo [INFO] Connexion a la nouvelle base de donnees
\c gestion_scolarite


\echo [INFO] Creation de la table client


-- Suppression des relations si elles sont deja créées 
-- L'ordre de suppression des relations doit être respecté 
-- pour ne pas violer les contraintes d'intégrité réferentielles
DROP TABLE IF EXISTS Reservation;
DROP TABLE IF EXISTS Salle;
DROP TABLE IF EXISTS Enseignement;
DROP TABLE IF EXISTS Enseignant;
DROP TABLE IF EXISTS Departement;

-- Script de création des relations

\echo [INFO] Creation de la table Departement
CREATE TABLE Departement
(
 Departement_id     SERIAL,
 Nom_Departement   varchar(25) NOT NULL,
 CONSTRAINT UN_Nom_Departement UNIQUE (nom_departement),
 CONSTRAINT PK_Departement PRIMARY KEY(Departement_ID)
);
 
\echo [INFO] Creation de la table Enseignement

CREATE TABLE Enseignement
( 
  Enseignement_ID  int4 NOT NULL,
  Departement_ID   int4 NOT NULL,
  Intitule         varchar(60) NOT NULL,
  Description      varchar(1000),
  CONSTRAINT PK_Enseignement PRIMARY KEY (Enseignement_ID, Departement_ID),
  CONSTRAINT PK_Enseignement_Departement FOREIGN KEY (Departement_ID) REFERENCES Departement (Departement_ID) ON UPDATE RESTRICT ON DELETE RESTRICT
) ;


\echo [INFO] Creation de la table Enseignant
CREATE TABLE Enseignant
(
 Enseignant_ID     integer,
 Departement_ID    integer NOT NULL,
 Nom        	   varchar(25) NOT NULL,
 Prenom            varchar(25) NOT NULL,
 Grade             varchar(25) 
 CONSTRAINT CK_Enseignant_Grade
 CHECK (Grade IN ('Vacataire', 'PRAG','ATER', 'MCF', 'PROF')),
 Telephone         varchar(10) DEFAULT NULL,
 Fax               varchar(10) DEFAULT NULL,
 Email             varchar(100) DEFAULT NULL,
 CONSTRAINT PK_Enseignant PRIMARY KEY (Enseignant_ID),
 CONSTRAINT FK_Enseignant_Departement_ID FOREIGN KEY (Departement_ID) REFERENCES Departement (Departement_ID) ON UPDATE RESTRICT ON DELETE RESTRICT
);

\echo [INFO] Creation de la table Salle
CREATE TABLE Salle
(
 Batiment     	varchar(1),
 Numero_Salle   varchar(10),
 Capacite  	integer CHECK (Capacite >1),
 CONSTRAINT PK_Salle PRIMARY KEY (Batiment, Numero_Salle)
);


\echo [INFO] Creation de la table Reservation
CREATE TABLE Reservation
(
 Reservation_ID     integer,
 Batiment           varchar(1) NOT NULL,
 Numero_Salle       varchar(10) NOT NULL,
 Enseignement_ID    integer NOT NULL,
 Departement_ID     integer NOT NULL,
 Enseignant_ID      integer NOT NULL, 
 Date_Resa          date NOT NULL DEFAULT CURRENT_DATE,
 Heure_Debut	    time NOT NULL DEFAULT CURRENT_TIME,
 Heure_Fin	    time NOT NULL DEFAULT '23:00:00',
 Nombre_Heures	    integer NOT NULL,
 CONSTRAINT PK_Reservation PRIMARY KEY (Reservation_ID),
 CONSTRAINT FK_Reservation_Salle FOREIGN KEY (Batiment,Numero_Salle) REFERENCES Salle (Batiment,Numero_Salle) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT FK_Reservation_Enseignement FOREIGN KEY (Enseignement_ID,Departement_ID) REFERENCES Enseignement (Enseignement_ID,Departement_ID) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT FK_Reservation_Enseignant FOREIGN KEY (Enseignant_ID) REFERENCES Enseignant (Enseignant_ID) ON UPDATE RESTRICT ON DELETE RESTRICT,
 CONSTRAINT CK_Reservation_Nombre_Heures CHECK (Nombre_Heures >=1),
 CONSTRAINT CK_Reservation_HeureDebFin CHECK (Heure_Debut < Heure_Fin)
);
