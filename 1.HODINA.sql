-- Začneme zde: https://kodim.cz/analyza-dat/da-data-sql/sql
-- Dataset Teror
-- Prostředí Snowflaku
-- A dále pak první lekce:
-- https://kodim.cz/analyza-dat/da-data-sql/sql/vyuka/lekce-01
------------------------------
-- Schemata a role - UI
--editor
--results
--database object (refresh)
--schema, role, database, warehouse
--kazdy worksheet se spusti s defaultnim nastavenim
--infomation schema (tables, columns)
------------------------------
-- Komentar
-- Něco píšu

-- komentar
/*
vice
radkovy
komentar
*/
//ahoj
// dalsi komentar
------------------------------
-- Spuštění příkazu  & první select
-- tlačítko Run
-- control (ctrl) / command (macOS) + enter
-- STŘEDNÍK!
-- vyznacovani query

SELECT 1, '1';   -- vybere 1
SELECT '1'; -- vybere '1'
SELECT 'Ahoj';
SELECT 'Ahoj', 'Dobrý den', 'Nazdárek';
;SELECT "1"; -- nevybere nic
-- ctete pozorne error hlasky!
-- velka / mala pismena ?
------------------------------
-- Kalkulačka?
                          
SELECT 25*30; -- 750
SELECT 25 * 0;  -- 0
SELECT 25/2.5; -- 10.0
SELECT 25/0; -- division by zero
SELECT 1 - 1;
 
------------------------------
-- TABULKA TEROR
------------------------------
-- codebook na kodim.cz / dokumentace od Janci
-- denormalizovana tabulka
------------------------------
-- Všechny sloupce *
SELECT * 
FROM teror; -- vybere vsechny sloupce a radky z tabulky teror
-- select je nedestruktivní, neovlivní zdrojovou tabulku
-- pozor na velke tabulky
--SHOW COLUMNS IN TABLE teror;
------------------------------ 
-- Omezení výběru sloupečku
                          
SELECT nkillter 
FROM teror; -- vybere pouze sloupec nkillter z tabulky teror

SELECT EVENTID 
FROM TEROR;

-- odsazeni, carky na zacatku radky
SELECT
      country_txt
    , iyear
    , city 
FROM teror;
SELECT 
      nkillter
    , iyear 
FROM teror;
                   
-- vycet sloupcu + hvezdicka
SELECT 
      nkillter 
    , iyear
    , *
FROM teror;
                   
-- specialita Snowflaku: EXCLUDE - spicifikace sloupců, které mají být vyřazeny z výsledku
--  jeden sloupec
SELECT * EXCLUDE iyear
FROM teror
;
--  dva sloupce
SELECT * EXCLUDE (iyear, imonth)
FROM teror
;
------------------------------ 
-- DISTINCT
;                          
SELECT DISTINCT country_txt -- udělá výpis hodnot z vybraného sloupce. Pokud se hodnoty opakují, vypíše ho jen jednou, pak je přeskočí
FROM teror; -- vybere unikatni hodnoty ve sloupci country_txt z tabulky teror

SELECT country_txt
FROM teror;

SELECT DISTINCT country_txt ,city
FROM teror;

SELECT DISTINCT country_txt
       ,iyear 
FROM teror; 
------------------------------ 
-- COUNT() - agregacni funkce
                          
SELECT COUNT(*)
FROM teror; -- spocita pocet radku v tabulce teror
SELECT COUNT(country_txt)
FROM teror; -- spocita, kolik zaznamu (ne NULL) je ve sloupci country_txt
SELECT COUNT(DISTINCT country_txt)
FROM teror; -- spocita, kolik unikatnich zaznamu (ne NULL) je ve sloupci country_txt
------------------------------ 
-- SUM() - agregacni funkce
SELECT SUM(nkill) -- secte vsechna cisla ve sloupci
FROM teror;
SELECT
     COUNT(nkill)
    ,SUM(nkill)
FROM teror;
------------------------------ 
-- ORDER BY: DESC, ASC
SELECT nkillter 
FROM teror 
ORDER BY nkillter; -- ASC je defaultní typ serazeni

SELECT nkillter 
FROM teror 
ORDER BY nkillter DESC; -- vypise radky serazene podle sloupce nkillter

SELECT nkillter, country_txt
FROM teror 
ORDER BY country_txt ASC, nkillter DESC;

SELECT nkillter 
FROM teror 
ORDER BY 
nkillter DESC NULLS LAST; 
-- hodnota NULL vs. prázdná hodnota ('')
-- NULLS LAST
------------------------------ 
-- LIMIT
                          
SELECT
* 
FROM teror 
LIMIT 10
; -- vybere 10 radku z tabulky teror
-- serazeni v databazich: ORDER BY
------------------------------
-- chovani NULL
SELECT COUNT(NULL);
SELECT SUM(NULL);
SELECT 3 + NULL;
------------------------------ 
-- UKOLY 1-4
------------------------------ 
//1/ Vyber vše z tabulky teror.
SELECT *
FROM TEROR;
                        
