# csv-data-cleaner

This project is used to read headers, get data, and clean data from the CSV file.

## Prerequisites

* Install Ballerina Swan Lake Beta1 
* Download the mysql server and start it.
* Update all the configurations in the `Config.toml`

## Run the App

To run this, move into the csv-data-cleaner and execute the below command.

    bal run

## Sample request

### Get Headers

    curl -v http://localhost:9090/csv/getHeader --data "PATH OF THE CSV FILE"
    Note: The given file data should be separated by `comma`.

### Get All Data

    curl -v "http://localhost:9090/csv/getData?columnNames={ADD COLUMN NAME}&columnNames={ADD COLUMN NAME}"

### Get specific no of Data

    curl -v "http://localhost:9090/csv/getData/{NO OF DATA}?columnNames={ADD COLUMN NAME}&columnNames={ADD COLUMN NAME}"

### Clear Data

    curl -v http://localhost:9090/csv/clearData --data "ADD QUERY"
    Eg query: `Region=\"Europe\" AND Country=\"Russia\"`

### Shutdown service
    curl -v http://localhost:9090/csv/shutdown
