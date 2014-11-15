var path        = require('path');
var express     = require('express');
var compression = require('compression')
var app         = express()

app.use(compression());
app.use(express.static(path.join(__dirname, '/dist')));
app.listen(process.env.PORT || 5000, function() {
  console.log("Server started.");
});
