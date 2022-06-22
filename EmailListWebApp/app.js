var express = require('express');
var app = express();
var mysql = require('mysql');
var bodyParser = require('body-parser');

app.set("view engine", "ejs");
app.use(bodyParser.urlencoded({extended: true}));
app.use(express.static(__dirname + "/public"));

var connection = mysql.createConnection({
	host: 'localhost',
	user: 'root',
	database: 'waiting_list'
});


app.get("/", function(req, res){
	
	var q= 'SELECT COUNT(*) as count FROM users';
	connection.query(q, function (error, results) {
		if (error) throw error;
		var count = results[0].count;
		res.render("home", {data: count});
	});
});

app.post("/register", function(req, res){
	var person = {
		email: req.body.email
	};
	connection.query('INSERT INTO users SET ?', person, function (error, results) {
		if (error) throw error;
		// res.send("Thanks for registering!")
		console.log(results);
		res.redirect('/');
	});
});


app.listen(3000, function(){
	console.log("Server running on 3000!");
});
