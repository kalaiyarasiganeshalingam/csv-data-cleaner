import ballerina/regex;
import ballerina/io;
import ballerinax/mysql;
import ballerina/sql;

public function readCsvFile(mysql:Client mysqlClient, string path, string dbname) returns error|string {
    stream<string[], io:Error?> csvStream = check io:fileReadCsvAsStream(path);
    record {|string[] value;|}? headers = check csvStream.next();
    string output = "Created table headers: ";
    if headers is record {|string[] value;|} {
        string data = check createTable(mysqlClient, dbname, headers, csvStream);
        return output + data.substring(2, data.length() - 2);
    } else {
        return output + "null";
    }
}

public function getColumnData(mysql:Client sqlClient, string[]? coloumnNames,
                              string dbName, int? noOfData = ()) returns string|error {
    string query = "";
    string data = "";
    if (coloumnNames is string[]) {
        foreach string coloumnName in coloumnNames {
            query = query + ", " + coloumnName;
        } 
        query = string `SELECT ${query.substring(2, query.length())} FROM ${dbName}.csvData`;
    } else {
        query = string `SELECT * FROM ${dbName}.csvData`;
    }
    stream<record{}, error> executeResult = sqlClient->query(query);
    int i = 0;
    error? e = executeResult.forEach(function(record {} result) {
        if (noOfData is int) {
            if (i < <int>noOfData) {
                data = data + "\n" + result.toString(); 
            }
            i =  i +1;
        } else {
            data = data + "\n" + result.toString(); 
        }
    });
    return data;
}

public function deleteData(mysql:Client sqlClient, string condition, string dbName) returns string|error {
    string query = string `DELETE FROM ${dbName}.csvData WHERE ${condition}`;
    sql:ExecutionResult result = check sqlClient->execute(query);
    return "Deleted row/rows successfully";
}

function createTable(mysql:Client mysqlClient, string dbName, 
                    record {|string[] value;|} header, stream<string[], 
                    io:Error?> csvStream) returns string|error {
    string headers = header.value.toString();
    headers = regex:replaceAll(headers, " ", "");
    headers = regex:replaceAll(headers, "\",\"", ", ");
    string tableHeaders = regex:replaceAll(headers, ",", " VARCHAR(300),"); 
    tableHeaders = tableHeaders.substring(2, tableHeaders.length() - 2); 
    sql:ExecutionResult executeResult = check mysqlClient->execute(string `DROP TABLE IF EXISTS ${dbName}.csvData`);
    string query = string `CREATE TABLE ${dbName}.csvData(${tableHeaders} VARCHAR(300))`;
    executeResult = check mysqlClient->execute(query); 
    int i = 0;
    string queryData = headers.substring(2, headers.length() - 2); 
    string data = "";
    error? e = csvStream.forEach(function(string[] result) {
            foreach string value in result {
                data = string `${data}'${value}', `; 
            }
        data = data.substring(0, data.length() - 2);
        string que = string `INSERT INTO ${dbName}.csvData(${queryData}) VALUES(${data})`;
        sql:ExecutionResult|error ase = mysqlClient->execute(que);
        data = "";
    });
    return headers;
}