//2/ Zobraz náhodných deset řádek z tabulky teror.
SELECT *
FROM TEROR
LIMIT 10;
                        
//3/ Vypiš jen sloupce EVENTID, IYEAR, COUNTRY_TXT, REGION_TXT.
SELECT EVENTID
    , IYEAR
    , COUNTRY_TXT
    , REGION_TXT
FROM TEROR;
                        
//4/ Vypiš všechny roky vyskytující se v tabulce teror, tak aby byl každý rok ve výsledné tabulce jen jednou.
SELECT DISTINCT IYEAR
FROM TEROR;
                          
------------------------------ 
------------------------------ 
-- 1
SELECT *
FROM teror
;
-- 2
SELECT *
FROM teror
LIMIT 10
;
-- 3
SELECT EVENTID, IYEAR, COUNTRY_TXT, REGION_TXT
FROM teror
;
--4
SELECT DISTINCT iyear
FROM TEROR
;
------------------------------ 
-- ALIAS
-- Přejmenovaní sloupečku
-- idealni nazvy sloupecku v sql: kratke, misto mezer podtrzitka, bez diakritiky
SELECT nkillter 
FROM teror ;
SELECT nkillter AS zabito_teroristu 
FROM teror 
LIMIT 100; -- prejmenuje sloupecek nkillter na ZABITO_TERORISTU
SELECT nkillter AS "zabito teroristu" 
FROM teror 
LIMIT 100; -- prejmenuje sloupecek nkillter na zabito_teroristu
SELECT nkillter AS "Zabito teroristů" 
FROM teror 
LIMIT 100;
SELECT nkillter AS zabito_teroristu,
       country_txt
FROM teror
LIMIT 100;
-- sloupecky vytvorene pomoci funkce (a dalsi transformace dat)
SELECT COUNT(*)
FROM teror; -- spocita pocet radku v tabulce teror
                      
------------------------------ 
-- Vybrání vlastní hodnoty do sloupečku: nový sloupeček, sloupeček existující v tabulce
                          
SELECT country_txt, 
       'Indonésie' AS region_txt
       ,NKILLTER
FROM teror;
SELECT 'Indonésie' AS reg_text,
       * 
FROM teror;
                        
                        
                        
                        
                        
                        
------------------------------ 
-- Spojení sloupečků
-- Pravý ALT a W napíší |
                          
SELECT city || country_txt 
FROM teror ;
select city || ', ' || country_txt as "city_country"
from teror;
select nkill, nkillter, nkill-nkillter AS POCET_MRTVYCH
from teror;
SELECT CONCAT(city,', ',country_txt) 
FROM teror 
LIMIT 100;
                        
------------------------------ 
-- Násobení sloupečků
                          
SELECT nkill, 
       nwound, 
       nkill * nwound 
FROM teror 
LIMIT 100;
                        
------------------------------ 
-- Filtrovaní radku
                          
SELECT nkillter, *
FROM teror 
WHERE nkillter > 100; -- vybere vsechny radky, kde je nkillter vetsi jak 100
SELECT 
        nkillter 
       ,nkillter 
       ,nkillter 
       ,imonth
       ,resolution
       ,* 
FROM teror 
WHERE nkillter > 100;
------------------------------ 
-- UKOLY 5-9
------------------------------ 
//5/ Vyber všechny teroristické útoky v roce 2016.
SELECT *
FROM TEROR
WHERE IYEAR = 2016;

//6/ Vypiš všechny útoky za rok 2015 a vyber pouze sloupce EVENTID, IYEAR, COUNTRY_TXT, REGION_TXT a přejmenuj je na UDALOST, ROK, ZEME, REGION.
SELECT
    EVENTID AS UDALOST
    , IYEAR AS ROK
    , COUNTRY_TXT AS ZEME
    , REGION_TXT AS REGION
FROM TEROR
WHERE ROK = 2015;
                        
//7/ Vyber všechny události v roce 2014 a vyber pouze sloupce IYEAR, IMONTH A IDAY. Spoj je do jednoho sloupce oddělené pomlčkou a pojmenuj ho DATUM.
SELECT
    IYEAR || "-" || IMONTH || "-" || IDAY AS DATUM
FROM TEROR
WHERE IYEAR = 2014;
                        
//8/ Seřaď datum z předchozího selektu sestupně (desc) a vypiš jen jedinečné záznamy.
SELECT
     DISTINCT (IYEAR || "-" || IMONTH || "-" || IDAY AS DATUM)
FROM TEROR
WHERE IYEAR = 2014
ORDER BY DESC;
                          
