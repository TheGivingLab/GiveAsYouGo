var hem  = new (require('hem'));
var HamlCoffee = require('haml-coffee/src/haml-coffee');
var CoffeeScript = require('coffee-script')
var fs   = require('fs');
var argv = process.argv.slice(2);

hem.compilers.haml = function(path) {
  var compiler, content, template;
  compiler = new HamlCoffee({});
  content = fs.readFileSync(path, 'utf8');
  compiler.parse(content);
  template = compiler.precompile();
  template = CoffeeScript.compile(template);
  return "module.exports = (function(data){ return (function(){ return " + template + " }).call(data); })";
};

hem.compilers.jhaml = function(path) {
  var compiler, content, template;
  compiler = new HamlCoffee({});
  content = fs.readFileSync(path, 'utf8');
  compiler.parse(content);
  template = compiler.precompile();
  template = CoffeeScript.compile(template);
  return "module.exports = (function(values){ " +
    "return (function(values){ " +
      "var $  = jQuery, result = $(); " +
      "for(var i=0; i < this.length; i++) { " +
        "var value = this[i]; " +
        "var elem = (function(){ " +
          "return " + template +
        "}).call(value); " +
        "elem  = $(elem); " +
        "elem.data('item', value); " +
        "$.merge(result, elem); " +
      "} " +
      "return result; " +
    "}).call(values); " +
  "})";
};

require.extensions['.jhaml'] = require.extensions['.haml'];

// http://blog.divshot.com/post/31336785156/exposing-env-to-spine
hem.compilers.env = function(path) {
  var content = fs.readFileSync(path, 'utf8');
  var envHash = JSON.parse(content);

  for (key in envHash) {
    if (process.env[key]) {
      envHash[key] = process.env[key];
    }
  }

  return "module.exports = " + JSON.stringify(envHash);
};

hem.exec(argv[0]);
