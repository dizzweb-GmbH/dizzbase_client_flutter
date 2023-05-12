# Getting started

Install and configure dizzbase on your backend server: https://www.npmjs.com/package/dizzbase

In the flutter apps main() function, call DizzbaseConnection.configureConnection(...) to configure your backend services URL and access token.

To understand how the dart/flutter dizzbase client works, look at dizzbase_demo_widget.dart first - there you can see how data is retrieved from the database.

In dizzbase_demo_ui.dart there are more widgets that demonstrate how to insert/update/delete data. There is also an example on how to directly send SQL to the backend an retrieve the result (without using a stream).

Note the initState() and dispose() overrides of the StatefulWidgets to see how to create and clean up the dizzbase connection and therefore to avoid backend memory leaks with long-running clients.

To build a small demo app, you can ```flutter create myApp``` and then add the initialization code to your main() function:

    void main() {
        runApp(const MyApp());
        DizzbaseConnection.configureConnection("http://localhost:3000", "my-security-token");
    }

Then set the DizzbaseDemoWidget as the body of your app:

    class _MyHomePageState extends State<MyHomePage> {
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(
                title: Text(widget.title),
            ),
            body: DizzbaseDemoWidget(),
        );
        }
    }
