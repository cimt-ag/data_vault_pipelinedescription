# Partition deletion detection catalog

Deletion detection by comparing data vault against the source data might become very expensive for large datasets or even impossible, when the source only delivers partitions of its data.

Partitioned deletion detection will still provide a way store a correct image of the delivered data in such cases.

The basic requirements for using a partitioned deletion detection are:
- partitions are identified by values in fields, that are stored in the data vault model
- the incoming extract of data contains all rows for all partitions, that are touched by the extract (or in pseudo sql language: The extract has always a complete set of rows for all values for SELECT DISTICT partitioning columns FROM extract)

The procedure for a single satellite is as follows:
- select all active "keys" from the satellite that belong to the partition (partitioning columns in the vault contain the values of the distict partitioning values in the stage)
- create deletion records for all "keys", that are missing in the stage
- apply enddating (when used)

Selecting all active keys that belong to the partition can be a complex taskt, depending on the distribution of the partitioning columns in the data vault model.
The following picture provides the 






Sofern ein vollständiger Datenbestand oder klar abgegrenzter Teildatenbestand im Stage vorliegt, kann eine Löscherkennung während der Load Phase in die Beladung der Satelliten integriert werden.  Für die Pipeline muss dazu angegeben werden, für welche Tabellen eine Löscherkennung vorzunehmen ist. 

Der Vollständigkeitsabgleich kann auf einen Teilbereich der Daten im Vault beschränkt werden, sofern sich diese über das Filtern von einzelnen Spalten (Partitioning Columns) abgrenzen lassen.

Solange alle Beteiligten über eine direkte “Elternschaft” verbunden sind, genügt für die Beschreibung der Kriterien die Angabe der Felder. Für komplexere Beziehungsgeflechte muss der Join Pfad in der DVPD vorgegeben. Eine Ableitung aus der Struktur ist nicht immer eindeutig möglich und würde beliebig komplex werden. Die Ersparnis bei der Deklaration wiegt in keinem Fall den Aufwand auf, der bei einem nicht abgedeckten Szenario oder eine fehlerhaften Ableitungslogik auftreten würde.

Die folgende Grafik veranschaulicht die abzudeckenden Fälle. Die Szenarien 2-5 basieren auf direkter “Elternschaft”. Die Szenarien XL1 und XL2 sind Beispiele für die weitergehenden Möglichkeiten.