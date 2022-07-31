import 'package:anon_wallet/screens/onboard/remote_node_setup.dart';
import 'package:anon_wallet/screens/onboard/wallet_passphrase.dart';
import 'package:flutter/material.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({Key? key}) : super(key: key);

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  PageController pageController = PageController();
  int currentPage = 0;
  String page = "NODE CONNECTION";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      pageController.addListener(() {
        setState(() {
          if (pageController.page == 0) {
            page = "NODE CONNECTION";
          }
          if (pageController.page == 1) {
            page = "POLYSEED MNEMONIC";
          }
          if (pageController.page == 2) {
            page = "PASSPHRASE ENCRYPTION";
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double topSegment = MediaQuery.of(context).size.height / 2.8;
    double mainPager = MediaQuery.of(context).size.height - (topSegment) - 60;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
              child: Container(
            height: topSegment,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(padding: EdgeInsets.all(34)),
                Hero(
                  tag: "anon_logo",
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width / 1.7, child: Image.asset("assets/anon_logo.png")),
                ),
                Text(
                  page,
                  style: Theme.of(context).textTheme.headline5,
                )
              ],
            ),
          )),
          SliverToBoxAdapter(
            child: Container(
              height: mainPager,
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  RemoteNodeWidget(),
                  Container(
                    alignment: Alignment.center,
                    child: const Text("WIP"),
                  ),
                  WalletPassphraseWidget(),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInSine);
                },
                child: Text("Next",
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.black, fontWeight: FontWeight.w700)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
