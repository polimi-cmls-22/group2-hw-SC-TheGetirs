// The Getirs
// - Di Palma Riccardo
// - Gargiulo Antonino Manuele
// - Morena Edoardo
// - Orsatti Alessandro
// - Perego Niccolò
// public repo: https://github.com/peregoniccolo/hw-SC
// CMLS repo: https://github.com/polimi-cmls-22/group2-hw-SC-TheGetirs

(

// synth model
var currAmp1, currAmp2, currAmp3, currAmp4;
var currFine1, currFine2, currFine3, currFine4;
var currCoarse1, currCoarse2, currCoarse3, currCoarse4;
var currSwitch1 = 1, currSwitch2 = 0, currSwitch3 = 0, currSwitch4 = 0, lpfSwitch = 0;
var currSignalType1, currSignalType2, currSignalType3, currSignalType4;
var currEnvelope, currEnvLvl1, currEnvLvl2, currEnvLvl3, currEnvLvl4;
var currEnvTime1, currEnvTime2, currEnvTime3, currEnvTime4, releaseNode = 2;
var durationEnv = 1;
var lpfMessage = "Control the LPF with your mouse: X axis is the Frequency Cut-off\nfrom 20 to 20k Hz, Y axis i the Resonance from 0 to 1.\n";
var scopeMessage = "Time scope already opened!\n";
var freqScopeMessage = "Frequency Analyzer already opened!\n";
var bootingMessage = "Error while booting the server!";

// functions
var updateEnvelope, updateTimes, styleSelects, styleKnobs;


// ============================================ GUI ============================================

// gui parameters
var path = thisProcess.nowExecutingPath.dirname; // for images
var envView, envViewLabel, envDurationSel, envTypeSel, selectedEnvType;
var envTypes = [
	'adsr' -> {
		selectedEnvType = Env.adsr;
		releaseNode = 2;
	}, //item action
	'asr' -> {
		selectedEnvType = Env.asr;
		releaseNode = 1;
	},
	'triangle' -> {
		selectedEnvType = Env.triangle;
		releaseNode = nil;
	},
	'perc' -> {
		selectedEnvType = Env.perc;
		releaseNode = nil;
	},
];
var envDurations = [
	'1 sec' -> { durationEnv = 1; },
	'2 sec' -> { durationEnv = 2; },
	'3 sec' -> { durationEnv = 3; },
	'4 sec' -> { durationEnv = 4; },
];

var frameHeight, frameWidth;
var titlesFont, labelsFont;
var csCoarse, csFine, csAmp, csModInd;
var nameLabel4, nameButton4, coarseKnob4, fineKnob4, ampKnob4, signTypeSel4;
var nameLabel3, nameButton3, coarseKnob3, fineKnob3, ampKnob3, signTypeSel3;
var nameLabel2, nameButton2, coarseKnob2, fineKnob2, ampKnob2, signTypeSel2;
var nameLabel1, nameButton1, coarseKnob1, fineKnob1, ampKnob1, signTypeSel1;
var signalTypes1 = [
	"Sinusoidal" -> { currSignalType1 = 0; },
	"Saw" -> { currSignalType1 = 1; },
	"Triangular" -> { currSignalType1 = 2; },
	"Square" -> { currSignalType1 = 3; }
];
var signalTypes2 = [
	"Sinusoidal" -> { currSignalType2 = 0; },
	"Saw" -> { currSignalType2 = 1; },
	"Triangular" -> { currSignalType2 = 2; },
	"Square" -> { currSignalType2 = 3; }
];
var signalTypes3 = [
	"Sinusoidal" -> { currSignalType3 = 0; },
	"Saw" -> { currSignalType3 = 1; },
	"Triangular" -> { currSignalType3 = 2; },
	"Square" -> { currSignalType3 = 3; }
];
var signalTypes4 = [
	"Sinusoidal" -> { currSignalType4 = 0; },
	"Saw" -> { currSignalType4 = 1; },
	"Triangular" -> { currSignalType4 = 2; },
	"Square" -> { currSignalType4 = 3; }
];

var freqScopeButton, scopeButton, lpfButton;
var freqScopeWindowAtStart = false, scopeWindow = false;

var operation = 'sourceOver', fraction = 1.0;
var algorithmSel, currIm, algorithmTypes, algorithmSelected;

s.boot;
Window.closeAll; // close all possible other windows to avoid problems

~voiceCount = 0;
~bend = 8192;
~notes = Array.newClear(128); // array of all possible midi notes

titlesFont = Font("Helvetica",18);
labelsFont = Font("Helvetica",14);

csCoarse = ControlSpec.new(1, 30, \lin, default:1, step:1);
csFine = ControlSpec.new(0, 1, \lin, default:0);
csAmp = ControlSpec.new(0, 1, \lin, default:0.5);
csModInd = ControlSpec.new(1, 6, \lin, default:1);

algorithmTypes = [
	'Cascade' -> {
		// set image
		currIm.free;
		currIm = Image.open(path ++ "/../images/algoCascataBIANCO.png");

		// change knobs
		ampKnob3.set("ModIndex", csModInd, initVal:1, initAction:true);
		ampKnob2.set("ModIndex", csModInd, initVal:1, initAction:true);

		// selected algorithm control variable
		algorithmSelected = 0;
	},
	'Parallel' -> {
		currIm.free;
		currIm = Image.open(path ++ "/../images/algo2-2BIANCO.png");

		ampKnob3.set("Amplitude", csAmp, initVal:0.5, initAction:true);
		ampKnob2.set("ModIndex", csModInd, initVal:1, initAction:true);

		algorithmSelected = 1;
	},
	'Triple carrier' -> {
		currIm.free;
		currIm = Image.open(path ++ "/../images/algo1-3BIANCO.png");

		ampKnob3.set("Amplitude", csAmp, initVal:0.5, initAction:true);
		ampKnob2.set("Amplitude", csAmp, initVal:0.5, initAction:true);

		algorithmSelected = 2;
	},
	'Triple modulator' -> {
		currIm.free;
		currIm = Image.open(path ++ "/../images/algo3-1BIANCO.png");

		ampKnob3.set("ModIndex", csModInd, initVal:1, initAction:true);
		ampKnob2.set("ModIndex", csModInd, initVal:1, initAction:true);

		algorithmSelected = 3;
	},
];

updateTimes = {
	// function that updates times in the model for the envelope design
	#currEnvTime1, currEnvTime2, currEnvTime3, currEnvTime4 = currEnvelope[0]*durationEnv;
	currEnvTime1 = currEnvTime2 - currEnvTime1;
	currEnvTime2 = currEnvTime3 - currEnvTime2;
	if(
	currEnvTime4.isNil;,
	{
		currEnvTime3 = 0;
	},
	{
		currEnvTime3 = currEnvTime4 - currEnvTime3;
	}
	);
	currEnvTime4 = nil;
};

updateEnvelope = {
	// function that update levels and times (through updateTimes) in the model for the envelope design
	arg newEnv;

	currEnvelope = newEnv;

	#currEnvLvl1, currEnvLvl2, currEnvLvl3, currEnvLvl4 = currEnvelope[1];
	updateTimes.value;
};

styleSelects = {
	// function that applies a proper stylind to a select
	arg select;
	select.setColors(menuBackground:Color.new(216/255, 200/255, 217/255));
	select.labelView.font_(labelsFont);
};

styleKnobs = {
	// function that applies a proper stylind to a knob
	arg knob;
	knob.numberView.align_(\center);
	knob.setColors(numBackground:Color.new(216/255, 200/255, 217/255), numTypingColor:Color.black);
	knob.labelView.font_(labelsFont).align_(\center);
};

//window creation
frameHeight = 525;
frameWidth = 892;

w = Window("FM Synth", Rect(
	Window.screenBounds.width/2 - (frameWidth/2),
	Window.screenBounds.height/2 - (frameHeight/2),
	frameWidth,
	frameHeight
), resizable:false).background_(Color.new(199/255,177/255,201/255));
w.front; // hidden by default
w.alwaysOnTop_(true);


// *********** OPERATOR 4 ***********
nameButton4 = Button(w, Rect(500,30,115,40)).states_([
	["Operator 4", Color.black, Color.white],
	["Operator 4", Color.black, Color.new(1,127/255,39/255)]
]).action_({
	currSwitch4 = (currSwitch4 + 1) % 2;

	~notes.do{arg synth; synth.set(\switch4, currSwitch4)}; //update all active synths
});
nameButton4.font_(titlesFont);

signTypeSel4 = EZPopUpMenu.new(w, bounds:Rect(500,75,115,50), label:"Signal type", items:signalTypes4, layout:\vert, initAction:true, globalAction:{
	~notes.do{arg synth; synth.set(\type4, currSignalType4)}; //update all active synths
});
styleSelects.value(signTypeSel4);

coarseKnob4 = EZKnob(parent:w, bounds:Rect(640,25,62,100), label:"Coarse", controlSpec:csCoarse, initAction:true, action:{
	arg val;
	currCoarse4 = val.value;

	~notes.do{arg synth; synth.set(\ocRatio4, currCoarse4)}; //update all active synths
});
styleKnobs.value(coarseKnob4);


fineKnob4 = EZKnob(parent:w, bounds:Rect(725,25,62,100), label:"Fine", controlSpec:csFine, initAction:true, action:{
	arg val;
	currFine4 = val.value;

	~notes.do{arg synth; synth.set(\ofRatio4, currFine4)}; //update all active synths
});
styleKnobs.value(fineKnob4);

ampKnob4 = EZKnob(parent:w, bounds:Rect(810,25,63,100), label:"ModIndex", controlSpec:csModInd, initAction:true, action:{
	arg val;
	currAmp4 = val.value;

	~notes.do{arg synth; synth.set(\mInd4, currAmp4)}; //update all active synths
});
styleKnobs.value(ampKnob4);


// *********** OPERATOR 3 ***********
nameButton3 = Button(w, Rect(500,155,115,40)).states_([
	["Operator 3", Color.black, Color.white],
	["Operator 3", Color.black, Color.new(153/255,217/255,234/255)]
]).action_({
	currSwitch3 = (currSwitch3 + 1) % 2;

	~notes.do{arg synth; synth.set(\switch3, currSwitch3)}; //update all active synths
});
nameButton3.font_(titlesFont);

signTypeSel3 = EZPopUpMenu.new(w, bounds:Rect(500,200,115,50), label:"Signal type", items:signalTypes3, layout:\vert, initAction:true, globalAction:{
	~notes.do{arg synth; synth.set(\type3, currSignalType3)}; //update all active synths
});
styleSelects.value(signTypeSel3);

coarseKnob3 = EZKnob(parent:w, bounds:Rect(640,150,62,100), label:"Coarse", controlSpec:csCoarse, initAction:true, action:{
	arg val;
	currCoarse3 = val.value;

	~notes.do{arg synth; synth.set(\ocRatio3, currCoarse3)}; //update all active synths
});
styleKnobs.value(coarseKnob3);

fineKnob3 = EZKnob(parent:w, bounds:Rect(725,150,62,100), label:"Fine", controlSpec:csFine, initAction:true, action:{
	arg val;
	currFine3 = val.value;

	~notes.do{arg synth; synth.set(\ofRatio3, currFine3)}; //update all active synths
});
styleKnobs.value(fineKnob3);

ampKnob3 = EZKnob(parent:w, bounds:Rect(810,150,63,100), label:"ModIndex", controlSpec:csModInd, initAction:true, action:{
	arg val;
	currAmp3 = val.value;

	// depending on the algorithm and the number of notes played simultaneously update the correct parameter in running synths
	if ( ((algorithmSelected!=1) && (algorithmSelected!=2)) ,
		{ ~notes.do{arg synth; synth.set(\mInd3, currAmp3)}; },
		{
			if (~voiceCount <= 1,
				{ ~notes.do{arg synth; synth.set(\amp3, currAmp3 )} },
				{ ~notes.do{arg synth; synth.set(\amp3, currAmp3/~voiceCount )} }
			);
		}
	);

});
styleKnobs.value(ampKnob3);


// *********** OPERATOR 2 ***********
nameButton2 = Button(w, Rect(500,280,115,40)).states_([
	["Operator 2", Color.black, Color.white],
	["Operator 2", Color.black, Color.new(34/255,177/255,76/255)]
]).action_({
	currSwitch2 = (currSwitch2 + 1) % 2;

	~notes.do{arg synth; synth.set(\switch2, currSwitch2)}; //update all active synths
});
nameButton2.font_(titlesFont);

signTypeSel2 = EZPopUpMenu.new(w, bounds:Rect(500,325,115,50), label:"Signal type", items:signalTypes2, layout:\vert, initAction:true, globalAction:{
	~notes.do{arg synth; synth.set(\type2, currSignalType2)}; //update all active synths
});
styleSelects.value(signTypeSel2);

coarseKnob2 = EZKnob(parent:w, bounds:Rect(640,275,62,100), label:"Coarse", controlSpec:csCoarse, initAction:true, action:{
	arg val;
	currCoarse2 = val.value;

	~notes.do{arg synth; synth.set(\ocRatio2, currCoarse2)}; //update all active synths
});
styleKnobs.value(coarseKnob2);

fineKnob2 = EZKnob(parent:w, bounds:Rect(725,275,62,100), label:"Fine", controlSpec:csFine, initAction:true, action:{
	arg val;
	currFine2 = val.value;

	~notes.do{arg synth; synth.set(\ofRatio2, currFine2)}; //update all active synths
});
styleKnobs.value(fineKnob2);

ampKnob2 = EZKnob(parent:w, bounds:Rect(810,275,63,100), label:"ModIndex", controlSpec:csModInd, initAction:true, action:{
	arg val;
	currAmp2 = val.value;

	// depending on the algorithm and the number of notes played simultaneously update the correct parameter in running synths
	if (algorithmSelected!=2,
		{ ~notes.do{arg synth; synth.set(\mInd2, currAmp2)}; },
		{
			if (~voiceCount <= 1,
				{ ~notes.do{arg synth; synth.set(\amp2, currAmp2 )} },
				{ ~notes.do{arg synth; synth.set(\amp2, currAmp2/~voiceCount )} }
			);
		}
	);
});
styleKnobs.value(ampKnob2);


// *********** OPERATOR 1 ***********
nameButton1 = Button(w, Rect(500,405,115,40)).states_([
	["Operator 1", Color.black, Color.new(1,242/255,0)],
	["Operator 1", Color.black, Color.white]
]).action_({
	currSwitch1 = (currSwitch1 + 1) % 2;

	~notes.do{arg synth; synth.set(\switch1, currSwitch1)}; //update all active synths
});
nameButton1.font_(titlesFont);

signTypeSel1 = EZPopUpMenu.new(w, bounds:Rect(500,450,115,50), label:"Signal type", items:signalTypes1, layout:\vert, initAction:true, globalAction:{
	~notes.do{arg synth; synth.set(\type1, currSignalType1)}; //update all active synths
});
styleSelects.value(signTypeSel1);

coarseKnob1 = EZKnob(parent:w, bounds:Rect(640,400,62,100), label:"Coarse", controlSpec:csCoarse, initAction:true, action:{
	arg val;
	currCoarse1 = val.value;

	~notes.do{arg synth; synth.set(\ocRatio1, currCoarse1)}; //update all active synths
});
styleKnobs.value(coarseKnob1);

fineKnob1 = EZKnob(parent:w, bounds:Rect(725,400,62,100), label:"Fine", controlSpec:csFine, initAction:true, action:{
	arg val;
	currFine1 = val.value;

	~notes.do{arg synth; synth.set(\ofRatio1, currFine1)}; //update all active synths
});
styleKnobs.value(fineKnob1);

ampKnob1 = EZKnob(parent:w, bounds:Rect(810,400,63,100), label:"Amplitude", controlSpec:csAmp, initAction:true, action:{
	arg val;
	currAmp1 = val.value;

	if (
		(~voiceCount <= 1);,
		{ ~notes.do{arg synth; synth.set(\amp1, currAmp1 )} },
		{ ~notes.do{arg synth; synth.set(\amp1, currAmp1/~voiceCount )} }
	); //update all active synths making sure normalization in case of polyphony is correct
});
styleKnobs.value(ampKnob1);


// ALGORITHM SELECTION
algorithmSel = EZPopUpMenu.new(w, bounds:Rect(10,25,135,65), label:"Algorithm type", items:algorithmTypes, globalAction:{
	w.drawFunc_({
		currIm.drawAtPoint(155@25, nil, operation, fraction);
	});
	w.refresh;
}, initAction:true, layout:\vert, margin:5@5, gap:5@5);
algorithmSel.labelView.font_(titlesFont);
algorithmSel.setColors(menuBackground:Color.new(216/255, 200/255, 217/255));

// LPF and SCOPES
lpfButton = Button(w, Rect(15,100,125,40)).states_([
	["Mouse LPF", Color.black, Color.white],
	["Mouse LPF", Color.black, Color.new(252/255, 245/255, 149/255)]
]).action_({
	if(
		lpfSwitch == 0,
		{
			lpfMessage.postln; // usage message on the postwindow
		}
	);


	lpfSwitch = (lpfSwitch + 1) % 2;
	~master.set(\filterSwitch, lpfSwitch); // toggle filter in master synth
});
lpfButton.font_(titlesFont);

scopeButton = Button(w, Rect(15,155,125,40)).states_([
	["Scope", Color.black, Color.new(252/255, 245/255, 149/255)]
]).action_({
	if (
		scopeWindow,
		{ scopeMessage.postln; },
		{
			Stethoscope.new.size_(328).window.onClose_({ scopeWindow = false; }).alwaysOnTop_(true);
			scopeWindow = true;
		}
	);

});
scopeButton.font_(titlesFont);

freqScopeButton = Button(w, Rect(15,210,125,40)).states_([
	["FreqScope", Color.black, Color.new(252/255, 245/255, 149/255)]
]).action_({

	if (
		freqScopeWindowAtStart == false,
		{ FreqScope.new; }
	);

	if (
		FreqScope.scopeOpen && freqScopeWindowAtStart == true ,
		{ freqScopeMessage.postln; },
		{ FreqScope.new; }
	);

	if (
		freqScopeWindowAtStart == false,
		{ freqScopeWindowAtStart = true; }
	);

});
freqScopeButton.font_(titlesFont);

// ENV/ENV DURATION SELECTION & VIEW
envViewLabel = StaticText.new(w, Rect(15,275,140,50)).string_("Carrier envelope").font_(titlesFont);
envView = EnvelopeView.new(w, Rect(10,325,475,175)).keepHorizontalOrder_(true).action_({
	arg val;
	updateEnvelope.value(val.value);
});

envDurationSel = EZPopUpMenu.new(w, bounds:Rect(175,275,150,50), label:"Envelope duration", items:envDurations, labelWidth:65, globalAction:{
	updateTimes.value;
}, gap:10@10, margin:5@5);
styleSelects.value(envDurationSel);

envTypeSel = EZPopUpMenu.new(w, bounds:Rect(320,275,169,50), label:"Envelope type", items:envTypes, globalAction:{
	envView.setEnv(selectedEnvType);
	updateEnvelope.value(envView.value);
}, initAction:true, gap:10@10, margin:5@5);
styleSelects.value(envTypeSel);

 // set default value for currEnvelope, times and levels
currEnvelope = envView.value;
#currEnvLvl1, currEnvLvl2, currEnvLvl3, currEnvLvl4 = currEnvelope[1];
#currEnvTime1, currEnvTime2, currEnvTime3, currEnvTime4 = currEnvelope[0]*durationEnv;
currEnvTime1 = currEnvTime2 - currEnvTime1;
currEnvTime2 = currEnvTime3 - currEnvTime2;
currEnvTime3 = currEnvTime4 - currEnvTime3;
currEnvTime4 = nil;

w.onClose({currIm.free;}); // on close free the displayed image

// ============================================ SYNTHS ============================================

// ALGORITHM 1: CASCATA
SynthDef(\fm1, {

	arg type1=0,type2=0,type3=0,type4=0,
	//test = 0,
	freq=440,
	amp1=0.2,
	gate = 0,
	ocRatio1=1,ocRatio2=1,ocRatio3=1,ocRatio4=1, //coarse ratio (integer)
	ofRatio1=0,ofRatio2=0,ofRatio3=0,ofRatio4=0, //fine ratio: value between (0,1) (float)
	mInd2=1,mInd3=1,mInd4=1, // modulation index = modAmp/modFreq; float value (1,6)
	switch1=1,switch2=1,switch3=1,switch4=1,
	envTime1, envTime2, envTime3, releaseNode=2,
	envLvl1, envLvl2, envLvl3, envLvl4,
	inbus,
	bend=0;
	var op1,op2,op3,op4,sig,env,levels, times;

	levels = [envLvl1, envLvl2, envLvl3, envLvl4];
	times = [envTime1, envTime2, envTime3];

	op4 = Select.ar( // select correct waveform in rt
		type4,
		[
			SinOsc.ar(freq*(ocRatio4+ofRatio4),mul:freq*(ocRatio4+ofRatio4)*mInd4),
			LFSaw.ar(freq*(ocRatio4+ofRatio4),mul:freq*(ocRatio4+ofRatio4)*mInd4),
			LFTri.ar(freq*(ocRatio4+ofRatio4),mul:freq*(ocRatio4+ofRatio4)*mInd4),
			LFPulse.ar(freq*(ocRatio4+ofRatio4),mul:freq*(ocRatio4+ofRatio4)*mInd4)
	])*switch4;

	op3 = Select.ar(
		type3,
		[
			SinOsc.ar(freq*(ocRatio3+ofRatio3)+op4,mul:(freq*(ocRatio3+ofRatio3)+op4) * mInd3),
			LFSaw.ar(freq*(ocRatio3+ofRatio3)+op4,mul:(freq*(ocRatio3+ofRatio3)+op4) * mInd3),
			LFTri.ar(freq*(ocRatio3+ofRatio3)+op4,mul:(freq*(ocRatio3+ofRatio3)+op4) * mInd3),
			LFPulse.ar(freq*(ocRatio3+ofRatio3)+op4,mul:(freq*(ocRatio3+ofRatio3)+op4) * mInd3)
	])*switch3;

	op2 = Select.ar(
		type2,
		[
			SinOsc.ar(freq*(ocRatio2+ofRatio2)+op3,mul:(freq*(ocRatio2+ofRatio2)+op3) * mInd2),
			LFSaw.ar(freq*(ocRatio2+ofRatio2)+op3,mul: (freq*(ocRatio2+ofRatio2)+op3) * mInd2),
			LFTri.ar(freq*(ocRatio2+ofRatio2)+op3,mul: (freq*(ocRatio2+ofRatio2)+op3) * mInd2),
			LFPulse.ar(freq*(ocRatio2+ofRatio2)+op3,mul:(freq*(ocRatio2+ofRatio2)+op3) * mInd2)
	])*switch2;

	op1 = Select.ar(
		type1,
		[
			SinOsc.ar(freq*(ocRatio1+ofRatio1)+op2*bend.midiratio,mul:amp1),
			LFSaw.ar(freq*(ocRatio1+ofRatio1)+op2*bend.midiratio,mul:amp1),
			LFTri.ar(freq*(ocRatio1+ofRatio1)+op2*bend.midiratio,mul:amp1),
			LFPulse.ar(freq*(ocRatio1+ofRatio1)+op2*bend.midiratio,mul:amp1)
	])*switch1;

	env = EnvGen.ar(Env.new(levels:levels, times:times, releaseNode:releaseNode), gate:gate, doneAction:2);
	sig = op1*env;
	Out.ar(inbus,sig);
}).add;

//ALGORITHM 2: PARALLEL
SynthDef(\fm2, {

	arg type1=0,type2=0,type3=0,type4=0, typeSig = 0,
	freq=440,
	amp1=0.2,amp3=0,
	gate = 0,
	ocRatio1=1,ocRatio2=1,ocRatio3=1,ocRatio4=1,
	ofRatio1=0,ofRatio2=0,ofRatio3=0,ofRatio4=0,
	mInd2=1,mInd4=1,
	switch1=1,switch2=1,switch3=1,switch4=1,
	envTime1, envTime2, envTime3, releaseNode=2,
	envLvl1, envLvl2, envLvl3, envLvl4,
	inbus,
	bend=0;
	var op1,op2,op3,op4,sig1,sig2,env,levels,times;

	levels = [envLvl1, envLvl2, envLvl3, envLvl4];
	times = [envTime1, envTime2, envTime3];

	op4 = Select.ar(
		type4,
		[
			SinOsc.ar(freq*(ocRatio4+ofRatio4),mul:freq*(ocRatio4+ofRatio4)*mInd4),
			LFSaw.ar(freq*(ocRatio4+ofRatio4),mul:freq*(ocRatio4+ofRatio4)*mInd4),
			LFTri.ar(freq*(ocRatio4+ofRatio4),mul:freq*(ocRatio4+ofRatio4)*mInd4),
			LFPulse.ar(freq*(ocRatio4+ofRatio4),mul:freq*(ocRatio4+ofRatio4)*mInd4)
	])*switch4;

	op3 = Select.ar(
		type3,
		[
			SinOsc.ar(freq*(ocRatio3+ofRatio3)+op4,mul:amp3/(switch1+switch3)),
			LFSaw.ar(freq*(ocRatio3+ofRatio3)+op4,mul:amp3/(switch1+switch3)),
			LFTri.ar(freq*(ocRatio3+ofRatio3)+op4,mul:amp3/(switch1+switch3)),
			LFPulse.ar(freq*(ocRatio3+ofRatio3)+op4,mul:amp3/(switch1+switch3))
	])*switch3;

	op2 = Select.ar(
		type2,
		[
			SinOsc.ar(freq*(ocRatio2+ofRatio2),mul:(freq*(ocRatio2+ofRatio2)) * mInd2),
			LFSaw.ar(freq*(ocRatio2+ofRatio2),mul: (freq*(ocRatio2+ofRatio2)) * mInd2),
			LFTri.ar(freq*(ocRatio2+ofRatio2),mul: (freq*(ocRatio2+ofRatio2)) * mInd2),
			LFPulse.ar(freq*(ocRatio2+ofRatio2),mul:(freq*(ocRatio2+ofRatio2)) * mInd2)
	])*switch2;

	op1 = Select.ar(
		type1,
		[
			SinOsc.ar(freq*(ocRatio1+ofRatio1)+op2,mul:amp1/(switch1+switch3)),
			LFSaw.ar(freq*(ocRatio1+ofRatio1)+op2,mul:amp1/(switch1+switch3)),
			LFTri.ar(freq*(ocRatio1+ofRatio1)+op2,mul:amp1/(switch1+switch3)),
			LFPulse.ar(freq*(ocRatio1+ofRatio1)+op2,mul:amp1/(switch1+switch3))
	])*switch1;


	env = EnvGen.ar(Env.new(levels:levels, times:times, releaseNode:releaseNode), gate:gate, doneAction:2);
	sig1 = op3*env;
	sig2 = op1*env;

	Out.ar(inbus, Mix.ar([sig1,sig2]));
}).add;

// ALGORITHM 3: TRIPLE CARRIER 1 - 3
// 4-->1,2,3
SynthDef(\fm3, {

	arg type1=0,type2=0,type3=0,type4=0,
	freq=440,
	amp1=0.2,amp2=0,amp3=0,
	gate = 0,
	ocRatio1=1,ocRatio2=1,ocRatio3=1,ocRatio4=1,
	ofRatio1=0,ofRatio2=0,ofRatio3=0,ofRatio4=0,
	mInd4=1,
	switch1=1,switch2=1,switch3=1,switch4=1,
	envTime1, envTime2, envTime3, releaseNode=2,
	envLvl1, envLvl2, envLvl3, envLvl4,
	inbus,
	bend=0;
	var op1,op2,op3,op4,sig1,sig2,sig3,env,levels,times;

	levels = [envLvl1, envLvl2, envLvl3, envLvl4];
	times = [envTime1, envTime2, envTime3];

	op4 = Select.ar(
		type4,
		[
			SinOsc.ar(freq*(ocRatio4+ofRatio4),mul:freq*(ocRatio4+ofRatio4)*mInd4),
			LFSaw.ar(freq*(ocRatio4+ofRatio4),mul:freq*(ocRatio4+ofRatio4)*mInd4),
			LFTri.ar(freq*(ocRatio4+ofRatio4),mul:freq*(ocRatio4+ofRatio4)*mInd4),
			LFPulse.ar(freq*(ocRatio4+ofRatio4),mul:freq*(ocRatio4+ofRatio4)*mInd4)
	])*switch4;

	op3 = Select.ar(
		type3,
		[
			SinOsc.ar(freq*(ocRatio3+ofRatio3)+op4,mul:amp3/(switch3+switch2+switch1)),
			LFSaw.ar(freq*(ocRatio3+ofRatio3)+op4,mul:amp3/(switch3+switch2+switch1)),
			LFTri.ar(freq*(ocRatio3+ofRatio3)+op4,mul:amp3/(switch3+switch2+switch1)),
			LFPulse.ar(freq*(ocRatio3+ofRatio3)+op4,mul:amp3/(switch3+switch2+switch1))
	])*switch3;

	op2 = Select.ar(
		type2,
		[
			SinOsc.ar(freq*(ocRatio2+ofRatio2)+op4,mul:amp2/(switch3+switch2+switch1)),
			LFSaw.ar(freq*(ocRatio2+ofRatio2)+op4,mul: amp2/(switch3+switch2+switch1)),
			LFTri.ar(freq*(ocRatio2+ofRatio2)+op4,mul: amp2/(switch3+switch2+switch1)),
			LFPulse.ar(freq*(ocRatio2+ofRatio2)+op4,mul:amp2/(switch3+switch2+switch1))
	])*switch2;

	op1 = Select.ar(
		type1,
		[
			SinOsc.ar(freq*(ocRatio1+ofRatio1)+op4,mul:amp1/(switch3+switch2+switch1)),
			LFSaw.ar(freq*(ocRatio1+ofRatio1)+op4,mul:amp1/(switch3+switch2+switch1)),
			LFTri.ar(freq*(ocRatio1+ofRatio1)+op4,mul:amp1/(switch3+switch2+switch1)),
			LFPulse.ar(freq*(ocRatio1+ofRatio1)+op4,mul:amp1/(switch3+switch2+switch1))
	])*switch1;

	env = EnvGen.ar(Env.new(levels:levels, times:times, releaseNode:releaseNode), gate:gate, doneAction:2);
	sig1 = op1*env;
	sig2 = op2*env;
	sig3 = op3*env;

	Out.ar(inbus, Mix.ar([sig1,sig2,sig3]));
}).add;

// ALGORITHM 4: TRIPLE MODULATOR 3 - 1
//2,3,4 --> 1
SynthDef(\fm4, {

	arg type1=0,type2=0,type3=0,type4=0,
	freq=440,
	amp1=0.2,
	gate = 0,
	ocRatio1=1,ocRatio2=1,ocRatio3=1,ocRatio4=1,
	ofRatio1=0,ofRatio2=0,ofRatio3=0,ofRatio4=0,
	mInd2=1,mInd3=1,mInd4=1,
	switch1=1,switch2=1,switch3=1,switch4=1,
	envTime1, envTime2, envTime3, releaseNode=2,
	envLvl1, envLvl2, envLvl3, envLvl4,
	inbus,
	bend=0;
	var op1,op2,op3,op4,sig,env,levels,times;

	levels = [envLvl1, envLvl2, envLvl3, envLvl4];
	times = [envTime1, envTime2, envTime3];

	op4 = Select.ar(
		type4,
		[
			SinOsc.ar(freq*(ocRatio4+ofRatio4),mul:freq*(ocRatio4+ofRatio4)*mInd4),
			LFSaw.ar(freq*(ocRatio4+ofRatio4),mul:freq*(ocRatio4+ofRatio4)*mInd4),
			LFTri.ar(freq*(ocRatio4+ofRatio4),mul:freq*(ocRatio4+ofRatio4)*mInd4),
			LFPulse.ar(freq*(ocRatio4+ofRatio4),mul:freq*(ocRatio4+ofRatio4)*mInd4)
	])*switch4;

	op3 = Select.ar(
		type3,
		[
			SinOsc.ar(freq*(ocRatio3+ofRatio3),mul:(freq*(ocRatio3+ofRatio3)) * mInd3),
			LFSaw.ar(freq*(ocRatio3+ofRatio3),mul: (freq*(ocRatio3+ofRatio3)) * mInd3),
			LFTri.ar(freq*(ocRatio3+ofRatio3),mul: (freq*(ocRatio3+ofRatio3)) * mInd3),
			LFPulse.ar(freq*(ocRatio3+ofRatio3),mul: (freq*(ocRatio3+ofRatio3)) * mInd3)
	])*switch3;

	op2 = Select.ar(
		type2,
		[
			SinOsc.ar(freq*(ocRatio2+ofRatio2),mul:(freq*(ocRatio2+ofRatio2)) * mInd2),
			LFSaw.ar(freq*(ocRatio2+ofRatio2),mul: (freq*(ocRatio2+ofRatio2)) * mInd2),
			LFTri.ar(freq*(ocRatio2+ofRatio2),mul: (freq*(ocRatio2+ofRatio2)) * mInd2),
			LFPulse.ar(freq*(ocRatio2+ofRatio2),mul:(freq*(ocRatio2+ofRatio2)) * mInd2)
	])*switch2;

	op1 = Select.ar(
		type1,
		[
			SinOsc.ar(freq*(ocRatio1+ofRatio1)+op2+op3+op4,mul:amp1),
			LFSaw.ar(freq*(ocRatio1+ofRatio1)+op2+op3+op4,mul:amp1),
			LFTri.ar(freq*(ocRatio1+ofRatio1)+op2+op3+op4,mul:amp1),
			LFPulse.ar(freq*(ocRatio1+ofRatio1)+op2+op3+op4,mul:amp1)
	])*switch1;

	env = EnvGen.ar(Env.new(levels:levels, times:times, releaseNode:releaseNode), gate:gate, doneAction:2);
	sig = op1*env;
	Out.ar(inbus,sig);
}).add;

// master synth receive input from the active algorithm and applies the LPF if the user enables it
	SynthDef(\master, {
		arg inbus,filterSwitch;
		var sig,in;
		in = In.ar(inbus,1);
		sig = Select.ar(
			filterSwitch,
			[
				in,
				RLPF.ar(in,MouseX.kr(20,20000,1),MouseY.kr());
		]);
		Out.ar([0,1],sig);
	}).add;


// ============================================ MIDI ============================================

s.waitForBoot({ // in case of the first bootup, we wait for the server to be ready

	MIDIClient.init;
	MIDIIn.connectAll;
	"\n\n".postln;

	~bus = Bus.audio(s,1);

	~master = Synth(\master, [\inbus, ~bus, \filterSwitch, lpfSwitch]);

	// note on mididef
	MIDIdef.noteOn(\noteOnSymbol, {
		arg vel, noteNum, chan, src;
		var linVel = vel.linexp(1,127,0.01,3), synth;

		switch (
			algorithmSelected, // generate correct synth
			// Cascata
			0, {
				synth = Synth.new(\fm1, [
					\switch1, currSwitch1, \switch2, currSwitch2, \switch3, currSwitch3, \switch4, currSwitch4,
					\type1, currSignalType1, \type2, currSignalType2, \type3, currSignalType3, \type4, currSignalType4,
					\freq, noteNum.midicps,
					\ocRatio4, currCoarse4, \ofRatio4, currFine4,
					\ocRatio3, currCoarse3, \ofRatio3, currFine3,
					\ocRatio2, currCoarse2, \ofRatio2, currFine2,
					\ocRatio1, currCoarse1, \ofRatio1, currFine1,
					\amp1, currAmp1, \mInd2, currAmp2, \mInd3, currAmp3, \mInd4, currAmp4,
					\gate, 1,
					\envTime1, currEnvTime1, \envTime2, currEnvTime2, \envTime3, currEnvTime3,
					\envLvl1, currEnvLvl1, \envLvl2, currEnvLvl2, \envLvl3, currEnvLvl3, \envLvl4, currEnvLvl4,
					\releaseNode, releaseNode,
					\inbus,~bus,
					\bend, ~bend.linlin(0,16383,-2,2)
			]); },

			// 2-2
			1, {
				synth = Synth.new(\fm2, [
					\switch1, currSwitch1, \switch2, currSwitch2, \switch3, currSwitch3, \switch4, currSwitch4,
					\type1, currSignalType1, \type2, currSignalType2, \type3, currSignalType3, \type4, currSignalType4,
					\freq, noteNum.midicps,
					\ocRatio4, currCoarse4, \ofRatio4, currFine4,
					\ocRatio3, currCoarse3, \ofRatio3, currFine3,
					\ocRatio2, currCoarse2, \ofRatio2, currFine2,
					\ocRatio1, currCoarse1, \ofRatio1, currFine1,
					\amp1, currAmp1, \mInd2, currAmp2, \amp3, currAmp3, \mInd4, currAmp4,
					\gate, 1,
					\envTime1, currEnvTime1, \envTime2, currEnvTime2, \envTime3, currEnvTime3,
					\envLvl1, currEnvLvl1, \envLvl2, currEnvLvl2, \envLvl3, currEnvLvl3, \envLvl4, currEnvLvl4,
					\releaseNode, releaseNode,
					\inbus,~bus,
					\bend, ~bend.linlin(0,16383,-2,2)
				]);

				if ((~voiceCount <= 1);,
					{ ~notes.do{arg synth; synth.set(\amp3, currAmp3 )} },
					{ ~notes.do{arg synth; synth.set(\amp3, currAmp3/~voiceCount )} }
			); },

			// 1-3
			2, {
				synth = Synth.new(\fm3, [
					\switch1, currSwitch1, \switch2, currSwitch2, \switch3, currSwitch3, \switch4, currSwitch4,
					\type1, currSignalType1, \type2, currSignalType2, \type3, currSignalType3, \type4, currSignalType4,
					\freq, noteNum.midicps,
					\ocRatio4, currCoarse4, \ofRatio4, currFine4,
					\ocRatio3, currCoarse3, \ofRatio3, currFine3,
					\ocRatio2, currCoarse2, \ofRatio2, currFine2,
					\ocRatio1, currCoarse1, \ofRatio1, currFine1,
					\amp1, currAmp1, \amp2, currAmp2, \amp3, currAmp3, \mInd4, currAmp4,
					\gate, 1,
					\envTime1, currEnvTime1, \envTime2, currEnvTime2, \envTime3, currEnvTime3,
					\envLvl1, currEnvLvl1, \envLvl2, currEnvLvl2, \envLvl3, currEnvLvl3, \envLvl4, currEnvLvl4,
					\releaseNode, releaseNode,
					\inbus,~bus,
					\bend, ~bend.linlin(0,16383,-2,2)
				]);

				if ((~voiceCount <= 1);,
					{ ~notes.do{arg synth; synth.set(\amp2, currAmp2 )} },
					{ ~notes.do{arg synth; synth.set(\amp2, currAmp2/~voiceCount )} }
				);
				if ((~voiceCount <= 1);,
					{ ~notes.do{arg synth; synth.set(\amp3, currAmp3 )} },
					{ ~notes.do{arg synth; synth.set(\amp3, currAmp3/~voiceCount )} }
			); },

			// 3-1
			3, {
				synth = Synth.new(\fm4, [
					\switch1, currSwitch1, \switch2, currSwitch2, \switch3, currSwitch3, \switch4, currSwitch4,
					\type1, currSignalType1, \type2, currSignalType2, \type3, currSignalType3, \type4, currSignalType4,
					\freq, noteNum.midicps,
					\ocRatio4, currCoarse4, \ofRatio4, currFine4,
					\ocRatio3, currCoarse3, \ofRatio3, currFine3,
					\ocRatio2, currCoarse2, \ofRatio2, currFine2,
					\ocRatio1, currCoarse1, \ofRatio1, currFine1,
					\amp1, currAmp1, \mInd2, currAmp2, \mInd3, currAmp3, \mInd4, currAmp4,
					\gate, 1,
					\envTime1, currEnvTime1, \envTime2, currEnvTime2, \envTime3, currEnvTime3,
					\envLvl1, currEnvLvl1, \envLvl2, currEnvLvl2, \envLvl3, currEnvLvl3, \envLvl4, currEnvLvl4,
					\releaseNode, releaseNode,
					\inbus,~bus,
					\bend, ~bend.linlin(0,16383,-2,2)
				]);
			}
		);

		~notes[noteNum] = synth; // insert in array of notes

		~voiceCount = ~voiceCount + 1;
		~notes.do( { arg synth; synth.set(\amp1, (currAmp1/~voiceCount)/*.postln*/) } ) ;


		synth.onFree({ var size;
			~voiceCount = ~voiceCount - 1;
		});
	});

	MIDIdef.noteOff(\noteOffSymbol,{
		arg vel, noteNum;
		~notes[noteNum].set(\gate, 0); // trigger release
		//~notes[noteNum].free;
		~notes[noteNum] = nil;
	});

	MIDIdef.bend(\bend, {
		arg val,chan,src;
		//[val,chan,src].postln;
		~bend = val;
		~notes.do{
			arg synth;	synth.set(\bend,val.linlin(0,16383,-2,2))};
	});

}, onFailure:{ bootingMessage.postln; })

)