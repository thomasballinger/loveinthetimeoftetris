(function(global){
  function simpleAttack(synth, t, freq, vel){
      synth.triggerAttack(freq, t, vel);
    }

  function simpleRelease(synth, t, freq){
    synth.triggerRelease(t);
  }

  function polyRelease(synth, t, freq, vel){
    synth.triggerRelease(freq, t);
  }

  function tetrisPlayer(){
    for (var trackName in this.trackInfo){
      if (this.trackInfo[trackName].group){
        var group = this.trackInfo[trackName].group;
        if (!this[group]){
          this[group] = new Tone.Volume();
          this[group].toMaster();
        }
      }
    }
  }

  /* 290 is full tetris speed
   *
   * */

  tetrisPlayer.prototype.buildInstrument = function(track){
    var instrument = this.trackInfo[track].instrument(this);
    var group = this.trackInfo[track].group;
    instrument.connect(this[group]);
    return instrument;
  };
  tetrisPlayer.prototype.updateGains = function(bpm){
    for (var name in this.groupInfo){
      var x = this.groupInfo[name];
      if (bpm < x[0] || bpm > x[3]){
        this[name].mute = true;
      } else if (bpm > x[1] && bpm < x[2]){
        this[name].mute = false;
        this[name].volume.value = 0;
      } else if (bpm > x[2]){
        this[name].mute = false;
        var fraction = (bpm - x[2]) / (x[3] - x[2]);
        this[name].volume.value = -15 * fraction;
      } else if (bpm < x[1]){
        this[name].mute = false;
        var fraction = (bpm - x[0]) / (x[1] - x[0]);
        this[name].volume.value = -15 * (1 - fraction);
      }
    }
  };
  /* silent - full - full - silent */
  tetrisPlayer.prototype.groupInfo = {
    'tetris': [120, 230, 10000, 10000],
    'always': [0, 0, 10000, 10000],
    'alt'   : [0, 0, 140, 240]
  };
  tetrisPlayer.prototype.trackInfo = {
    'Tetris Melody': {
      instrument: function(){
        var synth = new Tone.Synth();
        return synth;
      },
      attack: function(synth, t, freq, vel){ synth.triggerAttack(freq, t, vel); },
      release: simpleRelease,
      group: 'tetris'
    },
    'Tetris Harmony': {
      instrument: function(){
        var synth = new Tone.Synth();
        return synth;
      },
      attack: function(synth, t, freq, vel){ synth.triggerAttack(freq, t, vel); },
      release: simpleRelease,
      group: 'tetris'
    },
    'Tetris Bass': {
      instrument: function(){
        var synth = new Tone.Synth();
        return synth;
      },
      attack: simpleAttack,
      release: function(synth, t, freq){
        synth.triggerRelease(t);
      },
      group: 'always'
    },
    'Tetris Perc': {
      instrument: function(){
        var synth = new Tone.NoiseSynth();
        synth.volume.value = -12;
        return synth;
      },
      attack: function(synth, t, freq, vel){ synth.triggerAttack(t); },
      release: simpleRelease,
      group: 'always'
    },
    'Alt Bass': {
      instrument: function(){
        var synth = new Tone.PolySynth(4, Tone.Synth);
        return synth;
      },
      attack: simpleAttack,
      release: polyRelease,
      group: 'alt'
    },
    'Alt Melody': {
      instrument: function(){
        var synth = new Tone.PolySynth(4, Tone.Synth);
        return synth;
      },
      attack: simpleAttack,
      release: polyRelease,
      group: 'alt'
    }
  };

  function scheduleAttack(synth, attack, freq, time, velocity){
    Tone.Transport.schedule(function(t){
      attack(synth, t, freq, velocity);
    }, time);
  }
  function scheduleRelease(synth, release, freq, time){
    Tone.Transport.schedule(function(t){
      release(synth, t, freq);
    }, time);
  }

  function play(song, player){
    scheduleSong(song, player, 0.2);
    Tone.Transport.bpm.value = 20;
    player.updateGains(20);
    Tone.Transport.start();
  }

  function scheduleSong(song, player, offset){
    for (var track of song.tracks){
      if (!player.trackInfo[track.name]){
        continue;
        console.log("skipping track", track.name);
      }

      var synth = player.buildInstrument(track.name);
      var attack = player.trackInfo[track.name].attack;
      var release = player.trackInfo[track.name].release;

      for (var note of track.notes){
        scheduleAttack(synth, attack, note.note, note.time + offset, note.velocity);
        scheduleRelease(synth, release, note.note, note.time + offset + note.duration);
      }
    }
  }

  global.play = play;
  global.tetrisPlayer = tetrisPlayer;

  var player = new tetrisPlayer();
  play(tetrisSong, player);


  global.setBPM = function(bpm){
    var diff = Math.abs(bpm - Tone.Transport.bpm.value);
    if (diff < 1){ return; }
    Tone.Transport.bpm.value = bpm;
    player.updateGains(bpm);
  };


})(window);
