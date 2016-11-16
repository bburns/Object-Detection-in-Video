

Part of Yong Jae Lee's key-segments code, modified to add another motion cue to the ranking function. 

Brian Burns <bburns@cs.utexas.edu>
Oct 2011


Pipeline
========

The main pipeline is:

> getScores [puts scores.mat into each video's scores subfolder]
> gatherScores [puts all the scores together into one matrix, saved as scoresAll.mat]
> compareScores [generates boxplots for the top 50 scores of each ranking method, including regression]


Libsvm
======

Libsvm should be downloaded and put into the util subfolder. 
Version 3.1 of the Matlab interface is only compiled for 
32-bit linux, so the nonlinear regression won't work on 
64-bit machines, unless you compile it for it. 


Other files
===========

getAppMotionRegionScores [yjlee's code, modified to add second motion cue]
getMotionCue1 [code for the first motion cue]
getMotionCue2 [code for the new motion cue]
getRegressionLinear [called by compareScores]
getRegressionNonlinear [called by compareScores - calls libsvm]

showMotionCue [generates figures showing how the motion cues work]
findExamples [find good examples to compare the motion cues]
showRegion [show a single region by calling showMotionCue]
showStaticScores [shows a plot of endres static scores]

getImageType [determines the type of image in a folder, eg jpg, png]
selectRows [selects rows from a matrix]
motionRegion [work started on extracting regions based on motion]

scoresAll.mat [data generated for segtrack videos, can be run through compareScores]

paper/
motion2.pdf [paper describing the project]
motion2.docx [source for paper]

