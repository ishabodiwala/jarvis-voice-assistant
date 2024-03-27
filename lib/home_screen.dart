import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:jarvis_voice_assistant/feature_box.dart';
import 'package:jarvis_voice_assistant/openai_services.dart';
import 'package:jarvis_voice_assistant/pallete.dart';
import 'package:jarvis_voice_assistant/secret_key.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class MyHomeScreen extends StatefulWidget {
  const MyHomeScreen({super.key});

  @override
  State<MyHomeScreen> createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  final SpeechToText speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  bool speechEnabled = false;
  String userInput = '';
  final openAIServices = OpenAIServices();
  String? generatedContent;
  String? generatedImageUrl;

  @override
  void initState() {
    super.initState();
    _initSpeechToText();
    _initTextToSpeech();
  }

  Future<void> _initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
  }

  /// This has to happen only once per app
  void _initSpeechToText() async {
    speechEnabled = await speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  Future<void> startListening() async {
    await speechToText.listen(
        onResult: _onSpeechResult, listenFor: const Duration(seconds: 80));
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      userInput = result.recognizedWords;
    });
  }

  @override
  void dispose() {
    super.dispose();
    stopListening();
    flutterTts.stop();
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("J.A.R.V.I.S"),
          leading: const Icon(Icons.menu),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            margin:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // J.A.R.V.I.S Profile
                Center(
                  child: Container(
                    height: 170,
                    width: 300,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Pallete.assistantCircleColor,
                        image: DecorationImage(
                            image: AssetImage(
                                "assets/images/jarvis.gif"))),
                  ),
                ),
                // Chat-bubble
                Visibility(
                  visible: generatedImageUrl == null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        border: Border.all(
                          color: Pallete.mainFontColor,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12.0))
                                .copyWith(topLeft: Radius.zero)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        generatedContent == null
                            ? "Welcome! What can I do for you?"
                            : generatedContent!,
                        style: TextStyle(
                          fontFamily: "Cera Pro",
                          fontSize: generatedContent == null ? 25 : 18,
                        ),
                      ),
                    ),
                  ),
                ),
                if (generatedImageUrl != null)
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(generatedImageUrl!)),
                  ),
                // Suggestion
                Visibility(
                  visible: generatedContent == null && generatedImageUrl == null,
                  child: const Text(
                    "Here are some features",
                    style: TextStyle(
                      color: Pallete.mainFontColor,
                      fontFamily: "Cera Pro",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // feature-list
                Visibility(
                  visible: generatedContent == null && generatedImageUrl == null,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FeatureBox(
                          color: Pallete.firstSuggestionBoxColor,
                          headerText: "ChatGPT",
                          descText:
                              "ChatGPT is an AI-powered chatbot developed by OpenAI, that allows you to have human-like conversations."),
                      FeatureBox(
                          color: Pallete.secondSuggestionBoxColor,
                          headerText: "DALL-E",
                          descText:
                              "DALL-E is an AI system developed by OpenAI that can create realistic images and art from a description."),
                      FeatureBox(
                          color: Pallete.thirdSuggestionBoxColor,
                          headerText: "Smart Voice Assistant",
                          descText:
                              "Get the best of both worlds with voice assistant powered by DALL-E and ChatGPT"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // floating-button for record the voice
        floatingActionButton: FloatingActionButton(
            backgroundColor: Pallete.firstSuggestionBoxColor,
            onPressed: () async {
              if (speechToText.isNotListening) {
                await startListening();
              } else {
                
                  Future.delayed(const Duration(milliseconds: 700), () async {

                    final String res =
                        await openAIServices.isArtRequest(userInput);
                    if (res.contains("https")) {
                      generatedImageUrl = res;
                      generatedContent = null;
                      setState(() {});
                    } else {
                      generatedContent = res;
                      generatedImageUrl = null;
                      await systemSpeak(res);
                      setState(() {});
                    }

                  });
                  await stopListening();
                
              }
            },
            child:
                Icon(speechToText.isNotListening ? Icons.mic_off : Icons.stop)));
  }
}
