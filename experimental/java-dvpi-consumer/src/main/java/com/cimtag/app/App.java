package com.cimtag.app;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.IOException;
import java.util.Map;
import java.util.StringJoiner;
import java.util.Map.Entry;

public class App 
{
    public static void main(String[] args) throws IOException {
        ObjectMapper mapper = new ObjectMapper();
        DVPI dvpi = mapper.readValue(new File("/home/joscha/data_vault_pipelinedescription/documentation/dvpi_examples/test55_large_feature_cover.dvpi.json"), DVPI.class);

        for (Entry<String, Table> tableEntry : dvpi.getTableDict().entrySet()) {
            System.out.println(generateCreateTableStatement(tableEntry.getKey(), tableEntry.getValue().getColumnDict()));
        }
    }

    private static String generateCreateTableStatement(String tableName, Map<String, Column> columns) {
        StringJoiner columnsDDL = new StringJoiner(",\n  ", "(", ")");

        for (Entry<String, Column> columnEntry : columns.entrySet()) {
            String columnName = columnEntry.getKey();
            Column column = columnEntry.getValue();

            columnsDDL.add(columnName + " " + column.getColumnType());
        }

        return "CREATE TABLE " + tableName + " " + columnsDDL + ";";
    }
}
