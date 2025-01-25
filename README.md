###### <p align="center"> DbiUebung-006 </p>

# <p align="center"> Indizes & Laufzeitkomplexität </p>


- # 1.<sub>)</sub> 
  ## *<p align="center"> Folgende Abfragen sollen beschleunigt werden. </p>*
    > *Erstellen Sie - für jede Abfrage einzeln betrachtet - einen oder mehrere Index/izes, so dass jede Abfrage für sich bestmöglich abgearbeitet werden kann.*

  - ## a <sub>)</sub> 
    > ## `SELECT * FROM emp WHERE ENAME =: some_name;`
    ```SQL
        CREATE INDEX emp_ename ON emp(ename);
    ```
        
  <br>

  - ## b <sub>)</sub> 
    > ###  `SELECT * FROM emp WHERE job=:sel_job AND sal > :min_sal ORDER BY hiredate DESC;` 
    ```SQL
        CREATE INDEX idx_emp_job_sal_hiredate ON emp(job, sal, hiredate   DESC);
    ```		

  <br>
        
  - ## c <sub>)</sub> 
    > ## `SELECT * FROM emp WHERE (ROUND(sal/1000)*1000) = 2000;`  
      - > ( alle Mitarbeiter, deren Verdienst auf ganze Tausender gerundet  2000 beträgt )  
      - > `(ROUND(sal/1000)*1000)` verhindert die direkte Verwendung eines  einfachen Index auf `sal`.  
      - **Function based Index** :
      
      ```SQL
          CREATE INDEX emp_rd_sal_idx ON emp(ROUND(sal / 1000) * 1000);
      ```
  <br>
    
---

<br>

  - # 2.<sub>)</sub> 
    ## *<p align="center">Welche Zugriffsarten werden für folgende Queries verwendet?</p>* 
      ### <sub><p align="center">( begründen Sie )</p></sub><br>  

      > *Gehen Sie davon aus, dass die abgefragten Tabellen eine große Zahl von Zeilen enthalten und dass die gegebenen Indexe nur für den jeweiligen Unterpunkt der Aufgabe existieren.*  
      > 
      > <p align="right">( DDL/DML zu Tabelle inventories siehe DataWarehouse.zip )</p>

    - ## a <sub>)</sub> 
      > ## ` SELECT COUNT(*) FROM table; `
  
      - ### i <sub>)</sub>   
        ## *Ohne Primary-Key, ohne Index* :	  
        - ### `FULL TABLE SCAN`
	    > ***Dies ist die langsamste Methode, insbesondere bei großen Tabellen.*** 
      
      <br>

      - ### ii <sub>)</sub>   
        ## *Ohne Primary-Key, beliebiger Index* :
        - Da im Index ***keine `NULL`-Werte enthalten*** sind muss entweder die Query 
          > *zB:* ( ..`WHERE xyz IS NOT NULL, WHERE xyz > 10`.. ) - **`NULL`-Werte ausschließen**,  
        
          oder die indizierte Spalte **`NOT NULL`** sein.  
        - Sonst **kann der Index nicht verwendet werden**, da eventuelle `NULL`-Werte übersehen würden. 
          
        <br>

      - ### iii <sub>)</sub>   
        ## *Ohne Primary-Key, beliebiger `NOT NULL` Index* :  
  		  - ###  `FULL INDEX SCAN`

        <br>

      - ### iv <sub>)</sub>  
        ## *Mit Primary Key*  
  		  - ###  `FULL INDEX SCAN`

        <br>
 
    	---

    <br>

    - ## b <sub>)</sub>
      > ```SQL
      >   CREATE INDEX inventories_product_idx ON inventories(product_id);
      >   SELECT SUM(quantity) FROM inventories WHERE product_id = 210;
      > ```
      	> - ### `INDEX RANGE SCAN` + `TABLE ACCESS BY ROWID`  
	> - ( da quantity nicht im Index enthalten ist )

    <br>

    - ## c <sub>)</sub>
      > ```SQL
      >   CREATE INDEX inventories_quantity_idx ON inventories(quantity);
      >   CREATE INDEX inventories_product_idx ON inventories(product_id);
      >   SELECT SUM(quantity) FROM inventories WHERE product_id = 210;
      > ```
        > - ### `INDEX RANGE SCAN` + `TABLE ACCESS BY ROWID`  
      	> - ***wie b.)***   
      	> - ( der zusätzliche Index auf quantity kann nicht benützt werden )  

    <br>

    - ## d <sub>)</sub>
      > ```SQL
      >   CREATE INDEX inventories_prod_quant_idx ON inventories(product_id, quantity);
      >   SELECT SUM(quantity) FROM inventories WHERE product_id = 210;
      > ```
        > - ### `INDEX RANGE SCAN`
      	> - ( Da sämtliche Daten im Index enthalten sind ***entfällt der Table Access By Rowid*** )

    <br>

    - ## e <sub>)</sub>
      > ```SQL
      >   CREATE INDEX inventories_quant_prod_idx ON inventories(warehouse_id, product_id);
      >   SELECT COUNT(product_id) FROM inventories WHERE product_id = 210;
      > ```
        > - ### *Entweder* `FAST FULL SCAN` *oder* `SKIP SCAN`.

  <br>
    
