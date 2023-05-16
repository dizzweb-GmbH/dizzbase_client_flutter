# Examples

## Full flutter API demo app

Download a full flutter demo app for dizzbase at: https://github.com/dizzweb-GmbH/dizzbase_flutter_demo

The demo app illustrates all examples from below. It also contains SQL scripts to setup a demo database on PostgreSQL. Refer to the README.md file of the demo app for instructions.

## Initialization

Initialize the dizzbase client in main():
    ```dart
    void main() {
        runApp(const MyApp());
        DizzbaseConnection.configureConnection("http://localhost:3000", "my-security-token");
    }
    ```dart

## Retrieve data with real-time updates for use with StreamBuilder:

For each widget the requires streamed updates, create/dispose a DizzbaseConnection and create the Stream as follows:

    ```dart
    @override
    void initState() {
        myDizzbaseConnection = DizzbaseConnection();
        _stream_1 = myDizzbaseConnection.streamFromQuery(DizzbaseQuery(table: MainTable("employee", pkey: 3)))
        super.initState();

        // Demo of how a list of orders is automatically updated when a new order is added.
        _stream_2 = myDizzbaseConnection.streamFromQuery(DizzbaseQuery(
            table: MainTable("order"), 
            joinedTables: [JoinedTable('employee', joinToTableOrAlias: 'order', foreignKey:  'sales_rep_id' )],
            filters: [Filter('employee', 'employee_id', 2)])
            //...

        // Search with a LIKE statement.
        _stream_3 = myDizzbaseConnection.streamFromQuery(DizzbaseQuery(table: MainTable("employee"), 
            filters: [Filter('employee', 'employee_email', '%hotmail%', comparison: 'LIKE')])
            // ...

        // Complex query      
        _stream_4 = myDizzbaseConnection.streamFromQuery(DizzbaseQuery(
            table:
            MainTable('order'),
            joinedTables:
            [
            // Automatic JOIN: This will include all columns, and the JOIN to the MainTable will be added automatically using the constraint information in the database
            JoinedTable('customer'), 
            // Join the same table two time, so we need to add aliases. 
            // Observe that the columns for tables with aliases are named differently in the output table - "seller_employee_name" instead of just "employee_name"
            JoinedTable('employee', joinToTableOrAlias: 'order', foreignKey: 'sales_rep_id', columns: ['employee_name', 'employee_email'], alias: 'seller'),
            JoinedTable('employee', joinToTableOrAlias: 'order', foreignKey: 'services_rep_id', columns: ['employee_name'], alias: 'consultant'),
            ],
            sortFields: 
            [
            // Note the the alias is used for sorting, rather than the table name (as the table is part of two joins)
            SortField('seller', 'employee_name', ascending: false), 
            SortField('order', 'order_id', ascending: false), 
            ],
            filters: 
            [
            Filter ('order', 'order_revenue', 50, comparison: ">="),
            ]
        ));

    }

    @override
    void dispose() {
        // IMPORTANT!
        myDizzbaseConnection.dispose();
        super.dispose();
    }
    ```

Use the _stream_x objects as follows:

    StreamBuilder<List<Map<String, dynamic>>>(
    stream: _stream_x,
    builder: ((context, snapshot) {
        if (snapshot.hasData)
        {
            return // ... build your widget ...;
        } else if (snapshot.hasError) {
            throw Exception("Snapshot has error: ${snapshot.error}");
        } else {
            // ... show progress indicator ...
        }
    })),

## UPDATE/DELETE/INSERT Transactions

Use the DizzbaseUpdate, DizzbaseInsert, DizzbaseDelete classes with the DizzbaseConnection().updateTransaction, DizzbaseConnection().insertTransaction, DizzbaseConnection().deleteTransaction methods like so:

    DizzbaseConnection().updateTransaction(
        DizzbaseUpdate(table: "employee", fields: ["employee_name", "employee_email"], 
        values: [_controllerName.text, _controllerEmail.text], filters: [Filter('employee', 'employee_id', 2)]))
        // ERROR HANDLING and show how many rows were updated:
        .then((result) {
        if (result["error"]!= "") { throw Exception(result["error"]); }
        setState(() => rowsAffected = result["rowCount"]);
        });

## Directly sending SQL to execute SELECTs, stored procedures or anything else

Use DizzbaseConnection.directSQLTransaction(String) to send any custom SQL statement and receive the result as a Future<DizzbaseDirectSQLResult>. DizzbaseDirectSQLResult contains your data and error information (if any).