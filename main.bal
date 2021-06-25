import ballerinax/mysql;
import ballerina/http;
import ballerina/jballerina.java;
import ballerina/sql;
import data_cleaner.utils;

configurable string dbUsername = "root";
configurable string dbPassword = "";
configurable string dbName = "MYSQL_BBE";
configurable int port = 3306;

mysql:Client sqlClient = check new (user = dbUsername, password = dbPassword);

listener http:Listener storeListener = new (9090);

service /csv on storeListener {

    resource function post getHeader(@http:Payload string path) returns string|error {
        sql:ExecutionResult result = check sqlClient->execute(string `DROP DATABASE IF EXISTS ${dbName}`);
        result = check sqlClient->execute(string `CREATE DATABASE ${dbName}`);
        sqlClient = check new (user = dbUsername, password = dbPassword, database = dbName);
        return check utils:readCsvFile(sqlClient, path, dbName); 
    }

    resource function get getData(string[]? columnNames) returns string|error {
        return check utils:getColumnData(sqlClient, columnNames, dbName); 
    }

    resource function get getData/[int count](string[]? columnNames) returns string|error {
        if (count > 0) {
            return check utils:getColumnData(sqlClient, columnNames, dbName, count); 
        } else {
            return error("noOfData should be grater than 1.");
        }
    }

    resource function post clearData(@http:Payload string condition) returns string|error {
        return check utils:deleteData(sqlClient, condition, dbName);
    }

    resource function get shutdown () {
        system_exit(0);
        return;
    }
}

function system_exit(int arg0) = @java:Method {
    name: "exit",
    'class: "java.lang.System",
    paramTypes: ["int"]
} external;
