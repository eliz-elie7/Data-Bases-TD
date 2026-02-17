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
.output req1.txt
SELECT code, nom
FROM departements
WHERE prefecture = 'Bourges';

/* Requête 2 (question 3)*/
.output req2.txt
SELECT code, d.nom, prefecture, r.nom AS region
FROM departements d
JOIN regions r
ON d.rid = r.rid;

/* Requête 3 (question 4)*/
.output req3.txt
SELECT r.nom AS region, chefLieu, code, d.nom AS departement, prefecture
FROM regions r
JOIN departements d
ON r.rid = d.rid
ORDER BY r.nom;

/* Requête 4 (question 5)*/
.output req4.txt
SELECT code, d.nom, prefecture
FROM departements d
JOIN regions r
ON d.rid = r.rid
WHERE r.nom = 'Centre-Val de Loire';
