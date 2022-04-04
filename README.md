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
│   └── algoCascataBIANCO.png
├── report TheGetirs.pdf
└── sc
    └── FMSynth.scd
```

## Introduction 
The main idea of our project is to create a synthesizer based on the FM synthesis.

![image](https://user-images.githubusercontent.com/99413338/161602891-ea2be178-6b7e-4280-b4fb-aea155d6c44e.png)

## Operators

We have implemented 4 operators that can be connected to each other. Each operator, that can be turned on by clicking on his label, can generate 4 different type of signals (Sine, Saw, Triangle and Pulse Train) and can be customized through 3 knobs: Coarse, Fine and, one between
* Amplitude, if the operator is a carrier
* ModIndex, if it is a modulator

![image](https://user-images.githubusercontent.com/99413338/161450950-8cb29546-8c7e-4b0f-8c6c-be112435a1a1.png)

## Algorithms

The operators can be connected through each other in 4 different ways: cascade, parallel, triple carrier and triple modulator. In the left section of the interface, the executor can select wich algorithm has to be used, and can see the chain connections through a window. In order to see the output result, we have implemented two buttons: "Scope" for the oscilloscope and "Freqscope" for the frequency spectrum analyzer. In this section is also implemented a Low Pass Filter button that allows the user to filter the output signal moving the mouse left or right, controlling the cutoff frequency, and bottom and top, controlling resonance.

![image](https://user-images.githubusercontent.com/99413338/161451155-0b47c560-4763-469d-b12e-429e50d092b9.png)

## Envelope section 

Under the algorithms section, we have implemented the envelope section: 4 types of envelopes can be selected through a dropdown window: ADSR, ASR, triangle and perc. The user can also choose the duration of the envelope that can go from 1 to 4 seconds. 
The envelope shape can be customized through the interactive section in which you can set the dots to assign the parameters of the envelope, with a graphic feedback.

![image](https://user-images.githubusercontent.com/99413338/161451176-44e90b99-d4de-4f66-a4ec-311d8c0b9001.png)