/*-------------------------
  Partie 1 du TD
--------------------------*/

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
  code numeric(2) primary key,
  nom varchar(30),
  prefecture varchar(50),
  rid char(5),
  foreign key (rid) references regions
);

.separator ','

.import 'dept-files/regions.csv' regions

.import 'dept-files/departements.csv' departements

/* Requête 1 (question 2)*/
.output 'res/req1.txt'
SELECT code, nom
FROM departements
WHERE prefecture = 'Bourges';

/* Requête 2 (question 3)*/
.output 'res/req2.txt'
SELECT code, d.nom, prefecture, r.nom AS region
FROM departements d
JOIN regions r
ON d.rid = r.rid;

/* Requête 3 (question 4)*/
.output 'res/req3.txt'
SELECT r.nom AS region, chefLieu, code, d.nom AS departement, prefecture
FROM regions r
JOIN departements d
ON r.rid = d.rid
ORDER BY r.nom;

/* Requête 4 (question 5)*/
.output 'res/req4.txt'
SELECT code, d.nom, prefecture
FROM departements d
JOIN regions r
ON d.rid = r.rid
WHERE r.nom = 'Centre-Val de Loire';

/* Question 6*/
DROP TABLE IF EXISTS voisins;
CREATE TABLE voisins (
  rid1 char(5),
  rid2 char(5),
  primary key (rid1, rid2),
  foreign key (rid1) references regions,
  foreign key (rid2) references regions
);

.import 'dept-files/voisins.csv' voisins

/* Requête 5 (question 6)*/
.output 'res/req5.txt'
SELECT COUNT(*)
FROM voisins;

/* Requête 6 (question 7)*/
.output 'res/req6.txt'
DROP VIEW IF EXISTS voisinsSym;
CREATE VIEW voisinsSym AS
SELECT rid1, rid2
FROM voisins
UNION
SELECT rid2, rid1
FROM voisins;
SELECT COUNT(*)
FROM voisinsSym;

/* Requête 7 (question 8)*/
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
