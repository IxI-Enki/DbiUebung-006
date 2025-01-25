---                                          RITT JAN                                            ---

-- 1.) Folgende Abfragen sollen beschleunigt werden.
--       Erstellen Sie - für jede Abfrage einzeln betrachtet - einen oder mehrere Index/izes, 
--       so dass jede Abfrage für sich bestmöglich abgearbeitet werden kann.

  -- a) SELECT * FROM emp WHERE ENAME=:some_name;
        CREATE INDEX emp_ename ON emp(ename);

  -- b) SELECT * FROM emp WHERE job=:sel_job AND sal > :min_sal ORDER BY hiredate DESC; 
        CREATE INDEX idx_emp_job_sal_hiredate ON emp(job, sal, hiredate DESC);
		
  -- c) SELECT * FROM emp WHERE (ROUND(sal/1000)*1000) = 2000; ( alle Mitarbeiter, deren Verdienst auf ganze Tausender gerundet 2000 beträgt )
		(ROUND(sal/1000)*1000) verhindert die direkte Verwendung eines einfachen Index auf sal.
		Und die Spalte sal ist bereits indexiert, wir könnten stattdessen:
	  	  ALTER TABLE emp ADD rounded_sal AS (ROUND(sal/1000)*1000);
		  CREATE INDEX idx_emp_rounded_sal ON emp(rounded_sal);
		  SELECT * FROM emp WHERE rounded_sal = 2000; 
		

---

-- 2.) Welche Zugriffsarten werden für folgende Queries verwendet und begründen Sie.
--       Gehen Sie davon aus, dass die abgefragten Tabellen eine große Zahl von Zeilen enthalten 
--       und dass die gegebenen Indexe nur für den jeweiligen Unterpunkt der Aufgabe existieren.
--       ( DDL/DML zu Tabelle inventories siehe DataWarehouse.zip )

  -- a)
    -- SELECT COUNT(*) FROM table; 
      -- i)   ohne Primary-Key, ohne Index
		Table Access - table - Full
	    Vollständiger Tabellenscan: 
		  Da es keinen Index gibt, muss die Datenbank jede Zeile der Tabelle sequenziell durchlaufen, um die Anzahl der Zeilen zu bestimmen. 
		  Dies ist die langsamste Methode, insbesondere bei großen Tabellen.
      -- ii)  ohne Primary-Key, irgendeinem beliebigen Index
		Index - beliebiger_Index - Full Scan ... wenn der "beliebige Index" auf einer Spalte liegt, die schon NOT NULL als constraint hat, sonst:
		Table Access - table - Full
		Vollständiger Tabellenscan: 
		  Auch wenn ein Index existiert, wird dieser für diese spezifische Abfrage nicht genutzt. 
		  Die Existenz eines Indexes optimiert in der Regel nur Abfragen, die Bedingungen auf den indizierten Spalten enthalten (z.B. WHERE-Klauseln). 
		  Da hier keine Bedingung angegeben ist, wird die gesamte Tabelle durchlaufen.
      -- iii) ohne Primary-Key, irgendeinem beliebigen NOT NULL Index
	    Index - beliebiger_Index - Full Scan ... wenn der "beliebige Index" auf einer Spalte liegt, die keine NULL Zeilen enthalten, sonst:
	    Table Access - table - Full
		Vollständiger Tabellenscan: 
		  Auch ein Index auf einer NOT NULL-Spalte ändert nichts an der Tatsache, dass für die Zählung aller Zeilen ein vollständiger Tabellenscan erforderlich ist.
      -- iv)  mit Primary Key
		Index - Primary_Key - Full Scan 
		Vollständiger Tabellenscan (in den meisten Fällen): 
		  Auch wenn ein Primary Key vorhanden ist, wird in der Regel ein vollständiger Tabellenscan durchgeführt. 
		  Der Grund liegt darin, dass die meisten Datenbank-Systeme keine separate Zählung für die Anzahl der Zeilen in einer Tabelle führen. 
		  Um die genaue Anzahl zu bestimmen, muss die Tabelle durchlaufen werden.
 
				

  -- b)
    -- CREATE INDEX inventories_product_idx ON inventories(product_id);
    -- SELECT SUM(quantity) FROM inventories WHERE product_id = 210;
       Table Access inventories FULL

  -- c)
    -- CREATE INDEX inventories_quantity_idx ON inventories(quantity);
    -- CREATE INDEX inventories_product_idx ON inventories(product_id);
    -- SELECT SUM(quantity) FROM inventories WHERE product_id = 210;
       Table Access inventories FULL

  -- d)
    -- CREATE INDEX inventories_prod_quant_idx ON inventories(product_id, quantity);
    -- SELECT SUM(quantity) FROM inventories WHERE product_id = 210;
       Index inventories_prod_quant_idx RANGE SCAN

  -- e)
    -- CREATE INDEX inventories_quant_prod_idx ON inventories(warehouse_id, product_id);
    -- SELECT COUNT(product_id) FROM inventories WHERE product_id = 210;
       Index inventories_quant_prod_idx FAST FULL SCAN

---

-- 3.) Welcher Komplexitätsklasse gehörden folgende Operationen an:
  -- a) SELECT * FROM emp WHERE sal > 1000; (ohne index)
		Das Datenbanksystem muss die gesamte Tabelle durchsuchen, um Zeilen mit sal > 1000 zu finden.
		 O(n) - Lineare Zeitkomplexität
		 
  -- b) SELECT ename FROM emp ORDER BY ename; (kein Index)
		Das Datenbanksystem muss alle Zeilen basierend auf der Spalte ename sortieren.
		O(n log n) - Sortieralgorithmen haben typischerweise diese Komplexität
		
  -- c) SELECT e.ename, e.sal, (SELECT COUNT(*) FROM emp e2 WHERE e2.sal < e.sal) FROM emp e; (ohne index auf sal)
		Für jede Zeile in der äußeren Abfrage muss die innere Abfrage die gesamte Tabelle durchsuchen, um Zeilen mit einem niedrigeren Gehalt zu zählen.
		O(n^2) - Quadratische Zeitkomplexität, da die innere Abfrage für jede Zeile der äußeren Abfrage ausgeführt wird
		
  -- d) SELECT e.ename, e.sal, (SELECT COUNT(*) FROM emp e2 WHERE e2.sal < e.sal) FROM emp e; (mit index auf sal)
		Die innere Abfrage kann mithilfe des Index effizient die Anzahl der Zeilen mit einem niedrigeren Gehalt ermitteln.
		O(n log n) - Der dominierende Faktor ist die Sortierung der Ergebnisse der äußeren Abfrage
---  