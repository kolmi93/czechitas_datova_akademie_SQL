
-- SUBSELECT V SELECTU
-- vytvořte tabulku, kde v 1. sloupci je počet organizací se slovem "islam" v názvu, ve 2 je počet mrtvých za rok 2017 a ve 3. nejvyšší počet mrtvých teroristů
SELECT
(SELECT COUNT(DISTINCT GNAME) FROM TEROR WHERE GNAME ILIKE '%islam%') AS POCET_ORGANIZACI,
(SELECT SUM(NKILL) FROM TEROR WHERE IYEAR = 2017) AS ROK,
(SELECT MAX(NKILLTER) FROM TEROR) AS TERORISTE;


-- SUBSELECT V PODMÍNCE
-- Vypište sloupce město, provincie (provstate), region_txt, počet mrtvých a počet mrtvých teroristů v 5 provinciích s největším počtem sebevražedných útoků.
;
SELECT city, provstate, region_txt, nkill, nkillter
FROM teror
WHERE provstate IN
        (SELECT provstate FROM
            (SELECT provstate, count(eventid) as pocet
            FROM teror
            WHERE suicide = '1'
            GROUP BY provstate
            ORDER BY pocet DESC
            LIMIT 5)
    );

-- SUBSELECT V ČÁSTI FROM
-- Zjistěte, jestli v meziročně klesá nebo roste počet organizací v rámci jednotlivých regionů. K počtu organizací vytvořte sloupec, kde s rozlišení roste/klesá.

select rok_16.region_txt
    , rok_16.org_16
    , rok_17.org_17
    , CASE
          WHEN rok_16.org_16 < rok_17.org_17 THEN 'roste'
          WHEN rok_16.org_16 > rok_17.org_17 THEN 'klesá'
          ELSE 'nelze určit'
        END AS vyvoj
from (
    select region_txt
    , count(distinct gname) as org_16
    from teror
    where iyear = 2016
    group by region_txt
) as rok_16
left join (
    select region_txt
    , count(distinct gname) as org_17
    from teror
    where iyear = 2017
    group by region_txt
) as rok_17
on rok_16.region_txt = rok_17.region_txt;