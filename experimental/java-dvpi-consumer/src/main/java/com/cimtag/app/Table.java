package com.cimtag.app;

import java.util.Map;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;


@JsonIgnoreProperties(ignoreUnknown = true)
public class Table {

    @JsonProperty(value="column_dict", required=true)
    private Map<String, Column> columnDict;

    public Map<String, Column> getColumnDict() {
        return columnDict;
    }

    public void setColumnDict(Map<String, Column> columnDict) {
        this.columnDict = columnDict;
    }
    
}
