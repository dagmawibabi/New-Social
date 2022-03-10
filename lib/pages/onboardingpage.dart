import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:onboarding/onboarding.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    // Light Mode Status Bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, //Colors.grey[200],
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      body: Onboarding(
        background: Colors.black,
        proceedButtonStyle: ProceedButtonStyle(
          proceedButtonRoute: (context) {
            return Navigator.pushReplacementNamed(context, "homePage");
          },
        ),
        //isSkippable = true,
        pages: [
          // Page 1
          PageModel(
            widget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/content_illustrations/1.png"),
                Container(
                    width: double.infinity,
                    child: Text('SECURED BACKUP', style: pageTitleStyle)),
                Container(
                  width: double.infinity,
                  child: Text(
                    'Keep your files in closed safe so you can\'t lose them',
                    style: pageInfoStyle,
                  ),
                ),
              ],
            ),
          ),
          // Page 2
          PageModel(
            widget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/content_illustrations/2.png"),
                Text(
                  'CHANGE AND RISE',
                  style: pageTitleStyle,
                ),
                Text(
                  'Give others access to any file or folder you choose',
                  style: pageInfoStyle,
                )
              ],
            ),
          ),
          // Page 3
          PageModel(
            widget: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/content_illustrations/4.png"),
                Text(
                  'EASY ACCESS',
                  style: pageTitleStyle,
                ),
                Text(
                  'Reach your files anytime from any devices anywhere',
                  style: pageInfoStyle,
                ),
              ],
            ),
          ),
        ],
        indicator: Indicator(
          indicatorDesign: IndicatorDesign.line(
            lineDesign: LineDesign(
              lineType: DesignType.line_nonuniform,
              lineSpacer: 25.0,
            ),
          ),
        ),

        //-------------Other properties--------------
        //Color background,
        //EdgeInsets pagesContentPadding
        //EdgeInsets titleAndInfoPadding
        //EdgeInsets footerPadding
        //SkipButtonStyle skipButtonStyle
      ),
    );
  }
}
