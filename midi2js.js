#!/usr/bin/env node

var fs = require('fs');
var path = require('path');
var MidiConvert = require('./MidiConvert.js');

//TODO maybe round time and duration values a bit

function guessName(source){
  return path.basename(source, '.js');
}

function midi2json(input, output, varname){
  fs.readFile(input, "binary", function(err, midiBlob){
      if (!err){
          var json = MidiConvert.parse(midiBlob);
          var s = 'var '+varname + ' = ' + JSON.stringify(json, null, 4);
          fs.writeFile(output, s, function(err){
            if(err){ console.log(err); }
          });
      }
  });
}

function main(){
  if (process.argv.length < 4){
    console.log('more args!');
  } else {
    midi2json(process.argv[2], process.argv[3], guessName(process.argv[3]));
  }
}

if (require.main === module) {
    main();
}
