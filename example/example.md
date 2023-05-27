# Examples

## Full flutter API demo app

Download a full flutter demo app for dizzbase at: https://github.com/dizzweb-GmbH/dizzbase_flutter_demo

The demo app illustrates all examples from below. It also contains SQL scripts to setup a demo database on PostgreSQL. Refer to the README.md file of the demo app for instructions.

## Initialization

Initialize the dizzbase client in main(). For testing you can call login with the admin demo user that is automatically created (set main() to async to await the login) - otherwise you would show a login screen. Note that logging in and providing an access token is only necessary if JWT is enabled in the backend -  see README.md of the dizzbase NPM backend package on how to en/disable JWT and how to create an API access token.

```
void main() async {
    DizzbaseConnection.configureConnection("http://localhost:3000", "...api access token...");
    await DizzbaseAuthentication.login(userName: "admin", password: "admin");
    runApp(const MyApp());
}    
```

## Retrieve data with real-time updates for use with StreamBuilder:

For each widget the requires streamed updates, create/dispose a DizzbaseConnection and create the Stream as follows:

    
    @override
    void initState() {
        super.initState();
        
        // Start a new connection to the backend
        myDizzbaseConnection = DizzbaseConnection();

        // Retriev a single row via primary key
        _stream_1 = myDizzbaseConnection.streamFromQuery(DizzbaseQuery(table: MainTable("employee", pkey: 3)))

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
    

Use the _stream_x objects as follows:

    StreamBuilder<DizzbaseResultRows>(
        stream: _stream_x,
        builder: ((context, snapshot) {
            if (snapshot.hasData)
            {
                // Use snapshot.data!.rows![rowNumber][fieldName] ... to access your data.
                // eg: snapshot.data!.rows![0]["user_name"] ... 
                return // ... build your widget ...;
            } else if (snapshot.hasError) {
                throw Exception("Snapshot has error: ${snapshot.error}");
            } else {
                // ... show progress indicator ...
            }
    })),

Do NOT create the streams in build() or builder() of a widget as this leads to multiple streams being created (therefore slow performance) and significant overhead on the server.

Automatic join: If two tables are joined via a foreign key constraint in the database, the ```JoinedTable``` can be added to the query without naming the keys - it is automatically looked up in the db schema.

Note that JoinedTables has an option for Left/Right Outer Joins.

## Real-time updates for stream-based queries

Stream-based queries will be updated automatically if row in the query are updated or delete. 

For joined tables, the query will also be updated if a new record is inserted for the primary key of the joined table. Consider for example:
```
SELECT * FROM orders JOIN customers ON orders.customer_id = customers.id;
```
In this case, the query will be updated if a new "orders" row is created for the customer record.

## UPDATE/DELETE/INSERT Transactions

Use the ```DizzbaseUpdate```, ```DizzbaseInsert```, ```DizzbaseDelete``` classes with the ```DizzbaseConnection().updateTransaction()```, ```DizzbaseConnection().insertTransaction()```, ```DizzbaseConnection().deleteTransaction()``` methods. Either a ```DizzbaseResultRowCount``` (UPDATE/DELTE: indicating the number of affected rows) or a ```DizzbaseResultPkey``` (INSERT: indicating the primary key of the new row) object is return as a future:

    // Update, similar for Delete
    DizzbaseConnection().updateTransaction(
        DizzbaseUpdate(table: "employee", fields: ["employee_name", "employee_email"], 
        values: [_controllerName.text, _controllerEmail.text], filters: [Filter('employee', 'employee_id', 2)]))
        // ERROR HANDLING and show how many rows were updated:
        .then((result) {
            if (result.error != "") { throw Exception(result.error); }
            setState(() => rowsAffected = result.rowCount);
        });

    // Insert
    DizzbaseConnection().insertTransaction(
        DizzbaseInsert(table: "order", fields: ["order_name", "customer_id", "sales_rep_id", "services_rep_id", "order_revenue"], 
        values: [_controllerName.text, 1, 2, 2, _controllerRevenue.text], nickName: "InsertOrder"))
        // RETRIEVING THE PRIMARY KEY... add error handling via result.error here as well if needed: 
    .then((data) => setState(() => insertedRowPrimaryKey = data.pkey));

## Directly sending SQL to execute SELECTs, stored procedures or anything else

Use ```DizzbaseConnection.directSQLTransaction(String sqlStatement)``` to send any custom SQL statement and receive the result as a ```Future<DizzbaseResultRows>```. ```DizzbaseResultRows``` contains your data and error information (if any). Note that this feature carries the risk of SQL injections attacks and has to be enabled on the backend dizzbase server via .env file.
