package com.cimtag.app;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.util.Map;

@JsonIgnoreProperties(ignoreUnknown = true)
public class DVPI {

    @JsonProperty(value="table_dict", required=true)
    private Map<String, Table> tableDict;

    public Map<String,Table> getTableDict() {
        return this.tableDict;
    }

    public void setTableDict(Map<String,Table> tableDict) {
        this.tableDict = tableDict;
    }
}