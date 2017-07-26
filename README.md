# Proof-of-concept self-tutoring app

A flashcard-style app demonstrating two distinguishing feature: 'M to N' relationships between face one and face two, and flexible card tagging 

## Overview

There are many good flashcard apps with excellent feature sets, including most of the features in this app.

It is difficult, however, to find an app that replicates a particular data structure that is often found in the study of foreign languages. In real-life, it is common to have several concepts that could be considered 'correct' for both 'question' and 'answer.' There might, for example, be M words of language one that map, more or less, to some N words of language two. 

This is accommodated in most flashcard apps by working around it in several ways. One might create duplicative cards, each showing a single m -> n, or one might aggregate all possible M into one 'question' face, and all possible 'answers' onto the other face. Both of these solutions are unsatisfying. Duplicative cards will mark the learner as incorrect if a perfectly valid but not-listed answer is given. And aggregative cards are cumbersome to create and maintain, and don't offer the learner a quick sense of whether his answer is correct.

* This app allows the learner to create cards with multiple valid values for face one and for face two. Any of the n possible 'correct' answers entered will be counted as correct when asked any of the m possible face one items.
* Cards may be tagged with multiple comma-separated terms: for example, a card might have tags 'spanish', 'verb' and 'present tense'
* The learner can enable/disable any cards bearing a particular tag. E.g. unchecking 'welsh' makes every card with that tag inactive
* A spaced-repetition algorithm is used to determine a list of cards that should be studied on a particular day
* A Hint button may be repeatedly tapped to show more of the word, in the style of Hangman
* Progress is gamified, as the learner gets full points for a correct answer, but only partial points for answers after hints are shown.
* If the learner has international keyboard enabled, the app will attempt to switch to the correct keyboard for the langauge of a particular card. 
* If the card has an answer in ancient Greek (a preoccupation of the app author) the greek keyboard features a custom toolbar that can used to add the proper diacritical marks (rough/smooth breathing, acute/grave/circumflex)
* Currently, the library of learner cards and progress is stored in Core Data on a single device (thus, it persists between sessions)

## Build Requirements

Xcode 8.3 or later

## Runtime Requirements

iOS 9.0 or later

## Sample Screenshots
(taken from iphone SE)

Main screen:

<img src="/learnit/screen_01.PNG" width="200" style="border: 3px solid black; border-radius: 10px;">

Adding a new card:

<img src="/learnit/screen_02.PNG" width="200" style="border: 3px solid black; border-radius: 10px;">

Browsing existing cards:

<img src="/learnit/screen_04.PNG" width="200" style="border: 3px solid black; border-radius: 10px;">

Editing and showing detail of a particular card:

<img src="/learnit/screen_03.PNG" width="200" style="border: 3px solid black; border-radius: 10px;">

Browsing all tags in use. Cards with such tags are made active/inactive by tapping:

<img src="/learnit/screen_05.PNG" width="200" style="border: 3px solid black; border-radius: 10px;">

Configuration for learner:

<img src="/learnit/screen_06.PNG" width="200" style="border: 3px solid black; border-radius: 10px;">

Main screen, showing hint:

<img src="/learnit/screen_07.PNG" width="200" style="border: 3px solid black; border-radius: 10px;">

Main screen, showing correct answer feedback:

<img src="/learnit/screen_08.PNG" width="200" style="border: 3px solid black; border-radius: 10px;">


