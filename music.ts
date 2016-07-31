interface Playable {
    duration: number;
}

var context = new window.AudioContext();

class Note implements Playable{
    constructor(public halfSteps: number,
                public duration: number){ }

    frequency(fundamental = 220) {
        return fundamental * 2**(this.halfSteps / 12)
    }
    play(tempo=60){
        var osc = context.createOscillator();
        osc.frequency.value = this.frequency()
        osc.connect(context.destination);
        osc.start(0);
        osc.stop(this.duration*60/tempo)
    }

    static fromSolfege(s: string){
        var myRegexp = /([A-Z][a-z]+)(\d?)([ ]+)/;
        var match = myRegexp.exec(s);
        var halfSteps = noteMap[match[1]] + (match[2] ? 12 * parseInt(match[2]) : 0);
        var duration = match[3].length
        var n = new Note(halfSteps, duration);
        return n;
    }
}

class Riff{
    constructor(public notes: Note[],
                public instrument='default',
                public maxTempo=100000,
                public minTempo=1){}

    play(tempo=60){
        var notes = this.notes.slice(0);
        var osc = context.createOscillator();
        osc.connect(context.destination);

        function playAndShift(){
            if (notes.length === 0){
                osc.stop();
                return;
            }
            var note = notes.shift()
            osc.frequency.value = note.frequency()
            window.setTimeout(playAndShift, note.duration*1000 * 60 / tempo);
        }
        playAndShift();
        osc.start(0);
    }

    static fromSolfege(s: string){
        var myRegexp = /([A-Z][a-z]+[\d]?[ ]*)/g;
        var match = myRegexp.exec(s);
        var notes: Note[] = [];
        while (match !== null) {
            // matched text: match[0]
            // match start: match.index
            // capturing group n: match[n]
            notes.push(Note.fromSolfege(match[0]))
            match = myRegexp.exec(s);
        }
        return new Riff(notes)
        /*TODO should make these transposable */
    }
}

var noteMap: { [note: string]: number; } = {
"Do"   : 0,
"Di"   : 1,
"Ra"   : 1,
"Re"   : 2,
"Ri"   : 3,
"Ma"   : 3,
"Mi"   : 4,
"Fa"   : 5,
"Fi"   : 6,
"Se"   : 6,
"Sol"  : 7,
"Si"   : 8,
"Le"   : 8,
"La"   : 9,
"Li"   : 10,
"Te"   : 10,
"Ta"   : 10,
"Ti"   : 11,
}

var s = "Sol  Re Ma Fa  Ma Re Do  Do Ma Sol  Fa Ma Re   Ma Fa  Sol  Ma  Do  Do      "
var s2 = "Fa  Le Do1  Ta Le Sol   Ma Sol  Fa Ma Re  Re Ma Fa  Sol  Ma  Do  Do    "
var r = Riff.fromSolfege(s2);
console.log(r);
r.play(300)

/** A collection of riffs and when to play each */
class Song {

}


/* Given a chord progression, a melody, and a tempo, come up with
 *
 *
 * Helpers we'll need:
 * interesting licks that can be added in any key
 * rhythms to go along
 * NAH let's just do it with layers.o
 *
 * Many layers, each with an annotations for what tempos they should be played at.



data Note = N { note :: String,
                duration :: Float }
                deriving (Show, Eq)

-- Mi Sol Tiiii

parseSong :: String -> [Note]
parseSong s =
    let words = getAllTextMatches $ s =~ "[A-Z][a-z0-9]+[ ]+" :: [String] in
        [N (word =~ "[A-Z][a-z0-9]+" :: String) (fromInteger (toInteger (length (word =~ "[ ]+" :: String)))) | word <- words]

toneFromSolfege n = Sine (solfegeToFreq (note n) * 50) 0 (duration n / 5.0)

sinesFromSong song = [toneFromSolfege n | n <- parseSong song]
       */

