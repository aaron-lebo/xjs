var escodegen = require('escodegen');

var stdin = process.stdin;
var chunks = [];

stdin.resume();
stdin.setEncoding('utf8');

stdin.on('data', function(chunk) {
    chunks.push(chunk);
});

stdin.on('end', function() {
    var jst = JSON.parse(chunks.join());
    console.log(escodegen.generate(jst));
});
