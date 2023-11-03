package com.cimtag.app;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

@JsonIgnoreProperties(ignoreUnknown = true)
public class Column {
    
    @JsonProperty("column_class")
    private String columnClass;

    @JsonProperty(value="column_type", required=true)
    private String columnType;

    @JsonProperty("parent_key_column_name")
    private String parentKeyColumnName;

    @JsonProperty("parent_table_name")
    private String parentTableName;


    public String getColumnClass() {
        return this.columnClass;
    }

    public void setColumnClass(String columnClass) {
        this.columnClass = columnClass;
    }

    public String getColumnType() {
        return this.columnType;
    }

    public void setColumnType(String columnType) {
        this.columnType = columnType;
    }

    public String getParentKeyColumnName() {
        return this.parentKeyColumnName;
    }

    public void setParentKeyColumnName(String parentKeyColumnName) {
        this.parentKeyColumnName = parentKeyColumnName;
    }

    public String getParentTableName() {
        return this.parentTableName;
    }

    public void setParentTableName(String parentTableName) {
        this.parentTableName = parentTableName;
    }

}