---
<br>

- # 3.<sub>)</sub> 
    ## *<p align="center"> Welcher Komplexitätsklasse gehörden folgende Operationen an: </p>*

  - ## a <sub>)</sub> 
      ### `SELECT * FROM emp WHERE sal > 1000;` 
      *<p align="center"> ( ohne index ) </p>*

    - Das Datenbanksystem muss die gesamte Tabelle durchsuchen, um Zeilen mit sal > 1000 zu finden.

    	- $\Large\color{lime}{ O }\large{(\ n\ )}$ 
	      > Lineare Zeitkomplexität

  <br>
		 
  - ## b <sub>)</sub> 
      ### `SELECT ename FROM emp ORDER BY ename;` 
      *<p align="center"> ( kein Index ) </p>*  

	- Das Datenbanksystem muss alle Zeilen basierend auf der Spalte ename sortieren.

      - $\Large\color{greenyellow}{ O }\large{(\ n\ log\ n\ )}$ 
	      > Sortieralgorithmen haben typischerweise diese Komplexität

  <br>
		
  - ## c <sub>)</sub> 
      #### `SELECT e.ename, e.sal, (SELECT COUNT(*) FROM emp e2 WHERE e2.sal < e.sal) FROM emp e;`  
      >
     *<p align="center"> ( ohne index auf `sal` ) </p>*

    - Für jede Zeile in der äußeren Abfrage muss die innere Abfrage die gesamte Tabelle durchsuchen, um Zeilen mit einem niedrigeren Gehalt zu zählen.
		
        - $\Large\color{goldenrod}{ O }\large{(\ n^2\ )}$  
    	  > Quadratische Zeitkomplexität, da die innere Abfrage für jede Zeile der äußeren Abfrage ausgeführt wird

  <br><br>

  ---

  <br><br>

  > ## ***Spezialfall***
  >		
  >   - ## d <sub>)</sub> 
  >     #### `SELECT e.ename, e.sal, ( SELECT COUNT(*) FROM emp e2 WHERE e2.sal < e.sal ) FROM emp > e;`  
  >     *<p align="center"> ( mit index auf `sal` ) </p>*
  > 		
  >     - Die innere Abfrage kann mithilfe des Index effizient die Anzahl der Zeilen mit > einem niedrigeren Gehalt ermitteln.  
  > 		
  >       - $\Large\color{goldenrod}{ O }\large{(\ n^2\ )}$
  >         > dominierende Faktor ist die Sortierung der Ergebnisse der äußeren Abfrage

---  