//9/ Vypiš počet teroristických útoků, které se staly po roce 2015 (15138).
-- 5
SELECT *
FROM teror
WHERE iyear = 2016
;
-- 6
SELECT EVENTID AS UDALOST, IYEAR AS ROK, COUNTRY_TXT AS ZEME, REGION_TXT AS REGION
FROM teror
WHERE iyear = 2015
;
------------------------------ 
------------------------------ 
/* 
------------------------------------------------
DATOVÉ TYPY
------------------------------------------------
- datové typy specifikují, jaký druh dat se ukládá a jaké funkce lze vyvolat. Každé pole v databázi má přiřazený datový typ.
- odkaz na rozcestník datových typů ve Snowflaku: https://docs.snowflake.com/en/sql-reference/intro-summary-data-types.html
--> VARCHAR - řetězec libovolných znaků o různé délce
    - tento datový typ zachází se vším jako s textem, ale může obsahovat i číslice a speciální znaky
    - VARCHAR (defaultní a zároveň maximální velikost 16 777 216 bytů), STRING, TEXT, CHAR, CHARACTER, BINARY, VARBINARY
    - jejich spojením byste je pouze připojili za sebe, což byste očekávali od textu, nespojujte je plusem, ale znaky || nebo funkcí CONCAT
    - 'a' || 'b' --> 'ab'
    - '1' || '2' --> '12'
    - '1' || 'b' --> '1b'
    - odkaz na datový typ string v dokumentaci Snowflaku: https://docs.snowflake.com/en/sql-reference/data-types-text.html#data-types-for-text-strings
    - přehled funkcí pro tento datový typ v dokumentaci Snowflaku: https://docs.snowflake.com/en/sql-reference/functions-string.html
--> NUMBER - celá nebo desetinná čísla (desetinná čísla mají ve Snowflaku desetinnou TEČKU)
    - zafixované desetinné místo (Fixed-point numbers): NUMBER, DECIMAL, NUMERIC, INT, INTEGER, BIGINT, SMALLINT, TINYINT, BYTEINT
    - pohyblivé desetinné místo (Floating-point numbers): FLOAT, FLOAT4, FLOAT8, DOUBLE, DOUBLE PRECISION, REAL
    - Snowflake podporuje pro float také hodnoty 'NaN' (Not a Number), 'inf' (infinity/nekonečno), '-inf' (negative infinity/mínus nekonečno)
    - 1 + 2 --> 3
    - 1.1 + 2.2 --> 3.3
    - odkaz na datový typ numeric v dokumentaci Snowflaku: https://docs.snowflake.com/en/sql-reference/data-types-numeric.html
--> BOOLEAN - logický datový typ, nabývá jen dvou hodnot: True, nebo False
    - hodí se pro binární charakteristiky nebo status
    - přihlásil se někdo k útoku? - Ano/True, Ne/False
    - na boolean můžeme převést textové a numerické hodnoty použitím funkce CAST nebo TO_BOOLEAN
      - převod ze stringu na TRUE: 'true', 't', 'yes', 'y', 'on', '1'
      - převod ze stringu na FALSE: 'false', 'f', 'no', 'n', 'off', '0'
      - převod je case-insensitive (nerozlišuje malá a velká písmena), jakékoli jiné hodnoty stringu nebudou převedeny
      --------------------------------------------------------------------
      - převod čísla na FALSE: 0 (nula)
      - převod čísla na TRUE: jakákoli jiná nenulová číselná hodnota bude převedena na TRUE
--> DATE - hodnota datum(+čas)
    - tento datový typ obsahuje o datum a/nebo čas, což umožňuje používat kalkulace, které jsou relevatní k datumu/času
    - DATE, DATETIME, TIME, TIMESTAMP, TIMESTAMP_LTZ, TIMESTAMP_NTZ, TIMESTAMP_TZ
    - např. kolik dní uběhlo od útoku?
    - odkaz na datový typ DATE v dokumentaci Snowflaku: https://docs.snowflake.com/en/sql-reference/data-types-datetime.html
    - přehled funkcí pro tento datový typ v dokumentaci Snowflaku: https://docs.snowflake.com/en/sql-reference/functions-date-time.html
--> NULL - znamená chybějící hodnotu v poli
    - tento datový typ je vhodný pro zobrazení absence dat
    - prázdná buňka a NULL jsou rozdílné, vizuálně prázdná buňka může obsahovat prázdný string '' nebo whitespace 
        (mezera, nezlomitelná mezera, tabulátor, konec stránky, ...), což může být obtížné detekovat
    - agregační funkce zpravidla NULL ignorují (např. COUNT, SUM), pro detaily zkontrolujte dokumentaci vámi vybrané funkce
    - chování NULL ve Snowflaku shrnuto příspěvkem na Snowflake community: https://community.snowflake.com/s/article/NULL-handling-in-Snowflake
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DALŠÍ DATOVÉ TYPY
--> GEOSPATIAL - Snowflake nabízí podporu pro prostorová data jako jsou body, linie a plochy na Zemi (points, lines, and polygons)
    - odkaz na Snowflake dokumentaci o tomto datovém typu: https://docs.snowflake.com/en/sql-reference/data-types-geospatial.html
--> SEMI-STRUCTURED DATA TYPES - Snowflake podporuje semi-strukturované datové typy
    - VARIANT, OBJECT, ARRAY
    - použití například při importu dat ze souboru JSON, XML
    - odkaz na Snowflake dokumentaci o těchto datových typech: https://docs.snowflake.com/en/sql-reference/data-types-semistructured.html
*/