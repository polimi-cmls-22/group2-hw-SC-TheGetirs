# The Getris's FM Synth

## Folder structure
```bash
.
├── README.md
├── UGen graphs
│   ├── fm1.pdf
│   ├── fm2.pdf
│   ├── fm3.pdf
│   ├── fm4.pdf
│   └── master.pdf
├── images
│   ├── algo1-3BIANCO.png
│   ├── algo2-2BIANCO.png
│   ├── algo3-1BIANCO.png
│   ├── algoCascataBIANCO.png
│   └── realegetir.png
├── report HW1 - TheGetirs.pdf
└── sc
    └── FMSynth.scd
```

## Introduction 
Our project consists in the design of a synthesizer based on the FM synthesis.

![image](https://user-images.githubusercontent.com/99413338/161602891-ea2be178-6b7e-4280-b4fb-aea155d6c44e.png)

## Operators

We have implemented a synth with 4 operators. Each one can be turned on by clicking on his label, and can be used to generate 4 different type of signals (Sine, Saw, Triangle and Pulse Train). It can also be customized through 3 knobs: Coarse, Fine and, one between
* Amplitude, if the operator is a carrier
* ModIndex, if it is a modulator

![image](https://user-images.githubusercontent.com/99413338/161450950-8cb29546-8c7e-4b0f-8c6c-be112435a1a1.png)

## Algorithms

The operators can be connected with each other in 4 different algorithms: cascade, parallel, triple carrier and triple modulator. In the left section of the interface, the user can select which scheme to use, and can also see the chain connections through a window. In order to further visualize the output result, we have implemented two buttons: "Scope", that opens an oscilloscope, and "Freqscope", that opens a frequency spectrum analyzer. In this section is also placed a Low Pass Filter button that allows the user to applya filterint to the output signal moving the mouse left or right, controlling the cutoff frequency, and bottom and top, controlling resonance.

![image](https://user-images.githubusercontent.com/99413338/161451155-0b47c560-4763-469d-b12e-429e50d092b9.png)

## Envelope section 

Under the algorithms section, we have implemented an envelope section. 4 types of envelopes can be selected through a dropdown window: ADSR, ASR, triangle and perc. The user can also choose the duration of the envelope that can go from 1 to 4 seconds. 
The envelope shape can be customized through the designing section in which you can move the dots to modify the parameters of the envelope, with a graphic feedback.

![image](https://user-images.githubusercontent.com/99413338/161451176-44e90b99-d4de-4f66-a4ec-311d8c0b9001.png)

## Authors
![getirs](images/realegetir.png) 

Di Palma - Gargiulo - Orsatti - Morena - Perego