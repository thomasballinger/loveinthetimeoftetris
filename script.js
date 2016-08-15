(function(global){
  global.setBPM = function(bpm){
    Tone.Transport.bpm.value = bpm;
  };

  tetrisSpec = {
    'Tetris Melody': {
      instrument: function(){
        var synth = new Tone.Synth();
        synth.toMaster();
        return synth;
      },
      attack: function(synth, t, freq, vel){
        synth.triggerAttack(freq, t, vel);
      }
    },
    'Tetris Harmony': {
      instrument: function(){
        var synth = new Tone.Synth();
        synth.toMaster();
        return synth;
      },
      attack: function(synth, t, freq, vel){
        synth.triggerAttack(freq, t, vel);
      }
    },
    'Tetris Bass': {
      instrument: function(){
        var synth = new Tone.Synth();
        synth.toMaster();
        return synth;
      },
      attack: function(synth, t, freq, vel){
        synth.triggerAttack(freq, t, vel);
      }
    },
    'Tetris Perc': {
      instrument: function(){
        var synth = new Tone.NoiseSynth();
        synth.volume.value = -12;
        synth.toMaster();
        return synth;
      },
      attack: function(synth, t, freq, vel){
        synth.triggerAttack(t);
      },
    }
  };

  function scheduleAttack(synth, attack, freq, time, velocity){
    Tone.Transport.schedule(function(t){
      attack(synth, t, freq, velocity);
    }, time);
  }
  function scheduleRelease(synth, time){
    Tone.Transport.schedule(function(t){
      synth.triggerRelease(t);
    }, time);
  }

  function play(song, spec){
    for (var track of song.tracks){
      if (!spec[track.name]){ continue; }

      var synth = spec[track.name].instrument();
      var attack = spec[track.name].attack;

      for (var note of track.notes){
        scheduleAttack(synth, attack, note.note, note.time, note.velocity);
        scheduleRelease(synth, note.time + note.duration);
      }
    }
    Tone.Transport.bpm.value = 100;
    Tone.Transport.start();
  }

  global.play = play;
  global.tetrisSpec = tetrisSpec;
  play(tetrisSong, tetrisSpec);


})(window);
