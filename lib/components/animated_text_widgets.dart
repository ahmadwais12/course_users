import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:course_users/ui/ui_helper.dart';

class AppTypewriter extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;

  const AppTypewriter({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 80),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      repeatForever: false,
      isRepeatingAnimation: false,
      animatedTexts: [
        TypewriterAnimatedText(
          text,
          textStyle: style ?? AppText.h3(ctx: context),
          speed: duration,
          cursor: '|',
        ),
      ],
      totalRepeatCount: 1,
      displayFullTextOnTap: true,
    );
  }
}

class AppRotatingText extends StatelessWidget {
  final List<String> texts;
  final TextStyle? style;
  final Duration duration;

  const AppRotatingText({
    super.key,
    required this.texts,
    this.style,
    this.duration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      repeatForever: true,
      animatedTexts: texts.map((t) => RotateAnimatedText(
        t,
        textStyle: style ?? AppText.h3(ctx: context),
        duration: duration,
        rotateOut: true,
      )).toList(),
    );
  }
}

class AppFadingText extends StatelessWidget {
  final List<String> texts;
  final TextStyle? style;
  final Duration duration;
  final double? height;

  const AppFadingText({
    super.key,
    required this.texts,
    this.style,
    this.duration = const Duration(seconds: 2),
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final content = AnimatedTextKit(
      repeatForever: true,
      animatedTexts: texts.map((t) => FadeAnimatedText(
        t,
        textStyle: style ?? AppText.body(ctx: context),
        duration: duration,
        fadeOutBegin: 0.8,
      )).toList(),
    );
    if (height != null) {
      return SizedBox(height: height, child: content);
    }
    return content;
  }
}

class AppColorizeText extends StatelessWidget {
  final String text;
  final List<Color> colors;
  final TextStyle? baseStyle;
  final Duration duration;

  const AppColorizeText({
    super.key,
    required this.text,
    this.colors = const [
      Colors.purple,
      Colors.black87,
      Colors.pink,
      Colors.amber,
    ],
    this.baseStyle,
    this.duration = const Duration(seconds: 3),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      repeatForever: true,
      animatedTexts: [
        ColorizeAnimatedText(
          text,
          textStyle: (baseStyle ?? AppText.h2(ctx: context)).copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
          colors: colors,
          speed: duration,
        ),
      ],
    );
  }
}

class AppWavyText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const AppWavyText({
    super.key,
    required this.text,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      repeatForever: true,
      animatedTexts: [
        WavyAnimatedText(
          text,
          textStyle: style ?? AppText.h2(ctx: context),
        ),
      ],
    );
  }
}
