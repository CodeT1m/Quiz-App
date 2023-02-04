import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:quiz_app/api_services.dart';
import 'package:quiz_app/constants/colors.dart';
import 'package:quiz_app/constants/images.dart';
import 'package:quiz_app/widgets/text_style.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int seconds = 60;
  Timer? timer;
  var currentQuestionIndex = 0;
  int points = 0;

  startTimer() { // start quiz timer
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (seconds > 0) {
          seconds--;  // decrease by 1
        } else {
          timer.cancel();
        }
      });
    });
  }

  late Future quiz; // get quiz from API
  var isLoaded = false;
  var optionsList = [];
  var optionsColor = [
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white
  ];

  resetColors() {
    optionsColor = [
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white,
      Colors.white
    ];
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    quiz = getQuiz(); // on getting to this quiz screen, collect all d API quiz
    startTimer();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [blue, darkBlue]),
            ),
            child: FutureBuilder(
                // widget to display the quiz info
                future: quiz,
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    // if data is gotten from API
                    var data = snapshot.data['results'];
                    if (isLoaded == false) {
                      // load data
                      optionsList = data[currentQuestionIndex][
                          'incorrect_answers']; // get list of incorrect answers
                      optionsList.add(data[currentQuestionIndex][
                          'correct_answer']); // add d correct answer to the list
                      optionsList.shuffle(); // then shuffle them 2geda
                      isLoaded = true;
                    }

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    border: Border.all(
                                      color: lightgrey,
                                      width: 2,
                                    )),
                                child: IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(
                                      CupertinoIcons.xmark,
                                      color: Colors.white,
                                      size: 28,
                                    )),
                              ),
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  normalText('$seconds', Colors.white, 22),
                                  SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: CircularProgressIndicator(
                                      value: seconds / 60,
                                      valueColor: const AlwaysStoppedAnimation(
                                          Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border:
                                      Border.all(color: lightgrey, width: 2),
                                ),
                                child: TextButton.icon(
                                  onPressed: null,
                                  icon: const Icon(
                                    CupertinoIcons.heart_fill,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  label: normalText('Like', Colors.white, 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Image.asset(
                            ideas,
                            width: 200,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Align(
                              alignment: Alignment.centerLeft,
                              child: normalText(
                                  'Question ${currentQuestionIndex + 1} of ${data.length}',
                                  lightgrey,
                                  18)),
                          const SizedBox(
                            height: 20,
                          ),
                          normalText(
                            data[currentQuestionIndex][
                                'question'], // currentQuestionIndex is just like an array increasing it's value
                            Colors.white,
                            20,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: optionsList.length,
                              itemBuilder: (context, index) {
                                var answer = data[currentQuestionIndex]
                                    ['correct_answer'];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (answer.toString() ==
                                          optionsList[index].toString()) {
                                        // if option touched is the correct answer
                                        optionsColor[index] = Colors
                                            .green; // change color to green

                                            points = points + 10;
                                      } else {
                                        optionsColor[index] =
                                            Colors.red; // otherwise red
                                      }

                                      if (currentQuestionIndex < data.length - 1) { // after answering each question
                                        Future.delayed(const Duration(seconds: 1),
                                            () {
                                          isLoaded = false; // reload the next question
                                          currentQuestionIndex++; // increase question index
                                          resetColors();  // reset all option colors
                                          timer!.cancel();  // reset the timer to 60secs
                                          seconds=60;
                                          startTimer();
                                        });
                                      }else{
                                        timer!.cancel();
                                      }
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    alignment: Alignment.center,
                                    width: size.width - 100,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: optionsColor[index],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: headingText(
                                        optionsList[index].toString(),
                                        blue,
                                        18),
                                  ),
                                );
                              }),
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white)),
                    );
                  }
                }))),
      ),
    );
  }
}
