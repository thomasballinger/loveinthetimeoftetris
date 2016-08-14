(function(global){
  var midiPPQ = 9600;  // hardcoded for now, from tetris song file

  global.setBPM = function(bpm){
    desiredTicksPerSecond = bpm / 60 * midiPPQ;
  };

  var song = tetrisSong.notes.slice();

  var bpm = 60;
  var lastTicksPerSecond = bpm / 60 * midiPPQ;
  var lastTick = 0;
  var lastTime = 0;
  var desiredTicksPerSecond = undefined;
  var nextUnscheduledNoteStartIndex = 0;
  var queuedOrPlaying = [];

  audioContext = new AudioContext();
  scheduleNotes();


  function scheduleNotes(){
    // find all notes that will occur in next .1 seconds and schedule them
    var curTicksPerSecond = desiredTicksPerSecond || lastTicksPerSecond;
    desiredTicksPerSecond = undefined;

    var curTime = audioContext.currentTime;
    var dt = curTime - lastTime;
    var curTick = lastTick + lastTicksPerSecond * dt;

    var maxTickToSchedule = curTick + 0.1 * curTicksPerSecond;
    while (nextUnscheduledNoteStartIndex < song.length &&
           song[nextUnscheduledNoteStartIndex].ticks <= maxTickToSchedule){
      var note = song[nextUnscheduledNoteStartIndex++];
      if (note.ticks < curTick ){
        console.warn("we missed a note!");
      }
      var osc = playNote(curTime + (note.ticks - curTick)/curTicksPerSecond, note.midi);
      queuedOrPlaying.push([osc, note.ticks + note.duration * 12800]);  //TODO hardcoded for Tetris
           // Should really switch everything to time units, since durations are in time
           // and it's better anyway
    }
    queuedOrPlaying = queuedOrPlaying.filter(function(x){
      var osc = x[0];
      var tick = x[1];
      if (tick <= maxTickToSchedule){
        var stopTime = (curTime + (tick - curTick)/curTicksPerSecond);
        osc.stop(stopTime);
        return false;
      } else {
        return true;
      }
    });

    lastTick = curTick;
    lastTime = curTime;
    lastTicksPerSecond = curTicksPerSecond;
    setTimeout(scheduleNotes, 100);
  }

  function playNote(time, midiPitch){
    var osc = audioContext.createOscillator();
    osc.connect( audioContext.destination );
    var freq = 261.6 * Math.pow(2, (midiPitch/12) - 5);
    osc.frequency.value = freq;
    osc.start(time);
    //osc.stop(time + noteLength);
    return osc;
  }
})(window);
