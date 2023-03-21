# Partition deletion detection catalog

Deletion detection by comparing data vault against the complate source data might become very expensive for large datasets or is even impossible, when the source only delivers partitions of its data on the interface.

In such cases a partitioned deletion detection will provide a way store a correct image of the source data .

The basic requirements for using a partitioned deletion detection are:
- partitions are identified by values in fields, that are stored in the data vault model
- the incoming increment of data contains all rows for all partitions, that are mentioned in the increment (or in pseudo sql language: The increment has always a complete set of rows for all values for SELECT DISTICT partitioning columns FROM increment)

The procedure for a single satellite is as follows:
- select all active "keys" from the satellite that belong to the partition 
    - Join to the data vault tables, that contain the partitioning fields
	- constrain the partitioning field only to values that are in the stage table
- create deletion records for all "keys", that are missing in the stage
- apply enddating (when used)

Selecting all active keys that belong to the partition can be a complex task, depending on the distribution of the partitioning columns in the data vault model.
The following picture shows exaples of common  scenarios as examples

![Fig1](./images/partition delivery variations.drawio.png)