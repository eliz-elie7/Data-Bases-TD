/*-------------------------
  Partie 1 du TD
  Binôme : El Hadji Oumar Hanne & Eliezer Mahugnon DJIHINTO
--------------------------*/

/* Question 1)*/
.mode box
PRAGMA foreign_keys = on;

DROP TABLE IF EXISTS regions;
DROP TABLE IF EXISTS departements;


CREATE TABLE regions (
  rid char(5) primary key,
  nom varchar(50),
  chefLieu varchar(30)
);

CREATE TABLE departements (
  code varchar(3) primary key,
  nom varchar(50) UNIQUE,
  prefecture varchar(50),
  rid char(5),
  foreign key (rid) references regions
);

.separator ','

.import 'dept-files/regions.csv' regions

.import 'dept-files/departements.csv' departements

/* Question 2)*/
.output 'res/req1.txt'
SELECT code, nom
FROM departements
WHERE prefecture = 'Bourges';

/* Question 3)*/
.output 'res/req2.txt'
SELECT code, d.nom, prefecture, r.nom AS region
FROM departements d
JOIN regions r
ON d.rid = r.rid;

/* Question 4)*/
.output 'res/req3.txt'
SELECT r.nom AS region, chefLieu, code, d.nom AS departement, prefecture
FROM regions r
JOIN departements d
ON r.rid = d.rid
ORDER BY r.nom;

/* Question 5)*/
.output 'res/req4.txt'
SELECT code, d.nom, prefecture
FROM departements d
JOIN regions r
ON d.rid = r.rid
WHERE r.nom = 'Centre-Val de Loire';

/* Question 6)*/
DROP TABLE IF EXISTS voisins;
CREATE TABLE voisins (
  rid1 char(5),
  rid2 char(5),
  primary key (rid1, rid2),
  foreign key (rid1) references regions,
  foreign key (rid2) references regions
);

.import 'dept-files/voisins.csv' voisins

/* Requête */
.output 'res/req5.txt'
SELECT COUNT(*)
FROM voisins;

/* Question 7)*/
.output 'res/req6.txt'
DROP VIEW IF EXISTS voisinsSym;
CREATE VIEW voisinsSym AS
SELECT rid1, rid2
FROM voisins
UNION
SELECT rid2, rid1
FROM voisins;
SELECT COUNT(*) AS nbVoisinsSym
FROM voisinsSym;

/* Question 8)*/
.output 'res/req7.txt'
DROP VIEW IF EXISTS voisinsSymNoms;
CREATE VIEW voisinsSymNoms AS
SELECT r1.nom AS region, r2.nom AS voisines
FROM voisinsSym v, regions r1, regions r2
WHERE v.rid1 = r1.rid AND v.rid2 = r2.rid;
SELECT r.nom, COUNT(vs.voisines) AS nbVoisins
FROM  regions r
LEFT JOIN voisinsSymNoms vs ON r.nom = vs.region
GROUP BY r.nom
ORDER BY nbVoisins DESC;

/* Question 9*/
DROP TABLE IF EXISTS zus;
CREATE TABLE zus (
  departement varchar(50),
  commune varchar(50),
  quartier varchar(50),
  primary key (departement, commune, quartier),
  foreign key (departement) references departements(nom)
);

.separator ';'

.import 'dept-files/zus.csv' zus

/* Question 10)*/
.output 'res/req8.txt'
SELECT *
FROM zus
WHERE commune LIKE '%(%)%';

/* Question 11)*/
.output 'res/req9.txt'
DROP VIEW IF EXISTS ZusComPrefDep;
CREATE VIEW ZusComPrefDep AS
SELECT *
FROM zus z
JOIN departements d ON z.departement = d.nom
WHERE z.commune = d.prefecture;
SELECT
(SELECT COUNT(*) FROM Zus) AS Total,
(SELECT COUNT(*) FROM ZusComPrefDep) AS nbZusComInPref,
(SELECT COUNT(*) FROM Zus) - (SELECT COUNT(*) FROM ZusComPrefDep) AS nbZUSNotInPref;

/* Question 12)*/
.output 'res/req10.txt'
SELECT d.nom AS departement, r.nom AS region, COUNT(z.departement) AS nbZus
FROM departements d
LEFT JOIN regions r ON d.rid = r.rid
LEFT JOIN zus z ON d.nom = z.departement
GROUP BY d.nom
ORDER BY nbZus DESC;

/* Question 13)*/
.output 'res/req11.txt'
SELECT r.nom AS region, COUNT(z.departement) AS nbZus
FROM regions r
LEFT JOIN departements d ON r.rid = d.rid
LEFT JOIN zus z ON d.nom = z.departement
GROUP BY r.nom
ORDER BY nbZus DESC;

/* Question 14 - version 1)*/
.output 'res/req12.txt'
SELECT r.nom AS region
FROM regions r
WHERE NOT EXISTS(
  SELECT *
  FROM departements d
  WHERE d.rid = r.rid AND NOT EXISTS(
    SELECT *
    FROM zus z
    WHERE z.departement = d.nom
  )
);

/* Question 14 - version 2)*/
.output 'res/req13.txt'
SELECT r.nom AS region
FROM regions r
JOIN departements d ON r.rid = d.rid
JOIN zus z ON d.nom = z.departement
GROUP BY r.nom
HAVING COUNT(DISTINCT d.nom) = (
  SELECT COUNT(*)
  FROM departements d2
  WHERE d2.rid = r.rid);