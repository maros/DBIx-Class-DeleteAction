BEGIN TRANSACTION;

DROP TABLE IF EXISTS test1_a;
DROP TABLE IF EXISTS test1_b;

CREATE TABLE test1_a (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    b integer
);

CREATE TABLE test1_b (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
);

DROP TABLE IF EXISTS test2_a;
DROP TABLE IF EXISTS test2_b;
DROP TABLE IF EXISTS test2_c;
DROP TABLE IF EXISTS test2_d;

CREATE TABLE test2_a (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    b integer
);

CREATE TABLE test2_b (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    c integer
);

CREATE TABLE test2_c (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
);

CREATE TABLE test2_d (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    c integer
);

DROP TABLE IF EXISTS test3_a;

CREATE TABLE test3_a (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    a integer
);

DROP TABLE IF EXISTS test4_a;

CREATE TABLE test4_a (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    a integer
);

COMMIT;
